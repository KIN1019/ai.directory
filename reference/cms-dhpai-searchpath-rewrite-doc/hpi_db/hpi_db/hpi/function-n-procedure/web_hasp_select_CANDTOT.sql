-- DROP FUNCTION hpi.web_hasp_select_candtot(varchar, timestamp, timestamp, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.web_hasp_select_candtot(par_hosp_code character varying, par_trans_sys_fdatetime timestamp without time zone, par_trans_sys_tdatetime timestamp without time zone, par_trans_ns_code character varying, par_from_time character varying, par_to_time character varying)
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
	if par_FROM_TIME is not null then
		select substring(par_FROM_TIME, 1, 5) into par_FROM_TIME;
	end if;
    if par_TO_TIME is not null then
		select substring(par_TO_TIME, 1, 5) into par_TO_TIME;
	end if;
	
    OPEN p_refcur FOR
    SELECT
        Transaction_log.System_datetime, Transaction_log.Case_no, p.patient_name, p.sex, p.dob, c.discharge_code, c.destination_code,
        to_char(Transaction_log.System_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI'),
        date_part('year', localtimestamp::TIMESTAMP) - date_part('year', p.dob::TIMESTAMP), date_part('month', localtimestamp::TIMESTAMP) - date_part('month', p.dob::TIMESTAMP),
        date_part('day', localtimestamp::TIMESTAMP) - date_part('day', p.dob::TIMESTAMP), localtimestamp,
        to_char(p.dob::TIMESTAMP WITHOUT TIME ZONE, 'DD-MM-YYYY'),
        to_char(Transaction_log.System_datetime::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY'),
        Transaction_log.From_specialty_code, DT_transaction_type.DT_code, Transaction_log.To_ward_code, Transaction_log.To_bed, Transaction_log.To_specialty_code,
        Transaction_log.To_class, Transaction_log.From_ward_code, Transaction_log.From_bed, Transaction_log.From_class, par_TRANS_NS_CODE,
        CONCAT(to_char(Transaction_log.Transaction_datetime::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM'),
        	' ',
        	to_char(Transaction_log.Transaction_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI')),
        /* Sync column with hasp_select_CAND which for retrieve exactly ward code */
        par_TRANS_SYS_FDATETIME, par_TRANS_SYS_TDATETIME, par_FROM_TIME, par_TO_TIME, Transaction_log.Transaction_datetime, p.death_indicator, p.death_date
        /* End of Sync column with hasp_select_CAND which for retrieve exactly ward code */
        FROM hpi.Transaction_log, hpi.cpi_patient AS p, hpi.cpi_case AS c, hpi.DT_transaction_type
        WHERE (Transaction_log.Hospital_code = par_hosp_code) 
        AND (c.hospital_code = Transaction_log.Hospital_code)
        AND (c.case_no = Transaction_log.Case_no)
        AND (p.patient_key = c.patient_key)
        AND (Transaction_log.Transaction_type = DT_transaction_type.ADT_code)
        AND (Transaction_log.System_datetime >= par_TRANS_SYS_FDATETIME)
        AND (Transaction_log.System_datetime <= par_TRANS_SYS_TDATETIME)
        AND ((Transaction_log.From_ward_code LIKE par_TRANS_NS_CODE)
        OR (Transaction_log.To_ward_code LIKE par_TRANS_NS_CODE))
        AND ((Transaction_log.Transaction_type IN ('710', '220', '230', '240'))
        OR (Transaction_log.Transaction_type LIKE '21%'))
        ORDER BY Transaction_log.System_datetime ASC NULLS FIRST;
   RETURN NEXT p_refcur;
END;
$function$
;



;ALTER FUNCTION "web_hasp_select_candtot" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
