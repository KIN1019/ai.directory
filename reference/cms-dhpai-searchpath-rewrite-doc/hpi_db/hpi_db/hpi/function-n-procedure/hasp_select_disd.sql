-- DROP FUNCTION hpi.hasp_select_disd(varchar, timestamp, timestamp, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_select_disd(par_hosp_code character varying, par_trans_sys_fdatetime timestamp without time zone, par_trans_sys_tdatetime timestamp without time zone, par_trans_ns_code character varying, par_from_time character varying, par_to_time character varying)
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
	
    /*
    [3069 - Severity CRITICAL - Automatic conversion of FORCEPLAN clause of SET statement is not supported. Perform a manual conversion.]
    set forceplan on
    */
    OPEN p_refcur FOR
    SELECT
        Transaction_log.System_datetime, Transaction_log.Case_no, p.patient_name, p.sex, p.dob, SUBSTRING(Transaction_log.Transaction_type, 3, 1), (SELECT
            d1.Short_description
            FROM hpi.Discharge_type AS d1
            WHERE d1.Discharge_code = SUBSTRING(Transaction_log.Transaction_type, 3, 1)),
            to_char(Transaction_log.System_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS'),
            date_part('year', localtimestamp::TIMESTAMP) - date_part('year', p.dob::TIMESTAMP), date_part('month', localtimestamp::TIMESTAMP) - date_part('month', p.dob::TIMESTAMP),
            date_part('day', localtimestamp::TIMESTAMP) - date_part('day', p.dob::TIMESTAMP), localtimestamp,
            to_char(p.dob::TIMESTAMP WITHOUT TIME ZONE, 'DD-MM-YYYY'),
            par_TRANS_NS_CODE, to_char(par_TRANS_SYS_FDATETIME::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY'),
            CONCAT(to_char(Transaction_log.Transaction_datetime::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM'), ' ',
            to_char(Transaction_log.Transaction_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')),
            Transaction_log.From_ward_code,
            (select DT_code FROM hpi.DT_transaction_type WHERE Transaction_log.Transaction_type = ADT_code),
            Transaction_log.To_ward_code, par_TRANS_SYS_FDATETIME, par_TRANS_SYS_TDATETIME, par_FROM_TIME, par_TO_TIME, e.Doctor_code, e.Old_doctor_code,
            Transaction_log.Transaction_datetime,
        /* Add by fai  09099 to get death_indicator and death_date */
        p.death_indicator, p.death_date
        /* End */
        /*
        the Case table is replaced by a view named Case_view
        for the implementation of CPI
        */
        /* from  Transaction_log, PMI, Case, Event_log e */
        FROM hpi.Transaction_log, hpi.cpi_case AS c, hpi.cpi_patient AS p, hpi.Event_log AS e
        WHERE Transaction_log.Hospital_code = par_hosp_code AND Transaction_log.System_datetime >= par_TRANS_SYS_FDATETIME
        AND Transaction_log.System_datetime <= par_TRANS_SYS_TDATETIME
        AND SUBSTRING(Transaction_log.Transaction_type, 3, 1) NOT IN ('0', '4', '9')
        AND Transaction_log.From_ward_code LIKE par_TRANS_NS_CODE
        AND c.hospital_code = Transaction_log.Hospital_code
        AND c.case_no = Transaction_log.Case_no
        AND e.Hospital_code = Transaction_log.Hospital_code
        AND e.System_datetime = Transaction_log.System_datetime
        AND e.Case_no = Transaction_log.Case_no
        AND p.patient_key = c.patient_key
        AND
        /* updated by man at may 96 */
        /* requested by stephen chan */
        /*
        (Transaction_log.Transaction_type like '21%' or
        Transaction_log.Transaction_type like '13%')
        */
        /* end of comment */
        (Transaction_log.Transaction_type LIKE '21%' OR Transaction_log.Transaction_type LIKE '13%' OR Transaction_log.Transaction_type LIKE '33%' OR Transaction_log.Transaction_type LIKE '35%')
    UNION
    SELECT
        Transaction_log.System_datetime, Transaction_log.Case_no, p.patient_name, p.sex, p.dob, SUBSTRING(Transaction_log.Transaction_type, 3, 1),
        e.Destination_code, 
        to_char(Transaction_log.System_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS'),
        date_part('year', localtimestamp::TIMESTAMP) - date_part('year', p.dob::TIMESTAMP), date_part('month', localtimestamp::TIMESTAMP) - date_part('month', p.dob::TIMESTAMP),
        date_part('day', localtimestamp::TIMESTAMP) - date_part('day', p.dob::TIMESTAMP), localtimestamp,
        to_char(p.dob::TIMESTAMP WITHOUT TIME ZONE, 'DD-MM-YYYY'),
        par_TRANS_NS_CODE, to_char(par_TRANS_SYS_FDATETIME::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY'),
        CONCAT(to_char(Transaction_log.Transaction_datetime::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM'), ' ',
        to_char(Transaction_log.Transaction_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')),
        Transaction_log.From_ward_code, DT_code, Transaction_log.To_ward_code, par_TRANS_SYS_FDATETIME, par_TRANS_SYS_TDATETIME, par_FROM_TIME, par_TO_TIME, e.Doctor_code,
        e.Old_doctor_code, Transaction_log.Transaction_datetime,
        /* Add by fai 090999 to get death_indicator and death_date */
        p.death_indicator, p.death_date
        /* End */
        /*
        change Case to Case_view
        from Transaction_log, PMI, Event_log, DT_transaction_type, Case
        */
        FROM hpi.Transaction_log, hpi.DT_transaction_type, hpi.cpi_case AS c, hpi.cpi_patient AS p, hpi.Event_log AS e
        WHERE Transaction_log.Hospital_code = par_hosp_code AND Transaction_log.System_datetime >= par_TRANS_SYS_FDATETIME
        AND Transaction_log.System_datetime <= par_TRANS_SYS_TDATETIME 
        AND SUBSTRING(Transaction_log.Transaction_type, 3, 1) IN ('0', '4', '9')
        AND Transaction_log.From_ward_code LIKE par_TRANS_NS_CODE 
        AND c.hospital_code = Transaction_log.Hospital_code 
        AND c.case_no = Transaction_log.Case_no
        AND e.Hospital_code = Transaction_log.Hospital_code
        AND e.System_datetime = Transaction_log.System_datetime
        AND e.Case_no = Transaction_log.Case_no AND p.patient_key = c.patient_key AND
        /* updated by man at may 96 */
        /* requested by stephen chan */
        /*
        (Transaction_log.Transaction_type like '21%' or
        Transaction_log.Transaction_type like '13%') and
        */
        /* end of comment */
        (Transaction_log.Transaction_type LIKE '21%' OR Transaction_log.Transaction_type LIKE '13%' OR Transaction_log.Transaction_type LIKE '33%' OR Transaction_log.Transaction_type LIKE '35%') AND (Transaction_log.Transaction_type = ADT_code)
        ORDER BY 1 ASC NULLS FIRST;
    RETURN NEXT p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_select_disd" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
