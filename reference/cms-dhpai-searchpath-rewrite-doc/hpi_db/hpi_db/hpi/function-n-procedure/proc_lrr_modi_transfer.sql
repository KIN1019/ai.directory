-- DROP PROCEDURE hpi.proc_lrr_modi_transfer(inout int4, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.proc_lrr_modi_transfer(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_t_case_no character varying, IN par_t_user_id character varying, IN par_t_case_timestamp timestamp without time zone, IN par_t_prev_ns_code character varying, IN par_t_prev_bed_no character varying, IN par_t_curr_ns_code character varying, IN par_t_curr_bed_no character varying, IN par_t_datetime timestamp without time zone, IN par_t_to_ns_code character varying, IN par_t_to_specialty character varying, IN par_t_to_class character varying, IN par_t_to_bed_no character varying, IN par_t_doctor character varying, IN par_iso_status character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_error INTEGER;
    var_return_code INTEGER;
    var_rowcount INTEGER;
    var_prev_bed_status VARCHAR(2);
    var_need_to_restore INTEGER;
    var_temp_case_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_bed_timestamp VARCHAR(8000);
    var_occupied_bed_status VARCHAR(2);
    var_vacant_bed_status VARCHAR(2);
    var_err_msg text;
BEGIN
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
       
    SELECT
        0
        INTO var_need_to_restore;

    IF ((par_t_prev_ns_code != par_t_curr_ns_code) OR (COALESCE(par_t_prev_bed_no, 'aaa') != COALESCE(par_t_curr_bed_no, 'aaa'))) THEN
        BEGIN
            IF (par_t_prev_bed_no is not NULL) THEN
                BEGIN
                    BEGIN
                        SELECT
                            Status, row_update_datetime
                            INTO var_prev_bed_status, var_bed_timestamp
                            FROM Bed
                            WHERE Hospital_code = par_hosp_code AND Ward_code = par_t_prev_ns_code AND Bed_no = par_t_prev_bed_no;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    END;

                    IF var_error != 0 THEN
                        BEGIN
                            RAISE EXCEPTION '%', var_error;
                        END;
                    END IF;

                    IF (var_prev_bed_status = var_occupied_bed_status) THEN
                        BEGIN
                            IF ((par_t_prev_ns_code = par_t_to_ns_code) AND (COALESCE(par_t_prev_bed_no, 'aaa') = COALESCE(par_t_to_bed_no, 'bbb'))) THEN
                                BEGIN
                                    /* raiserror 102034 Original bed is occupied ! */
                                    /* return 102034 */
                                    pas_return_code := 40009;
                                    RAISE EXCEPTION 'Original bed is occupied !' USING ERRCODE := '40009';
                                    RETURN;
                                END;
                            END IF;
                            SELECT
                                1
                                INTO var_need_to_restore;

                            BEGIN
                                raise notice 'proc_lrr_modi_transfer=>update Bed Ward_code=%, Bed_no=%',par_t_prev_ns_code,par_t_prev_bed_no;
                                UPDATE Bed
                                SET Status = var_vacant_bed_status
                                    WHERE Hospital_code = par_hosp_code AND Ward_code = par_t_prev_ns_code AND Bed_no = par_t_prev_bed_no;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                            END;

                            IF var_error != 0 THEN
                                BEGIN
                                    RAISE EXCEPTION '%', var_error;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
        END;
    END IF;
    /* (1) cancellation of transfer */
    CALL hasp_cancel_transfer(var_return_code, par_hosp_code, par_t_case_no, par_t_prev_ns_code, par_t_user_id, par_t_case_timestamp);

    IF var_return_code != 0 THEN
        BEGIN
            pas_return_code := var_return_code;
            RAISE EXCEPTION 'Modification of Transfer update error!' USING ERRCODE := var_return_code;
            RETURN;
        END;
    END IF;

    BEGIN
        SELECT
            to_char(update_dtm, 'YYYY-MM-DD HH24:MI:SS.MS')::TIMESTAMP WITHOUT TIME ZONE
            INTO var_temp_case_timestamp
            FROM cpi_case
            WHERE case_no = par_t_case_no AND hospital_code = par_hosp_code;
        var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
    END;

    IF var_error != 0 THEN
        BEGIN
            RAISE EXCEPTION ' Modification of Transfer Select Case error !' USING ERRCODE := var_error;
            RETURN;
        END;
    END IF;
    /* CR16214 Yorky 09 Jul 2009 */
    /* (2) transfer */
    /* CR31244 Add isolation_status to capture patient isolation status by Yorky LEUNG */
   raise notice 'par_t_case_timestamp: %', var_temp_case_timestamp;
    CALL hasp_transfer(var_return_code, par_hosp_code,par_t_datetime, par_t_case_no, par_t_to_ns_code, par_t_to_specialty, par_t_to_class, par_t_to_bed_no, par_t_prev_ns_code, par_t_doctor, par_t_user_id, var_temp_case_timestamp, par_iso_status);

    IF var_return_code != 0 THEN
        BEGIN
            RAISE EXCEPTION 'Modification of Transfer update error!' USING ERRCODE := var_return_code;
            RETURN;
        END;
    END IF;

    IF (var_need_to_restore = 1) THEN
        BEGIN
            BEGIN
                UPDATE Bed
                SET Status = var_prev_bed_status
                    WHERE Hospital_code = par_hosp_code AND Ward_code = par_t_prev_ns_code AND Bed_no = par_t_prev_bed_no;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;

            IF var_error != 0 THEN
                BEGIN
                    RAISE EXCEPTION '%', var_error;
                END;
            END IF;
        END;
    END IF;
    BEGIN
        EXCEPTION
        WHEN others THEN
            BEGIN
                GET STACKED DIAGNOSTICS var_err_msg = MESSAGE_TEXT;
                raise notice 'web_app_amend error: %',var_err_msg;
                if var_err_msg = var_error THEN
                    pas_return_code := var_error;
                end if;
                RETURN;
            END;
    END;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "proc_lrr_modi_transfer" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
