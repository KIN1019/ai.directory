-- DROP FUNCTION hasp_in_pat_unplan_readm(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hasp_in_pat_unplan_readm(par_hosp_code character varying, par_from_date timestamp without time zone, par_to_date timestamp without time zone)
 RETURNS TABLE(old_case_no character varying, old_adt_dt timestamp without time zone, old_spec character varying, new_case_no character varying, new_adt_dt timestamp without time zone, new_spec character varying, old_disc_dt timestamp without time zone, hkid character varying, name character varying, sex character varying, dob date, mrn character varying, age integer, old_ward character varying, new_ward character varying, age_char character varying)
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_return_code    INTEGER;
    var_new_case_no    VARCHAR(24);
    var_new_adt_dt     TIMESTAMP;
    var_hkid           VARCHAR(24);
    var_name           VARCHAR(96);
    var_dob            TIMESTAMP;
    var_sex            VARCHAR(2);
    var_mrn            VARCHAR(16);
    var_new_spec       VARCHAR(8);
    var_old_spec       VARCHAR(8);
    var_new_ward       VARCHAR(8);
    var_old_ward       VARCHAR(8);
    var_old_adt_dt     TIMESTAMP;
    var_old_disc_dt    TIMESTAMP;
    var_old_case_no    VARCHAR(24);
    var_age            INT;
    var_age_char       VARCHAR(10);
    var_max_adt_dt     TIMESTAMP;
    var_comp_from_date TIMESTAMP;
    var_comp_to_date   TIMESTAMP;
BEGIN
    -- Adjust the to_date
    par_to_date := par_to_date + INTERVAL '1 day';

    -- Create a temporary table
    DROP TABLE IF EXISTS t$tx_table;
    CREATE TEMP TABLE t$tx_table
    (
        new_case_no VARCHAR(12),
        new_adt_dt  TIMESTAMP,
        hkid        VARCHAR(12),
        name        VARCHAR(48),
        dob         DATE,
        age         INT,
        sex         VARCHAR(1),
        mrn         VARCHAR(8),
        new_spec    VARCHAR(4),
        old_spec    VARCHAR(4),
        new_ward    VARCHAR(4),
        old_ward    VARCHAR(4),
        old_adt_dt  TIMESTAMP,
        old_disc_dt TIMESTAMP,
        old_case_no VARCHAR(12),
        age_char    VARCHAR(5)
    );

    -- Cursor for fetching data
    FOR var_new_case_no, var_new_adt_dt, var_new_spec, var_new_ward, var_hkid IN
        SELECT t.case_no, c.admission_datetime, t.from_specialty_code, t.from_ward_code, c.hkid
        FROM transaction_log t
                 JOIN case_view c ON t.case_no = c.case_no
        WHERE t.transaction_datetime >= par_from_date
          AND t.transaction_datetime < par_to_date
          AND t.transaction_type = '100'
          AND t.from_ward_code <> 'AE01'
          AND t.cancel_flag IS NULL
          AND c.source_indicator = '3'
          AND t.hospital_code = par_hosp_code
          AND c.hospital_code = par_hosp_code
        LOOP
            var_comp_from_date := var_new_adt_dt::DATE - INTERVAL '28 days';
            var_comp_to_date := var_new_adt_dt;

            -- Fetch previous admission details
            SELECT INTO var_max_adt_dt, var_old_case_no, var_old_adt_dt, var_old_disc_dt, var_old_spec,
                var_old_ward, var_name, var_dob, var_sex, var_mrn c.admission_datetime,
                                                                  c.case_no,
                                                                  c.admission_datetime,
                                                                  c.discharge_datetime,
                                                                  m.specialty_code,
                                                                  m.ward_code,
                                                                  p.name,
                                                                  p.dob,
                                                                  p.sex,
                                                                  p.medical_record_number
            FROM case_view c
                     JOIN movement m ON c.case_no = m.case_no
                     JOIN pmi p ON c.hkid = p.hkid
            WHERE c.hospital_code = par_hosp_code
              AND m.hospital_code = par_hosp_code
              AND p.pmi_hospital_code = par_hosp_code
              AND c.case_type = 'I'
              AND c.discharge_datetime IS NOT NULL
              AND c.discharge_datetime >= var_comp_from_date
              AND c.discharge_datetime <= var_comp_to_date
              AND c.hkid = var_hkid
              AND m.movement_count = 1
              AND c.discharge_datetime = (SELECT MAX(cv.discharge_datetime)
                                          FROM case_view cv
                                          WHERE cv.discharge_datetime >= var_comp_from_date
                                            AND cv.discharge_datetime <= var_comp_to_date
                                            AND cv.discharge_datetime IS NOT NULL
                                            AND cv.case_type = 'I'
                                            AND cv.hkid = var_hkid
                                            AND cv.hospital_code = par_hosp_code);

            IF FOUND THEN
                var_age := COALESCE(EXTRACT(YEAR FROM AGE(var_new_adt_dt, var_dob)), 0);

                IF var_dob IS NULL THEN
                    var_age_char := '';
                ELSE
                    -- Assuming hasp_cal_age is a function that returns age as a string
                    CALL hasp_cal_age(var_return_code, var_dob, var_new_adt_dt, var_age_char);
                END IF;

                INSERT INTO t$tx_table
                VALUES (var_new_case_no, var_new_adt_dt, var_hkid, var_name, var_dob, var_age, var_sex, var_mrn,
                        var_new_spec, var_old_spec,
                        var_new_ward, var_old_ward, var_old_adt_dt, var_old_disc_dt, var_old_case_no, var_age_char);
            END IF;
        END LOOP;

    -- Return the results
    RETURN QUERY
        SELECT t.old_case_no,
               t.old_adt_dt,
               t.old_spec,
               t.new_case_no,
               t.new_adt_dt,
               t.new_spec,
               t.old_disc_dt,
               t.hkid,
               t.name,
               t.sex,
               t.dob,
               t.mrn,
               t.age,
               t.old_ward,
               t.new_ward,
               t.age_char
        FROM t$tx_table t
        ORDER BY t.new_spec NULLS FIRST , t.old_spec NULLS FIRST , t.hkid NULLS FIRST,t.new_case_no NULLS FIRST;

    DROP TABLE t$tx_table;
END;
$function$
;

;ALTER FUNCTION "hasp_in_pat_unplan_readm" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
