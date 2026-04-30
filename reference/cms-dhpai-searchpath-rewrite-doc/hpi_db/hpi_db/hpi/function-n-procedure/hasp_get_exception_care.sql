-- DROP PROCEDURE hpi.hasp_get_exception_care(inout int4, in varchar, in timestamp, in timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_get_exception_care(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_case_no VARCHAR(12);
    var_transaction_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_transaction_type VARCHAR(3);
    var_care_category VARCHAR(1);
    var_from_ward VARCHAR(4);
    var_from_spec VARCHAR(4);
    var_from_treatment_loc VARCHAR(4);
    var_to_ward VARCHAR(4);
    var_to_spec VARCHAR(4);
    var_to_treatment_loc VARCHAR(4);
    var_eis_code VARCHAR(4);
    csr CURSOR FOR
    SELECT
        Case_no, Transaction_datetime, Transaction_type, To_ward_code, To_specialty_code, To_treatment_location, From_ward_code, From_specialty_code, From_treatment_location
        FROM Transaction_log
        WHERE Transaction_datetime >= par_input_from_date AND Transaction_datetime < par_input_to_date AND Transaction_type IN ('100', '141', '171') AND Cancel_flag IS NULL;
BEGIN
    DROP TABLE IF EXISTS t$temp_output;
    CREATE TEMPORARY TABLE t$temp_output
    (case_no VARCHAR(12),
        transaction_datetime TIMESTAMP WITHOUT TIME ZONE,
        transaction_type VARCHAR(3),
        care_category VARCHAR(1) NULL,
        from_ward VARCHAR(4) NULL,
        from_spec VARCHAR(4) NULL,
        from_treatment_loc VARCHAR(4) NULL,
        to_ward VARCHAR(4) NULL,
        to_spec VARCHAR(4) NULL,
        to_treatment_loc VARCHAR(4) NULL);

    IF par_input_to_date IS NULL THEN
        SELECT
            1 * INTERVAL '1 day' + par_input_from_date::TIMESTAMP
            INTO par_input_to_date;
    ELSE
        SELECT
            1 * INTERVAL '1 day' + par_input_to_date::TIMESTAMP
            INTO par_input_to_date;
    END IF;
    SELECT
        NULL
        INTO var_care_category;
    OPEN csr;
    FETCH csr INTO var_case_no, var_transaction_datetime, var_transaction_type, var_from_ward, var_from_spec, var_from_treatment_loc, var_to_ward, var_to_spec, var_to_treatment_loc;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        IF var_to_treatment_loc IS NOT NULL THEN
            SELECT
                IMIS_code
                INTO var_eis_code
                FROM (SELECT
                    IMIS_code, Specialty_code, Effective_date
                    FROM Specialty) AS ungrouped_query
                INNER JOIN (SELECT
                    Specialty_code, MAX(Effective_date) AS max_1
                    FROM Specialty
                    WHERE Specialty_code = var_to_treatment_loc AND Effective_date <= var_transaction_datetime
                    GROUP BY Specialty_code) AS grouped_query
                ON COALESCE(ungrouped_query.Specialty_code, '') = COALESCE(grouped_query.Specialty_code, '')
                    AND Effective_date = max_1;
        ELSE
            SELECT
                NULL
                INTO var_eis_code;
        END IF;

        IF var_eis_code NOT IN ('ICU', 'CCU', 'PIC', 'NIC', 'PIC', 'SCB', 'HDU', 'PRI') THEN
            SELECT
                NULL
                INTO var_eis_code;
        END IF;

        IF var_eis_code IS NULL THEN
            SELECT
                IMIS_code
                INTO var_eis_code
                FROM (SELECT
                    IMIS_code, Specialty_code, Effective_date
                    FROM Specialty) AS ungrouped_query
                INNER JOIN (SELECT
                    Specialty_code, MAX(Effective_date) AS max_1
                    FROM Specialty
                    WHERE Specialty_code = var_to_spec AND Effective_date <= var_transaction_datetime
                    GROUP BY Specialty_code) AS grouped_query
                ON COALESCE(ungrouped_query.Specialty_code, '') = COALESCE(grouped_query.Specialty_code, '')
                    AND Effective_date = max_1;
        END IF;
        SELECT
            Care_category
            INTO var_care_category
            FROM (SELECT
                Care_category, Ward_code, Effective_date
                FROM Ward) AS ungrouped_query
            INNER JOIN (SELECT
                Ward_code, MAX(Effective_date) AS max_1
                FROM Ward
                WHERE Ward_code = var_to_ward AND Effective_date <= var_transaction_datetime
                GROUP BY Ward_code) AS grouped_query
            ON COALESCE(ungrouped_query.Ward_code, '') = COALESCE(grouped_query.Ward_code, '')
                AND Effective_date = max_1;

        IF (var_eis_code = 'ICU' AND var_care_category <> 'U') OR (var_eis_code = 'HDU' AND var_care_category <> 'H') OR (var_eis_code = 'CCU' AND var_care_category NOT IN ('X', 'Y')) OR (var_eis_code = 'PIC' AND var_care_category <> 'X') OR (var_eis_code = 'NIC' AND var_care_category <> 'X') OR (var_eis_code = 'SCB' AND var_care_category <> 'A') OR (var_eis_code = 'NUR' AND var_care_category <> 'A') OR (var_eis_code = 'OBS' AND var_care_category IN ('I', 'R')) OR (var_eis_code = 'INF' AND var_care_category NOT IN ('I', 'R')) OR (var_eis_code = 'PSY' AND var_care_category IN ('X', 'Y')) OR (var_eis_code = 'MH' AND var_care_category IN ('X', 'Y')) OR (var_eis_code NOT IN ('PSY', 'MH') AND var_care_category = 'M') OR (var_eis_code = 'REH' AND var_care_category NOT IN ('I', 'R')) THEN
            INSERT INTO t$temp_output (case_no, transaction_datetime, transaction_type, care_category, from_ward, from_spec, from_treatment_loc, to_ward, to_spec, to_treatment_loc)
            VALUES (var_case_no, var_transaction_datetime, var_transaction_type, var_care_category, var_from_ward, var_from_spec, var_from_treatment_loc, var_to_ward, var_to_spec, var_to_treatment_loc);
        END IF;
        FETCH csr INTO var_case_no, var_transaction_datetime, var_transaction_type, var_from_ward, var_from_spec, var_from_treatment_loc, var_to_ward, var_to_spec, var_to_treatment_loc;
    END LOOP;
    CLOSE csr;
    OPEN p_refcur FOR
    SELECT
        case_no, transaction_datetime, transaction_type, care_category, from_ward, from_spec, from_treatment_loc, to_ward, to_spec, to_treatment_loc
        FROM t$temp_output
        ORDER BY case_no NULLS FIRST, transaction_datetime NULLS FIRST;
    pas_return_code := 0;
    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$temp_output;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_exception_care" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
