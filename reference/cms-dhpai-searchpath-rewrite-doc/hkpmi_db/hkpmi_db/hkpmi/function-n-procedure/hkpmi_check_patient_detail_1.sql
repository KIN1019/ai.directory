-- DROP PROCEDURE hkpmi.hkpmi_check_patient_detail_1(inout int4, in bpchar, in bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_check_patient_detail_1(INOUT pas_return_code integer, IN par_hkid VARCHAR, IN par_hospital_code VARCHAR)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_error INTEGER;
    var_patient_key VARCHAR(16);
    var_begin_tran VARCHAR(2);
    var_return_code INTEGER;
    sql$rowcount BIGINT;
BEGIN
    SELECT
        patient_key
        INTO var_patient_key
        FROM patient
        WHERE hkid = par_hkid;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount != 1 THEN
        pas_return_code := 2;
        RETURN;
    END IF;
    IF EXISTS (SELECT
        1
        FROM hospital AS h, patient_detail_1 AS p
        WHERE h.hospital_code = par_hospital_code AND p.patient_key = var_patient_key AND (p.hosp_byte_1 & h.byte_value_1 > 0 OR p.hosp_byte_2 & h.byte_value_2 > 0 OR p.hosp_byte_3 & h.byte_value_3 > 0)) THEN
        pas_return_code := 0;
        RETURN;
    ELSE
        pas_return_code := 1;
    END IF;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_check_patient_detail_1" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

