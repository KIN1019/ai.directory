-- DROP PROCEDURE hpi.hasp_adm_disc_by_ward(inout int4, in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_adm_disc_by_ward(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, IN par_input_ward character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* add hosp code for HPI by Mabel LAU on 27.07.1999 */
DECLARE
    result_date_value_1 TIMESTAMP WITHOUT TIME ZONE;
    result_date_value_2 TIMESTAMP WITHOUT TIME ZONE;
    result_str_value_1  VARCHAR(255);
    var_error           INTEGER;
    var_rowcount        INTEGER;
    var_errarg          VARCHAR(80);
    var_ward            VARCHAR(4);
    var_ind             VARCHAR(1);
    var_count           INTEGER;
    var_type            VARCHAR(3);
    var_prev_ward       VARCHAR(4);
    var_desc            VARCHAR(30);
    var_src_ind         VARCHAR(1);
    var_los             INTEGER;
    var_case            VARCHAR(12);
    var_prev_date       TIMESTAMP WITHOUT TIME ZONE;
    var_move_count      INTEGER;
    var_move_date       TIMESTAMP WITHOUT TIME ZONE;
    var_move_type       VARCHAR(1);
    var_adm_oth         INTEGER;
    var_adm_ae          INTEGER;
    var_adm_opd         INTEGER;
    var_adm_xin         INTEGER;
    var_adm_nb          INTEGER;
    var_tadm            INTEGER;
    var_dsch_conv       INTEGER;
    var_dsch_deth       INTEGER;
    var_dsch_home       INTEGER;
    var_dsch_hfu        INTEGER;
    var_dsch_acute      INTEGER;
    var_dsch_dama       INTEGER;
    var_dsch_miss       INTEGER;
    var_dsch_untr       INTEGER;
    var_dsch_oth        INTEGER;
    var_dsch_wa         INTEGER;
    var_tdsch           INTEGER;
    var_xout            INTEGER;
    var_tlos            REAL;
    var_alos            REAL;
    var_dp              INTEGER;
    var_hosp_adm_oth    INTEGER;
    var_hosp_adm_ae     INTEGER;
    var_hosp_adm_opd    INTEGER;
    var_hosp_adm_xin    INTEGER;
    var_hosp_adm_nb     INTEGER;
    var_hosp_tadm       INTEGER;
    var_hosp_dsch_conv  INTEGER;
    var_hosp_dsch_deth  INTEGER;
    var_hosp_dsch_home  INTEGER;
    var_hosp_dsch_hfu   INTEGER;
    var_hosp_dsch_acute INTEGER;
    var_hosp_dsch_dama  INTEGER;
    var_hosp_dsch_miss  INTEGER;
    var_hosp_dsch_untr  INTEGER;
    var_hosp_dsch_oth   INTEGER;
    var_hosp_dsch_wa    INTEGER;
    var_hosp_tdsch      INTEGER;
    var_hosp_xout       INTEGER;
    var_hosp_tlos       REAL;
    var_hosp_alos       REAL;
    var_hosp_dp         INTEGER;
    var_total           VARCHAR(5);
    var_adm_dt          TIMESTAMP WITHOUT TIME ZONE;
    var_disc_dt         TIMESTAMP WITHOUT TIME ZONE;
    adm_csr CURSOR FOR
        SELECT t.From_ward_code,
               c.Source_indicator,
               COUNT(*)
        FROM Transaction_log AS t,
             Case_view AS c
        WHERE t.Transaction_datetime >= par_input_from_date
          AND t.Transaction_datetime < par_input_to_date
          AND t.Transaction_type = '100'
          AND t.From_ward_code LIKE par_input_ward
          AND t.Cancel_flag IS NULL
          AND t.Case_no = c.Case_no
          AND t.Hospital_code = par_hosp_code
          AND c.Hospital_code = par_hosp_code
        GROUP BY t.From_ward_code, c.Source_indicator, t.Hospital_code;
    dsch_csr CURSOR FOR
        SELECT From_ward_code,
               Transaction_type,
               COUNT(*)
        FROM Transaction_log
        WHERE Transaction_datetime >= par_input_from_date
          AND Transaction_datetime < par_input_to_date
          AND Transaction_type LIKE '13_'
          AND From_ward_code LIKE par_input_ward
          AND Cancel_flag IS NULL
          AND Hospital_code = par_hosp_code
        GROUP BY From_ward_code, Transaction_type, Hospital_code;
    dp_csr CURSOR FOR
        SELECT t.From_ward_code,
               Transaction_type,
               COUNT(*)
        FROM Transaction_log AS t,
             Case_view AS c
        WHERE t.Transaction_datetime >= par_input_from_date
          AND t.Transaction_datetime < par_input_to_date
          AND t.Transaction_type LIKE '13_'
          AND t.From_ward_code LIKE par_input_ward
          AND t.Case_no = c.Case_no
          AND DATE_PART('days', c.Discharge_datetime::timestamp::date::timestamp -
                                c.Admission_datetime::timestamp::date::timestamp) = 0
          AND COALESCE(c.Source_indicator, ' ') <> '3'
          AND t.Cancel_flag IS NULL
          AND COALESCE(t.From_ward_code, ' ') <> 'AE01'
          AND t.Hospital_code = par_hosp_code
          AND c.Hospital_code = par_hosp_code
        GROUP BY t.From_ward_code, t.Transaction_type, t.Hospital_code;
    los_csr CURSOR FOR
        SELECT Case_no
        FROM Transaction_log
        WHERE Transaction_datetime >= par_input_from_date
          AND Transaction_datetime < par_input_to_date
          AND Transaction_type LIKE '13_'
          AND From_ward_code LIKE par_input_ward
          AND Cancel_flag IS NULL
          AND Hospital_code = par_hosp_code;
    move_csr CURSOR FOR
        SELECT Movement_count,
               Ward_code,
               Movement_datetime,
               Movement_type
        FROM Movement
        WHERE Case_no = var_case
          AND Hospital_code = par_hosp_code;
BEGIN
    /*
    Admission and Discharge Summary By Ward
    
            parameter name          Description
            @hosp_code              Hospital_code
    	@input_from_date        From date to be processed
    	@input_to_date          To date to be processed
       @input_ward             Required ward code
    20030911 SL : add 2 new output: new born / walk away
    */
    SELECT 1 * INTERVAL '1 day' + par_input_to_date::TIMESTAMP
    INTO par_input_to_date;

    DROP TABLE IF EXISTS t$tx_table;
    CREATE TEMPORARY TABLE t$tx_table
    (
        tx_ward       VARCHAR(5),
        tx_adm_oth    INTEGER NULL,
        tx_adm_ae     INTEGER NULL,
        tx_adm_opd    INTEGER NULL,
        tx_adm_xin    INTEGER NULL,
        tx_adm_nb     INTEGER NULL,
        tx_tadm       INTEGER NULL,
        tx_dsch_conv  INTEGER NULL,
        tx_dsch_deth  INTEGER NULL,
        tx_dsch_hfu   INTEGER NULL,
        tx_dsch_home  INTEGER NULL,
        tx_dsch_acute INTEGER NULL,
        tx_dsch_dama  INTEGER NULL,
        tx_dsch_miss  INTEGER NULL,
        tx_dsch_untr  INTEGER NULL,
        tx_dsch_oth   INTEGER NULL,
        tx_dsch_wa    INTEGER NULL,
        tx_tdsch      INTEGER NULL,
        tx_xout       INTEGER NULL,
        tx_tlos       REAL    NULL,
        tx_alos       REAL    NULL,
        tx_dp         INTEGER NULL
    );
    CREATE UNIQUE INDEX tx_index ON t$tx_table
        (tx_ward);
    /* ******************************************* */
    /* cal admission data */
    /* ******************************************* */
    /* add hosp code for HPI by ML on 27.07.1999 */
    OPEN adm_csr;
    FETCH adm_csr INTO var_ward, var_ind, var_count;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            IF NOT EXISTS (SELECT *
                           FROM t$tx_table
                           WHERE tx_ward = var_ward) THEN
                INSERT INTO t$tx_table
                VALUES (var_ward, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            END IF;

            IF var_ind = '3' THEN
                UPDATE t$tx_table
                SET tx_adm_ae = tx_adm_ae + var_count
                WHERE tx_ward = var_ward;
            ELSE
                IF var_ind = '4' THEN
                    UPDATE t$tx_table
                    SET tx_adm_opd = tx_adm_opd + var_count
                    WHERE tx_ward = var_ward;
                ELSE
                    IF var_ind = '5' THEN
                        UPDATE t$tx_table
                        SET tx_adm_xin = tx_adm_xin + var_count
                        WHERE tx_ward = var_ward;
                    ELSE
                        IF var_ind = '8' THEN /* 20030911 SL: new born */
                            UPDATE t$tx_table
                            SET tx_adm_nb = tx_adm_nb + var_count
                            WHERE tx_ward = var_ward;
                        ELSE
                            UPDATE t$tx_table
                            SET tx_adm_oth = tx_adm_oth + var_count
                            WHERE tx_ward = var_ward;
                        END IF;
                    END IF;
                END IF;
            END IF;
            FETCH adm_csr INTO var_ward, var_ind, var_count;
        END LOOP;
    CLOSE adm_csr;
    /* *************************** */
    /* cal disc data */
    /* *************************** */
    /* add hosp code for HPI by ML on 27.07.1999 */
    OPEN dsch_csr;
    FETCH dsch_csr INTO var_ward, var_type, var_count;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            IF NOT EXISTS (SELECT *
                           FROM t$tx_table
                           WHERE tx_ward = var_ward) THEN
                INSERT INTO t$tx_table
                VALUES (var_ward, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            END IF;

            IF var_type = '130' THEN
                UPDATE t$tx_table
                SET tx_dsch_conv = tx_dsch_conv + var_count
                WHERE tx_ward = var_ward;
            ELSE
                IF var_type = '131' THEN
                    UPDATE t$tx_table
                    SET tx_dsch_deth = tx_dsch_deth + var_count
                    WHERE tx_ward = var_ward;
                ELSE
                    IF var_type = '132' THEN
                        UPDATE t$tx_table
                        SET tx_dsch_hfu = tx_dsch_hfu + var_count
                        WHERE tx_ward = var_ward;
                    ELSE
                        IF var_type = '133' THEN
                            UPDATE t$tx_table
                            SET tx_dsch_home = tx_dsch_home + var_count
                            WHERE tx_ward = var_ward;
                        ELSE
                            IF var_type = '134' THEN
                                UPDATE t$tx_table
                                SET tx_dsch_acute = tx_dsch_acute + var_count
                                WHERE tx_ward = var_ward;
                            ELSE
                                IF var_type = '135' THEN
                                    UPDATE t$tx_table
                                    SET tx_dsch_dama = tx_dsch_dama + var_count
                                    WHERE tx_ward = var_ward;
                                ELSE
                                    IF var_type = '136' THEN
                                        UPDATE t$tx_table
                                        SET tx_dsch_miss = tx_dsch_miss + var_count
                                        WHERE tx_ward = var_ward;
                                    ELSE
                                        IF var_type = '137' THEN
                                            UPDATE t$tx_table
                                            SET tx_dsch_untr = tx_dsch_untr + var_count
                                            WHERE tx_ward = var_ward;
                                        ELSE
                                            IF var_type = '13M' THEN /* 20030911 SL : walk away */
                                                UPDATE t$tx_table
                                                SET tx_dsch_wa = tx_dsch_wa + var_count
                                                WHERE tx_ward = var_ward;
                                            ELSE
                                                UPDATE t$tx_table
                                                SET tx_dsch_oth = tx_dsch_oth + var_count
                                                WHERE tx_ward = var_ward;
                                            END IF;
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;
            FETCH dsch_csr INTO var_ward, var_type, var_count;
        END LOOP;
    CLOSE dsch_csr;
    /* ************************* */
    /* cal day patient */
    /* ************************* */
    /* add hosp code for HPI by ML on 27.07.1999 */
    OPEN dp_csr;
    FETCH dp_csr INTO var_ward, var_type, var_count;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            IF NOT EXISTS (SELECT *
                           FROM t$tx_table
                           WHERE tx_ward = var_ward) THEN
                INSERT INTO t$tx_table
                VALUES (var_ward, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            END IF;
            UPDATE t$tx_table
            SET tx_dp = tx_dp + var_count
            WHERE tx_ward = var_ward;
            FETCH dp_csr INTO var_ward, var_type, var_count;
        END LOOP;
    CLOSE dp_csr;
    /* ************************************************************* */
    /* Calculate Total LOS and Transfer Out of Discharged Patients */
    /* ************************************************************* */
    /* add hosp code for HPI by ML on 27.07.1999 */
    /* add hosp code for HPI by ML on 27.07.1999 */
    OPEN los_csr;
    FETCH los_csr INTO var_case;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            /* add hosp code for HPI by ML on 27.07.1999 */
            SELECT Admission_datetime,
                   Discharge_datetime
            -- INTO var_adm_dt, var_disc_dt
            INTO result_date_value_1,result_date_value_2
            FROM Case_view
            WHERE Case_no = var_case
              AND Hospital_code = par_hosp_code;
            IF FOUND THEN
                var_adm_dt := result_date_value_1;
                var_disc_dt := result_date_value_2;
            END IF;

            OPEN move_csr;
            FETCH move_csr INTO var_move_count, var_ward, var_move_date, var_move_type;

            WHILE (CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
                END) = 0
                LOOP
                    IF var_move_count = 1 THEN
                        SELECT var_ward,
                               var_move_date
                        INTO var_prev_ward, var_prev_date;
                    END IF;

                    IF COALESCE(var_ward, ' ') <> COALESCE(var_prev_ward, ' ') OR var_move_type = 'D' THEN
                        BEGIN
                            IF var_prev_ward = 'HOME' THEN
                                SELECT 0
                                INTO var_los;
                            ELSE
                                SELECT DATE_PART('days', var_move_date::timestamp::date::timestamp -
                                                         var_prev_date::timestamp::date::timestamp)
                                INTO var_los;
                            END IF;

                            IF var_prev_ward = 'HOME' OR var_ward = 'HOME' THEN
                                SELECT 0
                                INTO var_xout;
                            ELSE
                                IF var_move_type = 'D' THEN
                                    SELECT 0
                                    INTO var_xout;
                                ELSE
                                    SELECT 1
                                    INTO var_xout;
                                END IF;
                            END IF;

                            IF var_los = 0 AND var_move_type = 'D' AND COALESCE(var_prev_ward, ' ') <> 'HOME' THEN
                                BEGIN
                                    /* add hosp code for HPI by ML on 27.07.1999 */
                                    SELECT Source_indicator
                                    -- INTO var_src_ind
                                    INTO result_str_value_1
                                    FROM Case_view
                                    WHERE Case_no = var_case
                                      AND Hospital_code = par_hosp_code;
                                    IF FOUND THEN
                                        var_src_ind := result_str_value_1;
                                    END IF;

                                    IF var_src_ind = '3' AND
                                       DATE_PART('days', var_disc_dt::timestamp::date::timestamp -
                                                         var_adm_dt::timestamp::date::timestamp) = 0 THEN
                                        SELECT 1
                                        INTO var_los;
                                    END IF;
                                END;
                            END IF;

                            IF EXISTS (SELECT *
                                       FROM t$tx_table
                                       WHERE tx_ward = var_prev_ward) THEN
                                UPDATE t$tx_table
                                SET tx_xout = tx_xout + var_xout,
                                    tx_tlos = tx_tlos + var_los
                                WHERE tx_ward = var_prev_ward;
                            ELSE
                                INSERT INTO t$tx_table
                                VALUES (var_prev_ward, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, var_xout,
                                        var_los, 0, 0);
                            END IF;
                            SELECT var_ward,
                                   var_move_date
                            INTO var_prev_ward, var_prev_date;
                        END;
                    END IF;
                    FETCH move_csr INTO var_move_count, var_ward, var_move_date, var_move_type;
                END LOOP;
            CLOSE move_csr;
            FETCH los_csr INTO var_case;
        END LOOP;
    CLOSE los_csr;
    /* ****************************** */
    /* cal adm total and disc total */
    /* ****************************** */
    UPDATE t$tx_table
    SET tx_tadm  = tx_adm_oth + tx_adm_ae + tx_adm_opd + tx_adm_xin + tx_adm_nb,
        tx_tdsch = tx_dsch_conv + tx_dsch_deth + tx_dsch_home + tx_dsch_hfu + tx_dsch_acute +
                   tx_dsch_dama + tx_dsch_miss + tx_dsch_untr + tx_dsch_oth + tx_dsch_wa;
    UPDATE t$tx_table
    SET tx_alos = tx_tlos / (tx_tdsch + tx_xout - tx_dp)
    WHERE (tx_tdsch + tx_xout - tx_dp <> 0);
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
           0,
           0
    INTO var_hosp_adm_oth, var_hosp_adm_ae, var_hosp_adm_opd, var_hosp_adm_xin, var_hosp_adm_nb, var_hosp_tadm, var_hosp_dsch_conv, var_hosp_dsch_deth, var_hosp_dsch_home, var_hosp_dsch_hfu, var_hosp_dsch_acute, var_hosp_dsch_dama, var_hosp_dsch_miss, var_hosp_dsch_untr, var_hosp_dsch_oth, var_hosp_dsch_wa, var_hosp_tdsch, var_hosp_xout, var_hosp_tlos, var_hosp_dp;
    SELECT SUM(tx_adm_oth),
           SUM(tx_adm_ae),
           SUM(tx_adm_opd),
           SUM(tx_adm_xin),
           SUM(tx_adm_nb),
           SUM(tx_tadm),
           SUM(tx_dsch_conv),
           SUM(tx_dsch_deth),
           SUM(tx_dsch_home),
           SUM(tx_dsch_hfu),
           SUM(tx_dsch_acute),
           SUM(tx_dsch_dama),
           SUM(tx_dsch_miss),
           SUM(tx_dsch_untr),
           SUM(tx_dsch_oth),
           SUM(tx_dsch_wa),
           SUM(tx_tdsch),
           SUM(tx_xout),
           SUM(tx_tlos),
           SUM(tx_dp)
    INTO var_hosp_adm_oth, var_hosp_adm_ae, var_hosp_adm_opd, var_hosp_adm_xin, var_hosp_adm_nb, var_hosp_tadm, var_hosp_dsch_conv, var_hosp_dsch_deth, var_hosp_dsch_home, var_hosp_dsch_hfu, var_hosp_dsch_acute, var_hosp_dsch_dama, var_hosp_dsch_miss, var_hosp_dsch_untr, var_hosp_dsch_oth, var_hosp_dsch_wa, var_hosp_tdsch, var_hosp_xout, var_hosp_tlos, var_hosp_dp
    FROM t$tx_table;

    IF (var_hosp_tdsch - var_hosp_dp <> 0) THEN
        SELECT var_hosp_tlos / (var_hosp_tdsch - var_hosp_dp)
        INTO var_hosp_alos;
    ELSE
        SELECT 0
        INTO var_hosp_alos;
    END IF;
    CLUSTER t$tx_table USING tx_index;
    SELECT 'Total'
    INTO var_total;
    INSERT INTO t$tx_table
    VALUES (var_total, var_hosp_adm_oth, var_hosp_adm_ae, var_hosp_adm_opd, var_hosp_adm_xin, var_hosp_adm_nb,
            var_hosp_tadm, var_hosp_dsch_conv, var_hosp_dsch_deth, var_hosp_dsch_hfu, var_hosp_dsch_home,
            var_hosp_dsch_acute, var_hosp_dsch_dama, var_hosp_dsch_miss, var_hosp_dsch_untr, var_hosp_dsch_oth,
            var_hosp_dsch_wa, var_hosp_tdsch, var_hosp_xout, var_hosp_tlos, var_hosp_alos, var_hosp_dp);
    OPEN p_refcur FOR
        SELECT tx_ward,
               tx_adm_oth,
               tx_adm_ae,
               tx_adm_opd,
               tx_adm_xin,
               tx_adm_nb,
               tx_tadm,
               tx_dsch_conv,
               tx_dsch_deth,
               tx_dsch_hfu,
               tx_dsch_home,
               tx_dsch_acute,
               tx_dsch_dama,
               tx_dsch_miss,
               tx_dsch_untr,
               tx_dsch_oth,
               tx_dsch_wa,
               tx_tdsch,
               tx_xout,
               tx_tlos,
               tx_alos
        FROM t$tx_table;
    pas_return_code := 0;
    RETURN;
END;
$procedure$;

;ALTER PROCEDURE "hasp_adm_disc_by_ward" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
