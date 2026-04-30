-- DROP PROCEDURE web_cpi_patient_update(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, inout varchar, inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in int4, in timestamp, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE web_cpi_patient_update(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_patient_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc_1 character varying, IN par_ccc_2 character varying, IN par_ccc_3 character varying, IN par_ccc_4 character varying, IN par_ccc_5 character varying, IN par_ccc_6 character varying, IN par_chi_name character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_reference character varying, IN par_medical_record_number character varying, IN par_remark character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_home_phone_no character varying, IN par_other_phone_no_1 character varying, IN par_other_phone_ext_1 character varying, IN par_other_phone_no_2 character varying, IN par_other_phone_ext_2 character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_death_code character varying, IN par_card_holder integer, INOUT par_patient_key character varying, INOUT par_priority integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_home_phone character varying, IN par_nok_other_phone_no_1 character varying, IN par_nok_other_phone_ext_1 character varying, IN par_nok_other_phone_no_2 character varying, IN par_nok_other_phone_ext_2 character varying, IN par_txn_type character varying, IN par_access_code integer, IN par_security integer, IN par_transaction_datetime timestamp without time zone, IN par_update_hospital character varying, IN par_update_by character varying, IN par_last_update_datetime timestamp without time zone, IN par_source_system character varying, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_hkic_symbol character varying DEFAULT NULL::character varying, IN par_hkic_symbol_clear character varying DEFAULT 'N'::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rowcount INTEGER;
    var_error_msg VARCHAR(255);
    sql$rowcount BIGINT;
BEGIN
    CALL cpi_patient_update(pas_return_code,par_hospital_code, par_hkid, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_chi_name, par_marital_status, par_race_code, par_other_document_no, par_reference, par_medical_record_number, par_remark, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_home_phone_no, par_other_phone_no_1, par_other_phone_ext_1, par_other_phone_no_2, par_other_phone_ext_2, par_death_indicator, par_death_date, par_death_code, par_card_holder, par_patient_key, par_priority, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_home_phone, par_nok_other_phone_no_1, par_nok_other_phone_ext_1, par_nok_other_phone_no_2, par_nok_other_phone_ext_2, par_txn_type, par_access_code, par_security, par_transaction_datetime, par_update_hospital, par_update_by, par_last_update_datetime, par_source_system, par_document_flag, par_hkic_symbol, par_hkic_symbol_clear);

    IF pas_return_code != 0 THEN
        BEGIN
            SELECT
                messages
            INTO var_error_msg
            FROM error_msgs
            WHERE error_code = pas_return_code;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;
            IF var_rowcount != 1 THEN
                BEGIN
                SELECT
                    CONCAT('Call web_cpi_patient_update failed with return code ',
                        CASE CAST (pas_return_code AS VARCHAR(8))
                            WHEN '' THEN ' '
                            ELSE CAST (pas_return_code AS VARCHAR(8))
                            END)
                INTO var_error_msg;
                END;
            END IF;
                    /* 20191010 updated the error code due to the number must be between 17000 and 2147483647 */
            SELECT
                210001
            INTO pas_return_code;
            RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := pas_return_code;
            RETURN;
        END;
    END IF;
 
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "web_cpi_patient_update" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
