-- DROP FUNCTION download.dw_bp_get_tran(timestamp, timestamp, varchar, int4);

-- DROP FUNCTION download.dw_bp_get_tran(timestamp, timestamp, varchar, int4);

CREATE OR REPLACE FUNCTION download.dw_bp_get_tran(par_startdtm timestamp without time zone, par_enddtm timestamp without time zone, par_lasthospital character varying, par_maxrow integer)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/*
**********************************************************
By  Andy Wong
This store proc. is used to get a fixed
number of record from table transaction_log
in HKPMI
**********************************************************
*/
DECLARE
    p_refcur refcursor;
    var_count INTEGER;
    var_maxtxntime TIMESTAMP WITHOUT TIME ZONE;
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_hospital_code VARCHAR(3);
    var_type VARCHAR(3);
    var_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_hkid VARCHAR(12);
    var_patient_key VARCHAR(8);
    var_patient_name VARCHAR(48);
    var_sex VARCHAR(1);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag VARCHAR(1);
    var_cccode1 VARCHAR(5);
    var_cccode2 VARCHAR(5);
    var_cccode3 VARCHAR(5);
    var_cccode4 VARCHAR(5);
    var_cccode5 VARCHAR(5);
    var_cccode6 VARCHAR(5);
    var_chi_name VARCHAR(12);
    var_marital_status VARCHAR(1);
    var_race VARCHAR(2);
    var_other_doc_no VARCHAR(12);
    var_mrn VARCHAR(8);
    var_building VARCHAR(47);
    var_room VARCHAR(5);
    var_floor VARCHAR(2);
    var_block VARCHAR(2);
    var_district VARCHAR(5);
    var_religion VARCHAR(3);
    var_home_phone VARCHAR(10);
    var_office_phone VARCHAR(10);
    var_office_phone_ext VARCHAR(4);
    var_other_phone VARCHAR(10);
    var_other_phone_ext VARCHAR(4);
    var_death_indicator VARCHAR(4);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_death_external_cause VARCHAR(4);
    var_death_diagnosis VARCHAR(4);
    var_pcs_count INTEGER;
    var_priority INTEGER;
    var_major_nok VARCHAR(1);
    var_nok_name VARCHAR(48);
    var_nok_hkid VARCHAR(12);
    var_nok_relationship VARCHAR(2);
    var_nok_building VARCHAR(47);
    var_nok_room VARCHAR(5);
    var_nok_floor VARCHAR(2);
    var_nok_block VARCHAR(2);
    var_nok_district VARCHAR(5);
    var_nok_home_phone VARCHAR(10);
    var_nok_office_phone VARCHAR(10);
    var_nok_office_phone_ext VARCHAR(4);
    var_nok_other_phone VARCHAR(10);
    var_nok_other_phone_ext VARCHAR(4);
    var_case_no VARCHAR(12);
    var_source_indicator VARCHAR(1);
    var_source_code VARCHAR(3);
    var_patient_type VARCHAR(3);
    var_discharge_code VARCHAR(1);
    var_destination_code VARCHAR(5);
    var_case_type VARCHAR(1);
    var_security_count INTEGER;
    var_case_access_code INTEGER;
    var_pmi_access_code INTEGER;
    var_ambulance_no VARCHAR(4);
    var_police_case VARCHAR(1);
    var_labour_case VARCHAR(1);
    var_ae_case_type VARCHAR(1);
    var_dba VARCHAR(1);
    var_ward_code VARCHAR(4);
    var_specialty_code VARCHAR(4);
    var_bed_no VARCHAR(5);
    var_ward_class VARCHAR(1);
    var_old_patient_key VARCHAR(8);
    var_old_patient_name VARCHAR(48);
    var_old_hkid VARCHAR(12);
    var_old_sex VARCHAR(1);
    var_old_dob TIMESTAMP WITHOUT TIME ZONE;
    var_old_ward_class VARCHAR(1);
    var_old_ward_code VARCHAR(4);
    var_old_specialty_code VARCHAR(4);
    var_old_bed_no VARCHAR(5);
    var_pp_code VARCHAR(8);
    var_update_by VARCHAR(12);
    var_update_hospital VARCHAR(3);
    var_source_system VARCHAR(5);
    var_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_upload_status VARCHAR(1);
    var_filler VARCHAR(30);
    var_doctor_code VARCHAR(8);
    var_mrt_indicator VARCHAR(1);
    var_transfer_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_discharge_dtm TIMESTAMP WITHOUT TIME ZONE;
    txncur CURSOR FOR
    SELECT
        system_dtm, hospital_code, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_external_cause, death_diagnosis, pcs_count, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_home_phone, nok_office_phone, nok_office_phone_ext, nok_other_phone, nok_other_phone_ext, case_no, source_indicator, source_code, patient_type, discharge_code, destination_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba, ward_code, specialty_code, bed_no, ward_class, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, pp_code, update_by, update_hospital, source_system, source_system_dtm, upload_status, filler, doctor_code, mrt_indicator, transfer_dtm, discharge_dtm
        FROM transaction_log
        WHERE system_dtm >= par_startdtm AND system_dtm < par_enddtm
        ORDER BY system_dtm NULLS FIRST, hospital_code NULLS FIRST;
