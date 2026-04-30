-- DROP PROCEDURE hkpmi.hkpmi_patient_update(inout int4, in varchar, inout varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_patient_update(INOUT pas_return_code integer, IN par_hospital_code character varying, INOUT par_patient_key character varying, IN par_hkid character varying, IN par_patient_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc_1 character varying, IN par_ccc_2 character varying, IN par_ccc_3 character varying, IN par_ccc_4 character varying, IN par_ccc_5 character varying, IN par_ccc_6 character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_doc_no character varying, IN par_mrn character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_phone1_no character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone_no character varying, IN par_sms_language character varying, IN par_patient_type character varying, INOUT par_access_code integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_phone1 character varying, IN par_nok_phone2 character varying, IN par_nok_address_indicator character varying, IN par_nok_mobile_phone_no character varying, IN par_nok_sms_language character varying, IN par_txn_type character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_new_hkid character varying, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_hkic_symbol character varying DEFAULT NULL::character varying, IN par_hkic_symbol_clear character varying DEFAULT 'N'::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_error INTEGER;
    var_return_error_code INTEGER;

    var_return_code INTEGER;
    var_begin_tran VARCHAR(01);
    var_merge VARCHAR(01);
    var_tmp_new_hkid VARCHAR(12);
    var_tmp_txn_type VARCHAR(03);
    var_org_patient_type VARCHAR(03);
    var_tmp_patient_key VARCHAR(08);
    var_org_mrn VARCHAR(08);
	error_message varchar;
    sql$rowcount BIGINT;
	var_start_time timestamp(6);
begin
	SET search_path TO hkpmi, public;
    <<return_error>>
    BEGIN
        /* Declaration */

        /* Validate key fields */
		select 'Y' into var_begin_tran;
        IF par_new_hkid is NULL THEN
            BEGIN
                SELECT
                    par_hkid
                    INTO par_new_hkid;
            END;
        END IF;
        IF par_new_hkid != par_hkid AND EXISTS (SELECT
            *
            FROM patient
            WHERE hkid = par_new_hkid) THEN
            BEGIN
                /* reject change hkid if to hkid alread exists */
                /*
                select @merge = "Y"
                select @tmp_new_hkid = @hkid
                select @tmp_txn_type = '030'
                */
                SELECT
                    200175
                    INTO var_return_error_code;
                RAISE EXCEPTION '';
            END;
        ELSE
            BEGIN
                SELECT
                    'N'
                    INTO var_merge;
                SELECT
                    par_new_hkid
                    INTO var_tmp_new_hkid;
                SELECT
                    par_txn_type
                    INTO var_tmp_txn_type;
            END;
        END IF;
        IF par_txn_type = '031' THEN
            BEGIN
                SELECT
                    relationship, nok_name, n.hkid, n.building, n.room, n.floor, n.block, n.district, n.phone1, n.phone2, n.address_indicator, n.mobile_phone, n.sms_language
                    INTO par_nok_relation_code, par_nok_name, par_nok_hkid, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone_no, par_nok_sms_language
                    FROM nok AS n, patient AS p
                    WHERE p.hkid = par_hkid AND n.patient_key = p.patient_key AND n.major_nok = 'Y';
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                IF sql$rowcount = 0 THEN
                    BEGIN
                        SELECT
                            NULL
                            INTO par_nok_name;
                    END;
                END IF;
            END;
        END IF;
		-- 
        CALL hkpmi_patient_update_1(var_return_code, par_hospital_code, par_patient_key, par_hkid, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_marital_status, par_race_code, par_other_doc_no, par_mrn, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_phone1_no, par_phone2, par_address_indicator, par_mobile_phone_no, par_sms_language, par_patient_type, par_access_code, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone_no, par_nok_sms_language, var_tmp_txn_type, par_source_system_dtm, par_update_by, par_source_system, var_tmp_new_hkid, par_document_flag, par_hkic_symbol, par_hkic_symbol_clear);
	    IF var_return_code != 0 THEN
            BEGIN
                IF var_return_code > 200000 THEN
                    SELECT
                        var_return_code
                        INTO var_return_error_code;
                ELSE
                    SELECT
                        200128
                        INTO var_return_error_code;
                END IF;
                RAISE EXCEPTION '';
            END;
        END IF;

        IF par_txn_type = '031' THEN
            BEGIN

                SELECT
                    patient_key
                    FROM non_ha_patient_status
                    WHERE patient_key = par_patient_key;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
				

                IF sql$rowcount > 0 THEN
                    begin

                        CALL hkpmi_set_nonha_pat_status(par_patient_key => par_patient_key, par_status => 'Changed', par_source_system => par_source_system, par_update_hospital => par_hospital_code, par_update_datetime => par_source_system_dtm, par_update_by => par_update_by, par_action => 'U', pas_return_code =>  var_return_code);
                        IF var_return_code != 0 THEN
                            BEGIN
                                IF var_return_code > 500000 THEN
                                    SELECT
                                        var_return_code
                                        INTO var_return_error_code;
                                ELSE
                                    SELECT
                                        500035
                                        INTO var_return_error_code;
                                END IF;
                                RAISE EXCEPTION '';
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;

        IF var_merge = 'Y' THEN
            BEGIN
                CALL hkpmi_patient_merge(par_hospital_code => par_hospital_code, par_from_hkid => par_hkid, par_to_hkid => par_new_hkid, par_to_patient_key => par_patient_key, par_to_access_code => par_access_code, par_source_system_dtm => par_source_system_dtm, par_update_by => par_update_by, par_source_system => par_source_system, par_txn_type => '020', pas_return_code =>  var_return_code);

                IF var_return_code != 0 THEN
                    BEGIN
                        IF var_return_code > 200000 THEN
                            SELECT
                                var_return_code
                                INTO var_return_error_code;
                        ELSE
                            SELECT
                                200129
                                INTO var_return_error_code;
                        END IF;
                        RAISE EXCEPTION '';
                    END;
                END IF;
                /* Keep orginal to_patient's MRN and patient_type */
                SELECT
                    patient_type, patient_key
                    INTO var_org_patient_type, var_tmp_patient_key
                    FROM patient
                    WHERE hkid = par_new_hkid;
                SELECT
                    mrn
                    INTO var_org_mrn
                    FROM patient_hospital_data
                    WHERE patient_key = var_tmp_patient_key AND hospital_code = par_hospital_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount <> 1 THEN
                    SELECT
                        NULL
                        INTO var_org_mrn;
                END IF;
                /*
                update To_patient's demo as From patient's besides non_demo info.
                - mrn and patient_type
                */
                CALL hkpmi_patient_update_1(var_return_code, par_hospital_code, par_patient_key, par_new_hkid, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_marital_status, par_race_code, par_other_doc_no, var_org_mrn, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_phone1_no, par_phone2, par_address_indicator, par_mobile_phone_no, par_sms_language, var_org_patient_type, par_access_code, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone_no, par_nok_sms_language, var_tmp_txn_type, par_source_system_dtm, par_update_by, par_source_system, par_new_hkid, par_document_flag, par_hkic_symbol, par_hkic_symbol_clear);

                IF var_return_code != 0 THEN
                    BEGIN
                        IF var_return_code > 200000 THEN
                            SELECT
                                var_return_code
                                INTO var_return_error_code;
                        ELSE
                            SELECT
                                200128
                                INTO var_return_error_code;
                        END IF;
                        RAISE EXCEPTION '';
                    END;
                END IF;
            END;
        END IF;
        pas_return_code := 0;
        RETURN;
		exception
			when others then
				GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
				EXIT return_error;
				
    END;

--    RAISE EXCEPTION USING ERRCODE := var_return_error_code;
    pas_return_code := var_return_error_code;
    RETURN;

END;
$procedure$
;


ALTER PROCEDURE "hkpmi_patient_update" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
