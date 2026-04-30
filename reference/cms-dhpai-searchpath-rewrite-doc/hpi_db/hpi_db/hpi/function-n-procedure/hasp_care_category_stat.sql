-- DROP PROCEDURE hasp_care_category_stat(inout int4, in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_care_category_stat(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, IN par_input_care character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
    /* add hosp code for HPI by ML on 28.07.1999 */
/* ---------------------------------------------------------------------------------------------- */
/* 20180105 to fix/avoid following error : remove SELECT * */

/* ---------------------------------------------------------------------------------------------- */
/* DBCC upgrade_object: Upgrading PROCEDURE dbo.hasp_care_category_stat */
/* Warning: PROCEDURE hasp_care_category_stat contains the SELECT * construct in the outermost */
/* SELECT query. */
/* Please verify that the table(s) referenced in the SELECT * have not */
/* been altered.  During upgrade the SELECT * is expanded to include all */
/* columns of the table(s). */
/* Run DBCC upgrade_object with the 'force' option to upgrade hasp_care_category_stat. */
/* Msg 11031, Level 16, State 1: */
/* Server 'xxxxB', Procedure 'hasp_care_category_stat', Line 21: */
/* Execution of procedure hasp_care_category_stat failed because of errors parsing the source text in syscomments during upgrade. Please drop and recreate dbo.hasp_care_category_stat. */

/* ---------------------------------------------------------------------------------------------- */
DECLARE
    result_str_value         VARCHAR(128);
    result_int_value         INTEGER;
    result_dtm_value         TIMESTAMP WITHOUT TIME ZONE;
    result_dtm_value_2       TIMESTAMP WITHOUT TIME ZONE;
    var_error                INTEGER;
    var_tx_type              VARCHAR(3);
    var_case                 VARCHAR(12);
    var_tx_dtm               TIMESTAMP WITHOUT TIME ZONE;
    var_adm_source_ind       VARCHAR(1);
    var_adm_dtm              TIMESTAMP WITHOUT TIME ZONE;
    var_to_ward              VARCHAR(4);
    var_to_spec              VARCHAR(4);
    var_to_treat_loc         VARCHAR(4);
    var_to_care              VARCHAR(1);
    var_spec                 VARCHAR(4);
    var_ward                 VARCHAR(4);
    var_care                 VARCHAR(1);
    var_treat_loc            VARCHAR(4);
    var_day                  INTEGER;
    var_cur_spec             VARCHAR(4);
    var_cur_cc               VARCHAR(1);
    var_cur_ward             VARCHAR(4);
    var_cur_treat_loc        VARCHAR(4);
    var_cur_move_type        VARCHAR(1);
    var_cur_move_dtm         TIMESTAMP WITHOUT TIME ZONE;
    var_prev_ward            VARCHAR(4);
    var_prev_spec            VARCHAR(4);
    var_prev_treat_loc       VARCHAR(4);
    var_prev_cc              VARCHAR(1);
    var_prev_move_type       VARCHAR(1);
    var_prev_move_dtm        TIMESTAMP WITHOUT TIME ZONE;
    var_disc_dtm             TIMESTAMP WITHOUT TIME ZONE;
    var_move_cnt             INTEGER;
    var_los                  INTEGER;
    var_xout                 INTEGER;
    var_ans                  VARCHAR(50);
    var_i_bed                INTEGER;
    var_date                 TIMESTAMP WITHOUT TIME ZONE;
    var_adm                  INTEGER;
    var_ae_adm               INTEGER;
    var_transfer_in          INTEGER;
    var_transfer_out         INTEGER;
    var_trial_in             INTEGER;
    var_trial_out            INTEGER;
    var_tfr_wcc_ws           INTEGER;
    var_tfr_wcc_bs           INTEGER;
    var_tfr_bcc_ws           INTEGER;
    var_tfr_bcc_bs           INTEGER;
    var_ip_disc              INTEGER;
    var_dp_disc              INTEGER;
    var_ip_death             INTEGER;
    var_dp_death             INTEGER;
    var_aed_disc             INTEGER;
    var_aed_death            INTEGER;
    var_occ                  INTEGER;
    var_vac                  INTEGER;
    var_ava                  INTEGER;
    var_exc                  INTEGER;
    var_tfr_out_disc         INTEGER;
    var_total_los            INTEGER;
    var_description          VARCHAR(30);
    var_patient_remain       INTEGER;
    var_spec_cnt             INTEGER;
    var_adm_total            INTEGER;
    var_ae_adm_total         INTEGER;
    var_tfr_wcc_ws_total     INTEGER;
    var_tfr_wcc_bs_total     INTEGER;
    var_tfr_bcc_ws_total     INTEGER;
    var_tfr_bcc_bs_total     INTEGER;
    var_ip_disc_total        INTEGER;
    var_ip_death_total       INTEGER;
    var_dp_disc_total        INTEGER;
    var_dp_death_total       INTEGER;
    var_aed_disc_total       INTEGER;
    var_aed_death_total      INTEGER;
    var_patient_remain_total INTEGER;
    var_occ_total            INTEGER;
    var_vac_total            INTEGER;
    var_ava_total            INTEGER;
    var_exc_total            INTEGER;
    var_tfr_out_disc_total   INTEGER;
    var_total_los_total      INTEGER;
    var_care_desc            VARCHAR(20);
    var_adm_hosp             INTEGER;
    var_ae_adm_hosp          INTEGER;
    var_tfr_wcc_ws_hosp      INTEGER;
    var_tfr_wcc_bs_hosp      INTEGER;
    var_tfr_bcc_ws_hosp      INTEGER;
    var_tfr_bcc_bs_hosp      INTEGER;
    var_ip_disc_hosp         INTEGER;
    var_ip_death_hosp        INTEGER;
    var_dp_disc_hosp         INTEGER;
    var_dp_death_hosp        INTEGER;
    var_aed_disc_hosp        INTEGER;
    var_aed_death_hosp       INTEGER;
    var_patient_remain_hosp  INTEGER;
    var_occ_hosp             INTEGER;
    var_vac_hosp             INTEGER;
    var_ava_hosp             INTEGER;
    var_exc_hosp             INTEGER;
    var_tfr_out_disc_hosp    INTEGER;
    var_total_los_hosp       INTEGER;
    var_tmp_date             VARCHAR(30);
    var_t_ae_adm             INTEGER;
    var_t_adm                INTEGER;
    var_t_patient_remain     INTEGER;
    var_t_occ_daily          INTEGER;
    var_t_aed_disc           INTEGER;
    var_t_aed_death          INTEGER;
    var_t_dp_disc            INTEGER;
    var_t_dp_death           INTEGER;
    var_t_ip_disc            INTEGER;
    var_t_ip_death           INTEGER;
    var_t_transfer_in        INTEGER;
    var_t_transfer_out       INTEGER;
    var_t_tfr_wcc_ws         INTEGER;
    var_t_tfr_wcc_bs         INTEGER;
    var_t_tfr_bcc_ws         INTEGER;
    var_t_tfr_bcc_bs         INTEGER;
    var_t_trial_out          INTEGER;
    var_t_trial_in           INTEGER;

BEGIN
	IF date_part('days' , par_input_to_date - par_input_from_date) > 180 THEN
		SET LOCAL temp_buffers = '64MB';
	END IF;

    /* --declare @prev_remain int */
    SELECT 1 * INTERVAL '1 day' + par_input_to_date::TIMESTAMP
    INTO par_input_to_date;
    /* ** declare temp variable to hold temp result ** */
    /* --select @tmp_date = convert(char(30), getdate(),109) */
    /* --print -- Create #result begin at %1!--------, @tmp_date */

    /* * Create temp. table to hold result * */
    DROP TABLE IF EXISTS t$result;
    CREATE TEMPORARY TABLE t$result
    (
        care                 VARCHAR(1)  NULL,
        spec                 VARCHAR(4)  NULL,
        treat_loc            VARCHAR(4)  NULL,
        description          VARCHAR(30) NULL,
        /* --prev_remain int default 0, */
        adm                  INTEGER DEFAULT 0,
        transfer_in          INTEGER DEFAULT 0,
        transfer_out         INTEGER DEFAULT 0,
        trial_in             INTEGER DEFAULT 0,
        trial_out            INTEGER DEFAULT 0,
        ae_adm               INTEGER DEFAULT 0,
        tfr_wcc_ws           INTEGER DEFAULT 0,
        /* transfer out within care category & within spec */
        tfr_wcc_bs           INTEGER DEFAULT 0,
        /* transfer out within care category  & between spec */
        tfr_bcc_ws           INTEGER DEFAULT 0,
        /* transfer out between care category & within spec */
        tfr_bcc_bs           INTEGER DEFAULT 0,
        /* transfer out between care category & between spec */
        ip_disc              INTEGER DEFAULT 0,
        dp_disc              INTEGER DEFAULT 0,
        ip_death             INTEGER DEFAULT 0,
        dp_death             INTEGER DEFAULT 0,
        aed_disc             INTEGER DEFAULT 0, /* ae day disc */
        aed_death            INTEGER DEFAULT 0, /* ae day death */
        patient_remain       INTEGER DEFAULT 0,
        patient_remain_total INTEGER DEFAULT 0,
        occ                  INTEGER DEFAULT 0, /* occupied */
        occ_daily            INTEGER DEFAULT 0,
        vac                  INTEGER DEFAULT 0, /* vacant */
        vac_daily            INTEGER DEFAULT 0,
        ava                  INTEGER DEFAULT 0, /* available */
        ava_daily            INTEGER DEFAULT 0,
        exc                  INTEGER DEFAULT 0, /* excess */
        exc_daily            INTEGER DEFAULT 0,
        tfr_out_disc         INTEGER DEFAULT 0, /* transfer out of discharged patient */
        total_los            INTEGER DEFAULT 0 /* total length of stay */)
       ;
    
--     CREATE UNIQUE INDEX idx_result1 ON t$result(care, spec, treat_loc);
     CREATE INDEX idx_result1 ON t$result(care, spec, treat_loc);
--     CREATE INDEX idx_result2 ON t$result(care, treat_loc);
      
	IF date_part('days' , par_input_to_date - par_input_from_date) > 180 THEN
		ALTER TABLE t$result SET (fillfactor = 10);
	END IF;
    
    /* --select @tmp_date = convert(char(30), getdate(),109) */
    /* --print ------ End create #result table at %1!-----, @tmp_date */

    /* --select @tmp_date = convert(char(30), getdate(),109) */
    /* --print ------ begin cal previous remain %1!-----, @tmp_date */

    /* * CAL PREVIOUS REMAIN * */

    /* get previous remaining of start date */

    /* add hosp code for HPI by ML on 28.07.1999 */
    DROP TABLE IF EXISTS t$start_table;
    CREATE TEMPORARY TABLE t$start_table
    AS
    SELECT MAX(a.Ward_spec_tx_date) AS tx_date,
           a.Ward_code              AS ward_code,
           a.Specialty_code         AS spec_code,
           a.Treatment_location     AS treat_loc
    FROM Ward_spec_tx AS a
    WHERE Ward_spec_tx_date < par_input_from_date
      AND Hospital_code = par_hosp_code
    GROUP BY Ward_code, Specialty_code, Treatment_location;

    DROP TABLE IF EXISTS t$stat_table;
    CREATE TEMPORARY TABLE t$stat_table
    (
        ward_code      VARCHAR(4) NULL,
        spec_code      VARCHAR(4) NULL,
        treat_loc      VARCHAR(4) NULL,
        care           VARCHAR(1) NULL,
        patient_remain INTEGER DEFAULT 0
    );

    INSERT INTO t$stat_table (ward_code, spec_code, treat_loc, patient_remain)
    SELECT a.Ward_code,
           a.Specialty_code,
           a.Treatment_location,
           COALESCE(a.Previous_remaining, 0) + COALESCE(a.Admission, 0) - COALESCE(a.Canc_admission, 0) -
           COALESCE(a.Discharge, 0) + COALESCE(a.Canc_discharge, 0) + COALESCE(a.Transfer_in, 0) -
           COALESCE(a.Canc_transfer_in, 0) - COALESCE(a.Transfer_out, 0) + COALESCE(a.Canc_transfer_out, 0) -
           COALESCE(a.Death, 0) + COALESCE(a.Canc_death, 0) + COALESCE(a.Transfer_in_from_TD, 0) -
           COALESCE(a.Canc_transfer_in_from_TD, 0)
    FROM t$start_table AS b,
         Ward_spec_tx_adj_view AS a
    WHERE b.tx_date = a.Ward_spec_tx_date
      AND b.ward_code = a.Ward_code
      AND b.spec_code = a.Specialty_code
      AND a.Hospital_code = par_hosp_code
      AND COALESCE(b.treat_loc, 'null') = COALESCE(a.Treatment_location, 'null');

    /* add hosp code for HPI by ML on 28.07.1999 */
    DROP TABLE t$start_table;
    /* get care category */
    /* add hosp code for HPI by ML on 28.07.1999 */
    DROP TABLE IF EXISTS t$cc_table;
    CREATE TEMPORARY TABLE t$cc_table
    AS
    SELECT Care_category, Ward_code
    FROM (SELECT Care_category,
                 Ward_code,
                 Effective_date,
                 ROW_NUMBER() OVER (PARTITION BY Ward_code ORDER BY Effective_date DESC) AS rn
          FROM Ward
          WHERE Effective_date < par_input_from_date
            AND Hospital_code = par_hosp_code) sub
    WHERE rn = 1;

    UPDATE t$stat_table AS b
    SET care = Care_category
    FROM t$cc_table AS a
    WHERE a.Ward_code = b.ward_code;

    DROP TABLE t$cc_table;

    INSERT INTO t$result (care, spec, treat_loc, patient_remain, occ_daily)
    SELECT care,
           spec_code,
           treat_loc,
           SUM(patient_remain),
           SUM(patient_remain)
    FROM t$stat_table
    GROUP BY care, spec_code, treat_loc;

    DROP TABLE t$stat_table;

    /* --select @tmp_date = convert(char(30), getdate(),109) */
    /* --print ------ end cal previous remain %1!-----, @tmp_date */

    SELECT par_input_from_date
    INTO var_date;

    /* --select @tmp_date = convert(char(30), getdate(),109) */
    /* --print ------ begin cal BDA,TX SUMMARY, total los and transfer out of disc patient  %1!-----, @tmp_date */
   
    WHILE var_date < par_input_to_date
    LOOP
        FOR var_spec, var_treat_loc, var_tx_dtm, var_ward, var_case, var_tx_type,
            var_to_ward, var_to_spec, var_to_treat_loc IN
            SELECT From_specialty_code,
                   From_treatment_location,
                   Transaction_datetime,
                   From_ward_code,
                   Case_no,
                   Transaction_type,
                   To_ward_code,
                   To_specialty_code,
                   To_treatment_location
            FROM Transaction_log
            WHERE Cancel_flag IS NULL
              AND Hospital_code = par_hosp_code::VARCHAR
              AND Transaction_datetime >= var_date
              AND Transaction_datetime < 1 * INTERVAL '1 day' + var_date::TIMESTAMP
              AND ((Transaction_type LIKE '13_') OR (Transaction_type IN ('100', '140', '141', '160', '170')))
        LOOP
            /* * initialize temp variable * */
            SELECT 0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0
            INTO var_t_ae_adm, var_t_adm, var_t_patient_remain, var_t_occ_daily, var_t_aed_disc,
                var_t_aed_death, var_t_dp_disc, var_t_dp_death, var_t_ip_disc, var_t_ip_death,
                var_t_transfer_in, var_t_transfer_out, var_t_tfr_wcc_ws, var_t_tfr_wcc_bs,
                var_t_tfr_bcc_ws, var_t_tfr_bcc_bs, var_t_trial_out, var_t_trial_in;

            /* find out care category according to tx datetime */
            /* add hosp code for HPI by ML on 28.07.1999 */
            SELECT Care_category
            INTO result_str_value
            FROM Ward
            WHERE Ward_code = var_ward
              AND Hospital_code = par_hosp_code
              AND Effective_date = (SELECT MAX(Effective_date)
                                    FROM Ward
                                    WHERE Ward_code = var_ward
                                      AND Hospital_code = par_hosp_code
                                      AND Effective_date <= var_tx_dtm);

            IF FOUND
            THEN
                var_care := result_str_value;
            END IF;

            /* insert to #result table if not exist */
            IF NOT EXISTS (SELECT *
                           FROM t$result
                           WHERE care = var_care
                             AND spec = var_spec
                             AND COALESCE(treat_loc, 'null') = COALESCE(var_treat_loc, 'null'))
            THEN
                INSERT INTO t$result (care, spec, treat_loc)
                VALUES (var_care, var_spec, var_treat_loc);
            END IF;

            IF var_treat_loc IS NOT NULL
            THEN
                BEGIN
                    IF NOT EXISTS (SELECT *
                                   FROM t$result
                                   WHERE care = var_care
                                     AND spec = var_treat_loc
                                     AND treat_loc IS NULL)
                    THEN
                        INSERT INTO t$result (care, spec, treat_loc)
                        VALUES (var_care, var_treat_loc, NULL);
                    END IF;
                END;
            END IF;

            /* PROCESS ADMISSION & AE ADMISSION */
            IF var_tx_type = '100'
            THEN
                BEGIN
                    /* find out admission source indicator */
                    /* add hosp code for HPI by ML on 28.07.1999 */
                    SELECT Source_indicator
                    INTO result_str_value
                    FROM Case_view
                    WHERE Case_no = var_case
                      AND Hospital_code = par_hosp_code;

                    IF FOUND
                    THEN
                        var_adm_source_ind := result_str_value;
                    END IF;

                    IF var_adm_source_ind = '3'
                    THEN
                        SELECT var_t_ae_adm + 1
                        INTO var_t_ae_adm;
                    END IF;

                    SELECT var_t_adm + 1,
                           var_t_patient_remain + 1,
                           var_t_occ_daily + 1
                    INTO var_t_adm, var_t_patient_remain, var_t_occ_daily;
                END;
            END IF;

            IF SUBSTRING(var_tx_type, 1, 2) = '13'
            THEN
                BEGIN
                    /* PROCESS AE DAY DISCHARGE */
                    /* add hosp code for HPI by ML on 28.07.1999 */
                    SELECT Source_indicator,
                           Admission_datetime
                    INTO result_str_value, result_dtm_value
                    FROM Case_view
                    WHERE Case_no = var_case
                      AND Hospital_code = par_hosp_code;

                    IF FOUND
                    THEN
                        var_adm_source_ind := result_str_value;
                        var_adm_dtm := result_dtm_value;
                    END IF;

                    IF (var_adm_source_ind = '3') AND
                       (DATE_PART('days', var_tx_dtm::date::timestamp -
                                          var_adm_dtm::date::timestamp) = 0) AND
                       RIGHT(var_tx_type, 1) <> '1'
                    THEN
                        SELECT var_t_aed_disc + 1,
                               var_t_occ_daily + 1
                        INTO var_t_aed_disc, var_t_occ_daily;
                    END IF;

                    /* PROCESS AE DAY DEATH */
                    IF (var_adm_source_ind = '3') AND
                       (DATE_PART('days', var_tx_dtm::date::timestamp -
                                          var_adm_dtm::date::timestamp) = 0) AND
                       RIGHT(var_tx_type, 1) = '1'
                    THEN
                        SELECT var_t_aed_death + 1,
                               var_t_occ_daily + 1
                        INTO var_t_aed_death, var_t_occ_daily;
                    END IF;

                    /* PROCESS DAY DISCHARGE */
                    IF (DATE_PART('days', var_tx_dtm::date::timestamp -
                                          var_adm_dtm::date::timestamp) = 0) AND
                       RIGHT(var_tx_type, 1) <> '1' AND
                       (var_adm_source_ind <> '3' OR var_adm_source_ind IS NULL)
                    THEN
                        SELECT var_t_dp_disc + 1
                        INTO var_t_dp_disc;
                    END IF;

                    /* PROCESS DAY DEATH */
                    IF (DATE_PART('days', var_tx_dtm::date::timestamp -
                                          var_adm_dtm::date::timestamp) = 0) AND
                       RIGHT(var_tx_type, 1) = '1' AND
                       (var_adm_source_ind <> '3' OR var_adm_source_ind IS NULL)
                    THEN
                        SELECT var_t_dp_death + 1
                        INTO var_t_dp_death;
                    END IF;

                    /* PROCESS Inpat Discharge */
                    IF RIGHT(var_tx_type, 1) <> '1'
                    THEN
                        SELECT var_t_ip_disc + 1,
                               var_t_patient_remain - 1,
                               var_t_occ_daily - 1
                        INTO var_t_ip_disc, var_t_patient_remain, var_t_occ_daily;
                    END IF;

                    /* PROCESS Inpat Death */
                    IF RIGHT(var_tx_type, 1) = '1'
                    THEN
                        SELECT var_t_ip_death + 1,
                               var_t_patient_remain - 1,
                               var_t_occ_daily - 1
                        INTO var_t_ip_death, var_t_patient_remain, var_t_occ_daily;
                    END IF;

                    /* *** put cal total los and transfer out of disc pat here * */
                    /* add hosp code for HPI by ML on 27.07.1999 */
                    SELECT Admission_datetime,
                           Discharge_datetime
                    INTO result_dtm_value, result_dtm_value_2
                    FROM Case_view
                    WHERE Case_no = var_case
                      AND Hospital_code = par_hosp_code;

                    IF FOUND
                    THEN
                        var_adm_dtm := result_dtm_value;
                        var_disc_dtm := result_dtm_value_2;
                    END IF;

                    FOR var_move_cnt, var_cur_spec, var_cur_ward, var_cur_treat_loc, var_cur_move_dtm, var_cur_move_type IN
                        SELECT Movement_count,
                               Specialty_code,
                               Ward_code,
                               Treatment_location,
                               Movement_datetime,
                               Movement_type
                        FROM Movement
                        WHERE Case_no = var_case
                          AND Hospital_code = par_hosp_code
                    LOOP
                        /* find care category */
                        /* add hosp code for HPI by ML on 27.07.1999 */
                        SELECT Care_category
                        INTO result_str_value
                        FROM Ward
                        WHERE Ward_code = var_cur_ward
                          AND Hospital_code = par_hosp_code
                          AND Effective_date = (SELECT MAX(Effective_date)
                                                FROM Ward
                                                WHERE Ward_code = var_cur_ward
                                                  AND Hospital_code = par_hosp_code
                                                  AND Effective_date <= var_cur_move_dtm);

                        IF FOUND
                        THEN
                            var_cur_cc := result_str_value;
                        END IF;

                        IF var_move_cnt = 1
                        THEN
                            BEGIN
                                SELECT var_cur_spec,
                                       var_cur_ward,
                                       var_cur_treat_loc,
                                       var_cur_move_dtm,
                                       var_cur_cc
                                INTO var_prev_spec, var_prev_ward, var_prev_treat_loc, var_prev_move_dtm, var_prev_cc;
                            END;
                        ELSE
                            BEGIN
                                IF (var_cur_spec <> var_prev_spec) OR
                                   (COALESCE(var_cur_treat_loc, 'null') <>
                                    COALESCE(var_prev_treat_loc, 'null')) OR (var_cur_move_type = 'D')
                                THEN
                                    BEGIN
                                        IF var_prev_spec = 'HOME'
                                        THEN
                                            SELECT 0
                                            INTO var_los;
                                        ELSE
                                            SELECT DATE_PART('days',
                                                             var_cur_move_dtm::date::timestamp -
                                                             var_prev_move_dtm::date::timestamp)
                                            INTO var_los;
                                        END IF;

                                        IF (var_prev_spec = 'HOME') OR (var_cur_spec = 'HOME')
                                        THEN
                                            SELECT 0
                                            INTO var_xout;
                                        ELSE
                                            IF var_cur_move_type = 'D'
                                            THEN
                                                SELECT 0
                                                INTO var_xout;
                                            ELSE
                                                SELECT 1
                                                INTO var_xout;
                                            END IF;
                                        END IF;

                                        IF (var_los = 0) AND (var_cur_move_type = 'D') AND
                                           (var_prev_spec <> 'HOME' OR var_prev_spec IS NULL) AND
                                           DATE_PART('days', var_disc_dtm::date::timestamp -
                                                             var_adm_dtm::date::timestamp) =
                                           0
                                        THEN
                                            BEGIN
                                                /* add hosp code for HPI by ML on 27.07.1999 */
                                                SELECT Source_indicator
                                                INTO result_str_value
                                                FROM Case_view
                                                WHERE Case_no = var_case
                                                  AND Hospital_code = par_hosp_code;
                                                IF FOUND
                                                THEN
                                                    var_adm_source_ind := result_str_value;
                                                END IF;

                                                IF var_adm_source_ind = '3'
                                                THEN
                                                    SELECT 1
                                                    INTO var_los;
                                                END IF;
                                            END;
                                        END IF;

                                        IF NOT EXISTS (SELECT *
                                                       FROM t$result
                                                       WHERE care = var_prev_cc::VARCHAR
                                                         AND spec = var_prev_spec::VARCHAR
                                                         AND COALESCE(treat_loc, 'null') = COALESCE(var_prev_treat_loc, 'null'))
                                        THEN
                                            INSERT INTO t$result (care, spec, treat_loc)
                                            VALUES (var_prev_cc, var_prev_spec, var_prev_treat_loc);
                                        END IF;

                                        UPDATE t$result
                                        SET tfr_out_disc = tfr_out_disc + var_xout,
                                            total_los    = total_los + var_los
                                        WHERE spec = var_prev_spec
                                          AND care = var_prev_cc
                                          AND COALESCE(treat_loc, 'null') = COALESCE(var_prev_treat_loc, 'null');
                                        SELECT var_cur_spec,
                                               var_cur_treat_loc,
                                               var_cur_move_dtm,
                                               var_cur_ward,
                                               var_cur_cc
                                        INTO var_prev_spec, var_prev_treat_loc, var_prev_move_dtm, var_prev_ward, var_prev_cc;
                                    END;
                                END IF;
                            END;
                        END IF;
                    END LOOP;
                END;
            END IF;

            /* PROCESS TRANSFER IN */
            IF var_tx_type = '141'
            THEN
                SELECT var_t_transfer_in + 1,
                       var_t_patient_remain + 1,
                       var_t_occ_daily + 1
                INTO var_t_transfer_in, var_t_patient_remain, var_t_occ_daily;
            END IF;

            /* PROCESS TRANSFER OUT */
            IF var_tx_type = '140'
            THEN
                BEGIN
                    /* add hosp code for HPI by ML on 28.07.1999 */
                    SELECT Care_category
                    INTO result_str_value
                    FROM Ward
                    WHERE Ward_code = var_to_ward
                      AND Hospital_code = par_hosp_code
                      AND Effective_date = (SELECT MAX(Effective_date)
                                            FROM Ward
                                            WHERE Ward_code = var_to_ward
                                              AND Hospital_code = par_hosp_code
                                              AND Effective_date <= var_tx_dtm);
                    IF FOUND
                    THEN
                        var_to_care := result_str_value;
                    END IF;
                    SELECT var_t_transfer_out + 1,
                           var_t_patient_remain - 1,
                           var_t_occ_daily - 1
                    INTO var_t_transfer_out, var_t_patient_remain, var_t_occ_daily;

                    /* transfer out within Care Category & within Spec */
                    IF (var_care = var_to_care) AND (var_spec = var_to_spec AND
                                                     COALESCE(var_treat_loc, 'null') =
                                                     COALESCE(var_to_treat_loc, 'null'))
                    THEN
                        SELECT var_t_tfr_wcc_ws + 1
                        INTO var_t_tfr_wcc_ws;
                    END IF;

                    /* transfer out within Care Category & between Spec */
                    IF (var_care = var_to_care) AND (var_spec <> var_to_spec OR
                                                     COALESCE(var_treat_loc, 'null') <>
                                                     COALESCE(var_to_treat_loc, 'null'))
                    THEN
                        SELECT var_t_tfr_wcc_bs + 1
                        INTO var_t_tfr_wcc_bs;
                    END IF;

                    /* transfer out between Care Category & within Spec */
                    IF (var_care <> var_to_care) AND (var_spec = var_to_spec AND
                                                      COALESCE(var_treat_loc, 'null') =
                                                      COALESCE(var_to_treat_loc, 'null'))
                    THEN
                        SELECT var_t_tfr_bcc_ws + 1
                        INTO var_t_tfr_bcc_ws;
                    END IF;

                    /* transfer out between Care Category & between Spec */
                    IF (var_care <> var_to_care) AND (var_spec <> var_to_spec OR
                                                      COALESCE(var_treat_loc, 'null') <>
                                                      COALESCE(var_to_treat_loc, 'null'))
                    THEN
                        SELECT var_t_tfr_bcc_bs + 1
                        INTO var_t_tfr_bcc_bs;
                    END IF;
                END;
            END IF;

            /* PROCESS TRIAL DISCHARGE */
            IF var_tx_type = '160'
            THEN
                SELECT var_t_trial_out + 1,
                       var_t_patient_remain - 1,
                       var_t_occ_daily - 1
                INTO var_t_trial_out, var_t_patient_remain, var_t_occ_daily;
            END IF;

            /* PROCESS RETURN FROM TRIAL DISCHARGE */
            IF var_tx_type = '170'
            THEN
                SELECT var_t_trial_in + 1,
                       var_t_patient_remain + 1,
                       var_t_occ_daily + 1
                INTO var_t_trial_in, var_t_patient_remain, var_t_occ_daily;
            END IF;

            UPDATE t$result
            SET ae_adm         = ae_adm + var_t_ae_adm,
                adm            = adm + var_t_adm,
                patient_remain = patient_remain + var_t_patient_remain,
                occ_daily      = occ_daily + var_t_occ_daily,
                aed_disc       = aed_disc + var_t_aed_disc,
                aed_death      = aed_death + var_t_aed_death,
                dp_disc        = dp_disc + var_t_dp_disc,
                dp_death       = dp_death + var_t_dp_death,
                ip_disc        = ip_disc + var_t_ip_disc,
                ip_death       = ip_death + var_t_ip_death,
                transfer_in    = transfer_in + var_t_transfer_in,
                transfer_out   = transfer_out + var_t_transfer_out,
                tfr_wcc_ws     = tfr_wcc_ws + var_t_tfr_wcc_ws,
                tfr_wcc_bs     = tfr_wcc_bs + var_t_tfr_wcc_bs,
                tfr_bcc_ws     = tfr_bcc_ws + var_t_tfr_bcc_ws,
                tfr_bcc_bs     = tfr_bcc_bs + var_t_tfr_bcc_bs,
                trial_out      = trial_out + var_t_trial_out,
                trial_in       = trial_in + var_t_trial_in
            WHERE care = var_care
              AND spec = var_spec
              AND COALESCE(treat_loc, 'null') = COALESCE(var_treat_loc, 'null');
        END LOOP;

        UPDATE t$result
        SET patient_remain_total = patient_remain_total + patient_remain,
            occ                  = occ + occ_daily;

        CREATE TEMPORARY TABLE t$tmp_occ
        AS
        SELECT care,
               treat_loc,
               SUM(occ_daily) AS occ_daily
        FROM t$result
        WHERE treat_loc IS NOT NULL
        GROUP BY care, treat_loc;

        UPDATE t$result AS a
        SET occ_daily = a.occ_daily + b.occ_daily,
            occ       = a.occ + b.occ_daily
        FROM t$tmp_occ AS b
        WHERE a.care = b.care
          AND a.spec = b.treat_loc
          AND a.treat_loc IS NULL;

        DROP TABLE t$tmp_occ;

        /* * CAL BED DAY AVAILABLE DAILY * */
        FOR var_spec IN
            SELECT DISTINCT Specialty_code
            FROM Specialty
            WHERE Hospital_code = par_hosp_code
        LOOP
            FOR var_ward IN
                SELECT DISTINCT Ward_code
                FROM Ward_specialty
                WHERE Specialty_code = var_spec
                  AND Ward_code <> 'AE01'
                  AND Hospital_code = par_hosp_code
            LOOP
                SELECT 0
                INTO var_i_bed;

                /* add hosp code for HPI by ML on 28.07.1999 */
                WITH RankedWardSpecialty AS (SELECT Official_bed,
                                                    ROW_NUMBER()
                                                    OVER (PARTITION BY Ward_code, Specialty_code, Hospital_code ORDER BY Effective_date DESC) AS rn
                                             FROM Ward_specialty
                                             WHERE Ward_code = var_ward
                                               AND Specialty_code = var_spec
                                               AND Hospital_code = par_hosp_code
                                               AND Effective_date <= var_date)
                SELECT Official_bed
                INTO result_int_value
                FROM RankedWardSpecialty
                WHERE rn = 1;

                IF FOUND
                THEN
                    var_i_bed := result_int_value;
                END IF;

                IF var_i_bed > 0
                THEN
                    BEGIN
                        /* find out Care Category */
                        /* add hosp code for HPI by ML on 28.07.1999 */
                        WITH RankedWard AS (SELECT Care_category,
                                                   ROW_NUMBER()
                                                   OVER (PARTITION BY Ward_code, Hospital_code ORDER BY Effective_date DESC) AS rn
                                            FROM Ward
                                            WHERE Ward_code = var_ward
                                              AND Hospital_code = par_hosp_code
                                              AND Effective_date <= var_date)
                        SELECT Care_category
                        INTO result_str_value
                        FROM RankedWard
                        WHERE rn = 1;

                        IF FOUND
                        THEN
                            var_care := result_str_value;
                        END IF;

                        IF NOT EXISTS (SELECT 1
                                       FROM t$result
                                       WHERE care = var_care
                                         AND spec = var_spec
                                         AND treat_loc IS NULL)
                        THEN
                            INSERT INTO t$result (care, spec, treat_loc)
                            VALUES (var_care, var_spec, NULL);
                        END IF;

                        UPDATE t$result
                        SET ava       = ava + var_i_bed,
                            ava_daily = ava_daily + var_i_bed
                        WHERE care = var_care
                          AND spec = var_spec
                          AND treat_loc IS NULL;
                    END;
                END IF;
                SELECT 0
                INTO var_i_bed;
            END LOOP;
        END LOOP;
        UPDATE t$result
        SET vac_daily = ava_daily - occ_daily
        WHERE (treat_loc IS NULL)
          AND (ava_daily > occ_daily);

        UPDATE t$result
        SET exc_daily = occ_daily - ava_daily
        WHERE (treat_loc IS NULL)
          AND (occ_daily > ava_daily);

        UPDATE t$result
        SET vac       = vac + vac_daily,
            exc       = exc + exc_daily,
            ava_daily = 0,
            occ_daily = patient_remain,
            vac_daily = 0,
            exc_daily = 0;
        SELECT 1 * INTERVAL '1 day' + var_date::TIMESTAMP
        INTO var_date;
    END LOOP;
    /* end whild loop */
    /* --select @tmp_date = convert(char(30), getdate(),109) */
    /* --print ------ end cal BDA ,TX SUMMARY , total los and transfer out of disc pat  %1!-----, @tmp_date */

    DROP TABLE IF EXISTS t$tmp_pat_remain;
    CREATE TEMPORARY TABLE t$tmp_pat_remain
    AS
    SELECT care,
           treat_loc,
           SUM(patient_remain_total) AS patient_remain_total,
           SUM(adm)                  AS adm,
           SUM(ae_adm)               AS ae_adm,
           SUM(tfr_wcc_ws)           AS tfr_wcc_ws,
           SUM(tfr_wcc_bs)           AS tfr_wcc_bs,
           SUM(tfr_bcc_ws)           AS tfr_bcc_ws,
           SUM(tfr_bcc_bs)           AS tfr_bcc_bs,
           SUM(ip_disc)              AS ip_disc,
           SUM(ip_death)             AS ip_death,
           SUM(dp_disc)              AS dp_disc,
           SUM(dp_death)             AS dp_death,
           SUM(aed_disc)             AS aed_disc,
           SUM(aed_death)            AS aed_death,
           SUM(tfr_out_disc)         AS tfr_out_disc,
           SUM(total_los)            AS total_los
    FROM t$result
    WHERE treat_loc IS NOT NULL
    GROUP BY care, treat_loc;

    UPDATE t$result AS a
    SET patient_remain_total = a.patient_remain_total + b.patient_remain_total,
        adm                  = a.adm + b.adm,
        ae_adm               = a.ae_adm + b.ae_adm,
        tfr_wcc_ws           = a.tfr_wcc_ws + b.tfr_wcc_ws,
        tfr_wcc_bs           = a.tfr_wcc_bs + b.tfr_wcc_bs,
        tfr_bcc_ws           = a.tfr_bcc_ws + b.tfr_bcc_ws,
        tfr_bcc_bs           = a.tfr_bcc_bs + b.tfr_bcc_bs,
        ip_disc              = a.ip_disc + b.ip_disc,
        ip_death             = a.ip_death + b.ip_death,
        dp_disc              = a.dp_disc + b.dp_disc,
        dp_death             = a.dp_death + b.dp_death,
        aed_disc             = a.aed_disc + b.aed_disc,
        aed_death            = a.aed_death + b.aed_death,
        tfr_out_disc         = a.tfr_out_disc + b.tfr_out_disc,
        total_los            = a.total_los + b.total_los
    FROM t$tmp_pat_remain AS b
    WHERE a.care = b.care
      AND a.spec = b.treat_loc
      AND a.treat_loc IS NULL;
    DROP TABLE t$tmp_pat_remain;

    /* * Update Description * */
    UPDATE t$result
    SET description = treat_loc
    WHERE treat_loc IS NOT NULL;

    /* --select @tmp_date = convert(char(30), getdate(),109) */
    /* --print ---start create display table %1!---, @tmp_date */
    /* CREATE TEMP TABLE ONLY FOR DISPLAY */
    DROP TABLE IF EXISTS t$display;
    CREATE TEMPORARY TABLE t$display
    (    	
        care           VARCHAR(20) NULL,
        spec           VARCHAR(4)  NULL,
        description    VARCHAR(30) NULL,
        adm            INTEGER     NULL,
        ae_adm         INTEGER     NULL,
        tfr_wcc_ws     INTEGER     NULL,
        tfr_wcc_bs     INTEGER     NULL,
        tfr_bcc_ws     INTEGER     NULL,
        tfr_bcc_bs     INTEGER     NULL,
        ip_disc        INTEGER     NULL,
        ip_death       INTEGER     NULL,
        dp_disc        INTEGER     NULL,
        dp_death       INTEGER     NULL,
        aed_disc       INTEGER     NULL,
        aed_death      INTEGER     NULL,
        patient_remain INTEGER     NULL,
        occ            INTEGER     NULL,
        vac            INTEGER     NULL,
        ava            INTEGER     NULL,
        exc            INTEGER     NULL,
        tfr_out_disc   INTEGER     NULL,
        total_los      INTEGER     NULL,
        create_at TIMESTAMP DEFAULT clock_timestamp()
    );
    /* --select @tmp_date = convert(char(30), getdate(),109) */
    /* --print ---end create display table %1!---, @tmp_date */
    /* * Display result * */
    SELECT NULL,
           NULL,
           0
    INTO var_prev_cc, var_prev_spec, var_spec_cnt;
    SELECT 0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0
    INTO var_adm_total, var_ae_adm_total, var_tfr_wcc_ws_total, var_tfr_wcc_bs_total, var_tfr_bcc_ws_total,
        var_tfr_bcc_bs_total, var_ip_disc_total, var_ip_death_total, var_dp_disc_total, var_dp_death_total,
        var_aed_disc_total, var_aed_death_total, var_patient_remain_total, var_occ_total, var_vac_total,
        var_ava_total, var_exc_total, var_tfr_out_disc_total, var_total_los_total;
    SELECT 0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0
    INTO var_adm_hosp, var_ae_adm_hosp, var_tfr_wcc_ws_hosp, var_tfr_wcc_bs_hosp, var_tfr_bcc_ws_hosp,
        var_tfr_bcc_bs_hosp, var_ip_disc_hosp, var_ip_death_hosp, var_dp_disc_hosp, var_dp_death_hosp,
        var_aed_disc_hosp, var_aed_death_hosp, var_patient_remain_hosp, var_occ_hosp, var_vac_hosp,
        var_ava_hosp, var_exc_hosp, var_tfr_out_disc_hosp, var_total_los_hosp;
    /* --select @tmp_date = convert(char(30), getdate(),109) */
    /* --print ---begin format display table %1!---, @tmp_date */

    FOR var_care, var_spec, var_description, var_adm, var_ae_adm, var_tfr_wcc_ws, var_tfr_wcc_bs, var_tfr_bcc_ws,
        var_tfr_bcc_bs, var_ip_disc, var_ip_death, var_dp_disc, var_dp_death, var_aed_disc, var_aed_death,
        var_patient_remain, var_occ, var_vac, var_ava, var_exc, var_tfr_out_disc, var_total_los IN
        SELECT care,
               spec,
               description,
               adm,
               ae_adm,
               tfr_wcc_ws,
               tfr_wcc_bs,
               tfr_bcc_ws,
               tfr_bcc_bs,
               ip_disc,
               ip_death,
               dp_disc,
               dp_death,
               aed_disc,
               aed_death,
               patient_remain_total,
               occ,
               vac,
               ava,
               exc,
               tfr_out_disc,
               total_los
        FROM t$result
        WHERE (adm > 0 OR ae_adm > 0 OR tfr_wcc_ws > 0 OR tfr_wcc_bs > 0 OR tfr_bcc_ws > 0 OR tfr_bcc_bs > 0 OR
               ip_disc > 0 OR ip_death > 0 OR dp_disc > 0 OR dp_death > 0 OR aed_disc > 0 OR aed_death > 0 OR
               patient_remain_total > 0 OR occ > 0 OR vac > 0 OR ava > 0 OR exc > 0 OR tfr_out_disc > 0 OR
               total_los > 0)
          AND care LIKE par_input_care
        ORDER BY care COLLATE "C" NULLS FIRST, spec COLLATE "C" NULLS FIRST, description COLLATE "C" NULLS FIRST
    LOOP
        /* * for a new care category * */
        IF COALESCE(var_prev_cc,'null') <> COALESCE(var_care,'null')
        THEN
            BEGIN
                IF COALESCE(var_care,'null') = 'A'
                THEN
                    SELECT 'Acute'
                    INTO var_care_desc;
                END IF;

                IF COALESCE(var_care,'null') = 'I'
                THEN
                    SELECT 'Infirmary'
                    INTO var_care_desc;
                END IF;

                IF COALESCE(var_care,'null') = 'R'
                THEN
                    SELECT 'Conv./Reb.'
                    INTO var_care_desc;
                END IF;

                IF COALESCE(var_care,'null') = 'M'
                THEN
                    SELECT 'Mixed'
                    INTO var_care_desc;
                END IF;
                /* specialty with more than one rows */
                IF var_spec_cnt > 0
                THEN
                    BEGIN
                        INSERT INTO t$display
                        VALUES (NULL, NULL, 'Specialty Total', var_adm_total, var_ae_adm_total,
                                var_tfr_wcc_ws_total, var_tfr_wcc_bs_total, var_tfr_bcc_ws_total,
                                var_tfr_bcc_bs_total, var_ip_disc_total, var_ip_death_total, var_dp_disc_total,
                                var_dp_death_total, var_aed_disc_total, var_aed_death_total,
                                var_patient_remain_total, var_occ_total, NULL, NULL, NULL, var_tfr_out_disc_total,
                                var_total_los_total);
                        SELECT 0
                        INTO var_spec_cnt;
                    END;
                END IF;
               SELECT count(1) INTO result_int_value FROM t$display;
                INSERT INTO t$display (care)
                VALUES (var_care_desc);
            END;
        END IF;

        IF (var_prev_spec = var_spec) AND (var_prev_cc = var_care)
        THEN
            BEGIN
                IF var_description IS NULL
                THEN
                    BEGIN
                        /* add hosp code for HPI by ML on 28.07.1999 */
                        SELECT Description
                        INTO result_str_value
                        FROM Specialty
                        WHERE Specialty_code = var_spec
                          AND Hospital_code = par_hosp_code
                          AND Effective_date = (SELECT MAX(Effective_date)
                                                FROM Specialty
                                                WHERE Specialty_code = var_spec
                                                  AND Hospital_code = par_hosp_code
                                                  AND Effective_date < par_input_to_date);
                        IF FOUND
                        THEN
                            var_description := result_str_value;
                        END IF;
                        SELECT var_adm_hosp + var_adm,
                               var_ae_adm_hosp + var_ae_adm,
                               var_tfr_wcc_ws_hosp + var_tfr_wcc_ws,
                               var_tfr_wcc_bs_hosp + var_tfr_wcc_bs,
                               var_tfr_bcc_ws_hosp + var_tfr_bcc_ws,
                               var_tfr_bcc_bs_hosp + var_tfr_bcc_bs,
                               var_ip_disc_hosp + var_ip_disc,
                               var_ip_death_hosp + var_ip_death,
                               var_dp_disc_hosp + var_dp_disc,
                               var_dp_death_hosp + var_dp_death,
                               var_aed_disc_hosp + var_aed_disc,
                               var_aed_death_hosp + var_aed_death,
                               var_patient_remain_hosp + var_patient_remain,
                               var_occ_hosp + var_occ,
                               var_vac_hosp + var_vac,
                               var_ava_hosp + var_ava,
                               var_exc_hosp + var_exc,
                               var_tfr_out_disc_hosp + var_tfr_out_disc,
                               var_total_los_hosp + var_total_los
                        INTO var_adm_hosp, var_ae_adm_hosp, var_tfr_wcc_ws_hosp, var_tfr_wcc_bs_hosp,
                            var_tfr_bcc_ws_hosp, var_tfr_bcc_bs_hosp, var_ip_disc_hosp, var_ip_death_hosp,
                            var_dp_disc_hosp, var_dp_death_hosp, var_aed_disc_hosp, var_aed_death_hosp,
                            var_patient_remain_hosp, var_occ_hosp, var_vac_hosp, var_ava_hosp, var_exc_hosp,
                            var_tfr_out_disc_hosp, var_total_los_hosp;
                    END;
                END IF;
                INSERT INTO t$display
                VALUES (NULL, NULL, var_description, var_adm, var_ae_adm, var_tfr_wcc_ws, var_tfr_wcc_bs,
                        var_tfr_bcc_ws, var_tfr_bcc_bs, var_ip_disc, var_ip_death, var_dp_disc, var_dp_death,
                        var_aed_disc, var_aed_death, var_patient_remain, var_occ, var_vac, var_ava, var_exc,
                        var_tfr_out_disc, var_total_los);
                SELECT var_spec_cnt + 1
                INTO var_spec_cnt;
            END;
        ELSE
            BEGIN
                IF var_spec_cnt > 0
                THEN
                    INSERT INTO t$display
                    VALUES (NULL, NULL, 'Specialty Total', var_adm_total, var_ae_adm_total, var_tfr_wcc_ws_total,
                            var_tfr_wcc_bs_total, var_tfr_bcc_ws_total, var_tfr_bcc_bs_total, var_ip_disc_total,
                            var_ip_death_total, var_dp_disc_total, var_dp_death_total, var_aed_disc_total,
                            var_aed_death_total, var_patient_remain_total, var_occ_total, NULL, NULL, NULL,
                            var_tfr_out_disc_total, var_total_los_total);
                END IF;
                SELECT 0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0
                INTO var_adm_total, var_ae_adm_total, var_tfr_wcc_ws_total, var_tfr_wcc_bs_total,
                    var_tfr_bcc_ws_total, var_tfr_bcc_bs_total, var_ip_disc_total, var_ip_death_total,
                    var_dp_disc_total, var_dp_death_total, var_aed_disc_total, var_aed_death_total,
                    var_patient_remain_total, var_occ_total, var_vac_total, var_ava_total, var_exc_total,
                    var_tfr_out_disc_total, var_total_los_total;
                SELECT 0
                INTO var_spec_cnt;

                IF var_description IS NULL
                THEN
                    BEGIN
                        /* add hosp code for HPI by ML on 27.07.1999 */
                        SELECT Description
                        INTO result_str_value
                        FROM Specialty
                        WHERE Specialty_code = var_spec
                          AND Hospital_code = par_hosp_code
                          AND Effective_date = (SELECT MAX(Effective_date)
                                                FROM Specialty
                                                WHERE Specialty_code = var_spec
                                                  AND Hospital_code = par_hosp_code
                                                  AND Effective_date < par_input_to_date);
                        IF FOUND
                        THEN
                            var_description := result_str_value;
                        END IF;
                        SELECT var_adm_hosp + var_adm,
                               var_ae_adm_hosp + var_ae_adm,
                               var_tfr_wcc_ws_hosp + var_tfr_wcc_ws,
                               var_tfr_wcc_bs_hosp + var_tfr_wcc_bs,
                               var_tfr_bcc_ws_hosp + var_tfr_bcc_ws,
                               var_tfr_bcc_bs_hosp + var_tfr_bcc_bs,
                               var_ip_disc_hosp + var_ip_disc,
                               var_ip_death_hosp + var_ip_death,
                               var_dp_disc_hosp + var_dp_disc,
                               var_dp_death_hosp + var_dp_death,
                               var_aed_disc_hosp + var_aed_disc,
                               var_aed_death_hosp + var_aed_death,
                               var_patient_remain_hosp + var_patient_remain,
                               var_occ_hosp + var_occ,
                               var_vac_hosp + var_vac,
                               var_ava_hosp + var_ava,
                               var_exc_hosp + var_exc,
                               var_tfr_out_disc_hosp + var_tfr_out_disc,
                               var_total_los_hosp + var_total_los
                        INTO var_adm_hosp, var_ae_adm_hosp, var_tfr_wcc_ws_hosp, var_tfr_wcc_bs_hosp,
                            var_tfr_bcc_ws_hosp, var_tfr_bcc_bs_hosp, var_ip_disc_hosp, var_ip_death_hosp,
                            var_dp_disc_hosp, var_dp_death_hosp, var_aed_disc_hosp, var_aed_death_hosp,
                            var_patient_remain_hosp, var_occ_hosp, var_vac_hosp, var_ava_hosp, var_exc_hosp,
                            var_tfr_out_disc_hosp, var_total_los_hosp;
                    END;
                END IF;
                INSERT INTO t$display
                VALUES (NULL, var_spec, var_description, var_adm, var_ae_adm, var_tfr_wcc_ws, var_tfr_wcc_bs,
                        var_tfr_bcc_ws, var_tfr_bcc_bs, var_ip_disc, var_ip_death, var_dp_disc, var_dp_death,
                        var_aed_disc, var_aed_death, var_patient_remain, var_occ, var_vac, var_ava, var_exc,
                        var_tfr_out_disc, var_total_los);
            END;
        END IF;
        SELECT var_adm_total + var_adm,
               var_ae_adm_total + var_ae_adm,
               var_tfr_wcc_ws_total + var_tfr_wcc_ws,
               var_tfr_wcc_bs_total + var_tfr_wcc_bs,
               var_tfr_bcc_ws_total + var_tfr_bcc_ws,
               var_tfr_bcc_bs_total + var_tfr_bcc_bs,
               var_ip_disc_total + var_ip_disc,
               var_ip_death_total + var_ip_death,
               var_dp_disc_total + var_dp_disc,
               var_dp_death_total + var_dp_death,
               var_aed_disc_total + var_aed_disc,
               var_aed_death_total + var_aed_death,
               var_patient_remain_total + var_patient_remain,
               var_occ_total + var_occ,
               var_vac_total + var_vac,
               var_ava_total + var_ava,
               var_exc_total + var_exc,
               var_tfr_out_disc_total + var_tfr_out_disc,
               var_total_los_total + var_total_los
        INTO var_adm_total, var_ae_adm_total, var_tfr_wcc_ws_total, var_tfr_wcc_bs_total, var_tfr_bcc_ws_total,
            var_tfr_bcc_bs_total, var_ip_disc_total, var_ip_death_total, var_dp_disc_total, var_dp_death_total,
            var_aed_disc_total, var_aed_death_total, var_patient_remain_total, var_occ_total, var_vac_total,
            var_ava_total, var_exc_total, var_tfr_out_disc_total, var_total_los_total;
        SELECT var_care,
               var_spec
        INTO var_prev_cc, var_prev_spec;
    END LOOP;

    IF var_spec_cnt > 0
    THEN
        INSERT INTO t$display
        VALUES (NULL, NULL, 'Specialty Total', var_adm_total, var_ae_adm_total, var_tfr_wcc_ws_total,
                var_tfr_wcc_bs_total, var_tfr_bcc_ws_total, var_tfr_bcc_bs_total, var_ip_disc_total, var_ip_death_total,
                var_dp_disc_total, var_dp_death_total, var_aed_disc_total, var_aed_death_total,
                var_patient_remain_total, var_occ_total, NULL, NULL, NULL, var_tfr_out_disc_total, var_total_los_total);
    END IF;
    /* * write HOSPITAL TOTAL * */
    INSERT INTO t$display
    VALUES (NULL, NULL, 'Hospital Total', var_adm_hosp, var_ae_adm_hosp, var_tfr_wcc_ws_hosp, var_tfr_wcc_bs_hosp,
            var_tfr_bcc_ws_hosp, var_tfr_bcc_bs_hosp, var_ip_disc_hosp, var_ip_death_hosp, var_dp_disc_hosp,
            var_dp_death_hosp, var_aed_disc_hosp, var_aed_death_hosp, var_patient_remain_hosp, var_occ_hosp,
            var_vac_hosp, var_ava_hosp, var_exc_hosp, var_tfr_out_disc_hosp, var_total_los_hosp);
    -- DROP TABLE t$result;
    /* --select @tmp_date = convert(char(30), getdate(),109) */
    /* --print ---end format display table %1!---, @tmp_date */
    /* select * from #display -- 20180105 */
           
    OPEN p_refcur FOR
        SELECT care,
               spec,
               description,
               adm,
               ae_adm,
               tfr_wcc_ws,
               tfr_wcc_bs,
               tfr_bcc_ws,
               tfr_bcc_bs,
               ip_disc,
               ip_death,
               dp_disc,
               dp_death,
               aed_disc,
               aed_death,
               patient_remain,
               occ,
               vac,
               ava,
               exc,
               tfr_out_disc,
               total_los
        FROM t$display;

    pas_return_code := 0;

    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_care_category_stat" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
