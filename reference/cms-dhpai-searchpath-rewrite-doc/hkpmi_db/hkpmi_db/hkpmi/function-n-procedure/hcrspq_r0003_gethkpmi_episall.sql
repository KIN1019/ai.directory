-- DROP PROCEDURE hkpmi.hcrspq_r0003_gethkpmi_episall(inout int4, inout varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hkpmi.hcrspq_r0003_gethkpmi_episall(INOUT pas_return_code integer, INOUT par_hkid character varying, INOUT p_refcur refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_patient_key VARCHAR(16);
BEGIN
    IF OCTET_LENGTH(LTRIM(RTRIM(par_hkid))) < 9 THEN
        BEGIN
            SELECT
                CONCAT(' ', LTRIM(RTRIM(par_hkid)))
                INTO par_hkid;
        END;
    END IF;
    SELECT
        patient_key
        INTO var_patient_key
        FROM patient
        WHERE hkid = par_hkid;
    OPEN p_refcur FOR
    SELECT
        case_no, COALESCE(source_indicator, '') AS source_indicator, COALESCE(source_code, '') AS source_code,
        COALESCE(to_char(adm_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), '') AS admdate,
        COALESCE(to_char(adm_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24MI'), '') AS admtime, 
        COALESCE(to_char(discharge_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), '') AS disdate,
        COALESCE(to_char(discharge_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24MI'), '') AS distime,
        COALESCE(destination_code, '') AS disdest, 
        COALESCE(last_specialty_code, '') AS disspec,
        COALESCE(last_ward_code, '') AS disward, '' AS nc, '' AS mab, '' AS mrr, '' AS mri, hospital_code
        FROM pmi_case
        WHERE patient_key = var_patient_key;
END;
$procedure$
;


ALTER PROCEDURE "hcrspq_r0003_gethkpmi_episall" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

