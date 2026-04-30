-- DROP PROCEDURE hpi.opas_get_patient_info(inout int4, in varchar, in varchar, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout int4, inout varchar, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout int4, inout varchar, inout varchar, inout timestamp, inout varchar, inout timestamp, inout varchar);

CREATE OR REPLACE PROCEDURE opas_get_patient_info(INOUT pas_return_code integer, IN par_hkpmi character varying, IN par_hospital character varying, INOUT par_patient_no integer, INOUT par_hkid character varying, INOUT par_case_no character varying, INOUT par_patient_name character varying, INOUT par_sex character varying, INOUT par_dob timestamp without time zone, INOUT par_exact_dob_flag character varying, INOUT par_ccc_1 character varying, INOUT par_ccc_2 character varying, INOUT par_ccc_3 character varying, INOUT par_ccc_4 character varying, INOUT par_ccc_5 character varying, INOUT par_ccc_6 character varying, INOUT par_chi_name character varying, INOUT par_marital_status character varying, INOUT par_race_code character varying, INOUT par_other_document_no character varying, INOUT par_reference character varying, INOUT par_mrn character varying, INOUT par_remark character varying, INOUT par_building character varying, INOUT par_room character varying, INOUT par_floor character varying, INOUT par_block character varying, INOUT par_district_code character varying, INOUT par_religion_code character varying, INOUT par_phone1 character varying, INOUT par_phone2 character varying, INOUT par_address_indicator character varying, INOUT par_mobile_phone character varying, INOUT par_sms_language character varying, INOUT par_death_indicator character varying, INOUT par_death_date timestamp without time zone, INOUT par_death_code character varying, INOUT par_card_holder integer, INOUT par_patient_key character varying, INOUT par_priority integer, INOUT par_nok_name character varying, INOUT par_nok_hkid character varying, INOUT par_nok_relation_code character varying, INOUT par_nok_building character varying, INOUT par_nok_room character varying, INOUT par_nok_floor character varying, INOUT par_nok_block character varying, INOUT par_nok_district_code character varying, INOUT par_nok_phone1 character varying, INOUT par_nok_phone2 character varying, INOUT par_nok_address_indicator character varying, INOUT par_nok_mobile_phone character varying, INOUT par_nok_sms_language character varying, INOUT par_access_code integer, INOUT par_security integer, INOUT par_update_hospital character varying, INOUT par_update_by character varying, INOUT par_update_dtm timestamp without time zone, INOUT par_create_by character varying, INOUT par_create_dtm timestamp without time zone, INOUT par_hkic_symbol character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* 2019-12-13 OPAS-245 - To cater failure of finding opas_db in non-PRD VH hospitals issue */
/* 2019-12-04 OPAS-245 Fix major NOK's other phone extension update issue in OPAS F1 case creation */
/* 2010-12-07 SMR20017866 HKIC Symbol input in Registration */
/* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration */
/* ***** Object:  Stored Procedure opas_get_patient_info    Script Date: 11/10/96 15:34:07 ***** */
/* Nelson 27/11/98 handle TMP, SYP, SKC */ /* 2010-12-07 SMR20017866 HKIC Symbol input in Registration */
/* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
DECLARE
    var_return_code INTEGER;
begin
	
	
    IF par_hospital = 'TMP' THEN
        SELECT
            'TMH'
            INTO par_hospital;
    END IF;

    IF par_hospital = 'SYP' THEN
        SELECT
            'QMH'
            INTO par_hospital;
    END IF;

    IF par_hospital = 'SKC' THEN
        SELECT
            'PMH'
            INTO par_hospital;
    END IF;

    IF par_hkpmi = 'Y' THEN
        BEGIN
        
                begin
	             	
                    CALL cpi_get_patient_info(var_return_code,par_hospital, par_hkid, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_chi_name, par_marital_status, par_race_code, par_other_document_no, par_reference, par_mrn, par_remark, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_phone1, par_phone2, par_address_indicator, par_mobile_phone, par_sms_language, par_death_indicator, par_death_date, par_death_code, par_card_holder, par_patient_key, par_priority, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language, par_access_code, par_security, par_update_hospital, par_update_by, par_hkic_symbol); /* 2010-12-07 SMR20017866 HKIC Symbol input in Registration */
				
                    IF par_patient_key > '' THEN
                        BEGIN
                            SELECT
                                CAST (par_patient_key AS INTEGER)
                                INTO par_patient_no;
                            SELECT
                                update_by, update_dtm, create_by, create_dtm
                                INTO par_update_by, par_update_dtm, par_create_by, par_create_dtm
                                FROM cpi_patient
                                WHERE patient_key = par_patient_key;
                        END;
                    END IF;
                END;
           
            pas_return_code := var_return_code;
            RETURN;
        END;
    ELSE
        BEGIN
            IF par_patient_no > 0 THEN
                SELECT
                    patient_key
                    INTO par_patient_key
                    FROM cpi_patient
                    WHERE patient_no = par_patient_no;
            ELSE
                IF par_hkid > '' THEN
                    SELECT
                        patient_key
                        INTO par_patient_key
                        FROM cpi_patient
                        WHERE hkid = par_hkid;
                ELSE
                    IF par_case_no > '' THEN
                        SELECT
                            patient_key
                            INTO par_patient_key
                            FROM cpi_case
                            WHERE case_no = par_case_no AND hospital_code = par_hospital;
                    END IF;
                END IF;
            END IF;
          
           if exists (  select 1
                 FROM cpi_patient
                WHERE patient_key = par_patient_key)then 
	            SELECT
	                patient_no, hkid, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, reference, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder, access_code, security, update_hospital, update_by, update_dtm, create_by, create_dtm, hkic_symbol
	                INTO par_patient_no, par_hkid, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_chi_name, par_marital_status, par_race_code, par_other_document_no, par_reference, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_phone1, par_phone2, par_address_indicator, par_mobile_phone, par_sms_language, par_death_indicator, par_death_date, par_death_code, par_card_holder, par_access_code, par_security, par_update_hospital, par_update_by, par_update_dtm, par_create_by, par_create_dtm, par_hkic_symbol /* 2010-12-07 SMR20017866 HKIC Symbol input in Registration */
	                FROM cpi_patient
	                WHERE patient_key = par_patient_key;
               end if ;
            SELECT
                mrn, remark
                INTO par_mrn, par_remark
                FROM cpi_patient_hospital_data
                WHERE patient_key = par_patient_key AND hospital_code = par_hospital;
            SELECT
                priority, nok_name, hkid, relationship, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language
                INTO par_priority, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language 
                FROM cpi_nok
                WHERE patient_key = par_patient_key AND major_nok = 'Y';
        END;
    END IF;
END;
$procedure$
;
;ALTER PROCEDURE "opas_get_patient_info" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
