-- DROP PROCEDURE hkpmi.hkpmi_insert_bcf_log(inout int4, in bpchar, in bpchar, in bpchar, in int4, in bpchar, in bpchar, in bpchar, in bpchar, inout bpchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_insert_bcf_log(INOUT pas_return_code integer, IN par_hospital_code VARCHAR, IN par_hkid VARCHAR, IN par_body_category VARCHAR, 
IN "par_mortuary_ID" integer, IN "par_user_ID" VARCHAR, IN par_user_hospital VARCHAR, IN "par_workstation_ID" VARCHAR, IN par_source_system VARCHAR, INOUT par_status_code VARCHAR, 
INOUT par_return_code integer, INOUT par_error_message character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rowcount INTEGER;
    var_error INTEGER;
    var_today TIMESTAMP WITHOUT TIME ZONE;
    var_hkpmi_srvr VARCHAR(20);
    var_prg_name VARCHAR(48);
    var_retcode INTEGER;
    sql$rowcount BIGINT;

BEGIN
    <<error>>
    BEGIN
        SELECT
            0
            INTO par_return_code;
        SELECT
            NULL
            INTO par_error_message;

        IF par_hkid IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO par_return_code;
                SELECT
                    'HKID should be provided'
                    INTO par_error_message;
                EXIT error;
            END;
        END IF;

        IF par_hospital_code IS NULL OR par_body_category IS NULL OR "par_mortuary_ID" IS NULL OR "par_user_ID" IS NULL OR par_user_hospital IS NULL OR "par_workstation_ID" IS NULL OR par_source_system IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO par_return_code;
                SELECT
                    'Data cannot be null'
                    INTO par_error_message;
                EXIT error;
            END;
        END IF;

        IF par_hkid IS NOT NULL THEN
            BEGIN
                SELECT
                    COUNT(*)
                    INTO var_rowcount
                    FROM patient
                    WHERE hkid = par_hkid;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                

                IF var_error != 0 OR var_rowcount != 1 THEN
                    BEGIN
                        SELECT
                            'HKID not found'
                            INTO par_error_message;
                        SELECT
                            var_error
                            INTO par_return_code;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* Check print status before insert the log */
        CALL hkpmi_get_bcf_print_status(pas_return_code, par_hospital_code, par_hkid, par_status_code, par_return_code, par_error_message);


        IF var_retcode != 0 THEN
            BEGIN
                SELECT
                    - 2
                    INTO par_return_code;
                /* Fail to call HKPMI */
                SELECT
                    'Cannot check printing status in HKPMI'
                    INTO par_error_message;
                EXIT error;
            END;
        END IF;
        SELECT
            localtimestamp
            INTO var_today;
        INSERT INTO bcf_log (hospital_code, hkid, system_datetime, body_category, mortuary_id, update_by, update_hospital, workstation_id, source_system, update_datetime)
        VALUES (par_hospital_code, par_hkid, var_today, par_body_category, "par_mortuary_ID", "par_user_ID", par_user_hospital, "par_workstation_ID", par_source_system, var_today);
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        

        IF var_error != 0 OR var_rowcount != 1 THEN
            BEGIN
                SELECT
                    - 3
                    INTO par_return_code;
                SELECT
                    'Fail to update bcf_log'
                    INTO par_error_message;
                EXIT error;
            END;
        END IF;
    END;

    IF par_return_code != 0 THEN
        pas_return_code := - 1;
        RETURN;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_insert_bcf_log" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
