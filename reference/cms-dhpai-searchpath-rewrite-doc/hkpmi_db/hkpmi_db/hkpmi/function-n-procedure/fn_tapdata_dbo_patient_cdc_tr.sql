-- DROP FUNCTION hkpmi.fn_tapdata_dbo_patient_cdc_tr();

CREATE OR REPLACE FUNCTION hkpmi.fn_tapdata_dbo_patient_cdc_tr()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_inserted_cnt INTEGER;
    var_delete_cnt INTEGER;
    var_op INTEGER;
BEGIN
    /* CREATING TEMPORARY TABLES */
    IF (TG_OP = 'INSERT') THEN
        CREATE TEMPORARY TABLE IF NOT EXISTS deleted$2a3a060c
        AS
        TABLE inserted$2a3a060c
        WITH NO DATA;
    ELSIF (TG_OP = 'DELETE') THEN
        CREATE TEMPORARY TABLE IF NOT EXISTS inserted$2a3a060c
        AS
        TABLE deleted$2a3a060c
        WITH NO DATA;
    END IF;
    SELECT
        COUNT(*)
        INTO var_inserted_cnt
        FROM inserted$2a3a060c;
    SELECT
        COUNT(*)
        INTO var_delete_cnt
        FROM deleted$2a3a060c;

    IF var_inserted_cnt > 0 AND var_delete_cnt <= 0 THEN
        BEGIN
            SELECT
                2
                INTO var_op;
            INSERT INTO tp_cdc.dbo_patient_ct (_$op, patient_key, religion, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_diagnosis, death_external_cause, patient_type, pcs_count, access_code, update_hospital, source_system, update_by, source_system_dtm, system_dtm, row_update_datetime, filler)
            SELECT
                var_op, patient_key, religion, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_diagnosis, death_external_cause, patient_type, pcs_count, access_code, update_hospital, source_system, update_by, source_system_dtm, system_dtm, row_update_datetime, filler
                FROM inserted$2a3a060c;
        END;
    ELSE
        IF var_inserted_cnt <= 0 AND var_delete_cnt > 0 THEN
            BEGIN
                SELECT
                    1
                    INTO var_op;
                INSERT INTO tp_cdc.dbo_patient_ct (_$op, patient_key, religion, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_diagnosis, death_external_cause, patient_type, pcs_count, access_code, update_hospital, source_system, update_by, source_system_dtm, system_dtm, row_update_datetime, filler)
                SELECT
                    var_op, patient_key, religion, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_diagnosis, death_external_cause, patient_type, pcs_count, access_code, update_hospital, source_system, update_by, source_system_dtm, system_dtm, row_update_datetime, filler
                    FROM deleted$2a3a060c;
            END;
        ELSE
            BEGIN
                INSERT INTO tp_cdc.dbo_patient_ct (_$op, patient_key, religion, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_diagnosis, death_external_cause, patient_type, pcs_count, access_code, update_hospital, source_system, update_by, source_system_dtm, system_dtm, row_update_datetime, filler)
                SELECT
                    3, patient_key, religion, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_diagnosis, death_external_cause, patient_type, pcs_count, access_code, update_hospital, source_system, update_by, source_system_dtm, system_dtm, row_update_datetime, filler
                    FROM deleted$2a3a060c;
                INSERT INTO tp_cdc.dbo_patient_ct (_$op, patient_key, religion, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_diagnosis, death_external_cause, patient_type, pcs_count, access_code, update_hospital, source_system, update_by, source_system_dtm, system_dtm, row_update_datetime, filler)
                SELECT
                    4, patient_key, religion, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_diagnosis, death_external_cause, patient_type, pcs_count, access_code, update_hospital, source_system, update_by, source_system_dtm, system_dtm, row_update_datetime, filler
                    FROM inserted$2a3a060c;
            END;
        END IF;
    END IF;
    RETURN NULL;
END;
$function$
;


ALTER FUNCTION "fn_tapdata_dbo_patient_cdc_tr" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
