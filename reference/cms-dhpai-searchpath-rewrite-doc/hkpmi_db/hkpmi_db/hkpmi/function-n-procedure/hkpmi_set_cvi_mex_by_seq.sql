-- DROP PROCEDURE hkpmi.hkpmi_set_cvi_mex_by_seq(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, in int4, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_set_cvi_mex_by_seq(INOUT pas_return_code integer, IN par_system_id character varying, IN par_patient_key character varying, IN par_mex_indicator character varying, IN par_issue_by_inst_english_name character varying, IN par_issue_by_inst_chinese_name character varying, IN "par_issue_by_RMP_english_name" character varying, IN "par_issue_by_RMP_chinese_name" character varying, IN par_issue_date timestamp without time zone, IN par_valid_till_date timestamp without time zone, IN par_upload_src_system character varying, IN par_check_datetime character varying, IN par_batch_seq integer, INOUT par_return_code integer, INOUT par_return_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_begin_tran VARCHAR(1);
    var_hkid VARCHAR(12);
    var_source_system VARCHAR(5);
    var_status VARCHAR(20);
    var_vac_record_key VARCHAR(30);
    var_dt_check_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_error_msg VARCHAR(255);
    var_error_code INTEGER;
    var_rowcount INTEGER;
    var_log_datetime TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            par_system_id
            INTO var_source_system;
        SELECT
            hkid
            INTO var_hkid
            FROM patient
            WHERE patient_key = par_patient_key;

        IF par_batch_seq <= 0 THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Batch seq. must be started from 1!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;

        IF var_hkid IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Patient record not found!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;

        IF var_source_system NOT IN ('ADT', 'OPAS', 'EAI', 'IPAS', 'CVSE') THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Source system code is invalid!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;

        IF par_check_datetime IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Check datetime is invalid!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;

        IF par_check_datetime IS NOT NULL AND LENGTH(par_check_datetime) >= 17 THEN
            BEGIN
                SELECT
                    CAST (par_check_datetime AS TIMESTAMP WITHOUT TIME ZONE)
                    INTO var_dt_check_datetime;
            END;
        ELSE
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Check datetime is invalid!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;
        SELECT
            'Y'
            INTO var_begin_tran;
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
        	begin
        		select @begin_tran = 'Y'
        		begin transaction
        	end
        	else
        	begin
        		select @begin_tran = 'S'
        		save transaction hkpmi_set_cvi_mex_by_seq
        	end
        */
       
        SELECT
            vac_record_key
            INTO var_vac_record_key
            FROM hkpmi_patient_cvi_record
            WHERE patient_key = par_patient_key::VARCHAR;

        IF var_vac_record_key IS NOT NULL THEN
            BEGIN
                SELECT
                    'NO_RECORD'
                    INTO var_status;

                BEGIN
                    IF par_batch_seq = 1 THEN
                        BEGIN
                            UPDATE hkpmi_patient_cvi_record
                            SET update_datetime = localtimestamp, status = var_status, source_system = var_source_system, last_check_datetime = var_dt_check_datetime
                                WHERE patient_key = par_patient_key::VARCHAR;
                        END;
                    ELSE
                        BEGIN
                            UPDATE hkpmi_patient_cvi_record
                            SET source_system = var_source_system, last_check_datetime = var_dt_check_datetime
                                WHERE patient_key = par_patient_key::VARCHAR;
                        END;
                    END IF;
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
                            'Fail to update hkpmi_patient_cvi_record!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                SELECT
                    'NO_RECORD'
                    INTO var_status;

                select concat(par_patient_key,'_',to_char(localtimestamp,'YYYYMMDD') ) into var_vac_record_key;
                BEGIN
                    INSERT INTO hkpmi_patient_cvi_record (source_system, patient_key, vac_record_key, status, last_check_datetime, create_datetime, update_datetime)
                    VALUES (var_source_system, par_patient_key, var_vac_record_key, var_status, var_dt_check_datetime, localtimestamp, localtimestamp);
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
                            'Fail to insert hkpmi_patient_cvi_record!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;

        IF EXISTS (SELECT
            1
            FROM hkpmi_patient_cvi_mex
            WHERE patient_key = par_patient_key::VARCHAR) THEN
            BEGIN
                BEGIN
                    UPDATE hkpmi_patient_cvi_mex
                    SET source_system = var_source_system, mex_indicator = par_mex_indicator, issue_by_inst_english_name = par_issue_by_inst_english_name, issue_by_inst_chinese_name = par_issue_by_inst_chinese_name, issue_by_RMP_english_name = "par_issue_by_RMP_english_name", issue_by_RMP_chinese_name = "par_issue_by_RMP_chinese_name", issue_date = par_issue_date, valid_till_date = par_valid_till_date, upload_src_system = par_upload_src_system, update_datetime = localtimestamp
                        WHERE patient_key = par_patient_key::VARCHAR;
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
                            'Fail to update hkpmi_patient_cvi_mex!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                BEGIN
                    INSERT INTO hkpmi_patient_cvi_mex (source_system, patient_key, vac_record_key, mex_indicator, issue_by_inst_english_name, issue_by_inst_chinese_name, issue_by_rmp_english_name, issue_by_rmp_chinese_name, issue_date, valid_till_date, upload_src_system, create_datetime, update_datetime)
                    VALUES (var_source_system, par_patient_key, var_vac_record_key, par_mex_indicator, par_issue_by_inst_english_name, par_issue_by_inst_chinese_name, "par_issue_by_RMP_english_name", "par_issue_by_RMP_chinese_name", par_issue_date, par_valid_till_date, par_upload_src_system, localtimestamp, localtimestamp);
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
                            'Fail to insert hkpmi_patient_cvi_mex!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        SELECT
            NULL
            INTO par_return_message;
        SELECT
            0
            INTO par_return_code;

--        IF var_begin_tran = 'Y' THEN
--            BEGIN
--                /*
--                [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
--                commit transaction
--                */
--            END;
--        ELSE
--            IF var_begin_tran = 'S' THEN
--                BEGIN
--                    /*
--                    [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
--                    commit hkpmi_set_cvi_mex_by_seq
--                    */
--                END;
--            END IF;
--        END IF;
        pas_return_code := 0;
        RETURN;
    END;
    SELECT
        var_error_msg
        INTO par_return_message;
    SELECT
        - 1
        INTO par_return_code;

    IF var_begin_tran = 'Y' THEN
        BEGIN
            --ROLLBACK;
            raise exception '';
        END;
    ELSE
        IF var_begin_tran = 'S' THEN
            BEGIN
                /*
                [9996 - Severity CRITICAL - Transformer error occurred in statement. Please submit report to developers.]
                rollback hkpmi_set_cvi_mex_by_seq
                */
                BEGIN
                END;
            END;
        END IF;
    END IF;
    pas_return_code := - 1;
    RETURN;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_set_cvi_mex_by_seq" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";