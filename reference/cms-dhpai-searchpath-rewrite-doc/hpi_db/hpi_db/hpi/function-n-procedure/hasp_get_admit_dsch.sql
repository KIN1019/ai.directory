-- DROP PROCEDURE hasp_get_admit_dsch(inout int4, in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_get_admit_dsch(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, IN par_input_spec character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    result_date_value_1 TIMESTAMP WITHOUT TIME ZONE;
    result_date_value_2 TIMESTAMP WITHOUT TIME ZONE;
    result_str_value_1  VARCHAR(255);
    var_error           INTEGER;
    var_rowcount        INTEGER;
    var_errarg          VARCHAR(80);
    var_spec            VARCHAR(4);
    var_ind             VARCHAR(1);
    var_count           INTEGER;
    var_type            VARCHAR(3);
    var_loc             VARCHAR(4);
    var_prev_spec       VARCHAR(4);
    var_prev_loc        VARCHAR(4);
    var_desc            VARCHAR(30);
    var_src_ind         VARCHAR(1);
    var_los             INTEGER;
    var_case            VARCHAR(12);
    var_prev_date       TIMESTAMP WITHOUT TIME ZONE;
    var_move_count      INTEGER;
    var_move_date       TIMESTAMP WITHOUT TIME ZONE;
    var_move_type       VARCHAR(1);
    var_adm_date        TIMESTAMP WITHOUT TIME ZONE;
    var_dsch_date       TIMESTAMP WITHOUT TIME ZONE;
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
    var_spec_adm_oth    INTEGER;
    var_spec_adm_ae     INTEGER;
    var_spec_adm_opd    INTEGER;
    var_spec_adm_xin    INTEGER;
    var_spec_adm_nb     INTEGER;
    var_spec_tadm       INTEGER;
    var_spec_dsch_conv  INTEGER;
    var_spec_dsch_deth  INTEGER;
    var_spec_dsch_home  INTEGER;
    var_spec_dsch_hfu   INTEGER;
    var_spec_dsch_acute INTEGER;
    var_spec_dsch_dama  INTEGER;
    var_spec_dsch_miss  INTEGER;
    var_spec_dsch_untr  INTEGER;
    var_spec_dsch_oth   INTEGER;
    var_spec_dsch_wa    INTEGER;
    var_spec_tdsch      INTEGER;
    var_spec_xout       INTEGER;
    var_spec_tlos       REAL;
    var_spec_alos       REAL;
    var_spec_dp         INTEGER;
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
    adm_csr CURSOR FOR
        SELECT t.From_specialty_code,
               t.From_treatment_location,
               c.Source_indicator,
               COUNT(*)
        FROM Transaction_log AS t,
             Case_view AS c
        WHERE t.Transaction_datetime >= par_input_from_date
          AND t.Transaction_datetime < par_input_to_date
          AND t.Transaction_type = '100'
          AND (t.From_specialty_code LIKE par_input_spec OR t.From_treatment_location LIKE par_input_spec)
          AND t.Cancel_flag IS NULL
          AND t.Case_no = c.Case_no
          AND t.Hospital_code = par_hosp_code
          AND c.Hospital_code = par_hosp_code
        GROUP BY t.From_specialty_code, t.From_treatment_location, c.Source_indicator, t.Hospital_code;
    dsch_csr CURSOR FOR
        SELECT From_specialty_code,
               From_treatment_location,
               Transaction_type,
               COUNT(*)
        FROM Transaction_log
        WHERE Transaction_datetime >= par_input_from_date
          AND Transaction_datetime < par_input_to_date
          AND Transaction_type LIKE '13_'
          AND (From_specialty_code LIKE par_input_spec OR From_treatment_location LIKE par_input_spec)
          AND Cancel_flag IS NULL
          AND Hospital_code = par_hosp_code
        GROUP BY From_specialty_code, From_treatment_location, Transaction_type, Transaction_log.Hospital_code;
    dp_csr CURSOR FOR
        SELECT t.From_specialty_code,
               t.From_treatment_location,
               t.Transaction_type,
               COUNT(*)
        FROM Transaction_log AS t,
             Case_view AS c
        WHERE t.Transaction_datetime >= par_input_from_date
          AND t.Transaction_datetime < par_input_to_date
          AND t.Transaction_type LIKE '13_'
          AND (t.From_specialty_code LIKE par_input_spec OR t.From_treatment_location LIKE par_input_spec)
          AND t.Case_no = c.Case_no
          AND DATE_PART('days', c.Discharge_datetime::timestamp::date::timestamp -
                                c.Admission_datetime::timestamp::date::timestamp) = 0
          AND COALESCE(c.Source_indicator, ' ') <> '3'
          AND t.Cancel_flag IS NULL
          AND t.Hospital_code = par_hosp_code
          AND c.Hospital_code = par_hosp_code
        GROUP BY t.From_specialty_code, t.From_treatment_location, t.Transaction_type, t.Hospital_code;
    los_csr CURSOR FOR
        SELECT Case_no
        FROM Transaction_log
        WHERE Transaction_datetime >= par_input_from_date
          AND Transaction_datetime < par_input_to_date
          AND Transaction_type LIKE '13_'
          AND (From_specialty_code LIKE par_input_spec OR From_treatment_location LIKE par_input_spec)
          AND Cancel_flag IS NULL
          AND Hospital_code = par_hosp_code;
    move_csr CURSOR FOR
        SELECT Movement_count,
               Specialty_code,
               Treatment_location,
               Movement_datetime,
               Movement_type
        FROM Movement
        WHERE Case_no = var_case
          AND Hospital_code = par_hosp_code;
    loc_csr CURSOR FOR
        SELECT tx_spec,
               tx_loc,
               tx_adm_oth,
               tx_adm_ae,
               tx_adm_opd,
               tx_adm_xin,
               tx_adm_nb,
               tx_tadm,
               tx_dsch_conv,
               tx_dsch_deth,
               tx_dsch_home,
               tx_dsch_hfu,
               tx_dsch_acute,
               tx_dsch_dama,
               tx_dsch_miss,
               tx_dsch_untr,
               tx_dsch_oth,
               tx_dsch_wa,
               tx_tdsch,
               tx_xout,
               tx_tlos,
               tx_alos,
               tx_dp
        FROM t$tx_table
        WHERE tx_loc IS NOT NULL;
    dsp_csr CURSOR FOR
        SELECT tx_spec,
               tx_loc,
               tx_adm_oth,
               tx_adm_ae,
               tx_adm_opd,
               tx_adm_xin,
               tx_adm_nb,
               tx_tadm,
               tx_dsch_conv,
               tx_dsch_deth,
               tx_dsch_home,
               tx_dsch_hfu,
               tx_dsch_acute,
               tx_dsch_dama,
               tx_dsch_miss,
               tx_dsch_untr,
               tx_dsch_oth,
               tx_dsch_wa,
               tx_tdsch,
               tx_xout,
               tx_tlos,
               tx_alos,
               tx_dp
        FROM t$tx_table
        WHERE COALESCE(tx_spec, ' ') <> 'HOME'
          AND (tx_adm_oth <> 0 OR tx_adm_ae <> 0 OR tx_adm_opd <> 0 OR tx_adm_xin <> 0 OR tx_adm_nb <> 0 OR
               tx_dsch_conv <> 0 OR tx_dsch_deth <> 0 OR tx_dsch_home <> 0 OR tx_dsch_hfu <> 0 OR tx_dsch_acute <> 0 OR
               tx_dsch_dama <> 0 OR tx_dsch_miss <> 0 OR tx_dsch_untr <> 0 OR tx_dsch_oth <> 0 OR tx_dsch_wa <> 0 OR
               tx_xout <> 0 OR tx_tlos <> 0)
        ORDER BY tx_spec NULLS FIRST, tx_loc NULLS FIRST;
BEGIN
    /*
    Admission and Discharge Summary By Specialty
    
            parameter name          Description
            @hosp_code              Hospital Code
            @input_from_date        From date to be processed
            @input_to_date          To date to be processed
            @input_spec             Required ward code
    
            27.07.1999 - Add hosp code for HPI by Mabel LAU
    	20030911 SL - Add 2 output : newborn / walk away
    */
    SELECT 1 * INTERVAL '1 day' + par_input_to_date::TIMESTAMP
    INTO par_input_to_date;

    DROP TABLE IF EXISTS t$tx_table;
    CREATE TEMPORARY TABLE t$tx_table
    (
        tx_spec       VARCHAR(4),
        tx_loc        VARCHAR(4) NULL,
        tx_adm_oth    INTEGER    NULL,
        tx_adm_ae     INTEGER    NULL,
        tx_adm_opd    INTEGER    NULL,
        tx_adm_xin    INTEGER    NULL,
        tx_adm_nb     INTEGER    NULL,
        tx_tadm       INTEGER    NULL,
        tx_dsch_conv  INTEGER    NULL,
        tx_dsch_deth  INTEGER    NULL,
        tx_dsch_home  INTEGER    NULL,
        tx_dsch_hfu   INTEGER    NULL,
        tx_dsch_acute INTEGER    NULL,
        tx_dsch_dama  INTEGER    NULL,
        tx_dsch_miss  INTEGER    NULL,
        tx_dsch_untr  INTEGER    NULL,
        tx_dsch_oth   INTEGER    NULL,
        tx_dsch_wa    INTEGER    NULL,
        tx_tdsch      INTEGER    NULL,
        tx_xout       INTEGER    NULL,
        tx_tlos       REAL       NULL,
        tx_alos       REAL       NULL,
        tx_dp         INTEGER    NULL
    );
    CREATE UNIQUE INDEX tx_index ON t$tx_table
        (tx_spec, tx_loc);
    /* changed by Karen at 1996-04-25 for cpi */
    /* before changes are comment for select from Case_view written below */
    /*
    declare adm_csr cursor for
    select From_specialty_code, From_treatment_location, Source_indicator,
            count(*)
    from Transaction_log t, Case c
    where Transaction_datetime >= @input_from_date
    and Transaction_datetime < @input_to_date
    and Transaction_type = '100'
    and (From_specialty_code like @input_spec
    or From_treatment_location like @input_spec)
    and Cancel_flag is null
    and t.Case_no = c.Case_no
    group by From_specialty_code, From_treatment_location, Source_indicator
    for read only
    */
    /* end of comment for change to select from Case_view written below */
    /* modify start for select from Case_view */
    /* end of modify for select from Case_view */
    OPEN adm_csr;
    FETCH adm_csr INTO var_spec, var_loc, var_ind, var_count;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            IF NOT EXISTS (SELECT *
                           FROM t$tx_table
                           WHERE tx_spec = var_spec
                             AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null')) THEN
                INSERT INTO t$tx_table
                VALUES (var_spec, var_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0);
            END IF;

            IF var_ind = '3' THEN
                UPDATE t$tx_table
                SET tx_adm_ae = tx_adm_ae + var_count
                WHERE tx_spec = var_spec
                  AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
            ELSE
                IF var_ind = '4' THEN
                    UPDATE t$tx_table
                    SET tx_adm_opd = tx_adm_opd + var_count
                    WHERE tx_spec = var_spec
                      AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
                ELSE
                    IF var_ind = '5' THEN
                        UPDATE t$tx_table
                        SET tx_adm_xin = tx_adm_xin + var_count
                        WHERE tx_spec = var_spec
                          AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
                    ELSE
                        IF var_ind = '8' THEN /* 20030911 SL : new born */
                            UPDATE t$tx_table
                            SET tx_adm_nb = tx_adm_nb + var_count
                            WHERE tx_spec = var_spec
                              AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
                        ELSE
                            UPDATE t$tx_table
                            SET tx_adm_oth = tx_adm_oth + var_count
                            WHERE tx_spec = var_spec
                              AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
                        END IF;
                    END IF;
                END IF;
            END IF;
            FETCH adm_csr INTO var_spec, var_loc, var_ind, var_count;
        END LOOP;
    CLOSE adm_csr;
    OPEN dsch_csr;
    FETCH dsch_csr INTO var_spec, var_loc, var_type, var_count;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            IF NOT EXISTS (SELECT *
                           FROM t$tx_table
                           WHERE tx_spec = var_spec
                             AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null')) THEN
                INSERT INTO t$tx_table
                VALUES (var_spec, var_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0);
            END IF;

            IF var_type = '130' THEN
                UPDATE t$tx_table
                SET tx_dsch_conv = tx_dsch_conv + var_count
                WHERE tx_spec = var_spec
                  AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
            ELSE
                IF var_type = '131' THEN
                    UPDATE t$tx_table
                    SET tx_dsch_deth = tx_dsch_deth + var_count
                    WHERE tx_spec = var_spec
                      AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
                ELSE
                    IF var_type = '132' THEN
                        UPDATE t$tx_table
                        SET tx_dsch_hfu = tx_dsch_hfu + var_count
                        WHERE tx_spec = var_spec
                          AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
                    ELSE
                        IF var_type = '133' THEN
                            UPDATE t$tx_table
                            SET tx_dsch_home = tx_dsch_home + var_count
                            WHERE tx_spec = var_spec
                              AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
                        ELSE
                            IF var_type = '134' THEN
                                UPDATE t$tx_table
                                SET tx_dsch_acute = tx_dsch_acute + var_count
                                WHERE tx_spec = var_spec
                                  AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
                            ELSE
                                IF var_type = '135' THEN
                                    UPDATE t$tx_table
                                    SET tx_dsch_dama = tx_dsch_dama + var_count
                                    WHERE tx_spec = var_spec
                                      AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
                                ELSE
                                    IF var_type = '136' THEN
                                        UPDATE t$tx_table
                                        SET tx_dsch_miss = tx_dsch_miss + var_count
                                        WHERE tx_spec = var_spec
                                          AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
                                    ELSE
                                        IF var_type = '137' THEN
                                            UPDATE t$tx_table
                                            SET tx_dsch_untr = tx_dsch_untr + var_count
                                            WHERE tx_spec = var_spec
                                              AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
                                        ELSE
                                            IF var_type = '13M' THEN /* 20030911 SL : Walk Away */
                                                UPDATE t$tx_table
                                                SET tx_dsch_wa = tx_dsch_wa + var_count
                                                WHERE tx_spec = var_spec
                                                  AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
                                            ELSE
                                                UPDATE t$tx_table
                                                SET tx_dsch_oth = tx_dsch_oth + var_count
                                                WHERE tx_spec = var_spec
                                                  AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
                                            END IF;
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;
            FETCH dsch_csr INTO var_spec, var_loc, var_type, var_count;
        END LOOP;
    CLOSE dsch_csr;
    /* changed by Karen at 1996-04-25 for cpi */
    /* before changes are comment for select from Case_view written below */
    /*
    declare dp_csr cursor for
    select From_specialty_code, From_treatment_location, Transaction_type,
            count(*)
    from Transaction_log t, Case c
    where Transaction_datetime >= @input_from_date
    and Transaction_datetime < @input_to_date
    and Transaction_type like '13_'
    and (From_specialty_code like @input_spec
    or From_treatment_location like @input_spec)
    and t.Case_no = c.Case_no
    and datediff(dd, Admission_datetime, Discharge_datetime) = 0
    and Source_indicator <> '3'
    and Cancel_flag is null
    group by From_specialty_code, From_treatment_location, Transaction_type
    for read only
    */
    /* end of comment for change to select from Case_view written below */
    /* modify start for select from Case_view */
    /* end of modify for select from Case_view */
    OPEN dp_csr;
    FETCH dp_csr INTO var_spec, var_loc, var_type, var_count;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            IF NOT EXISTS (SELECT *
                           FROM t$tx_table
                           WHERE tx_spec = var_spec
                             AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null')) THEN
                INSERT INTO t$tx_table
                VALUES (var_spec, var_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0);
            END IF;
            UPDATE t$tx_table
            SET tx_dp = tx_dp + var_count
            WHERE tx_spec = var_spec
              AND COALESCE(tx_loc, 'null') = COALESCE(var_loc, 'null');
            FETCH dp_csr INTO var_spec, var_loc, var_type, var_count;
        END LOOP;
    CLOSE dp_csr;

    /* Calculate Total LOS and Transfer Out of Discharged Patients */
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
            INTO result_date_value_1,result_date_value_2
            FROM Case_view
            WHERE Case_no = var_case
              AND Hospital_code = par_hosp_code;
            IF FOUND THEN
                var_adm_date = result_date_value_1;
                var_dsch_date = result_date_value_2;
            END IF;

            OPEN move_csr;
            FETCH move_csr INTO var_move_count, var_spec, var_loc, var_move_date, var_move_type;

            WHILE (CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
                END) = 0
                LOOP
                    IF var_move_count = 1 THEN
                        SELECT var_spec,
                               var_loc,
                               var_move_date
                        INTO var_prev_spec, var_prev_loc, var_prev_date;
                    ELSE
                        BEGIN
                            IF COALESCE(var_spec, ' ') <> COALESCE(var_prev_spec, ' ')
                                OR COALESCE(var_loc, ' ') <> COALESCE(var_prev_loc, ' ')
                                OR var_move_type = 'D' THEN
                                BEGIN
                                    IF var_prev_spec = 'HOME' THEN
                                        SELECT 0
                                        INTO var_los;
                                    ELSE
                                        SELECT DATE_PART('days', var_move_date::timestamp::date::timestamp -
                                                                 var_prev_date::timestamp::date::timestamp)
                                        INTO var_los;
                                    END IF;

                                    IF var_prev_spec = 'HOME' OR var_spec = 'HOME' THEN
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

                                    IF var_los = 0 AND var_move_type = 'D' AND
                                       COALESCE(var_prev_spec, ' ') <> 'HOME' AND
                                       DATE_PART('days', var_dsch_date::timestamp::date::timestamp -
                                                         var_adm_date::timestamp::date::timestamp) = 0 THEN
                                        BEGIN
                                            /*
                                            before changes are comment for
                                            select from Case_view
                                            */
                                            /*
                                            select @src_ind = Source_indicator
                                                    from Case
                                                    where Case_no = @case
                                            if @src_ind = '3'
                                                    select @los = 1
                                            */
                                            /* end of comment */
                                            /*
                                            modify start to select from
                                            Case_view
                                            */
                                            /* add hosp code for HPI by ML on 27.07.1999 */
                                            SELECT Source_indicator
                                            INTO result_str_value_1
                                            FROM Case_view
                                            WHERE Case_no = var_case
                                              AND Hospital_code = par_hosp_code;
                                            IF FOUND THEN
                                                var_src_ind = result_str_value_1;
                                            END IF;

                                            IF var_src_ind = '3' THEN
                                                SELECT 1
                                                INTO var_los;
                                            END IF;
                                            /*
                                            end of modify to select from
                                            Case_view
                                            */
                                        END;
                                    END IF;

                                    IF EXISTS (SELECT *
                                               FROM t$tx_table
                                               WHERE tx_spec = var_prev_spec
                                                 AND COALESCE(tx_loc, 'null') = COALESCE(var_prev_loc, 'null')) THEN
                                        UPDATE t$tx_table
                                        SET tx_xout = tx_xout + var_xout,
                                            tx_tlos = tx_tlos + var_los
                                        WHERE tx_spec = var_prev_spec
                                          AND COALESCE(tx_loc, 'null') = COALESCE(var_prev_loc, 'null');
                                    ELSE
                                        INSERT INTO t$tx_table
                                        VALUES (var_prev_spec, var_prev_loc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                                0, 0, 0, var_xout, var_los, NULL, 0);
                                    END IF;
                                    SELECT var_spec,
                                           var_loc,
                                           var_move_date
                                    INTO var_prev_spec, var_prev_loc, var_prev_date;
                                END;
                            END IF;
                        END;
                    END IF;
                    FETCH move_csr INTO var_move_count, var_spec, var_loc, var_move_date, var_move_type;
                END LOOP;
            CLOSE move_csr;
            FETCH los_csr INTO var_case;
        END LOOP;
    CLOSE los_csr;
    /*
    update #tx_table set
            tx_desc =
            (select Description from Specialty
            where Specialty_code = a.tx_spec
    	and Effective=date = (select max(Effective_date) from Specialty
    			      where Effective_date < @input_to_date
    			      and Specialty_code = a.tx_spec ))
            from #tx_table a
    
    select * from #tx_table
    where tx_adm_oth <> 0
    or tx_adm_ae <> 0
    or tx_adm_opd <> 0
    or tx_adm_xin <> 0
    or tx_dsch_conv <> 0
    or tx_dsch_deth <> 0
    or tx_dsch_home <> 0
    or tx_dsch_hfu <> 0
    or tx_dsch_acute <> 0
    or tx_dsch_dama <> 0
    or tx_dsch_miss <> 0
    or tx_dsch_untr <> 0
    or tx_dsch_oth <> 0
    */
    /* Add Treatment_location's figures to original specialty */
    OPEN loc_csr;
    FETCH loc_csr INTO var_spec, var_loc, var_adm_oth, var_adm_ae, var_adm_opd, var_adm_xin, var_adm_nb, var_tadm, var_dsch_conv, var_dsch_deth, var_dsch_home, var_dsch_hfu, var_dsch_acute, var_dsch_dama, var_dsch_miss, var_dsch_untr, var_dsch_oth, var_dsch_wa, var_tdsch, var_xout, var_tlos, var_alos, var_dp;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            IF NOT EXISTS (SELECT *
                           FROM t$tx_table
                           WHERE tx_spec = var_loc
                             AND tx_loc IS NULL) THEN
                INSERT INTO t$tx_table
                VALUES (var_loc, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0);
            END IF;
            UPDATE t$tx_table
            SET tx_adm_oth    = tx_adm_oth + var_adm_oth,
                tx_adm_ae     = tx_adm_ae + var_adm_ae,
                tx_adm_opd    = tx_adm_opd + var_adm_opd,
                tx_adm_xin    = tx_adm_xin + var_adm_xin,
                tx_adm_nb     = tx_adm_nb + var_adm_nb,
                tx_dsch_conv  = tx_dsch_conv + var_dsch_conv,
                tx_dsch_deth  = tx_dsch_deth + var_dsch_deth,
                tx_dsch_home  = tx_dsch_home + var_dsch_home,
                tx_dsch_hfu   = tx_dsch_hfu + var_dsch_hfu,
                tx_dsch_acute = tx_dsch_acute + var_dsch_acute,
                tx_dsch_dama  = tx_dsch_dama + var_dsch_dama,
                tx_dsch_miss  = tx_dsch_miss + var_dsch_miss,
                tx_dsch_untr  = tx_dsch_untr + var_dsch_untr,
                tx_dsch_oth   = tx_dsch_oth + var_dsch_oth,
                tx_dsch_wa    = tx_dsch_wa + var_dsch_wa,
                tx_xout       = tx_xout + var_xout,
                tx_tlos       = tx_tlos + var_tlos,
                tx_dp         = tx_dp + var_dp
            WHERE tx_spec = var_loc
              AND tx_loc IS NULL;
            FETCH loc_csr INTO var_spec, var_loc, var_adm_oth, var_adm_ae, var_adm_opd, var_adm_xin, var_adm_nb, var_tadm, var_dsch_conv, var_dsch_deth, var_dsch_home, var_dsch_hfu, var_dsch_acute, var_dsch_dama, var_dsch_miss, var_dsch_untr, var_dsch_oth, var_dsch_wa, var_tdsch, var_xout, var_tlos, var_alos, var_dp;
        END LOOP;
    CLOSE loc_csr;

    DELETE
    FROM t$tx_table
    WHERE tx_loc IS NOT NULL
      AND tx_spec = tx_loc;

    UPDATE t$tx_table
    SET tx_tadm  = tx_adm_oth + tx_adm_ae + tx_adm_opd + tx_adm_xin + tx_adm_nb,
        tx_tdsch = tx_dsch_conv + tx_dsch_deth + tx_dsch_home + tx_dsch_hfu + tx_dsch_acute +
                   tx_dsch_dama + tx_dsch_miss + tx_dsch_untr + tx_dsch_oth + tx_dsch_wa;

    UPDATE t$tx_table
    SET tx_alos = tx_tlos / (tx_tdsch + tx_xout - tx_dp)
    WHERE tx_loc IS NULL
      AND (tx_tdsch + tx_xout - tx_dp <> 0);

    DROP TABLE IF EXISTS t$dsp_table_dsch;
    CREATE TEMPORARY TABLE t$dsp_table_dsch
    (
        dsp_spec       VARCHAR(4)  NULL,
        dsp_desc       VARCHAR(30) NULL,
        dsp_adm_oth    INTEGER     NULL,
        dsp_adm_ae     INTEGER     NULL,
        dsp_adm_opd    INTEGER     NULL,
        dsp_adm_xin    INTEGER     NULL,
        dsp_adm_nb     INTEGER     NULL,
        dsp_tadm       INTEGER     NULL,
        dsp_dsch_conv  INTEGER     NULL,
        dsp_dsch_deth  INTEGER     NULL,
        dsp_dsch_home  INTEGER     NULL,
        dsp_dsch_hfu   INTEGER     NULL,
        dsp_dsch_acute INTEGER     NULL,
        dsp_dsch_dama  INTEGER     NULL,
        dsp_dsch_miss  INTEGER     NULL,
        dsp_dsch_untr  INTEGER     NULL,
        dsp_dsch_oth   INTEGER     NULL,
        dsp_dsch_wa    INTEGER     NULL,
        dsp_tdsch      INTEGER     NULL,
        dsp_xout       INTEGER     NULL,
        dsp_tlos       REAL        NULL,
        dsp_alos       REAL        NULL
    );
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
           0,
           0,
           0,
           0
    INTO var_spec_adm_oth, var_spec_adm_ae, var_spec_adm_opd, var_spec_adm_xin, var_spec_adm_nb, var_spec_tadm, var_spec_dsch_conv, var_spec_dsch_deth, var_spec_dsch_home, var_spec_dsch_hfu, var_spec_dsch_acute, var_spec_dsch_dama, var_spec_dsch_miss, var_spec_dsch_untr, var_spec_dsch_oth, var_spec_dsch_wa, var_spec_tdsch, var_spec_xout, var_spec_tlos, var_spec_dp, var_hosp_adm_oth, var_hosp_adm_ae, var_hosp_adm_opd, var_hosp_adm_xin, var_hosp_adm_nb, var_hosp_tadm, var_hosp_dsch_conv, var_hosp_dsch_deth, var_hosp_dsch_home, var_hosp_dsch_hfu, var_hosp_dsch_acute, var_hosp_dsch_dama, var_hosp_dsch_miss, var_hosp_dsch_untr, var_hosp_dsch_oth, var_hosp_dsch_wa, var_hosp_tdsch, var_hosp_xout, var_hosp_tlos, var_hosp_dp, var_count;

    OPEN dsp_csr;
    FETCH dsp_csr INTO var_spec, var_loc, var_adm_oth, var_adm_ae, var_adm_opd, var_adm_xin, var_adm_nb, var_tadm, var_dsch_conv, var_dsch_deth, var_dsch_home, var_dsch_hfu, var_dsch_acute, var_dsch_dama, var_dsch_miss, var_dsch_untr, var_dsch_oth, var_dsch_wa, var_tdsch, var_xout, var_tlos, var_alos, var_dp;
    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            IF COALESCE(var_spec, ' ') <> COALESCE(var_prev_spec, ' ') THEN
                BEGIN
                    IF var_count > 1 THEN
                        BEGIN
                            IF (var_spec_tdsch + var_spec_xout - var_spec_dp <> 0) THEN
                                SELECT var_spec_tlos / (var_spec_tdsch + var_spec_xout - var_spec_dp)
                                INTO var_spec_alos;
                            ELSE
                                SELECT NULL
                                INTO var_spec_alos;
                            END IF;
                            INSERT INTO t$dsp_table_dsch
                            VALUES (NULL, 'Specialty Total', var_spec_adm_oth, var_spec_adm_ae, var_spec_adm_opd,
                                    var_spec_adm_xin, var_spec_adm_nb, var_spec_tadm, var_spec_dsch_conv,
                                    var_spec_dsch_deth, var_spec_dsch_home, var_spec_dsch_hfu, var_spec_dsch_acute,
                                    var_spec_dsch_dama, var_spec_dsch_miss, var_spec_dsch_untr, var_spec_dsch_oth,
                                    var_spec_dsch_wa, var_spec_tdsch, var_spec_xout, var_spec_tlos, var_spec_alos);
                        END;
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
                           0,
                           0,
                           0
                    INTO var_spec_adm_oth, var_spec_adm_ae, var_spec_adm_opd, var_spec_adm_xin, var_spec_adm_nb, var_spec_tadm, var_spec_dsch_conv, var_spec_dsch_deth, var_spec_dsch_home, var_spec_dsch_hfu, var_spec_dsch_acute, var_spec_dsch_dama, var_spec_dsch_miss, var_spec_dsch_untr, var_spec_dsch_oth, var_spec_dsch_wa, var_spec_tdsch, var_spec_xout, var_spec_tlos, var_spec_dp, var_count;
                END;
            END IF;
            SELECT var_spec,
                   var_spec_adm_oth + var_adm_oth,
                   var_spec_adm_ae + var_adm_ae,
                   var_spec_adm_opd + var_adm_opd,
                   var_spec_adm_xin + var_adm_xin,
                   var_spec_adm_nb + var_adm_nb,
                   var_spec_tadm + var_tadm,
                   var_spec_dsch_conv + var_dsch_conv,
                   var_spec_dsch_deth + var_dsch_deth,
                   var_spec_dsch_home + var_dsch_home,
                   var_spec_dsch_hfu + var_dsch_hfu,
                   var_spec_dsch_acute + var_dsch_acute,
                   var_spec_dsch_dama + var_dsch_dama,
                   var_spec_dsch_miss + var_dsch_miss,
                   var_spec_dsch_untr + var_dsch_untr,
                   var_spec_dsch_oth + var_dsch_oth,
                   var_spec_dsch_wa + var_dsch_wa,
                   var_spec_tdsch + var_tdsch,
                   var_spec_xout + var_xout,
                   var_spec_tlos + var_tlos,
                   var_spec_dp + var_dp,
                   var_count + 1
            INTO var_prev_spec, var_spec_adm_oth, var_spec_adm_ae, var_spec_adm_opd, var_spec_adm_xin, var_spec_adm_nb, var_spec_tadm, var_spec_dsch_conv, var_spec_dsch_deth, var_spec_dsch_home, var_spec_dsch_hfu, var_spec_dsch_acute, var_spec_dsch_dama, var_spec_dsch_miss, var_spec_dsch_untr, var_spec_dsch_oth, var_spec_dsch_wa, var_spec_tdsch, var_spec_xout, var_spec_tlos, var_spec_dp, var_count;

            IF var_loc IS NULL THEN
                SELECT var_hosp_adm_oth + var_adm_oth,
                       var_hosp_adm_ae + var_adm_ae,
                       var_hosp_adm_opd + var_adm_opd,
                       var_hosp_adm_xin + var_adm_xin,
                       var_hosp_adm_nb + var_adm_nb,
                       var_hosp_tadm + var_tadm,
                       var_hosp_dsch_conv + var_dsch_conv,
                       var_hosp_dsch_deth + var_dsch_deth,
                       var_hosp_dsch_home + var_dsch_home,
                       var_hosp_dsch_hfu + var_dsch_hfu,
                       var_hosp_dsch_acute + var_dsch_acute,
                       var_hosp_dsch_dama + var_dsch_dama,
                       var_hosp_dsch_miss + var_dsch_miss,
                       var_hosp_dsch_untr + var_dsch_untr,
                       var_hosp_dsch_oth + var_dsch_oth,
                       var_hosp_dsch_wa + var_dsch_wa,
                       var_hosp_tdsch + var_tdsch,
                       var_hosp_xout + var_xout,
                       var_hosp_tlos + var_tlos,
                       var_hosp_dp + var_dp
                INTO var_hosp_adm_oth, var_hosp_adm_ae, var_hosp_adm_opd, var_hosp_adm_xin, var_hosp_adm_nb, var_hosp_tadm, var_hosp_dsch_conv, var_hosp_dsch_deth, var_hosp_dsch_home, var_hosp_dsch_hfu, var_hosp_dsch_acute, var_hosp_dsch_dama, var_hosp_dsch_miss, var_hosp_dsch_untr, var_hosp_dsch_oth, var_hosp_dsch_wa, var_hosp_tdsch, var_hosp_xout, var_hosp_tlos, var_hosp_dp;
            END IF;

            IF var_loc IS NULL THEN
                /*
                select @desc = Description from Specialty
                where Specialty_code = @spec
                */
                /* add hosp code for HPI by ML on 27.07.1999 */
                SELECT Description
                INTO result_str_value_1
                FROM Specialty
                WHERE Specialty_code = var_spec
                  AND Hospital_code = par_hosp_code
                  AND Effective_date = (SELECT MAX(Effective_date)
                                        FROM Specialty
                                        WHERE Effective_date < par_input_to_date
                                          AND Specialty_code = var_spec
                                          AND Hospital_code = par_hosp_code);
                IF FOUND THEN
                    var_desc = result_str_value_1;
                END IF;

            ELSE
                BEGIN
                    SELECT var_loc
                    INTO var_desc;

                    IF var_count > 1 THEN
                        SELECT NULL
                        INTO var_spec;
                    END IF;
                END;
            END IF;
            INSERT INTO t$dsp_table_dsch
            VALUES (var_spec, var_desc, var_adm_oth, var_adm_ae, var_adm_opd, var_adm_xin, var_adm_nb, var_tadm,
                    var_dsch_conv, var_dsch_deth, var_dsch_home, var_dsch_hfu, var_dsch_acute, var_dsch_dama,
                    var_dsch_miss, var_dsch_untr, var_dsch_oth, var_dsch_wa, var_tdsch, var_xout, var_tlos, var_alos);
            FETCH dsp_csr INTO var_spec, var_loc, var_adm_oth, var_adm_ae, var_adm_opd, var_adm_xin, var_adm_nb, var_tadm, var_dsch_conv, var_dsch_deth, var_dsch_home, var_dsch_hfu, var_dsch_acute, var_dsch_dama, var_dsch_miss, var_dsch_untr, var_dsch_oth, var_dsch_wa, var_tdsch, var_xout, var_tlos, var_alos, var_dp;
        END LOOP;
    CLOSE dsp_csr;

    IF var_count > 1 THEN
        BEGIN
            IF (var_spec_tdsch + var_spec_xout - var_spec_dp <> 0) THEN
                SELECT var_spec_tlos / (var_spec_tdsch + var_spec_xout - var_spec_dp)
                INTO var_spec_alos;
            ELSE
                SELECT NULL
                INTO var_spec_alos;
            END IF;
            INSERT INTO t$dsp_table_dsch
            VALUES (NULL, 'Specialty Total', var_spec_adm_oth, var_spec_adm_ae, var_spec_adm_opd, var_spec_adm_xin,
                    var_spec_adm_nb, var_spec_tadm, var_spec_dsch_conv, var_spec_dsch_deth, var_spec_dsch_home,
                    var_spec_dsch_hfu, var_spec_dsch_acute, var_spec_dsch_dama, var_spec_dsch_miss, var_spec_dsch_untr,
                    var_spec_dsch_oth, var_spec_dsch_wa, var_spec_tdsch, var_spec_xout, var_spec_tlos, var_spec_alos);
        END;
    END IF;

    IF par_input_spec = '%' THEN
        BEGIN
            IF (var_hosp_tdsch - var_hosp_dp <> 0) THEN
                SELECT var_hosp_tlos / (var_hosp_tdsch - var_hosp_dp)
                INTO var_hosp_alos;
            ELSE
                SELECT NULL
                INTO var_hosp_alos;
            END IF;
            INSERT INTO t$dsp_table_dsch
            VALUES (NULL, 'Hospital Total', var_hosp_adm_oth, var_hosp_adm_ae, var_hosp_adm_opd, var_hosp_adm_xin,
                    var_hosp_adm_nb, var_hosp_tadm, var_hosp_dsch_conv, var_hosp_dsch_deth, var_hosp_dsch_home,
                    var_hosp_dsch_hfu, var_hosp_dsch_acute, var_hosp_dsch_dama, var_hosp_dsch_miss, var_hosp_dsch_untr,
                    var_hosp_dsch_oth, var_hosp_dsch_wa, var_hosp_tdsch, var_hosp_xout, var_hosp_tlos, var_hosp_alos);
        END;
    END IF;

    IF par_input_spec = '%' OR par_input_spec = 'HOME' THEN
        INSERT INTO t$dsp_table_dsch
        SELECT tx_spec,
               'HOME',
               tx_adm_oth,
               tx_adm_ae,
               tx_adm_opd,
               tx_adm_xin,
               tx_adm_nb,
               tx_tadm,
               tx_dsch_conv,
               tx_dsch_deth,
               tx_dsch_home,
               tx_dsch_hfu,
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
        FROM t$tx_table
        WHERE tx_spec = 'HOME';
    END IF;

    OPEN p_refcur FOR
        SELECT dsp_spec,
               dsp_desc,
               dsp_adm_oth,
               dsp_adm_ae,
               dsp_adm_opd,
               dsp_adm_xin,
               dsp_adm_nb,
               dsp_tadm,
               dsp_dsch_conv,
               dsp_dsch_deth,
               dsp_dsch_home,
               dsp_dsch_hfu,
               dsp_dsch_acute,
               dsp_dsch_dama,
               dsp_dsch_miss,
               dsp_dsch_untr,
               dsp_dsch_oth,
               dsp_dsch_wa,
               dsp_tdsch,
               dsp_xout,
               dsp_tlos,
               dsp_alos
        FROM t$dsp_table_dsch
        WHERE dsp_adm_oth <> 0
           OR dsp_adm_ae <> 0
           OR dsp_adm_opd <> 0
           OR dsp_adm_xin <> 0
           OR dsp_adm_nb <> 0
           OR dsp_dsch_conv <> 0
           OR dsp_dsch_deth <> 0
           OR dsp_dsch_home <> 0
           OR dsp_dsch_hfu <> 0
           OR dsp_dsch_acute <> 0
           OR dsp_dsch_dama <> 0
           OR dsp_dsch_miss <> 0
           OR dsp_dsch_untr <> 0
           OR dsp_dsch_oth <> 0
           OR dsp_dsch_wa <> 0
           OR dsp_xout <> 0
           OR dsp_tlos <> 0
           OR dsp_alos <> 0;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_admit_dsch" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
