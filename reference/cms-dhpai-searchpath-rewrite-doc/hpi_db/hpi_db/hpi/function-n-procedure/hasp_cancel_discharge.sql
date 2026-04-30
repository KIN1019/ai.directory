-- DROP PROCEDURE hpi.hasp_cancel_discharge(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.hasp_cancel_discharge(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_t_case_no character varying, IN par_t_ns_code character varying, IN par_t_user_id character varying, IN par_t_case_timestamp timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/* -------------------------------------------------------------- */
/* This store procedure is developed base on the LRR/DT version */
/* Date                : 22th June, 1995 */
/* Project             : IPAS/ADT v2.0 */
/* Server              : Sybase 10.0.2 */
/* O.S.                : AIX 3.2.5 */
/* Function            : To perform cancellation of discharge */
/* AIX file name       : sp_cd.sql */
/* -------------------------------------------------------------- */
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_return_code INTEGER;
    var_ward_code VARCHAR(8);
    var_bed_no VARCHAR(10);
    var_current_bed_no VARCHAR(10);
    var_specialty_code VARCHAR(8);
    var_ward_class VARCHAR(2);
    var_movement_type VARCHAR(2);
    var_movement_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_treatment_location VARCHAR(8);
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_old_doctor_code VARCHAR(16);
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
    var_case_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_case_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_movement_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_current_movement_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_current_ward_code VARCHAR(8);
    var_current_specialty_code VARCHAR(8);
    var_current_ward_class VARCHAR(2);
    var_current_doctor_code VARCHAR(10);
    var_message VARCHAR(160);
    var_status VARCHAR(2);
    var_bed_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_ward_list_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_tx_cancel_discharge VARCHAR(6);
    var_occupied_bed_status VARCHAR(2);
    var_vacant_bed_status VARCHAR(2);
    sql$rowcount BIGINT;
BEGIN
    /* declare variables */
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
    IF var_return_code != 0 THEN
        pas_return_code := var_return_code;
        RETURN;
    END IF;
    */

    /* validation start here */
    /* check In-patient Case */
    /* check timestamp */
    /* check ward code */
    /* check movement type */
    /* check bed status */
    /* delete Movement */
    /*
    delete  Movement
    where   Case_no = @T_CASE_NO
    and     Movement_count = @case_movement_count
    
    select @error = @@error
    if @error != 0
            begin
                    rollback transaction
                    return @error
            end
    */
    /* update Case */
    /*
    In order to get the last discharge information,
       only Discharge_code will be set to null.
            update  Case_view
            set     Movement_count = @case_movement_count,
    		Discharge_code = null,
    		Discharge_datetime = null,
    		Destination_code = null,
    		System_datetime = @system_datetime,
    		User_ID = @T_USER_ID
            where   Case_no = @T_CASE_NO
            and     timestamp = @case_timestamp
    */
    /*
    update  Case_view
            set     Movement_count = @case_movement_count,
    						Discharge_code = null,
    						Active_indicator = 'Y',
    						System_datetime = @system_datetime,
    						User_ID = @T_USER_ID
            where   Case_no = @T_CASE_NO
            and     timestamp = @case_timestamp
    
            select @error = @@error
            if @error != 0
                    begin
                            rollback transaction
                            return @error
                    end
    */
    /* insert Ward_list */
    /*
    insert Ward_list
    	(Case_no,
    	 Ward_code,
    	 Specialty_code,
    	 Bed_no
    	)
       values (@T_CASE_NO,
    	   @ward_code,
    	   @specialty_code,
    	   @bed_no
    	  )
    
            select @error = @@error
            if @error != 0
                    begin
                            rollback transaction
                            return @error
                    end
    */
    /* Update Bed */
    /*
    if @bed_no != null
    begin
    	update	Bed
    	set 	Status = @occupied_bed_status
    	where	Ward_code = @T_NS_CODE
    	and	Bed_no	= @bed_no
    	select @error = @@error
    	if @error != 0
    	begin
    		rollback transaction
    		return @error
    	end
    end
    */
    /* Delete Diagnosis */
    /*
    delete Diagnosis
    where Case_no = @T_CASE_NO
    */
    /* if cancel death, set the death indicator to 'N' */
    /* cpi version */
    /*
    if @discharge_code = '1' /* death */
    begin
    	update PMI
    	set Death_indicator = 'N'
    	where HKID = @hkid
    end
    */
    /* Insert Transaction_log */
    /* Insert Event_log */ /* mrt indicator */
    <<restart>>
    BEGIN
 
        SELECT
            clock_timestamp()
            INTO var_system_datetime;

        BEGIN
            SELECT
                Case_view.row_update_datetime, Case_view.Movement_count, Admission_datetime,  Case_view.Source_indicator,  Case_view.Source_code, HKID,  Case_view.District_code, Pay_code,  Case_view.Discharge_code, Discharge_datetime,  Case_view.Destination_code,  Case_view.Case_type, update_dtm
                INTO var_case_timestamp, var_case_movement_count, var_admission_datetime, var_source_indicator, var_source_code, var_hkid, var_district_code, var_pay_code, var_discharge_code, var_discharge_datetime, var_destination_code, var_case_type, var_case_system_datetime
                FROM Case_view, cpi_case AS c1
                WHERE Case_view.Case_no = par_T_CASE_NO AND Case_view.Hospital_code = par_hosp_code AND Case_view.Case_no = c1.case_no AND Case_view.Hospital_code = c1.hospital_code;
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
                /* raiserror 102051 This is not an in-patient Case number!  */
                /* return 102051 */
                RAISE EXCEPTION 'This is not an in-patient Case number! ' USING ERRCODE := '40003';
                pas_return_code := 40003;
                RETURN;
            END;
        END IF;
        SELECT
            CONCAT('21', var_discharge_code)
            INTO var_tx_cancel_discharge;

        BEGIN
            SELECT
                Ward_code, Specialty_code, Bed_no, Ward_class, Movement_type, Movement_datetime, Treatment_location, m.System_datetime, m.Doctor_code
                INTO var_ward_code, var_specialty_code, var_bed_no, var_ward_class, var_movement_type, var_movement_datetime, var_treatment_location, var_movement_system_datetime, var_old_doctor_code
                FROM Movement AS m, Case_view AS c
                WHERE m.Hospital_code = par_hosp_code AND m.Case_no = par_T_CASE_NO AND m.Hospital_code = c.Hospital_code AND m.Case_no = c.Case_no AND m.Movement_count = c.Movement_count;
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
                WHERE Hospital_code = par_hosp_code AND Ward_code = par_T_NS_CODE AND Bed_no = var_bed_no;
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
                /* raiserror 102051 Case record has been modified by other user! */
                /* return 102051 */
                RAISE EXCEPTION 'Case record has been modified by other user!' USING ERRCODE := '40004';
                pas_return_code := 40004;
                RETURN;
            END;
        END IF;

        IF var_ward_code != par_T_NS_CODE THEN
            BEGIN
                /* raiserror 102053 Patient not in this ward! */
                /* return 102053 */
                RAISE EXCEPTION 'Patient not in this ward!' USING ERRCODE := '40012';
                pas_return_code := 40012;
                RETURN;
            END;
        END IF;

        IF var_movement_type != 'D' THEN
            BEGIN
                /* raiserror 102052 Last transaction is not a discharge! */
                /* return 102052 */
                RAISE EXCEPTION 'Last transaction is not a discharge!' USING ERRCODE := '40008';
                pas_return_code := 40008;
                RETURN;
            END;
        END IF;

        IF var_bed_no is not NULL THEN
            BEGIN
                IF var_status != var_vacant_bed_status THEN
                    BEGIN
                        /* raiserror 102054 Original bed is occupied */
                        /* return 102052 */
                        RAISE EXCEPTION 'Original bed is occupied' USING ERRCODE := '40009';
                        pas_return_code := 40009;
                        RETURN;
                    END;
                END IF;
            END;
        END IF;
        SELECT
            var_case_movement_count - 1
            INTO var_case_movement_count;
        CALL hasp_insert_transaction_log(var_return_code, par_hosp_code, var_system_datetime, par_T_CASE_NO, par_T_NS_CODE, var_treatment_location, var_ward_class, var_bed_no, var_specialty_code, NULL, NULL, NULL, NULL, NULL, var_movement_datetime, var_tx_cancel_discharge, NULL, par_T_USER_ID, NULL, var_movement_system_datetime);

        IF var_return_code != 0 THEN
            BEGIN
                pas_return_code := var_return_code;
                RETURN;
            END;
        END IF;
        CALL hasp_insert_event_log(var_return_code, par_hosp_code, var_system_datetime, var_tx_cancel_discharge, var_hkid, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_T_CASE_NO, var_admission_datetime, var_source_indicator, var_source_code, var_pay_code, var_discharge_code, var_discharge_datetime, var_destination_code, var_case_type, var_case_movement_count, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_T_NS_CODE, var_specialty_code, var_bed_no, var_ward_class, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_T_USER_ID, NULL, var_old_doctor_code, NULL, NULL);

        IF var_return_code != 0 THEN
            BEGIN
                pas_return_code := var_return_code;
                RETURN;
            END;
        END IF;

        BEGIN
            SELECT
                Bed_no, Movement_datetime, Ward_code, Specialty_code, Ward_class, Doctor_code
                INTO var_current_bed_no, var_current_movement_datetime, var_current_ward_code, var_current_specialty_code, var_current_ward_class, var_current_doctor_code
                FROM Movement
                WHERE Hospital_code = par_hosp_code AND Case_no = par_T_CASE_NO AND Movement_count = var_case_movement_count;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF var_error != 0 THEN
            BEGIN
                pas_return_code := var_error;
                RETURN;
            END;
        END IF;

        IF var_rowcount != 1 THEN
            BEGIN
                SELECT
                    CONCAT('Movement not found ', par_T_CASE_NO)
                    INTO var_message;
                /* raiserror 102006 @message */
                /* return 102006 */
                RAISE EXCEPTION '%', var_message USING ERRCODE := '40022';
                pas_return_code := 40022;
                RETURN;
            END;
        END IF;
        CALL cpi_cancel_discharge(var_return_code, par_hosp_code, par_T_CASE_NO, var_hkid, var_current_ward_code, var_current_ward_class, var_current_bed_no, var_current_specialty_code, NULL, var_current_doctor_code, var_case_type, var_tx_cancel_discharge, var_system_datetime, par_T_USER_ID, 'LRRDT');

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

;ALTER PROCEDURE "hasp_cancel_discharge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";