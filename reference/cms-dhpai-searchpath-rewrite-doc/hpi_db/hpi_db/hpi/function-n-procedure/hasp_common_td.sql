-- DROP PROCEDURE hpi.hasp_common_td(inout int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_common_td(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_t_datetime timestamp without time zone, IN par_t_case_no character varying, IN par_t_to_ns_code character varying, IN par_t_to_specialty character varying, IN par_t_to_class character varying, IN par_t_to_bed_no character varying, IN par_t_ns_code character varying, IN par_t_doctor character varying, IN par_t_user_id character varying, IN par_t_case_timestamp timestamp without time zone, IN par_trans_type character varying, IN par_iso_status character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* -------------------------------------------------------------- */
/* This store procedure is developed base on the LRR/DT version */
/* Date                : 01st Dec,  1995 */
/* Project             : IPAS/ADT v2.0 */
/* Server              : Sybase 10.0.2 */
/* O.S.                : AIX 3.2.5 */
/* AIX file name       : sp_co_td.sql */
/* call from           : hasp_transfer         -140(Trans.type) */
/* : hasp_trial_discharge  -160(Trans.type) */
/* : hasp_return_td        -170(Trans.type) */
/* History		: CR11337 check bed_history */
/* : CR11468 check bed_history only when Hospital_control.text_value = 'Y' where Type = íºbed_allocation */
/* : CR31244 Add ISO_STATUS to capture patient isolation status by Yorky LEUNG */
/* -------------------------------------------------------------- */
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_return_code INTEGER;
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ward_treatment_location VARCHAR(4);
    var_home_ward VARCHAR(4);
    var_home_specialty VARCHAR(4);
    var_ward_code VARCHAR(4);
    var_specialty_code VARCHAR(4);
    var_bed_no VARCHAR(5);
    var_ward_class VARCHAR(1);
    var_movement_type VARCHAR(1);
    var_movement_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_treatment_location VARCHAR(4);
    var_old_doctor_code VARCHAR(8);
    var_message VARCHAR(80);
    var_case_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_case_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_case_movement_count INTEGER;
    var_admission_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_source_indicator VARCHAR(1);
    var_source_code VARCHAR(3);
    var_hkid VARCHAR(12);
    var_district_code VARCHAR(5);
    var_pay_code VARCHAR(3);
    var_discharge_code VARCHAR(1);
    var_discharge_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_destination_code VARCHAR(3);
    var_case_type VARCHAR(1);
    var_security_count INTEGER;
    var_case_access_code INTEGER;
    var_name VARCHAR(48);
    var_sex VARCHAR(01);
    var_ccc_1 VARCHAR(05);
    var_ccc_2 VARCHAR(05);
    var_ccc_3 VARCHAR(05);
    var_ccc_4 VARCHAR(05);
    var_ccc_5 VARCHAR(05);
    var_ccc_6 VARCHAR(05);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag VARCHAR(01);
    var_marital_status VARCHAR(01);
    var_race_code VARCHAR(02);
    var_other_document_no VARCHAR(12);
    var_medical_record_number VARCHAR(08);
    var_pmi_building VARCHAR(47);
    var_pmi_room VARCHAR(05);
    var_pmi_floor VARCHAR(02);
    var_pmi_block VARCHAR(02);
    var_pmi_district_code VARCHAR(05);
    var_pmi_religion_code VARCHAR(03);
    var_home_phone_no VARCHAR(10);
    var_other_phone_no_1 VARCHAR(10);
    var_other_phone_ext_1 VARCHAR(04);
    var_other_phone_no_2 VARCHAR(10);
    var_other_phone_ext_2 VARCHAR(04);
    var_death_indicator VARCHAR(01);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_t_prk VARCHAR(08);
    var_pmi_access_code INTEGER;
    var_status VARCHAR(1);
    var_bed_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_ward_list_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_t_to_bed_no VARCHAR(5);
    var_transaction_type VARCHAR(3);
    var_occupied_bed_status VARCHAR(1);
    var_vacant_bed_status VARCHAR(1);
    var_active_status VARCHAR(1);
    var_bed_allocation VARCHAR(1);
    sql$rowcount BIGINT;
BEGIN
    /* variables declared from IPAS v2.0 */
    SELECT
        par_Trans_type
        INTO var_transaction_type;
    SELECT
        'O'
        INTO var_occupied_bed_status;
    SELECT
        'V'
        INTO var_vacant_bed_status;

    -- CP2 & Harmonycloud on Jan-2025:
    -- Since the ownership of cmslrr_db and the migration approach are to be confirmed with other CMS teams (E.g. Related SPs may be changed to APIs),
    -- the following logic about cmslrr_db was not migrated to PG in this moment and was commented in PG DDL with this remark for record.
    /*
    CALL proc_lrr_get_hosp_map(var_return_code,var_hosp_code);

    IF var_return_code != 0 THEN
        pas_return_code := var_return_code;
        RETURN;
    END IF;
    */
    /* Yorky LEUNG 20160426 - Check isolation bed for an update on patient isolation status */
    IF par_ISO_STATUS IS NOT NULL THEN
        BEGIN
            CALL cms_dt_check_iso_bed(var_return_code,par_hosp_code, par_T_NS_CODE, par_T_TO_BED_NO, par_T_DATETIME);

            IF var_return_code != 1 THEN
                BEGIN
                    /*
                    [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
                    if @@trancount != 0
                    			begin
                    				rollback transaction
                    			end
                    */
                    RAISE EXCEPTION 'Isolation status cannot be updated as assigned bed is not isolation bed!' USING ERRCODE := '40005';
                    pas_return_code := 40005;
                    RETURN;
                END;
            END IF;
        END;
    END IF;
    /*
    [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
    begin transaction
    */
    SELECT
        clock_timestamp()
        INTO var_system_datetime;
    /* validation start here */
    /* check if home ward exist */
    /* check In-patient Case */
    /* check timestamp */
    /* check ward code */
    /* check date/time */
    /* check discharge */
    /* check transfer to another ward */
    /* check last movment is 'HOME' if return from TD */
    /* check change nothing */
    /* check to_bed is vacant */
    /* insert Movment */
    /* Comment by Stephen CHAN */
    /*
    select  @ward_treatment_location = Treatment_location
    from    Ward
    where   Ward_code = @T_TO_NS_CODE
    */
    /*
    by ivy for hpi
             insert  Movement
                   (Case_no,
                    Movement_count,
                    Ward_code,
                    Bed_no,
                    Specialty_code,
                    Ward_class,
                    Movement_type,
                    Movement_datetime,
                    Treatment_location,
                    System_datetime,
                    User_ID,
                    Doctor_code
                   )
            values (@T_CASE_NO,
                    @case_movement_count,
                    @T_TO_NS_CODE,
                    @t_to_bed_no,
                    @T_TO_SPECIALTY,
                    @T_TO_CLASS,
                    'T',
                    @T_DATETIME,
                    @ward_treatment_location,
                    @system_datetime,
                    @T_USER_ID,
                    @T_DOCTOR
                   )
            select @error = @@error
            if @error != 0
                    begin
                            rollback transaction
                            return @error
                    end
    
            update  Case_view
            set     Movement_count = @case_movement_count,
    				      System_datetime = @system_datetime
    		  from	cpi_case c1
            where   Case_no = @T_CASE_NO
            and     c1.update_dtm = @case_system_datetime
    		  and		 c1.case_no = Case_no
    		  and 	 c1.hospital_code = @hosp_code
    
            select @error = @@error
            if @error != 0
                    begin
                            rollback transaction
                            return @error
                    end
    
            update  Ward_list
            set     Bed_no = @t_to_bed_no,
                    Ward_code = @T_TO_NS_CODE,
                    Specialty_code = @T_TO_SPECIALTY
            where   Case_no = @T_CASE_NO
            and     timestamp = @ward_list_timestamp
    
            select @error = @@error
            if @error != 0
                    begin
                            rollback transaction
                            return @error
                    end
    
            if isnull(@t_to_bed_no, ) != isnull(@bed_no, )
                    begin
                            if @t_to_bed_no != null
                                    begin
                                            update  Bed
                                            set     Status = @occupied_bed_status
                                            where   Ward_code = @T_TO_NS_CODE
                                            and     Bed_no  = @t_to_bed_no
                                            and     timestamp = @bed_timestamp
    
                                            select @error = @@error
                                            if @error != 0
                                            begin
                                                    rollback transaction
                                                    return @error
                                            end
                                    end
                            if @bed_no != null
                                    begin
                                            select  @status = Status,
                                                    @bed_timestamp = timestamp
                                                    from   Bed     holdlock
                                            where   Ward_code = @ward_code
                                            and     Bed_no  = @bed_no
    
                                            select @error = @@error
                                            if @error != 0
                                                    begin
                                                            rollback transaction
                                                            return @error
                                                    end
    
                                            update  Bed
                                            set     Status = @vacant_bed_status
                                            where   Ward_code = @ward_code
                                            and     Bed_no  = @bed_no
                                            and     timestamp = @bed_timestamp
    
                                            select @error = @@error
                                            if @error != 0
                                            begin
                                                    rollback transaction
                                                    return @error
                                            end
                                    end
                    end
    
    end by ivy for hpi
    */
    /* Insert Transaction_log */
    /* Insert Event_log */ /* mrt indicator */
    <<restart>>
    BEGIN
        SELECT
            LTRIM(RTRIM(par_T_TO_BED_NO))
            INTO var_t_to_bed_no;

        IF var_t_to_bed_no = '' THEN
            BEGIN
                SELECT
                    NULL
                    INTO var_t_to_bed_no;
            END;
        END IF;

        IF par_Trans_type = '160' OR par_Trans_type = '170' THEN
            BEGIN
                /* Comment by Stephen CHAN on 06/02/97 */
                /*
                select  @home_ward = Ward_code
                from    Ward
                where   Ward_code = 'HOME'
                */
                -- SELECT
                --     Ward_code
                --     INTO var_home_ward
                --     FROM Ward
                --     WHERE Hospital_code = var_hosp_code AND Ward_code = 'HOME' AND Effective_date <= timestamp_convert(localtimestamp)
                --     GROUP BY Ward_code
                --     HAVING Hospital_code = var_hosp_code AND Ward_code = 'HOME' AND Effective_date <= timestamp_convert(localtimestamp) AND Effective_date = MAX(Effective_date) AND Active_status = 'A';
                SELECT 
                    Ward_code
                    INTO var_home_ward
                    FROM (
                        SELECT 
                        Ward_code, Effective_date,Hospital_code,Active_status,MAX(Effective_date) OVER (PARTITION BY Ward_code) AS max_effective_date
                        FROM Ward
                        WHERE 
                        Hospital_code = par_hosp_code AND Ward_code = 'HOME'AND Effective_date <= timestamp_convert(localtimestamp)) AS subquery
                    WHERE Effective_date = max_effective_date AND Hospital_code = par_hosp_code AND Active_status = 'A';
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF var_rowcount != 1 OR var_error != 0 THEN
                    BEGIN
                        /* raiserror 102015 HOME ward not exist, cannot process! */
                        /* return 102015 */
                        RAISE EXCEPTION 'HOME ward not exist, cannot process!' USING ERRCODE := '40024';
                        pas_return_code := 40024;
                        RETURN;
                    END;
                END IF;
                /* check if home specialty exist */
                /* Comment by Stephen CHAN */
                /*
                select  @home_specialty = Specialty_code
                from    Specialty
                where   Specialty_code = 'HOME'
                */
                -- SELECT
                --     Specialty_code
                --     INTO var_home_specialty
                --     FROM Specialty
                --     WHERE
                --     /*
                --     ivy for hpi
                --     		Hospital_code = @hosp_code and
                --                     Effective_date <= getdate()
                --                 and Specialty_code = 'HOME'
                --     */
                --     Hospital_code = var_hosp_code AND Specialty_code = 'HOME' AND Effective_date <= timestamp_convert(localtimestamp)
                --     GROUP BY Specialty_code
                --     HAVING Hospital_code = var_hosp_code AND Specialty_code = 'HOME' AND Effective_date <= timestamp_convert(localtimestamp) AND Effective_date = MAX(Effective_date) AND Active_status = 'A';
                SELECT 
                    Specialty_code
                    INTO var_home_specialty
                FROM (
                    SELECT 
                    Specialty_code,Effective_date,Hospital_code,Active_status,MAX(Effective_date) OVER (PARTITION BY Specialty_code) AS max_effective_date
                    FROM Specialty
                    WHERE Hospital_code = par_hosp_code AND Specialty_code = 'HOME'AND Effective_date <= timestamp_convert(localtimestamp)) AS subquery
                WHERE Effective_date = max_effective_date AND Hospital_code = par_hosp_code AND Active_status = 'A';
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF var_rowcount != 1 OR var_error != 0 THEN
                    BEGIN
                        --ROLLBACK;
                        /* raiserror 102016 HOME specialty not exist, cannot process! */
                        /* return 102016 */
                        RAISE EXCEPTION 'HOME specialty not exist, cannot process!' USING ERRCODE := '40015';
                        pas_return_code := 40015;
                        RETURN;
                    END;
                END IF;
            END;
        END IF;

        BEGIN
            SELECT
                Case_view.row_update_datetime, to_char(update_dtm, 'YYYY-MM-DD HH24:MI:SS.MS')::TIMESTAMP WITHOUT TIME ZONE update_dtm, Case_view.Movement_count, Admission_datetime,Case_view.Source_indicator, Case_view.Source_code, HKID, Case_view.District_code, Pay_code, Case_view.Discharge_code, par_T_DATETIME,Case_view.Destination_code, Case_view.Case_type, Security_count, Case_view.Access_code
                INTO var_case_timestamp, var_case_system_datetime, var_case_movement_count, var_admission_datetime, var_source_indicator, var_source_code, var_hkid, var_district_code, var_pay_code, var_discharge_code, var_discharge_datetime, var_destination_code, var_case_type, var_security_count, var_case_access_code
                /*
                change Case to Case_view for the implementation of cpi
                from    Case
                */
                FROM Case_view, cpi_case AS c1
                WHERE Case_view.Case_no = par_T_CASE_NO AND Case_view.Hospital_code =par_hosp_code AND Case_view.Case_no = c1.case_no AND Case_view.Hospital_code = c1.hospital_code;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
		raise notice 'hasp_common_td, var_case_system_datetime:%',var_case_system_datetime;
        IF var_error != 0 THEN
            BEGIN
                pas_return_code :=var_error;
                RETURN;
            END;
        END IF;
		raise notice 'case_type:%', var_case_type;
        IF var_case_type != 'I' THEN
            BEGIN
                /* raiserror 102021 This is not an in-patient Case number!  */
                /* return 102021 */
                RAISE EXCEPTION 'This is not an in-patient Case number! ' USING ERRCODE := '40003';
                pas_return_code := 40003;
                RETURN;
            END;
        END IF;

        BEGIN
        /*
            SELECT
                Name, Sex, CCC_1, CCC_2, CCC_3, CCC_4, CCC_5, CCC_6, DOB, Exact_DOB_flag, Marital_status, Race_code, Other_document_no, Medical_record_number, Building, Room, Floor, Block, District_code, Religion_code, Home_phone_no, Other_phone_no_1, Other_phone_ext_1, Other_phone_no_2, Other_phone_ext_2, Death_indicator, Death_date, T_PRK, Access_code
                INTO var_name, var_sex, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_dob, var_exact_dob_flag, var_marital_status, var_race_code, var_other_document_no, var_medical_record_number, var_pmi_building, var_pmi_room, var_pmi_floor, var_pmi_block, var_pmi_district_code, var_pmi_religion_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_t_prk, var_pmi_access_code
                FROM PMI
                WHERE PMI_hospital_code = var_hosp_code AND HKID = var_hkid;
        */
            SELECT  name,sex, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, dob, exact_dob_flag, marital_status, race_code, other_document_no, medical_record_number, building, room, floor, block, district_code,religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date,t_prk, access_code
                INTO var_name, var_sex, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_dob, var_exact_dob_flag, var_marital_status, var_race_code, var_other_document_no, var_medical_record_number, var_pmi_building, var_pmi_room, var_pmi_floor, var_pmi_block, var_pmi_district_code, var_pmi_religion_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_t_prk, var_pmi_access_code
                FROM pmi
                WHERE pmi_hospital_code=par_hosp_code AND HKID = var_hkid ;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                --ROLLBACK;
                RAISE EXCEPTION ''; 
                pas_return_code := var_error;
                RETURN;
            END;
        END IF;

        BEGIN
            SELECT
                Ward_code, Specialty_code, Bed_no, Ward_class, Movement_type, Movement_datetime, Treatment_location, Doctor_code
                INTO var_ward_code, var_specialty_code, var_bed_no, var_ward_class, var_movement_type, var_movement_datetime, var_treatment_location, var_old_doctor_code
                /*
                change Case to Case_view for the implementation of cpi
                from   Movement, Case
                */
                FROM Movement AS m, Case_view AS c
                WHERE m.Hospital_code = par_hosp_code AND m.Case_no = par_T_CASE_NO AND m.Hospital_code = c.Hospital_code AND m.Case_no = c.Case_no AND m.Movement_count = c.Movement_count;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                --ROLLBACK;
                RAISE EXCEPTION '';
                pas_return_code := var_error;
                RETURN;
            END;
        END IF;

        BEGIN
            SELECT
                row_update_datetime
                INTO var_ward_list_timestamp
                FROM Ward_list
                WHERE Hospital_code = par_hosp_code AND Case_no = par_T_CASE_NO;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                pas_return_code := var_error;
                RETURN;
            END;
        END IF;
	
        IF var_case_system_datetime != par_T_CASE_timestamp THEN
            BEGIN
                /* raiserror 102021 Case record has been modified by other user! */
                /* return 102021 */
                RAISE EXCEPTION 'Case record has been modified by other user!' USING ERRCODE := '40004';
                pas_return_code := 40004;
                RETURN;
            END;
        END IF;

        IF var_ward_code != par_T_NS_CODE THEN
            BEGIN
                /* raiserror 102023 Patient not in this ward! */
                /* return 102023 */
                RAISE EXCEPTION 'Patient not in this ward!' USING ERRCODE := '40012';
                pas_return_code := 40012;
                RETURN;
            END;
        END IF;

        IF var_system_datetime < par_T_DATETIME THEN
            BEGIN
                /* raiserror 102029 Process datetime cannot be later than the system datetime! */
                /* return 102029 */
                RAISE EXCEPTION 'Process datetime cannot be later than the system datetime!' USING ERRCODE := '40001';
                pas_return_code := 40001;
                RETURN;
            END;
        END IF;

        IF var_movement_datetime > par_T_DATETIME THEN
            BEGIN
                /* raiserror 102027 Process datetime must be later than last movement! */
                /* return 102027 */
                RAISE EXCEPTION 'Process datetime must be later than last movement!' USING ERRCODE := '40000';
                pas_return_code := 40000;
                RETURN;
            END;
        END IF;

        IF var_admission_datetime > par_T_DATETIME THEN
            BEGIN
                /* raiserror 102028 Process datetime must be later than admission datetime! */
                /* return 102028 */
                RAISE EXCEPTION 'Process datetime must be later than admission datetime!' USING ERRCODE := '40021';
                pas_return_code := 40021;
                RETURN;
            END;
        END IF;

        IF var_movement_type = 'D' THEN /* D ==> discharge */
            BEGIN
                /* raiserror 102022 Patient already discharged */
                /* return 102022 */
                RAISE EXCEPTION 'Patient already discharged' USING ERRCODE := '40010';
                pas_return_code := 40010;
                RETURN;
            END;
        END IF;

        IF (var_t_to_bed_no is not NULL) AND (par_T_TO_NS_CODE != par_T_NS_CODE) THEN
            BEGIN
                /* raiserror 102035 Cannot assign bed while Transfer or Return from TD ! */
                /* return 102035 */
                RAISE EXCEPTION 'Cannot assign bed while Transfer or Return from TD !' USING ERRCODE := '40014';
                pas_return_code := 40014;
                RETURN;
            END;
        END IF;

        IF par_Trans_type = '170' AND var_ward_code != 'HOME' THEN
            BEGIN
                /* raiserror 102029 last movment is not TD, cannot process! */
                /* return 102029 */
                RAISE EXCEPTION 'last movment is not TD, cannot process!' USING ERRCODE := '40008';
                pas_return_code := 40008;
                RETURN;
            END;
        END IF;
		raise notice 'par_T_TO_NS_CODE:%,var_ward_code:%',par_T_TO_NS_CODE,var_ward_code;
        IF (par_T_TO_NS_CODE = var_ward_code) AND (par_T_TO_SPECIALTY = var_specialty_code) AND (par_T_TO_CLASS = var_ward_class) AND (COALESCE(var_t_to_bed_no, ' ') = COALESCE(var_bed_no, ' ')) THEN
            BEGIN
                /* raiserror 102026 No change can be made! */
                /* return 102206 */
                RAISE EXCEPTION 'No change can be made!' USING ERRCODE := '40019';
                pas_return_code := 40019;
                RETURN;
            END;
        END IF;

        IF (var_t_to_bed_no is not NULL) THEN
            BEGIN
                IF var_bed_no is NULL THEN
                    BEGIN
                        /* raiserror 102024 Please use Bed Assignment function to assign bed! */
                        /* return 102024 */
                        RAISE EXCEPTION 'Please use Bed Assignment function to assign bed!' USING ERRCODE := '40020';
                        pas_return_code := 40020;
                        RETURN;
                    END;
                END IF;
                /* check disabled bed */
                SELECT
                    Text_value
                    INTO var_bed_allocation
                    FROM Hospital_control
                    WHERE Type = 'bed_allocation' AND Hospital_code = par_hosp_code;

            
                IF var_bed_allocation = 'Y' THEN
                    BEGIN
                        SELECT
                            active_status
                            INTO var_active_status
                            FROM (SELECT
                                active_status, hospital_code, ward_code, bed_no, effective_datetime
                                FROM bed_history) AS ungrouped_query
                            INNER JOIN (SELECT
                                hospital_code, ward_code, bed_no, MAX(effective_datetime) AS max_1
                                FROM bed_history
                                WHERE ward_code = par_T_TO_NS_CODE AND hospital_code = par_hosp_code AND bed_no = var_t_to_bed_no AND effective_datetime <= timestamp_convert(localtimestamp)
                                GROUP BY hospital_code, ward_code, bed_no) AS grouped_query
                                ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
                            WHERE effective_datetime = max_1 AND active_status = 'A';
                        IF var_active_status != 'A' THEN
                            BEGIN
                                RAISE EXCEPTION 'Bed number does not currently exist' USING ERRCODE := '40027';
                                pas_return_code := 40027;
                                RETURN;
                            END;
                        END IF;
                    END;
                END IF;

                IF var_t_to_bed_no != var_bed_no THEN
                    BEGIN
                        BEGIN
                            SELECT
                                Status, row_update_datetime
                                INTO var_status, var_bed_timestamp
                                FROM Bed
                                WHERE Hospital_code = par_hosp_code AND Ward_code = par_T_TO_NS_CODE AND Bed_no = var_t_to_bed_no;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;

                        IF var_error != 0 THEN
                            BEGIN
                                pas_return_code := var_error;
                                RETURN;
                            END;
                        END IF;

                        IF var_status != var_vacant_bed_status THEN
                            BEGIN
                                /* raiserror 102025 Bed not vacant! */
                                /* return 102025 */
                                RAISE EXCEPTION 'Bed not vacant!' USING ERRCODE := '40002';
                                pas_return_code := 40002;
                                RETURN;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        SELECT
            Treatment_location
            INTO var_ward_treatment_location
            FROM (SELECT
                Treatment_location, Ward_code, Active_status, Effective_date, Hospital_code
                FROM Ward) AS ungrouped_query
            INNER JOIN (SELECT
                Ward_code, MAX(Effective_date) AS max_2
                FROM Ward
                WHERE Hospital_code = par_hosp_code AND Ward_code = par_T_TO_NS_CODE AND Effective_date <= par_T_DATETIME
                GROUP BY Ward_code) AS grouped_query
                ON (ungrouped_query.Ward_code = grouped_query.Ward_code OR (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL))
            WHERE Hospital_code = par_hosp_code AND ungrouped_query.Ward_code = par_T_TO_NS_CODE AND Effective_date <= timestamp_convert(localtimestamp) AND Effective_date = max_2 AND Active_status = 'A';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_rowcount != 1 OR var_error != 0 THEN
            BEGIN
                /* raiserror 102016 Treatment location not found, cannot process! */
                /* return @error */
                RAISE EXCEPTION 'Treatment location not found, cannot process!' USING ERRCODE := '40023';
                pas_return_code := 40023;
                RETURN;
            END;
        END IF;
        SELECT
            var_case_movement_count + 1
            INTO var_case_movement_count;
        CALL hasp_insert_transaction_log(var_return_code,par_hosp_code, var_system_datetime, par_T_CASE_NO, var_ward_code, var_treatment_location, var_ward_class, var_bed_no, var_specialty_code, par_T_TO_NS_CODE, var_ward_treatment_location, par_T_TO_CLASS, var_t_to_bed_no, par_T_TO_SPECIALTY, par_T_DATETIME, var_transaction_type, NULL, par_T_USER_ID, NULL, NULL);
        

        IF var_return_code != 0 THEN
            BEGIN
                --ROLLBACK;
                RAISE EXCEPTION '';
                /* annie 18022005 Trace 2601 */
                IF var_return_code = 2601 THEN
                    BEGIN
                        SELECT
                            912601
                            INTO var_return_code;
                        SELECT
                            'Error in executing hasp_insert_transaction_log'
                            INTO var_message;
                        RAISE EXCEPTION '%', var_message USING ERRCODE := var_return_code;
                    END;
                END IF;
                pas_return_code := var_return_code;
                RETURN;
            END;
        END IF;
        CALL hasp_insert_event_log(var_return_code,par_hosp_code, var_system_datetime, var_transaction_type, var_hkid, var_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_marital_status, var_race_code, var_other_document_no, var_medical_record_number, var_pmi_building, var_pmi_room, var_pmi_floor, var_pmi_block, var_pmi_district_code, var_pmi_religion_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_t_prk, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_T_CASE_NO, var_admission_datetime, var_source_indicator, var_source_code, var_pay_code, var_discharge_code, var_discharge_datetime, var_destination_code, var_case_type, var_case_movement_count, var_security_count, var_case_access_code, var_pmi_access_code, NULL, NULL, NULL, NULL, NULL, NULL, par_T_TO_NS_CODE, par_T_TO_SPECIALTY, var_t_to_bed_no, par_T_TO_CLASS, NULL, NULL, NULL, NULL, var_ward_class, var_ward_code, var_specialty_code, var_bed_no, par_T_USER_ID, par_T_DOCTOR, var_old_doctor_code, NULL, NULL);

        IF var_return_code != 0 THEN
            BEGIN
                /* annie 18022005 Trace 2601 */
                IF var_return_code = 2601 THEN
                    BEGIN
                        SELECT
                            922601
                            INTO var_return_code;
                        SELECT
                            'Error in executing hasp_insert_event_log'
                            INTO var_message;
                        RAISE EXCEPTION '%', var_message USING ERRCODE := var_return_code;
                    END;
                END IF;
                pas_return_code := var_return_code;
                RETURN;
            END;
        END IF;
     
        CALL cpi_transfer(var_return_code,par_hosp_code, par_T_CASE_NO, var_hkid, var_ward_code, var_ward_class, var_bed_no, var_specialty_code, var_old_doctor_code, par_T_TO_NS_CODE, par_T_TO_CLASS, var_t_to_bed_no, par_T_TO_SPECIALTY, par_T_DOCTOR, var_ward_treatment_location, par_T_DATETIME, var_case_type, var_transaction_type, var_system_datetime, par_T_USER_ID, 'LRRDT',
        /* CR31244 add isolation status */
        par_ISO_STATUS);

        IF var_return_code != 0 THEN
            BEGIN
                SELECT
                    messages
                    INTO var_message
                    FROM error_msgs
                    WHERE error_code = var_return_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_rowcount != 1 THEN
                    BEGIN
                        SELECT
                            CONCAT('Call cpi function failed with return code ',
                            CASE CAST (var_return_code AS VARCHAR(8))
                                WHEN '' THEN ''
                                ELSE CAST (var_return_code AS VARCHAR(8))
                            END)
                            INTO var_message;
                    END;
                END IF;
                /* annie 18022005 Trace 2601 */
                IF var_return_code = 2601 THEN
                    BEGIN
                        SELECT
                            932601
                            INTO var_return_code;
                        SELECT
                            'Error in executing cpi_transfer'
                            INTO var_message;
                    END;
                END IF;
                RAISE EXCEPTION '%', var_message USING ERRCODE := var_return_code;
                pas_return_code := var_return_code;
                RETURN;
            END;
        END IF;
        pas_return_code := 0;
        RETURN;
    END;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_common_td" OWNER TO "HPI_SCHEMA_OWNER_ROLE";