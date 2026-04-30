-- DROP PROCEDURE hpi.pas_ete_call_web_hasp_admission(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.pas_ete_call_web_hasp_admission(INOUT pas_return_code integer DEFAULT NULL::integer, IN par_in_hkid character varying DEFAULT NULL::character varying, IN par_in_case character varying DEFAULT NULL::character varying, IN par_in_case_type character varying DEFAULT 'I'::character varying, IN par_in_ward character varying DEFAULT 'DUMM'::character varying, IN par_in_spec character varying DEFAULT 'DUMM'::character varying, IN par_in_pay_code character varying DEFAULT 'PIP'::character varying, IN par_in_doc_code character varying DEFAULT 'A'::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* Specified HKID */
/* Specified Case HNYY990000?? */
/* I/A : HN/AE case */
/* 'DUMMY WARD FOR TEST' */
/* 'DUMMY SPECIALTY FOR TEST' */
/* N/A: No identity document */
DECLARE
    var_hosp_code VARCHAR(06);
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    /* ------------------------------------- */
    var_name VArCHAR(96);
    var_sex VARCHAR(02);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag VARCHAR(02);
    var_ccc1 VARCHAR(10);
    var_ccc2 VARCHAR(10);
    var_ccc3 VARCHAR(10);
    var_ccc4 VARCHAR(10);
    var_ccc5 VARCHAR(10);
    var_ccc6 VARCHAR(10);
    var_marital_status VARCHAR(02);
    var_race_code VARCHAR(04);
    var_other_document_no VARCHAR(24);
    /* --@medical_record_number		char(08), -- NOT defined @PMI_wo_MRN */
    var_building VARCHAR(94);
    var_room VARCHAR(10);
    var_floor VARCHAR(04);
    var_block VARCHAR(04);
    var_district_code VARCHAR(10);
    var_religion_code VARCHAR(06);
    var_home_phone_no VARCHAR(20);
    var_other_phone_no_1 VARCHAR(20);
    var_other_phone_ext_1 VARCHAR(06);
    var_other_phone_no_2 VARCHAR(20);
    var_other_phone_ext_2 VARCHAR(06);
    var_death_indicator VARCHAR(04);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_t_prk VARCHAR(16);
    var_case_no VARCHAR(24);
    var_admission_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_sys_now TIMESTAMP WITHOUT TIME ZONE;
    var_rtn_code INTEGER;
    var_rtn_msg VARCHAR(255);
    var_valid_flag VARCHAR(2);
    var_case_movement_count INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<prg_end>>
    BEGIN
        /* ---------------------------------------------------- */
        /* Declare the web_hasp_admission Input Parm List -- */
        
        /* ---------------------------------------------------- */
        
        /* ---------------------------------------------- */
        
        /* ---------------------------------------------- */
        /* Init Var and Init validation -- */
        
        /* ---------------------------------------------- */
        IF par_in_hkid IS NULL THEN
            SELECT
                'UG0300096'
                INTO par_in_hkid;
        END IF;
        /* 'UG990000?' */
        /* --select @in_case=' HN20000397Z' -- ' HNYY990000?' */

        IF par_in_case IS NULL THEN
            BEGIN
                SELECT
                    monitor_data
                    INTO par_in_case
                    FROM pas_monitor
                    WHERE monitor_sys = 'PAS_ETE' AND monitor_type = 'IP_CASE';
            END;
        END IF;
        /* ---------------------------------------------- */
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_sys_now;
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_system_datetime;
        SELECT
            Hospital_code
            INTO var_hosp_code
            FROM Hospital;
        SELECT
            par_in_case
            INTO var_case_no;
        /* --select @admission_datetime = convert(char(8),@system_datetime,112) +  06:30AM    -- */
        SELECT
            CONCAT(to_char(var_system_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ' 00:30AM')
            INTO var_admission_datetime; /* -- */
        SELECT
            0
            INTO var_rtn_code;
        SELECT
            ''
            INTO var_rtn_msg;
        /* ---------------------------------------------- */
        /* Check Case Movement Count -- */
        
        /* ---------------------------------------------- */
        SELECT
            COUNT(*)
            INTO var_case_movement_count
            FROM Movement
            /* XPKcpi_movement  hospital_code, case_no, movement_count clustered, unique */
            WHERE Hospital_code = var_hosp_code AND Case_no = var_case_no;

        IF var_case_movement_count >= 1 THEN
            BEGIN
                SELECT
                    -1
                    INTO var_rtn_code;
                SELECT
                    CONCAT('in_hkid[', par_in_hkid, ']in_case[', par_in_case, '] ==> Case Movement already exists with rtn_code[', CAST (var_rtn_code AS VARCHAR(10)), ']')
                    INTO var_rtn_msg;
                EXIT prg_end;
            END;
        END IF;
        /* ---------------------------------------------- */
        /* exec  @rtn_code  = cpi..cpi_pq_validate_caseno @in_case,@hosp_code, @valid_flag out  -- CPI */
        CALL cpi_pq_validate_caseno(var_rtn_code, par_in_case, var_hosp_code, var_valid_flag);

        IF (var_valid_flag = 'N' OR var_rtn_code != 0) THEN
            BEGIN
                SELECT
                    -2
                    INTO var_rtn_code;
                SELECT
                    CONCAT('in_hkid[', par_in_hkid, ']in_case[', par_in_case, '] ==> Invalid Case No with rtn_code[', CAST (var_rtn_code AS VARCHAR(10)), ']')
                    INTO var_rtn_msg;
                EXIT prg_end;
            END;
        END IF;
        /* ---------------------------------------------- */
        SELECT
            Name, Sex, DOB, Exact_DOB_flag, CCC_1, CCC_2, CCC_3, CCC_4, CCC_5, CCC_6, Marital_status, Race_code, Other_document_no, Building, Room, Floor, Block, District_code, phone1, Religion_code, phone2, address_indicator, mobile_phone, sms_language, Death_indicator, Death_date, T_PRK
            INTO var_name, var_sex, var_dob, var_exact_dob_flag, var_ccc1, var_ccc2, var_ccc3, var_ccc4, var_ccc5, var_ccc6, var_marital_status, var_race_code, var_other_document_no, var_building, var_room, var_floor, var_block, var_district_code, var_home_phone_no, var_religion_code, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_t_prk
            FROM PMI_wo_MRN
            /* Same for CPI/HPI -- */
            WHERE HKID = par_in_hkid;
        /* ----------------------------------------------- */
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            BEGIN
                SELECT
                    -3
                    INTO var_rtn_code;
                SELECT
                    CONCAT('in_hkid[', par_in_hkid, ']in_case[', par_in_case, '] ==> Patient NOT Found with rtn_code[', CAST (var_rtn_code AS VARCHAR(10)), ']')
                    INTO var_rtn_msg;
                EXIT prg_end;
            END;
        END IF;
        /* ------------------------------------------- */
        CALL web_hasp_admission(var_rtn_code, var_hosp_code, var_system_datetime, par_in_case_type,
        /* @case_type */
        par_in_hkid, var_name, var_sex, var_dob, var_exact_dob_flag, var_ccc1, var_ccc2, var_ccc3, var_ccc4, var_ccc5, var_ccc6, var_marital_status, var_race_code, var_other_document_no, NULL,
        /* @medical_record_number */
        var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_t_prk,
        /* -------------------------------------------- */
        /* /* major NOK */ */
        NULL,
        /* @nok_priority */
        NULL,
        /* @nok_name */
        NULL,
        /* @nok_hkid */
        NULL,
        /* @nok_relation_code */
        NULL,
        /* @nok_building */
        NULL,
        /* @nok_room */
        NULL,
        /* @nok_floor */
        NULL,
        /* @nok_block */
        NULL,
        /* @nok_district_code */
        NULL,
        /* @nok_home_phone */
        NULL,
        /* @nok_other_phone_no_1 */
        NULL,
        /* @nok_other_phone_ext_1 */
        NULL,
        /* @nok_other_phone_no_2 */
        NULL,
        /* @nok_other_phone_ext_2 */
        /* /* NOK 2 */ */
        NULL,
        /* @nok2_priority */
        NULL,
        /* @nok2_name */
        NULL,
        /* @nok2_hkid */
        NULL,
        /* @nok2_relation_code */
        NULL,
        /* @nok2_building */
        NULL,
        /* @nok2_room */
        NULL,
        /* @nok2_floor */
        NULL,
        /* @nok2_block */
        NULL,
        /* @nok2_district_code */
        NULL,
        /* @nok2_home_phone */
        NULL,
        /* @nok2_other_phone_no_1 */
        NULL,
        /* @nok2_other_phone_ext_1 */
        NULL,
        /* @nok2_other_phone_no_2 */
        NULL,
        /* @nok2_other_phone_ext_2 */
        /* /* NOK 3 */ */
        NULL,
        /* @nok3_priority */
        NULL,
        /* @nok3_name */
        NULL,
        /* @nok3_hkid */
        NULL,
        /* @nok3_relation_code */
        NULL,
        /* @nok3_building */
        NULL,
        /* @nok3_room */
        NULL,
        /* @nok3_floor */
        NULL,
        /* @nok3_block */
        NULL,
        /* @nok3_district_code */
        NULL,
        /* @nok3_home_phone */
        NULL,
        /* @nok3_other_phone_no_1 */
        NULL,
        /* @nok3_other_phone_ext_1 */
        NULL,
        /* @nok3_other_phone_no_2 */
        NULL,
        /* @nok3_other_phone_ext_2 */
        /* /* NOK 4 */ */
        NULL,
        /* @nok4_priority */
        NULL,
        /* @nok4_name */
        NULL,
        /* @nok4_hkid */
        NULL,
        /* @nok4_relation_code */
        NULL,
        /* @nok4_building */
        NULL,
        /* @nok4_room */
        NULL,
        /* @nok4_floor */
        NULL,
        /* @nok4_block */
        NULL,
        /* @nok4_district_code */
        NULL,
        /* @nok4_home_phone */
        NULL,
        /* @nok4_other_phone_no_1 */
        NULL,
        /* @nok4_other_phone_ext_1 */
        NULL,
        /* @nok4_other_phone_no_2 */
        NULL,
        /* @nok4_other_phone_ext_2 */
        /* /* NOK 5 */ */
        NULL,
        /* @nok5_priority */
        NULL,
        /* @nok5_name */
        NULL,
        /* @nok5_hkid */
        NULL,
        /* @nok5_relation_code */
        NULL,
        /* @nok5_building */
        NULL,
        /* @nok5_room */
        NULL,
        /* @nok5_floor */
        NULL,
        /* @nok5_block */
        NULL,
        /* @nok5_district_code */
        NULL,
        /* @nok5_home_phone */
        NULL,
        /* @nok5_other_phone_no_1 */
        NULL,
        /* @nok5_other_phone_ext_1 */
        NULL,
        /* @nok5_other_phone_no_2 */
        NULL,
        /* @nok5_other_phone_ext_2 */
        /* /* NOK 6 */ */
        NULL,
        /* @nok6_priority */
        NULL,
        /* @nok6_name */
        NULL,
        /* @nok6_hkid */
        NULL,
        /* @nok6_relation_code */
        NULL,
        /* @nok6_building */
        NULL,
        /* @nok6_room */
        NULL,
        /* @nok6_floor */
        NULL,
        /* @nok6_block */
        NULL,
        /* @nok6_district_code */
        NULL,
        /* @nok6_home_phone */
        NULL,
        /* @nok6_other_phone_no_1 */
        NULL,
        /* @nok6_other_phone_ext_1 */
        NULL,
        /* @nok6_other_phone_no_2 */
        NULL,
        /* @nok6_other_phone_ext_2 */
        /* /* NOK 7 */ */
        NULL,
        /* @nok7_priority */
        NULL,
        /* @nok7_name */
        NULL,
        /* @nok7_hkid */
        NULL,
        /* @nok7_relation_code */
        NULL,
        /* @nok7_building */
        NULL,
        /* @nok7_room */
        NULL,
        /* @nok7_floor */
        NULL,
        /* @nok7_block */
        NULL,
        /* @nok7_district_code */
        NULL,
        /* @nok7_home_phone */
        NULL,
        /* @nok7_other_phone_no_1 */
        NULL,
        /* @nok7_other_phone_ext_1 */
        NULL,
        /* @nok7_other_phone_no_2 */
        NULL,
        /* @nok7_other_phone_ext_2 */
        /* /* NOK 8 */ */
        NULL,
        /* @nok8_priority */
        NULL,
        /* @nok8_name */
        NULL,
        /* @nok8_hkid */
        NULL,
        /* @nok8_relation_code */
        NULL,
        /* @nok8_building */
        NULL,
        /* @nok8_room */
        NULL,
        /* @nok8_floor */
        NULL,
        /* @nok8_block */
        NULL,
        /* @nok8_district_code */
        NULL,
        /* @nok8_home_phone */
        NULL,
        /* @nok8_other_phone_no_1 */
        NULL,
        /* @nok8_other_phone_ext_1 */
        NULL,
        /* @nok8_other_phone_no_2 */
        NULL,
        /* @nok8_other_phone_ext_2 */
        /* /* NOK 9 */ */
        NULL,
        /* @nok9_priority */
        NULL,
        /* @nok9_name */
        NULL,
        /* @nok9_hkid */
        NULL,
        /* @nok9_relation_code */
        NULL,
        /* @nok9_building */
        NULL,
        /* @nok9_room */
        NULL,
        /* @nok9_floor */
        NULL,
        /* @nok9_block */
        NULL,
        /* @nok9_district_code */
        NULL,
        /* @nok9_home_phone */
        NULL,
        /* @nok9_other_phone_no_1 */
        NULL,
        /* @nok9_other_phone_ext_1 */
        NULL,
        /* @nok9_other_phone_no_2 */
        NULL,
        /* @nok9_other_phone_ext_2 */
        /* /* NOK 10 */ */
        NULL,
        /* @nok10_priority */
        NULL,
        /* @nok10_name */
        NULL,
        /* @nok10_hkid */
        NULL,
        /* @nok10_relation_code */
        NULL,
        /* @nok10_building */
        NULL,
        /* @nok10_room */
        NULL,
        /* @nok10_floor */
        NULL,
        /* @nok10_block */
        NULL,
        /* @nok10_district_code */
        NULL,
        /* @nok10_home_phone */
        NULL,
        /* @nok10_other_phone_no_1 */
        NULL,
        /* @nok10_other_phone_ext_1 */
        NULL,
        /* @nok10_other_phone_no_2 */
        NULL,
        /* @nok10_other_phone_ext_2 */
        
        /* ------------------------------------------------------------- */
        
        /* case detail */
        var_case_no, var_admission_datetime, '0',
        /* @source_indicator			char(01), --  [0 - OTHER] */
        var_hosp_code,
        /* @source_code				char(03), */
        par_in_pay_code,
        /* --@pay_code char(03) -- 'NE9' */
        1,
        /* @movement_count			int,  -- [1] */
        0,
        /* @security_count			int,  -- [0] */
        2147483647,
        /* @case_access_code	int,  -- [2147483647] */
        2147483647,
        /* @pmi_access_code	int,  -- [2147483647] */
        NULL,
        /* @ambulance_no				char(04), */
        NULL,
        /* @police_case				char(01), */
        NULL,
        /* @labour_case				char(01), */
        NULL,
        /* @ae_case_type				char(01), */
        NULL,
        /* @dba_flag					char(01), */
        '3',
        /* @ward_class			char(01) */
        par_in_ward,
        /* @ward_code  char(04), */
        par_in_spec,
        /* @specialty_code char(04), */
        '@PAS_ETE',
        /* @user_id char(08) */
        
        /* ------------------------------------------------------ */
        NULL,
        /* @pp_code			 char(08), */
        NULL,
        /* @eh_code			 char(08)	= null, */
        par_in_doc_code,
        /* @document_flag		 char(01)	= null,  ['A' - N/A: No identity document] */
        NULL,
        /* @source_hosp_code	 char(03)	= null, */
        NULL,
        /* @source_case_no	 char(12)	= null, */
        NULL,
        /* @previous_case		 char(12)	= null, */
        NULL,
        /* @hkic_symbol		 char(01)	= null, */
        /* ------------- Mother baby linkage ---------------------- */
        NULL,
        /* @mother_baby_action char(01), */
        NULL,
        /* @mother_hosp		 varchar(3), */
        NULL,
        /* @mother_case		 varchar(12), */
        NULL,
        /* @baby_hosp			 varchar(03), */
        NULL,
        /* @birth_order		 int, */
        NULL,
        /* @preg_number		 int, */
        NULL,
        /* @birth_location	 varchar(03), */
        NULL,
        /* @birth_place		 varchar(01), */
        NULL,
        /* @old_mother_case	 varchar(12), */
        NULL);
        /* @old_baby_case		 varchar(12) */
        
        /* ---------------------------------------------- */
        IF var_rtn_code = 0 THEN
            SELECT
                CONCAT('in_hkid[', par_in_hkid, ']in_case[', par_in_case, '] ==> call <web_hasp_admission> with rtn_code[', CAST (var_rtn_code AS VARCHAR(10)), ']')
                INTO var_rtn_msg;
        ELSE
            SELECT
                CONCAT('in_hkid[', par_in_hkid, ']in_case[', par_in_case, '] ==> Fail to call <web_hasp_admission> with rtn_code[', CAST (var_rtn_code AS VARCHAR(20)), ']')
                INTO var_rtn_msg;
        END IF;
    END;
    /* ---------------------------------- */
    UPDATE pas_monitor
    SET monitor_data = var_rtn_msg, monitor_dtm = var_system_datetime, update_dtm = timestamp_convert(localtimestamp)
        WHERE monitor_sys = 'PAS_ETE' AND monitor_type = 'IP_ADM';
    /* -------------------------------------- */
    pas_return_code := var_rtn_code;
    RETURN;
END;
$procedure$
;
