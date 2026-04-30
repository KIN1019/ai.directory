-- DROP PROCEDURE hpi.proc_lrr_last_aehn_case(inout int4, in varchar, inout varchar, inout varchar, inout timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.proc_lrr_last_aehn_case(INOUT pas_return_code integer, IN par_in_case_hkid character varying, INOUT par_out_case_no character varying, INOUT par_out_case_hkid character varying, INOUT par_out_case_datetime timestamp without time zone, INOUT p_refcur refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rowcount INTEGER;
    var_error_msg VARCHAR(80);
    var_error INTEGER;
    var_hosp_code VARCHAR(03);
    var_return_code INTEGER;
    var_case_type VARCHAR(01);
    var_movement_count INTEGER;
    var_case_no VARCHAR(12);
    var_hkid VARCHAR(12);
    var_admission_dtm TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
   -- CP2 & Harmonycloud on Jan-2025:
	-- Since the ownership of cmslrr_db and the migration approach are to be confirmed with other CMS teams (E.g. Related SPs may be changed to APIs),
	-- the following logic about cmslrr_db was not migrated to PG in this moment and was commented in PG DDL with this remark for record.
	/*
    CALL proc_lrr_get_hosp_map(var_return_code, var_hosp_code);

    IF var_return_code != 0 THEN
        OPEN p_refcur FOR
        select var_return_code;
        RETURN NEXT p_refcur;
        RETURN;
    END IF;
    */
	       DROP TABLE IF EXISTS t$temp_table;
    CREATE TEMPORARY TABLE t$temp_table
    AS
    SELECT
        c2.case_type, c2.movement_count, c2.case_no, p2.hkid, c2.admission_dtm
        FROM cpi_patient AS p2, cpi_case AS c2
        WHERE c2.hospital_code = var_hosp_code AND p2.hkid = par_in_case_hkid AND c2.patient_key = p2.patient_key AND c2.case_type <> 'O' AND c2.status_code = 'AC';
    SELECT
        MAX(admission_dtm)
        INTO var_admission_dtm
        FROM t$temp_table;

    BEGIN
        SELECT
            case_no, hkid, admission_dtm
            INTO par_out_case_no, par_out_case_hkid, par_out_case_datetime
            FROM t$temp_table
            WHERE admission_dtm = var_admission_dtm;
        var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
    END;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
    var_rowcount := sql$rowcount;

    IF var_error != 0 THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                NULL, NULL, NULL;
            pas_return_code := var_error;
            RETURN;
        END;
    END IF;

    IF var_rowcount = 0 THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                NULL, NULL, NULL;
            pas_return_code := 100;
            RETURN;
        END;
    ELSE
        BEGIN
            OPEN p_refcur FOR
            SELECT
                par_out_case_no, par_out_case_hkid, par_out_case_datetime;
            pas_return_code := 0;
            RETURN;




        END;
    END IF;
END;
$procedure$
;

;ALTER PROCEDURE "proc_lrr_last_aehn_case" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
