CREATE OR REPLACE FUNCTION hasp_get_patient_by_sex(par_hosp_code VARCHAR, par_ward_code VARCHAR, par_spec_code VARCHAR)
 RETURNS SETOF refcursor
   LANGUAGE plpgsql
 AS $function$
DECLARE
    var_ward VARCHAR(4);
    var_spec VARCHAR(4);
    var_sex VARCHAR(1);
    var_count INTEGER;
    p_refcur refcursor;
    csr CURSOR FOR
    SELECT
        Ward_code, Specialty_code, COUNT(*)
        FROM Ward_list AS w, Case_view AS c, PMI_wo_MRN AS p
        WHERE Ward_code LIKE par_ward_code AND Specialty_code LIKE par_spec_code AND Ward_code <> 'AE01' AND Specialty_code <> 'A&E' AND w.Hospital_code = par_hosp_code AND w.Case_no = c.Case_no AND c.Hospital_code = par_hosp_code AND c.HKID = p.HKID AND Sex = var_sex
        GROUP BY Ward_code, Specialty_code;
BEGIN
    DROP TABLE IF EXISTS t$temp_sex;
    CREATE TEMPORARY TABLE t$temp_sex
    (ward_code VARCHAR(4),
        spec_code VARCHAR(4),
        male INTEGER DEFAULT 0 NULL,
        female INTEGER DEFAULT 0 NULL,
        unknown INTEGER DEFAULT 0 NULL);
    CREATE UNIQUE INDEX temp_sex_index ON t$temp_sex
        (ward_code, spec_code);

    IF par_ward_code IS NULL THEN
        SELECT
            '%'
            INTO par_ward_code;
    END IF;

    IF par_spec_code IS NULL THEN
        SELECT
            '%'
            INTO par_spec_code;
    END IF;
    SELECT
        'M'
        INTO var_sex;
    OPEN csr;
    FETCH csr INTO var_ward, var_spec, var_count;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        IF EXISTS (SELECT
            *
            FROM t$temp_sex
            WHERE ward_code = var_ward AND spec_code = var_spec) THEN
            UPDATE t$temp_sex
            SET male = male + var_count
                WHERE ward_code = var_ward AND spec_code = var_spec;
        ELSE
            INSERT INTO t$temp_sex (ward_code, spec_code, male)
            VALUES (var_ward, var_spec, var_count);
        END IF;
        FETCH csr INTO var_ward, var_spec, var_count;
    END LOOP;
    CLOSE csr;
    SELECT
        'F'
        INTO var_sex;
    OPEN csr;
    FETCH csr INTO var_ward, var_spec, var_count;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        IF EXISTS (SELECT
            *
            FROM t$temp_sex
            WHERE ward_code = var_ward AND spec_code = var_spec) THEN
            UPDATE t$temp_sex
            SET female = female + var_count
                WHERE ward_code = var_ward AND spec_code = var_spec;
        ELSE
            INSERT INTO t$temp_sex (ward_code, spec_code, female)
            VALUES (var_ward, var_spec, var_count);
        END IF;
        FETCH csr INTO var_ward, var_spec, var_count;
    END LOOP;
    CLOSE csr;
    SELECT
        'U'
        INTO var_sex;
    OPEN csr;
    FETCH csr INTO var_ward, var_spec, var_count;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        IF EXISTS (SELECT
            *
            FROM t$temp_sex
            WHERE ward_code = var_ward AND spec_code = var_spec) THEN
            UPDATE t$temp_sex
            SET unknown = unknown + var_count
                WHERE ward_code = var_ward AND spec_code = var_spec;
        ELSE
            INSERT INTO t$temp_sex (ward_code, spec_code, unknown)
            VALUES (var_ward, var_spec, var_count);
        END IF;
        FETCH csr INTO var_ward, var_spec, var_count;
    END LOOP;
    CLOSE csr;
    OPEN p_refcur FOR
    SELECT
        t$temp_sex.ward_code, t$temp_sex.spec_code, t$temp_sex.male, t$temp_sex.female, t$temp_sex.unknown
        FROM t$temp_sex order by t$temp_sex.ward_code, t$temp_sex.spec_code;
    
    return next p_refcur;
    /*
    
    DROP TABLE IF EXISTS t$temp_sex;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;

;ALTER FUNCTION "hasp_get_patient_by_sex" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
