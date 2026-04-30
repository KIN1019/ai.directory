CREATE OR REPLACE PROCEDURE hasp_eis_subx(INOUT pas_return_code int, IN par_input_date TIMESTAMP WITHOUT TIME ZONE, IN par_input_offset INTEGER, IN par_hospital_code VARCHAR)
AS 
$BODY$
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_errarg VARCHAR(80);
    var_from_date TIMESTAMP WITHOUT TIME ZONE;
    var_to_date TIMESTAMP WITHOUT TIME ZONE;
    var_hosp VARCHAR(6);
    var_month VARCHAR(12);
    var_from_ward VARCHAR(8);
    var_from_spec VARCHAR(8);
    var_from_loc VARCHAR(8);
    var_to_ward VARCHAR(8);
    var_to_spec VARCHAR(8);
    var_to_loc VARCHAR(8);
    var_from_imis VARCHAR(6);
    var_to_imis VARCHAR(6);
    var_tx_within INTEGER;
    var_tx_between INTEGER;
    csr CURSOR FOR
    SELECT
        From_ward_code, From_specialty_code, From_treatment_location, To_ward_code, To_specialty_code, To_treatment_location
        FROM Transaction_log
        WHERE Transaction_datetime >= var_from_date AND Transaction_datetime < var_to_date AND Transaction_type = '140' AND Cancel_flag IS NULL AND From_ward_code <> 'AE01' AND Hospital_code = var_hosp;
