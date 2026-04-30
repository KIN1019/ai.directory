CREATE OR REPLACE PROCEDURE opas_update_pp(INOUT pas_return_code int, IN par_hospital_code CHAR, IN par_case_no CHAR, IN par_specialty CHAR, IN par_pp_code VARCHAR, IN par_user_id CHAR)
AS 
$BODY$
DECLARE
    var_cur_datetime TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    SELECT
        timestamp_convert(localtimestamp)
        INTO var_cur_datetime;

    IF EXISTS (SELECT
        *
        FROM opas_pp_by_specialty
        WHERE hospital_code = par_hospital_code::VARCHAR AND case_no = par_case_no::VARCHAR AND specialty = par_specialty::VARCHAR) THEN
        BEGIN
            UPDATE opas_pp_by_specialty
            SET pp_code = par_pp_code, update_by = par_user_id, update_datetime = var_cur_datetime
                WHERE hospital_code = par_hospital_code::VARCHAR AND case_no = par_case_no::VARCHAR AND specialty = par_specialty::VARCHAR;
        END;
    ELSE
        BEGIN
            INSERT INTO opas_pp_by_specialty (hospital_code, case_no, specialty, pp_code, create_by, create_datetime, update_by, update_datetime)
            VALUES (par_hospital_code, par_case_no, par_specialty, par_pp_code, par_user_id, var_cur_datetime, par_user_id, var_cur_datetime);
        END;
    END IF;
END;
$BODY$
LANGUAGE plpgsql;