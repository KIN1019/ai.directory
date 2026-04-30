-- DROP PROCEDURE hpi.hasp_daily_stat_adm(inout int4, in timestamp, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hasp_daily_stat_adm(INOUT pas_return_code integer, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, IN par_hospital_code character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_case VARCHAR(24);
    var_type VARCHAR(6);
    var_spec VARCHAR(8);
    var_loc VARCHAR(8);
    var_adm_date TIMESTAMP WITHOUT TIME ZONE;
    var_hkid VARCHAR(24);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_age INTEGER;
    var_imis_spec VARCHAR(12);
    var_hosp VARCHAR(12);
    var_age_grp INTEGER;
    var_src_ind VARCHAR(4);
    var_ae_att INTEGER;
    var_ae_adm INTEGER;
    var_adm INTEGER;
    var_from_date TIMESTAMP WITHOUT TIME ZONE;
    var_to_date TIMESTAMP WITHOUT TIME ZONE;
    csr CURSOR FOR
    SELECT
        Case_no, Transaction_type, From_specialty_code, From_treatment_location, Transaction_datetime
        FROM Transaction_log
        WHERE Transaction_datetime >= var_from_date AND Transaction_datetime < var_to_date 
       AND Hospital_code = par_hospital_code::VARCHAR AND /* ----20120614 */
      Transaction_type IN ('100', '300')  AND Cancel_flag IS NULL;
BEGIN
    IF par_input_to_date IS NULL THEN
        SELECT
            to_char(- 1 * INTERVAL '1 day'::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
            INTO par_input_to_date;
    END IF;

    IF par_input_from_date IS NULL THEN
        SELECT
            - 14 * INTERVAL '1 day' + par_input_to_date::TIMESTAMP
            INTO par_input_from_date;
    END IF;
    SELECT
        1 * INTERVAL '1 day' + par_input_to_date::TIMESTAMP
        INTO par_input_to_date;
    DELETE FROM daily_adm_summary;
    /* select @hosp = Hospital_code from Hospital */
    SELECT
        par_hospital_code
        INTO var_hosp;
    SELECT
        par_input_from_date
        INTO var_from_date;

    WHILE var_from_date < par_input_to_date LOOP
        SELECT
            1 * INTERVAL '1 day' + var_from_date::TIMESTAMP
            INTO var_to_date;
        OPEN csr;
        FETCH csr INTO var_case, var_type, var_spec, var_loc, var_adm_date;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            SELECT
                HKID, Source_indicator
                INTO var_hkid, var_src_ind
                FROM Case_view
                WHERE Case_no = var_case AND Hospital_code = var_hosp;
            SELECT
                DOB
                INTO var_dob
                FROM PMI_wo_MRN
                WHERE HKID = var_hkid::VARCHAR;

            IF var_dob IS NULL THEN
                SELECT
                    NULL
                    INTO var_age;
            ELSE
                BEGIN
                    SELECT
                        DATE_PART('year', var_adm_date::TIMESTAMP) - DATE_PART('year', var_dob::TIMESTAMP)
                        INTO var_age;

                    IF var_age * INTERVAL '1 year' + var_dob::TIMESTAMP > var_adm_date THEN
                        SELECT
                            var_age - 1
                            INTO var_age;
                    END IF;
                END;
            END IF;

            IF var_age IS NULL THEN
                SELECT
                    1
                    INTO var_age_grp;
            ELSE
                IF var_age < 5 THEN
                    SELECT
                        2
                        INTO var_age_grp;
                ELSE
                    IF var_age < 15 THEN
                        SELECT
                            3
                            INTO var_age_grp;
                    ELSE
                        IF var_age < 65 THEN
                            SELECT
                                4
                                INTO var_age_grp;
                        ELSE
                            SELECT
                                5
                                INTO var_age_grp;
                        END IF;
                    END IF;
                END IF;
            END IF;

            IF var_type = '300' THEN
                SELECT
                    'A&E'
                    INTO var_imis_spec;
            ELSE
                BEGIN
                    IF var_loc IS NULL THEN
                        SELECT
                            NULL
                            INTO var_imis_spec;
                    ELSE
                        BEGIN
                            SELECT
                                IMIS_code
                                INTO var_imis_spec
                                FROM Specialty
                                WHERE Specialty_code = var_loc::VARCHAR AND Hospital_code = var_hosp::VARCHAR AND Effective_date = (SELECT
                                    MAX(Effective_date)
                                    FROM Specialty
                                    WHERE Specialty_code = var_loc::VARCHAR AND Hospital_code = var_hosp::VARCHAR AND Effective_date <= var_adm_date);

                            IF var_imis_spec NOT IN ('ICU', 'CCU', 'PIC', 'NIC', 'SCB', 'PRI') THEN
                                SELECT
                                    NULL
                                    INTO var_imis_spec;
                            END IF;
                        END;
                    END IF;

                    IF var_imis_spec IS NULL THEN
                        SELECT
                            IMIS_code
                            INTO var_imis_spec
                            FROM Specialty
                            WHERE Specialty_code = var_spec::VARCHAR AND Hospital_code = var_hosp::VARCHAR AND Effective_date = (SELECT
                                MAX(Effective_date)
                                FROM Specialty
                                WHERE Specialty_code = var_spec::VARCHAR AND Hospital_code = var_hosp::VARCHAR AND Effective_date <= var_adm_date);
                    END IF;
                END;
            END IF;

            IF var_type = '100' THEN
                BEGIN
                    SELECT
                        0, 1
                        INTO var_ae_att, var_adm;

                    IF var_src_ind = '3' THEN
                        SELECT
                            1
                            INTO var_ae_adm;
                    ELSE
                        SELECT
                            0
                            INTO var_ae_adm;
                    END IF;
                END;
            ELSE
                SELECT
                    1, 0, 0
                    INTO var_ae_att, var_adm, var_ae_adm;
            END IF;

            IF EXISTS (SELECT
                *
                FROM daily_adm_summary
                WHERE hospital_code = var_hosp::VARCHAR AND specialty_code = var_imis_spec::VARCHAR AND report_date = var_from_date AND age_group = var_age_grp) THEN
                UPDATE daily_adm_summary
                SET ae_attendance = ae_attendance + var_ae_att, ae_admission = ae_admission + var_ae_adm, admission = admission + var_adm
                    WHERE hospital_code = var_hosp::VARCHAR AND specialty_code = var_imis_spec::VARCHAR AND report_date = var_from_date AND age_group = var_age_grp;
            ELSE
                INSERT INTO daily_adm_summary
                VALUES (var_hosp, var_from_date, var_imis_spec, var_age_grp, var_ae_att, var_ae_adm, var_adm);
            END IF;
            FETCH csr INTO var_case, var_type, var_spec, var_loc, var_adm_date;
        END LOOP;
        CLOSE csr;
        SELECT
            1 * INTERVAL '1 day' + var_from_date::TIMESTAMP
            INTO var_from_date;
    END LOOP;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;
;ALTER PROCEDURE "hasp_daily_stat_adm" OWNER TO "HPI_SCHEMA_OWNER_ROLE";