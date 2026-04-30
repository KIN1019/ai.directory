-- DROP PROCEDURE hpi.web_hasp_update_access(inout int4, in varchar, in varchar, in varchar, in int4, in timestamp, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_update_access(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_hkid character varying, IN par_patient_key character varying, IN par_access_code integer, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_last_update_datetime timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/* -- add hosp_code by WL on 27 July 1999 for HPI --- */
DECLARE
    var_cpi_flag VARCHAR(01);
    var_retcode INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_error_msg VARCHAR(255);
    var_patient_name VARCHAR(48);
    var_sex VARCHAR(01);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
    <<end_exit>>
    BEGIN
        /* --- remark hosp_code by WL on 27 July 1999 for HPI --- */
        
        /* get cpi flag */
        /* -- Modified by WL for HPI on 27 July 1999 -- */
        SELECT
            text_value
            INTO var_cpi_flag
            FROM hospital_control
            WHERE "type" = 'cpi_server' AND hospital_code = par_hosp_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                SELECT
                    var_error
                    INTO var_retcode;
                EXIT end_exit;
            END;
        END IF;

        IF var_rowcount != 1 THEN
            BEGIN
                SELECT
                    20026
                    INTO var_retcode;
--                RAISE NOTICE '1 % %', 20026, var_error_msg;
                RAISE EXCEPTION '% ', 'Incorrect stored proc for CPI server' USING ERRCODE := var_retcode;
                EXIT end_exit;
            END;
        END IF;

        /* -- remove cpi.. by WL on 27 July 1999 for HPI --- */        
        /* --exec @retcode = cpi..cpi_patient_upd_access */
        CALL cpi_patient_upd_access(var_retcode, par_hosp_code, par_hkid, par_patient_key, par_access_code, par_transaction_datetime, par_hosp_code, par_update_by, par_last_update_datetime, 'ADT');
--        RAISE NOTICE 'call cpi_patient_upd_access var_retcode=%', var_retcode;
        IF var_retcode != 0 THEN
            BEGIN
                /* -- remove cpi.. by WL on 27 July 1999 for HPI --- */
                /* --select @error_msg = messages from cpi..error_msgs */
                SELECT
                    messages
                    INTO var_error_msg
                    FROM error_msgs
                    WHERE error_code = var_retcode;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_rowcount != 1 THEN
                    BEGIN
                        SELECT
                            CONCAT('Call cpi function failed with return code ',
                            CASE var_retcode::VARCHAR(8)
                                WHEN '' THEN ' '
                                ELSE var_retcode::VARCHAR(8)
                            END)
                            INTO var_error_msg;
                    END;
                END IF;
--                RAISE NOTICE '2 % %', 20026, var_error_msg;
                RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := 20026;
                EXIT end_exit;
            END;
        END IF;
        /* --- Remove cpi.. by WL on 27 July 1999 for HPI --- */
        SELECT
            patient_name, sex, dob
            INTO var_patient_name, var_sex, var_dob
            /* --from  cpi..cpi_patient */
            FROM cpi_patient
            WHERE patient_key = par_patient_key AND hkid = par_hkid;

        BEGIN
            INSERT INTO event_log (hospital_code, system_datetime, type, hkid, name, sex, dob, t_prk, pmi_access_code, user_id, upload_status)
            	VALUES (par_hosp_code, par_transaction_datetime, '034', par_hkid, var_patient_name, var_sex, var_dob, par_patient_key, par_access_code, par_update_by, 'N');
            var_retcode := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_retcode := 1;
        END;

        IF var_retcode != 0 THEN
            BEGIN
                EXIT end_exit;
            END;
        END IF;

	        pas_return_code := var_retcode;
	        RETURN;
   	    END;
    --RAISE EXCEPTION '%', var_retcode USING ERRCODE := var_retcode;
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "web_hasp_update_access" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
