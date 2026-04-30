-- DROP FUNCTION hasp_mr24uadm(varchar, timestamp, timestamp, varchar);

CREATE OR REPLACE FUNCTION hasp_mr24uadm(par_hosp_code character varying, par_input_from_datetime timestamp without time zone, par_input_to_datetime timestamp without time zone, par_input_spec_code character varying)
 RETURNS TABLE(mr24uadm_spec character varying, mr24uadm_desc character varying, mr24_ttl smallint, uadm_ttl smallint)
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_spec       VARCHAR(4);
    var_case_no    VARCHAR(12);
    var_trans_date TIMESTAMP;
    var_hkid       VARCHAR(12);
    var_adm_code   VARCHAR(1);
    var_hour_diff  INT;
BEGIN
    -- Create a temporary table to store results
    Drop TABLE IF EXISTS t$temp_mr24uadm_table;
    CREATE TEMP TABLE t$temp_mr24uadm_table
    (
        mr24uadm_spec VARCHAR(4) NOT NULL,
        mr24uadm_desc VARCHAR(30),
        mr24_ttl      SMALLINT DEFAULT 0,
        uadm_ttl      SMALLINT DEFAULT 0
    );

    -- Extract mortality < 24 hours
    FOR var_spec, var_case_no IN
        SELECT tl.from_specialty_code, tl.case_no
        FROM transaction_log tl
        WHERE tl.transaction_datetime >= par_input_from_datetime
          AND tl.transaction_datetime < par_input_to_datetime + INTERVAL '1 day'
          AND tl.transaction_type = '131'
          AND tl.cancel_flag IS NULL
          AND tl.from_specialty_code LIKE par_input_spec_code
          AND tl.from_ward_code <> 'AE01'
          AND tl.hospital_code = par_hosp_code
        LOOP
            IF NOT EXISTS (SELECT 1 FROM t$temp_mr24uadm_table t WHERE t.mr24uadm_spec = var_spec) THEN
                INSERT INTO t$temp_mr24uadm_table (mr24uadm_spec) VALUES (var_spec);
            END IF;

            SELECT EXTRACT(EPOCH FROM (cv.Discharge_datetime - cv.Admission_datetime)) / 3600
            INTO var_hour_diff
            FROM case_view cv
            WHERE cv.case_no = var_case_no
              AND cv.hospital_code = par_hosp_code;

            IF var_hour_diff < 24 THEN
                UPDATE t$temp_mr24uadm_table t
                SET mr24_ttl = t.mr24_ttl + 1
                WHERE t.mr24uadm_spec = var_spec;
            END IF;
        END LOOP;

    -- Extract unplanned readmissions
    FOR var_spec, var_case_no, var_trans_date IN
        SELECT tl.from_specialty_code, tl.case_no, tl.transaction_datetime
        FROM transaction_log tl
        WHERE tl.transaction_datetime >= par_input_from_datetime
          AND tl.transaction_datetime < par_input_to_datetime + INTERVAL '1 day'
          AND tl.transaction_type = '100'
          AND tl.cancel_flag IS NULL
          AND tl.from_specialty_code LIKE par_input_spec_code
          AND tl.from_ward_code <> 'AE01'
          AND tl.hospital_code = par_hosp_code
        LOOP
            SELECT cv.hkid, cv.source_indicator
            INTO var_hkid, var_adm_code
            FROM case_view cv
            WHERE cv.case_no = var_case_no
              AND cv.hospital_code = par_hosp_code;

            IF var_adm_code = '3' THEN
                IF NOT EXISTS (SELECT 1 FROM t$temp_mr24uadm_table t WHERE t.mr24uadm_spec = var_spec) THEN
                    INSERT INTO t$temp_mr24uadm_table (mr24uadm_spec) VALUES (var_spec);
                END IF;

                IF EXISTS (SELECT 1
                           FROM case_view cv
                           WHERE cv.hkid = var_hkid
                             AND cv.discharge_datetime < var_trans_date
                             AND var_trans_date - cv.discharge_datetime <= INTERVAL '28 days'
                             AND cv.case_no <> var_case_no
                             AND cv.case_type = 'I'
                             AND cv.hospital_code = par_hosp_code) THEN
                    UPDATE t$temp_mr24uadm_table t
                    SET uadm_ttl = t.uadm_ttl + 1
                    WHERE t.mr24uadm_spec = var_spec;
                END IF;
            END IF;
        END LOOP;

    -- Update descriptions
    DROP TABLE IF EXISTS t$temp_spec_desc;
    CREATE TEMP TABLE t$temp_spec_desc AS
    SELECT DISTINCT ON (Specialty_code) Specialty_code, Description
    FROM (SELECT Specialty_code,
                 Description,
                 Effective_date,
                 ROW_NUMBER() OVER (PARTITION BY Specialty_code ORDER BY Effective_date DESC) AS rn
          FROM Specialty
          WHERE Effective_date <= par_input_to_datetime
            AND Hospital_code = par_hosp_code) subquery
    WHERE rn = 1;

    UPDATE t$temp_mr24uadm_table t
    SET mr24uadm_desc = tsd.description
    FROM t$temp_spec_desc tsd
    WHERE t.mr24uadm_spec = tsd.specialty_code;

    -- Return the results
    RETURN QUERY
        SELECT t.mr24uadm_spec, t.mr24uadm_desc, t.mr24_ttl, t.uadm_ttl
        FROM t$temp_mr24uadm_table t
        WHERE t.mr24_ttl > 0
           OR t.uadm_ttl > 0
        ORDER BY t.mr24uadm_spec;
    
    Drop TABLE IF EXISTS t$temp_spec_desc;
    Drop TABLE IF EXISTS t$temp_mr24uadm_table;

END;
$function$
;

;ALTER FUNCTION "hasp_mr24uadm" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
