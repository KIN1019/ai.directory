-- DROP FUNCTION hpi.hasp_select_cms_trout(varchar, timestamp, timestamp, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_select_cms_trout(par_hosp_code character varying, par_trans_sys_fdatetime timestamp without time zone, par_trans_sys_tdatetime timestamp without time zone, par_trans_ns_code character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_return_code INTEGER;
    p_refcur refcursor;
BEGIN

	-- CP2 & Harmonycloud on Jan-2025:
	-- Since the ownership of cmslrr_db and the migration approach are to be confirmed with other CMS teams (E.g. Related SPs may be changed to APIs),
	-- the following logic about cmslrr_db was not migrated to PG in this moment and was commented in PG DDL with this remark for record.
   	/*
    IF var_return_code != 0 THEN
        pas_return_code := var_return_code;
        RETURN;
    END IF;
    */
	
    OPEN p_refcur FOR
    SELECT
        Transaction_log.System_datetime, DT_transaction_type.DT_code
        FROM hpi.Transaction_log, hpi.DT_transaction_type
        WHERE (Transaction_log.Hospital_code = par_hosp_code) AND (Transaction_log.Transaction_type = DT_transaction_type.ADT_code) AND (Transaction_log.System_datetime >= par_TRANS_SYS_FDATETIME) AND (Transaction_log.System_datetime <= par_TRANS_SYS_TDATETIME) AND (Transaction_log.From_ward_code LIKE par_TRANS_NS_CODE AND Transaction_log.From_ward_code != Transaction_log.To_ward_code AND Transaction_log.Transaction_type IN ('140', '220'));
    RETURN NEXT p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_select_cms_trout" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
