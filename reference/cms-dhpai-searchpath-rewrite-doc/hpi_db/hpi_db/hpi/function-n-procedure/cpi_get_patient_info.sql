-- DROP PROCEDURE hpi.cpi_get_patient_info(inout int4, in varchar, in varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout int4, inout varchar, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout int4, inout varchar, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_get_patient_info(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, INOUT par_patient_name character varying, INOUT par_sex character varying, INOUT par_dob timestamp without time zone, INOUT par_exact_dob_flag character varying, INOUT par_ccc_1 character varying, INOUT par_ccc_2 character varying, INOUT par_ccc_3 character varying, INOUT par_ccc_4 character varying, INOUT par_ccc_5 character varying, INOUT par_ccc_6 character varying, INOUT par_chi_name character varying, INOUT par_marital_status character varying, INOUT par_race_code character varying, INOUT par_other_document_no character varying, INOUT par_reference character varying, INOUT par_medical_record_number character varying, INOUT par_remark character varying, INOUT par_building character varying, INOUT par_room character varying, INOUT par_floor character varying, INOUT par_block character varying, INOUT par_district_code character varying, INOUT par_religion_code character varying, INOUT par_home_phone_no character varying, INOUT par_other_phone_no_1 character varying, INOUT par_other_phone_ext_1 character varying, INOUT par_other_phone_no_2 character varying, INOUT par_other_phone_ext_2 character varying, INOUT par_death_indicator character varying, INOUT par_death_date timestamp without time zone, INOUT par_death_code character varying, INOUT par_card_holder integer, INOUT par_patient_key character varying, INOUT par_priority integer, INOUT par_nok_name character varying, INOUT par_nok_hkid character varying, INOUT par_nok_relation_code character varying, INOUT par_nok_building character varying, INOUT par_nok_room character varying, INOUT par_nok_floor character varying, INOUT par_nok_block character varying, INOUT par_nok_district_code character varying, INOUT par_nok_home_phone character varying, INOUT par_nok_other_phone_no_1 character varying, INOUT par_nok_other_phone_ext_1 character varying, INOUT par_nok_other_phone_no_2 character varying, INOUT par_nok_other_phone_ext_2 character varying, INOUT par_access_code integer, INOUT par_security integer, INOUT par_update_hospital character varying, INOUT par_update_by character varying, INOUT par_hkic_symbol character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
    var_return_status INTEGER;
    var_patient_type VARCHAR(3);
    var_death_diagnosis VARCHAR(4);
    var_death_external_cause VARCHAR(4);
	var_return_code integer;
    sql$rowcount BIGINT;
BEGIN
    /* Declaration */
    SELECT
        COUNT(*)
        INTO var_cnt
        FROM cpi_patient
        WHERE hkid = par_hkid;

    IF (var_cnt = 0) THEN
        BEGIN
            CALL cpi_get_hkpmi(var_return_code,par_hospital_code, par_hkid,
            /* 'Y', 'CPI', 'CPI'  -- GL 19981110 */
            'N'::varchar, 'CPI'::varchar, 'CPI'::varchar, par_dob, par_exact_dob_flag, par_medical_record_number, par_patient_name, par_sex, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_marital_status, par_race_code, par_other_document_no, par_building, par_floor, par_room, par_block, par_district_code, par_home_phone_no, par_death_indicator, par_patient_key, par_card_holder, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_home_phone, par_nok_other_phone_no_2, par_nok_other_phone_ext_2, par_nok_hkid, par_nok_name, par_nok_relation_code, par_religion_code, par_access_code, par_chi_name,
                par_other_phone_no_1, par_other_phone_ext_1, par_other_phone_no_2, par_other_phone_ext_2, par_death_date,
                var_death_diagnosis, var_death_external_cause, var_patient_type, par_nok_other_phone_no_1, par_nok_other_phone_ext_1,
                par_hkic_symbol);

			raise notice 'par_dob=%',par_dob;
            IF (var_return_status != 0) THEN
                BEGIN
                    /* print "Fail to retrieve data from HKPMI!" */
                    pas_return_code := var_return_status;
                    RETURN;
                END;
            END IF;
            SELECT
                NULL, 0, 'HKPMI', par_hospital_code
                INTO par_priority, par_security, par_update_by, par_update_hospital;
        END;
    ELSE
        BEGIN
            /* --	select	@cnt = count(*) */
            /* --	from	cpi_patient */
            /* --	where	hkid = @hkid */
            /* -- */
            /* --	if (@cnt = 0) */
            /* --	begin */
            /* print "No patient data can be found in CPI and HKPMI!" */
            /* --		return 14003 */
            /* --	end */
            SELECT
                patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, reference, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder, patient_key, access_code, security, update_hospital, update_by, hkic_symbol
                INTO par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_chi_name, par_marital_status, par_race_code, par_other_document_no, par_reference, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_home_phone_no, par_other_phone_no_1, par_other_phone_ext_1, par_other_phone_no_2, par_other_phone_ext_2, par_death_indicator, par_death_date, par_death_code, par_card_holder, par_patient_key, par_access_code, par_security, par_update_hospital, par_update_by, par_hkic_symbol
                FROM cpi_patient
                WHERE hkid = par_hkid;
            SELECT
                mrn, remark
                INTO par_medical_record_number, par_remark
                FROM cpi_patient_hospital_data
                WHERE patient_key = par_patient_key AND hospital_code = par_hospital_code;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF (sql$rowcount = 0) THEN
                BEGIN
                    SELECT
                        NULL
                        INTO par_medical_record_number;
                    SELECT
                        NULL
                        INTO par_remark;
                END;
            END IF;
            SELECT
                priority, nok_name, hkid, relationship, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language
                INTO par_priority, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_home_phone, par_nok_other_phone_no_1, par_nok_other_phone_ext_1, par_nok_other_phone_no_2, par_nok_other_phone_ext_2
                FROM cpi_nok
                WHERE patient_key = par_patient_key AND major_nok = 'Y';
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF (sql$rowcount = 0) THEN
                BEGIN
                    SELECT
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                        INTO par_priority, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_home_phone, par_nok_other_phone_no_1, par_nok_other_phone_ext_1, par_nok_other_phone_no_2, par_nok_other_phone_ext_2;
                END;
            END IF;
        END;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "cpi_get_patient_info" OWNER TO "HPI_SCHEMA_OWNER_ROLE";