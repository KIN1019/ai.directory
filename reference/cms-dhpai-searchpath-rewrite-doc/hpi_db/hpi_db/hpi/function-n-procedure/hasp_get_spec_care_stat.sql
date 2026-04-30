-- DROP FUNCTION hpi.hasp_get_spec_care_stat(bpchar, timestamp, timestamp, bpchar, bpchar);

CREATE OR REPLACE FUNCTION hpi.hasp_get_spec_care_stat(par_hosp_code character, par_from_date timestamp without time zone, par_to_date timestamp without time zone, par_input_spec_list character, par_input_care_list character)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
p_refcur refcursor;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_errarg VARCHAR(80);
    var_local_server VARCHAR(48);
    var_report_server VARCHAR(48);
    var_prog_name VARCHAR(80);
    var_db_name VARCHAR(48);
    var_hospital VARCHAR(3);
    var_dblink_sql text;
    sql$rowcount BIGINT;
    var_retcode INTEGER;
BEGIN
    /*
    [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@SERVERNAME function. Use suitable function or create user defined function.]
    select @local_server = @@servername
    */

SELECT
    'hasp_get_spec_care_stat_report'
INTO var_prog_name;
SELECT
    Text_value
INTO var_report_server
FROM Hospital_control
WHERE Type = 'REPORT_SERVER_NAME';
GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

IF sql$rowcount <> 1 THEN
SELECT
    NULL
INTO var_report_server;
END IF;
    /* ---if @local_server <> @report_server */
    IF var_report_server IS NOT NULL then
SELECT
    Hospital_code
INTO var_hospital
FROM Hospital;
SELECT RTRIM(LOWER(var_hospital)) || 'hpi_db' INTO var_db_name;
SELECT
        RTRIM(var_report_server) || '.' || RTRIM(var_db_name) || '..' || RTRIM(var_prog_name)
INTO var_prog_name;
IF var_prog_name IS NULL THEN
    RAISE EXCEPTION 'var_prog_name is NULL, cannot proceed with EXECUTE';
END IF;
var_dblink_sql := 'select * from ' || var_prog_name || '('
		        || quote_literal(par_hosp_code) || ','
		        || quote_literal(par_from_date) || ','
		        || quote_literal(par_to_date) || ','
		        || quote_literal(par_input_spec_list) || ','
		        || quote_literal(par_input_care_list) || ')';

		    PERFORM public.dblink_connect('remote_server', var_report_server);
		    RAISE NOTICE 'Executing dblink: %', var_dblink_sql;

BEGIN
SELECT * FROM public.dblink('remote_server', var_dblink_sql)
                  AS result(var_retcode INT) INTO var_retcode;

IF var_retcode <> 0 THEN
	            RAISE EXCEPTION 'Error in remote call, code: %', var_retcode;
END IF;

	        PERFORM public.dblink_disconnect('remote_server');
EXCEPTION
	        WHEN OTHERS THEN
	            RAISE NOTICE 'Error occurred during dblink execution: %', SQLERRM;
	            PERFORM public.dblink_disconnect('remote_server');
	            RAISE;
END;
else
		RAISE NOTICE 'No report server available, executing local procedure.';
		RAISE NOTICE 'var_prog_name: %', var_prog_name;
		RAISE NOTICE 'par_hosp_code: %', par_hosp_code;
		RAISE NOTICE 'par_from_date: %', par_from_date;
		RAISE NOTICE 'par_to_date: %', par_to_date;
		RAISE NOTICE 'par_input_spec_list: %', par_input_spec_list;
		RAISE NOTICE 'par_input_care_list: %', par_input_care_list;

		EXECUTE format('SELECT * FROM %I(%L, %L, %L, %L, %L)',
			var_prog_name,
			par_hosp_code,
			par_from_date,
			par_to_date,
			par_input_spec_list,
			par_input_care_list)
		INTO p_refcur;
    return next p_refcur;
END IF;
    /*
    [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
    exec @prog_name @hosp_code,@from_date,@to_date,@input_spec_list,@input_care_list
    */
END;
$function$
;

;ALTER FUNCTION "hasp_get_spec_care_stat" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
