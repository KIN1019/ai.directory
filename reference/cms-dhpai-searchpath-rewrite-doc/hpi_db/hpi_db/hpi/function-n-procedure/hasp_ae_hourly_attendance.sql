CREATE OR REPLACE function hasp_ae_hourly_attendance(IN par_hosp_code CHAR, IN par_from_date TIMESTAMP WITHOUT TIME ZONE, IN par_to_date TIMESTAMP WITHOUT TIME ZONE)
RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/*
- A&E hourly attendance report

    Parameters to be used :-
	     Description          Data Type
	--------------------	  -------------
	1. Hospital Code          character
	2. From date              datetime
	3. To date                datetime
*/
DECLARE
    var_adm_dt TIMESTAMP WITHOUT TIME ZONE;
    var_tx_dt TIMESTAMP WITHOUT TIME ZONE;
    var_i INTEGER;
    var_tot_adm INTEGER;
    var_tot_att INTEGER;
    var_s_interval VARCHAR(20);
    var_hour INTEGER;
	p_refcur refcursor;
    cur1 CURSOR FOR
    SELECT
        Case_view.Admission_datetime, Transaction_log.Transaction_datetime
        FROM Case_view, Transaction_log
        WHERE (Case_view.Case_no = Transaction_log.Case_no) AND (Transaction_log.Transaction_type = '300') AND (Transaction_log.Transaction_datetime >= par_from_date) AND (Transaction_log.Transaction_datetime < par_to_date) AND (Cancel_flag IS NULL) AND (Transaction_log.Hospital_code = par_hosp_code) AND (Case_view.Hospital_code = par_hosp_code);
BEGIN
    /* create skeleton but insert no rows */
    SELECT
        1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
        INTO par_to_date;
	DROP TABLE IF EXISTS t$tx_table;
	CREATE TEMP TABLE t$tx_table (
		interval INTEGER default 0 null,
		s_interval VARCHAR(20) null,
		attendance INTEGER default 0 null,
		adm_rate NUMERIC(8, 4) DEFAULT 0.0
	);

    SELECT
        0, 0
        INTO var_i, var_tot_att;

    WHILE (var_i < 24) LOOP
        var_s_interval := LPAD(var_i::TEXT, 2, '0') || ':00 - ' || LPAD(var_i::TEXT, 2, '0') || ':59';
        INSERT INTO t$tx_table
        VALUES (var_i, var_s_interval, 0, 0.0);
        SELECT
            var_i + 1
            INTO var_i;
    END LOOP;
    SELECT
        'BACKDATED ADMISSIONS'
        INTO var_s_interval;
    INSERT INTO t$tx_table
    VALUES (var_i, var_s_interval, 0, 0.0);
    /* changed by Karen at 1996-04-29 for cpi */
    /* before changes are comment for select from Case_view */
    /*
    declare CUR1 cursor for select
    Case.Admission_datetime, Transaction_log.Transaction_datetime
    from Case, Transaction_log
    where (Case.Case_no = Transaction_log.Case_no) and
    	(Transaction_log.Transaction_type = '300') and
    	(Transaction_log.Transaction_datetime >= @from_date) and
    	(Transaction_log.Transaction_datetime < @to_date) and
    	(Cancel_flag is null)
    */
    /* end of comment */
    /* modify start for select from Case_view */
    /* -- Add hospital code for HPI by ML on 26.07.1999 --- */

    /* end of modify */
    OPEN cur1;

    WHILE (1 = 1) LOOP
        FETCH cur1 INTO var_adm_dt, var_tx_dt;

        IF (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 THEN
            BEGIN
                IF var_tx_dt <> var_adm_dt THEN
                    SELECT
                        25
                        INTO var_hour;
                ELSE
                    SELECT
                        date_part('hour', var_tx_dt::TIMESTAMP)
                        INTO var_hour;
                END IF;
                UPDATE t$tx_table
                SET attendance = attendance + 1
                    WHERE (interval = var_hour);
                SELECT
                    var_tot_att + 1
                    INTO var_tot_att;
            END;
        ELSE
            EXIT;
        END IF;
    END LOOP;
    CLOSE cur1;
    /* before changes are comment for select from Case_view */
    /*
    select @tot_adm = count(*) from Case, Transaction_log where
    Transaction_type = '100' and
    Transaction_datetime >= @from_date and
    Transaction_datetime < @to_date and
    Transaction_log.Case_no = Case.Case_no and
    Source_indicator = '3' and
    Cancel_flag is null and
    Source_code = @hosp_code
    */
    /* end of comment */
    /* modify start for select from Case_view */
    /* --- Add hospital code for HPI by Mabel on 26.07.1999 --- */
    SELECT
        COUNT(*)
        INTO var_tot_adm
        FROM Case_view, Transaction_log
        WHERE Transaction_type = '100' AND Transaction_datetime >= par_from_date AND Transaction_datetime < par_to_date AND Transaction_log.Case_no = Case_view.Case_no AND Case_view.Source_indicator = '3' AND Cancel_flag IS NULL AND Case_view.Source_code = par_hosp_code AND Transaction_log.Hospital_code = par_hosp_code AND Case_view.Hospital_code = par_hosp_code;
    /* end of modify */
    IF var_tot_att > 0 THEN
        UPDATE t$tx_table
        SET adm_rate = COALESCE(var_tot_adm, 0) / CAST (var_tot_att AS DOUBLE PRECISION);
    END IF;
    OPEN p_refcur FOR
    SELECT
        s_interval, attendance, adm_rate
        FROM t$tx_table
        ORDER BY interval NULLS FIRST;
    return next p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_ae_hourly_attendance" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
