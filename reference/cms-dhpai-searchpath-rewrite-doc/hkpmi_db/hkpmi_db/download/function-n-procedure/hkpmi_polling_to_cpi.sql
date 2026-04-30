-- DROP PROCEDURE download.hkpmi_polling_to_cpi(inout int4, in varchar, in timestamp, in varchar, inout varchar, inout timestamp, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout varchar, inout timestamp, inout timestamp, inout timestamp, inout varchar, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE download.hkpmi_polling_to_cpi(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_trx_datetime timestamp without time zone, IN par_poll_mode character varying, INOUT par_retrieve_flag character varying, INOUT par_last_update_dtm timestamp without time zone, INOUT par_type character varying, INOUT par_adm_dtm timestamp without time zone, INOUT par_hkid character varying, INOUT par_patient_key character varying, INOUT par_patient_name character varying, INOUT par_sex character varying, INOUT par_dob timestamp without time zone, INOUT par_exact_dob_flag character varying, INOUT par_cccode1 character varying, INOUT par_cccode2 character varying, INOUT par_cccode3 character varying, INOUT par_cccode4 character varying, INOUT par_cccode5 character varying, INOUT par_cccode6 character varying, INOUT par_chi_name character varying, INOUT par_marital_status character varying, INOUT par_race character varying, INOUT par_other_doc_no character varying, INOUT par_building character varying, INOUT par_room character varying, INOUT par_floor character varying, INOUT par_block character varying, INOUT par_district character varying, INOUT par_religion character varying, INOUT par_home_phone character varying, INOUT par_office_phone character varying, INOUT par_office_phone_ext character varying, INOUT par_other_phone character varying, INOUT par_other_phone_ext character varying, INOUT par_priority integer, INOUT par_major_nok character varying, INOUT par_nok_name character varying, INOUT par_nok_hkid character varying, INOUT par_nok_relationship character varying, INOUT par_nok_building character varying, INOUT par_nok_room character varying, INOUT par_nok_floor character varying, INOUT par_nok_block character varying, INOUT par_nok_district character varying, INOUT par_nok_home_phone character varying, INOUT par_nok_office_phone character varying, INOUT par_nok_office_phone_ext character varying, INOUT par_nok_other_phone character varying, INOUT par_nok_other_phone_ext character varying, INOUT par_case_no character varying, INOUT par_source_indicator character varying, INOUT par_source_code character varying, INOUT par_patient_type character varying, INOUT par_discharge_code character varying, INOUT par_destination_code character varying, INOUT par_case_type character varying, INOUT par_ward_code character varying, INOUT par_specialty_code character varying, INOUT par_bed_no character varying, INOUT par_ward_class character varying, INOUT par_old_patient_key character varying, INOUT par_old_patient_name character varying, INOUT par_old_hkid character varying, INOUT par_old_sex character varying, INOUT par_old_dob timestamp without time zone, INOUT par_old_ward_class character varying, INOUT par_old_ward_code character varying, INOUT par_old_specialty_code character varying, INOUT par_old_bed_no character varying, INOUT par_update_by character varying, INOUT par_update_hospital character varying, INOUT par_filler character varying, INOUT par_pmi_access_code integer, INOUT par_death_flag character varying, INOUT par_death_date timestamp without time zone, INOUT par_transfer_dtm timestamp without time zone, INOUT par_discharge_dtm timestamp without time zone, INOUT par_source_system character varying, INOUT par_pp_code character varying, INOUT par_mrn character varying)
 LANGUAGE plpgsql
AS $procedure$
/* new *//* new *//* new *//* new *//* new *//* new *//* new *//* new *//* new *//* new *//* new *//* new *//* new *//* new *//* new *//* new *//* new *//* new *//* new */DECLARE
    var_death_ind VARCHAR(8);
    var_rowcount INTEGER;
    var_tmp_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_pbrc_flag VARCHAR(2);
    var_opas_flag VARCHAR(2);
    sql$rowcount BIGINT;
begin
	SET search_path TO download, public;
    IF par_poll_mode NOT IN ('B', 'A') THEN /* A - Actual, B - Bulk */
        BEGIN
            RAISE EXCEPTION 'Poll Mode should either A or B' USING ERRCODE := '999999';
            pas_return_code := 999999;
            RETURN;
        END;
    END IF;
   
    SELECT
        - 30 * INTERVAL '1 second' + system_dtm::TIMESTAMP
        INTO var_tmp_system_dtm
        FROM transaction_log_control;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount != 1 THEN
        begin
	        raise notice 'No rows';
            RAISE EXCEPTION 'No rows in transaction_log_control not equal to 1' USING ERRCODE := '999999';
            pas_return_code := 999999;
            RETURN;
        END;
    END IF;
   raise notice 'par_poll_mode';
    /* set rowcount 1 */
	raise notice 'par_poll_mode=%,par_trx_datetime=%,par_hospital_code=%',par_poll_mode,par_trx_datetime,par_hospital_code;
    IF par_poll_mode = 'A' THEN
        BEGIN
            SELECT
                system_dtm, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, case_no, source_indicator, source_code, patient_type, discharge_code, destination_code, case_type, ward_code, specialty_code, bed_no, ward_class, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, update_by, update_hospital, filler, pmi_access_code, death_indicator, death_date, transfer_dtm, discharge_dtm, source_system, pp_code, mrn
                INTO par_last_update_dtm, par_type, par_adm_dtm, par_hkid, par_patient_key, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, par_chi_name, par_marital_status, par_race, par_other_doc_no, par_building, par_room, par_floor, par_block, par_district, par_religion, par_home_phone, par_office_phone, par_office_phone_ext, par_other_phone, par_other_phone_ext, par_priority, par_major_nok, par_nok_name, par_nok_hkid, par_nok_relationship, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district, par_nok_home_phone, par_nok_office_phone, par_nok_office_phone_ext, par_nok_other_phone, par_nok_other_phone_ext, par_case_no, par_source_indicator, par_source_code, par_patient_type, par_discharge_code, par_destination_code, par_case_type, par_ward_code, par_specialty_code, par_bed_no, par_ward_class, par_old_patient_key, par_old_patient_name, par_old_hkid, par_old_sex, par_old_dob, par_old_ward_class, par_old_ward_code, par_old_specialty_code, par_old_bed_no, par_update_by, par_update_hospital, par_filler, par_pmi_access_code, var_death_ind, par_death_date, par_transfer_dtm, par_discharge_dtm, par_source_system, par_pp_code, par_mrn
                FROM transaction_log
                WHERE system_dtm = par_trx_datetime AND hospital_code = par_hospital_code;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;
        END;
    ELSE
        /* @poll_mode = 'B' */
        BEGIN
            SELECT
                pbrc_upload_flag, opas_upload_flag
                INTO var_pbrc_flag, var_opas_flag
                FROM hospital_upload_control
                WHERE hospital_code = par_hospital_code;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount <> 1 THEN
                SELECT
                    'N', 'N'
                    INTO var_pbrc_flag, var_opas_flag;
            END IF;

            SELECT
                system_dtm, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, case_no, source_indicator, source_code, patient_type, discharge_code, destination_code, case_type, ward_code, specialty_code, bed_no, ward_class, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, update_by, update_hospital, filler, pmi_access_code, death_indicator, death_date, transfer_dtm, discharge_dtm, source_system, pp_code, mrn
                INTO par_last_update_dtm, par_type, par_adm_dtm, par_hkid, par_patient_key, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, par_chi_name, par_marital_status, par_race, par_other_doc_no, par_building, par_room, par_floor, par_block, par_district, par_religion, par_home_phone, par_office_phone, par_office_phone_ext, par_other_phone, par_other_phone_ext, par_priority, par_major_nok, par_nok_name, par_nok_hkid, par_nok_relationship, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district, par_nok_home_phone, par_nok_office_phone, par_nok_office_phone_ext, par_nok_other_phone, par_nok_other_phone_ext, par_case_no, par_source_indicator, par_source_code, par_patient_type, par_discharge_code, par_destination_code, par_case_type, par_ward_code, par_specialty_code, par_bed_no, par_ward_class, par_old_patient_key, par_old_patient_name, par_old_hkid, par_old_sex, par_old_dob, par_old_ward_class, par_old_ward_code, par_old_specialty_code, par_old_bed_no, par_update_by, par_update_hospital, par_filler, par_pmi_access_code, var_death_ind, par_death_date, par_transfer_dtm, par_discharge_dtm, par_source_system, par_pp_code, par_mrn
                FROM transaction_log
                WHERE system_dtm > par_trx_datetime AND system_dtm <= var_tmp_system_dtm AND hospital_code = par_hospital_code AND ((update_hospital != hospital_code AND type LIKE '03%') OR (update_hospital = hospital_code AND source_system NOT IN ('ADT', 'OPAS', 'OPAS2', 'PBRC') AND (type LIKE '03%' OR type = '010')) OR (update_hospital = hospital_code AND source_system IN ('OPAS', 'OPAS2') AND var_opas_flag = 'Y') OR (update_hospital = hospital_code AND source_system = 'PBRC' AND var_pbrc_flag = 'Y') OR (update_hospital != hospital_code AND type = '250' AND source_system = 'ADT') OR (update_hospital != hospital_code AND type = '020' AND source_system IN ('ADT', 'OPAS', 'OPAS2')))
                LIMIT 1;
            /* ---or (update_hospital != hospital_code and type = '020' and source_system = 'ADT')) */
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;
        END;
    END IF;
	raise notice 'var_rowcount=%',var_rowcount;
    IF var_rowcount = 0 THEN
        SELECT
            'F'
            INTO par_retrieve_flag;
    ELSE
        SELECT
            'T'
            INTO par_retrieve_flag;
    END IF;

    IF var_death_ind IS NOT NULL THEN
        SELECT
            'Y'
            INTO par_death_flag;
    ELSE
        SELECT
            'N'
            INTO par_death_flag;
    END IF;
    /* set rowcount 0 */
    pas_return_code := 0;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_polling_to_cpi" OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";