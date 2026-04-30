-- DROP FUNCTION hpi.hasp_select_sumatot(varchar, timestamp, timestamp, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_select_sumatot(par_hosp_code character varying, par_trans_sys_fdatetime timestamp without time zone, par_trans_sys_tdatetime timestamp without time zone, par_trans_ns_code character varying)
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
	
    /* updated by man at may 96 */
    /* requested by stephen chan */
    /*
    select Transaction_log.System_datetime,
               t1.temp_hh,
              (select DT_code from DT_transaction_type
                where ADT_code = Transaction_log.Transaction_type),
               Transaction_log.From_ward_code,
               Transaction_log.To_ward_code,
               d1.Short_description,
               @TRANS_SYS_TDATETIME,
               @TRANS_SYS_FDATETIME,
               @TRANS_NS_CODE,
               convert(char(30),convert(datetime,@TRANS_SYS_TDATETIME),103),
               Transaction_log.System_datetime
          from Transaction_log,
               TEMP_TRANS_SUMMARY t1,
               Discharge_type d1
         where
               substring(Transaction_log.Transaction_type,3,1)=d1.Discharge_code and
              (Transaction_log.Transaction_type in ('140','160','170','700','710') or
               Transaction_log.Transaction_type in ('131','132','133','135','136','137','138') or
               Transaction_log.Transaction_type in ('211','212','213','215','216','217','218','230','240')) and
              (Transaction_log.System_datetime >= @TRANS_SYS_FDATETIME) and
              (Transaction_log.System_datetime <= @TRANS_SYS_TDATETIME) and
              (Transaction_log.From_ward_code like @TRANS_NS_CODE or
               Transaction_log.To_ward_code   like @TRANS_NS_CODE ) and
              (datepart(hh, Transaction_log.System_datetime) =
                    convert(smallint,t1.temp_hh))
    union
        select Transaction_log.System_datetime,
               t1.temp_hh,
              (select DT_code from DT_transaction_type
                where Transaction_log.Transaction_type = ADT_code),
               Transaction_log.From_ward_code,
               Transaction_log.To_ward_code,
               ' ',
               @TRANS_SYS_TDATETIME,
               @TRANS_SYS_FDATETIME,
               @TRANS_NS_CODE,
               convert(char(30),convert(datetime,@TRANS_SYS_TDATETIME),103),
               Transaction_log.System_datetime
          from Transaction_log,
               TEMP_TRANS_SUMMARY t1
         where
              (Transaction_log.Transaction_type in ('130','134','139') or
               Transaction_log.Transaction_type in ('210','214','219')) and
              (Transaction_log.System_datetime >= @TRANS_SYS_FDATETIME) and
              (Transaction_log.System_datetime <= @TRANS_SYS_TDATETIME) and
              (Transaction_log.From_ward_code like @TRANS_NS_CODE or
               Transaction_log.To_ward_code like @TRANS_NS_CODE) and
              (datepart(hh, Transaction_log.System_datetime) =
                   convert(smallint, t1.temp_hh))
    */
    /* end of comment */
    OPEN p_refcur FOR
    SELECT
        Transaction_log.System_datetime, t1.temp_hh, (SELECT
            DT_code
            FROM DT_transaction_type
            WHERE ADT_code = Transaction_log.Transaction_type), Transaction_log.From_ward_code, Transaction_log.To_ward_code, d1.Short_description, par_TRANS_SYS_TDATETIME, par_TRANS_SYS_FDATETIME, par_TRANS_NS_CODE, to_char(par_TRANS_SYS_TDATETIME::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY'), Transaction_log.System_datetime
        FROM Transaction_log, TEMP_TRANS_SUMMARY AS t1, Discharge_type AS d1
        WHERE Transaction_log.Hospital_code = par_hosp_code AND SUBSTRING(Transaction_log.Transaction_type, 3, 1) = d1.Discharge_code AND (Transaction_log.Transaction_type IN ('140', '160', '170', '700', '710', '230', '240') OR Transaction_log.Transaction_type LIKE '13%' OR Transaction_log.Transaction_type LIKE '21%' OR Transaction_log.Transaction_type LIKE '33%' OR Transaction_log.Transaction_type LIKE '35%') AND (Transaction_log.System_datetime >= par_TRANS_SYS_FDATETIME) AND (Transaction_log.System_datetime <= par_TRANS_SYS_TDATETIME) AND (Transaction_log.From_ward_code LIKE par_TRANS_NS_CODE OR Transaction_log.To_ward_code LIKE par_TRANS_NS_CODE) AND (date_part('hour', Transaction_log.System_datetime::TIMESTAMP) = CAST (t1.temp_hh AS SMALLINT))
    UNION
    SELECT
        t1.Transaction_datetime, t2.temp_hh, (SELECT
            DT_code
            FROM DT_transaction_type
            WHERE t1.Transaction_type = ADT_code), t1.From_ward_code, t1.To_ward_code, ' ', par_TRANS_SYS_TDATETIME, par_TRANS_SYS_FDATETIME, par_TRANS_NS_CODE, to_char(par_TRANS_SYS_TDATETIME::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY'), t1.System_datetime
        FROM Transaction_log AS t1, TEMP_TRANS_SUMMARY AS t2
        WHERE t1.Hospital_code = par_hosp_code AND (t1.Transaction_type IN ('100', '300')) AND (t1.Transaction_datetime >= par_TRANS_SYS_FDATETIME) AND (t1.Transaction_datetime <= par_TRANS_SYS_TDATETIME) AND (t1.From_ward_code LIKE par_TRANS_NS_CODE) AND (t1.Cancel_flag IS NULL) AND (date_part('hour', t1.Transaction_datetime::TIMESTAMP) = CAST (t2.temp_hh AS SMALLINT))
    UNION
    SELECT
        Transaction_log.System_datetime, t1.temp_hh, (SELECT
            DT_code
            FROM DT_transaction_type
            WHERE Transaction_log.Transaction_type = ADT_code), Transaction_log.To_ward_code, Transaction_log.From_ward_code, ' ', par_TRANS_SYS_TDATETIME, par_TRANS_SYS_FDATETIME, par_TRANS_NS_CODE, to_char(par_TRANS_SYS_TDATETIME::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY'), Transaction_log.System_datetime
        FROM Transaction_log, TEMP_TRANS_SUMMARY AS t1
        WHERE Transaction_log.Hospital_code = par_hosp_code AND Transaction_log.Transaction_type = '220' AND (Transaction_log.System_datetime >= par_TRANS_SYS_FDATETIME) AND (Transaction_log.System_datetime <= par_TRANS_SYS_TDATETIME) AND (Transaction_log.From_ward_code LIKE par_TRANS_NS_CODE OR Transaction_log.To_ward_code LIKE par_TRANS_NS_CODE) AND (date_part('hour', Transaction_log.System_datetime::TIMESTAMP) = CAST (t1.temp_hh AS SMALLINT));
    RETURN NEXT p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_select_sumatot" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
