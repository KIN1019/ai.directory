-- DROP PROCEDURE hkpmi.ops_chk_hkid_inpatient(inout int4, in varchar, in timestamp, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.ops_chk_hkid_inpatient(INOUT pas_return_code integer, IN par_patient_key character varying, IN par_slot_datetime timestamp without time zone, INOUT par_hkid character varying, INOUT par_hospital_code character varying, INOUT par_adm_dtm timestamp without time zone, INOUT par_last_specialty_code character varying, INOUT par_last_ward_code character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_pmi_case_cnt INTEGER;
    var_patient_cnt INTEGER;
    sql$rowcount BIGINT;
    var_err_msg TEXT;
BEGIN
    /* ----------------------------------------------- */
    /* Sep 2016 : Called by <ops_app_rpt_default_inpatient / web_ops_rpt_default_inpatient> */
    
    /* ----------------------------------------------- */
    /* Name                   Owner Object_type      Object_status Create_date */
    /* ---------------------- ----- ---------------- ------------- ------------------- */
    /* ops_chk_hkid_inpatient dbo   stored procedure  -- none --   Jan  8 2002 11:27AM */
    
    /* ----------------------------------------------- */
    SET search_path TO hkpmi, public;
    IF (SELECT EXISTS (SELECT
        patient_key
        FROM pmi_case
        WHERE patient_key = par_patient_key AND case_type = 'I' AND adm_dtm <= par_slot_datetime AND (discharge_dtm > par_slot_datetime OR discharge_dtm IS NULL) LIMIT 1)) THEN
        BEGIN
            SELECT
                hospital_code, adm_dtm, last_specialty_code, last_ward_code
                INTO par_hospital_code, par_adm_dtm, par_last_specialty_code, par_last_ward_code
                FROM pmi_case
                WHERE patient_key = par_patient_key AND case_type = 'I' AND (discharge_dtm IS NULL OR discharge_dtm > par_slot_datetime) AND adm_dtm = (SELECT
                    MAX(adm_dtm)
                    FROM pmi_case
                    WHERE patient_key = par_patient_key AND case_type = 'I' AND adm_dtm <= par_slot_datetime AND (discharge_dtm > par_slot_datetime OR discharge_dtm IS NULL));
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            IF sql$rowcount = 1 THEN
                SELECT
                    1
                    INTO var_pmi_case_cnt;
            ELSE
                SELECT
                    0
                    INTO var_pmi_case_cnt;
            END IF;
        EXCEPTION
            WHEN others THEN
                GET STACKED DIAGNOSTICS var_err_msg = MESSAGE_TEXT;
                raise notice 'ops_chk_hkid_inpatient error: %', var_err_msg;
                SELECT
                    0
                    INTO var_pmi_case_cnt;
        END;
    END IF;

    BEGIN
        SELECT
            hkid
            INTO par_hkid
            FROM patient
            WHERE patient_key = par_patient_key;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        IF sql$rowcount = 1 THEN
            SELECT
                1
                INTO var_patient_cnt;
        ELSE
            SELECT
                0
                INTO var_patient_cnt;
        END IF;
    EXCEPTION
        WHEN others THEN
            GET STACKED DIAGNOSTICS var_err_msg = MESSAGE_TEXT;
            raise notice 'ops_chk_hkid_inpatient error: %', var_err_msg;
            SELECT
                0
                INTO var_patient_cnt;
    END;

    IF var_pmi_case_cnt = 1 AND var_patient_cnt = 1 THEN
        pas_return_code := 1;
        RETURN;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
END;
/* ### DEFNCOPY: END OF DEFINITION */
$procedure$
;

ALTER PROCEDURE "ops_chk_hkid_inpatient" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

