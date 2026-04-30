CREATE OR REPLACE PROCEDURE hasp_get_case_key_changed(INOUT pas_return_code int, IN par_hosp_code VARCHAR, IN par_case_no VARCHAR, IN par_hkid VARCHAR, IN par_from_date TIMESTAMP WITHOUT TIME ZONE, IN par_to_date TIMESTAMP WITHOUT TIME ZONE, INOUT p_refcur refcursor)
AS 
$BODY$
/* ---------------------------------------------------------------------------------------------- */
/* 20180105 to fix/avoid following error : remove SELECT * */

/* ---------------------------------------------------------------------------------------------- */
/* DBCC upgrade_object: Upgrading PROCEDURE dbo.hasp_get_case_key_changed */
/* Warning: PROCEDURE hasp_get_case_key_changed contains the SELECT * construct in the outermost */
/* SELECT query. */
/* Please verify that the table(s) referenced in the SELECT * have not */
/* been altered.  During upgrade the SELECT * is expanded to include all */
/* columns of the table(s). */
/* Run DBCC upgrade_object with the 'force' option to upgrade hasp_get_case_key_changed. */
/* Warning: PROCEDURE hasp_get_case_key_changed contains the SELECT * construct in the outermost */
/* SELECT query. */
/* Please verify that the table(s) referenced in the SELECT * have not */
/* been altered.  During upgrade the SELECT * is expanded to include all */
/* columns of the table(s). */
/* Run DBCC upgrade_object with the 'force' option to upgrade hasp_get_case_key_changed. */
/* Msg 11031, Level 16, State 1: */
/* Server 'xxx', Procedure 'hasp_get_case_key_changed', Line 33: */
/* Execution of procedure hasp_get_case_key_changed failed because of errors parsing the source text in syscomments during upgrade. Please drop and recreate dbo.hasp_get_case_key_changed. */

/* ---------------------------------------------------------------------------------------------- */
DECLARE
    var_temp_case_no VARCHAR(24);
    var_system_dt TIMESTAMP WITHOUT TIME ZONE;
    var_temp_count INTEGER;
    var_rowcount INTEGER;
    get_case_key_changed_csr_0 CURSOR FOR
    SELECT DISTINCT
        Case_no
        FROM Case_key_changed
        WHERE Old_HKID = par_hkid AND Hospital_code = par_hosp_code;
    get_case_key_changed_csr CURSOR FOR
    SELECT
        Case_no, COUNT(*)
        FROM Case_key_changed
        WHERE Hospital_code = par_hosp_code AND System_datetime >= par_from_date AND System_datetime <= par_to_date
        GROUP BY Case_no;
    sql$rowcount BIGINT;
