-- DROP FUNCTION hpi.opas_get_pat_info(varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.opas_get_pat_info(par_hkpmi character varying, par_hospital character varying, par_hkid character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/* ***** Object:  Stored Procedure dbo.opas_get_pat_info    Script Date: 11/10/96 15:34:07 ***** */
/* 2005-04-15 Noel Chan SMR20014280 Create Case read patient directly from CPI */
DECLARE
    var_patient_no INTEGER;
    var_case_no VARCHAR(24);
    var_patient_name VARCHAR(96);
    var_sex VARCHAR(2);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag VARCHAR(2);
    var_ccc_1 VARCHAR(10);
    var_ccc_2 VARCHAR(10);
    var_ccc_3 VARCHAR(10);
    var_ccc_4 VARCHAR(10);
    var_ccc_5 VARCHAR(10);
    var_ccc_6 VARCHAR(10);
    var_chi_name VARCHAR(24);
    var_marital_status VARCHAR(2);
    var_race_code VARCHAR(4);
    var_other_document_no VARCHAR(24);
    var_reference VARCHAR(40);
    var_mrn VARCHAR(16);
    var_remark VARCHAR(500);
    var_building VARCHAR(94);
    var_room VARCHAR(10);
    var_floor VARCHAR(4);
    var_block VARCHAR(4);
    var_district_code VARCHAR(10);
    var_religion_code VARCHAR(6);
    var_home_phone_no VARCHAR(20);
    var_other_phone_no_1 VARCHAR(20);
    var_other_phone_ext_1 VARCHAR(8);
    var_other_phone_no_2 VARCHAR(20);
    var_other_phone_ext_2 VARCHAR(8);
    var_death_indicator VARCHAR(2);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_death_code VARCHAR(8);
    var_card_holder INTEGER;
    var_patient_key VARCHAR(16);
    var_priority INTEGER;
    var_nok_name VARCHAR(96);
    var_nok_hkid VARCHAR(24);
    var_nok_relation_code VARCHAR(4);
    var_nok_building VARCHAR(94);
    var_nok_room VARCHAR(10);
    var_nok_floor VARCHAR(4);
    var_nok_block VARCHAR(4);
    var_nok_district_code VARCHAR(10);
    var_nok_home_phone VARCHAR(20);
    var_nok_other_phone_no_1 VARCHAR(20);
    var_nok_other_phone_ext_1 VARCHAR(8);
    var_nok_other_phone_no_2 VARCHAR(20);
    var_nok_other_phone_ext_2 VARCHAR(8);
    var_access_code INTEGER;
    var_security INTEGER;
    var_update_hospital VARCHAR(6);
    var_update_by VARCHAR(24);
    var_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_create_by VARCHAR(24);
    var_create_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_return_code int;
    p_refcur refcursor;
     var_hkic_symbol varchar;               
BEGIN
    SELECT
        '', 0
        INTO var_case_no, var_patient_no;
    CALL opas_get_patient_info(var_return_code,par_hkpmi, par_hospital, var_patient_no, par_hkid, var_case_no, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_status, var_race_code, var_other_document_no, var_reference, var_mrn, var_remark, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_death_code, var_card_holder, var_patient_key, var_priority, var_nok_name, var_nok_hkid, var_nok_relation_code, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_home_phone, var_nok_other_phone_no_1, var_nok_other_phone_ext_1, var_nok_other_phone_no_2, var_nok_other_phone_ext_2, var_access_code, var_security, var_update_hospital, var_update_by, var_update_dtm, var_create_by, var_create_dtm,var_hkic_symbol);
    OPEN p_refcur FOR
    SELECT
        var_patient_no, par_hkid, var_case_no, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_status, var_race_code, var_other_document_no, var_reference, var_mrn, var_remark, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_death_code, var_card_holder, var_patient_key, var_priority, var_nok_name, var_nok_hkid, var_nok_relation_code, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_home_phone, var_nok_other_phone_no_1, var_nok_other_phone_ext_1, var_nok_other_phone_no_2, var_nok_other_phone_ext_2, var_access_code, var_security, var_update_hospital, var_update_by, var_update_dtm, var_create_by, var_create_dtm;
      RETURN
    NEXT p_refcur;
END;
$function$
;

;ALTER FUNCTION "opas_get_pat_info" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
