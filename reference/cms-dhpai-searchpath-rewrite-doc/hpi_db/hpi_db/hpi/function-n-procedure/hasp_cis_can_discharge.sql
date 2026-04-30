-- DROP PROCEDURE hpi.hasp_cis_can_discharge(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_cis_can_discharge(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_t_case_no character varying, IN par_t_ns_code character varying, IN par_t_user_id character varying, IN par_t_case_timestamp timestamp without time zone, IN par_trans_type character varying)
 LANGUAGE plpgsql
AS $procedure$
    /* -- add hospital code as input parm by WL on 28 Jul 99 -- */

/* ----------------------------------------------------------------- */

/* This store procedure is developed base on the LRR/DT version */

/* Date                : 14th March, 1996 */

/* Project             : IPAS/ADT v2.0 */

/* Server              : Sybase 10.0.2 */

/* O.S.                : AIX 3.2.5 */

/* Function            : To perform cancellation of discharge */

/* AIX file name       : sp_co_cd.sql */

/* Call from           : hasp_cancel_discharge   -I (Trans.type) */

/* : hasp_ae_cancel_discharge-AE(Trans.type) */

/* ----------------------------------------------------------------- */

/*¡¡
Return values   Meaning
0				Normal
1				ADT_Case not found
2				Movement not found
3				Bed not found
4				Ward list not found
6				Delete Movement error
7				Update ADT_Case error
8				Update Bed error
*/
DECLARE
    var_error                    INTEGER;
    var_rowcount                 INTEGER;
    var_return_code              INTEGER;
    var_ward_code                VARCHAR(4);
    var_bed_no                   VARCHAR(5);
    var_current_bed_no           VARCHAR(5);
    var_specialty_code           VARCHAR(4);
    var_ward_class               VARCHAR(1);
    var_movement_type            VARCHAR(1);
    var_movement_datetime        TIMESTAMP WITHOUT TIME ZONE;
    var_treatment_location       VARCHAR(4);
    var_system_datetime          TIMESTAMP WITHOUT TIME ZONE;
    var_old_doctor_code          VARCHAR(08);
    var_case_movement_count      INTEGER;
    var_admission_datetime       TIMESTAMP WITHOUT TIME ZONE;
    var_source_indicator         VARCHAR(1);
    var_source_code              VARCHAR(3);
    var_hkid                     VARCHAR(12);
    var_district_code            VARCHAR(5);
    var_pay_code                 VARCHAR(3);
    var_discharge_code           VARCHAR(1);
    var_discharge_datetime       TIMESTAMP WITHOUT TIME ZONE;
    var_destination_code         VARCHAR(3);
    var_case_type                VARCHAR(1);
    var_case_timestamp           TIMESTAMP WITHOUT TIME ZONE;
    var_case_system_datetime     TIMESTAMP WITHOUT TIME ZONE;
    var_movement_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_status                   VARCHAR(1);
    var_bed_timestamp            VARCHAR(8000);
    var_ward_list_timestamp      VARCHAR(8000);
    var_tx_cancel_discharge      VARCHAR(3);
    var_occupied_bed_status      VARCHAR(1);
    var_vacant_bed_status        VARCHAR(1);
    sql$rowcount                 BIGINT;
BEGIN
    /* declare variables */
    /* -- remark by WL on 28 Jul 99 -- */

    /* --declare @hospital_code          VARCHAR(03) */
    SELECT 'O'
    INTO var_occupied_bed_status;
    SELECT 'V'
    INTO var_vacant_bed_status;
    /* --begin transaction */
    SELECT timestamp_convert(localtimestamp)
    INTO var_system_datetime;
    /* validation start here */
    /* --add hosp code by WL on 28 Jul 99-- */
    SELECT a.row_update_datetime,
           a.Movement_count,
           a.Admission_datetime,
           a.Source_indicator,
           a.Source_code,
           b.HKID,
           a.District_code,
           a.Pay_code,
           a.Discharge_code,
           a.Discharge_datetime,
           a.Destination_code,
           a.Case_type,
           a.System_datetime
    INTO var_case_timestamp, var_case_movement_count, var_admission_datetime,
        var_source_indicator, var_source_code, var_hkid,
        var_district_code, var_pay_code, var_discharge_code,
        var_discharge_datetime, var_destination_code, var_case_type,
        var_case_system_datetime
    FROM ADT_Case AS a,
         PMI_wo_MRN AS b
    WHERE a.Case_no = par_T_CASE_NO
      AND a.Hospital_code = par_hospital_code
      AND a.T_PRK = b.T_PRK;
    /*
    select @error = @@error
    if @error != 0
    */
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
    /* check In-patient ADT_Case */
    /* --- add hospital code by WL on 28 Jul 99 -- */
    /*
    select @error = @@error
            if @error != 0
                    begin
    --                        rollback transaction
                            return @error
                    end
    */
    /* --- add hosp code by WL on 28 Jul 99 -- */
    /*
    select @error = @@error
            if @error != 0
                    begin
    --                        rollback transaction
                            return @error
                    end
    */

    /* check timestamp */

    /* check ward code */

    /* check movement type */

    /* check bed status */

    /* update death indicator for death case */
    /*
    if @discharge_code = '1'
     	begin
      		update PMI
       		set Death_indicator = 'N',
        		Death_date = null,
    			System_datetime = @system_datetime,
    			User_ID = @T_USER_ID
       	 where HKID = @hkid
    	end
        select @error = @@error
        if @error != 0
        begin
    --       rollback transaction
           return @error
        end
    */
    /* ------- Begin remove local update by WL on 28 Jul 99 for HPI -- */
    /*
    /* delete Movement */
            delete  Movement
            where   Case_no = @T_CASE_NO
            and     Movement_count = @case_movement_count
    
    /*
            select @error = @@error
            if @error != 0
                    begin
    --                        rollback transaction
                            return @error
                    end
    */
            select @rowcount = @@rowcount
            if @rowcount = 0
            begin
                  return 6
            end
            select @case_movement_count = @case_movement_count - 1
    
    
    /* update ADT_Case */
    /* In order to get the last discharge information,
       only Discharge_code will be set to null.
    
            update  ADT_Case
            set     Movement_count = @case_movement_count,
    		Discharge_code = null,
    		Discharge_datetime = null,
    		Destination_code = null,
    		System_datetime = @system_datetime,
    		User_ID = @T_USER_ID
            where   Case_no = @T_CASE_NO
            and     timestamp = @case_timestamp
    */
            update  ADT_Case
            set     Movement_count = @case_movement_count,
    						Discharge_code = null,
    						Discharge_datetime = null,
    						Destination_code = null,
    						Active_indicator = 'Y',
    						System_datetime = @system_datetime,
    						User_ID = @T_USER_ID
            where   Case_no = @T_CASE_NO
            and     timestamp = @case_timestamp
    
            select @error = @@error, @rowcount = @@rowcount
            if @error != 0
                    begin
    --                        rollback transaction
                            return @error
                    end
    --        select @rowcount = @@rowcount
            if @rowcount = 0
            begin
                return 7
            end
    
    /* insert Ward_list */
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
    --                        rollback transaction
                            return @error
                    end
    
    /* Update Bed */
    if @bed_no != null
    begin
    	update	Bed
    	set 	Status = @occupied_bed_status
    	where	Ward_code = @T_NS_CODE
    	and	Bed_no	= @bed_no
    	select @error = @@error, @rowcount = @@rowcount
    	if @error != 0
    	begin
    --		rollback transaction
    		return @error
    	end
    --   select @rowcount = @@rowcount
       if @rowcount = 0
       begin
          return 8
       end
    
    end
    
    /* Delete Diagnosis */
    
    /* delete Diagnosis
       where Case_no = @T_CASE_NO
    */
    */
    /* --- end remark by WL on 28 Jul 99 to remove local update -- */

    /* Insert Transaction_log */

    /* add hospital code for HPI by ML on 22.09.1999 */

    /* Insert Event_log */
    /* mrt_indicator by Winnie on 19 FEB 1998 * */

    /* Cancel CPI discharge */
    /* --- remarked by WL on 28 Jul 99 --- */

    /*
    select @hospital_code = Hospital_code
    from Hospital
    if @@rowcount != 1
    begin
       return 102052
    end
    */
    /* --- remove cpi.. by WL on 28 Jul 99 for HPI-- */

    /* --execute @pas_return_code = cpi..cpi_cancel_discharge */
    /* commit transaction */
    <<restart>>
    BEGIN
        var_rowcount := sql$rowcount;

        IF var_rowcount = 0 THEN
            BEGIN
                /* rollback transaction */
                pas_return_code := 1;
                RETURN;
            END;
        END IF;

        IF par_Trans_type = 'I' THEN
            BEGIN
                IF var_case_type != 'I' THEN
                    BEGIN
                        /* --				rollback transaction */
                        /* --				raiserror 102051 This is not an in-patient Case number!  */
                        pas_return_code := 102051;
                        RETURN;
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                IF var_case_type != 'A' THEN
                    BEGIN
                        /* rollback transaction */
                        /* raiserror 102051 This is not A&E Case number!  */
                        pas_return_code := 102051;
                        RETURN;
                    END;
                END IF;
            END;
        END IF;

        IF par_Trans_type = 'I' THEN
            SELECT CONCAT('21', var_discharge_code)
            INTO var_tx_cancel_discharge;
        ELSE
            SELECT CONCAT('35', var_discharge_code)
            INTO var_tx_cancel_discharge;
        END IF;
        SELECT Ward_code,
               Specialty_code,
               Bed_no,
               Ward_class,
               Movement_type,
               Movement_datetime,
               Treatment_location,
               Movement.System_datetime,
               Movement.Doctor_code
        INTO var_ward_code, var_specialty_code, var_bed_no, var_ward_class, var_movement_type, var_movement_datetime, var_treatment_location, var_movement_system_datetime, var_old_doctor_code
        FROM Movement,
             ADT_Case
        WHERE ADT_Case.Movement_count = Movement.Movement_count
          AND ADT_Case.Hospital_code = par_hospital_code
          AND ADT_Case.Case_no = Movement.Case_no
          AND Movement.Hospital_code = par_hospital_code
          AND ADT_Case.Case_no = par_T_CASE_NO;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF var_rowcount = 0 THEN
            BEGIN
                /* rollback transaction */
                pas_return_code := 2;
                RETURN;
            END;
        END IF;

        IF var_bed_no != NULL THEN
            BEGIN
                /* --- add hospital code by WL on 28 Jul 99 --- */
                SELECT Status,
                       row_update_datetime
                INTO var_status, var_bed_timestamp
                FROM Bed
                WHERE Ward_code = par_T_NS_CODE
                  AND Bed_no = var_bed_no
                  AND Hospital_code = par_hospital_code;
                /*
                select @error = @@error
                             if @error != 0
                                begin
                --                        rollback transaction
                                        return @error
                                end
                */
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_rowcount = 0 THEN
                    BEGIN
                        /* rollback transaction */
                        pas_return_code := 3;
                        RETURN;
                    END;
                END IF;
            END;
        END IF;
        SELECT row_update_datetime
        INTO var_ward_list_timestamp
        FROM Ward_list
        WHERE Case_no = par_T_CASE_NO
          AND Hospital_code = par_hospital_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF var_rowcount != 0 THEN
            BEGIN
                /* rollback transaction */
                pas_return_code := 4;
                RETURN;
            END;
        END IF;

        IF var_case_system_datetime != par_T_CASE_timestamp THEN
            BEGIN
                /* rollback transaction */
                /* raiserror 102051 Case record has been modified by other user! */
                pas_return_code := 102051;
                RETURN;
            END;
        END IF;

        IF var_ward_code != par_T_NS_CODE THEN
            BEGIN
                /* rollback transaction */
                /* raiserror 102053 Patient not in this ward! */
                pas_return_code := 102053;
                RETURN;
            END;
        END IF;

        IF var_movement_type != 'D' THEN
            BEGIN
                /* rollback transaction */
                /* raiserror 102052 Last transaction is not a discharge! */
                pas_return_code := 102052;
                RETURN;
            END;
        END IF;

        IF var_bed_no IS NOT NULL THEN
            BEGIN
                IF var_status != var_vacant_bed_status THEN
                    BEGIN
                        /* --				rollback transaction */
                        /* --				raiserror 102054 Original bed is occupied */
                        pas_return_code := 102052;
                        RETURN;
                    END;
                END IF;
            END;
        END IF;
        SELECT var_case_movement_count - 1
        INTO var_case_movement_count;
        CALL hasp_insert_transaction_log(var_return_code, par_hospital_code, var_system_datetime, par_T_CASE_NO,
                                         par_T_NS_CODE, var_treatment_location, var_ward_class, var_bed_no,
                                         var_specialty_code, NULL, NULL, NULL, NULL, NULL, var_movement_datetime,
                                         var_tx_cancel_discharge, NULL, par_T_USER_ID, NULL,
                                         var_movement_system_datetime);

        IF var_return_code != 0 THEN
            BEGIN
                /* rollback transaction */
                pas_return_code := var_return_code;
                RETURN;
            END;
        END IF;
        CALL hasp_insert_event_log(var_return_code, par_hospital_code, var_system_datetime, var_tx_cancel_discharge,
                                   var_hkid, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, par_T_CASE_NO, var_admission_datetime, var_source_indicator, var_source_code,
                                   var_pay_code, NULL, NULL, NULL, var_case_type, var_case_movement_count, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_T_NS_CODE, var_specialty_code,
                                   var_bed_no, var_ward_class, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   par_T_USER_ID, NULL, var_old_doctor_code, NULL, NULL);

        IF var_return_code != 0 THEN
            BEGIN
                /* rollback transaction */
                pas_return_code := var_return_code;
                RETURN;
            END;
        END IF;
        CALL cpi_cancel_discharge(var_return_code, par_hospital_code, par_T_CASE_NO, var_hkid, var_ward_code,
                                  var_ward_class, var_bed_no, var_specialty_code, NULL, /* sub_specialty */
                                  NULL, /* doctor_code */ var_case_type, var_tx_cancel_discharge, var_system_datetime,
                                  par_T_USER_ID, 'ADT');

        IF var_return_code != 0 THEN
            BEGIN
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


;ALTER PROCEDURE "hasp_cis_can_discharge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
