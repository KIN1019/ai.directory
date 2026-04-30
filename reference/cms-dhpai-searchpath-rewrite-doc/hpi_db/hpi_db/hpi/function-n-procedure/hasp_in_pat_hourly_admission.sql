CREATE OR REPLACE function hasp_in_pat_hourly_admission(IN par_hosp_code CHAR, IN par_from_date TIMESTAMP WITHOUT TIME ZONE, IN par_to_date TIMESTAMP WITHOUT TIME ZONE)
RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/*
- In Patient hourly admission report

    Parameters to be used :-
	     Description          Data Type
	--------------------	  -------------
	1. Hospital code          VARCHAR(3)
	2. From date              datetime
	3. To date                datetime
*/
DECLARE
    var_source_ind VARCHAR(2);
    var_source VARCHAR(6);
    var_adm_dt TIMESTAMP WITHOUT TIME ZONE;
    var_tx_dt TIMESTAMP WITHOUT TIME ZONE;
    var_i INTEGER;
    var_s_interval VARCHAR(40);
    var_hour INTEGER;
	p_refcur refcursor;
    cur1 CURSOR FOR
    SELECT
        Case_view.Admission_datetime, Case_view.Source_code, Case_view.Source_indicator, Transaction_log.Transaction_datetime
        FROM Case_view, Transaction_log
        WHERE (Case_view.Case_no = Transaction_log.Case_no) AND (Transaction_log.Transaction_type = '100') AND (Transaction_log.Transaction_datetime >= par_from_date) AND (Transaction_log.Transaction_datetime < par_to_date) AND (Cancel_flag IS NULL) AND (Case_view.Hospital_code = par_hosp_code) AND (Transaction_log.Hospital_code = par_hosp_code);
BEGIN
    SELECT
        1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
        INTO par_to_date;
    SELECT
        0
        INTO var_i;
	DROP TABLE IF EXISTS t$tx_table;
	CREATE TEMP TABLE t$tx_table (
		interval INTEGER default 0 null,
		s_interval VARCHAR(20) null,
		clin_adm INTEGER default 0 null,
		ae_adm INTEGER default 0 null,
		ae_adm_oth INTEGER default 0 null
	);

    WHILE (var_i < 24) LOOP
        var_s_interval := var_i || ':00 - ' ||  var_i || ':59';
        INSERT INTO t$tx_table
        VALUES (var_i, var_s_interval, 0, 0, 0);
        SELECT
            var_i + 1
            INTO var_i;
    END LOOP;
    SELECT
        'BACKDATED ADMISSIONS'
        INTO var_s_interval;
    INSERT INTO t$tx_table
    VALUES (var_i, var_s_interval, 0, 0, 0);
    /* changed by Karen at 1996-04-29 for cpi */
    /* before changes are comment for select from Case_view written below */
    /*
    declare CUR1 cursor for select
    Case.Admission_datetime, Case.Source_code, Case.Source_indicator,
    Transaction_log.Transaction_datetime
    from Case, Transaction_log
    where (Case.Case_no = Transaction_log.Case_no) and
    	(Transaction_log.Transaction_type = '100') and
    	(Transaction_log.Transaction_datetime >= @from_date) and
    	(Transaction_log.Transaction_datetime < @to_date) and
    	(Cancel_flag is null)
    */
    /* end of comment */
    /* modify start for select from Case_view */
    /* add hospital_code and index for HPI by ML on 31.07.1999 */
    /* end of modify */
    OPEN cur1;

    WHILE (1 = 1) LOOP
        FETCH cur1 INTO var_adm_dt, var_source, var_source_ind, var_tx_dt;

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
                    BEGIN
                        SELECT
                            date_part('hour', var_tx_dt::TIMESTAMP)
                            INTO var_hour;

                        IF var_source_ind = '3' THEN
                            IF var_source = par_hosp_code THEN
                                UPDATE t$tx_table
                                SET ae_adm = ae_adm + 1
                                    WHERE (interval = var_hour);
                            ELSE
                                UPDATE t$tx_table
                                SET ae_adm_oth = ae_adm_oth + 1
                                    WHERE (interval = var_hour);
                            END IF;
                        ELSE
                            UPDATE t$tx_table
                            SET clin_adm = clin_adm + 1
                                WHERE (interval = var_hour);
                        END IF;
                    END;
                END IF;
            END;
        ELSE
            EXIT;
        END IF;
    END LOOP;
    CLOSE cur1;
    OPEN p_refcur FOR
    SELECT
        s_interval, clin_adm, ae_adm, ae_adm_oth
        FROM t$tx_table
        ORDER BY interval NULLS FIRST;
    return next p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_in_pat_hourly_admission" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
