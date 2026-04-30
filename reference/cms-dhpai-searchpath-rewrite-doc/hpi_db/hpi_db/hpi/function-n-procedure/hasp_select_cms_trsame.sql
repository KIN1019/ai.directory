-- DROP FUNCTION hpi.hasp_select_cms_trsame(varchar, timestamp, timestamp, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_select_cms_trsame(par_hosp_code character varying, par_trans_sys_fdatetime timestamp without time zone, par_trans_sys_tdatetime timestamp without time zone, par_trans_ns_code character varying)
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
        transaction_log.system_datetime, dt_transaction_type.dt_code
        FROM hpi.transaction_log, hpi.dt_transaction_type
        WHERE (transaction_log.hospital_code = par_hosp_code) AND (transaction_log.system_datetime >= par_TRANS_SYS_FDATETIME) AND (transaction_log.system_datetime <= par_TRANS_SYS_TDATETIME) AND (Transaction_log.From_ward_code LIKE par_TRANS_NS_CODE AND transaction_log.from_ward_code = transaction_log.to_ward_code AND transaction_log.transaction_type IN ('140', '220')) AND (transaction_log.transaction_type = dt_transaction_type.adt_code);
    
    RETURN NEXT p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_select_cms_trsame" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
