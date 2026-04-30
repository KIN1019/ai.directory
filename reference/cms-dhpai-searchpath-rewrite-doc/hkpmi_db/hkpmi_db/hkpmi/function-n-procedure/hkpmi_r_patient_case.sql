-- DROP PROCEDURE hkpmi.hkpmi_r_patient_case(inout int4, in bpchar, in bpchar, inout bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_r_patient_case(INOUT pas_return_code integer, IN par_ihosp_code varchar, IN par_type varchar, INOUT par_parm varchar)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_patient_key VARCHAR(16);
    var_hkid VARCHAR(24);
    var_hosp_code VARCHAR(6);
    var_case_hosp VARCHAR(6);
    var_discharge_code VARCHAR(2);
    var_discharge_dtm TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
    SELECT
        RIGHT(CONCAT(REPEAT(' ', 2), RTRIM(SAFE_SUBSTRING(par_parm, 1, 12))), 9)
        INTO var_hkid;

    SELECT RPAD(par_parm, 16)
    INTO par_parm;
    
    SELECT
        SAFE_SUBSTRING(par_parm, 14, 3)
        INTO var_hosp_code;
    SELECT
        patient_key
        INTO var_patient_key
        FROM patient
        WHERE hkid = var_hkid;
    SELECT
        hospital_code
        INTO var_case_hosp
        FROM (SELECT
            hospital_code, patient_key, adm_dtm
            FROM pmi_case) AS ungrouped_query
        INNER JOIN (SELECT
            patient_key, MAX(adm_dtm) AS max_1
            FROM pmi_case
            WHERE patient_key = var_patient_key AND case_type IN ('A', 'I')
            GROUP BY patient_key) AS grouped_query
            ON (ungrouped_query.patient_key = grouped_query.patient_key OR (ungrouped_query.patient_key IS NULL AND grouped_query.patient_key IS NULL))
        WHERE adm_dtm = max_1;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount = 1 THEN
        BEGIN
            IF var_case_hosp = var_hosp_code THEN
                BEGIN
                    SELECT
                        CONCAT(SAFE_SUBSTRING(par_parm, 1, 12), 'Y', SAFE_SUBSTRING(par_parm, 14, 3))
                        INTO par_parm;
                    pas_return_code := 0;
                    RETURN;
                END;
            END IF;
        END;
    END IF;
    SELECT
        discharge_code
        INTO var_discharge_code
        FROM (SELECT
            discharge_code, patient_key, hospital_code, adm_dtm
            FROM pmi_case) AS ungrouped_query
        INNER JOIN (SELECT
            patient_key, hospital_code, MAX(adm_dtm) AS max_1
            FROM pmi_case
            WHERE patient_key = var_patient_key AND case_type IN ('A', 'I') AND hospital_code = var_hosp_code
            GROUP BY patient_key, hospital_code) AS grouped_query
            ON (ungrouped_query.patient_key = grouped_query.patient_key OR (ungrouped_query.patient_key IS NULL AND grouped_query.patient_key IS NULL))
        WHERE adm_dtm = max_1;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount = 1 THEN
        BEGIN
            IF var_discharge_code IS NULL THEN
                BEGIN
                    SELECT
                        CONCAT(SAFE_SUBSTRING(par_parm, 1, 12), 'Y', SAFE_SUBSTRING(par_parm, 14, 3))
                        INTO par_parm;
                    pas_return_code := 0;
                    RETURN;
                END;
            END IF;
        END;
    END IF;

    IF EXISTS (SELECT
        *
        FROM pmi_case
        WHERE patient_key = var_patient_key AND case_type = 'O' AND hospital_code = var_hosp_code AND discharge_dtm IS NULL) THEN
        BEGIN
            SELECT
                CONCAT(SAFE_SUBSTRING(par_parm, 1, 12), 'Y', SAFE_SUBSTRING(par_parm, 14, 3))
                INTO par_parm;
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    SELECT
        CONCAT(SAFE_SUBSTRING(par_parm, 1, 12), 'N', SAFE_SUBSTRING(par_parm, 14, 3))
        INTO par_parm;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_r_patient_case" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

