-- DROP FUNCTION hkpmi.hkpmi_get_death(bpchar, timestamp, timestamp, int4, int4, bpchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_death(par_hosp_code varchar, par_from_date timestamp without time zone, par_to_date timestamp without time zone, par_from_age integer, par_to_age integer, par_in_sex varchar)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_hosp VARCHAR(3);
    var_hospital VARCHAR(3);
    var_hkid VARCHAR(12);
    var_name VARCHAR(48);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_case_no VARCHAR(12);
    var_dsch_date TIMESTAMP WITHOUT TIME ZONE;
    var_ward VARCHAR(4);
    var_spec VARCHAR(4);
    var_age INTEGER;
    var_sex_flag VARCHAR(1);
    var_age_flag VARCHAR(1);
    var_sex VARCHAR(1);
    var_c1 VARCHAR(5);
    var_c2 VARCHAR(5);
    var_c3 VARCHAR(5);
    var_c4 VARCHAR(5);
    var_c5 VARCHAR(5);
    var_c6 VARCHAR(5);
    var_chi_name VARCHAR(12);
    var_chi_char1 VARCHAR(2);
    var_chi_char2 VARCHAR(2);
    var_chi_char3 VARCHAR(2);
    var_chi_char4 VARCHAR(2);
    var_chi_char5 VARCHAR(2);
    var_chi_char6 VARCHAR(2);
    var_dob_flag VARCHAR(1);
    var_death_dtm TIMESTAMP WITHOUT TIME ZONE;
/* 2006-09-01 Added by HK Fong SMR20015696 - Start */
    var_schi_name VARCHAR(24);
    var_is_schi_name VARCHAR(2);
    var_phonetic VARCHAR(48);
    pas_return_code INTEGER;
    csr CURSOR FOR
    SELECT
        d.hospital_code, hkid, patient_name, sex, dob, d.case_no, d.discharge_dtm, last_ward_code, last_specialty_code, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, exact_dob_flag, p.death_date
        FROM death_transaction AS d, patient AS p, pmi_case AS c
        /* --			where p.death_date >= @from_date */
        /* --			and p.death_date < @to_date */
        WHERE d.discharge_dtm >= par_from_date AND d.discharge_dtm < par_to_date AND
        /* --			and d.hospital_code like @hosp */
        d.patient_key = p.patient_key AND (p.sex LIKE var_sex OR p.sex = 'U') AND d.hospital_code = c.hospital_code AND d.case_no = c.case_no;
    sql$rowcount BIGINT;
BEGIN
    SET search_path TO hkpmi, public;
	IF par_hosp_code = 'ALL' THEN
        SELECT
            '%'
            INTO var_hosp;
    ELSE
        SELECT
            par_hosp_code
            INTO var_hosp;
    END IF;

    IF var_sex IS NULL THEN
        SELECT
            '%'
            INTO var_sex;
    END IF;
    SELECT
        1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
        INTO par_to_date;
    DROP TABLE IF EXISTS t$temp_table;
    CREATE TEMPORARY TABLE t$temp_table
    ("hosp" VARCHAR(3),
        "hkid" VARCHAR(12),
        "name" VARCHAR(48),
        "sex" VARCHAR(1) NULL,
        "dob" TIMESTAMP WITHOUT TIME ZONE NULL,
        "case_no" VARCHAR(12),
        "dsch_date" TIMESTAMP WITHOUT TIME ZONE,
        "ward" VARCHAR(4),
        "spec" VARCHAR(4),
        "chi_name" VARCHAR(12),
        "dob_flag" VARCHAR(1),
        "death_dtm" TIMESTAMP WITHOUT TIME ZONE NULL,
        /* 2006-09-01 Added by HK Fong SMR20015696 - Start */
        "schi_name" VARCHAR(12) NULL);
    /* 2006-09-01 Added by HK Fong SMR20015696 - end */
    OPEN csr;
    FETCH csr INTO var_hospital, var_hkid, var_name, var_sex, var_dob, var_case_no, var_dsch_date, var_ward, var_spec, var_c1, var_c2, var_c3, var_c4, var_c5, var_c6, var_dob_flag, var_death_dtm;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        IF var_dob IS NULL THEN
            SELECT
                NULL
                INTO var_age;
        ELSE
            BEGIN
                SELECT
                    DATE_PART('year', var_dsch_date::TIMESTAMP) - DATE_PART('year', var_dob::TIMESTAMP)
                    INTO var_age;

                IF var_age * INTERVAL '1 year' + var_dob::TIMESTAMP > var_dsch_date THEN
                    SELECT
                        var_age - 1
                        INTO var_age;
                END IF;
            END;
        END IF;

        IF par_in_sex IS NULL OR (par_in_sex IS NOT NULL AND (var_sex IS NULL OR var_sex = par_in_sex)) THEN
            SELECT
                'Y'
                INTO var_sex_flag;
        ELSE
            SELECT
                'N'
                INTO var_sex_flag;
        END IF;

        IF (par_from_age IS NOT NULL AND par_to_age IS NOT NULL AND ((var_age >= par_from_age AND var_age <= par_to_age) OR var_age IS NULL)) OR (par_from_age IS NULL AND par_to_age IS NULL) THEN
            SELECT
                'Y'
                INTO var_age_flag;
        ELSE
            SELECT
                'N'
                INTO var_age_flag;
        END IF;

        IF (var_sex_flag = 'Y' OR par_in_sex IS NULL) AND (var_age_flag = 'Y' OR (par_from_age IS NULL AND par_to_age IS NULL)) AND var_hospital LIKE var_hosp THEN
            BEGIN
                SELECT
                    NULL
                    INTO var_chi_name;
                SELECT
                    unicode_char
                    INTO var_chi_char1
                    FROM ccc_unicode
                    WHERE ccc_head = SUBSTRING(var_c1, 1, 4) AND ccc_tail = SUBSTRING(var_c1, 5, 1);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount <> 1 THEN
                    SELECT
                        REPEAT(' ', 2)
                        INTO var_chi_char1;
                END IF;
                SELECT
                    unicode_char
                    INTO var_chi_char2
                    FROM ccc_unicode
                    WHERE ccc_head = SUBSTRING(var_c2, 1, 4) AND ccc_tail = SUBSTRING(var_c2, 5, 1);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount <> 1 THEN
                    SELECT
                        REPEAT(' ', 2)
                        INTO var_chi_char2;
                END IF;
                SELECT
                    unicode_char
                    INTO var_chi_char3
                    FROM ccc_unicode
                    WHERE ccc_head = SUBSTRING(var_c3, 1, 4) AND ccc_tail = SUBSTRING(var_c3, 5, 1);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount <> 1 THEN
                    SELECT
                        REPEAT(' ', 2)
                        INTO var_chi_char3;
                END IF;
                SELECT
                    unicode_char
                    INTO var_chi_char4
                    FROM ccc_unicode
                    WHERE ccc_head = SUBSTRING(var_c4, 1, 4) AND ccc_tail = SUBSTRING(var_c4, 5, 1);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount <> 1 THEN
                    SELECT
                        REPEAT(' ', 2)
                        INTO var_chi_char4;
                END IF;
                SELECT
                    unicode_char
                    INTO var_chi_char5
                    FROM ccc_unicode
                    WHERE ccc_head = SUBSTRING(var_c5, 1, 4) AND ccc_tail = SUBSTRING(var_c5, 5, 1);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount <> 1 THEN
                    SELECT
                        REPEAT(' ', 2)
                        INTO var_chi_char5;
                END IF;
                SELECT
                    unicode_char
                    INTO var_chi_char6
                    FROM ccc_unicode
                    WHERE ccc_head = SUBSTRING(var_c6, 1, 4) AND ccc_tail = SUBSTRING(var_c6, 5, 1);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount <> 1 THEN
                    SELECT
                        REPEAT(' ', 2)
                        INTO var_chi_char6;
                END IF;
                SELECT
                    CONCAT(var_chi_char1, var_chi_char2, var_chi_char3, var_chi_char4, var_chi_char5, var_chi_char6)
                    INTO var_chi_name;
                /* 2006-09-01 Added by HK Fong SMR20015696 - Start */
                /*
                insert into #temp_table values
                (@hospital, @hkid, @name, @sex, @dob, @case_no, @dsch_date,
                @ward, @spec, @chi_name, @dob_flag, @death_dtm)
                */
                IF COALESCE(var_chi_name, '') <> '' THEN
                    BEGIN
                        CALL hkpmi_check_schi_name(pas_return_code => pas_return_code, par_ccc1 => var_c1, par_ccc2 => var_c2, par_ccc3 => var_c3, par_ccc4 => var_c4, par_ccc5 => var_c5, par_ccc6 => var_c6, par_is_schi_name => var_is_schi_name);

                        IF var_is_schi_name = 'Y' THEN
                            SELECT
                                var_chi_name
                                INTO var_schi_name;
                        ELSE
                            SELECT
                                ' '
                                INTO var_schi_name;
                        END IF;
                    END;
                ELSE
                    SELECT
                        ' '
                        INTO var_schi_name;
                END IF;
                INSERT INTO t$temp_table
                VALUES (var_hospital, var_hkid, var_name, var_sex, var_dob, var_case_no, var_dsch_date, var_ward, var_spec, var_chi_name, var_dob_flag, var_death_dtm, var_schi_name);
                /* 2006-09-01 Added by HK Fong SMR20015696 - End */
            END;
        END IF;
        FETCH csr INTO var_hospital, var_hkid, var_name, var_sex, var_dob, var_case_no, var_dsch_date, var_ward, var_spec, var_c1, var_c2, var_c3, var_c4, var_c5, var_c6, var_dob_flag, var_death_dtm;
    END LOOP;
    CLOSE csr;
    OPEN p_refcur FOR
    SELECT
        t$temp_table.hosp, t$temp_table.hkid, t$temp_table.name, t$temp_table.sex, t$temp_table.dob, t$temp_table.case_no, t$temp_table.dsch_date, t$temp_table.ward, t$temp_table.spec, t$temp_table.chi_name, t$temp_table.dob_flag, t$temp_table.death_dtm, t$temp_table.schi_name
        FROM t$temp_table
        ORDER BY hosp NULLS FIRST, death_dtm NULLS FIRST;
	return next p_refcur;
    /*
    
    DROP TABLE IF EXISTS t$temp_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;

ALTER FUNCTION "hkpmi_get_death" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