BEGIN
    DROP TABLE IF EXISTS t$case_key_hkid;
    DROP TABLE IF EXISTS t$case_key_date;
    IF (par_case_no IS NOT NULL) THEN
        BEGIN
            /* case_no as parameter */
            /* add hosp code for HPI by ML on 30.07.1999 */
            /* --select Case_no, System_datetime, Old_HKID, User_ID */
            OPEN p_refcur FOR
            SELECT
                Case_no, System_datetime, Old_HKID, User_ID
                FROM Case_key_changed
                WHERE Case_no = par_case_no AND Hospital_code = par_hosp_code;
        END;
    ELSE
        IF (par_hkid IS NOT NULL) THEN
            BEGIN
                /* hkid as parameter */
                /* --select * from Case_key_changed */
                CREATE TEMPORARY TABLE t$case_key_hkid
                AS
                SELECT
                    Case_no, System_datetime, Old_HKID, User_ID
                    FROM Case_key_changed
                    WHERE 1 != 1;
                /* add hosp code for HPI by ML on 30.07.1999 */
                OPEN get_case_key_changed_csr_0;
                FETCH get_case_key_changed_csr_0 INTO var_temp_case_no;

                WHILE (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) = 0 LOOP
                    /* add hosp code for HPI by ML on 30.07.1999 */
                    INSERT INTO t$case_key_hkid
                    SELECT
                        Case_no, System_datetime, Old_HKID, User_ID
                        FROM Case_key_changed
                        WHERE Case_no = var_temp_case_no AND Hospital_code = par_hosp_code;
                    FETCH get_case_key_changed_csr_0 INTO var_temp_case_no;
                END LOOP;
                /* --select * from #case_key_hkid  -- 20180105 */
                OPEN p_refcur FOR
                SELECT
                    Case_no, System_datetime, Old_HKID, user_id
                    FROM t$case_key_hkid;
                -- DROP TABLE t$case_key_hkid;
                CLOSE get_case_key_changed_csr_0;
            END;
        ELSE
            IF (par_from_date IS NOT NULL AND par_to_date IS NOT NULL) THEN
                BEGIN
                    /* date as parameter */
                    /* modified for HPI by ML on 30.07.1999 */
                    /* --select * into #case_key_date */
                    CREATE TEMPORARY TABLE t$case_key_date
                    AS
                    SELECT
                        Case_no, System_datetime, Old_HKID, User_ID
                        FROM Case_key_changed
                        WHERE 1 != 1;
                    /* add hosp code for HPI by ML on 30.07.1999 */
                    OPEN get_case_key_changed_csr;
                    FETCH get_case_key_changed_csr INTO var_temp_case_no, var_temp_count;

                    WHILE (CASE
                        WHEN FOUND THEN 0
                        WHEN NOT FOUND THEN 2
                        ELSE 1
                    END) = 0 LOOP
                        /*
                        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
                        set rowcount 1
                        */
                        /* add hosp code for HPI by ML on 30.07.1999 */
                        SELECT
                            System_datetime
                            INTO var_system_dt
                            FROM Case_key_changed
                            WHERE Hospital_code = par_hosp_code AND Case_no = var_temp_case_no AND System_datetime < par_from_date
                            ORDER BY System_datetime DESC NULLS FIRST;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;
                        /*
                        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
                        set rowcount 0
                        */
                        IF var_rowcount > 0 THEN
                            BEGIN
                                INSERT INTO t$case_key_date
                                /* add hosp code for HPI by ML on 30.07.1999 */
                                SELECT
                                    Case_no, System_datetime, Old_HKID, User_ID
                                    FROM Case_key_changed
                                    WHERE Hospital_code = par_hosp_code AND Case_no = var_temp_case_no AND System_datetime >= var_system_dt AND System_datetime <= par_to_date;
                            END;
                        ELSE
                            BEGIN
                                IF var_temp_count > 1 THEN
                                    BEGIN
                                        /* add hosp code for HPI by ML on 30.07.1999 */
                                        INSERT INTO t$case_key_date
                                        SELECT
                                            Case_no, System_datetime, Old_HKID, User_ID
                                            FROM Case_key_changed
                                            WHERE Hospital_code = par_hosp_code AND Case_no = var_temp_case_no AND System_datetime >= par_from_date AND System_datetime <= par_to_date;
                                    END;
                                END IF;
                            END;
                        END IF;
                        FETCH get_case_key_changed_csr INTO var_temp_case_no, var_temp_count;
                    END LOOP;
                    /* select * from #case_key_date --20180105 */
                    OPEN p_refcur FOR
                    SELECT
                        Case_no, System_datetime, Old_HKID, user_id
                        FROM t$case_key_date;
                    -- DROP TABLE t$case_key_date;
                    CLOSE get_case_key_changed_csr;
                END;
            ELSE
                BEGIN
                    pas_return_code := 99;
                    RETURN;
                END;
            END IF;
        END IF;
    END IF;
    /*
    
    DROP TABLE IF EXISTS t$case_key_hkid;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$case_key_date;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$BODY$
LANGUAGE plpgsql;