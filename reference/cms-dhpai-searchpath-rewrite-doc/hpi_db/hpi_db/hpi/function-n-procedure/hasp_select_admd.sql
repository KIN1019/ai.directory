-- DROP FUNCTION hpi.hasp_select_admd(varchar, timestamp, timestamp, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_select_admd(par_hosp_code character varying, par_trans_sys_fdatetime timestamp without time zone, par_trans_sys_tdatetime timestamp without time zone, par_trans_ns_code character varying, par_from_time character varying, par_to_time character varying)
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
	if par_FROM_TIME is not null then
	    select substring(par_FROM_TIME, 1, 5) into par_FROM_TIME;
	end if;
    if par_TO_TIME is not null then
	    select substring(par_TO_TIME, 1, 5) into par_TO_TIME;
	end if;
    OPEN p_refcur FOR
    SELECT
	        p.patient_name, p.sex, p.dob, c.Case_no, From_ward_code, From_specialty_code, Transaction_log.Transaction_datetime, p.hkid,
	        to_char(Transaction_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI'),
	        date_part('year', localtimestamp::TIMESTAMP) - date_part('year', p.dob::TIMESTAMP), date_part('month', localtimestamp::TIMESTAMP) - date_part('month', p.dob::TIMESTAMP),
	        date_part('day', localtimestamp::TIMESTAMP) - date_part('day', p.dob::TIMESTAMP), localtimestamp,
	        to_char(p.dob::TIMESTAMP WITHOUT TIME ZONE, 'DD-MM-YYYY'),
	        par_TRANS_NS_CODE,
	        to_char(par_TRANS_SYS_FDATETIME::TIMESTAMP WITHOUT TIME ZONE, 'DD-MM-YYYY'),
	        par_TRANS_SYS_FDATETIME, par_TRANS_SYS_TDATETIME,
	        par_FROM_TIME, par_TO_TIME,
	        p.death_indicator, p.death_date
        FROM hpi.Transaction_log, hpi.Case_view AS c, hpi.cpi_patient AS p
        WHERE (Transaction_log.Hospital_code = par_hosp_code) 
	        AND (Transaction_log.Transaction_datetime >= par_TRANS_SYS_FDATETIME)
	        AND (Transaction_log.Transaction_datetime <= par_TRANS_SYS_TDATETIME)
	        AND (Transaction_log.From_ward_code LIKE par_TRANS_NS_CODE)
	        AND (Transaction_type IN ('100', '300'))
	        AND (Transaction_log.Cancel_flag IS NULL)
	        AND (p.patient_key = c.T_PRK) AND (c.Hospital_code = Transaction_log.Hospital_code) AND (c.Case_no = Transaction_log.Case_no)
        ORDER BY Transaction_log.Transaction_datetime ASC NULLS FIRST, p.patient_name ASC NULLS FIRST;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of FORCEPLAN clause of SET statement is not supported. Perform a manual conversion.]
    set forceplan off
    */
    RETURN NEXT p_refcur;
END;
$function$
;



;ALTER FUNCTION "hasp_select_admd" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
