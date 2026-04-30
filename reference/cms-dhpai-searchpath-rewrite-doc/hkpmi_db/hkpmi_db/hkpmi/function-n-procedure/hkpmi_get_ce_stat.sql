-- DROP PROCEDURE hkpmi.hkpmi_get_ce_stat(inout int4, in timestamp, in timestamp, in bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_get_ce_stat(INOUT pas_return_code integer, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, 
IN par_hospital_code VARCHAR)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_ae_att DOUBLE PRECISION;
    var_ae_adm DOUBLE PRECISION;
    var_adm DOUBLE PRECISION;
    var_ae_adm_per NUMERIC(9, 2);
    var_bdo DOUBLE PRECISION;
    var_bda DOUBLE PRECISION;
    var_occ_rate NUMERIC(9, 2);
    var_vbd DOUBLE PRECISION;
    var_ebd DOUBLE PRECISION;
    var_hosp VARCHAR(3);
    var_string VARCHAR(255);
    var_date TIMESTAMP WITHOUT TIME ZONE;
    var_prev_ae_att DOUBLE PRECISION;
    var_prev_ae_adm DOUBLE PRECISION;
    var_prev_adm DOUBLE PRECISION;
    var_prev_vbd DOUBLE PRECISION;
    var_prev_ebd DOUBLE PRECISION;
    var_prev_ae_att_per NUMERIC(9, 2);
    var_prev_ae_adm_per NUMERIC(9, 2);
    var_prev_adm_per NUMERIC(9, 2);
    var_prev_vbd_per NUMERIC(9, 2);
    var_prev_ebd_per NUMERIC(9, 2);
    csr CURSOR FOR
    SELECT DISTINCT
        cluster
        FROM cluster_hospital;
BEGIN
    IF par_input_to_date IS NULL THEN
        SELECT
            - 1 * INTERVAL '1 day' + to_char(timestamp_convert(localtimestamp), 'YYYYMMDD')::TIMESTAMP
            INTO par_input_to_date;
    END IF;

    IF par_input_from_date IS NULL THEN
        SELECT
            - 6 * INTERVAL '1 day' + par_input_to_date::TIMESTAMP
            INTO par_input_from_date;
    END IF;
    OPEN csr;
    FETCH csr INTO var_hosp;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            NULL, NULL, NULL, NULL, NULL
            INTO var_prev_ae_att, var_prev_ae_adm, var_prev_adm, var_prev_vbd, var_prev_ebd;
        /* select @hosp = Hospital_code from Hospital */
        SELECT
            par_input_from_date
            INTO var_date;

        WHILE var_date <= par_input_to_date LOOP
            SELECT
                SUM(COALESCE(ae_attendance, 0)), SUM(COALESCE(ae_admission, 0)), SUM(COALESCE(admission, 0))
                INTO var_ae_att, var_ae_adm, var_adm
                FROM cluster_hospital AS a, daily_adm_summary AS b
                WHERE report_date = var_date AND cluster = var_hosp AND a.hospital_code = b.hospital_code;
            SELECT
                SUM(COALESCE(bdo, 0)), SUM(COALESCE(bda, 0))
                INTO var_bdo, var_bda
                FROM cluster_hospital AS a, daily_spec_summary AS b
                WHERE report_date = var_date AND cluster = var_hosp AND a.hospital_code = b.hospital_code;
            SELECT
                SUM(COALESCE(vbd, 0)), SUM(COALESCE(ebd, 0))
                INTO var_vbd, var_ebd
                FROM cluster_hospital AS a, daily_ward_summary AS b
                WHERE report_date = var_date AND cluster = var_hosp AND a.hospital_code = b.hospital_code;

            IF var_bda = 0 THEN
                SELECT
                    NULL
                    INTO var_occ_rate;
            ELSE
                SELECT
                    100 * var_bdo / var_bda
                    INTO var_occ_rate;
            END IF;

            IF var_adm = 0 THEN
                SELECT
                    0
                    INTO var_ae_adm_per;
            ELSE
                SELECT
                    100 * var_ae_adm / var_adm
                    INTO var_ae_adm_per;
            END IF;

            IF var_date <> '19990101' THEN
                BEGIN
                    IF var_prev_ae_att = 0 THEN
                        SELECT
                            NULL
                            INTO var_prev_ae_att_per;
                    ELSE
                        SELECT
                            100 * (var_ae_att - var_prev_ae_att) / var_prev_ae_att
                            INTO var_prev_ae_att_per;
                    END IF;

                    IF var_prev_ae_adm = 0 THEN
                        SELECT
                            0
                            INTO var_prev_ae_adm_per;
                    ELSE
                        SELECT
                            100 * (var_ae_adm - var_prev_ae_adm) / var_prev_ae_adm
                            INTO var_prev_ae_adm_per;
                    END IF;

                    IF var_prev_adm = 0 THEN
                        SELECT
                            0
                            INTO var_prev_adm_per;
                    ELSE
                        SELECT
                            100 * (var_adm - var_prev_adm) / var_prev_adm
                            INTO var_prev_adm_per;
                    END IF;

                    IF var_prev_vbd = 0 THEN
                        SELECT
                            0
                            INTO var_prev_vbd_per;
                    ELSE
                        SELECT
                            100 * (var_vbd - var_prev_vbd) / var_prev_vbd
                            INTO var_prev_vbd_per;
                    END IF;

                    IF var_prev_ebd = 0 THEN
                        SELECT
                            0
                            INTO var_prev_ebd_per;
                    ELSE
                        SELECT
                            100 * (var_ebd - var_prev_ebd) / var_prev_ebd
                            INTO var_prev_ebd_per;
                    END IF;
                END;
            END IF;
            SELECT
                CONCAT(SUBSTRING(to_char(var_date, 'YYYYMMDD'), 1, 8), SUBSTRING(CONCAT(var_hosp, REPEAT(' ', 3)), 1, 3), SUBSTRING(CONCAT(CAST (var_ae_att AS VARCHAR(8)), REPEAT(' ', 8)), 1, 8), SUBSTRING(CONCAT(CAST (var_prev_ae_att_per AS VARCHAR(10)), REPEAT(' ', 10)), 1, 10), SUBSTRING(CONCAT(CAST (var_ae_adm AS VARCHAR(8)), REPEAT(' ', 8)), 1, 8), SUBSTRING(CONCAT(CAST (var_prev_ae_adm_per AS VARCHAR(10)), REPEAT(' ', 10)), 1, 10), SUBSTRING(CONCAT(CAST (var_adm AS VARCHAR(8)), REPEAT(' ', 8)), 1, 8), SUBSTRING(CONCAT(CAST (var_prev_adm_per AS VARCHAR(10)), REPEAT(' ', 10)), 1, 10), SUBSTRING(CONCAT(CAST (var_ae_adm_per AS VARCHAR(10)), REPEAT(' ', 10)), 1, 10), SUBSTRING(CONCAT(CAST (var_occ_rate AS VARCHAR(10)), REPEAT(' ', 10)), 1, 10), SUBSTRING(CONCAT(CAST (var_vbd AS VARCHAR(8)), REPEAT(' ', 8)), 1, 8), SUBSTRING(CONCAT(CAST (var_prev_vbd_per AS VARCHAR(10)), REPEAT(' ', 10)), 1, 10), SUBSTRING(CONCAT(CAST (var_ebd AS VARCHAR(8)), REPEAT(' ', 8)), 1, 8), SUBSTRING(CONCAT(CAST (var_prev_ebd_per AS VARCHAR(10)), REPEAT(' ', 10)), 1, 10))
                INTO var_string;
            RAISE NOTICE '%', var_string;
            SELECT
                1 * INTERVAL '1 day' + var_date::TIMESTAMP, var_ae_att, var_ae_adm, var_adm, var_vbd, var_ebd
                INTO var_date, var_prev_ae_att, var_prev_ae_adm, var_prev_adm, var_prev_vbd, var_prev_ebd;
        END LOOP;
        FETCH csr INTO var_hosp;
    END LOOP;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_get_ce_stat" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

