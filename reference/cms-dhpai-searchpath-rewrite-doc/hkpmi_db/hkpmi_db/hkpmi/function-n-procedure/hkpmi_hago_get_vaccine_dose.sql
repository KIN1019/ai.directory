-- DROP PROCEDURE hkpmi.hkpmi_hago_get_vaccine_dose(inout int4, in bpchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_hago_get_vaccine_dose(INOUT pas_return_code integer, IN par_hkid varchar, INOUT p_refcur refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* ---------------------------------------------------------------------------------------------------------------------- */
/* Script Name: hkpmi_hago_get_vaccine_dose.sql */
/* Script Version: 2022.07.001 */
/* Description: To get vaccine dose records by HKID */
/* ---------------------------------------------------------------------------------------------------------------------- */
/* Update History: */
/* Date                 JIRA #			Update details       												Updated By */
/* ==================================================================================== */
/* 14-Jul-2022			HAGO-XXX		Initial version													Max CHAN */
/* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
/* drop proc hkpmi_hago_get_vaccine_dose */
DECLARE
    var_patient_key VARCHAR(16);
    var_code INTEGER;
    var_status VARCHAR(20);
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_valid_flag VARCHAR(1);
    var_return_code int;
BEGIN
    CALL cpi_pq_validate_hkid(var_return_code, par_hkid, var_valid_flag);

    IF var_valid_flag = 'N' THEN
        BEGIN
            SELECT
                2905, 'Invalid HKID'
                INTO var_code, var_status;
            pas_return_code := 2905;
            RETURN;
        END;
    END IF;
    /* HKID not exist */
    SELECT
        patient_key
        INTO var_patient_key
        /* --,@death_indicator = death_indicator */
        /* --,@death_date = death_date */
        FROM patient
        WHERE hkid = par_hkid;

    IF var_patient_key IS NULL THEN
        BEGIN
            SELECT
                2907, 'HKID Not Found'
                INTO var_code, var_status;
            pas_return_code := 2907;
            RETURN;
        END;
    END IF;
    SELECT
        status, update_datetime
        INTO var_status, var_update_datetime
        FROM hkpmi_patient_cvi_record /* --(index hkpmi_patient_cvi_record_pk_idx) */
        WHERE patient_key = var_patient_key::VARCHAR;
    OPEN p_refcur FOR
    SELECT
        vaccine_brand, dose_order,
        TO_CHAR(dose_date, 'DD-Mon-YYYY'),
        vac_center
        FROM hkpmi_patient_cvi_dose_info /* --(index hkpmi_patient_cvi_record_pk_do_idx) */
        WHERE patient_key = var_patient_key::VARCHAR AND update_datetime >= var_update_datetime AND
        /* --AND @status is not null */
        var_status = 'VACCINATED'
        ORDER BY dose_date DESC NULLS FIRST, vaccine_brand NULLS FIRST, dose_order DESC NULLS FIRST;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_hago_get_vaccine_dose" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

