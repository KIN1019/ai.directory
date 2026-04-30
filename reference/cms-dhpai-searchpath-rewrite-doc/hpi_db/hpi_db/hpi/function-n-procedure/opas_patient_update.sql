-- DROP PROCEDURE hpi.opas_patient_update(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, inout varchar, inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in int4, in timestamp, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE opas_patient_update(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_patient_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc_1 character varying, IN par_ccc_2 character varying, IN par_ccc_3 character varying, IN par_ccc_4 character varying, IN par_ccc_5 character varying, IN par_ccc_6 character varying, IN par_chi_name character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_reference character varying, IN par_medical_record_number character varying, IN par_remark character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_phone1 character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone character varying, IN par_sms_language character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_death_code character varying, IN par_card_holder integer, INOUT par_patient_key character varying, INOUT par_priority integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_phone1 character varying, IN par_nok_phone2 character varying, IN par_nok_address_indicator character varying, IN par_nok_mobile_phone character varying, IN par_nok_sms_language character varying, IN par_txn_type character varying, IN par_access_code integer, IN par_security integer, IN par_transaction_datetime timestamp without time zone, IN par_update_hospital character varying, IN par_update_by character varying, IN par_last_update_datetime timestamp without time zone, IN par_source_system character varying, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_hkic_symbol character varying DEFAULT NULL::character varying, IN par_hkic_symbol_clear character varying DEFAULT 'N'::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* 2016-05-25 jw - improve handling for opas database name in different environment */
/* 2010-12-07 SMR20017866 HKIC Symbol input in Registration */
/* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration */
/* 2004-12-07 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number */

/* ***** Object:  Stored Procedure opas_patient_update    Script Date: 11/10/96 15:35:41 ***** */
/* 2004-12-07 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number - Start */
/* 2004-12-07 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number - End */

/* 2010-12-21 SMR20017866 HKIC Symbol input in Registration - Start */

/* 2010-12-21 SMR20017866 HKIC Symbol input in Registration - End */
DECLARE
    var_return_code INTEGER;
   

begin
	set search_path to hpi,public;
    
    CALL cpi_patient_update( var_return_code,par_hospital_code, par_hkid, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_chi_name, par_marital_status, par_race_code, par_other_document_no, par_reference, par_medical_record_number, par_remark, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_phone1, par_phone2, par_address_indicator, par_mobile_phone, par_sms_language, par_death_indicator, par_death_date, par_death_code, par_card_holder, par_patient_key, par_priority, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language, par_txn_type, par_access_code, par_security, par_transaction_datetime, par_update_hospital, par_update_by, par_last_update_datetime, par_source_system,
    /* 2004-12-07 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number - Start */
    par_document_flag,
    /* 2004-12-07 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number - End */
    
    /* 2010-12-07 SMR20017866 HKIC Symbol input in Registration - Start */
    par_hkic_symbol, par_hkic_symbol_clear);
      
   

    /* 2010-12-07 SMR20017866 HKIC Symbol input in Registration - End */
    pas_return_code := var_return_code;
 
    RETURN;
END;
$procedure$
;



;ALTER PROCEDURE "opas_patient_update" OWNER TO "HPI_SCHEMA_OWNER_ROLE";