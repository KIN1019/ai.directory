-- DROP PROCEDURE hpi.hasp_get_los(inout int4, in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_los(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_input_from_datetime timestamp without time zone, IN par_input_to_datetime timestamp without time zone, IN par_input_spec character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_error     INTEGER;
    var_rowcount  INTEGER;
    var_errarg    VARCHAR(160);
    var_case      VARCHAR(24);
    var_spec      VARCHAR(8);
    var_los       SMALLINT;
    var_adm_date  TIMESTAMP WITHOUT TIME ZONE;
    var_dsch_date TIMESTAMP WITHOUT TIME ZONE;
    var_last_date TIMESTAMP WITHOUT TIME ZONE;
    var_move_spec VARCHAR(8);
    var_last_spec VARCHAR(8);
    var_move_date TIMESTAMP WITHOUT TIME ZONE;
    tx_csr CURSOR FOR
        SELECT Case_no,
               From_specialty_code
        /* --from Transaction_log */
        FROM Transaction_log
        WHERE Transaction_datetime >= par_input_from_datetime
          AND Transaction_datetime < 1 * INTERVAL '1 day' + par_input_to_datetime::TIMESTAMP
          AND Transaction_type LIKE '13_'
          AND COALESCE(From_ward_code, 'null') <> 'AE01'
          AND Cancel_flag IS NULL
          AND From_specialty_code LIKE par_input_spec
          AND Hospital_code = par_hosp_code;
    move_csr CURSOR FOR
        SELECT Specialty_code,
               Movement_datetime
        FROM Movement
        WHERE Case_no = var_case
          AND Hospital_code = par_hosp_code;
    sql$rowcount  BIGINT;
BEGIN
    /*
    Discharged Patient Stat. by Actual LOS
    --------------------------------------
    parameter name          Description
    @input_from_datetime    Report start date to be processed
    @input_to_datetime      Report end date to be processed
    @input_spec             Specialty code to be processed
    
    27.07.1999 - Add hosp code for HPI by Mabel LAU
    */
    /* declare temporary variables */
    /* create temp table */
    DROP TABLE IF EXISTS t$los_table;
    CREATE TEMPORARY TABLE t$los_table
    (
        los_spec VARCHAR(8)  NOT NULL,
        los_desc VARCHAR(60) NULL,
        los_1    SMALLINT,
        los_2    SMALLINT,
        los_3    SMALLINT,
        los_4    SMALLINT,
        los_5    SMALLINT,
        los_6    SMALLINT,
        los_7    SMALLINT,
        los_8    SMALLINT,
        los_9    SMALLINT,
        los_10   SMALLINT,
        los_11   SMALLINT,
        los_12   SMALLINT,
        los_13   SMALLINT,
        los_14   SMALLINT,
        los_15   SMALLINT,
        los_16   SMALLINT,
        los_17   SMALLINT,
        los_18   SMALLINT,
        los_19   SMALLINT,
        los_20   SMALLINT,
        los_21   SMALLINT,
        los_22   SMALLINT,
        los_23   SMALLINT,
        los_24   SMALLINT,
        los_25   SMALLINT,
        los_26   SMALLINT,
        los_27   SMALLINT,
        los_28   SMALLINT,
        los_29   SMALLINT,
        los_30   SMALLINT,
        los_31   SMALLINT,
        los_32   SMALLINT,
        los_33   SMALLINT,
        los_34   SMALLINT,
        los_35   SMALLINT,
        los_36   SMALLINT
    );
    /* declare cursor for selecting discharged cases */
    /* add hosp code for HPI by ML on 27.07.1999 */
    /* add hosp code for HPI by ML on 27.07.1999 */
    OPEN tx_csr;
    FETCH tx_csr INTO var_case, var_spec;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            IF var_spec = 'HOME' THEN
                SELECT 'PSY'
                INTO var_spec;
            END IF;

            IF NOT EXISTS (SELECT *
                           FROM t$los_table
                           WHERE var_spec = los_spec) THEN
                INSERT INTO t$los_table
                VALUES (var_spec, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0, 0);
            END IF;
            /*
            select @adm_date = Admission_datetime, @dsch_date = Discharge_datetime
            from Case
            where Case_no = @case
            */
            OPEN move_csr;
            FETCH move_csr INTO var_move_spec, var_move_date;
            SELECT var_move_date,
                   0,
                   var_move_date,
                   var_move_spec
            INTO var_last_date, var_los, var_adm_date, var_last_spec;

            WHILE (CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
                END) = 0
                LOOP
                    IF COALESCE(var_last_spec, 'null') <> 'HOME' THEN
                        SELECT var_los + DATE_PART('days', var_move_date::TIMESTAMP::DATE::TIMESTAMP -
                                                           var_last_date::TIMESTAMP::DATE::TIMESTAMP)
                        INTO var_los;
                    END IF;
                    SELECT var_move_date,
                           var_move_spec
                    INTO var_last_date, var_last_spec;
                    FETCH move_csr INTO var_move_spec, var_move_date;
                END LOOP;
            CLOSE move_csr;
            SELECT var_los * INTERVAL '1 day' + var_adm_date::TIMESTAMP
            INTO var_dsch_date;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount > 0 THEN
                BEGIN
                    /*
                    select @los = datediff(yy,@adm_date,@dsch_date)

                    if @los = 0
                    begin
                            select @los = datediff(dd,@adm_date,@dsch_date)
                            If @los > 300
                                    update #los_table set
                                            los_6 = los_6 + 1
                                            where los_spec = @spec
                            else
                            if @los > 240
                                    update #los_table set
                                            los_5 = los_5 + 1
                                            where los_spec = @spec
                            else
                            if @los > 180
                                    update #los_table set
                                            los_4 = los_4 + 1
                                            where los_spec = @spec
                            else
                            if @los > 120
                                    update #los_table set
                                            los_3 = los_3 + 1
                                            where los_spec = @spec
                            else
                            if @los > 60
                                    update #los_table set
                                            los_2 = los_2 + 1
                                            where los_spec = @spec
                            else
                                    update #los_table set
                                            los_1 = los_1 + 1
                                            where los_spec = @spec
                    end
                    else
                    begin
                            if @los > 30
                                    update #los_table set
                                            los_36 = los_36 + 1
                                            where los_spec = @spec

                            if @los = 30
                                    update #los_table set
                                            los_35 = los_35 + 1
                                            where los_spec = @spec

                            if @los = 29
                                    update #los_table set
                                            los_34 = los_34 + 1
                                            where los_spec = @spec

                            if @los = 28
                                    update #los_table set
                                            los_33 = los_33 + 1
                                            where los_spec = @spec

                            if @los = 27
                                    update #los_table set
                                            los_32 = los_32 + 1
                                            where los_spec = @spec

                            if @los = 26
                                    update #los_table set
                                            los_31 = los_31 + 1
                                            where los_spec = @spec

                            if @los = 25
                                    update #los_table set
                                            los_30 = los_30 + 1
                                            where los_spec = @spec

                            if @los = 24
                                    update #los_table set
                                            los_29 = los_29 + 1
                                            where los_spec = @spec

                            if @los = 23
                                    update #los_table set
                                            los_28 = los_28 + 1
                                            where los_spec = @spec

                            if @los = 22
                                    update #los_table set
                                            los_27 = los_27 + 1
                                            where los_spec = @spec

                            if @los = 21
                                    update #los_table set
                                            los_26 = los_26 + 1
                                            where los_spec = @spec

                            if @los = 20
                                    update #los_table set
                                            los_25 = los_25 + 1
                                            where los_spec = @spec

                            if @los = 19
                                    update #los_table set
                                            los_24 = los_24 + 1
                                            where los_spec = @spec

                            if @los = 18
                                    update #los_table set
                                            los_23 = los_23 + 1
                                            where los_spec = @spec

                            if @los = 17
                                    update #los_table set
                                            los_22 = los_22 + 1
                                            where los_spec = @spec

                            if @los = 16
                                    update #los_table set
                                            los_21 = los_21 + 1
                                            where los_spec = @spec

                            if @los = 15
                                    update #los_table set
                                            los_20 = los_20 + 1
                                            where los_spec = @spec

                            if @los = 14
                                    update #los_table set
                                            los_19 = los_19 + 1
                                            where los_spec = @spec

                            if @los = 13
                                    update #los_table set
                                            los_18 = los_18 + 1
                                            where los_spec = @spec

                            if @los = 12
                                    update #los_table set
                                            los_17 = los_17 + 1
                                            where los_spec = @spec

                            if @los = 11
                                    update #los_table set
                                            los_16 = los_16 + 1
                                            where los_spec = @spec

                            if @los = 10
                                    update #los_table set
                                            los_15 = los_15 + 1
                                            where los_spec = @spec

                            if @los = 9
                                    update #los_table set
                                            los_14 = los_14 + 1
                                            where los_spec = @spec

                            if @los = 8
                                    update #los_table set
                                            los_13 = los_13 + 1
                                            where los_spec = @spec

                            if @los = 7
                                    update #los_table set
                                            los_12 = los_12 + 1
                                            where los_spec = @spec

                            if @los = 6
                                    update #los_table set
                                            los_11 = los_11 + 1
                                            where los_spec = @spec

                            if @los = 5
                                    update #los_table set
                                            los_10 = los_10 + 1
                                            where los_spec = @spec

                            if @los = 4
                                    update #los_table set
                                            los_9 = los_9 + 1
                                            where los_spec = @spec

                            if @los = 3
                                    update #los_table set
                                            los_8 = los_8 + 1
                                            where los_spec = @spec

                            if @los = 2
                                    update #los_table set
                                            los_7 = los_7 + 1
                                            where los_spec = @spec

                            if @los = 1
                                    update #los_table set
                                            los_6 = los_6 + 1
                                            where los_spec = @spec

                    end
                    */
                    IF 1 * INTERVAL '1 year' + var_adm_date::TIMESTAMP < var_dsch_date THEN
                        BEGIN
                            SELECT
                                DATE_PART('year', var_dsch_date::TIMESTAMP) - DATE_PART('year', var_adm_date::TIMESTAMP)
                            INTO var_los;

                            IF var_los * INTERVAL '1 year' + var_adm_date::TIMESTAMP > var_dsch_date THEN
                                SELECT var_los - 1
                                INTO var_los;
                            END IF;

                            IF var_los > 30 THEN
                                UPDATE t$los_table
                                SET los_36 = los_36 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 30 THEN
                                UPDATE t$los_table
                                SET los_35 = los_35 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 29 THEN
                                UPDATE t$los_table
                                SET los_34 = los_34 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 28 THEN
                                UPDATE t$los_table
                                SET los_33 = los_33 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 27 THEN
                                UPDATE t$los_table
                                SET los_32 = los_32 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 26 THEN
                                UPDATE t$los_table
                                SET los_31 = los_31 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 25 THEN
                                UPDATE t$los_table
                                SET los_30 = los_30 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 24 THEN
                                UPDATE t$los_table
                                SET los_29 = los_29 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 23 THEN
                                UPDATE t$los_table
                                SET los_28 = los_28 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 22 THEN
                                UPDATE t$los_table
                                SET los_27 = los_27 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 21 THEN
                                UPDATE t$los_table
                                SET los_26 = los_26 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 20 THEN
                                UPDATE t$los_table
                                SET los_25 = los_25 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 19 THEN
                                UPDATE t$los_table
                                SET los_24 = los_24 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 18 THEN
                                UPDATE t$los_table
                                SET los_23 = los_23 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 17 THEN
                                UPDATE t$los_table
                                SET los_22 = los_22 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 16 THEN
                                UPDATE t$los_table
                                SET los_21 = los_21 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 15 THEN
                                UPDATE t$los_table
                                SET los_20 = los_20 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 14 THEN
                                UPDATE t$los_table
                                SET los_19 = los_19 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 13 THEN
                                UPDATE t$los_table
                                SET los_18 = los_18 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 12 THEN
                                UPDATE t$los_table
                                SET los_17 = los_17 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 11 THEN
                                UPDATE t$los_table
                                SET los_16 = los_16 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 10 THEN
                                UPDATE t$los_table
                                SET los_15 = los_15 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 9 THEN
                                UPDATE t$los_table
                                SET los_14 = los_14 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 8 THEN
                                UPDATE t$los_table
                                SET los_13 = los_13 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 7 THEN
                                UPDATE t$los_table
                                SET los_12 = los_12 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 6 THEN
                                UPDATE t$los_table
                                SET los_11 = los_11 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 5 THEN
                                UPDATE t$los_table
                                SET los_10 = los_10 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 4 THEN
                                UPDATE t$los_table
                                SET los_9 = los_9 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 3 THEN
                                UPDATE t$los_table
                                SET los_8 = los_8 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 2 THEN
                                UPDATE t$los_table
                                SET los_7 = los_7 + 1
                                WHERE los_spec = var_spec;
                            END IF;

                            IF var_los = 1 THEN
                                UPDATE t$los_table
                                SET los_6 = los_6 + 1
                                WHERE los_spec = var_spec;
                            END IF;
                        END;
                    ELSE
                        BEGIN
                            SELECT DATE_PART('days', var_dsch_date::TIMESTAMP::DATE::TIMESTAMP -
                                                     var_adm_date::TIMESTAMP::DATE::TIMESTAMP)
                            INTO var_los;

                            IF var_los > 180 THEN
                                UPDATE t$los_table
                                SET los_5 = los_5 + 1
                                WHERE los_spec = var_spec;
                            ELSE
                                IF var_los > 90 THEN
                                    UPDATE t$los_table
                                    SET los_4 = los_4 + 1
                                    WHERE los_spec = var_spec;
                                ELSE
                                    IF var_los > 60 THEN
                                        UPDATE t$los_table
                                        SET los_3 = los_3 + 1
                                        WHERE los_spec = var_spec;
                                    ELSE
                                        IF var_los > 30 THEN
                                            UPDATE t$los_table
                                            SET los_2 = los_2 + 1
                                            WHERE los_spec = var_spec;
                                        ELSE
                                            UPDATE t$los_table
                                            SET los_1 = los_1 + 1
                                            WHERE los_spec = var_spec;
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
            FETCH tx_csr INTO var_case, var_spec;
        END LOOP;
    CLOSE tx_csr;
    /* add hosp code for HPI by ML on 27.07.1999 */
    UPDATE t$los_table AS a
    SET los_desc = (SELECT s.Description
                    FROM Specialty AS s
                    WHERE s.Specialty_code = a.los_spec
                      AND s.Hospital_code = par_hosp_code
                      AND s.Effective_date = (SELECT MAX(s2.Effective_date)
                                              FROM Specialty AS s2
                                              WHERE s2.Effective_date <= par_input_to_datetime
                                                AND s2.Specialty_code = a.los_spec
                                                AND s2.Hospital_code = par_hosp_code));
                                               
    OPEN p_refcur FOR
        SELECT los_spec,
               los_desc,
               los_1,
               los_2,
               los_3,
               los_4,
               los_5,
               los_6,
               los_7,
               los_8,
               los_9,
               los_10,
               los_11,
               los_12,
               los_13,
               los_14,
               los_15,
               los_16,
               los_17,
               los_18,
               los_19,
               los_20,
               los_21,
               los_22,
               los_23,
               los_24,
               los_25,
               los_26,
               los_27,
               los_28,
               los_29,
               los_30,
               los_31,
               los_32,
               los_33,
               los_34,
               los_35,
               los_36
        FROM t$los_table
        WHERE los_1 > 0
           OR los_2 > 0
           OR los_3 > 0
           OR los_4 > 0
           OR los_5 > 0
           OR los_6 > 0
           OR los_7 > 0
           OR los_8 > 0
           OR los_9 > 0
           OR los_10 > 0
           OR los_11 > 0
           OR los_12 > 0
           OR los_13 > 0
           OR los_14 > 0
           OR los_15 > 0
           OR los_16 > 0
           OR los_17 > 0
           OR los_18 > 0
           OR los_19 > 0
           OR los_20 > 0
           OR los_21 > 0
           OR los_22 > 0
           OR los_23 > 0
           OR los_24 > 0
           OR los_25 > 0
           OR los_26 > 0
           OR los_27 > 0
           OR los_28 > 0
           OR los_29 > 0
           OR los_30 > 0
           OR los_31 > 0
           OR los_32 > 0
           OR los_33 > 0
           OR los_34 > 0
           OR los_35 > 0
           OR los_36 > 0
        ORDER BY los_spec NULLS FIRST;
    pas_return_code := 0;
    RETURN;
END ;
$procedure$
;

;ALTER PROCEDURE "hasp_get_los" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
