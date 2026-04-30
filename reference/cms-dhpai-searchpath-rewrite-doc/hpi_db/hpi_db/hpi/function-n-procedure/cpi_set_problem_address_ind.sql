-- DROP PROCEDURE cpi_set_problem_address_ind(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE cpi_set_problem_address_ind(INOUT pas_return_code integer, IN par_hkid character varying, IN par_set_type character varying, IN par_hospital_code character varying, IN par_source_system character varying, IN par_user_id character varying, INOUT par_return_code integer DEFAULT 0, INOUT par_return_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_error_code INTEGER;
    var_hosp_code CHAR(3);
    var_access_code INTEGER;
    var_hex INTEGER;
    var_patient_key CHAR(8);
    var_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_rowcount INTEGER;
    var_ret_code INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN

        /* --@update_access_code char(1) */
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
        	begin
        		select @return_message = 'The stored procedure should be within a transaction!',
        		@error_code = 20000
        		goto return_error
        	end
        */
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support SAVE TRAN cpi_set_problem_address_ind command. Perform a manual conversion.]
        save transaction cpi_set_problem_address_ind
        */
		 -- SAVEPOINT cpi_set_problem_address_ind;
        SELECT
            0
            INTO var_error_code;
        /* --@update_access_code = 'N' */
        IF par_hkid IS NULL THEN
            BEGIN
                SELECT
                    'HKID cannot be null', - 1
                    INTO par_return_message, var_error_code;
                EXIT return_error;
            END;
        END IF;

        IF par_set_type NOT IN ('Y', 'N') THEN
            BEGIN
                SELECT
                    'Set type can be either Y or N only!', - 1
                    INTO par_return_message, var_error_code;
                EXIT return_error;
            END;
        END IF;

        IF par_hospital_code IS NULL THEN
            BEGIN
                SELECT
                    'Hospital code cannot be null', - 1
                    INTO par_return_message, var_error_code;
                EXIT return_error;
            END;
        END IF;

        IF par_source_system IS NULL THEN
            BEGIN
                SELECT
                    'Source system cannot be null', - 1
                    INTO par_return_message, var_error_code;
                EXIT return_error;
            END;
        END IF;

        IF par_user_id IS NULL THEN
            BEGIN
                SELECT
                    'User ID cannot be null', - 1
                    INTO par_return_message, var_error_code;
                EXIT return_error;
            END;
        END IF;
        SELECT
            hospital_code
            INTO var_hosp_code
            FROM hospital
            WHERE hospital_code = par_hospital_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF var_rowcount != 1 THEN
            BEGIN
                SELECT
                    'Invalid hospital code', - 1
                    INTO par_return_message, var_error_code;
                EXIT return_error;
            END;
        END IF;
        SELECT
            update_dtm, patient_key, access_code
            INTO var_update_dtm, var_patient_key, var_access_code
            FROM cpi_patient
            WHERE hkid = par_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;


        IF var_rowcount != 1 THEN
            BEGIN
                SELECT
                    'Patient not found!', - 1
                    INTO par_return_message, var_error_code;
                EXIT return_error;
            END;
        END IF;
        /* Set on */

        IF par_set_type = 'Y' THEN
            /* --and @access_code & 2 = 2 */
            BEGIN
                CALL cpi_get_int_by_bin(pas_return_code, 'YNYYYYYYYYYYYYYYYYYYYYYYYYYYYYY', var_hex);
                SELECT
                    var_access_code & var_hex
                    INTO var_access_code;
                /* --select @update_access_code = 'Y' */
            END;
        END IF;
        /* Set off */

        IF par_set_type = 'N' THEN
            /* --and @access_code & 2 = 0 */
            BEGIN
                CALL cpi_get_int_by_bin(pas_return_code, 'NYNNNNNNNNNNNNNNNNNNNNNNNNNNNNN', var_hex);
                SELECT
                    var_access_code | var_hex
                    INTO var_access_code;
                /* --select @update_access_code = 'Y' */
            END;
        END IF;
        /* --if @update_access_code = 'Y' */
        /* --begin */
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_system_dtm;
        CALL cpi_patient_upd_access(var_ret_code, par_hospital_code, par_hkid, var_patient_key, var_access_code, var_system_dtm, par_hospital_code, par_user_id, var_update_dtm, par_source_system);
        /* --@system_dtm, */
        IF var_ret_code != 0 THEN
            SELECT
                var_ret_code, 'Fail to update access code of patient!'
                INTO var_error_code, par_return_message;
        END IF;
        /* --end */
    END;

    IF var_error_code <> 0 THEN
        BEGIN
            /*
            [9996 - Severity CRITICAL - Transformer error occurred in statement. Please submit report to developers.]
            rollback cpi_set_problem_address_ind
            */
		--	ROLLBACK TO SAVEPOINT cpi_set_problem_address_ind;
            SELECT
                1
                INTO par_return_code;
            pas_return_code := var_error_code;
            RETURN;
        END;
    ELSE
        BEGIN

            SELECT
                0
                INTO par_return_code;
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_set_problem_address_ind" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
