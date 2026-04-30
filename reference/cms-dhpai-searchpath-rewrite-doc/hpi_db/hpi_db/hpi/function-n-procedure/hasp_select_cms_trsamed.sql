-- DROP FUNCTION hpi.hasp_select_cms_trsamed(varchar, timestamp, timestamp, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_select_cms_trsamed(par_hosp_code character varying, par_trans_sys_fdatetime timestamp without time zone, par_trans_sys_tdatetime timestamp without time zone, par_trans_ns_code character varying, par_from_time character varying, par_to_time character varying)
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
                   Transaction_log.Case_no,
                   PMI.Name,
                   PMI.Sex,
                   PMI.DOB,
                   Case.Discharge_code,
                   Case.Destination_code,
                   convert(char(5),Transaction_log.System_datetime,108),
                   datepart(year,getdate()) - datepart(year,PMI.DOB),
                   datepart(month,getdate()) - datepart(month,PMI.DOB),
                   datepart(day,getdate()) - datepart(day,PMI.DOB),
                   getdate(),
                   convert(varchar(30),PMI.DOB,105),
                   @TRANS_NS_CODE,
                   convert(char(30),convert(datetime,@TRANS_SYS_FDATETIME),103),
                   Transaction_log.From_ward_code,
                   Transaction_log.From_bed,
                   Transaction_log.From_specialty_code,
                   Transaction_log.From_class,
                   Transaction_log.To_bed,
                   Transaction_log.To_specialty_code,
                   Transaction_log.To_class,
                   Transaction_log.To_ward_code,
                   convert(char(5),Transaction_log.Transaction_datetime,3) + ' ' + convert(char(5), Transaction_log.Transaction_datetime,8),
                   DT_transaction_type.DT_code,
                   @TRANS_SYS_FDATETIME,
                   @TRANS_SYS_TDATETIME,
                   @FROM_TIME,
                   @TO_TIME,
                   e.Doctor_code,
                   e.Old_doctor_code
            from Transaction_log, PMI, Case, DT_transaction_type, Event_log e
          where (Transaction_log.Case_no = Case.Case_no and
                 Case.HKID = PMI.HKID and
                 Case.Case_no = e.Case_no) and
                (e.System_datetime = Transaction_log.System_datetime and
                 e.Case_no = Transaction_log.Case_no) and
                (Transaction_log.Transaction_type = DT_transaction_type.ADT_code) and
                (Transaction_log.System_datetime >= @TRANS_SYS_FDATETIME) and
                (Transaction_log.System_datetime <= @TRANS_SYS_TDATETIME) and
               (Transaction_log.From_ward_code like @TRANS_NS_CODE and
    			Transaction_log.From_ward_code = Transaction_log.To_ward_code
    			 and
                 Transaction_log.Transaction_type in ('140', '220'))
                order by System_datetime ASC
    *****
      updated by man at may 96
    */
    OPEN p_refcur FOR
    SELECT
        Transaction_log.System_datetime, Transaction_log.Case_no, p.patient_name, p.sex, p.dob, c.Discharge_code, c.Destination_code, to_char(Transaction_log.System_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS'), date_part('year', localtimestamp::TIMESTAMP) - date_part('year', p.dob::TIMESTAMP), date_part('month', localtimestamp::TIMESTAMP) - date_part('month', p.dob::TIMESTAMP), date_part('day', localtimestamp::TIMESTAMP) - date_part('day', p.dob::TIMESTAMP), localtimestamp, to_char(p.dob::TIMESTAMP WITHOUT TIME ZONE, 'DD-MM-YYYY'), par_TRANS_NS_CODE, to_char(par_TRANS_SYS_FDATETIME::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY'), Transaction_log.From_ward_code, Transaction_log.From_bed, Transaction_log.From_specialty_code, Transaction_log.From_class, Transaction_log.To_bed, Transaction_log.To_specialty_code, Transaction_log.To_class, Transaction_log.To_ward_code, CONCAT(to_char(Transaction_log.Transaction_datetime::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM'), ' ', to_char(Transaction_log.Transaction_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')), DT_transaction_type.DT_code, par_TRANS_SYS_FDATETIME, par_TRANS_SYS_TDATETIME, par_FROM_TIME, par_TO_TIME, e.Doctor_code, e.Old_doctor_code, Transaction_log.Transaction_datetime, p.death_indicator, p.death_date
        FROM Transaction_log, Case_view AS c, cpi_patient AS p, Event_log AS e, DT_transaction_type
        WHERE (Transaction_log.Hospital_code = par_hosp_code) AND (Transaction_log.System_datetime >= par_TRANS_SYS_FDATETIME) AND (Transaction_log.System_datetime <= par_TRANS_SYS_TDATETIME) AND (Transaction_log.From_ward_code LIKE par_TRANS_NS_CODE AND Transaction_log.From_ward_code = Transaction_log.To_ward_code AND Transaction_log.Transaction_type IN ('140', '220')) AND (Transaction_log.Hospital_code = c.Hospital_code AND Transaction_log.Case_no = c.Case_no AND c.T_PRK = p.patient_key AND c.Case_no = e.Case_no) AND e.Hospital_code = Transaction_log.Hospital_code AND e.System_datetime = Transaction_log.System_datetime AND e.Case_no = Transaction_log.Case_no AND Transaction_log.Transaction_type = DT_transaction_type.ADT_code
        ORDER BY e.System_datetime ASC NULLS FIRST;
    RETURN NEXT p_refcur;
    /*
    In adt : Transfer : In - 141, Out - 140
    Cancellation of Transfer : In - 221, Out - 220
    */
    /*
    Original coding
    ((TRANSACTIONS.TRANS_PREV_NS_CODE like @TRANS_NS_CODE and
      TRANSACTIONS.TRANS_TYPE = '4') or
     (TRANSACTIONS.TRANS_NS_CODE like @TRANS_NS_CODE and
      TRANSACTIONS.TRANS_TYPE = '8'))
    */
END;
$function$
;


;ALTER FUNCTION "hasp_select_cms_trsamed" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
