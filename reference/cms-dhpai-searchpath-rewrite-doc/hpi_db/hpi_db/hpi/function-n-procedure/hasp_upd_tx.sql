-- DROP FUNCTION hpi.hasp_upd_tx(varchar, timestamp, timestamp, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_upd_tx(par_hosp_code character varying, par_input_from_datetime timestamp without time zone, par_input_to_datetime timestamp without time zone, par_input_trans_type character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/* add hosp code for HPI by ML on 04.08.1999 */
/* ------------------------------------------------------------------------------------------------ */
/* ---- 20180105 to fix/avoid following error : remove SELECT * */

/* ------------------------------------------------------------------------------------------------ */
/* DBCC upgrade_object: Upgrading PROCEDURE dbo.hasp_upd_tx */
/* Warning: PROCEDURE hasp_upd_tx contains the SELECT * construct in the outermost */
/* SELECT query. */
/* Please verify that the table(s) referenced in the SELECT * have not */
/* been altered.  During upgrade the SELECT * is expanded to include all */
/* columns of the table(s). */
/* Run DBCC upgrade_object with the 'force' option to upgrade hasp_upd_tx. */
/* Warning: PROCEDURE hasp_upd_tx contains the SELECT * construct in the outermost */
/* SELECT query. */
/* Please verify that the table(s) referenced in the SELECT * have not */
/* been altered.  During upgrade the SELECT * is expanded to include all */
/* columns of the table(s). */
/* Run DBCC upgrade_object with the 'force' option to upgrade hasp_upd_tx. */
/* Msg 11031, Level 16, State 1: */
/* Server 'xxx', Procedure 'hasp_upd_tx', Line 343: */
/* Execution of procedure hasp_upd_tx failed because of errors parsing the source text in syscomments during upgrade. Please drop and recreate dbo.hasp_upd_tx. */

/* ------------------------------------------------------------------------------------------------ */
DECLARE
    var_processing_date TIMESTAMP WITHOUT TIME ZONE;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_errarg VARCHAR(80);
    var_updated_flag VARCHAR(1);
    var_tran_sys_date TIMESTAMP WITHOUT TIME ZONE;
    var_tran_type VARCHAR(3);
    var_case_no VARCHAR(12);
    var_from_ward VARCHAR(4);
    var_from_spec VARCHAR(4);
    var_from_loc VARCHAR(4);
    var_to_ward VARCHAR(4);
    var_to_spec VARCHAR(4);
    var_to_loc VARCHAR(4);
    var_tran_date TIMESTAMP WITHOUT TIME ZONE;
    var_post_date TIMESTAMP WITHOUT TIME ZONE;
    var_post_flag VARCHAR(1);
    var_system_date TIMESTAMP WITHOUT TIME ZONE;
    var_temp_ae_adm SMALLINT;
    var_temp_ae_day SMALLINT;
    var_temp_tx_within_ward SMALLINT;
    var_temp_tx_within_spec SMALLINT;
    var_temp_adm_src VARCHAR(1);
    var_temp_day_dsch SMALLINT;
    var_temp_adm_dt TIMESTAMP WITHOUT TIME ZONE;
    var_adjustment SMALLINT;
    var_date TIMESTAMP WITHOUT TIME ZONE;
    var_ward VARCHAR(4);
    var_spec VARCHAR(4);
    var_loc VARCHAR(4);
    var_prev_date TIMESTAMP WITHOUT TIME ZONE;
    var_prev_remain SMALLINT;
    var_prev_adm SMALLINT;
    var_prev_canc_adm SMALLINT;
    var_prev_txin SMALLINT;
    var_prev_canc_txin SMALLINT;
    var_prev_txout SMALLINT;
    var_prev_canc_txout SMALLINT;
    var_prev_tx_within_spec SMALLINT;
    var_prev_canc_tx_within_spec SMALLINT;
    var_prev_tx_within_ward SMALLINT;
    var_prev_canc_tx_within_ward SMALLINT;
    var_prev_td_txin SMALLINT;
    var_prev_canc_td_txin SMALLINT;
    var_prev_td_txout SMALLINT;
    var_prev_canc_td_txout SMALLINT;
    var_prev_ae_adm SMALLINT;
    var_prev_canc_ae_adm SMALLINT;
    var_prev_dsch SMALLINT;
    var_prev_canc_dsch SMALLINT;
    var_prev_deth SMALLINT;
    var_prev_canc_deth SMALLINT;
    var_prev_ae_day_dsch SMALLINT;
    var_prev_canc_ae_day_dsch SMALLINT;
    var_prev_ae_day_deth SMALLINT;
    var_prev_canc_ae_day_deth SMALLINT;
    var_prev_day_dsch SMALLINT;
    var_prev_canc_day_dsch SMALLINT;
    var_prev_day_deth SMALLINT;
    var_prev_canc_day_deth SMALLINT;
    var_ttl_canc SMALLINT;
    var_remain SMALLINT;
    var_adm SMALLINT;
    var_canc_adm SMALLINT;
    var_txin SMALLINT;
    var_canc_txin SMALLINT;
    var_txout SMALLINT;
    var_canc_txout SMALLINT;
    var_tx_within_spec SMALLINT;
    var_canc_tx_within_spec SMALLINT;
    var_tx_within_ward SMALLINT;
    var_canc_tx_within_ward SMALLINT;
    var_td_txin SMALLINT;
    var_canc_td_txin SMALLINT;
    var_td_txout SMALLINT;
    var_canc_td_txout SMALLINT;
    var_ae_adm SMALLINT;
    var_canc_ae_adm SMALLINT;
    var_dsch SMALLINT;
    var_canc_dsch SMALLINT;
    var_deth SMALLINT;
    var_canc_deth SMALLINT;
    var_ae_day_dsch SMALLINT;
    var_canc_ae_day_dsch SMALLINT;
    var_ae_day_deth SMALLINT;
    var_canc_ae_day_deth SMALLINT;
    var_day_dsch SMALLINT;
    var_canc_day_dsch SMALLINT;
    var_day_deth SMALLINT;
    var_canc_day_deth SMALLINT;
    sql$rowcount BIGINT;
    p_refcur refcursor;

-- par_input_trans_type = 'R'
    trans_log_csr1 CURSOR FOR
    SELECT
        System_datetime, Transaction_type, Case_no, From_ward_code, From_specialty_code, From_treatment_location, To_ward_code, To_specialty_code, To_treatment_location, Transaction_datetime, Post_datetime, Post_flag
        FROM Transaction_log
        WHERE Transaction_datetime >= var_processing_date AND Transaction_datetime < 1 * INTERVAL '1 day' + var_processing_date::TIMESTAMP AND From_ward_code != 'AE01' AND Hospital_code = par_hosp_code::VARCHAR;

    trans_log_csr2 CURSOR FOR
    SELECT
        System_datetime, Transaction_type, Case_no, From_ward_code, From_specialty_code, From_treatment_location, To_ward_code, To_specialty_code, To_treatment_location, Transaction_datetime, Post_datetime, Post_flag
        FROM Transaction_log
        WHERE Transaction_datetime >= var_processing_date AND Transaction_datetime < 1 * INTERVAL '1 day' + var_processing_date::TIMESTAMP AND From_ward_code != 'AE01' AND Hospital_code = par_hosp_code::VARCHAR AND Post_datetime IS NULL;

    stat_csr CURSOR FOR
    SELECT
        stat_date, stat_ward, stat_spec, stat_loc, stat_adm, stat_txin, stat_txout, stat_dsch, stat_deth, stat_tx_within_spec, stat_tx_within_ward, stat_td_txin, stat_td_txout, stat_ae_adm, stat_ae_day_dsch, stat_ae_day_deth, stat_day_dsch, stat_day_deth, stat_canc_adm, stat_canc_txin, stat_canc_txout, stat_canc_dsch, stat_canc_deth, stat_canc_tx_within_spec, stat_canc_tx_within_ward, stat_canc_td_txin, stat_canc_td_txout, stat_canc_ae_adm, stat_canc_ae_day_dsch, stat_canc_ae_day_deth, stat_canc_day_dsch, stat_canc_day_deth
        FROM t$stat_table
        ORDER BY stat_date NULLS FIRST;

BEGIN
    <<normal_exit>>
    BEGIN
        /*
        parameter name          Description
        @input_from_datetime    Report start date to be processed
        @input_to_datetime      Report end date to be processed
        @input_trans_type       'R' regenerate for all transactions
                                'D' generate for un-posted transactions only
        04.08.1999 - Add hospital code for HPI by Mabel Lau
        */
        /* declare temporary variables */
        /* create temp table */
        --RAISE notice '[hasp_upd_tx] par_input_from_datetime=%',par_input_from_datetime;
        DROP TABLE IF EXISTS t$stat_table;
        CREATE TEMPORARY TABLE t$stat_table
        (stat_date TIMESTAMP WITHOUT TIME ZONE,
            stat_ward VARCHAR(4),
            stat_spec VARCHAR(4),
            stat_loc VARCHAR(4) NULL,
            stat_adm SMALLINT NULL,
            stat_txin SMALLINT NULL,
            stat_txout SMALLINT NULL,
            stat_dsch SMALLINT NULL,
            stat_deth SMALLINT NULL,
            stat_tx_within_spec SMALLINT NULL,
            stat_tx_within_ward SMALLINT NULL,
            stat_td_txin SMALLINT NULL,
            stat_td_txout SMALLINT NULL,
            stat_ae_adm SMALLINT NULL,
            stat_ae_day_dsch SMALLINT NULL,
            stat_ae_day_deth SMALLINT NULL,
            stat_day_dsch SMALLINT NULL,
            stat_day_deth SMALLINT NULL,
            stat_canc_adm SMALLINT NULL,
            stat_canc_txin SMALLINT NULL,
            stat_canc_txout SMALLINT NULL,
            stat_canc_dsch SMALLINT NULL,
            stat_canc_deth SMALLINT NULL,
            stat_canc_tx_within_spec SMALLINT NULL,
            stat_canc_tx_within_ward SMALLINT NULL,
            stat_canc_td_txin SMALLINT NULL,
            stat_canc_td_txout SMALLINT NULL,
            stat_canc_ae_adm SMALLINT NULL,
            stat_canc_ae_day_dsch SMALLINT NULL,
            stat_canc_ae_day_deth SMALLINT NULL,
            stat_canc_day_dsch SMALLINT NULL,
            stat_canc_day_deth SMALLINT NULL);
        DROP TABLE IF EXISTS t$dsp_table;
        CREATE TEMPORARY TABLE t$dsp_table
        (dsp_date TIMESTAMP WITHOUT TIME ZONE,
            dsp_ward VARCHAR(4),
            dsp_spec VARCHAR(4),
            dsp_loc VARCHAR(4) NULL,
            dsp_adm SMALLINT NULL,
            dsp_txin SMALLINT NULL,
            dsp_txout SMALLINT NULL,
            dsp_dsch SMALLINT NULL,
            dsp_deth SMALLINT NULL,
            dsp_tx_within_spec SMALLINT NULL,
            dsp_tx_within_ward SMALLINT NULL,
            dsp_td_txin SMALLINT NULL,
            dsp_td_txout SMALLINT NULL,
            dsp_ae_adm SMALLINT NULL,
            dsp_ae_day_dsch SMALLINT NULL,
            dsp_ae_day_deth SMALLINT NULL,
            dsp_day_dsch SMALLINT NULL,
            dsp_day_deth SMALLINT NULL,
            dsp_canc_adm SMALLINT NULL,
            dsp_canc_txin SMALLINT NULL,
            dsp_canc_txout SMALLINT NULL,
            dsp_canc_dsch SMALLINT NULL,
            dsp_canc_deth SMALLINT NULL,
            dsp_canc_tx_within_spec SMALLINT NULL,
            dsp_canc_tx_within_ward SMALLINT NULL,
            dsp_canc_td_txin SMALLINT NULL,
            dsp_canc_td_txout SMALLINT NULL,
            dsp_canc_ae_adm SMALLINT NULL,
            dsp_canc_ae_day_dsch SMALLINT NULL,
            dsp_canc_ae_day_deth SMALLINT NULL,
            dsp_canc_day_dsch SMALLINT NULL,
            dsp_canc_day_deth SMALLINT NULL);
        SELECT
            par_input_from_datetime
            INTO var_processing_date;

        WHILE var_processing_date <= par_input_to_datetime LOOP
            /*
            [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
            begin tran
            */
            SELECT
                timestamp_convert(localtimestamp)
                INTO var_system_date;
            /*
            if regenerate whole day transactions then
                 declare cursor for all transactions
            else
                 declare cursor for un-posted transcations only
            */
            IF par_input_trans_type <> 'D' THEN
                SELECT
                    'D'
                    INTO par_input_trans_type;
            END IF;

            --RAISE notice '[hasp_upd_tx] par_input_trans_type=%',par_input_trans_type;
            /* loop for transactions */
            IF par_input_trans_type = 'R' THEN
                OPEN trans_log_csr1;
                FETCH trans_log_csr1 INTO var_tran_sys_date, var_tran_type, var_case_no, var_from_ward, var_from_spec, var_from_loc, var_to_ward, var_to_spec, var_to_loc, var_tran_date, var_post_date, var_post_flag;
            ELSE
                OPEN trans_log_csr2;
                FETCH trans_log_csr2 INTO var_tran_sys_date, var_tran_type, var_case_no, var_from_ward, var_from_spec, var_from_loc, var_to_ward, var_to_spec, var_to_loc, var_tran_date, var_post_date, var_post_flag;
            END IF;

            WHILE (SELECT
                (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END)) = 0 LOOP
                /*
                print 'processing case %1!, tran type %2!, trans datetime %3!',
                @case_no, @tran_type, @tran_date
                */
                SELECT
                    'n'
                    INTO var_updated_flag;
                /* Admission */
                IF var_tran_type = '100' THEN
                    BEGIN
                        SELECT
                            'y'
                            INTO var_updated_flag;
                        SELECT
                            Source_indicator
                            INTO var_temp_adm_src
                            FROM Event_log
                            WHERE System_datetime = var_tran_sys_date AND Case_no = var_case_no AND Type = var_tran_type AND Hospital_code = par_hosp_code;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF sql$rowcount = 0 THEN
                            BEGIN
                                SELECT
                                    Source_indicator
                                    INTO var_temp_adm_src
                                    FROM Event_log
                                    WHERE System_datetime > - 15 * INTERVAL '1 second' + var_tran_sys_date::TIMESTAMP AND System_datetime < 15 * INTERVAL '1 second' + var_tran_sys_date::TIMESTAMP AND Case_no = var_case_no::VARCHAR AND Type = '121' AND Hospital_code = par_hosp_code::VARCHAR;
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                IF sql$rowcount = 0 THEN
                                    SELECT
                                        Source_indicator
                                        INTO var_temp_adm_src
                                        /*
                                        script before CPI update
                                                                                from Case
                                        updated by man at may 96
                                        */
                                        FROM Case_view
                                        WHERE Case_no = var_case_no AND Hospital_code = par_hosp_code;
                                END IF;
                            END;
                        END IF;

                        IF var_temp_adm_src = '3' THEN
                            SELECT
                                1
                                INTO var_temp_ae_adm;
                        ELSE
                            SELECT
                                0
                                INTO var_temp_ae_adm;
                        END IF;

                        IF EXISTS (SELECT
                            *
                            FROM t$stat_table
                            WHERE DATE_PART('days', var_tran_date::TIMESTAMP-stat_date::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                            UPDATE t$stat_table
                            SET stat_adm = stat_adm + 1, stat_ae_adm = stat_ae_adm + var_temp_ae_adm
                                WHERE DATE_PART('days', var_tran_date::TIMESTAMP-stat_date::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                        ELSE
                            INSERT INTO t$stat_table
                            VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 1, 0, 0, 0, 0, 0, 0, 0, 0, var_temp_ae_adm, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                        END IF;
                    END;
                END IF;
                /* Transfer in */
                IF var_tran_type = '141' THEN
                    BEGIN
                        SELECT
                            'y'
                            INTO var_updated_flag;

                        IF var_from_ward = var_to_ward THEN
                            SELECT
                                1
                                INTO var_temp_tx_within_ward;
                        ELSE
                            SELECT
                                0
                                INTO var_temp_tx_within_ward;
                        END IF;

                        IF var_from_spec = var_to_spec AND COALESCE(var_from_loc, 'null') = COALESCE(var_to_loc, 'null') THEN
                            SELECT
                                1
                                INTO var_temp_tx_within_spec;
                        ELSE
                            SELECT
                                0
                                INTO var_temp_tx_within_spec;
                        END IF;

                        IF EXISTS (SELECT
                            *
                            FROM t$stat_table
                            WHERE DATE_PART('days', var_tran_date::TIMESTAMP-stat_date::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                            UPDATE t$stat_table
                            SET stat_txin = stat_txin + 1, stat_tx_within_spec = stat_tx_within_spec + var_temp_tx_within_spec, stat_tx_within_ward = stat_tx_within_ward + var_temp_tx_within_ward
                                WHERE DATE_PART('days', var_tran_date::TIMESTAMP-stat_date::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                        ELSE
                            INSERT INTO t$stat_table
                            VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 1, 0, 0, 0, var_temp_tx_within_spec, var_temp_tx_within_ward, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                        END IF;
                    END;
                END IF;
                /* Transfer out */
                IF var_tran_type = '140' THEN
                    BEGIN
                        SELECT
                            'y'
                            INTO var_updated_flag;

                        IF var_from_ward = var_to_ward THEN
                            SELECT
                                1
                                INTO var_temp_tx_within_ward;
                        ELSE
                            SELECT
                                0
                                INTO var_temp_tx_within_ward;
                        END IF;

                        IF var_from_spec = var_to_spec AND COALESCE(var_from_loc, 'null') = COALESCE(var_to_loc, 'null') THEN
                            SELECT
                                1
                                INTO var_temp_tx_within_spec;
                        ELSE
                            SELECT
                                0
                                INTO var_temp_tx_within_spec;
                        END IF;

                        IF EXISTS (SELECT
                            *
                            FROM t$stat_table
                            WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                            UPDATE t$stat_table
                            SET stat_txout = stat_txout + 1, stat_tx_within_spec = stat_tx_within_spec + var_temp_tx_within_spec, stat_tx_within_ward = stat_tx_within_ward + var_temp_tx_within_ward
                                WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                        ELSE
                            INSERT INTO t$stat_table
                            VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 1, 0, 0, var_temp_tx_within_spec, var_temp_tx_within_ward, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                        END IF;
                    END;
                END IF;
                /* Discharge */
                IF var_tran_type LIKE '13_' AND var_tran_type != '131' THEN
                    BEGIN
                        SELECT
                            'y'
                            INTO var_updated_flag;
                        SELECT
                            Source_indicator, Admission_datetime
                            INTO var_temp_adm_src, var_temp_adm_dt
                            FROM Event_log
                            WHERE System_datetime = var_tran_sys_date AND Case_no = var_case_no AND Type = var_tran_type AND Hospital_code = par_hosp_code;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF sql$rowcount = 0 THEN
                            SELECT
                                Source_indicator, Admission_datetime
                                INTO var_temp_adm_src, var_temp_adm_dt
                                /*
                                script before CPI update
                                                                from Case
                                updated by man at may 96
                                */
                                FROM Case_view
                                WHERE Case_no = var_case_no AND Hospital_code = par_hosp_code;
                        END IF;

                        IF DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - var_temp_adm_dt::TIMESTAMP::TIMESTAMP) = 0 THEN
                            BEGIN
                                IF var_temp_adm_src = '3' THEN
                                    BEGIN
                                        SELECT
                                            1
                                            INTO var_temp_ae_day;
                                        SELECT
                                            0
                                            INTO var_temp_day_dsch;
                                    END;
                                ELSE
                                    BEGIN
                                        SELECT
                                            0
                                            INTO var_temp_ae_day;
                                        SELECT
                                            1
                                            INTO var_temp_day_dsch;
                                    END;
                                END IF;
                            END;
                        ELSE
                            BEGIN
                                SELECT
                                    0
                                    INTO var_temp_ae_day;
                                SELECT
                                    0
                                    INTO var_temp_day_dsch;
                            END;
                        END IF;

                        IF EXISTS (SELECT
                            *
                            FROM t$stat_table
                            WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                            UPDATE t$stat_table
                            SET stat_dsch = stat_dsch + 1, stat_day_dsch = stat_day_dsch + var_temp_day_dsch, stat_ae_day_dsch = stat_ae_day_dsch + var_temp_ae_day
                                WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                        ELSE
                            INSERT INTO t$stat_table
                            VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, var_temp_ae_day, 0, var_temp_day_dsch, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                        END IF;
                    END;
                END IF;
                /* Death */
                IF var_tran_type = '131' THEN
                    BEGIN
                        SELECT
                            'y'
                            INTO var_updated_flag;
                        SELECT
                            Source_indicator, Admission_datetime
                            INTO var_temp_adm_src, var_temp_adm_dt
                            FROM Event_log
                            WHERE System_datetime = var_tran_sys_date AND Case_no = var_case_no AND Type = var_tran_type AND Hospital_code = par_hosp_code;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF sql$rowcount = 0 THEN
                            SELECT
                                Source_indicator, Admission_datetime
                                INTO var_temp_adm_src, var_temp_adm_dt
                                /*
                                script before CPI update
                                                                from Case
                                updated by man at may 96
                                */
                                FROM Case_view
                                WHERE Case_no = var_case_no AND Hospital_code = par_hosp_code;
                        END IF;

                        IF DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - var_temp_adm_dt::TIMESTAMP::TIMESTAMP) = 0 THEN
                            BEGIN
                                IF var_temp_adm_src = '3' THEN
                                    BEGIN
                                        SELECT
                                            1
                                            INTO var_temp_ae_day;
                                        SELECT
                                            0
                                            INTO var_temp_day_dsch;
                                    END;
                                ELSE
                                    BEGIN
                                        SELECT
                                            0
                                            INTO var_temp_ae_day;
                                        SELECT
                                            1
                                            INTO var_temp_day_dsch;
                                    END;
                                END IF; 
                            END;
                        ELSE
                            BEGIN
                                SELECT
                                    0
                                    INTO var_temp_ae_day;
                                SELECT
                                    0
                                    INTO var_temp_day_dsch;
                            END;
                        END IF;

                        IF EXISTS (SELECT
                            *
                            FROM t$stat_table
                            WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP -stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                            UPDATE t$stat_table
                            SET stat_deth = stat_deth + 1, stat_ae_day_deth = stat_ae_day_deth + var_temp_ae_day, stat_day_deth = stat_day_deth + var_temp_day_dsch
                                WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP-stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                        ELSE
                            INSERT INTO t$stat_table
                            VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, var_temp_ae_day, 0, var_temp_day_dsch, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                        END IF;
                    END;
                END IF;

                IF var_tran_type = '160' THEN
                    BEGIN
                        SELECT
                            'y'
                            INTO var_updated_flag;

                        IF EXISTS (SELECT
                            *
                            FROM t$stat_table
                            WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP -stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                            UPDATE t$stat_table
                            SET stat_td_txout = stat_td_txout + 1
                                WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP -stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                        ELSE
                            INSERT INTO t$stat_table
                            VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                        END IF;
                    END;
                END IF;

                IF var_tran_type = '161' THEN
                    BEGIN
                        SELECT
                            'y'
                            INTO var_updated_flag;

                        IF EXISTS (SELECT
                            *
                            FROM t$stat_table
                            WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                            UPDATE t$stat_table
                            SET stat_td_txin = stat_td_txin + 1
                                WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                        ELSE
                            INSERT INTO t$stat_table
                            VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                        END IF;
                    END;
                END IF;

                IF var_tran_type = '170' THEN
                    BEGIN
                        SELECT
                            'y'
                            INTO var_updated_flag;

                        IF EXISTS (SELECT
                            *
                            FROM t$stat_table
                            WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                            UPDATE t$stat_table
                            SET stat_td_txout = stat_td_txout + 1
                                WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                        ELSE
                            INSERT INTO t$stat_table
                            VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                        END IF;
                    END;
                END IF;

                IF var_tran_type = '171' THEN
                    BEGIN
                        SELECT
                            'y'
                            INTO var_updated_flag;

                        IF EXISTS (SELECT
                            *
                            FROM t$stat_table
                            WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                            UPDATE t$stat_table
                            SET stat_td_txin = stat_td_txin + 1
                                WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                        ELSE
                            INSERT INTO t$stat_table
                            VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                        END IF;
                    END;
                END IF;
                /* process cancellation only for daily statistics generation */
                IF par_input_trans_type = 'D' AND var_post_flag = 'Y' THEN
                    BEGIN
                        /* Update admission datetime (old) */
                        IF var_tran_type = '120' THEN
                            BEGIN
                                SELECT
                                    'y'
                                    INTO var_updated_flag;
                                SELECT
                                    Source_indicator
                                    INTO var_temp_adm_src
                                    FROM Event_log
                                    WHERE System_datetime > - 15 * INTERVAL '1 second' + var_tran_sys_date::TIMESTAMP AND System_datetime < 15 * INTERVAL '1 second' + var_tran_sys_date::TIMESTAMP AND Case_no = var_case_no::VARCHAR AND Type = var_tran_type::VARCHAR AND Hospital_code = par_hosp_code::VARCHAR;

                                IF var_temp_adm_src = '3' THEN
                                    SELECT
                                        1
                                        INTO var_temp_ae_adm;
                                ELSE
                                    SELECT
                                        0
                                        INTO var_temp_ae_adm;
                                END IF;

                                IF EXISTS (SELECT
                                    *
                                    FROM t$stat_table
                                    WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                                    UPDATE t$stat_table
                                    SET stat_canc_adm = stat_canc_adm + 1, stat_canc_ae_adm = stat_canc_ae_adm + var_temp_ae_adm
                                        WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                                ELSE
                                    INSERT INTO t$stat_table
                                    VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, var_temp_ae_adm, 0, 0, 0, 0);
                                END IF;
                            END;
                        END IF;
                        /* Update admission datetime (new) */
                        IF var_tran_type = '121' THEN
                            BEGIN
                                SELECT
                                    'y'
                                    INTO var_updated_flag;
                                SELECT
                                    Source_indicator
                                    INTO var_temp_adm_src
                                    FROM Event_log
                                    WHERE System_datetime > - 15 * INTERVAL '1 second' + var_tran_sys_date::TIMESTAMP AND System_datetime < 15 * INTERVAL '1 second' + var_tran_sys_date::TIMESTAMP AND Case_no = var_case_no::VARCHAR AND Type = var_tran_type::VARCHAR AND Hospital_code = par_hosp_code::VARCHAR;

                                IF var_temp_adm_src = '3' THEN
                                    SELECT
                                        1
                                        INTO var_temp_ae_adm;
                                ELSE
                                    SELECT
                                        0
                                        INTO var_temp_ae_adm;
                                END IF;

                                IF EXISTS (SELECT
                                    *
                                    FROM t$stat_table
                                    WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                                    UPDATE t$stat_table
                                    SET stat_adm = stat_adm + 1, stat_ae_adm = stat_ae_adm + var_temp_ae_adm
                                        WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                                ELSE
                                    INSERT INTO t$stat_table
                                    VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 1, 0, 0, 0, 0, 0, 0, 0, 0, var_temp_ae_adm, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                                END IF;
                            END;
                        END IF;
                        /* Cancellation of Admission */
                        IF var_tran_type = '201' THEN
                            BEGIN
                                SELECT
                                    'y'
                                    INTO var_updated_flag;
                                SELECT
                                    Source_indicator
                                    INTO var_temp_adm_src
                                    FROM Event_log
                                    WHERE System_datetime = var_tran_sys_date AND Hospital_code = par_hosp_code;

                                IF var_temp_adm_src = '3' THEN
                                    SELECT
                                        1
                                        INTO var_temp_ae_adm;
                                ELSE
                                    SELECT
                                        0
                                        INTO var_temp_ae_adm;
                                END IF;

                                IF EXISTS (SELECT
                                    *
                                    FROM t$stat_table
                                    WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                                    UPDATE t$stat_table
                                    SET stat_canc_adm = stat_canc_adm + 1, stat_canc_ae_adm = stat_canc_ae_adm + var_temp_ae_adm
                                        WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                                ELSE
                                    INSERT INTO t$stat_table
                                    VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, var_temp_ae_adm, 0, 0, 0, 0);
                                END IF;
                            END;
                        END IF;
                        /* Cancellation of Transfer in */
                        IF var_tran_type = '221' THEN
                            BEGIN
                                SELECT
                                    'y'
                                    INTO var_updated_flag;

                                IF var_from_ward = var_to_ward THEN
                                    SELECT
                                        1
                                        INTO var_temp_tx_within_ward;
                                ELSE
                                    SELECT
                                        0
                                        INTO var_temp_tx_within_ward;
                                END IF;

                                IF var_from_spec = var_to_spec AND COALESCE(var_from_loc, 'null') = COALESCE(var_to_loc, 'null') THEN
                                    SELECT
                                        1
                                        INTO var_temp_tx_within_spec;
                                ELSE
                                    SELECT
                                        0
                                        INTO var_temp_tx_within_spec;
                                END IF;

                                IF EXISTS (SELECT
                                    *
                                    FROM t$stat_table
                                    WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                                    UPDATE t$stat_table
                                    SET stat_canc_txin = stat_canc_txin + 1, stat_canc_tx_within_spec = stat_canc_tx_within_spec + var_temp_tx_within_spec, stat_canc_tx_within_ward = stat_canc_tx_within_ward + var_temp_tx_within_ward
                                        WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                                ELSE
                                    INSERT INTO t$stat_table
                                    VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, var_temp_tx_within_spec, var_temp_tx_within_ward, 0, 0, 0, 0, 0, 0, 0);
                                END IF;
                            END;
                        END IF;
                        /* Cancellation of Transfer out */
                        IF var_tran_type = '220' THEN
                            BEGIN
                                SELECT
                                    'y'
                                    INTO var_updated_flag;

                                IF var_from_ward = var_to_ward THEN
                                    SELECT
                                        1
                                        INTO var_temp_tx_within_ward;
                                ELSE
                                    SELECT
                                        0
                                        INTO var_temp_tx_within_ward;
                                END IF;

                                IF var_from_spec = var_to_spec AND COALESCE(var_from_loc, 'null') = COALESCE(var_to_loc, 'null') THEN
                                    SELECT
                                        1
                                        INTO var_temp_tx_within_spec;
                                ELSE
                                    SELECT
                                        0
                                        INTO var_temp_tx_within_spec;
                                END IF;

                                IF EXISTS (SELECT
                                    *
                                    FROM t$stat_table
                                    WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                                    UPDATE t$stat_table
                                    SET stat_canc_txout = stat_canc_txout + 1, stat_canc_tx_within_spec = stat_canc_tx_within_spec + var_temp_tx_within_spec, stat_canc_tx_within_ward = stat_canc_tx_within_ward + var_temp_tx_within_ward
                                        WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                                ELSE
                                    INSERT INTO t$stat_table
                                    VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, var_temp_tx_within_spec, var_temp_tx_within_ward, 0, 0, 0, 0, 0, 0, 0);
                                END IF;
                            END;
                        END IF;
                        /* Cancellation of Discharge */
                        IF var_tran_type LIKE '21_' AND var_tran_type != '211' THEN
                            BEGIN
                                SELECT
                                    'y'
                                    INTO var_updated_flag;
                                SELECT
                                    Source_indicator, Admission_datetime
                                    INTO var_temp_adm_src, var_temp_adm_dt
                                    FROM Event_log
                                    WHERE System_datetime = var_tran_sys_date AND Hospital_code = par_hosp_code;

                                IF DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - var_temp_adm_dt::TIMESTAMP::TIMESTAMP) = 0 THEN
                                    BEGIN
                                        IF var_temp_adm_src = '3' THEN
                                            BEGIN
                                                SELECT
                                                    1
                                                    INTO var_temp_ae_day;
                                                SELECT
                                                    0
                                                    INTO var_temp_day_dsch;
                                            END;
                                        ELSE
                                            BEGIN
                                                SELECT
                                                    0
                                                    INTO var_temp_ae_day;
                                                SELECT
                                                    1
                                                    INTO var_temp_day_dsch;
                                            END;
                                        END IF;
                                    END;
                                ELSE
                                    BEGIN
                                        SELECT
                                            0
                                            INTO var_temp_ae_day;
                                        SELECT
                                            0
                                            INTO var_temp_day_dsch;
                                    END;
                                END IF;

                                IF EXISTS (SELECT
                                    *
                                    FROM t$stat_table
                                    WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                                    UPDATE t$stat_table
                                    SET stat_canc_dsch = stat_canc_dsch + 1, stat_canc_ae_day_dsch = stat_canc_ae_day_dsch + var_temp_ae_day, stat_canc_day_dsch = stat_canc_day_dsch + var_temp_day_dsch
                                        WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                                ELSE
                                    INSERT INTO t$stat_table
                                    VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, var_temp_ae_day, 0, var_temp_day_dsch, 0);
                                END IF;
                            END;
                        END IF;
                        /* Cancellation of Death */
                        IF var_tran_type = '211' THEN
                            BEGIN
                                SELECT
                                    'y'
                                    INTO var_updated_flag;
                                SELECT
                                    Source_indicator, Admission_datetime
                                    INTO var_temp_adm_src, var_temp_adm_dt
                                    FROM Event_log
                                    WHERE System_datetime = var_tran_sys_date AND Hospital_code = par_hosp_code;

                                IF DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - var_temp_adm_dt::TIMESTAMP::TIMESTAMP) = 0 THEN
                                    BEGIN
                                        IF var_temp_adm_src = '3' THEN
                                            BEGIN
                                                SELECT
                                                    1
                                                    INTO var_temp_ae_day;
                                                SELECT
                                                    0
                                                    INTO var_temp_day_dsch;
                                            END;
                                        ELSE
                                            BEGIN
                                                SELECT
                                                    0
                                                    INTO var_temp_ae_day;
                                                SELECT
                                                    1
                                                    INTO var_temp_day_dsch;
                                            END;
                                        END IF;
                                    END;
                                ELSE
                                    BEGIN
                                        SELECT
                                            0
                                            INTO var_temp_ae_day;
                                        SELECT
                                            0
                                            INTO var_temp_day_dsch;
                                    END;
                                END IF;

                                IF EXISTS (SELECT
                                    *
                                    FROM t$stat_table
                                    WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                                    UPDATE t$stat_table
                                    SET stat_canc_deth = stat_canc_deth + 1, stat_canc_ae_day_deth = stat_canc_ae_day_deth + var_temp_ae_day, stat_canc_day_deth = stat_canc_day_deth + var_temp_day_dsch
                                        WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                                ELSE
                                    INSERT INTO t$stat_table
                                    VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, var_temp_ae_day, 0, var_temp_day_dsch);
                                END IF;
                            END;
                        END IF;

                        IF var_tran_type = '230' THEN
                            BEGIN
                                SELECT
                                    'y'
                                    INTO var_updated_flag;

                                IF EXISTS (SELECT
                                    *
                                    FROM t$stat_table
                                    WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                                    UPDATE t$stat_table
                                    SET stat_canc_td_txout = stat_canc_td_txout + 1
                                        WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                                ELSE
                                    INSERT INTO t$stat_table
                                    VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0);
                                END IF;
                            END;
                        END IF;

                        IF var_tran_type = '231' THEN
                            BEGIN
                                SELECT
                                    'y'
                                    INTO var_updated_flag;

                                IF EXISTS (SELECT
                                    *
                                    FROM t$stat_table
                                    WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                                    UPDATE t$stat_table
                                    SET stat_canc_td_txin = stat_canc_td_txin + 1
                                        WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                                ELSE
                                    INSERT INTO t$stat_table
                                    VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0);
                                END IF;
                            END;
                        END IF;

                        IF var_tran_type = '240' THEN
                            BEGIN
                                SELECT
                                    'y'
                                    INTO var_updated_flag;

                                IF EXISTS (SELECT
                                    *
                                    FROM t$stat_table
                                    WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                                    UPDATE t$stat_table
                                    SET stat_canc_td_txout = stat_canc_td_txout + 1
                                        WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                                ELSE
                                    INSERT INTO t$stat_table
                                    VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0);
                                END IF;
                            END;
                        END IF;

                        IF var_tran_type = '241' THEN
                            BEGIN
                                SELECT
                                    'y'
                                    INTO var_updated_flag;

                                IF EXISTS (SELECT
                                    *
                                    FROM t$stat_table
                                    WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc)) THEN
                                    UPDATE t$stat_table
                                    SET stat_canc_td_txin = stat_canc_td_txin + 1
                                        WHERE DATE_PART('day', var_tran_date::TIMESTAMP::TIMESTAMP - stat_date::TIMESTAMP::TIMESTAMP) = 0 AND stat_ward = var_from_ward AND stat_spec = var_from_spec AND ((stat_loc is null and var_from_loc is null) or stat_loc = var_from_loc);
                                ELSE
                                    INSERT INTO t$stat_table
                                    VALUES (to_char(var_tran_date, 'YYYYMMDD')::timestamp, var_from_ward, var_from_spec, var_from_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0);
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;
                /*
                use ordinary update statement instead of using current of cursor
                for change in clustered and nonclustered index
                */
                /*
                if @updated_flag = 'y'
                update Transaction_log set
                        Post_datetime = @system_date
                        where current of trans_log_csr
                */
                IF var_updated_flag = 'y' THEN
                    UPDATE Transaction_log
                    SET Post_datetime = var_system_date
                        WHERE Transaction_datetime = var_tran_date AND System_datetime = var_tran_sys_date AND Transaction_type = var_tran_type AND Hospital_code = par_hosp_code;
                END IF;
                --RAISE notice '[hasp_upd_tx] test';
                IF par_input_trans_type = 'R' THEN
                    --OPEN trans_log_csr1;
                    FETCH trans_log_csr1 INTO var_tran_sys_date, var_tran_type, var_case_no, var_from_ward, var_from_spec, var_from_loc, var_to_ward, var_to_spec, var_to_loc, var_tran_date, var_post_date, var_post_flag;
                ELSE
                    --OPEN trans_log_csr2;
                    FETCH trans_log_csr2 INTO var_tran_sys_date, var_tran_type, var_case_no, var_from_ward, var_from_spec, var_from_loc, var_to_ward, var_to_spec, var_to_loc, var_tran_date, var_post_date, var_post_flag;
                END IF;
            END LOOP;
            /* select * from #stat_table */
            IF par_input_trans_type = 'R' THEN
                CLOSE trans_log_csr1;
            ELSE
                --RAISE notice '[hasp_upd_tx] test2';
                CLOSE trans_log_csr2;
            END IF;
            /* update Ward_spec_tx table */
            OPEN stat_csr;
            FETCH stat_csr INTO var_date, var_ward, var_spec, var_loc, var_adm, var_txin, var_txout, var_dsch, var_deth, var_tx_within_spec, var_tx_within_ward, var_td_txin, var_td_txout, var_ae_adm, var_ae_day_dsch, var_ae_day_deth, var_day_dsch, var_day_deth, var_canc_adm, var_canc_txin, var_canc_txout, var_canc_dsch, var_canc_deth, var_canc_tx_within_spec, var_canc_tx_within_ward, var_canc_td_txin, var_canc_td_txout, var_canc_ae_adm, var_canc_ae_day_dsch, var_canc_ae_day_deth, var_canc_day_dsch, var_canc_day_deth;

            WHILE (CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
            END) = 0 LOOP
                SELECT
                    var_adm + var_txin + var_td_txin - var_txout - var_td_txout - var_dsch - var_deth - var_canc_adm - var_canc_txin - var_canc_td_txin + var_canc_txout + var_canc_td_txout + var_canc_dsch + var_canc_deth
                    INTO var_adjustment;

                IF par_input_trans_type = 'R' THEN
                    BEGIN
                        /* select @prev_remain = Previous_remaining, */
                        SELECT
                            Admission, Transfer_in, Transfer_out, Transfer_in_from_TD, Transfer_out_to_TD, Discharge, Death
                            INTO var_prev_adm, var_prev_txin, var_prev_txout, var_prev_td_txin, var_prev_td_txout, var_prev_dsch, var_prev_deth
                            FROM Ward_spec_tx
                            WHERE to_char(Ward_spec_tx_date, 'YYYYMMDD') = to_char(var_date, 'YYYYMMDD') AND Ward_code = var_ward AND Specialty_code = var_spec AND ((Treatment_location is null and var_loc is null) or Treatment_location = var_loc) AND Hospital_code = par_hosp_code;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF (SELECT
                            sql$rowcount) > 0 THEN
                            BEGIN
                                SELECT
                                    Canc_admission, Canc_transfer_in, Canc_transfer_out, Canc_transfer_in_from_TD, Canc_transfer_out_to_TD, Canc_discharge, Canc_death
                                    INTO var_prev_canc_adm, var_prev_canc_txin, var_prev_canc_txout, var_prev_canc_td_txin, var_prev_canc_td_txout, var_prev_canc_dsch, var_prev_canc_deth
                                    FROM Ward_spec_adj
                                    WHERE to_char(Ward_spec_adj_date, 'YYYYMMDD') = to_char(var_date, 'YYYYMMDD') AND Ward_spec_adj.Ward_code = var_ward AND Ward_spec_adj.Specialty_code = var_spec AND ((Ward_spec_adj.Treatment_location  is null and var_loc is null) or Ward_spec_adj.Treatment_location  = var_loc) AND Hospital_code = par_hosp_code;
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                IF (SELECT
                                    sql$rowcount) = 0 THEN
                                    SELECT
                                        0, 0, 0, 0, 0, 0, 0
                                        INTO var_prev_canc_adm, var_prev_canc_txin, var_prev_canc_txout, var_prev_canc_td_txin, var_prev_canc_td_txout, var_prev_canc_dsch, var_prev_canc_deth;
                                END IF;
                                /* ( @prev_remain + @prev_adm + @prev_txin + */
                                SELECT
                                    var_adjustment - (var_prev_adm + var_prev_txin + var_prev_td_txin - var_prev_txout - var_prev_td_txout - var_prev_dsch - var_prev_deth - var_prev_canc_adm - var_prev_canc_txin - var_prev_canc_td_txin + var_prev_canc_txout + var_prev_canc_td_txout + var_prev_canc_dsch + var_prev_canc_deth)
                                    INTO var_adjustment;
                            END;
                        END IF;
                        DELETE FROM Ward_spec_tx
                            WHERE to_char(Ward_spec_tx_date, 'YYYYMMDD') = to_char(var_date, 'YYYYMMDD') AND Ward_code = var_ward AND Specialty_code = var_spec AND ((Treatment_location is null and var_loc is null) or Treatment_location = var_loc) AND Hospital_code = par_hosp_code;
                        DELETE FROM Ward_spec_adj
                            WHERE to_char(Ward_spec_adj_date, 'YYYYMMDD') = to_char(var_date, 'YYYYMMDD') AND Ward_code = var_ward AND Specialty_code = var_spec AND ((Treatment_location is null and var_loc is null) or Treatment_location = var_loc) AND Hospital_code = par_hosp_code;
                    END;
                END IF;

                IF EXISTS (SELECT
                    *
                    FROM Ward_spec_tx
                    WHERE to_char(Ward_spec_tx_date, 'YYYYMMDD') = to_char(var_date, 'YYYYMMDD') AND Ward_code = var_ward AND Specialty_code = var_spec AND Hospital_code = par_hosp_code AND  ((Treatment_location is null and var_loc is null) or Treatment_location = var_loc)) THEN
                    UPDATE Ward_spec_tx
                    SET Admission = Admission + var_adm, Transfer_in = Transfer_in + var_txin, Transfer_out = Transfer_out + var_txout, Transfer_within_ward = Transfer_within_ward + var_tx_within_ward, Transfer_within_specialty = Transfer_within_specialty + var_tx_within_spec, Transfer_in_from_TD = Transfer_in_from_TD + var_td_txin, Transfer_out_to_TD = Transfer_out_to_TD + var_td_txout, Discharge = Discharge + var_dsch, Death = Death + var_deth, Admission_thru_AE = Admission_thru_AE + var_ae_adm, AE_day_discharge = AE_day_discharge + var_ae_day_dsch, AE_day_death = AE_day_death + var_ae_day_deth, Day_discharge = Day_discharge + var_day_dsch, Day_death = Day_death + var_day_deth
                        WHERE to_char(Ward_spec_tx_date, 'YYYYMMDD') = to_char(var_date, 'YYYYMMDD') AND Ward_code = var_ward AND Specialty_code = var_spec AND  ((Treatment_location is null and var_loc is null) or Treatment_location = var_loc) AND Hospital_code = par_hosp_code;
                ELSE
                    BEGIN
                        SELECT
                            Ward_spec_tx_date, Previous_remaining, Admission, Transfer_in, Transfer_out, Transfer_in_from_TD, Transfer_out_to_TD, Discharge, Death
                            INTO var_prev_date, var_prev_remain, var_prev_adm, var_prev_txin, var_prev_txout, var_prev_td_txin, var_prev_td_txout, var_prev_dsch, var_prev_deth
                            FROM Ward_spec_tx
                            WHERE Ward_spec_tx_date = (SELECT
                                MAX(Ward_spec_tx_date)
                                FROM Ward_spec_tx
                                WHERE Hospital_code = par_hosp_code AND Ward_spec_tx_date < var_date AND Ward_code = var_ward AND Specialty_code = var_spec AND ((Treatment_location is null and var_loc is null) or Treatment_location = var_loc)) AND Ward_code = var_ward AND Specialty_code = var_spec AND ((Treatment_location is null and var_loc is null) or Treatment_location = var_loc) AND Hospital_code = par_hosp_code;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF (SELECT
                            sql$rowcount) = 0 THEN
                            SELECT
                                0
                                INTO var_remain;
                        ELSE
                            BEGIN
                                SELECT
                                    Ward_spec_adj.Canc_admission, Canc_transfer_in, Canc_transfer_out, Canc_transfer_in_from_TD, Canc_transfer_out_to_TD, Canc_discharge, Canc_death
                                    INTO var_prev_canc_adm, var_prev_canc_txin, var_prev_canc_txout, var_prev_canc_td_txin, var_prev_canc_td_txout, var_prev_canc_dsch, var_prev_canc_deth
                                    FROM Ward_spec_adj
                                    WHERE to_char(Ward_spec_adj_date, 'YYYYMMDD') = to_char(var_prev_date, 'YYYYMMDD') AND Ward_code = var_ward AND Specialty_code = var_spec AND ((Treatment_location is null and var_loc is null) or Treatment_location = var_loc) AND Hospital_code = par_hosp_code;
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                IF (SELECT
                                    sql$rowcount) = 0 THEN
                                    SELECT
                                        0, 0, 0, 0, 0, 0, 0
                                        INTO var_prev_canc_adm, var_prev_canc_txin, var_prev_canc_td_txin, var_prev_canc_txout, var_prev_canc_td_txout, var_prev_canc_dsch, var_prev_canc_deth;
                                END IF;
                                SELECT
                                    var_prev_remain + var_prev_adm + var_prev_txin + var_prev_td_txin - var_prev_txout - var_prev_td_txout - var_prev_dsch - var_prev_deth - var_prev_canc_adm - var_prev_canc_txin - var_prev_canc_td_txin + var_prev_canc_txout + var_prev_canc_td_txout + var_prev_canc_dsch + var_prev_canc_deth
                                    INTO var_remain;
                            END;
                        END IF;
                        /*
                        select @remain, @prev_remain, @prev_adm, @prev_txin,
                        @prev_td_txin, @prev_txout, @prev_td_txout,
                        @prev_dsch, @prev_deth, @prev_canc_adm,
                        @prev_canc_txin, @prev_canc_td_txin,
                        @prev_canc_txout, @prev_canc_td_txout,
                        @prev_canc_dsch, @prev_canc_deth
                        */
                        INSERT INTO Ward_spec_tx
                        VALUES
                        /* --(@date, @ward, @spec, @loc, */
                        (par_hosp_code, var_date, var_ward, var_spec, var_loc, var_remain, var_adm, var_dsch, var_txin, var_txout, var_deth, var_day_dsch, var_day_deth, var_ae_adm, var_td_txin, var_td_txout, var_ae_day_dsch, var_ae_day_deth, var_tx_within_spec, var_tx_within_ward);
                    END;
                END IF;

                IF var_canc_adm > 0 OR var_canc_txin > 0 OR var_canc_txout > 0 OR var_canc_dsch > 0 OR var_canc_deth > 0 OR var_canc_day_dsch > 0 OR var_canc_day_deth > 0 OR var_canc_ae_adm > 0 OR var_canc_td_txin > 0 OR var_canc_td_txin > 0 OR var_canc_td_txout > 0 OR var_canc_ae_day_dsch > 0 OR var_canc_ae_day_deth > 0 OR var_canc_tx_within_ward > 0 OR var_canc_tx_within_spec > 0 THEN
                    BEGIN
                        IF EXISTS (SELECT
                            *
                            FROM Ward_spec_adj
                            WHERE to_char(Ward_spec_adj_date, 'YYYYMMDD') = to_char(var_date, 'YYYYMMDD') AND Hospital_code = par_hosp_code AND Ward_code = var_ward AND Specialty_code = var_spec AND ((Treatment_location is null and var_loc is null) or Treatment_location = var_loc)) THEN
                            UPDATE Ward_spec_adj
                            SET Canc_admission = Canc_admission + var_canc_adm, Canc_discharge = Canc_discharge + var_canc_dsch, Canc_transfer_in = Canc_transfer_in + var_canc_txin, Canc_transfer_out = Canc_transfer_out + var_canc_txout, Canc_death = Canc_death + var_canc_deth, Canc_day_discharge = Canc_day_discharge + var_canc_day_dsch, Canc_day_death = Canc_day_death + var_canc_day_deth, Canc_admission_thru_AE = Canc_admission_thru_AE + var_canc_ae_adm, Canc_transfer_in_from_TD = Canc_transfer_in_from_TD + var_canc_td_txin, Canc_transfer_out_to_TD = Canc_transfer_out_to_TD + var_canc_td_txout, Canc_AE_day_discharge = Canc_AE_day_discharge + var_canc_ae_day_dsch, Canc_AE_day_death = Canc_AE_day_death + var_canc_ae_day_deth, Canc_transfer_within_specialty = Canc_transfer_within_specialty + var_canc_tx_within_spec, Canc_transfer_within_ward = Canc_transfer_within_ward + var_canc_tx_within_ward
                                WHERE to_char(Ward_spec_adj_date, 'YYYYMMDD') = to_char(var_date, 'YYYYMMDD') AND Ward_code = var_ward AND Specialty_code = var_spec AND ((Treatment_location is null and var_loc is null) or Treatment_location = var_loc) AND Hospital_code = par_hosp_code;
                        ELSE
                            INSERT INTO Ward_spec_adj
                            VALUES
                            /* --(@date, @ward, @spec, @loc, */
                            (par_hosp_code, var_date, var_ward, var_spec, var_loc, var_canc_adm, var_canc_dsch, var_canc_txin, var_canc_txout, var_canc_deth, var_canc_day_dsch, var_canc_day_deth, var_canc_ae_adm, var_canc_td_txin, var_canc_td_txout, var_canc_ae_day_dsch, var_canc_ae_day_deth, var_canc_tx_within_spec, var_canc_tx_within_ward);
                        END IF;
                    END;
                END IF;
                /* Adjust Previous remaining of subsequent Ward_spec_tx */
                UPDATE Ward_spec_tx
                SET Previous_remaining = Previous_remaining + var_adjustment
                    WHERE Ward_spec_tx_date > var_date AND Ward_code = var_ward AND Specialty_code = var_spec AND ((Treatment_location is null and var_loc is null) or Treatment_location = var_loc) AND Hospital_code = par_hosp_code;
                FETCH stat_csr INTO var_date, var_ward, var_spec, var_loc, var_adm, var_txin, var_txout, var_dsch, var_deth, var_tx_within_spec, var_tx_within_ward, var_td_txin, var_td_txout, var_ae_adm, var_ae_day_dsch, var_ae_day_deth, var_day_dsch, var_day_deth, var_canc_adm, var_canc_txin, var_canc_txout, var_canc_dsch, var_canc_deth, var_canc_tx_within_spec, var_canc_tx_within_ward, var_canc_td_txin, var_canc_td_txout, var_canc_ae_adm, var_canc_ae_day_dsch, var_canc_ae_day_deth, var_canc_day_dsch, var_canc_day_deth;
            END LOOP;
            CLOSE stat_csr;

            IF par_input_trans_type = 'D' THEN
                UPDATE hospital_config
                SET Last_reported_date = var_processing_date
                    WHERE par_input_to_datetime > Last_reported_date AND Hospital_code = par_hosp_code;
            END IF;

            /* --insert into #dsp_table select * from #stat_table   -- 20180105 */
            INSERT INTO t$dsp_table
            SELECT
                stat_date, stat_ward, stat_spec, stat_loc, stat_adm, stat_txin, stat_txout, stat_dsch, stat_deth, stat_tx_within_spec, stat_tx_within_ward, stat_td_txin, stat_td_txout, stat_ae_adm, stat_ae_day_dsch, stat_ae_day_deth, stat_day_dsch, stat_day_deth, stat_canc_adm, stat_canc_txin, stat_canc_txout, stat_canc_dsch, stat_canc_deth, stat_canc_tx_within_spec, stat_canc_tx_within_ward, stat_canc_td_txin, stat_canc_td_txout, stat_canc_ae_adm, stat_canc_ae_day_dsch, stat_canc_ae_day_deth, stat_canc_day_dsch, stat_canc_day_deth
                FROM t$stat_table;
            TRUNCATE TABLE t$stat_table;
            SELECT
                1 * INTERVAL '1 day' + var_processing_date::TIMESTAMP
                INTO var_processing_date;
        END LOOP;
--        EXIT normal_exit;
--        ROLLBACK;
--        return_code := 999;

--        <<abnormal_exit>>
--        BEGIN
--            RETURN;
--        END;
    END;
    OPEN p_refcur FOR
    SELECT
        dsp_date, dsp_ward, dsp_spec, SUM(dsp_adm)::INTEGER, SUM(dsp_canc_adm)::INTEGER, SUM(dsp_txin)::INTEGER, SUM(dsp_canc_txin)::INTEGER, SUM(dsp_txout)::INTEGER, SUM(dsp_canc_txout)::INTEGER, SUM(dsp_dsch)::INTEGER, SUM(dsp_canc_dsch)::INTEGER, SUM(dsp_deth)::INTEGER, SUM(dsp_canc_deth)::INTEGER, SUM(dsp_td_txin)::INTEGER, SUM(dsp_canc_td_txin)::INTEGER, SUM(dsp_td_txout)::INTEGER, SUM(dsp_canc_td_txout)::INTEGER
        FROM t$dsp_table
        GROUP BY dsp_date, dsp_ward, dsp_spec;
    /*
    [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
    commit
    */
--    return_code := 0;
    --RAISE notice '[hasp_upd_tx] end';
    return next p_refcur;
    /*
    
    DROP TABLE IF EXISTS t$stat_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$dsp_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;

;ALTER FUNCTION "hasp_upd_tx" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
