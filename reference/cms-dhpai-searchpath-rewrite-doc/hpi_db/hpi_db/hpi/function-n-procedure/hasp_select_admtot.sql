-- DROP FUNCTION hpi.hasp_select_admtot(varchar, timestamp, timestamp, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_select_admtot(par_hosp_code character varying, par_case_adm_fdatetime timestamp without time zone, par_case_adm_tdatetime timestamp without time zone, par_case_ns_code character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_return_code INTEGER;
    p_refcur refcursor;
begin
	
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
        From_ward_code
        FROM hpi.Transaction_log
        WHERE (Hospital_code = par_hosp_code) AND (Transaction_datetime >= par_CASE_ADM_FDATETIME) AND (Transaction_datetime <= par_CASE_ADM_TDATETIME) AND (From_ward_code LIKE par_CASE_NS_CODE) AND (Transaction_type IN ('100', '300')) AND (Cancel_flag IS NULL);
    RETURN NEXT p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_select_admtot" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
