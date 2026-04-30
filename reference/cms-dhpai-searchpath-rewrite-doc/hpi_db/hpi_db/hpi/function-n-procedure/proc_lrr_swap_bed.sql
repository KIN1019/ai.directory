-- DROP PROCEDURE hpi.proc_lrr_swap_bed(inout int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.proc_lrr_swap_bed(INOUT pas_return_code integer, IN var_hosp_code character varying, IN par_t_datetime timestamp without time zone, IN par_t_case_no_a character varying, IN par_t_case_no_b character varying, IN par_t_ns_code_a character varying, IN par_t_ns_code_b character varying, IN par_t_spec_a character varying, IN par_t_spec_b character varying, IN par_t_class_a character varying, IN par_t_class_b character varying, IN par_t_bed_a character varying, IN par_t_bed_b character varying, IN par_t_case_timestamp_a timestamp without time zone, IN par_t_case_timestamp_b timestamp without time zone, IN par_t_user_id character varying, IN par_iso_status_a character varying DEFAULT NULL::character varying, IN par_iso_status_b character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* ******************************************************************************************************* */
/* History : 20160426 - CR31244 Add isolation_status to capture patient isolation status by Yorky LEUNG */
/* ******************************************************************************************************* */
DECLARE
    var_error INTEGER;
    var_return_code INTEGER;
    var_rowcount INTEGER;
    var_T_DOCTOR VARCHAR(8);
    var_T_TO_BED_NO VARCHAR(5);
begin
	
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
    SELECT
        NULL
        INTO var_T_DOCTOR;
    /* (1) transfer patient A to temp bed */
    SELECT
        NULL
        INTO var_T_TO_BED_NO;
         /*set timestamp sss*/
    select to_char(par_T_CASE_timestamp_A, 'YYYY-MM-DD HH24:MI:SS.MS') into par_T_CASE_timestamp_A;
    select to_char(par_T_CASE_timestamp_B, 'YYYY-MM-DD HH24:MI:SS.MS') into par_T_CASE_timestamp_B;
   
    CALL hasp_transfer(var_return_code,var_hosp_code, par_T_DATETIME, par_T_CASE_NO_A, par_T_NS_CODE_A, par_T_SPEC_A, par_T_CLASS_A, var_T_TO_BED_NO, par_T_NS_CODE_A, var_T_DOCTOR, par_T_USER_ID, par_T_CASE_timestamp_A, par_iso_status_a);

    IF var_return_code != 0 THEN
        BEGIN
           -- ROLLBACK;
            RAISE EXCEPTION 'Swap Bed record update error!' USING ERRCODE := var_return_code;
            pas_return_code := var_return_code;
            RETURN;
        END;
    END IF;
    PERFORM pg_sleep(0.1);

    /* (2) transfer patient B to temp bed */
    SELECT
        NULL
        INTO var_T_TO_BED_NO;
    CALL hasp_transfer(var_return_code, var_hosp_code, par_T_DATETIME, par_T_CASE_NO_B, par_T_NS_CODE_B, par_T_SPEC_B, par_T_CLASS_B, var_T_TO_BED_NO, par_T_NS_CODE_B, var_T_DOCTOR, par_T_USER_ID, par_T_CASE_timestamp_B,par_iso_status_b);


    IF var_return_code != 0 THEN
        BEGIN
            --ROLLBACK;
            RAISE EXCEPTION 'Swap Bed record update error!' USING ERRCODE := var_return_code;
            pas_return_code := var_return_code;
            RETURN;
        END;
    END IF;
    /* (3) transfer patient A from temp BEd to original B  bed */
    SELECT
        par_T_BED_B
        INTO var_T_TO_BED_NO;

    BEGIN
        SELECT
            to_char(update_dtm, 'YYYY-MM-DD HH24:MI:SS.MS')
            INTO par_T_CASE_timestamp_A
            FROM cpi_case
            WHERE case_no = par_T_CASE_NO_A AND hospital_code = var_hosp_code;
        var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
    END;

    IF var_error != 0 THEN
        BEGIN
            --ROLLBACK;
            RAISE EXCEPTION ' Swap Bed Select Case error !' USING ERRCODE := var_error;
            pas_return_code := var_error;
            RETURN;
        END;
    END IF;
	
    CALL hasp_bed_assignment(var_return_code, var_hosp_code, par_T_DATETIME, par_T_CASE_NO_A, var_T_TO_BED_NO, par_T_NS_CODE_A, par_T_USER_ID, par_T_CASE_timestamp_A, par_ISO_STATUS_A);

    IF var_return_code != 0 THEN
        BEGIN
            --ROLLBACK;
            RAISE EXCEPTION 'Swap Bed record update error!' USING ERRCODE := var_return_code;
            pas_return_code := var_return_code;
            RETURN;
        END;
    END IF;
    /* (4) transfer patient B from temp bed to origal A bed */
    SELECT
        par_T_BED_A
        INTO var_T_TO_BED_NO;

    BEGIN
        SELECT
            to_char(update_dtm, 'YYYY-MM-DD HH24:MI:SS.MS')
            INTO par_T_CASE_timestamp_B
            FROM cpi_case
            WHERE case_no = par_T_CASE_NO_B AND hospital_code = var_hosp_code;
        var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
    END;

    IF var_error != 0 THEN
        BEGIN
            --ROLLBACK;
            RAISE EXCEPTION ' Swap Bed Select Case error !' USING ERRCODE := var_error;
            pas_return_code := var_error;
            RETURN;
        END;
    END IF;
 
    CALL hasp_bed_assignment(var_return_code, var_hosp_code, par_T_DATETIME, par_T_CASE_NO_B, var_T_TO_BED_NO, par_T_NS_CODE_B, par_T_USER_ID, par_T_CASE_timestamp_B, par_ISO_STATUS_B);

    IF var_return_code != 0 THEN
        BEGIN
            --ROLLBACK;
            RAISE EXCEPTION 'Swap Bed record update error!' USING ERRCODE := var_return_code;
            pas_return_code := var_return_code;
            RETURN;
        END;
    END IF;
--    COMMIT;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "proc_lrr_swap_bed" OWNER TO "HPI_SCHEMA_OWNER_ROLE";