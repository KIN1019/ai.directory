CREATE OR REPLACE PROCEDURE mrts_poll_uid(INOUT pas_return_code int, IN par_input_record_count INTEGER, IN par_last_update_dtm TIMESTAMP WITHOUT TIME ZONE, INOUT p_refcur refcursor)
AS 
$BODY$
BEGIN
	    
    DROP TABLE IF EXISTS t$tmp_uid_table;
	DROP TABLE IF EXISTS t$tmp_uid_table_dup;
    IF par_input_record_count < 1 THEN
        BEGIN
            pas_return_code := 1;
            RETURN;
        END;
    END IF;
    CREATE TEMPORARY TABLE t$tmp_uid_table
    (update_dtm TIMESTAMP WITHOUT TIME ZONE);
    CREATE TEMPORARY TABLE t$tmp_uid_table_dup
    (update_dtm TIMESTAMP WITHOUT TIME ZONE);
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @input_record_count clause of SET statement is not supported. Perform a manual conversion.]
    set rowcount @input_record_count
    */
    INSERT INTO t$tmp_uid_table_dup
    SELECT
        update_dtm
        FROM hkpmi_uid_table
        WHERE update_dtm > par_last_update_dtm
        ORDER BY update_dtm ASC NULLS FIRST;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
    set rowcount 0
    */
    INSERT INTO t$tmp_uid_table
    SELECT DISTINCT
        update_dtm
        FROM t$tmp_uid_table_dup;
    OPEN p_refcur FOR
    SELECT
        h.uid_hkid, h.link_hkid, h.link_status, h.create_dtm, h.create_hospital, h.create_user, h.create_system, h.update_dtm, h.update_hospital, h.update_user, h.update_system
        FROM hkpmi_uid_table AS h, t$tmp_uid_table AS t
        WHERE h.update_dtm = t.update_dtm;
    /* --drop table #tmp_uid_table */
    /* --drop table #tmp_uid_table_dup */
    pas_return_code := 0;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;

;ALTER PROCEDURE "mrts_poll_uid" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";