BEGIN
    /*
    Generate EIS Interface for Transfer Within Specialty
    
    parameter name          Description
    @input_date					Start date for extraction
    @input_offset				Month offset
    @hospital_code				Hospital to be processed
    */
    IF par_input_date IS NULL THEN
        SELECT
            - 1 * INTERVAL '1 month' + CONCAT(to_char(localtimestamp, 'YYYYMM'), '01')::TIMESTAMP
            INTO var_from_date;
    ELSE
        SELECT
            CONCAT(to_char(par_input_date, 'YYYYMM'), '01')
            INTO var_from_date;
    END IF;
    SELECT
        par_input_offset * INTERVAL '1 month' + var_from_date::TIMESTAMP
        INTO var_from_date;
    SELECT
        1 * INTERVAL '1 month' + var_from_date::TIMESTAMP
        INTO var_to_date;
    /* select @hosp = Hospital_code from Hospital */
    SELECT
        par_hospital_code
        INTO var_hosp;
    SELECT
        to_char(var_from_date, 'YYYYMMDD')
        INTO var_month;
    /* due to warm stand by, change truncate to delete by WL */
    /* --truncate table eis_subx */
    DELETE FROM eis_subx;
    DROP TABLE IF EXISTS t$eis_table;
    CREATE TEMPORARY TABLE t$eis_table
    (eis_spec VARCHAR(3),
        eis_within INTEGER,
        eis_between INTEGER);
    OPEN csr;
    FETCH csr INTO var_from_ward, var_from_spec, var_from_loc, var_to_ward, var_to_spec, var_to_loc;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            NULL, NULL
            INTO var_from_imis, var_to_imis;

        IF var_from_loc IS NOT NULL THEN
            BEGIN
                SELECT
                    IMIS_code
                    INTO var_from_imis
                    FROM (SELECT
                        IMIS_code, Specialty_code, Effective_date
                        FROM Specialty) AS ungrouped_query
                    INNER JOIN (SELECT
                        Specialty_code, MAX(Effective_date) AS max_1
                        FROM Specialty
                        WHERE Specialty_code = var_from_loc AND Effective_date < var_to_date AND Hospital_code = var_hosp
                        GROUP BY Specialty_code) AS grouped_query
                        ON (ungrouped_query.Specialty_code = grouped_query.Specialty_code OR (ungrouped_query.Specialty_code IS NULL AND grouped_query.Specialty_code IS NULL))
                    WHERE Effective_date = max_1;

                IF var_from_imis NOT IN ('ICU', 'CCU', 'PRI', 'PIC', 'SCB', 'NIC') THEN
                    SELECT
                        NULL
                        INTO var_from_imis;
                END IF;
            END;
        END IF;

        IF var_from_imis IS NULL THEN
            SELECT
                IMIS_code
                INTO var_from_imis
                FROM (SELECT
                    IMIS_code, Specialty_code, Effective_date
                    FROM Specialty) AS ungrouped_query
                INNER JOIN (SELECT
                    Specialty_code, MAX(Effective_date) AS max_1
                    FROM Specialty
                    WHERE Specialty_code = var_from_spec AND Effective_date < var_to_date AND Hospital_code = var_hosp
                    GROUP BY Specialty_code) AS grouped_query
                    ON (ungrouped_query.Specialty_code = grouped_query.Specialty_code OR (ungrouped_query.Specialty_code IS NULL AND grouped_query.Specialty_code IS NULL))
                WHERE Effective_date = max_1;
        END IF;
        /* added by chuls @990707 for adding MED, GER, TBC, CCU, MID, PID */
        IF var_from_imis IN ('PAE', 'NIC', 'PIC', 'SCB') OR (var_from_imis IN ('MED', 'GER', 'TBC', 'CCU', 'MID', 'PID') AND var_from_date >= '19990401') THEN
            BEGIN
                IF var_to_loc IS NOT NULL THEN
                    BEGIN
                        SELECT
                            IMIS_code
                            INTO var_to_imis
                            FROM (SELECT
                                IMIS_code, Specialty_code, Effective_date
                                FROM Specialty) AS ungrouped_query
                            INNER JOIN (SELECT
                                Specialty_code, MAX(Effective_date) AS max_1
                                FROM Specialty
                                WHERE Specialty_code = var_to_loc AND Effective_date < var_to_date AND Hospital_code = var_hosp
                                GROUP BY Specialty_code) AS grouped_query
                                ON (ungrouped_query.Specialty_code = grouped_query.Specialty_code OR (ungrouped_query.Specialty_code IS NULL AND grouped_query.Specialty_code IS NULL))
                            WHERE Effective_date = max_1;

                        IF var_to_imis NOT IN ('ICU', 'CCU', 'PRI', 'PIC', 'SCB', 'NIC') THEN
                            SELECT
                                NULL
                                INTO var_to_imis;
                        END IF;
                    END;
                END IF;

                IF var_to_imis IS NULL THEN
                    SELECT
                        IMIS_code
                        INTO var_to_imis
                        FROM (SELECT
                            IMIS_code, Specialty_code, Effective_date
                            FROM Specialty) AS ungrouped_query
                        INNER JOIN (SELECT
                            Specialty_code, MAX(Effective_date) AS max_1
                            FROM Specialty
                            WHERE Specialty_code = var_to_spec AND Effective_date < var_to_date AND Hospital_code = var_hosp
                            GROUP BY Specialty_code) AS grouped_query
                            ON (ungrouped_query.Specialty_code = grouped_query.Specialty_code OR (ungrouped_query.Specialty_code IS NULL AND grouped_query.Specialty_code IS NULL))
                        WHERE Effective_date = max_1;
                END IF;

                IF var_from_imis <> var_to_imis THEN
                    BEGIN
                        SELECT
                            0, 0
                            INTO var_tx_within, var_tx_between;

                        IF var_from_imis IN ('PAE', 'PIC', 'PID') THEN
                            IF var_to_imis IN ('PAE', 'PIC', 'PID') THEN
                                SELECT
                                    1, 0
                                    INTO var_tx_within, var_tx_between;
                            ELSE
                                SELECT
                                    0, 1
                                    INTO var_tx_within, var_tx_between;
                            END IF;
                        END IF;

                        IF var_from_imis IN ('NIC', 'SCB') THEN
                            IF var_to_imis IN ('NIC', 'SCB') THEN
                                SELECT
                                    1, 0
                                    INTO var_tx_within, var_tx_between;
                            ELSE
                                SELECT
                                    0, 1
                                    INTO var_tx_within, var_tx_between;
                            END IF;
                        END IF;

                        IF var_from_imis IN ('MED', 'GER', 'CCU', 'TBC', 'MID') THEN
                            IF var_to_imis IN ('GER', 'MED', 'CCU', 'TBC', 'MID') THEN
                                SELECT
                                    1, 0
                                    INTO var_tx_within, var_tx_between;
                            ELSE
                                SELECT
                                    0, 1
                                    INTO var_tx_within, var_tx_between;
                            END IF;
                        END IF;

                        IF EXISTS (SELECT
                            *
                            FROM t$eis_table
                            WHERE eis_spec = var_from_imis) THEN
                            UPDATE t$eis_table
                            SET eis_within = eis_within + var_tx_within, eis_between = eis_between + var_tx_between
                                WHERE eis_spec = var_from_imis;
                        ELSE
                            INSERT INTO t$eis_table
                            VALUES (var_from_imis, var_tx_within, var_tx_between);
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        FETCH csr INTO var_from_ward, var_from_spec, var_from_loc, var_to_ward, var_to_spec, var_to_loc;
    END LOOP;
    CLOSE csr;
    INSERT INTO eis_subx
    SELECT
        CONCAT(SUBSTRING(CONCAT(var_hosp, REPEAT(' ', 3)), 1, 3), SUBSTRING(CONCAT(eis_spec, REPEAT(' ', 3)), 1, 3), var_month, RIGHT(CONCAT('00000000000', CAST (eis_within AS VARCHAR(11))), 11), RIGHT(CONCAT('00000000000', CAST (eis_between AS VARCHAR(11))), 11))
        FROM t$eis_table;
    -- DROP TABLE t$eis_table;
    pas_return_code := 0;
    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$eis_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$BODY$
LANGUAGE plpgsql;