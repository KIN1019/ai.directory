-- DROP FUNCTION hpi.hasp_select_bedassd(varchar, timestamp, timestamp, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_select_bedassd(par_hosp_code character varying, par_trans_sys_fdatetime timestamp without time zone, par_trans_sys_tdatetime timestamp without time zone, par_trans_ns_code character varying, par_from_time character varying, par_to_time character varying)
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
                      Transaction_log.Case_no, PMI.Name,
                      PMI.Sex, PMI.DOB,
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
                      Transaction_log.From_bed,
                      convert(char(5),Transaction_log.Transaction_datetime,3)+ ' ' + convert(char(5),Transaction_log.Transaction_datetime,8),
                      Transaction_log.From_ward_code,
                      (select DT_code from DT_transaction_type
                       where Transaction_log.Transaction_type = ADT_code),
                      @TRANS_SYS_FDATETIME, @TRANS_SYS_TDATETIME,
                      @FROM_TIME, @TO_TIME
                 from Transaction_log, PMI, Case
                where (Transaction_log.Case_no = Case.Case_no) and
                      (Case.HKID = PMI.HKID) and
                      (Transaction_log.System_datetime >= @TRANS_SYS_FDATETIME) and
                      (Transaction_log.System_datetime <= @TRANS_SYS_TDATETIME) and
                      (Transaction_log.From_ward_code like @TRANS_NS_CODE) and
                      (Transaction_log.Transaction_type in ('700','710'))
    *****
      CPI updated by man at april 96
    */
    OPEN p_refcur FOR
    SELECT
        Transaction_log.System_datetime, Transaction_log.Case_no, p.patient_name, p.sex, p.dob, c.discharge_code, c.destination_code, to_char(Transaction_log.System_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS'), date_part('year', localtimestamp::TIMESTAMP) - date_part('year', p.dob::TIMESTAMP), date_part('month', localtimestamp::TIMESTAMP) - date_part('month', p.dob::TIMESTAMP), date_part('day', localtimestamp::TIMESTAMP) - date_part('day', p.dob::TIMESTAMP), localtimestamp, to_char(p.dob::TIMESTAMP WITHOUT TIME ZONE, 'DD-MM-YYYY'), par_TRANS_NS_CODE, to_char(par_TRANS_SYS_FDATETIME::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY'), Transaction_log.From_bed, CONCAT(to_char(Transaction_log.Transaction_datetime::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM'), ' ', to_char(Transaction_log.Transaction_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')), Transaction_log.From_ward_code, (SELECT
            DT_code
            FROM DT_transaction_type
            WHERE Transaction_log.Transaction_type = ADT_code), par_TRANS_SYS_FDATETIME, par_TRANS_SYS_TDATETIME, par_FROM_TIME, par_TO_TIME, Transaction_log.Transaction_datetime, p.death_indicator, p.death_date
        FROM Transaction_log, cpi_patient AS p, cpi_case AS c
        WHERE (Transaction_log.Hospital_code = par_hosp_code) AND (c.hospital_code = Transaction_log.Hospital_code) AND (c.case_no = Transaction_log.Case_no) AND (p.patient_key = c.patient_key) AND (Transaction_log.System_datetime >= par_TRANS_SYS_FDATETIME) AND (Transaction_log.System_datetime <= par_TRANS_SYS_TDATETIME) AND (Transaction_log.From_ward_code LIKE par_TRANS_NS_CODE) AND (Transaction_log.Transaction_type IN ('700', '710'))
        /*
        union
        select Event_log.System_datetime,
               Event_log.Case_no, PMI.Name,
               PMI.Sex, PMI.DOB,
               Event_log.Discharge_code,
               Event_log.Destination_code,
               convert(char(5),Transaction_log.System_datetime,108),
               datepart(year,getdate()) - datepart(year,PMI.DOB),
               datepart(month,getdate()) - datepart(month,PMI.DOB),
               datepart(day,getdate()) - datepart(day,PMI.DOB),
               getdate(),
               convert(varchar(30),PMI.DOB,105),
               @TRANS_NS_CODE,
               convert(char(30),convert(datetime,@TRANS_SYS_FDATETIME),103),
               Transaction_log.From_bed,
               convert(char(5),Transaction_log.Transaction_datetime,3) + ' ' + convert(char(5),Transaction_log.Transaction_datetime,8),
               Transaction_log.From_ward_code,
               (select DT_code from DT_transaction_type
                where Transaction_log.Transaction_type = ADT_code),
        
               @TRANS_SYS_FDATETIME, @TRANS_SYS_TDATETIME,
               @FROM_TIME, @TO_TIME
          from Transaction_log, PMI, Event_log
         where (Transaction_log.System_datetime = Event_log.System_datetime) and
               (PMI.HKID = Event_log.HKID) and
               (Transaction_log.Transaction_datetime >= @TRANS_SYS_FDATETIME) and
               (Transaction_log.Transaction_datetime <= @TRANS_SYS_TDATETIME) and
               (Transaction_log.From_ward_code like @TRANS_NS_CODE) and
               (Transaction_log.Transaction_type = '710')
        */
        ORDER BY 1 ASC NULLS FIRST;
    RETURN NEXT p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_select_bedassd" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
