-- DROP PROCEDURE hpi.hasp_common_ctd(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_common_ctd(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_t_case_no character varying, IN par_t_ns_code character varying, IN par_t_user_id character varying, IN par_t_case_timestamp timestamp without time zone, IN par_trans_type character varying)
 LANGUAGE plpgsql
AS $procedure$
/* -------------------------------------------------------------- */
/* This store procedure is developed base on the LRR/DT version */
/* Date                : 01st Dec,  1995 */
/* Project             : IPAS/ADT v2.0 */
/* Server              : Sybase 10.0.2 */
/* O.S.                : AIX 3.2.5 */
/* AIX file name       : sp_coctd.sql */
/* call from           : hasp_cancel_transfer  -220(Trans.type) */
/* : hasp_cancel_td        -230(Trans.type) */
/* : hasp_cancel_return_td -240(Trans.type) */
/* -------------------------------------------------------------- */
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_return_code INTEGER;
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_work_movement_count INTEGER;
    var_curr_ward_code VARCHAR(8);
    var_curr_bed_no VARCHAR(10);
    var_curr_specialty_code VARCHAR(8);
    var_curr_ward_class VARCHAR(2);
    var_curr_movement_type VARCHAR(2);
    var_curr_movement_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_curr_treatment_location VARCHAR(8);
    var_curr_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_curr_doctor_code VARCHAR(16);
    var_message VARCHAR(160);
    var_prev_ward_code VARCHAR(8);
    var_prev_bed_no VARCHAR(10);
    var_prev_specialty_code VARCHAR(8);
    var_prev_ward_class VARCHAR(2);
    var_prev_movement_type VARCHAR(2);
    var_prev_movement_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_prev_treatment_location VARCHAR(8);
    var_prev_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_prev_doctor_code VARCHAR(16);
    var_case_movement_count INTEGER;
    var_admission_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_source_indicator VARCHAR(2);
    var_source_code VARCHAR(6);
    var_hkid VARCHAR(24);
    var_district_code VARCHAR(10);
    var_pay_code VARCHAR(6);
    var_discharge_code VARCHAR(2);
    var_discharge_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_destination_code VARCHAR(6);
    var_case_type VARCHAR(2);
    var_case_timestamp VARCHAR(8000);
    var_case_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_security_count INTEGER;
    var_case_access_code INTEGER;
    var_name VARCHAR(96);
    var_sex VARCHAR(2);
    var_ccc_1 VARCHAR(10);
    var_ccc_2 VARCHAR(10);
    var_ccc_3 VARCHAR(10);
    var_ccc_4 VARCHAR(10);
    var_ccc_5 VARCHAR(10);
    var_ccc_6 VARCHAR(10);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag VARCHAR(2);
    var_marital_status VARCHAR(2);
    var_race_code VARCHAR(4);
    var_other_document_no VARCHAR(24);
    var_medical_record_number VARCHAR(16);
    var_pmi_building VARCHAR(94);
    var_pmi_room VARCHAR(10);
    var_pmi_floor VARCHAR(4);
    var_pmi_block VARCHAR(4);
    var_pmi_district_code VARCHAR(10);
    var_pmi_religion_code VARCHAR(6);
    var_home_phone_no VARCHAR(20);
    var_other_phone_no_1 VARCHAR(20);
    var_other_phone_ext_1 VARCHAR(8);
    var_other_phone_no_2 VARCHAR(20);
    var_other_phone_ext_2 VARCHAR(8);
    var_death_indicator VARCHAR(2);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_t_prk VARCHAR(16);
    var_pmi_access_code INTEGER;
    var_status VARCHAR(2);
    var_bed_timestamp VARCHAR(8000);
    var_ward_list_timestamp VARCHAR(8000);
    var_tx_common_ctd VARCHAR(6);
    var_occupied_bed_status VARCHAR(2);
    var_vacant_bed_status VARCHAR(2);
    var_transfer VARCHAR(2);
    sql$rowcount BIGINT;
BEGIN
    /* declare variables */
    SELECT
        par_trans_type
        INTO var_tx_common_ctd;
    SELECT
        'O'
        INTO var_occupied_bed_status;
    SELECT
        'V'
        INTO var_vacant_bed_status;
    SELECT
        'T'
        INTO var_transfer;
       
    -- CP2 & Harmonycloud on Jan-2025:
    -- Since the ownership of cmslrr_db and the migration approach are to be confirmed with other CMS teams (E.g. Related SPs may be changed to APIs),
    -- the following logic about cmslrr_db was not migrated to PG in this moment and was commented in PG DDL with this remark for record.
    /*
    CALL proc_lrr_get_hosp_map(var_return_code, var_hosp_code);

    IF var_return_code != 0 THEN
        pas_return_code := var_return_code;
        RETURN;
    END IF;
    */
    /* validation start here */
    /* check In-patient Case */
    /* check timestamp */
    /* check ward code */
    /* check last transaction type */
    /* update From bed */
    /*
    if ward_code and bed no. no change, no need to check this statement
    refer by DT
    */
    /* update To bed */
    /*
    if (@curr_bed_no != null)
    	begin
               if ((@prev_bed_no != @curr_bed_no) and
                   (@prev_ward_code = @curr_ward_code)) or
                  (@prev_ward_code != @curr_ward_code)
                    begin
                            select  @status = Status,
                                    @bed_timestamp = timestamp
                            from    Bed     holdlock
                            where   Hospital_code = @hosp_code
    			and	Ward_code = @curr_ward_code
                            and     Bed_no  = @curr_bed_no
    
                            select @error = @@error
                            if @error != 0
                                    begin
                                            rollback transaction
                                            return @error
                                    end
                            if @status != @occupied_bed_status
                                    begin
                                            rollback transaction
                                            return @error
                                    end
                            update  Bed
                            set     Status = @vacant_bed_status
                            where   Hospital_code = @hosp_code
    			 and Ward_code = @curr_ward_code
                            and     Bed_no  = @curr_bed_no
    
                            select @error = @@error
                            if @error != 0
                                    begin
                                            rollback transaction
                                            return @error
                                    end
    
                    end
    
    	end
    */
    /* delete Movement */
    /*
    delete  Movement
            where  Hospital_code = @hosp_code
    	and Case_no = @T_CASE_NO
            and Movement_count = @case_movement_count
    
            select @error = @@error
            if @error != 0
                    begin
                            rollback transaction
                            return @error
                    end
    */
    /* update Case */
    /*
    change Case to Case_view for the implementation of cpi
    update  Case
    */
    /*
    update  Case_view
            set     Movement_count = @work_movement_count,
    				      System_datetime = @system_datetime
            where   Hospital_code = @hosp_code
            and	Case_no = @T_CASE_NO
            and     timestamp = @case_timestamp
    
            select @error = @@error
            if @error != 0
                    begin
                            rollback transaction
                            return @error
                    end
    */
    /* update Ward_list */
    /*
    update  Ward_list
            set     Bed_no = @prev_bed_no,
    		Ward_code = @prev_ward_code,
    		Specialty_code = @prev_specialty_code
            where   Hospital_code = @hosp_code
    	and     Case_no = @T_CASE_NO
            and     timestamp = @ward_list_timestamp
    
            select @error = @@error
            if @error != 0
                    begin
                            rollback transaction
                            return @error
                    end
    */
    /* Insert Transaction_log */
    /* Insert Event_log */ /* mrt indicator */
    <<restart>>
    BEGIN
        SELECT
            localtimestamp
            INTO var_system_datetime;

        BEGIN
            SELECT
                Case_view.row_update_datetime, Case_view.Movement_count, Admission_datetime, Case_view.Source_indicator, Case_view.Source_code, HKID, Case_view.District_code, Pay_code, Case_view.Discharge_code, Discharge_datetime, Case_view.Destination_code, Case_view.Case_type, update_dtm, Security_count, Case_view.Access_code
                INTO var_case_timestamp, var_case_movement_count, var_admission_datetime, var_source_indicator, var_source_code, var_hkid, var_district_code, var_pay_code, var_discharge_code, var_discharge_datetime, var_destination_code, var_case_type, var_case_system_datetime, var_security_count, var_case_access_code
                /*
                change Case to Case_view for the implementation of cpi
                from    Case
                */
                FROM Case_view, cpi_case AS c1
                WHERE Case_view.Case_no = par_t_case_no AND Case_view.Hospital_code = par_hosp_code AND Case_view.Case_no = c1.case_no AND Case_view.Hospital_code = c1.hospital_code;
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

        IF var_case_type != 'I' THEN
            BEGIN
                /* raiserror 102031 This is not an in-patient Case number!  */
                /* return 102031 */
                RAISE EXCEPTION 'This is not an in-patient Case number! ' USING ERRCODE := '40003';
                pas_return_code := 40003;
                RETURN;
            END;
        END IF;

        BEGIN
            SELECT
                name,sex, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, dob, exact_dob_flag, marital_status, race_code, other_document_no, medical_record_number, building, room, floor, block, district_code,religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date,t_prk, access_code
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
                pas_return_code := var_error;
                RETURN;
            END;
        END IF;

        BEGIN
            SELECT
                Ward_code, Specialty_code, Bed_no, Ward_class, Movement_type, Movement_datetime, Treatment_location, m.System_datetime, m.Doctor_code
                INTO var_curr_ward_code, var_curr_specialty_code, var_curr_bed_no, var_curr_ward_class, var_curr_movement_type, var_curr_movement_datetime, var_curr_treatment_location, var_curr_system_datetime, var_curr_doctor_code
                /*
                change Case to Case_view for the implementation of cpi
                from    Movement, Case
                */
                FROM Movement AS m, Case_view AS c
                WHERE m.Hospital_code = par_hosp_code AND m.Case_no = par_t_case_no AND m.Hospital_code = c.Hospital_code AND m.Case_no = c.Case_no AND m.Movement_count = c.Movement_count;
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

        BEGIN
            SELECT
                row_update_datetime
                INTO var_ward_list_timestamp
                FROM Ward_list
                WHERE Hospital_code = par_hosp_code AND Case_no = par_t_case_no;
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

       RAISE NOTICE 'var_case_system_datetime => [%] , par_t_case_timestamp => [%]',var_case_system_datetime,par_t_case_timestamp;
        IF var_case_system_datetime != par_t_case_timestamp THEN
            BEGIN
                /* raiserror 102031 Case record has been modified by other user! */
                /* return 102031 */
                RAISE EXCEPTION 'Case record has been modified by other user!' USING ERRCODE := '40004';
                pas_return_code := 40004;
                RETURN;
            END;
        END IF;
        SELECT
            var_case_movement_count - 1
            INTO var_work_movement_count;

        BEGIN
            SELECT
                Ward_code, Specialty_code, Bed_no, Ward_class, Movement_type, Movement_datetime, Treatment_location, System_datetime, Doctor_code
                INTO var_prev_ward_code, var_prev_specialty_code, var_prev_bed_no, var_prev_ward_class, var_prev_movement_type, var_prev_movement_datetime, var_prev_treatment_location, var_prev_system_datetime, var_prev_doctor_code
                FROM Movement
                WHERE Movement.Hospital_code = par_hosp_code AND Movement.Case_no = par_t_case_no AND Movement.Movement_count = var_work_movement_count;
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

        IF par_trans_type = '230' THEN /* cancel of TD */
            BEGIN
                IF var_curr_movement_type != var_transfer OR var_curr_ward_code != 'HOME' THEN
                    BEGIN
                        /* raiserror 102032 Last transaction is not trial discharge */
                        /* return 102032 */
                        RAISE EXCEPTION 'Last transaction is not trial discharge' USING ERRCODE := '40018';
                        pas_return_code := 40018;
                        RETURN;
                    END;
                END IF;
            END;
        ELSE
            IF par_trans_type = '240' THEN /* cancel of return from TD */
                BEGIN
                    IF var_prev_movement_type != var_transfer OR var_prev_ward_code != 'HOME' THEN
                        BEGIN
                            /* raiserror 102032 Last transaction is not return from trial discharge */
                            /* return 102032 */
                            RAISE EXCEPTION 'Last transaction is not return from trial discharge' USING ERRCODE := '40016';
                            pas_return_code := 40016;
                            RETURN;
                        END;
                    END IF;
                END;
            ELSE
                IF par_trans_type = '220' THEN /* cancel of transfer */
                    BEGIN
                        IF var_curr_movement_type != var_transfer THEN
                            BEGIN
                                /* raiserror 102032 Last transaction is not transfer */
                                /* return 102032 */
                                RAISE EXCEPTION 'Last transaction is not transfer' USING ERRCODE := '40017';
                                pas_return_code := 40017;
                                RETURN;
                            END;
                        END IF;
                    END;
                END IF;
            END IF;
        END IF;

        IF var_prev_ward_code != par_t_ns_code THEN
            BEGIN
                /* raiserror 102033 Patient not in this ward! */
                /* return 102033 */
                RAISE EXCEPTION 'Patient not in this ward!' USING ERRCODE := '40012';
                pas_return_code := 40012;
                RETURN;
            END;
        END IF;

        IF NOT ((var_curr_ward_code = var_prev_ward_code) AND (COALESCE(var_curr_bed_no, 'aaa') = COALESCE(var_prev_bed_no, 'bbb'))) THEN
            BEGIN
                IF (var_prev_bed_no is not NULL) THEN
                    BEGIN
                        BEGIN
                            SELECT
                                Status, row_update_datetime
                                INTO var_status, var_bed_timestamp
                                FROM Bed
                                WHERE Hospital_code = par_hosp_code AND Ward_code = var_prev_ward_code AND Bed_no = var_prev_bed_no;
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
                                /* raiserror 102034 Original bed is occupied */
                                /* return 102034 */
                                RAISE EXCEPTION 'Original bed is occupied' USING ERRCODE := '40009';
                                pas_return_code := 40009;
                                RETURN;
                            END;
                        END IF;
                        /*
                        update  Bed
                                                set     Status = @occupied_bed_status
                                                where   Hospital_code = @hosp_code
                        			 and    Ward_code = @prev_ward_code
                                                and     Bed_no  = @prev_bed_no
                                                and     timestamp = @bed_timestamp
                        
                                                select @error = @@error
                                                if @error != 0
                                                        begin
                                                                rollback transaction
                                                                return @error
                                                        end
                        */
                    END;
                END IF;
            END;
        END IF;
        CALL hasp_insert_transaction_log(var_return_code, par_hosp_code, var_system_datetime, par_t_case_no, var_prev_ward_code, var_prev_treatment_location, var_prev_ward_class, var_prev_bed_no, var_prev_specialty_code, var_curr_ward_code, var_curr_treatment_location, var_curr_ward_class, var_curr_bed_no, var_curr_specialty_code, var_curr_movement_datetime, var_tx_common_ctd, NULL, par_t_user_id, NULL, var_curr_system_datetime);

        IF var_return_code != 0 THEN
            BEGIN
                pas_return_code := var_return_code;
                RETURN;
            END;
        END IF;
        CALL hasp_insert_event_log(var_return_code, par_hosp_code, var_system_datetime, var_tx_common_ctd, var_hkid, var_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_marital_status, var_race_code, var_other_document_no, var_medical_record_number, var_pmi_building, var_pmi_room, var_pmi_floor, var_pmi_block, var_pmi_district_code, var_pmi_religion_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_t_prk, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_t_case_no, var_admission_datetime, var_source_indicator, var_source_code, var_pay_code, var_discharge_code, var_curr_movement_datetime, /* refer to adt cancel TD */ var_destination_code, var_case_type, var_case_movement_count, var_security_count, var_case_access_code, var_pmi_access_code, NULL, NULL, NULL, NULL, NULL, NULL, var_prev_ward_code, var_prev_specialty_code, var_prev_bed_no, var_prev_ward_class, NULL, NULL, NULL, NULL, var_curr_ward_class, var_curr_ward_code, var_curr_specialty_code, var_curr_bed_no, par_t_user_id, var_curr_doctor_code, var_prev_doctor_code, NULL, NULL);

        IF var_return_code != 0 THEN
            BEGIN
                pas_return_code := var_return_code;
                RETURN;
            END;
        END IF;
       raise notice 'call cpi_cancel_transfer';
        CALL cpi_cancel_transfer(var_return_code, par_hosp_code, par_t_case_no, var_hkid, var_prev_ward_code, var_prev_ward_class, var_prev_bed_no, var_prev_specialty_code, var_prev_doctor_code, var_curr_ward_code, var_curr_ward_class, var_curr_bed_no, var_curr_specialty_code, var_curr_doctor_code, var_curr_movement_datetime, var_case_type, var_tx_common_ctd, var_system_datetime, par_t_user_id, 'LRRDT');
 raise notice 'call cpi_cancel_transfer end';
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

;ALTER PROCEDURE "hasp_common_ctd" OWNER TO "HPI_SCHEMA_OWNER_ROLE";