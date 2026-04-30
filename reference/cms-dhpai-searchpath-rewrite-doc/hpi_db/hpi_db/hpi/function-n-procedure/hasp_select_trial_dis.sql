-- DROP FUNCTION hpi.hasp_select_trial_dis(timestamp, timestamp, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_select_trial_dis(par_hosp_code character varying, par_trans_sys_fdatetime timestamp without time zone, par_trans_sys_tdatetime timestamp without time zone, par_trans_ns_code character varying)
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
    CALL proc_lrr_get_hosp_map(var_return_code, var_hosp_code);

    IF var_return_code != 0 THEN
        OPEN p_refcur FOR
        select var_return_code;
        RETURN NEXT p_refcur;
        RETURN;
    END IF;
    */
	
    /*
    script before CPI update
    *****
            select Transaction_log.System_datetime,
                   DT_transaction_type.DT_code
              from Transaction_log, PMI, Case, DT_transaction_type
             where (Transaction_log.Case_no = Case.Case_no)
               and (Case.HKID = PMI.HKID)
               and (Transaction_log.Transaction_type = DT_transaction_type.ADT_code)
               and (Transaction_log.System_datetime >= @TRANS_SYS_FDATETIME)
               and (Transaction_log.System_datetime <= @TRANS_SYS_TDATETIME)
               and (Transaction_log.From_ward_code like @TRANS_NS_CODE and
                     Transaction_log.Transaction_type in ('160','230'))
    union
    
            select Transaction_log.System_datetime,
                   DT_transaction_type.DT_code
              from Transaction_log, PMI, Case, DT_transaction_type
             where (Transaction_log.Case_no = Case.Case_no)
               and (Case.HKID = PMI.HKID)
               and (Transaction_log.Transaction_type = DT_transaction_type.ADT_code)
               and (Transaction_log.System_datetime >= @TRANS_SYS_FDATETIME)
               and (Transaction_log.System_datetime <= @TRANS_SYS_TDATETIME)
               and (Transaction_log.To_ward_code like @TRANS_NS_CODE and
                     Transaction_log.Transaction_type in ('170','240'))
    *****
      updated by man at may 96
    */
    OPEN p_refcur FOR
    SELECT
        Transaction_log.System_datetime, DT_transaction_type.DT_code
        FROM Transaction_log, DT_transaction_type
        WHERE (Transaction_log.Hospital_code = par_hosp_code) AND (Transaction_log.Transaction_type = DT_transaction_type.ADT_code) AND (Transaction_log.System_datetime >= par_TRANS_SYS_FDATETIME) AND (Transaction_log.System_datetime <= par_TRANS_SYS_TDATETIME) AND (Transaction_log.From_ward_code LIKE par_TRANS_NS_CODE AND Transaction_log.Transaction_type IN ('160', '230'))
    UNION
    SELECT
        Transaction_log.System_datetime, DT_transaction_type.DT_code
        FROM Transaction_log, DT_transaction_type
        WHERE (Transaction_log.Hospital_code = par_hosp_code) AND (Transaction_log.Transaction_type = DT_transaction_type.ADT_code) AND (Transaction_log.System_datetime >= par_TRANS_SYS_FDATETIME) AND (Transaction_log.System_datetime <= par_TRANS_SYS_TDATETIME) AND (Transaction_log.To_ward_code LIKE par_TRANS_NS_CODE AND Transaction_log.Transaction_type IN ('170', '240'));
    RETURN NEXT p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_select_trial_dis" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
