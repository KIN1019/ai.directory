-- DROP PROCEDURE hpi.cpi_set_pas_func_whitelist(inout int4, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, inout varchar);

CREATE OR REPLACE PROCEDURE cpi_set_pas_func_whitelist(INOUT pas_return_code integer, IN par_hospital_code character, IN par_user_id character, IN par_whitelist_type character, IN par_last_updated_by character, IN par_cvforaereg character, IN par_cvforipreg character, IN par_cvforpmienq character, IN par_cvforhkpmienq character, IN par_cvforupdpatdemo character, IN par_cvforupdpatdemononmajorkey character, IN par_cvforupdconfi character, INOUT par_return_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_last_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_whitelist_group_ae VARCHAR(100);
    var_whitelist_group_ip VARCHAR(100);
    var_whitelist_group_pmi_enq VARCHAR(100);
    var_whitelist_group_hkpmi_enq VARCHAR(100);
    var_whitelist_group_upd_confi VARCHAR(100);
    var_whitelist_group_upd_demo VARCHAR(100);
    var_whitelist_group_upd_demo_non_major VARCHAR(100);
    var_begin_tran VARCHAR(1);
    var_rowcount INTEGER;
    var_error_msg VARCHAR(255);
    var_error_code INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
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
        		save transaction cpi_set_pas_func_whitelist
            end
        */
        SELECT
            'AE_REGISTRATION'
            INTO var_whitelist_group_ae;
        SELECT
            'IP_REGISTRATION'
            INTO var_whitelist_group_ip;
        SELECT
            'ENQ_OF_PMI'
            INTO var_whitelist_group_pmi_enq;
        SELECT
            'ENQ_OF_HKPMI'
            INTO var_whitelist_group_hkpmi_enq;
        SELECT
            'UPD_PATIENT_CONFIDENTIALITY'
            INTO var_whitelist_group_upd_confi;
        SELECT
            'UPD_PATIENT_DEMO_DATA'
            INTO var_whitelist_group_upd_demo;
        SELECT
            'UPD_PATIENT_DEMO_DATA(NON-MAJOR-KEYS)'
            INTO var_whitelist_group_upd_demo_non_major;
        /* --AE_REGISTRATION */
        IF EXISTS (SELECT
            *
            FROM pas_func_whitelist
            WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_ae) THEN
            BEGIN
                BEGIN
                    UPDATE pas_func_whitelist
                    SET control_value = par_cvForAeReg, last_updated_by = par_last_updated_by, last_update_datetime = timestamp_convert(localtimestamp)
                        WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_ae;
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to update pas_func_whitelist!'
                            INTO var_error_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                BEGIN
                    INSERT INTO pas_func_whitelist (hosp_code, user_id, whitelist_type, whitelist_group, control_value, last_updated_by, last_update_datetime)
                    VALUES (par_hospital_code, par_user_id, par_whitelist_type, var_whitelist_group_ae, par_cvForAeReg, par_last_updated_by, timestamp_convert(localtimestamp));
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to insert pas_func_whitelist!'
                            INTO var_error_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        END IF;
        /* --IP_REGISTRATION */
        IF EXISTS (SELECT
            *
            FROM pas_func_whitelist
            WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_ip) THEN
            BEGIN
                BEGIN
                    UPDATE pas_func_whitelist
                    SET control_value = par_cvForIpReg, last_updated_by = par_last_updated_by, last_update_datetime = timestamp_convert(localtimestamp)
                        WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_ip;
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to update pas_func_whitelist!'
                            INTO var_error_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                BEGIN
                    INSERT INTO pas_func_whitelist (hosp_code, user_id, whitelist_type, whitelist_group, control_value, last_updated_by, last_update_datetime)
                    VALUES (par_hospital_code, par_user_id, par_whitelist_type, var_whitelist_group_ip, par_cvForIpReg, par_last_updated_by, timestamp_convert(localtimestamp));
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to insert pas_func_whitelist!'
                            INTO var_error_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        END IF;
        /* --ENQ_OF_PMI */
        IF EXISTS (SELECT
            *
            FROM pas_func_whitelist
            WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_pmi_enq) THEN
            BEGIN
                BEGIN
                    UPDATE pas_func_whitelist
                    SET control_value = par_cvForPmiEnq, last_updated_by = par_last_updated_by, last_update_datetime = timestamp_convert(localtimestamp)
                        WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_pmi_enq;
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to update pas_func_whitelist!'
                            INTO var_error_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                BEGIN
                    INSERT INTO pas_func_whitelist (hosp_code, user_id, whitelist_type, whitelist_group, control_value, last_updated_by, last_update_datetime)
                    VALUES (par_hospital_code, par_user_id, par_whitelist_type, var_whitelist_group_pmi_enq, par_cvForPmiEnq, par_last_updated_by, timestamp_convert(localtimestamp));
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to insert pas_func_whitelist!'
                            INTO var_error_msg;
                       /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        END IF;
        /* --ENQ_OF_HKPMI */
        IF EXISTS (SELECT
            *
            FROM pas_func_whitelist
            WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_hkpmi_enq) THEN
            BEGIN
                BEGIN
                    UPDATE pas_func_whitelist
                    SET control_value = par_cvForHkpmiEnq, last_updated_by = par_last_updated_by, last_update_datetime = timestamp_convert(localtimestamp)
                        WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_hkpmi_enq;
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to update pas_func_whitelist!'
                            INTO var_error_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                BEGIN
                    INSERT INTO pas_func_whitelist (hosp_code, user_id, whitelist_type, whitelist_group, control_value, last_updated_by, last_update_datetime)
                    VALUES (par_hospital_code, par_user_id, par_whitelist_type, var_whitelist_group_hkpmi_enq, par_cvForHkpmiEnq, par_last_updated_by, timestamp_convert(localtimestamp));
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to insert pas_func_whitelist!'
                            INTO var_error_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        END IF;
        /* --UPD_PATIENT_CONFIDENTIALITY */
        IF EXISTS (SELECT
            *
            FROM pas_func_whitelist
            WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_upd_confi) THEN
            BEGIN
                BEGIN
                    UPDATE pas_func_whitelist
                    SET control_value = par_cvForUpdConfi, last_updated_by = par_last_updated_by, last_update_datetime = timestamp_convert(localtimestamp)
                        WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_upd_confi;
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to update pas_func_whitelist!'
                            INTO var_error_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                BEGIN
                    INSERT INTO pas_func_whitelist (hosp_code, user_id, whitelist_type, whitelist_group, control_value, last_updated_by, last_update_datetime)
                    VALUES (par_hospital_code, par_user_id, par_whitelist_type, var_whitelist_group_upd_confi, par_cvForUpdConfi, par_last_updated_by, timestamp_convert(localtimestamp));
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to insert pas_func_whitelist!'
                            INTO var_error_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        END IF;
        /* --UPD_PATIENT_DEMO_DATA */
        IF EXISTS (SELECT
            *
            FROM pas_func_whitelist
            WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_upd_demo) THEN
            BEGIN
                BEGIN
                    UPDATE pas_func_whitelist
                    SET control_value = par_cvForUpdPatDemo, last_updated_by = par_last_updated_by, last_update_datetime = timestamp_convert(localtimestamp)
                        WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_upd_demo;
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to update pas_func_whitelist!'
                            INTO var_error_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                BEGIN
                    INSERT INTO pas_func_whitelist (hosp_code, user_id, whitelist_type, whitelist_group, control_value, last_updated_by, last_update_datetime)
                    VALUES (par_hospital_code, par_user_id, par_whitelist_type, var_whitelist_group_upd_demo, par_cvForUpdPatDemo, par_last_updated_by, timestamp_convert(localtimestamp));
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to insert pas_func_whitelist!'
                            INTO var_error_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        END IF;
        /* --UPD_PATIENT_DEMO_DATA(NON-MAJOR-KEYS) */
        IF EXISTS (SELECT
            *
            FROM pas_func_whitelist
            WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_upd_demo_non_major) THEN
            BEGIN
                BEGIN
                    UPDATE pas_func_whitelist
                    SET control_value = par_cvForUpdPatDemoNonMajorKey, last_updated_by = par_last_updated_by, last_update_datetime = timestamp_convert(localtimestamp)
                        WHERE hosp_code = par_hospital_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND whitelist_group = var_whitelist_group_upd_demo_non_major;
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to update pas_func_whitelist!'
                            INTO var_error_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                BEGIN
                    INSERT INTO pas_func_whitelist (hosp_code, user_id, whitelist_type, whitelist_group, control_value, last_updated_by, last_update_datetime)
                    VALUES (par_hospital_code, par_user_id, par_whitelist_type, var_whitelist_group_upd_demo_non_major, par_cvForUpdPatDemoNonMajorKey, par_last_updated_by, timestamp_convert(localtimestamp));
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
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Fail to insert pas_func_whitelist!'
                            INTO var_error_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        END IF;
        SELECT
            NULL
            INTO par_return_message;
        SELECT
            0
            INTO pas_return_code;

        /*IF var_begin_tran = 'Y' THEN
            BEGIN
                /*
                [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                commit transaction
                */
            END;
        END IF;*/
        /* remark the commit save tran checkpoint otherwise the outer SP cannot rollback the transactions done in the inner SP */
        /* Ref: https://simplesqltutorials.com/rollback-mistake-in-stored-procedure/ */
        
        /*
        else if @begin_tran = 'S'
            begin
        		commit cpi_set_pas_func_whitelist
            end
        */
        pas_return_code := 0;
        RETURN;
    END;
   
   
   	EXCEPTION
        WHEN OTHERS THEN
   	    	BEGIN
	   	    	SELECT
			        var_error_msg
			        INTO par_return_message;
			    SELECT
			        var_error_code
			        INTO pas_return_code;
	   	    END;
    

    /*  
    IF var_begin_tran = 'Y' THEN
        BEGIN
            ROLLBACK;
        END;
    ELSE
        IF var_begin_tran = 'S' THEN
            BEGIN
                /*
                [9996 - Severity CRITICAL - Transformer error occurred in statement. Please submit report to developers.]
                rollback cpi_set_pas_func_whitelist
                */
                BEGIN
                END;
            END;
        END IF;
    END IF;
    */
    pas_return_code := - 1;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_set_pas_func_whitelist" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
