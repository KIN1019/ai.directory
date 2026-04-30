-- DROP FUNCTION hpi.hasp_check_ds(varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_check_ds(par_ds_code character varying, par_ds_specialty_code character varying, par_ds_ns_code character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/* Add Hospital Code */
DECLARE
    var_hosp_code VARCHAR(6);
    var_return_code INTEGER;
    p_refcur refcursor;
begin
	
	-- CP2 & Harmonycloud on Jan-2025:
	-- Since the ownership of cmslrr_db and the migration approach are to be confirmed with other CMS teams (E.g. Related SPs may be changed to APIs),
	-- the following logic about cmslrr_db was not migrated to PG in this moment and was commented in PG DDL with this remark for record.
	/*
    CALL proc_lrr_get_hosp_map(var_return_code, var_hosp_code);

    IF var_return_code != 0 THEN
        OPEN p_refcur FOR
            SELECT -1;
        RETURN NEXT p_refcur;
        RETURN;
    END IF;
    */
    /*2025-01-24*/
   /*
    OPEN p_refcur FOR
    SELECT
        COUNT(*)
        FROM cmslrr_db_dbo.DELIVERY_SUITE
        WHERE HOSP_CODE = var_hosp_code AND DS_CODE = par_DS_CODE AND DS_SPECIALTY_CODE = par_DS_SPECIALTY_CODE AND DS_NS_CODE = par_DS_NS_CODE;
    RETURN NEXT p_refcur;
    */
    OPEN p_refcur FOR
    SELECT 0 AS COUNT;
    RETURN NEXT p_refcur;
    RETURN;
END;
$function$
;

;ALTER FUNCTION "hasp_check_ds" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
