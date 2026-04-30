-- DROP PROCEDURE hpi.proc_lrr_modi_discharge(inout int4, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.proc_lrr_modi_discharge(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_t_case_no character varying, IN par_t_user_id character varying, IN par_t_case_timestamp timestamp without time zone, IN par_t_prev_ns_code character varying, IN par_t_prev_bed_no character varying, IN par_t_datetime timestamp without time zone, IN par_t_discharge_code character varying, IN par_t_destination character varying, IN par_t_remark character varying, IN par_t_doctor character varying, IN par_t_mrt_indicator character varying, IN par_t_deathdtm timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/* kar9 Dec 99 */DECLARE
    var_error INTEGER;
    var_return_code INTEGER;
    var_rowcount INTEGER;
    var_prev_bed_status VARCHAR(2);
    var_need_to_restore INTEGER;
    var_temp_case_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_bed_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_occupied_bed_status VARCHAR(2);
    var_vacant_bed_status VARCHAR(2);
BEGIN
    SELECT
        'O'
        INTO var_occupied_bed_status;
    SELECT
        'V'
        INTO var_vacant_bed_status;
    /*
    [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
    begin transaction
    */
       
	-- CP2 & Harmonycloud on Jan-2025:
	-- Since the ownership of cmslrr_db and the migration approach are to be confirmed with other CMS teams (E.g. Related SPs may be changed to APIs),
	-- the following logic about cmslrr_db was not migrated to PG in this moment and was commented in PG DDL with this remark for record.
   	/*
    IF var_return_code != 0 THEN
        pas_return_code := var_return_code;
        RETURN;
    END IF;
    */
       
    SELECT
        0
        INTO var_need_to_restore;

    IF (par_T_PREV_BED_NO is not NULL) THEN
        BEGIN
            BEGIN
                SELECT
                    Status, row_update_datetime
                    INTO var_prev_bed_status, var_bed_timestamp
                    FROM Bed
                    WHERE Hospital_code = par_hosp_code AND Ward_code = par_T_PREV_NS_CODE AND Bed_no = par_T_PREV_BED_NO;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;

            IF var_error != 0 THEN
                BEGIN
                    pas_return_code := var_error;
                END;
            END IF;

            IF (var_prev_bed_status = var_occupied_bed_status) THEN
                BEGIN
                    SELECT
                        1
                        INTO var_need_to_restore;

                    BEGIN
                        UPDATE Bed
                        SET Status = var_vacant_bed_status
                            WHERE Hospital_code = par_hosp_code AND Ward_code = par_T_PREV_NS_CODE AND Bed_no = par_T_PREV_BED_NO;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    END;

                    IF var_error != 0 THEN
                        BEGIN
                            RAISE EXCEPTION '';
                            pas_return_code := var_error;
                            RETURN;
                        END;
                    END IF;
                    BEGIN
                        EXCEPTION
                            WHEN OTHERS THEN
                                pas_return_code := var_error;
                        RETURN;
                    END;
                END;
            END IF;
        END;
    END IF;
    /* (1) cancellation of discharge */
    CALL hasp_cancel_discharge(var_return_code, par_hosp_code, par_T_CASE_NO, par_T_PREV_NS_CODE, par_T_USER_ID, par_T_CASE_timestamp);

    IF var_return_code != 0 THEN
        BEGIN
            RAISE EXCEPTION 'Modification of Discharge update error!' USING ERRCODE := var_return_code;
            pas_return_code := var_return_code;
            RETURN;
        END;
    END IF;

    BEGIN
        SELECT
            update_dtm
            INTO var_temp_case_timestamp
            FROM cpi_case
            WHERE case_no = par_T_CASE_NO AND hospital_code = par_hosp_code;
        var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
    END;

    IF var_error != 0 THEN
        BEGIN
            RAISE EXCEPTION ' Modification of Discharge Select Case error !' USING ERRCODE := var_error;
            pas_return_code := var_error;
            RETURN;
        END;
    END IF;
    /* (2) discharge */
    CALL hasp_discharge(var_return_code, par_hosp_code, par_T_DATETIME, par_T_CASE_NO, par_T_DISCHARGE_CODE, par_T_DESTINATION, par_T_REMARK, par_T_PREV_NS_CODE, par_T_DOCTOR, par_T_USER_ID, var_temp_case_timestamp, par_T_MRT_INDICATOR, par_T_DEATHDTM);

    IF var_return_code != 0 THEN
        BEGIN
            RAISE EXCEPTION 'Modification of Discharge update error!' USING ERRCODE := var_return_code;
            pas_return_code := var_return_code;
            RETURN;
        END;
    END IF;

    IF (var_need_to_restore = 1) THEN
        BEGIN
            BEGIN
                UPDATE Bed
                SET Status = var_prev_bed_status
                    WHERE Hospital_code = par_hosp_code AND Ward_code = par_T_PREV_NS_CODE AND Bed_no = par_T_PREV_BED_NO;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;

            IF var_error != 0 THEN
                BEGIN
                    RAISE EXCEPTION '';
                    
                    RETURN;
                END;
            END IF;
            BEGIN
                EXCEPTION
                    WHEN OTHERS THEN
                        pas_return_code := var_error;
                RETURN;
            END;
        END;
    END IF;

    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "proc_lrr_modi_discharge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
