-- DROP PROCEDURE hpi.cpi_update_patient_privacy(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_update_patient_privacy(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_patient_key character varying, IN par_privacy character varying, IN par_case_no character varying DEFAULT NULL::character varying, IN par_source_system character varying DEFAULT NULL::character varying, IN par_function_id integer DEFAULT NULL::integer, IN par_update_by character varying DEFAULT NULL::character varying, INOUT par_return_code integer DEFAULT 0, INOUT par_return_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_begin_tran VARCHAR(1);
    var_error_code INTEGER;
    var_error_message VARCHAR(255);
    var_rowcount INTEGER;
    var_hkid VARCHAR(12);
    var_case_patient_key VARCHAR(8);
    var_is_update VARCHAR(1);
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            'N'
            INTO var_is_update;
        /*
        if @source_system NOT in ('IPAS','CMS') begin
        	select @error_code = -1
        	select @error_message = 'SP error: Invalid source system [' + @source_system + ']'
        	goto return_error
        end
        */
        IF par_privacy NOT IN ('Y', 'N') THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    CONCAT('SP error: Invalid privacy flag [', par_privacy, ']')
                    INTO var_error_message;
                RAISE EXCEPTION '%', var_error_message;
                EXIT return_error;
            END;
        END IF;
        SELECT
            hkid
            INTO var_hkid
            FROM cpi_patient
            WHERE patient_key = par_patient_key;

        IF var_hkid IS NULL OR var_hkid = '' THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    CONCAT('SP error: Unexpected patient key [', par_patient_key, ']')
                    INTO var_error_message;
                RAISE EXCEPTION '%', var_error_message;
                EXIT return_error;
            END;
        END IF;
        /*
        if @case_no is not null and @case_no <> '' begin
        	select @case_patient_key = patient_key
        	from cpi_case
        	where hospital_code = @hospital_code and case_no = @case_no
        
        	if @case_patient_key != @patient_key begin
        		select @error_code = -1
        		select @error_message = 'SP error: Unexpected case no [' + @case_no + ']'
        		goto return_error
        	end
        end
        */
        /* --------------------------------------- */
        /* ----- Start Insert/Update ------------- */
        
        /* --------------------------------------- */
        
        /* --========== Generic Transaction Handling ============================== */
        /* Since PAS is all using non-XA mode without opening transaction in application side, */
        /* it's needed to open transaction in stored procedure. */
        /* If @@trancount is not 0, the parent/caller SP will open/commit transaction */
        /* (but parent/caller SP is not responsible for child SP rollback) */
        
        /* --========== End - Generic Transaction Handling ======================== */
        IF EXISTS (SELECT
            1
            FROM cpi_privacy_flag
            WHERE patient_key = par_patient_key) THEN
            BEGIN
                BEGIN
                    UPDATE cpi_privacy_flag
                    SET privacy_flag = par_privacy, last_update_system = par_source_system, last_update_function_id = par_function_id, last_update_user_id = par_update_by, last_update_datetime = timestamp_convert(localtimestamp)
                        WHERE patient_key = par_patient_key AND hospital_code = par_hospital_code;
                    var_error_code := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error_code := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_error_code <> 0 OR var_rowcount <> 1 THEN
                    BEGIN
                        SELECT
                            CONCAT('SP error when updating privacy flag table, rowcount: ',
                            CASE CAST (var_rowcount AS VARCHAR(3))
                                WHEN '' THEN ''
                                ELSE CAST (var_rowcount AS VARCHAR(3))
                            END)
                            INTO var_error_message;
                        RAISE EXCEPTION '%', var_error_message;
                        EXIT return_error;
                    END;
                END IF;
                SELECT
                    'Y'
                    INTO var_is_update;
            END;
        ELSE
            BEGIN
                /* Insert the privacy indicator table only if the flag is turned on by IPAS function */
                /* Skip insertion by CMS Discharge which would turn off the flag automatically */
                /* Internal review: No real case usage for inserting 'N' in privacy indicator table */
                IF par_privacy = 'Y' THEN
                    BEGIN
                        BEGIN
                            INSERT INTO cpi_privacy_flag
                            VALUES (par_hospital_code, par_patient_key,
                            /* --@case_no, */
                            par_privacy, par_source_system, par_function_id, par_update_by, timestamp_convert(localtimestamp));
                            var_error_code := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error_code := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF var_error_code <> 0 OR var_rowcount <> 1 THEN
                            BEGIN
                                SELECT
                                    CONCAT('SP error when inserting privacy flag table, rowcount: ',
                                    CASE CAST (var_rowcount AS VARCHAR(3))
                                        WHEN '' THEN ''
                                        ELSE CAST (var_rowcount AS VARCHAR(3))
                                    END)
                                    INTO var_error_message;
                                RAISE EXCEPTION '%', var_error_message;
                                EXIT return_error;
                            END;
                        END IF;
                        SELECT
                            'Y'
                            INTO var_is_update;
                    END;
                END IF;
            END;
        END IF;
        /* Insert update log only if the above update/insert action is done */

        IF var_is_update = 'Y' THEN
            BEGIN
                BEGIN
                    INSERT INTO cpi_privacy_flag_update_log
                    VALUES (par_hospital_code, par_patient_key, par_patient_key, par_case_no, par_privacy, par_source_system, par_function_id, par_update_by, timestamp_convert(localtimestamp));
                    var_error_code := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error_code := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_error_code <> 0 OR var_rowcount <> 1 THEN
                    BEGIN
                        SELECT
                            CONCAT('SP error when inserting privacy flag update log table, rowcount: ',
                            CASE CAST (var_rowcount AS VARCHAR(3))
                                WHEN '' THEN ''
                                ELSE CAST (var_rowcount AS VARCHAR(3))
                            END)
                            INTO var_error_message;
                        RAISE EXCEPTION '%', var_error_message;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* --========== Generic Transaction Handling ============================== */
        /* There is partial rollback but no partial commit */
        /* Don't commit as below or the global @@trancount will be affected and */
        /* any stored procedure reading @@trancount after this will be affected */
        /* (E.g. cpi_patient_upd_access will return error if @@trancount is 0) */
        
        /* --	else if @begin_tran = 'S' begin */
        
        /* --		commit cpi_update_patient_privacy */
        
        /* --	end */
        
        /* --========== End - Generic Transaction Handling ======================== */
        SELECT
            0
            INTO par_return_code;
        pas_return_code := par_return_code;
        RETURN;
    END;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'cpi_update_patient_privacy error';
    /* --raiserror @error_code @error_message */
    SELECT
        var_error_code
        INTO par_return_code;
    SELECT
        var_error_message
        INTO par_return_message;
    /* --========== Generic Transaction Handling ============================== */
    
    /* --========== End - Generic Transaction Handling ======================== */
    SELECT
        - 1
        INTO par_return_code;
    pas_return_code := par_return_code;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_update_patient_privacy" OWNER TO "HPI_SCHEMA_OWNER_ROLE";