BEGIN
    /* necessary transaction log variable */
    /* necessary transaction log variable */
    DROP TABLE IF EXISTS t$txn_log;
    CREATE TEMPORARY TABLE t$txn_log
    AS
    SELECT
        system_dtm, hospital_code, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_external_cause, death_diagnosis, pcs_count, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_home_phone, nok_office_phone, nok_office_phone_ext, nok_other_phone, nok_other_phone_ext, case_no, source_indicator, source_code, patient_type, discharge_code, destination_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba, ward_code, specialty_code, bed_no, ward_class, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, pp_code, update_by, update_hospital, source_system, source_system_dtm, upload_status, filler, timestamp, doctor_code, mrt_indicator, transfer_dtm, discharge_dtm
        FROM transaction_log
        WHERE 1 = 0;
    /* get data not later than 30 seconds of system_dtm */
    SELECT
        - 30 * INTERVAL '1 second' + system_dtm::TIMESTAMP
        INTO var_maxtxntime
        FROM transaction_log_control;

    IF (par_enddtm > var_maxtxntime) THEN
        SELECT
            var_maxtxntime
            INTO par_enddtm;
    END IF;
    OPEN txncur;
    SELECT
        1
        INTO var_count;
    FETCH txncur INTO var_system_dtm, var_hospital_code, var_type, var_adm_dtm, var_hkid, var_patient_key, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_chi_name, var_marital_status, var_race, var_other_doc_no, var_mrn, var_building, var_room, var_floor, var_block, var_district, var_religion, var_home_phone, var_office_phone, var_office_phone_ext, var_other_phone, var_other_phone_ext, var_death_indicator, var_death_date, var_death_external_cause, var_death_diagnosis, var_pcs_count, var_priority, var_major_nok, var_nok_name, var_nok_hkid, var_nok_relationship, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district, var_nok_home_phone, var_nok_office_phone, var_nok_office_phone_ext, var_nok_other_phone, var_nok_other_phone_ext, var_case_no, var_source_indicator, var_source_code, var_patient_type, var_discharge_code, var_destination_code, var_case_type, var_security_count, var_case_access_code, var_pmi_access_code, var_ambulance_no, var_police_case, var_labour_case, var_ae_case_type, var_dba, var_ward_code, var_specialty_code, var_bed_no, var_ward_class, var_old_patient_key, var_old_patient_name, var_old_hkid, var_old_sex, var_old_dob, var_old_ward_class, var_old_ward_code, var_old_specialty_code, var_old_bed_no, var_pp_code, var_update_by, var_update_hospital, var_source_system, var_source_system_dtm, var_upload_status, var_filler, var_doctor_code, var_mrt_indicator, var_transfer_dtm, var_discharge_dtm;

    WHILE ((CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 AND var_count <= par_maxrow) LOOP
        IF (var_system_dtm > par_startdtm OR var_hospital_code > par_lasthospital) THEN
            BEGIN
                SELECT
                    var_count + 1
                    INTO var_count;
                INSERT INTO t$txn_log
                VALUES (var_system_dtm, var_hospital_code, var_type, var_adm_dtm, var_hkid, var_patient_key, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_chi_name, var_marital_status, var_race, var_other_doc_no, var_mrn, var_building, var_room, var_floor, var_block, var_district, var_religion, var_home_phone, var_office_phone, var_office_phone_ext, var_other_phone, var_other_phone_ext, var_death_indicator, var_death_date, var_death_external_cause, var_death_diagnosis, var_pcs_count, var_priority, var_major_nok, var_nok_name, var_nok_hkid, var_nok_relationship, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district, var_nok_home_phone, var_nok_office_phone, var_nok_office_phone_ext, var_nok_other_phone, var_nok_other_phone_ext, var_case_no, var_source_indicator, var_source_code, var_patient_type, var_discharge_code, var_destination_code, var_case_type, var_security_count, var_case_access_code, var_pmi_access_code, var_ambulance_no, var_police_case, var_labour_case, var_ae_case_type, var_dba, var_ward_code, var_specialty_code, var_bed_no, var_ward_class, var_old_patient_key, var_old_patient_name, var_old_hkid, var_old_sex, var_old_dob, var_old_ward_class, var_old_ward_code, var_old_specialty_code, var_old_bed_no, var_pp_code, var_update_by, var_update_hospital, var_source_system, var_source_system_dtm, var_upload_status, var_filler, NULL, var_doctor_code, var_mrt_indicator, var_transfer_dtm, var_discharge_dtm);
            END;
        END IF;
        FETCH txncur INTO var_system_dtm, var_hospital_code, var_type, var_adm_dtm, var_hkid, var_patient_key, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_chi_name, var_marital_status, var_race, var_other_doc_no, var_mrn, var_building, var_room, var_floor, var_block, var_district, var_religion, var_home_phone, var_office_phone, var_office_phone_ext, var_other_phone, var_other_phone_ext, var_death_indicator, var_death_date, var_death_external_cause, var_death_diagnosis, var_pcs_count, var_priority, var_major_nok, var_nok_name, var_nok_hkid, var_nok_relationship, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district, var_nok_home_phone, var_nok_office_phone, var_nok_office_phone_ext, var_nok_other_phone, var_nok_other_phone_ext, var_case_no, var_source_indicator, var_source_code, var_patient_type, var_discharge_code, var_destination_code, var_case_type, var_security_count, var_case_access_code, var_pmi_access_code, var_ambulance_no, var_police_case, var_labour_case, var_ae_case_type, var_dba, var_ward_code, var_specialty_code, var_bed_no, var_ward_class, var_old_patient_key, var_old_patient_name, var_old_hkid, var_old_sex, var_old_dob, var_old_ward_class, var_old_ward_code, var_old_specialty_code, var_old_bed_no, var_pp_code, var_update_by, var_update_hospital, var_source_system, var_source_system_dtm, var_upload_status, var_filler, var_doctor_code, var_mrt_indicator, var_transfer_dtm, var_discharge_dtm;
    END LOOP;
    CLOSE txncur;
    OPEN p_refcur FOR
    SELECT
        system_dtm, hospital_code, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_external_cause, death_diagnosis, pcs_count, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_home_phone, nok_office_phone, nok_office_phone_ext, nok_other_phone, nok_other_phone_ext, case_no, source_indicator, source_code, patient_type, discharge_code, destination_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba, ward_code, specialty_code, bed_no, ward_class, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, pp_code, update_by, update_hospital, source_system, source_system_dtm, upload_status, filler, timestamp, doctor_code, mrt_indicator, transfer_dtm, discharge_dtm
        FROM t$txn_log;
    RETURN NEXT p_refcur;
    DROP TABLE IF EXISTS t$txn_log;
END;
$function$
;


ALTER FUNCTION "dw_bp_get_tran" OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";