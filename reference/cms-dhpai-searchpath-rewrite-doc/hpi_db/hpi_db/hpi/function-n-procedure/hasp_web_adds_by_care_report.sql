-- DROP PROCEDURE hasp_web_adds_by_care_report(in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_web_adds_by_care_report(IN par_hospital_code character varying, IN par_from_date timestamp without time zone, IN par_to_date timestamp without time zone, IN par_care_category character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_case          VARCHAR(12);
    var_adm_date      TIMESTAMP WITHOUT TIME ZONE;
    var_dsch_date     TIMESTAMP WITHOUT TIME ZONE;
    var_care          VARCHAR(1);
    var_ward          VARCHAR(4);
    var_move_ward     VARCHAR(4);
    var_move_date     TIMESTAMP WITHOUT TIME ZONE;
    var_move_type     VARCHAR(1);
    var_type          VARCHAR(3);
    var_move_care     VARCHAR(1);
    var_prev_care     VARCHAR(1);
    var_prev_date     TIMESTAMP WITHOUT TIME ZONE;
    var_count         INTEGER;
    var_src           VARCHAR(1);
    var_adm0          INTEGER;
    var_adm3          INTEGER;
    var_adm4          INTEGER;
    var_adm5          INTEGER;
    var_adm8          INTEGER;
    var_dsch0         INTEGER;
    var_dsch1         INTEGER;
    var_dsch2         INTEGER;
    var_dsch3         INTEGER;
    var_dsch4         INTEGER;
    var_dsch5         INTEGER;
    var_dsch6         INTEGER;
    var_dscha         INTEGER;
    var_dschm         INTEGER;
    var_desc          VARCHAR(48);
    var_xout          INTEGER;
    var_los           INTEGER;
    var_prev_ward     VARCHAR(4);
    var_ttl_adm       INTEGER;
    var_ttl_dsch      INTEGER;
    var_dsch7         INTEGER;
    var_spec          VARCHAR(4);
    var_loc           VARCHAR(4);
    var_prev_spec     VARCHAR(4);
    var_prev_loc      VARCHAR(4);
    var_move_spec     VARCHAR(4);
    var_move_loc      VARCHAR(4);
    var_loc_count     INTEGER;
    var_out_spec      VARCHAR(4);
    var_dp            INTEGER;
    var_alos          REAL;
    var_spec_adm0     INTEGER;
    var_spec_adm1     INTEGER;
    var_spec_adm3     INTEGER;
    var_spec_adm4     INTEGER;
    var_spec_adm5     INTEGER;
    var_spec_adm8     INTEGER;
    var_spec_dsch0    INTEGER;
    var_spec_dsch1    INTEGER;
    var_spec_dsch2    INTEGER;
    var_spec_dsch3    INTEGER;
    var_spec_dsch4    INTEGER;
    var_spec_dsch5    INTEGER;
    var_spec_dsch6    INTEGER;
    var_spec_dsch7    INTEGER;
    var_spec_dscha    INTEGER;
    var_spec_dschm    INTEGER;
    var_spec_los      INTEGER;
    var_spec_xout     INTEGER;
    var_spec_ttl_adm  INTEGER;
    var_spec_ttl_dsch INTEGER;
    var_spec_dp       INTEGER;
    var_hosp_adm0     INTEGER;
    var_hosp_adm1     INTEGER;
    var_hosp_adm3     INTEGER;
    var_hosp_adm4     INTEGER;
    var_hosp_adm5     INTEGER;
    var_hosp_adm8     INTEGER;
    var_hosp_dsch0    INTEGER;
    var_hosp_dsch1    INTEGER;
    var_hosp_dsch2    INTEGER;
    var_hosp_dsch3    INTEGER;
    var_hosp_dsch4    INTEGER;
    var_hosp_dsch5    INTEGER;
    var_hosp_dsch6    INTEGER;
    var_hosp_dsch7    INTEGER;
    var_hosp_dscha    INTEGER;
    var_hosp_dschm    INTEGER;
    var_hosp_los      INTEGER;
    var_hosp_xout     INTEGER;
    var_hosp_ttl_adm  INTEGER;
    var_hosp_ttl_dsch INTEGER;
    var_hosp_dp       INTEGER;
    
    adm_csr CURSOR FOR
        SELECT From_ward_code,
               From_specialty_code,
               From_treatment_location,
               Source_indicator,
               COUNT(*)
        FROM Transaction_log AS t,
             ADT_Case AS c
        WHERE t.Hospital_code = par_hospital_code
          AND Transaction_datetime >= par_from_date
          AND Transaction_datetime < par_to_date
          AND Transaction_type = '100'
          AND Cancel_flag IS NULL
          AND t.Hospital_code = c.Hospital_code
          AND t.Case_no = c.Case_no
        GROUP BY From_ward_code, From_specialty_code, From_treatment_location, Source_indicator;
    
    dsch_csr CURSOR FOR
        SELECT From_ward_code,
               From_specialty_code,
               From_treatment_location,
               Transaction_type,
               COUNT(*)
        FROM Transaction_log
        WHERE Hospital_code = par_hospital_code
          AND Transaction_datetime >= par_from_date
          AND Transaction_datetime < par_to_date
          AND Transaction_type LIKE '13_'
          AND Cancel_flag IS NULL
        GROUP BY From_ward_code, From_specialty_code, From_treatment_location, Transaction_type;
    
    case_csr CURSOR FOR
        SELECT t.Case_no,
               Admission_datetime,
               Discharge_datetime,
               Source_indicator
        FROM Transaction_log AS t,
             ADT_Case AS c
        WHERE t.Hospital_code = par_hospital_code
          AND Transaction_datetime >= par_from_date
          AND Transaction_datetime < par_to_date
          AND Transaction_type LIKE '13_'
          AND Cancel_flag IS NULL
          AND t.Hospital_code = c.Hospital_code
          AND t.Case_no = c.Case_no;
    
    move_csr CURSOR FOR
        SELECT Movement_type,
               Movement_datetime,
               Ward_code,
               Specialty_code,
               Treatment_location
        FROM Movement
        WHERE Hospital_code = par_hospital_code
          AND Case_no = var_case;
    
    loc_csr CURSOR FOR
        SELECT spec_code,
               care_type,
               loc,
               adm0,
               adm3,
               adm4,
               adm5,
               adm8,
               dsch0,
               dsch1,
               dsch2,
               dsch3,
               dsch4,
               dsch5,
               dsch6,
               dsch7,
               dscha,
               dschm,
               los,
               xout,
               dp_dsch
        FROM t$outtable
        WHERE loc IS NOT NULL
          AND COALESCE(spec_code, 'null') <> COALESCE(loc, 'null');
    
    dsp_csr CURSOR FOR
        SELECT spec_code,
               care_type,
               loc,
               adm0,
               adm3,
               adm4,
               adm5,
               adm8,
               dsch0,
               dsch1,
               dsch2,
               dsch3,
               dsch4,
               dsch5,
               dsch6,
               dsch7,
               dscha,
               dschm,
               los,
               xout,
               dp_dsch
        FROM t$outtable
        WHERE COALESCE(spec_code, 'null') <> 'HOME'
        ORDER BY spec_code NULLS FIRST, care_type NULLS FIRST, loc NULLS FIRST;
BEGIN
    IF par_to_date IS NULL THEN
        SELECT 1 * INTERVAL '1 day' + par_from_date::TIMESTAMP
        INTO par_to_date;
    END IF;
    SELECT 1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
    INTO par_to_date;

    DROP TABLE IF EXISTS t$worktable;
    CREATE TEMPORARY TABLE t$worktable
    (
        ward_code VARCHAR(4),
        spec_code VARCHAR(4),
        loc       VARCHAR(4)        NULL,
        care_type VARCHAR(1)        NULL,
        adm0      INTEGER DEFAULT 0 NULL,
        adm3      INTEGER DEFAULT 0 NULL,
        adm4      INTEGER DEFAULT 0 NULL,
        adm5      INTEGER DEFAULT 0 NULL,
        adm8      INTEGER DEFAULT 0 NULL,
        dsch0     INTEGER DEFAULT 0 NULL,
        dsch1     INTEGER DEFAULT 0 NULL,
        dsch2     INTEGER DEFAULT 0 NULL,
        dsch3     INTEGER DEFAULT 0 NULL,
        dsch4     INTEGER DEFAULT 0 NULL,
        dsch5     INTEGER DEFAULT 0 NULL,
        dsch6     INTEGER DEFAULT 0 NULL,
        dsch7     INTEGER DEFAULT 0 NULL,
        dscha     INTEGER DEFAULT 0 NULL,
        dschm     INTEGER DEFAULT 0 NULL
    );
    CREATE UNIQUE INDEX ward_code_spec_code_loc_index ON t$worktable
        (ward_code, spec_code, loc);
    CREATE INDEX index2 ON t$worktable
        (spec_code, care_type, loc);

    DROP TABLE IF EXISTS t$outtable;
    CREATE TEMPORARY TABLE t$outtable
    (
        spec_code VARCHAR(4),
        care_type VARCHAR(1),
        loc       VARCHAR(4)        NULL,
        adm0      INTEGER DEFAULT 0 NULL,
        adm3      INTEGER DEFAULT 0 NULL,
        adm4      INTEGER DEFAULT 0 NULL,
        adm5      INTEGER DEFAULT 0 NULL,
        adm8      INTEGER DEFAULT 0 NULL,
        dsch0     INTEGER DEFAULT 0 NULL,
        dsch1     INTEGER DEFAULT 0 NULL,
        dsch2     INTEGER DEFAULT 0 NULL,
        dsch3     INTEGER DEFAULT 0 NULL,
        dsch4     INTEGER DEFAULT 0 NULL,
        dsch5     INTEGER DEFAULT 0 NULL,
        dsch6     INTEGER DEFAULT 0 NULL,
        dsch7     INTEGER DEFAULT 0 NULL,
        dscha     INTEGER DEFAULT 0 NULL,
        dschm     INTEGER DEFAULT 0 NULL,
        xout      INTEGER DEFAULT 0 NULL,
        los       INTEGER DEFAULT 0 NULL,
        dp_dsch   INTEGER DEFAULT 0 NULL
    );
    CREATE UNIQUE INDEX spec_code_care_type_loc_index ON t$outtable
        (spec_code, care_type, loc);

    DROP TABLE IF EXISTS t$dsptable;
    CREATE TEMPORARY TABLE t$dsptable
    (
        record_id   SERIAL PRIMARY KEY,
        spec_code   VARCHAR(4)        NULL,
        care_type   VARCHAR(1)        NULL,
        description VARCHAR(48)       NULL,
        loc         VARCHAR(30)       NULL,
        adm0        INTEGER DEFAULT 0 NULL,
        adm3        INTEGER DEFAULT 0 NULL,
        adm4        INTEGER DEFAULT 0 NULL,
        adm5        INTEGER DEFAULT 0 NULL,
        adm8        INTEGER DEFAULT 0 NULL,
        ttl_adm     INTEGER DEFAULT 0 NULL,
        dsch0       INTEGER DEFAULT 0 NULL,
        dsch1       INTEGER DEFAULT 0 NULL,
        dsch2       INTEGER DEFAULT 0 NULL,
        dsch3       INTEGER DEFAULT 0 NULL,
        dsch4       INTEGER DEFAULT 0 NULL,
        dsch5       INTEGER DEFAULT 0 NULL,
        dsch6       INTEGER DEFAULT 0 NULL,
        dsch7       INTEGER DEFAULT 0 NULL,
        dscha       INTEGER DEFAULT 0 NULL,
        dschm       INTEGER DEFAULT 0 NULL,
        ttl_dsch    INTEGER DEFAULT 0 NULL,
        xout        INTEGER DEFAULT 0 NULL,
        los         INTEGER DEFAULT 0 NULL,
        alos        REAL  NULL,
        dp_dsch     INTEGER DEFAULT 0 NULL
    );

    DROP TABLE IF EXISTS t$caretable;
    CREATE TEMPORARY TABLE t$caretable
    (
        care_type   VARCHAR(1)        NULL,
        description VARCHAR(48)       NULL,
        adm0        INTEGER DEFAULT 0 NULL,
        adm3        INTEGER DEFAULT 0 NULL,
        adm4        INTEGER DEFAULT 0 NULL,
        adm5        INTEGER DEFAULT 0 NULL,
        adm8        INTEGER DEFAULT 0 NULL,
        ttl_adm     INTEGER DEFAULT 0 NULL,
        dsch0       INTEGER DEFAULT 0 NULL,
        dsch1       INTEGER DEFAULT 0 NULL,
        dsch2       INTEGER DEFAULT 0 NULL,
        dsch3       INTEGER DEFAULT 0 NULL,
        dsch4       INTEGER DEFAULT 0 NULL,
        dsch5       INTEGER DEFAULT 0 NULL,
        dsch6       INTEGER DEFAULT 0 NULL,
        dsch7       INTEGER DEFAULT 0 NULL,
        dscha       INTEGER DEFAULT 0 NULL,
        dschm       INTEGER DEFAULT 0 NULL,
        ttl_dsch    INTEGER DEFAULT 0 NULL,
        xout        INTEGER DEFAULT 0 NULL,
        los         INTEGER DEFAULT 0 NULL,
        alos        REAL  NULL,
        dp_dsch     INTEGER DEFAULT 0 NULL
    );
    CREATE UNIQUE INDEX care_index ON t$caretable
        (care_type);
    /*
    for adding treatment_location data to original specialty
    should be removed if not required to show treatment location
    */
    OPEN adm_csr;
    FETCH adm_csr INTO var_ward, var_spec, var_loc, var_src, var_count;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            SELECT 0,
                   0,
                   0,
                   0,
                   0
            INTO var_adm0, var_adm3, var_adm4, var_adm5, var_adm8;

            IF var_src = '0' THEN
                SELECT var_count
                INTO var_adm0;
            END IF;

            IF var_src = '3' THEN
                SELECT var_count
                INTO var_adm3;
            END IF;

            IF var_src = '4' THEN
                SELECT var_count
                INTO var_adm4;
            END IF;

            IF var_src = '5' THEN
                SELECT var_count
                INTO var_adm5;
            END IF;

            IF var_src = '8' THEN
                SELECT var_count
                INTO var_adm8;
            END IF;

            IF EXISTS (SELECT *
                       FROM t$worktable
                       WHERE ward_code = var_ward
                         AND spec_code = var_spec
                         AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null')) THEN
                UPDATE t$worktable
                SET adm0 = adm0 + var_adm0,
                    adm3 = adm3 + var_adm3,
                    adm4 = adm4 + var_adm4,
                    adm5 = adm5 + var_adm5,
                    adm8 = adm8 + var_adm8
                WHERE ward_code = var_ward
                  AND spec_code = var_spec
                  AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null');
            ELSE
                INSERT INTO t$worktable (ward_code, spec_code, loc, adm0, adm3, adm4, adm5, adm8)
                VALUES (var_ward, var_spec, var_loc, var_adm0, var_adm3, var_adm4, var_adm5, var_adm8);
            END IF;
            FETCH adm_csr INTO var_ward, var_spec, var_loc, var_src, var_count;
        END LOOP;
    CLOSE adm_csr;
    
    OPEN dsch_csr;
    FETCH dsch_csr INTO var_ward, var_spec, var_loc, var_type, var_count;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            SELECT 0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0
            INTO var_dsch0, var_dsch1, var_dsch2, var_dsch3, var_dsch4, var_dsch5, var_dsch6, var_dsch7, var_dscha, var_dschm;

            IF var_type = '130' THEN
                SELECT var_count
                INTO var_dsch0;
            END IF;

            IF var_type = '131' THEN
                SELECT var_count
                INTO var_dsch1;
            END IF;

            IF var_type = '132' THEN
                SELECT var_count
                INTO var_dsch2;
            END IF;

            IF var_type = '133' THEN
                SELECT var_count
                INTO var_dsch3;
            END IF;

            IF var_type = '134' THEN
                SELECT var_count
                INTO var_dsch4;
            END IF;

            IF var_type = '135' THEN
                SELECT var_count
                INTO var_dsch5;
            END IF;

            IF var_type = '136' THEN
                SELECT var_count
                INTO var_dsch6;
            END IF;

            IF var_type = '137' THEN
                SELECT var_count
                INTO var_dsch7;
            END IF;

            IF var_type = '13A' THEN
                SELECT var_count
                INTO var_dscha;
            END IF;

            IF var_type = '13M' THEN
                SELECT var_count
                INTO var_dschm;
            END IF;

            IF EXISTS (SELECT *
                       FROM t$worktable
                       WHERE ward_code = var_ward
                         AND spec_code = var_spec
                         AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null')) THEN
                UPDATE t$worktable
                SET dsch0 = dsch0 + var_dsch0,
                    dsch1 = dsch1 + var_dsch1,
                    dsch2 = dsch2 + var_dsch2,
                    dsch3 = dsch3 + var_dsch3,
                    dsch4 = dsch4 + var_dsch4,
                    dsch5 = dsch5 + var_dsch5,
                    dsch6 = dsch6 + var_dsch6,
                    dsch7 = dsch7 + var_dsch7,
                    dscha = dscha + var_dscha,
                    dschm = dschm + var_dschm
                WHERE ward_code = var_ward
                  AND spec_code = var_spec
                  AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null');
            ELSE
                INSERT INTO t$worktable (ward_code, spec_code, loc, dsch0, dsch1, dsch2, dsch3, dsch4, dsch5, dsch6,
                                         dsch7, dscha, dschm)
                VALUES (var_ward, var_spec, var_loc, var_dsch0, var_dsch1, var_dsch2, var_dsch3, var_dsch4, var_dsch5,
                        var_dsch6, var_dsch7, var_dscha, var_dschm);
            END IF;
            FETCH dsch_csr INTO var_ward, var_spec, var_loc, var_type, var_count;
        END LOOP;
    CLOSE dsch_csr;
    
    UPDATE t$worktable AS a
     SET care_type = w.Care_category
     FROM Ward AS w
     WHERE w.Hospital_code = par_hospital_code
       AND a.ward_code = w.Ward_code
       AND w.Effective_date = (SELECT MAX(Effective_date)
                             FROM Ward
                             WHERE Ward_code = a.ward_code
                               AND Hospital_code = par_hospital_code
                               AND Effective_date < par_to_date);
                              
    UPDATE t$worktable
    SET care_type = 'M'
    WHERE care_type IS NULL;
    
    INSERT INTO t$outtable (spec_code, care_type, loc, adm0, adm3, adm4, adm5, adm8, dsch0, dsch1, dsch2, dsch3, dsch4,
                            dsch5, dsch6, dsch7, dscha, dschm)
    SELECT spec_code,
           care_type,
           loc,
           SUM(adm0),
           SUM(adm3),
           SUM(adm4),
           SUM(adm5),
           SUM(adm8),
           SUM(dsch0),
           SUM(dsch1),
           SUM(dsch2),
           SUM(dsch3),
           SUM(dsch4),
           SUM(dsch5),
           SUM(dsch6),
           SUM(dsch7),
           SUM(dscha),
           SUM(dschm)
    FROM t$worktable
    GROUP BY spec_code, care_type, loc;
    
    OPEN case_csr;
    FETCH case_csr INTO var_case, var_adm_date, var_dsch_date, var_src;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            OPEN move_csr;
            FETCH move_csr INTO var_move_type, var_move_date, var_move_ward, var_move_spec, var_move_loc;

            WHILE (CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
                END) = 0
                LOOP
                    SELECT NULL
                    INTO var_move_care;
                    
                    SELECT Care_category
                    INTO var_move_care
                    FROM Ward
                    WHERE Hospital_code = par_hospital_code
                      AND Ward_code = var_move_ward
                      AND Effective_date = (SELECT MAX(Effective_date)
                                            FROM Ward
                                            WHERE Hospital_code = par_hospital_code
                                              AND Ward_code = var_move_ward
                                              AND Effective_date <= var_move_date);

                    IF var_move_care IS NULL THEN
                        SELECT 'M'
                        INTO var_move_care;
                    END IF;
                    /* --if @move_type = 'A' */
                    /* --	select @prev_care = @move_care, @prev_date = @move_date */
                    IF var_move_type NOT IN ('A', 'D') THEN
                        BEGIN
                            SELECT DATE_PART('days', var_move_date::timestamp::date::timestamp -
                                                     var_prev_date::timestamp::date::timestamp)
                            INTO var_los;

                            IF COALESCE(var_prev_care, 'null') <> COALESCE(var_move_care, 'null')
                                OR COALESCE(var_prev_spec, 'null') <> COALESCE(var_move_spec, 'null')
                                OR COALESCE(var_prev_loc, 'null') <> COALESCE(var_move_loc, 'null') THEN
                                SELECT 1
                                INTO var_xout;
                            ELSE
                                SELECT 0
                                INTO var_xout;
                            END IF;

                            IF var_prev_ward = 'HOME' THEN
                                SELECT 0,
                                       0
                                INTO var_los, var_xout;
                            END IF;

                            IF var_move_ward = 'HOME' THEN
                                SELECT 0
                                INTO var_xout;
                            END IF;

                            IF var_los > 0 OR var_xout > 0 THEN
                                IF EXISTS (SELECT *
                                           FROM t$outtable
                                           WHERE care_type = var_prev_care
                                             AND spec_code = var_prev_spec
                                             AND COALESCE(loc, 'null') = COALESCE(var_prev_loc, 'null')) THEN
                                    UPDATE t$outtable
                                    SET los  = los + var_los,
                                        xout = xout + var_xout
                                    WHERE care_type = var_prev_care
                                      AND spec_code = var_prev_spec
                                      AND COALESCE(loc, 'null') = COALESCE(var_prev_loc, 'null');
                                ELSE
                                    INSERT INTO t$outtable (spec_code, care_type, loc, los, xout)
                                    VALUES (var_prev_spec, var_prev_care, var_prev_loc, var_los, var_xout);
                                END IF;
                            END IF;
                        END;
                    END IF;

                    IF var_move_type = 'D' THEN
                        BEGIN
                            IF DATE_PART('days', var_dsch_date::timestamp::date::timestamp -
                                                 var_adm_date::timestamp::date::timestamp) = 0 AND
                               COALESCE(var_src, 'null') <> '3' THEN
                                SELECT 1
                                INTO var_dp;
                            ELSE
                                SELECT 0
                                INTO var_dp;
                            END IF;
                            SELECT DATE_PART('days', var_move_date::timestamp::date::timestamp -
                                                     var_prev_date::timestamp::date::timestamp)
                            INTO var_los;

                            IF var_move_ward = 'HOME' THEN
                                SELECT 0
                                INTO var_los;
                            ELSE
                                IF var_los = 0 AND
                                   DATE_PART('days', var_dsch_date::timestamp::date::timestamp -
                                                     var_adm_date::timestamp::date::timestamp) = 0 AND
                                   var_src = '3' THEN
                                    SELECT 1
                                    INTO var_los;
                                END IF;
                            END IF;

                            IF var_los > 0 OR var_dp > 0 THEN
                                IF EXISTS (SELECT *
                                           FROM t$outtable
                                           WHERE care_type = var_prev_care
                                             AND spec_code = var_prev_spec
                                             AND COALESCE(loc, 'null') = COALESCE(var_prev_loc, 'null')) THEN
                                    UPDATE t$outtable
                                    SET los     = los + var_los,
                                        dp_dsch = dp_dsch + var_dp
                                    WHERE care_type = var_prev_care
                                      AND spec_code = var_prev_spec
                                      AND COALESCE(loc, 'null') = COALESCE(var_prev_loc, 'null');
                                ELSE
                                    INSERT INTO t$outtable (spec_code, care_type, loc, los, dp_dsch)
                                    VALUES (var_prev_spec, var_prev_care, var_prev_loc, var_los, var_dp);
                                END IF;
                            END IF;
                        END;
                    END IF;
                    SELECT var_move_care,
                           var_move_date,
                           var_move_ward,
                           var_move_spec,
                           var_move_loc
                    INTO var_prev_care, var_prev_date, var_prev_ward, var_prev_spec, var_prev_loc;
                    FETCH move_csr INTO var_move_type, var_move_date, var_move_ward, var_move_spec, var_move_loc;
                END LOOP;
            CLOSE move_csr;
            FETCH case_csr INTO var_case, var_adm_date, var_dsch_date, var_src;
        END LOOP;
    CLOSE case_csr;
    SELECT SUM(adm0),
           SUM(adm3),
           SUM(adm4),
           SUM(adm5),
           SUM(adm8),
           SUM(dsch0),
           SUM(dsch1),
           SUM(dsch2),
           SUM(dsch3),
           SUM(dsch4),
           SUM(dsch5),
           SUM(dsch6),
           SUM(dsch7),
           SUM(dscha),
           SUM(dschm),
           SUM(xout),
           SUM(los),
           SUM(dp_dsch)
    INTO var_hosp_adm0, var_hosp_adm3, var_hosp_adm4, var_hosp_adm5, var_hosp_adm8, var_hosp_dsch0, var_hosp_dsch1, var_hosp_dsch2, var_hosp_dsch3, var_hosp_dsch4, var_hosp_dsch5, var_hosp_dsch6, var_hosp_dsch7, var_hosp_dscha, var_hosp_dschm, var_hosp_xout, var_hosp_los, var_hosp_dp
    FROM t$outtable;
    SELECT var_hosp_adm0 + var_hosp_adm3 + var_hosp_adm4 + var_hosp_adm5 + var_hosp_adm8
    INTO var_hosp_ttl_adm;
    SELECT var_hosp_dsch0 + var_hosp_dsch1 + var_hosp_dsch2 + var_hosp_dsch3 + var_hosp_dsch4 + var_hosp_dsch5 +
           var_hosp_dsch6 + var_hosp_dsch7 + var_hosp_dscha + var_hosp_dschm
    INTO var_hosp_ttl_dsch;
    
    INSERT INTO t$caretable (care_type, adm0, adm3, adm4, adm5, adm8, dsch0, dsch1, dsch2, dsch3, dsch4, dsch5, dsch6,
                             dsch7, dscha, dschm, xout, los, dp_dsch)
    SELECT care_type,
           SUM(adm0),
           SUM(adm3),
           SUM(adm4),
           SUM(adm5),
           SUM(adm8),
           SUM(dsch0),
           SUM(dsch1),
           SUM(dsch2),
           SUM(dsch3),
           SUM(dsch4),
           SUM(dsch5),
           SUM(dsch6),
           SUM(dsch7),
           SUM(dscha),
           SUM(dschm),
           SUM(xout),
           SUM(los),
           SUM(dp_dsch)
    FROM t$outtable
    GROUP BY care_type;
    
    UPDATE t$caretable
    SET ttl_adm  = adm0 + adm3 + adm4 + adm5 + adm8,
        ttl_dsch = dsch0 + dsch1 + dsch2 + dsch3 + dsch4 + dsch5 + dsch6 + dsch7 + dscha + dschm;
    OPEN loc_csr;
    FETCH loc_csr INTO var_spec, var_care, var_loc, var_adm0, var_adm3, var_adm4, var_adm5, var_adm8, var_dsch0, var_dsch1, var_dsch2, var_dsch3, var_dsch4, var_dsch5, var_dsch6, var_dsch7, var_dscha, var_dschm, var_los, var_xout, var_dp;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            IF EXISTS (SELECT *
                       FROM t$outtable
                       WHERE spec_code = var_loc
                         AND care_type = var_care
                         AND loc IS NULL) THEN
                UPDATE t$outtable
                SET adm0    = adm0 + var_adm0,
                    adm3    = adm3 + var_adm3,
                    adm4    = adm4 + var_adm4,
                    adm5    = adm5 + var_adm5,
                    adm8    = adm8 + var_adm8,
                    dsch0   = dsch0 + var_dsch0,
                    dsch1   = dsch1 + var_dsch1,
                    dsch2   = dsch2 + var_dsch2,
                    dsch3   = dsch3 + var_dsch3,
                    dsch4   = dsch4 + var_dsch4,
                    dsch5   = dsch5 + var_dsch5,
                    dsch6   = dsch6 + var_dsch6,
                    dsch7   = dsch7 + var_dsch7,
                    dscha   = dscha + var_dscha,
                    dschm   = dschm + var_dschm,
                    los     = los + var_los,
                    xout    = xout + var_xout,
                    dp_dsch = dp_dsch + var_dp
                WHERE spec_code = var_loc
                  AND care_type = var_care
                  AND loc IS NULL;
            ELSE
                INSERT INTO t$outtable (spec_code, care_type, loc, adm0, adm3, adm4, adm5, adm8, dsch0, dsch1, dsch2,
                                        dsch3, dsch4, dsch5, dsch6, dsch7, dscha, dschm, los, xout, dp_dsch)
                VALUES (var_loc, var_care, NULL, var_adm0, var_adm3, var_adm4, var_adm5, var_adm8, var_dsch0, var_dsch1,
                        var_dsch2, var_dsch3, var_dsch4, var_dsch5, var_dsch6, var_dsch7, var_dscha, var_dschm, var_los,
                        var_xout, var_dp);
            END IF;
            FETCH loc_csr INTO var_spec, var_care, var_loc, var_adm0, var_adm3, var_adm4, var_adm5, var_adm8, var_dsch0, var_dsch1, var_dsch2, var_dsch3, var_dsch4, var_dsch5, var_dsch6, var_dsch7, var_dscha, var_dschm, var_los, var_xout, var_dp;
        END LOOP;
    CLOSE loc_csr;
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
    INTO var_spec_adm0, var_spec_adm3, var_spec_adm4, var_spec_adm5, var_spec_adm8, var_spec_dsch0, var_spec_dsch1, var_spec_dsch2, var_spec_dsch3, var_spec_dsch4, var_spec_dsch5, var_spec_dsch6, var_spec_dsch7, var_spec_dscha, var_spec_dschm, var_spec_los, var_spec_xout, var_spec_ttl_adm, var_spec_ttl_dsch, var_spec_dp;
    /*
    select @hosp_adm0 = 0, @hosp_adm3 = 0, @hosp_adm4 = 0, @hosp_adm5 = 0,
    @hosp_adm8 = 0, @hosp_dsch0 = 0, @hosp_dsch1 = 0, @hosp_dsch2 = 0,
    @hosp_dsch3 = 0, @hosp_dsch4 = 0, @hosp_dsch5 = 0, @hosp_dsch6 = 0,
    @hosp_dsch7 = 0, @hosp_dscha = 0, @hosp_dschm = 0, @hosp_los = 0,
    @hosp_xout = 0, @hosp_ttl_adm = 0, @hosp_ttl_dsch = 0, @hosp_dp = 0
    */
    SELECT NULL,
           0
    INTO var_prev_spec, var_loc_count;
    OPEN dsp_csr;
    FETCH dsp_csr INTO var_spec, var_care, var_loc, var_adm0, var_adm3, var_adm4, var_adm5, var_adm8, var_dsch0, var_dsch1, var_dsch2, var_dsch3, var_dsch4, var_dsch5, var_dsch6, var_dsch7, var_dscha, var_dschm, var_los, var_xout, var_dp;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            SELECT 1
            INTO var_count;

            WHILE var_count <= 10
                LOOP
                    SELECT safe_substring(par_care_category, var_count, 1)
                    INTO var_move_care;

                    IF var_move_care IS NULL OR var_move_care = var_care THEN
                        BEGIN
                            SELECT var_adm0 + var_adm3 + var_adm4 + var_adm5 + var_adm8
                            INTO var_ttl_adm;
                            SELECT var_dsch0 + var_dsch1 + var_dsch2 + var_dsch3 + var_dsch4 + var_dsch5 + var_dsch6 +
                                   var_dsch7 + var_dscha + var_dschm
                            INTO var_ttl_dsch;

                            IF COALESCE(var_ttl_adm, -1) <> 0 OR COALESCE(var_ttl_dsch, -1) <> 0 OR
                               COALESCE(var_xout, -1) <> 0 OR COALESCE(var_los, -1) <> 0 THEN
                                BEGIN
                                    IF var_prev_spec IS NOT NULL
                                        AND COALESCE(var_spec, 'null') <> COALESCE(var_prev_spec, 'null') THEN
                                        BEGIN
                                            IF var_loc_count > 1 THEN
                                                BEGIN
                                                    IF par_care_category IS NULL THEN
                                                        SELECT 'SPECIALTY TOTAL'
                                                        INTO var_desc;
                                                    ELSE
                                                        SELECT 'SUB-TOTAL'
                                                        INTO var_desc;
                                                    END IF;
                                                    INSERT INTO t$dsptable (spec_code, care_type, loc, adm0, adm3, adm4,
                                                                            adm5, adm8, dsch0, dsch1, dsch2, dsch3,
                                                                            dsch4, dsch5, dsch6, dsch7, dscha, dschm,
                                                                            xout, los, description, ttl_adm, ttl_dsch,
                                                                            dp_dsch)
                                                    VALUES (NULL, NULL, NULL, var_spec_adm0, var_spec_adm3,
                                                            var_spec_adm4, var_spec_adm5, var_spec_adm8, var_spec_dsch0,
                                                            var_spec_dsch1, var_spec_dsch2, var_spec_dsch3,
                                                            var_spec_dsch4, var_spec_dsch5, var_spec_dsch6,
                                                            var_spec_dsch7, var_spec_dscha, var_spec_dschm,
                                                            var_spec_xout, var_spec_los, var_desc, var_spec_ttl_adm,
                                                            var_spec_ttl_dsch, var_spec_dp);
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
                                                   0
                                            INTO var_spec_adm0, var_spec_adm3, var_spec_adm4, var_spec_adm5, var_spec_adm8, var_spec_dsch0, var_spec_dsch1, var_spec_dsch2, var_spec_dsch3, var_spec_dsch4, var_spec_dsch5, var_spec_dsch6, var_spec_dsch7, var_spec_dscha, var_spec_dschm, var_spec_los, var_spec_xout, var_spec_ttl_adm, var_spec_ttl_dsch, var_spec_dp;
                                            SELECT 0
                                            INTO var_loc_count;
                                        END;
                                    END IF;

                                    IF var_care = 'U' THEN
                                        SELECT 'ICU'
                                        INTO var_desc;
                                    ELSE
                                        IF var_care = 'H' THEN
                                            SELECT 'HDU'
                                            INTO var_desc;
                                        ELSE
                                            IF var_care = 'X' THEN
                                                SELECT 'ICU in non-ICU'
                                                INTO var_desc;
                                            ELSE
                                                IF var_care = 'Y' THEN
                                                    SELECT 'HDU in non-ICU'
                                                    INTO var_desc;
                                                ELSE
                                                    IF var_care = 'A' THEN
                                                        SELECT 'ACUTE'
                                                        INTO var_desc;
                                                    ELSE
                                                        IF var_care = 'I' THEN
                                                            SELECT 'INFIMARY'
                                                            INTO var_desc;
                                                        ELSE
                                                            IF var_care = 'R' THEN
                                                                SELECT 'CONVALESCENCE/REHABILITATION'
                                                                INTO var_desc;
                                                            ELSE
                                                                IF var_care = 'M' THEN
                                                                    SELECT 'MIXED'
                                                                    INTO var_desc;
                                                                ELSE
                                                                    SELECT var_care
                                                                    INTO var_desc;
                                                                END IF;
                                                            END IF;
                                                        END IF;
                                                    END IF;
                                                END IF;
                                            END IF;
                                        END IF;
                                    END IF;
                                    SELECT var_spec,
                                           var_loc_count + 1,
                                           var_spec_adm0 + var_adm0,
                                           var_spec_adm3 + var_adm3,
                                           var_spec_adm4 + var_adm4,
                                           var_spec_adm5 + var_adm5,
                                           var_spec_adm8 + var_adm8,
                                           var_spec_dsch0 + var_dsch0,
                                           var_spec_dsch1 + var_dsch1,
                                           var_spec_dsch2 + var_dsch2,
                                           var_spec_dsch3 + var_dsch3,
                                           var_spec_dsch4 + var_dsch4,
                                           var_spec_dsch5 + var_dsch5,
                                           var_spec_dsch6 + var_dsch6,
                                           var_spec_dsch7 + var_dsch7,
                                           var_spec_dscha + var_dscha,
                                           var_spec_dschm + var_dschm,
                                           var_spec_xout + var_xout,
                                           var_spec_los + var_los,
                                           var_spec_ttl_adm + var_ttl_adm,
                                           var_spec_ttl_dsch + var_ttl_dsch,
                                           var_spec_dp + var_dp
                                    INTO var_prev_spec, var_loc_count, var_spec_adm0, var_spec_adm3, var_spec_adm4, var_spec_adm5, var_spec_adm8, var_spec_dsch0, var_spec_dsch1, var_spec_dsch2, var_spec_dsch3, var_spec_dsch4, var_spec_dsch5, var_spec_dsch6, var_spec_dsch7, var_spec_dscha, var_spec_dschm, var_spec_xout, var_spec_los, var_spec_ttl_adm, var_spec_ttl_dsch, var_spec_dp;
                                    /*
                                    if @loc_count = 1 or @loc is null
                                    begin
                                        select @hosp_adm0 = @hosp_adm0 + @adm0,
                                            @hosp_adm3 = @hosp_adm3 + @adm3,
                                            @hosp_adm4 = @hosp_adm4 + @adm4,
                                            @hosp_adm5 = @hosp_adm5 + @adm5,
                                            @hosp_adm8 = @hosp_adm8 + @adm8,
                                            @hosp_dsch0 = @hosp_dsch0 + @dsch0,
                                            @hosp_dsch1 = @hosp_dsch1 + @dsch1,
                                            @hosp_dsch2 = @hosp_dsch2 + @dsch2,
                                            @hosp_dsch3 = @hosp_dsch3 + @dsch3,
                                            @hosp_dsch4 = @hosp_dsch4 + @dsch4,
                                            @hosp_dsch5 = @hosp_dsch5 + @dsch5,
                                            @hosp_dsch6 = @hosp_dsch6 + @dsch6,
                                            @hosp_dsch7 = @hosp_dsch7 + @dsch7,
                                            @hosp_dscha = @hosp_dscha + @dscha,
                                            @hosp_dschm = @hosp_dschm + @dschm,
                                            @hosp_xout = @hosp_xout + @xout,
                                            @hosp_los = @hosp_los + @los,
                                            @hosp_ttl_adm = @hosp_ttl_adm + @ttl_adm,
                                            @hosp_ttl_dsch = @hosp_ttl_dsch + @ttl_dsch,
                                            @hosp_dp = @hosp_dp + @dp
                                        if exists(select * from #caretable
                                            where care_type = @care)
                                            update #caretable set
                                                adm0 = adm0 + @adm0,
                                                adm3 = adm3 + @adm3,
                                                adm4 = adm4 + @adm4,
                                                adm5 = adm5 + @adm5,
                                                adm8 = adm8 + @adm8,
                                                dsch0 = dsch0 + @dsch0,
                                                dsch1 = dsch1 + @dsch1,
                                                dsch2 = dsch2 + @dsch2,
                                                dsch3 = dsch3 + @dsch3,
                                                dsch4 = dsch4 + @dsch4,
                                                dsch5 = dsch5 + @dsch5,
                                                dsch6 = dsch6 + @dsch6,
                                                dsch7 = dsch7 + @dsch7,
                                                dscha = dscha + @dscha,
                                                dschm = dschm + @dschm,
                                                los = los + @los,
                                                xout = xout + @xout,
                                                ttl_adm = ttl_adm + @ttl_adm,
                                                ttl_dsch = ttl_dsch + @ttl_dsch,
                                                dp_dsch = dp_dsch + @dp
                                                where care_type = @care
                                        else
                                            insert into #caretable
                                                (care_type, adm0, adm3, adm4, adm5, adm8,
                                                dsch0, dsch1, dsch2, dsch3,
                                                dsch4, dsch5, dsch6, dsch7, dscha, dschm, xout, los,
                                                ttl_adm, ttl_dsch, dp_dsch)
                                                values
                                                (@care, @adm0, @adm3, @adm4,
                                                @adm5, @adm8,
                                                @dsch0, @dsch1, @dsch2, @dsch3, @dsch4,
                                                @dsch5, @dsch6, @dsch7, @dscha, @dschm,
                                                @xout, @los, @ttl_adm, @ttl_dsch, @dp)
                                    end
                                    */
                                    IF var_loc_count > 1 THEN
                                        SELECT NULL
                                        INTO var_out_spec;
                                    ELSE
                                        SELECT var_spec
                                        INTO var_out_spec;
                                    END IF;
                                    INSERT INTO t$dsptable (spec_code, care_type, loc, adm0, adm3, adm4, adm5, adm8,
                                                            dsch0, dsch1, dsch2, dsch3, dsch4, dsch5, dsch6, dscha,
                                                            dschm, xout, los, description, ttl_adm, ttl_dsch, dsch7,
                                                            dp_dsch)
                                    VALUES (var_out_spec, var_care, var_loc, var_adm0, var_adm3, var_adm4, var_adm5,
                                            var_adm8, var_dsch0, var_dsch1, var_dsch2, var_dsch3, var_dsch4, var_dsch5,
                                            var_dsch6, var_dscha, var_dschm, var_xout, var_los, var_desc, var_ttl_adm,
                                            var_ttl_dsch, var_dsch7, var_dp);
                                END;
                            END IF;
                            SELECT 11
                            INTO var_count;
                        END;
                    ELSE
                        SELECT var_count + 1
                        INTO var_count;
                    END IF;
                END LOOP;
            FETCH dsp_csr INTO var_spec, var_care, var_loc, var_adm0, var_adm3, var_adm4, var_adm5, var_adm8, var_dsch0, var_dsch1, var_dsch2, var_dsch3, var_dsch4, var_dsch5, var_dsch6, var_dsch7, var_dscha, var_dschm, var_los, var_xout, var_dp;
        END LOOP;
    CLOSE dsp_csr;

    IF var_loc_count > 1 THEN
        INSERT INTO t$dsptable (spec_code, care_type, loc, adm0, adm3, adm4, adm5, adm8, dsch0, dsch1, dsch2, dsch3,
                                dsch4, dsch5, dsch6, dsch7, dscha, dschm, xout, los, description, ttl_adm, ttl_dsch,
                                dp_dsch)
        VALUES (NULL, NULL, NULL, var_spec_adm0, var_spec_adm3, var_spec_adm4, var_spec_adm5, var_spec_adm8,
                var_spec_dsch0, var_spec_dsch1, var_spec_dsch2, var_spec_dsch3, var_spec_dsch4, var_spec_dsch5,
                var_spec_dsch6, var_spec_dsch7, var_spec_dscha, var_spec_dschm, var_spec_xout, var_spec_los,
                'SPECIALTY TOTAL', var_spec_ttl_adm, var_spec_ttl_dsch, var_spec_dp);
    END IF;

    IF par_care_category IS NULL THEN
        SELECT 'HOSPITAL TOTAL'
        INTO var_desc;
    ELSE
        SELECT 'GRAND TOTAL'
        INTO var_desc;
    END IF;
    /*
    select @adm0 = sum(adm0), @adm3 = sum(adm3), @adm4 = sum(adm4),
    @adm5 = sum(adm5), @adm8 = sum(adm8), @dsch0 = sum(dsch0),
    @dsch1 = sum(dsch1), @dsch2 = sum(dsch2), @dsch3 = sum(dsch3),
    @dsch4 = sum(dsch4), @dsch5 = sum(dsch5), @dsch6 = sum(dsch6),
    @dscha = sum(dscha), @dschm = sum(dschm), @xout = sum(xout),
    @los = sum(los), @ttl_adm = sum(ttl_adm), @ttl_dsch = sum(ttl_dsch),
    @dsch7 = sum(dsch7)
    from #dsptable
    */
    SELECT NULL,
           NULL,
           NULL
    INTO var_care, var_spec, var_loc;
    SELECT (CASE
        WHEN CAST(var_hosp_ttl_dsch - var_hosp_dp AS REAL) = 0 THEN NULL
        ELSE (CAST(var_hosp_los AS REAL) / CAST(var_hosp_ttl_dsch - var_hosp_dp AS REAL))
        END)
    INTO var_alos;
    INSERT INTO t$dsptable (spec_code, care_type, description, loc, adm0, adm3, adm4, adm5, adm8, dsch0, dsch1, dsch2,
                            dsch3, dsch4, dsch5, dsch6, dscha, dschm, xout, los, ttl_adm, ttl_dsch, dsch7, dp_dsch,
                            alos)
    VALUES (var_spec, var_care, var_desc, var_loc, var_hosp_adm0, var_hosp_adm3, var_hosp_adm4, var_hosp_adm5,
            var_hosp_adm8, var_hosp_dsch0, var_hosp_dsch1, var_hosp_dsch2, var_hosp_dsch3, var_hosp_dsch4,
            var_hosp_dsch5, var_hosp_dsch6, var_hosp_dscha, var_hosp_dschm, var_hosp_xout, var_hosp_los,
            var_hosp_ttl_adm, var_hosp_ttl_dsch, var_hosp_dsch7, var_hosp_dp, var_alos);

    IF par_care_category IS NULL THEN
        INSERT INTO t$dsptable (spec_code, care_type, description, loc, adm0, adm3, adm4, adm5, adm8, dsch0, dsch1,
                                dsch2, dsch3, dsch4, dsch5, dsch6, dscha, dschm, xout, los, ttl_adm, ttl_dsch, dsch7,
                                dp_dsch)
        SELECT spec_code,
               care_type,
               'HOME',
               loc,
               adm0,
               adm3,
               adm4,
               adm5,
               adm8,
               dsch0,
               dsch1,
               dsch2,
               dsch3,
               dsch4,
               dsch5,
               dsch6,
               dscha,
               dschm,
               xout,
               los,
               adm0 + adm3 + adm4 + adm5 + adm8,
               dsch0 + dsch1 + dsch2 + dsch3 + dsch4 + dsch5 + dsch6 + dsch7 + dscha + dschm,
               dsch7,
               dp_dsch
        FROM t$outtable
        WHERE spec_code = 'HOME';
    END IF;
    UPDATE t$caretable
    SET description = 'ACUTE TOTAL'
    WHERE care_type = 'A';
    UPDATE t$caretable
    SET description = 'ICU TOTAL'
    WHERE care_type = 'U';
    UPDATE t$caretable
    SET description = 'HDU TOTAL'
    WHERE care_type = 'H';
    UPDATE t$caretable
    SET description = 'ICU in non-ICU TOTAL'
    WHERE care_type = 'X';
    UPDATE t$caretable
    SET description = 'HCU in non-ICU TOTAL'
    WHERE care_type = 'Y';
    UPDATE t$caretable
    SET description = 'Infirmary TOTAL'
    WHERE care_type = 'I';
    UPDATE t$caretable
    SET description = 'CONVALESCENCE/REHABILITATION TOTAL'
    WHERE care_type = 'R';
    UPDATE t$caretable
    SET description = 'MIXED TOTAL'
    WHERE care_type = 'M';
    INSERT INTO t$dsptable (spec_code, care_type, description, loc, adm0, adm3, adm4, adm5, adm8, dsch0, dsch1, dsch2,
                            dsch3, dsch4, dsch5, dsch6, dscha, dschm, xout, los, ttl_adm, ttl_dsch, dsch7, dp_dsch)
    SELECT NULL,
           care_type,
           description,
           NULL,
           adm0,
           adm3,
           adm4,
           adm5,
           adm8,
           dsch0,
           dsch1,
           dsch2,
           dsch3,
           dsch4,
           dsch5,
           dsch6,
           dscha,
           dschm,
           xout,
           los,
           ttl_adm,
           ttl_dsch,
           dsch7,
           dp_dsch
    FROM t$caretable
    ORDER BY care_type;
   
    UPDATE t$dsptable
    SET alos = CAST(los AS REAL) / (CAST(xout + ttl_dsch - dp_dsch AS REAL))
    WHERE loc IS NULL
      AND COALESCE(xout + ttl_dsch - dp_dsch, -1) <> 0
      AND alos IS NULL;
    
    UPDATE t$dsptable AS d
    SET loc = s.Description
    FROM Specialty AS s
    WHERE spec_code IS NOT NULL
      AND loc IS NULL
      AND spec_code = Specialty_code
      AND Hospital_code = par_hospital_code
      AND Effective_date = (SELECT MAX(Effective_date)
                            FROM Specialty
                            WHERE Specialty_code = s.Specialty_code
                              AND Hospital_code = par_hospital_code
                              AND Effective_date < par_to_date);
    
    OPEN p_refcur FOR
        SELECT spec_code,
               description,
               loc,
               adm0,
               adm3,
               adm4,
               adm5,
               adm8,
               ttl_adm,
               dsch0,
               dsch1,
               dsch2,
               dsch3,
               dsch4,
               dsch5,
               dsch6,
               dsch7,
               dscha,
               dschm,
               ttl_dsch,
               xout,
               los,
               alos
        FROM t$dsptable
        ORDER BY record_id NULLS FIRST;

END;
$procedure$
;

;ALTER PROCEDURE "hasp_web_adds_by_care_report" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
