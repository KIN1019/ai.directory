-- DROP PROCEDURE hpi.hasp_update_access(inout int4, in varchar, in varchar, in varchar, in int4, in timestamp, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.hasp_update_access(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_hkid character varying, IN par_patient_key character varying, IN par_access_code integer, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_last_update_datetime timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/* -- add hosp_code by WL on 27 July 1999 for HPI --- */
DECLARE
    /* --@hosp_code				char(03) , */
    var_cpi_flag CHAR(01);
    var_retcode INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_error_msg VARCHAR(255);
    var_patient_name CHAR(48);
    var_sex CHAR(01);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
    <<end_exit>>
    BEGIN
        /* --- remark hosp_code by WL on 27 July 1999 for HPI --- */
        /* --- Remarked by hosp_code by WL on 27 July 1999 for HPI-- */
        
        /* get hospital code */
        
        /*
        select @hosp_code = Text_value from Hospital_control
        	where Type = "hospital_code"
        
        select @rowcount = @@rowcount, @error = @@error
        if @rowcount != 1
        begin
        	select @retcode = 200016
        	raiserror @retcode
        	goto end_exit
        end
        */
        
        /* get cpi flag */
        /* -- Modified by WL for HPI on 27 July 1999 -- */
        SELECT
            Text_value
            INTO var_cpi_flag
            FROM Hospital_control
            WHERE Type = 'cpi_server' AND Hospital_code = par_hosp_code;
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
                    200026
                    INTO var_retcode;
                RAISE EXCEPTION '% ', 'Incorrect stored proc for CPI server' USING ERRCODE := var_retcode;
                EXIT end_exit;
            END;
        END IF;
        /* -- remove cpi.. by WL on 27 July 1999 for HPI --- */
        
        /* --exec @retcode = cpi..cpi_patient_upd_access */
        call cpi_patient_upd_access(pas_return_code, par_hosp_code, par_hkid,
       par_patient_key, par_access_code, par_transaction_datetime, 
      par_hosp_code, par_update_by, par_last_update_datetime, 'ADT'::character varying);

        IF pas_return_code != 0 THEN
            BEGIN
                /* -- remove cpi.. by WL on 27 July 1999 for HPI --- */
                
                /* --select @error_msg = messages from cpi..error_msgs */
                SELECT
                    messages
                    INTO var_error_msg
                    FROM error_msgs
                    WHERE error_code = pas_return_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_rowcount != 1 THEN
                    BEGIN
                        SELECT
                            CONCAT('Call cpi function failed with return code ',
                            CASE CAST (pas_return_code AS VARCHAR(8))
                                WHEN '' THEN ''
                                ELSE CAST (pas_return_code AS VARCHAR(8))
                            END)
                            INTO var_error_msg;
                    END;
                END IF;
                RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := '200026';
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
            INSERT INTO Event_log (hospital_code, system_datetime, type, hkid, name, sex, dob, t_prk, pmi_access_code, user_id, upload_status)
            VALUES (par_hosp_code, par_transaction_datetime, '034', par_hkid, var_patient_name, var_sex, var_dob, par_patient_key, par_access_code, par_update_by, 'N');
             raise notice 'hasp_update_access(118)[INSERT]Event_log,par_hkid=%,system_datetime => [%]',par_hkid,par_transaction_datetime;
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
    END;
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_update_access" OWNER TO "HPI_SCHEMA_OWNER_ROLE";