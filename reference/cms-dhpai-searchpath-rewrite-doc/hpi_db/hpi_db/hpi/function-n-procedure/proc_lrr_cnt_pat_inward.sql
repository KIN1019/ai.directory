-- DROP FUNCTION hpi.proc_lrr_cnt_pat_inward(varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.proc_lrr_cnt_pat_inward(par_hosp_code character varying, par_case_ns_code character varying)
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
    CALL proc_lrr_get_hosp_map(var_return_code, var_hosp_code);

    IF var_return_code != 0 THEN
        OPEN p_refcur FOR
            select -1;
        RETURN NEXT p_refcur;
        RETURN;
    END IF;
    */

    IF EXISTS (select * from pg_tables where tablename = 'ward_list') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                COUNT(*)
                FROM ward_list
                WHERE hospital_code = par_hosp_code AND ward_code LIKE par_CASE_NS_CODE;
            RETURN NEXT p_refcur;
        END;
    END IF;
END;
$function$
;


;ALTER FUNCTION "proc_lrr_cnt_pat_inward" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
