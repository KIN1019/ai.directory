-- DROP PROCEDURE hpi.hasp_bed_assignment(inout int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_bed_assignment(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_t_datetime timestamp without time zone, IN par_t_case_no character varying, IN par_t_bed_no character varying, IN par_t_ns_code character varying, IN par_t_user_id character varying, IN par_t_case_timestamp timestamp without time zone, IN par_iso_status character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* -------------------------------------------------------------- */
/* This store procedure is developed base on the LRR/DT version */
/* Developed by        : Watson Tsui */
/* Date                : 20th June, 1995 */
/* Project             : IPAS/ADT v2.0 */
/* Server              : Sybase 10.0.2 */
/* O.S.                : AIX 3.2.5 */
/* Function            : To perform bed assignment */
/* AIX file name       : sp_ba.sql */
/* History		: CR11337 check bed_history */
/* : CR11468 check bed_history only when Hospital_control.text_value = 'Y' where Type = íºbed_allocation" */
/* : CR31244 Yorky LEUNG 16/01/2017 Allow the update on isolation status */
/* -------------------------------------------------------------- */
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_return_code INTEGER;
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ward_code VARCHAR(4);
    var_specialty_code VARCHAR(4);
    var_bed_no VARCHAR(5);
    var_ward_class VARCHAR(1);
    var_movement_type VARCHAR(1);
    var_movement_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_treatment_location VARCHAR(4);
    var_old_doctor_code VARCHAR(8);
    var_hosp_code VARCHAR(03);
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
    var_status VARCHAR(1);
    var_bed_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_ward_list_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_transaction_type VARCHAR(3);
    var_occupied_bed_status VARCHAR(1);
    var_vacant_bed_status VARCHAR(1);
    var_active_status VARCHAR(1);
    var_bed_allocation VARCHAR(1);
    sql$rowcount BIGINT;
BEGIN
    /*
    declare @case_ns_code           char(4)
    declare @case_bed_no            varchar(5)
    declare @case_specialty         char(4)
    declare @case_class             char(1)
    declare @case_datetime          datetime
    declare @case_his_count         smallint
    declare @case_hkid              char(12)
    declare @case_adm_datetime      datetime
    declare @case_discharge_code    char(1)
    declare @case_destination       char(5)
    declare @case_diagnosis         varchar(100)
    declare @case_external_cause    varchar(40)
    declare @case_timestamp         datetime
    
    declare @bed_status             char(1)
    declare @bed_timestamp          datetime
    
    declare @movement_ns_code       char(4)
    declare @movement_bed_no        varchar(5)
    declare @movement_specialty     char(4)
    declare @movement_class         char(1)
    declare @movement_datetime      datetime
    declare @movement_sys_datetime  datetime
    declare @movement_type          char(1)
    declare @movement_timestamp     datetime
    */
    /* variables declared from IPAS v2.0 */
    SELECT
        '700'
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
   
    select par_hosp_code into var_hosp_code;
    SELECT
        timestamp_convert(localtimestamp)
        INTO var_system_datetime;
    /* validation start here */
    /* check In-patient Case */
    /* check timestamp */
    /* check date/time */
    /* check ward code */
    /* check exist in ward */
    /* check discharge */
    /* check disabled bed */
    /* check occupied bed */
    /* CR31244 Yorky LEUNG 20160426 - Check isolation bed for an update on patient isolation status */
    /* insert Movment */
    /*
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
                    @ward_code,
                    @T_BED_NO,
                    @specialty_code,
                    @ward_class,
                    'B',
                    @T_DATETIME,
                    @treatment_location,
                    @system_datetime,
                    @T_USER_ID,
                    null
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
            from    cpi_case c1
            where   Case_no = @T_CASE_NO
    		  and     c1.case_no = Case_no
    		  and     c1.update_dtm = @case_system_datetime
    		  and     c1.hospital_code = @hosp_code
    
            select @error = @@error
            if @error != 0
                    begin
                            rollback transaction
                            return @error
                    end
    
            update  Ward_list
            set     Bed_no = @T_BED_NO
            where   Case_no = @T_CASE_NO
            and     timestamp = @ward_list_timestamp
    
            select @error = @@error
            if @error != 0
                    begin
                            rollback transaction
                            return @error
                    end
    
            update  Bed
            set     Status = @occupied_bed_status
            where   Ward_code = @T_NS_CODE
            and     Bed_no  = @T_BED_NO
            and     timestamp = @bed_timestamp
    
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
        BEGIN
            SELECT
                Case_view.row_update_datetime, to_char(update_dtm, 'YYYY-MM-DD HH24:MI:SS.MS')::TIMESTAMP WITHOUT TIME ZONE update_dtm, Case_view.Movement_count, Admission_datetime, Case_view.Source_indicator, Case_view.Source_code, HKID, Case_view.District_code, Pay_code, Case_view.Discharge_code, Discharge_datetime, Case_view.Destination_code, Case_view.Case_type
                INTO var_case_timestamp, var_case_system_datetime, var_case_movement_count, var_admission_datetime, var_source_indicator, var_source_code, var_hkid, var_district_code, var_pay_code, var_discharge_code, var_discharge_datetime, var_destination_code, var_case_type
                FROM Case_view, cpi_case AS c1
                WHERE Case_view.Case_no = par_T_CASE_NO::VARCHAR AND Case_view.Hospital_code = var_hosp_code::VARCHAR AND Case_view.Case_no = c1.case_no AND Case_view.Hospital_code = c1.hospital_code;
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
                /* raiserror 102001 "This is not an in-patient Case number! " */
                /* return 102001 */
                RAISE EXCEPTION 'This is not an in-patient Case number! ' USING ERRCODE := '40003';
                pas_return_code := 40003;
                RETURN;
            END;
        END IF;

        BEGIN
            SELECT
                Ward_code, Specialty_code, Bed_no, Ward_class, Movement_type, Movement_datetime, Treatment_location, Doctor_code
                INTO var_ward_code, var_specialty_code, var_bed_no, var_ward_class, var_movement_type, var_movement_datetime, var_treatment_location, var_old_doctor_code
                FROM Movement AS m, Case_view AS c
                WHERE m.Hospital_code = var_hosp_code::VARCHAR AND m.Case_no = par_T_CASE_NO::VARCHAR AND m.Hospital_code = c.Hospital_code AND m.Case_no = c.Case_no AND m.Movement_count = c.Movement_count;
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
                Status, row_update_datetime
                INTO var_status, var_bed_timestamp
                FROM Bed
                WHERE Hospital_code = var_hosp_code::VARCHAR AND Ward_code = par_T_NS_CODE::VARCHAR AND Bed_no = par_T_BED_NO::VARCHAR;
               raise notice '123123 %,%,%,%',var_hosp_code,par_T_NS_CODE,par_T_BED_NO,var_status;
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
                WHERE Hospital_code = var_hosp_code::VARCHAR AND Case_no = par_T_CASE_NO::VARCHAR;
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
                /* raiserror 102001 "Case record has been modified by other user!" */
                /* return 102001 */
                RAISE EXCEPTION 'Case record has been modified by other user!' USING ERRCODE := '40004';
                pas_return_code := 40004;
                RETURN;
            END;
        END IF;

        IF var_system_datetime < par_T_DATETIME THEN
            BEGIN
                /* raiserror 102006 "Assignment datetime cannot be later than the system datetime!" */
                /* return 102006 */
                RAISE EXCEPTION 'Assignment datetime cannot be later than the system datetime!' USING ERRCODE := '40001';
                pas_return_code := 40001;
                RETURN;
            END;
        END IF;

        IF var_movement_datetime > par_T_DATETIME THEN
            BEGIN
                /* raiserror 102007 "Assignment datetime cannot be earlier than last movement!" */
                /* return 102007 */
                RAISE EXCEPTION 'Assignment datetime cannot be earlier than last movement!' USING ERRCODE := '40000';
                pas_return_code := 40000;
                RETURN;
            END;
        END IF;

        IF var_ward_code != par_T_NS_CODE THEN
            BEGIN
                /* raiserror 102002 "Patient not in this ward!" */
                /* return 102002 */
                RAISE EXCEPTION 'Patient not in this ward!' USING ERRCODE := '40012';
                pas_return_code := 40012;
                RETURN;
            END;
        END IF;

        IF var_bed_no is not NULL THEN
            BEGIN
                /* raiserror 102003 "Patient bed already assigned" */
                /* return 102003 */
                RAISE EXCEPTION 'Patient bed already assigned' USING ERRCODE := '40011';
                pas_return_code := 40011;
                RETURN;
            END;
        END IF;

        IF var_movement_type = 'D' THEN /* D ==> discharge */
            BEGIN
                /* raiserror 102004 "Patient already discharged" */
                /* return 102004 */
                RAISE EXCEPTION 'Patient already discharged' USING ERRCODE := '40010';
                pas_return_code := 40010;
                RETURN;
            END;
        END IF;
        SELECT
            Text_value
            INTO var_bed_allocation
            FROM Hospital_control
            WHERE Type = 'bed_allocation' AND Hospital_code = var_hosp_code::VARCHAR;

        IF var_bed_allocation = 'Y' THEN
            BEGIN
                SELECT
                    active_status
                    INTO var_active_status
                    FROM (SELECT
                        active_status, hospital_code, ward_code, bed_no) AS ungrouped_query
                    INNER JOIN (SELECT
                        hospital_code, ward_code, bed_no, MAX(effective_datetime) AS max_1
                        FROM bed_history
                        WHERE ward_code = par_T_NS_CODE::VARCHAR AND hospital_code = var_hosp_code::VARCHAR AND bed_no = par_T_BED_NO::VARCHAR AND effective_datetime <= timestamp_convert(localtimestamp)
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

        IF coalesce(var_status, ' ') != var_vacant_bed_status THEN
            BEGIN
                /* raiserror 102005 "Bed not vacant" */
                /* return 102005 */
                RAISE EXCEPTION 'Bed not vacant' USING ERRCODE := '40002';
                pas_return_code := 40002;
                RETURN;
            END;
        END IF;

        IF par_ISO_STATUS IS NOT NULL THEN
            BEGIN
                CALL cms_dt_check_iso_bed(var_return_code,var_hosp_code, var_ward_code, par_T_BED_NO, par_T_DATETIME);

                IF var_return_code != 1 THEN
                    BEGIN
                        SELECT
                            CONCAT('Isolation status cannot be updated as assigned bed: ', par_T_BED_NO, ' is not isolation bed!')
                            INTO var_message;
                        RAISE EXCEPTION '%', var_message USING ERRCODE := '40005';
                        pas_return_code := 40005;
                        RETURN;
                    END;
                END IF;
                /*
                if @bed_service = 'I' and @ISO_STATUS = '1'
                begin
                	rollback transaction
                	select @message = "The assigned bed: "+@T_BED_NO+" does not support Air-borne Infection Isolation service!"
                	raiserror 40007 @message
                	return 40007
                end
                */
            END;
        END IF;
        SELECT
            var_case_movement_count + 1
            INTO var_case_movement_count;
        CALL hasp_insert_transaction_log(var_return_code,var_hosp_code, var_system_datetime, par_T_CASE_NO, par_T_NS_CODE, var_treatment_location, var_ward_class, par_T_BED_NO, var_specialty_code, NULL, NULL, NULL, NULL, NULL, par_T_DATETIME, var_transaction_type, NULL, par_T_USER_ID, NULL, NULL);

        IF var_return_code != 0 THEN
            BEGIN
                pas_return_code := var_return_code;
                RETURN;
            END;
        END IF;
        CALL hasp_insert_event_log(var_return_code,var_hosp_code, var_system_datetime, var_transaction_type, var_hkid, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_T_CASE_NO, var_admission_datetime, var_source_indicator, var_source_code, var_pay_code, var_discharge_code, par_T_DATETIME, var_destination_code, var_case_type, var_case_movement_count, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_T_NS_CODE, var_specialty_code, par_T_BED_NO, var_ward_class, NULL, NULL, NULL, NULL, var_ward_class, par_T_NS_CODE, var_specialty_code, NULL, par_T_USER_ID, NULL, var_old_doctor_code, NULL, NULL);

        IF var_return_code != 0 THEN
            BEGIN
                pas_return_code := var_return_code;
                RETURN;
            END;
        END IF;
        CALL cpi_transfer(var_return_code,var_hosp_code, par_T_CASE_NO, var_hkid, par_T_NS_CODE, var_ward_class, NULL, var_specialty_code, var_old_doctor_code, par_T_NS_CODE, var_ward_class, par_T_BED_NO, var_specialty_code, NULL, var_treatment_location, par_T_DATETIME, var_case_type, var_transaction_type, var_system_datetime, par_T_USER_ID, 'LRRDT',
        /* CR31244 Add isolation status */
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
                                WHEN '' THEN ' '
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


;ALTER PROCEDURE "hasp_bed_assignment" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
