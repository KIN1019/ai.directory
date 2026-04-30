-- DROP PROCEDURE hpi.hasp_set_problem_address_ind(inout int4, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_set_problem_address_ind(INOUT pas_return_code integer, IN par_hkid character varying, IN par_set_type character varying, IN par_user_id character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_hospital_code CHAR(3);
    var_ret_code INTEGER;
    var_return_message VARCHAR(255);
    var_return_code int;
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            NULL
            INTO var_return_message;

        IF par_hkid IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_ret_code;
                RAISE EXCEPTION USING ERRCODE := var_return_message;
                EXIT return_error;
            END;
        END IF;

        IF par_set_type NOT IN ('Y', 'N') THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_ret_code;
                RAISE EXCEPTION USING ERRCODE := var_return_message;
                EXIT return_error;
            END;
        END IF;

        IF par_user_id IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_ret_code;
                RAISE EXCEPTION USING ERRCODE := var_return_message;
                EXIT return_error;
            END;
        END IF;
        SELECT
            Hospital_code
            INTO var_hospital_code
            FROM Hospital;
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
        begin transaction
        */
        CALL cpi_set_problem_address_ind(var_return_code, par_hkid, par_set_type, var_hospital_code, 'ADT', par_user_id, var_ret_code, var_return_message);

        IF var_ret_code != 0 THEN
            BEGIN
                --ROLLBACK;
                RAISE EXCEPTION USING ERRCODE := var_return_message;
            END;
        ELSE
            
        END IF;
    END;
    pas_return_code := var_ret_code;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_set_problem_address_ind" OWNER TO "HPI_SCHEMA_OWNER_ROLE";