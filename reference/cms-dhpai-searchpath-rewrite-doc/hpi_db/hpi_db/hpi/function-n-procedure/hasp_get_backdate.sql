-- DROP FUNCTION hpi.hasp_get_backdate(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hpi.hasp_get_backdate(par_hosp_code character varying, par_from_date timestamp without time zone, par_to_date timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/* ---------------------------------------------------------------------------------------------- */
/* 20180105 to fix/avoid following error : remove SELECT * */

/* ---------------------------------------------------------------------------------------------- */
/* DBCC upgrade_object: Upgrading PROCEDURE dbo.hasp_get_backdate */
/* Warning: PROCEDURE hasp_get_backdate contains the SELECT * construct in the outermost */
/* SELECT query. */
/* Please verify that the table(s) referenced in the SELECT * have not */
/* been altered.  During upgrade the SELECT * is expanded to include all */
/* columns of the table(s). */
/* Run DBCC upgrade_object with the 'force' option to upgrade hasp_get_backdate. */
/* Msg 11031, Level 16, State 1: */
/* Server 'Fxxx_SB', Procedure 'hasp_get_backdate', Line 29: */
/* Execution of procedure hasp_get_backdate failed because of errors parsing the source text in syscomments during upgrade. Please drop and recreate dbo.hasp_get_backdate. */

/* ---------------------------------------------------------------------------------------------- */
DECLARE
    var_tx_date TIMESTAMP WITHOUT TIME ZONE;
    var_case VARCHAR(12);
    var_sys_date TIMESTAMP WITHOUT TIME ZONE;
    var_from_ward VARCHAR(4);
    var_from_spec VARCHAR(4);
    var_from_loc VARCHAR(4);
    var_from_bed VARCHAR(5);
    var_from_class VARCHAR(1);
    var_to_ward VARCHAR(4);
    var_to_spec VARCHAR(4);
    var_to_bed VARCHAR(5);
    var_to_class VARCHAR(1);
    var_to_loc VARCHAR(4);
    var_type VARCHAR(3);
    var_string VARCHAR(255);
    var_tx_desc VARCHAR(40);
    var_tx_sys_date VARCHAR(8);
    p_refcur refcursor;
    csr CURSOR FOR
    SELECT
        Transaction_datetime, Case_no, System_datetime, From_ward_code, From_specialty_code, From_treatment_location, From_bed, From_class, To_ward_code, To_specialty_code, To_treatment_location, To_bed, To_class, Transaction_type
        FROM Transaction_log
        WHERE System_datetime >= par_from_date AND System_datetime < par_to_date AND Transaction_datetime < - 3 * INTERVAL '1 month' + System_datetime::TIMESTAMP AND Transaction_type NOT LIKE '3%' AND Hospital_code = par_hosp_code;
    sql$rowcount BIGINT;
BEGIN
    SELECT
        1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
        INTO par_to_date;
    DROP TABLE IF EXISTS t$temp_tx_log;
    CREATE TEMPORARY TABLE t$temp_tx_log
    (tx_sys_date VARCHAR(8),
        tx_case VARCHAR(12),
        sys_date TIMESTAMP WITHOUT TIME ZONE NULL,
        tx_date TIMESTAMP WITHOUT TIME ZONE NULL,
        tx_desc VARCHAR(40) NULL,
        from_ward VARCHAR(4) NULL,
        from_spec VARCHAR(4) NULL,
        from_loc VARCHAR(4) NULL,
        from_bed VARCHAR(5) NULL,
        from_class VARCHAR(1) NULL,
        to_ward VARCHAR(4) NULL,
        to_spec VARCHAR(4) NULL,
        to_loc VARCHAR(4) NULL,
        to_bed VARCHAR(5) NULL,
        to_class VARCHAR(1) NULL);
    CREATE INDEX i$temp_tx_log_index ON t$temp_tx_log
        (tx_sys_date, tx_case);
    DROP TABLE IF EXISTS t$temp_tx_type;
    CREATE TEMPORARY TABLE t$temp_tx_type
    (tx_type VARCHAR(3),
        tx_desc VARCHAR(40));
    CREATE UNIQUE INDEX i$temp_tx_index ON t$temp_tx_type
        (tx_type);
    INSERT INTO t$temp_tx_type
    VALUES ('100', 'Inpatient Registration');
    INSERT INTO t$temp_tx_type
    VALUES ('121', 'Update Admission Registration');
    INSERT INTO t$temp_tx_type
    VALUES ('140', 'Transfer Out');
    INSERT INTO t$temp_tx_type
    VALUES ('700', 'Bed Assignment');
    INSERT INTO t$temp_tx_type
    VALUES ('130', 'Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('131', 'Discharge Death');
    INSERT INTO t$temp_tx_type
    VALUES ('132', 'Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('133', 'Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('134', 'Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('135', 'Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('136', 'Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('137', 'Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('138', 'Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('139', 'Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('13A', 'Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('160', 'Trial Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('170', 'Return From Trial Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('201', 'Cancellation of Admission');
    INSERT INTO t$temp_tx_type
    VALUES ('210', 'Cancellation of Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('211', 'Cancellation of Discharge Death');
    INSERT INTO t$temp_tx_type
    VALUES ('212', 'Cancellation of Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('213', 'Cancellation of Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('214', 'Cancellation of Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('215', 'Cancellation of Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('216', 'Cancellation of Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('217', 'Cancellation of Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('218', 'Cancellation of Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('219', 'Cancellation of Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('21A', 'Cancellation of Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('220', 'Cancellation of Transfer');
    INSERT INTO t$temp_tx_type
    VALUES ('230', 'Cancellation of TD');
    INSERT INTO t$temp_tx_type
    VALUES ('240', 'Cancellation of Return From TD');
    INSERT INTO t$temp_tx_type
    VALUES ('330', 'A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('331', 'A&E Discharge Death');
    INSERT INTO t$temp_tx_type
    VALUES ('332', 'A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('333', 'A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('334', 'A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('335', 'A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('336', 'A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('337', 'A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('338', 'A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('339', 'A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('33A', 'A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('350', 'Cancellation of A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('351', 'Cancellation of A&E Discharge Death');
    INSERT INTO t$temp_tx_type
    VALUES ('352', 'Cancellation of A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('353', 'Cancellation of A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('354', 'Cancellation of A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('355', 'Cancellation of A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('356', 'Cancellation of A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('357', 'Cancellation of A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('358', 'Cancellation of A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('359', 'Cancellation of A&E Discharge');
    INSERT INTO t$temp_tx_type
    VALUES ('35A', 'Cancellation of A&E Discharge');
    OPEN csr;
    FETCH csr INTO var_tx_date, var_case, var_sys_date, var_from_ward, var_from_spec, var_from_loc, var_from_bed, var_from_class, var_to_ward, var_to_spec, var_to_loc, var_to_bed, var_to_class, var_type;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            tx_desc
            INTO var_tx_desc
            FROM t$temp_tx_type
            WHERE tx_type = var_type;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 1 THEN
            BEGIN
                IF var_type <> '100' OR (var_type = '100' AND NOT EXISTS (SELECT
                    *
                    FROM Transaction_log
                    WHERE System_datetime = var_sys_date AND Hospital_code = par_hosp_code AND Case_no = var_case AND Transaction_type IN ('120', '121'))) THEN
                    BEGIN
                        IF var_type = '121' THEN
                            BEGIN
                                SELECT
                                    var_from_ward, var_from_spec, var_from_loc, var_from_bed, var_from_class
                                    INTO var_to_ward, var_to_spec, var_to_loc, var_to_bed, var_to_class;
                                if exists (SELECT 1 FROM Transaction_log
                                    WHERE System_datetime >= - 100 * INTERVAL '1 millisecond' + var_sys_date::TIMESTAMP
                                    AND System_datetime < 100 * INTERVAL '1 millisecond' + var_sys_date::TIMESTAMP
                                    AND Hospital_code = par_hosp_code
                                    AND Case_no = var_case
                                    AND Transaction_datetime = var_tx_date 
                                    AND Transaction_type = '120') then
	                                begin
		                                SELECT
	                                    From_ward_code, From_specialty_code, From_treatment_location, From_bed, From_class
	                                    INTO var_from_ward, var_from_spec, var_from_loc, var_from_bed, var_from_class
	                                    FROM Transaction_log
	                                    WHERE System_datetime >= - 100 * INTERVAL '1 millisecond' + var_sys_date::TIMESTAMP AND System_datetime < 100 * INTERVAL '1 millisecond' + var_sys_date::TIMESTAMP AND Hospital_code = par_hosp_code AND Case_no = var_case AND Transaction_datetime = var_tx_date AND Transaction_type = '120';
		                            end;
	                            end if;
                            END;
                        END IF;
                        SELECT
--                            aws_sapase_ext.conv_datetime_to_string('VARCHAR (8)'::TEXT, 'DATETIME'::TEXT, var_sys_date::TIMESTAMP WITHOUT TIME ZONE, 112)
                            to_char(var_sys_date, 'YYYYMMDD')
                            INTO var_tx_sys_date;
                        INSERT INTO t$temp_tx_log
                        VALUES (var_tx_sys_date, var_case, var_sys_date, var_tx_date, var_tx_desc, var_from_ward, var_from_spec, var_from_loc, var_from_bed, var_from_class, var_to_ward, var_to_spec, var_to_loc, var_to_bed, var_to_class);
                    END;
                END IF;
            END;
        END IF;
        FETCH csr INTO var_tx_date, var_case, var_sys_date, var_from_ward, var_from_spec, var_from_loc, var_from_bed, var_from_class, var_to_ward, var_to_spec, var_to_loc, var_to_bed, var_to_class, var_type;
    END LOOP;
    CLOSE csr;
    /* --select * from #temp_tx_log  --20180105 */
    OPEN p_refcur FOR
    SELECT
        tx_sys_date, tx_case, sys_date, tx_date, tx_desc, from_ward, from_spec, from_loc, from_bed, from_class, to_ward, to_spec, to_loc, to_bed, to_class
        FROM t$temp_tx_log order by tx_sys_date, tx_case;
    /* 20180105 -- */
    --DROP TABLE t$temp_tx_log;
    --DROP TABLE t$temp_tx_type;
    return next p_refcur;
    /*
    
    DROP TABLE IF EXISTS t$temp_tx_log;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$temp_tx_type;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;


;ALTER FUNCTION "hasp_get_backdate" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
