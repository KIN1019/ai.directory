-- DROP FUNCTION hpi.proc_lrr_get_chgnscode(varchar, varchar, int4, varchar);

CREATE OR REPLACE FUNCTION hpi.proc_lrr_get_chgnscode(par_default_ns_flag character varying, par_ws_code character varying, change_ns_code_count integer, par_change_ns_code character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_hosp_code VARCHAR(6);
    var_return_code INTEGER;
    p_refcur refcursor;
BEGIN
    /* Add Hospital Code */
	
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

    /*2025-01-23*/
    /*
    BEGIN
        SELECT
            COUNT(CHANGE_NS_CODE)
            INTO var_rowcount
            FROM cmslrr_db_dbo.CHANGE_WARD
            WHERE DEFAULT_NS_FLAG = par_DEFAULT_NS_FLAG AND RTRIM(WS_CODE) = RTRIM(par_WS_CODE) AND HOSP_CODE = var_hosp_code;

         IF var_rowcount > 1 THEN
            BEGIN
                RAISE EXCEPTION 'Invalid Change NS code in CHANGE_WARD!' USING ERRCODE := '99999';
            END;
        END IF;
    END;

    BEGIN
        OPEN p_refcur FOR
        SELECT
            CHANGE_NS_CODE
            FROM cmslrr_db_dbo.CHANGE_WARD
            WHERE DEFAULT_NS_FLAG = par_DEFAULT_NS_FLAG AND RTRIM(WS_CODE) = RTRIM(par_WS_CODE) AND HOSP_CODE = var_hosp_code;
        RETURN NEXT p_refcur;
    END;
    /* if @rowcount != 1 */
    */
    var_rowcount :=change_ns_code_count;
    IF var_rowcount > 1 THEN
        RAISE EXCEPTION 'Invalid Change NS code in CHANGE_WARD!' USING ERRCODE := '99999';
    ELSE
        BEGIN
            OPEN p_refcur FOR
            SELECT par_change_ns_code AS CHANGE_NS_CODE;
            RETURN NEXT p_refcur;
        END;
    END IF;
END;
$function$
;


;ALTER FUNCTION "proc_lrr_get_chgnscode" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
