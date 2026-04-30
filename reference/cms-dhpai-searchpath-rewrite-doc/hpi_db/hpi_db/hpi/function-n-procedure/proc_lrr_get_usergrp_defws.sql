-- DROP FUNCTION hpi.proc_lrr_get_usergrp_defws(varchar, varchar, int4, varchar);

CREATE OR REPLACE FUNCTION hpi.proc_lrr_get_usergrp_defws(par_hosp_code character varying, par_user_group character varying, ns_code_count integer, par_ns_code character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_hosp_code VARCHAR(6);
    var_return_code INTEGER;
    sql$rowcount BIGINT;
    p_refcur refcursor;
begin
	
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
    /* Add Hospital Code */
    /*
    BEGIN
        SELECT
            COUNT(ns_code)
            INTO var_rowcount
            FROM cmslrr_db_dbo.cms_ward_list
            WHERE default_ns_flag = 'Y' AND RTRIM(user_group) = RTRIM(par_user_group) AND hosp_code = var_hosp_code;
        IF var_rowcount > 1 THEN
            BEGIN
                RAISE EXCEPTION 'Invalid Change NS code in cms_ward_list' USING ERRCODE := '99999';
            END;
        END IF;

        OPEN p_refcur FOR
        SELECT
            ns_code
            FROM cmslrr_db_dbo.cms_ward_list
            WHERE default_ns_flag = 'Y' AND RTRIM(user_group) = RTRIM(par_user_group) AND hosp_code = var_hosp_code;
        RETURN NEXT p_refcur;
        var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
    END;

    IF var_error != 0 THEN
        BEGIN
            RAISE EXCEPTION 'Error selecting default ward code' USING ERRCODE := '99999';
        END;
    END IF;
    */
   var_rowcount := ns_code_count; 
    IF var_rowcount > 1 THEN
        RAISE EXCEPTION 'Invalid Change NS code in CHANGE_WARD!' USING ERRCODE := '99999';
    ELSE
        var_error := 0;

        BEGIN
            OPEN p_refcur FOR
            SELECT par_ns_code AS NS_CODE;
            RETURN NEXT p_refcur;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;
        IF var_error != 0 THEN
            RAISE EXCEPTION 'Error selecting default ward code' USING ERRCODE := '99999';
        END IF;
    END IF;
END;
$function$
;


;ALTER FUNCTION "proc_lrr_get_usergrp_defws" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
