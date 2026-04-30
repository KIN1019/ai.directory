-- DROP FUNCTION hpi.hasp_select_sum(varchar, timestamp, timestamp, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_select_sum(par_hosp_code character varying, par_trans_sys_fdatetime timestamp without time zone, par_trans_sys_tdatetime timestamp without time zone, par_trans_ns_code character varying, par_from_time character varying, par_to_time character varying)
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
    select t1.System_datetime,
                   t2.temp_hh,
                   (select DT_code from DT_transaction_type
       			      where t1.Transaction_type = ADT_code),
                   t1.From_ward_code,
                   t1.To_ward_code,
                   d1.Short_description,
                   @TRANS_SYS_TDATETIME,
                   @TRANS_SYS_FDATETIME,
                   @TRANS_NS_CODE,
                   convert(char(30),convert(datetime,@TRANS_SYS_TDATETIME),103),
                   t1.System_datetime,
                   @FROM_TIME,
                   @TO_TIME
              from Transaction_log t1, TEMP_TRANS_SUMMARY t2,
                   Discharge_type d1
             where
                   substring(t1.Transaction_type,3,1) = d1.Discharge_code and
    	       (t1.Transaction_type in ('140','160','170','700','710') or
    		t1.Transaction_type in ('131','132','133','135','136','137','138') or
                    t1.Transaction_type in ('211','212','213','215','216','217','218','230','240')) and
                   (t1.System_datetime >= @TRANS_SYS_FDATETIME) and
                   (t1.System_datetime <= @TRANS_SYS_TDATETIME) and
                   ((t1.From_ward_code = @TRANS_NS_CODE) or
                    (t1.To_ward_code   = @TRANS_NS_CODE)) and
                   (datepart(hh, t1.System_datetime) =
                    convert(smallint, t2.temp_hh))
    union
            select t1.System_datetime,
                   t2.temp_hh,
                   (select DT_code from DT_transaction_type
    			where t1.Transaction_type = ADT_code),
                   t1.From_ward_code,
                   t1.To_ward_code,
                   ' ',
                   @TRANS_SYS_TDATETIME,
                   @TRANS_SYS_FDATETIME,
                   @TRANS_NS_CODE,
                   convert(char(30),convert(datetime,@TRANS_SYS_TDATETIME),103),
                   t1.System_datetime,
                   @FROM_TIME,
                   @TO_TIME
              from Transaction_log t1, TEMP_TRANS_SUMMARY t2,
                   Discharge_type d1
             where
            	(t1.Transaction_type in ('130','134','139') or
                    t1.Transaction_type in ('210','214','219')) and
                   (t1.System_datetime >= @TRANS_SYS_FDATETIME) and
                   (t1.System_datetime <= @TRANS_SYS_TDATETIME) and
                  ((t1.From_ward_code = @TRANS_NS_CODE)  or
                   (t1.To_ward_code   = @TRANS_NS_CODE)) and
                   (datepart(hh, t1.System_datetime) =
                    convert(smallint, t2.temp_hh))
    */
    OPEN p_refcur FOR
    SELECT
        t1.System_datetime, t2.temp_hh, (SELECT
            DT_code
            FROM DT_transaction_type
            WHERE t1.Transaction_type = ADT_code), t1.From_ward_code, t1.To_ward_code, d1.Short_description, par_TRANS_SYS_TDATETIME, par_TRANS_SYS_FDATETIME, par_TRANS_NS_CODE, to_char(par_TRANS_SYS_TDATETIME::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY'), t1.System_datetime, par_FROM_TIME, par_TO_TIME
        FROM Transaction_log AS t1, TEMP_TRANS_SUMMARY AS t2, Discharge_type AS d1
        WHERE t1.Hospital_code = par_hosp_code AND SUBSTRING(t1.Transaction_type, 3, 1) = d1.Discharge_code AND (t1.Transaction_type IN ('140', '160', '170', '700', '710', '230', '240') OR t1.Transaction_type LIKE '13%' OR t1.Transaction_type LIKE '21%' OR t1.Transaction_type LIKE '35%' OR t1.Transaction_type LIKE '33%') AND (t1.System_datetime >= par_TRANS_SYS_FDATETIME) AND (t1.System_datetime <= par_TRANS_SYS_TDATETIME) AND ((t1.From_ward_code = par_TRANS_NS_CODE) OR (t1.To_ward_code = par_TRANS_NS_CODE)) AND (date_part('hour', t1.System_datetime::TIMESTAMP) = CAST (t2.temp_hh AS SMALLINT))
    UNION
    SELECT
        t1.Transaction_datetime, t2.temp_hh, (SELECT
            DT_code
            FROM DT_transaction_type
            WHERE t1.Transaction_type = ADT_code), t1.From_ward_code, t1.To_ward_code, ' ', par_TRANS_SYS_TDATETIME, par_TRANS_SYS_FDATETIME, par_TRANS_NS_CODE, to_char(par_TRANS_SYS_TDATETIME::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY'), t1.System_datetime, par_FROM_TIME, par_TO_TIME
        FROM Transaction_log AS t1, TEMP_TRANS_SUMMARY AS t2
        WHERE t1.Hospital_code = par_hosp_code AND (t1.Transaction_type IN ('100', '300')) AND (t1.Transaction_datetime >= par_TRANS_SYS_FDATETIME) AND (t1.Transaction_datetime <= par_TRANS_SYS_TDATETIME) AND (t1.From_ward_code = par_TRANS_NS_CODE) AND (t1.Cancel_flag IS NULL) AND (date_part('hour', t1.Transaction_datetime::TIMESTAMP) = CAST (t2.temp_hh AS SMALLINT))
    UNION
    SELECT
        t1.System_datetime, t2.temp_hh, (SELECT
            DT_code
            FROM DT_transaction_type
            WHERE t1.Transaction_type = ADT_code), t1.To_ward_code, t1.From_ward_code, ' ', par_TRANS_SYS_TDATETIME, par_TRANS_SYS_FDATETIME, par_TRANS_NS_CODE, to_char(par_TRANS_SYS_TDATETIME::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY'), t1.System_datetime, par_FROM_TIME, par_TO_TIME
        FROM Transaction_log AS t1, TEMP_TRANS_SUMMARY AS t2, Discharge_type AS d1
        WHERE t1.Hospital_code = par_hosp_code AND t1.Transaction_type = '220' AND (t1.System_datetime >= par_TRANS_SYS_FDATETIME) AND (t1.System_datetime <= par_TRANS_SYS_TDATETIME) AND (t1.From_ward_code = par_TRANS_NS_CODE OR t1.To_ward_code = par_TRANS_NS_CODE) AND (date_part('hour', t1.System_datetime::TIMESTAMP) = CAST (t2.temp_hh AS SMALLINT))
    UNION
    SELECT
        '1900-01-01 00:00:00.000'::TIMESTAMP, temp_hh,''::VARCHAR,par_TRANS_NS_CODE, par_TRANS_NS_CODE, '', par_TRANS_SYS_TDATETIME, par_TRANS_SYS_FDATETIME, par_TRANS_NS_CODE, to_char(par_TRANS_SYS_TDATETIME::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY'), par_TRANS_SYS_TDATETIME, par_FROM_TIME, par_TO_TIME
        FROM TEMP_TRANS_SUMMARY
        WHERE (CAST (temp_hh AS SMALLINT) <= date_part('hour', CAST (par_TRANS_SYS_TDATETIME AS TIMESTAMP WITHOUT TIME ZONE)::TIMESTAMP)) AND (CAST (temp_hh AS SMALLINT) >= date_part('hour', CAST (par_TRANS_SYS_FDATETIME AS TIMESTAMP WITHOUT TIME ZONE)::TIMESTAMP))
        ORDER BY temp_hh ASC NULLS FIRST;
    RETURN NEXT p_refcur;
END;
$function$
;



;ALTER FUNCTION "hasp_select_sum" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
