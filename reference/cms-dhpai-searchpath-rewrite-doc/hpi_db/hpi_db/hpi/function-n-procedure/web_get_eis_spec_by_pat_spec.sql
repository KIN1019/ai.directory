CREATE OR REPLACE PROCEDURE web_get_eis_spec_by_pat_spec(INOUT pas_return_code int, IN par_hospital_code VARCHAR, IN par_input_code VARCHAR, INOUT par_return_code INTEGER, INOUT par_return_message VARCHAR)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_IMISCode VARCHAR(6);
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            0
            INTO par_return_code;
        /* *********************************************************** */
        /* check input code valid or not and retrieve IMIS_code */
        /* *********************************************************** */
        IF NOT EXISTS (SELECT
            Specialty_code
            FROM Specialty
            WHERE Specialty_code = par_input_code AND Hospital_code = par_hospital_code AND Active_status = 'A') THEN
            BEGIN
                SELECT
                    10001
                    INTO par_return_code;
                SELECT
                    'Patient Specialty Not Found'
                    INTO par_return_message;
                EXIT return_error;
            END;
        ELSE
            BEGIN
                SELECT
                    IMIS_code
                    INTO var_IMISCode
                    FROM (SELECT
                        IMIS_code, Specialty_code, Effective_date
                        FROM Specialty) AS ungrouped_query
                    INNER JOIN (SELECT
                        Specialty_code, MAX(Effective_date) AS max_1
                        FROM Specialty
                        WHERE Specialty_code = par_input_code AND Hospital_code = par_hospital_code AND Active_status = 'A'
                        GROUP BY Specialty_code) AS grouped_query
                        ON (ungrouped_query.Specialty_code = grouped_query.Specialty_code OR (ungrouped_query.Specialty_code IS NULL AND grouped_query.Specialty_code IS NULL))
                    WHERE Effective_date = max_1;
            END;
        END IF;
        /* ************************************ */
        /* retrieve EIS code */
        /* ************************************ */
        SELECT
            EIS_code
            INTO par_return_message
            FROM IMIS
            WHERE IMIS_code = var_IMISCode;
        pas_return_code := 0;
        RETURN;
    END;
    pas_return_code := - 1;
    RETURN;
END;
$procedure$
;