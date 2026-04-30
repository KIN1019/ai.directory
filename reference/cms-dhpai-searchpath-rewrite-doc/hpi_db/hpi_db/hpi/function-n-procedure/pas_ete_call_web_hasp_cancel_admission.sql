-- DROP PROCEDURE hpi.pas_ete_call_web_hasp_cancel_admission(inout int4, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.pas_ete_call_web_hasp_cancel_admission(INOUT pas_return_code integer DEFAULT NULL::integer, IN par_in_hkid character varying DEFAULT NULL::character varying, IN par_in_case character varying DEFAULT NULL::character varying, IN par_in_case_type character varying DEFAULT 'I'::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* Specified HKID */
/* Specified Case */
/* I/A : HN/AE case */
DECLARE
    var_hosp_code VARCHAR(06);
    /* --Case data */
    var_case_no VARCHAR(24);
    var_admission_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_source_indicator VARCHAR(02);
    var_source_code VARCHAR(06);
    var_pay_code VARCHAR(06);
    var_discharge_code VARCHAR(02);
    var_discharge_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_discharge_destination VARCHAR(06);
    var_movement_count INTEGER;
    var_security_count INTEGER;
    var_case_access_code INTEGER;
    /* --Last movement data */
    var_ward_code VARCHAR(08);
    var_ward_class VARCHAR(02);
    var_specialty VARCHAR(08);
    var_bed_no VARCHAR(10);
    var_treatment_location VARCHAR(08);
    var_last_movement_tran_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_last_movement_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    /* ---------------------------------- */
    /* --Patient major keys */
    var_hkid VARCHAR(24);
    var_patient_key VARCHAR(16);
    var_name VARCHAR(96);
    var_sex VARCHAR(02);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag VARCHAR(02);
    var_ccc1 VARCHAR(10);
    var_ccc2 VARCHAR(10);
    var_ccc3 VARCHAR(10);
    var_ccc4 VARCHAR(10);
    var_ccc5 VARCHAR(10);
    var_ccc6 VARCHAR(10);
    /* --Patient data (others) */
    var_marital_status VARCHAR(02);
    var_race_code VARCHAR(04);
    var_other_document_no VARCHAR(24);
    /* --@medical_record_number char(08),  -- NOT defined @PMI_wo_MRN */
    var_religion_code VARCHAR(06);
    var_room VARCHAR(10);
    var_floor VARCHAR(04);
    var_block VARCHAR(04);
    var_district_code VARCHAR(10);
    var_building VARCHAR(94);
    var_home_phone VARCHAR(20);
    /* ---------------------------------- */
    var_office_phone VARCHAR(20);
    var_office_phone_ext VARCHAR(08);
    var_other_phone VARCHAR(20);
    var_other_phone_ext VARCHAR(08);
    var_death_indicator VARCHAR(02);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_sys_now TIMESTAMP WITHOUT TIME ZONE;
    var_rtn_code INTEGER;
    var_rtn_msg VARCHAR(255);
    var_valid_flag VARCHAR(2);
    var_case_movement_count INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<prg_end>>
    BEGIN
        /* ----------------------------------------------------------- */
        /* Declare the web_hasp_cancel_admission Input Parm List -- */
        
        /* ----------------------------------------------------------- */
        
        /* ------------------------------------------ */
        
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
            SELECT
                monitor_data
                INTO par_in_case
                FROM pas_monitor
                WHERE monitor_sys = 'PAS_ETE' AND monitor_type = 'IP_CASE';
        END IF;
        /* ---------------------------------------------- */
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_sys_now;
        SELECT
            Hospital_code
            INTO var_hosp_code
            FROM Hospital;
        SELECT
            par_in_case
            INTO var_case_no;
        SELECT
            0
            INTO var_case_movement_count;
        SELECT
            0
            INTO var_rtn_code;
        SELECT
            ''
            INTO var_rtn_msg;
        /* ---------------------------------------------- */
        /* exec  @rtn_code  = cpi..cpi_pq_validate_caseno @in_case,@hosp_code, @valid_flag out  -- CPI */
        /* exec  @rtn_code  = cpi_pq_validate_caseno @in_case,@hosp_code, @valid_flag out */
        /* if (@valid_flag = N or @rtn_code  != 0) */
        /* begin */
        /* select @rtn_code = -1 */
        /* select @rtn_msg	= in_hkid[ + @in_hkid + ]in_case[ + @in_case + ] ==> Invalid Case No with rtn_code[ + convert(char(5),@rtn_code) +] */
        /* goto prg_end */
        /* end */
        
        /* ---------------------------------------------- */
        /* Case Information */
        
        /* ---------------------------------------------- */
        SELECT
            Admission_datetime, Source_indicator, Source_code, Pay_code, Discharge_code, Discharge_datetime, Destination_code, Movement_count, Security_count, Access_code
            INTO var_admission_datetime, var_source_indicator, var_source_code, var_pay_code, var_discharge_code, var_discharge_datetime, var_discharge_destination, var_movement_count, var_security_count, var_case_access_code
            FROM ADT_Case
            /* Same for CPI/HPI -- */
            WHERE Hospital_code = var_hosp_code AND Case_no = var_case_no;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            BEGIN
                SELECT
                    -2
                    INTO var_rtn_code;
                SELECT
                    CONCAT('in_hkid[', par_in_hkid, ']in_case[', par_in_case, '] ==> ADT_Case NOT Found with rtn_code[', CAST (var_rtn_code AS VARCHAR(10)), ']')
                    INTO var_rtn_msg;
                EXIT prg_end;
            END;
        END IF;
        /* ---------------------------------------------- */
        /* Check Case Movement Count -- */
        
        /* ---------------------------------------------- */
        SELECT
            COUNT(*)
            INTO var_case_movement_count
            FROM Movement
            /* XPKcpi_movement  hospital_code, case_no, movement_count clustered, unique */
            WHERE Hospital_code = var_hosp_code AND Case_no = var_case_no;
        IF var_case_movement_count > 1 THEN
            BEGIN
                SELECT
                    -3
                    INTO var_rtn_code;
                SELECT
                    CONCAT('in_hkid[', par_in_hkid, ']in_case[', par_in_case, '] ==> Case Movement Over 1 with rtn_code[', CAST (var_rtn_code AS VARCHAR(10)), ']')
                    INTO var_rtn_msg;
                EXIT prg_end;
            END;
        END IF;
        /* ---------------------------------------------- */
        /* Case Movement Information */
        
        /* ---------------------------------------------- */
        SELECT
            Ward_code, Ward_class, Specialty_code, Bed_no, Treatment_location, Movement_datetime, System_datetime
            INTO var_ward_code, var_ward_class, var_specialty, var_bed_no, var_treatment_location, var_last_movement_tran_datetime, var_last_movement_system_datetime
            FROM Movement
            /* XPKcpi_movement  hospital_code, case_no, movement_count clustered, unique */
            WHERE Hospital_code = var_hosp_code AND Case_no = var_case_no AND Movement_count = 1;
        /* @movement_count */
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            BEGIN
                SELECT
                    -4
                    INTO var_rtn_code;
                SELECT
                    CONCAT('in_hkid[', par_in_hkid, ']in_case[', par_in_case, '] ==> Movement NOT Found with rtn_code[', CAST (var_rtn_code AS VARCHAR(10)), ']')
                    INTO var_rtn_msg;
                EXIT prg_end;
            END;
        END IF;
        /* ---------------------------------------------- */
        /* Patient  Information */
        
        /* ---------------------------------------------- */
        SELECT
            Name, Sex, DOB, Exact_DOB_flag, CCC_1, CCC_2, CCC_3, CCC_4, CCC_5, CCC_6, Marital_status, Race_code, Other_document_no, Building, Room, Floor, Block, District_code, phone1, Religion_code, phone2,
            /* OfficePhone */
            address_indicator, mobile_phone, sms_language, Death_indicator, Death_date, T_PRK
            INTO var_name, var_sex, var_dob, var_exact_dob_flag, var_ccc1, var_ccc2, var_ccc3, var_ccc4, var_ccc5, var_ccc6, var_marital_status, var_race_code, var_other_document_no, var_building, var_room, var_floor, var_block, var_district_code, var_home_phone, var_religion_code, var_office_phone, var_office_phone_ext, var_other_phone, var_other_phone_ext, var_death_indicator, var_death_date, var_patient_key
            FROM PMI_wo_MRN
            /* Same for CPI/HPI -- */
            WHERE HKID = par_in_hkid;
        /* ----------------------------------------------- */
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            BEGIN
                SELECT
                    -5
                    INTO var_rtn_code;
                SELECT
                    CONCAT('in_hkid[', par_in_hkid, ']in_case[', par_in_case, '] ==> Patient NOT Found with rtn_code[', CAST (var_rtn_code AS VARCHAR(10)), ']')
                    INTO var_rtn_msg;
                EXIT prg_end;
            END;
        END IF;
        /* ---------------------------------------------- */
        CALL web_hasp_cancel_admission(var_rtn_code, var_hosp_code, '@PAS_ETE',
        /* @user_id char(08), */
        '201',
        /* @transaction_type char(03),  [201 : Cancellation of Admission (Inpatient)] */
        
        /* --Case data-- */
        var_case_no, var_admission_datetime, var_source_indicator, var_source_code, var_pay_code, var_discharge_code, var_discharge_datetime, var_discharge_destination, var_movement_count, var_security_count, var_case_access_code,
        /* --AE case detail -- */
        NULL,
        /* @ae_case_type char(01), */
        NULL,
        /* @ambulance_no char(04), */
        NULL,
        /* @dba_flag char(01), */
        NULL,
        /* @follow_up_datetime datetime, */
        NULL,
        /* @labour_case char(01), */
        NULL,
        /* @police_case char(01), */
        /* --Last movement data -- */
        var_ward_code, var_ward_class, var_specialty, var_bed_no, var_treatment_location, var_last_movement_tran_datetime, var_last_movement_system_datetime,
        /* --Patient major keys */
        par_in_hkid, var_patient_key, var_name, var_sex, var_dob, var_exact_dob_flag, var_ccc1, var_ccc2, var_ccc3, var_ccc4, var_ccc5, var_ccc6,
        /* --Patient data (others) */
        var_marital_status, var_race_code, var_other_document_no, NULL,
        /* --- @medical_record_number char(08), */
        var_religion_code, var_room, var_floor, var_block, var_district_code, var_building, var_home_phone, var_office_phone, var_office_phone_ext, var_other_phone, var_other_phone_ext, var_death_indicator, var_death_date, 2147483647);
        /* @pmi_access_code int */
        
        /* -------------------------------------- */
        IF var_rtn_code = 0 THEN
            SELECT
                CONCAT('in_hkid[', par_in_hkid, ']in_case[', par_in_case, '] ==> call <web_hasp_cancel_admission> with rtn_code[', CAST (var_rtn_code AS VARCHAR(10)), ']')
                INTO var_rtn_msg;
        ELSE
            SELECT
                CONCAT('in_hkid[', par_in_hkid, ']in_case[', par_in_case, '] ==> Fail to call <web_hasp_cancel_admission> with rtn_code[', CAST (var_rtn_code AS VARCHAR(20)), ']')
                INTO var_rtn_msg;
        END IF;
    END;
    /* ---------------------------------- */
    UPDATE pas_monitor
    SET monitor_data = var_rtn_msg, monitor_dtm = var_sys_now, update_dtm = timestamp_convert(localtimestamp)
        WHERE monitor_sys = 'PAS_ETE' AND monitor_type = 'IP_CANCEL';
    /* -------------------------------------- */
    pas_return_code := var_rtn_code;
    RETURN;
END;
$procedure$
;
