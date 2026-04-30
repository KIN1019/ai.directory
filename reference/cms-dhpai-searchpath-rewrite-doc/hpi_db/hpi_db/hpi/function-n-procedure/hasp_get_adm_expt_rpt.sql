-- DROP FUNCTION hpi.hasp_get_adm_expt_rpt(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hpi.hasp_get_adm_expt_rpt(par_hosp_code character varying, par_input_from_date timestamp without time zone, par_input_to_date timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/* 2010-01-22 20017749 fx use d, m, y for age indicator */
DECLARE
    var_spec_code VARCHAR(4);
    var_case_no VARCHAR(12);
    var_hkid VARCHAR(12);
    var_sex VARCHAR(1);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_age_char VARCHAR(5);
    var_s_from_age INTEGER;
    var_s_to_age INTEGER;
    var_s_from_unit VARCHAR(2);
    var_s_to_unit VARCHAR(2);
    var_s_sex VARCHAR(1);
    var_s_spec VARCHAR(4);
    var_age_int INTEGER;
    p_refcur refcursor;
    select_cur CURSOR FOR
    SELECT
        specialty_code, from_age, from_age_unit, to_age, to_age_unit, sex
        FROM exception_rpt_table
        WHERE hospital_code = par_hosp_code;
    adm_cur CURSOR FOR
    SELECT
        From_specialty_code, c.Case_no, c.Admission_datetime, p.HKID, p.DOB, p.Sex
        FROM Transaction_log AS t, PMI AS p, Case_view AS c
        WHERE t.Transaction_datetime >= par_input_from_date AND t.Transaction_datetime < par_input_to_date AND t.Transaction_type = '100' AND t.Cancel_flag is null AND p.HKID = c.HKID AND c.Case_no = t.Case_no AND t.Hospital_code = par_hosp_code AND c.Hospital_code = par_hosp_code;
    var_return_code int;
BEGIN
    SELECT
        1 * INTERVAL '1 day' + par_input_to_date::TIMESTAMP
        INTO par_input_to_date;
    DROP TABLE IF EXISTS t$tmp_adm_tbl;
    CREATE TEMPORARY TABLE t$tmp_adm_tbl
    (spec_code VARCHAR(4) NOT NULL,
        case_no VARCHAR(12) NOT NULL,
        adm_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
        hkid VARCHAR(12) NOT NULL,
        dob TIMESTAMP WITHOUT TIME ZONE NULL,
        age_char VARCHAR(05) NULL,
        sex VARCHAR(1) NULL);
    OPEN select_cur;
    FETCH select_cur INTO var_s_spec, var_s_from_age, var_s_from_unit, var_s_to_age, var_s_to_unit, var_s_sex;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            NULL
            INTO var_age_char;
        /* formating selection criteria */
        IF var_s_spec is null OR var_s_spec = 'ALL' THEN
            SELECT
                '%'
                INTO var_s_spec;
        END IF;

        IF var_s_sex is null OR var_s_sex = 'A' THEN
            SELECT
                '%'
                INTO var_s_sex;
        END IF;

        IF var_s_from_age is null OR var_s_from_age = 0 THEN
            BEGIN
                SELECT
                    0
                    INTO var_s_from_age;
                SELECT
                    'da'
                    INTO var_s_from_unit;
            END;
        END IF;

        IF var_s_to_age is null THEN
            BEGIN
                SELECT
                    0
                    INTO var_s_to_age;
            END;
        END IF;
        OPEN adm_cur;
        FETCH adm_cur INTO var_spec_code, var_case_no, var_adm_dtm, var_hkid, var_dob, var_sex;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            <<process_next>>
            BEGIN
                <<insert_tbl>>
                BEGIN
                    IF var_sex NOT LIKE var_s_sex THEN
                        EXIT process_next;
                    END IF;

                    IF var_spec_code NOT LIKE var_s_spec THEN
                        EXIT process_next;
                    END IF;

                    IF var_dob is not null THEN
                        CALL hasp_cal_age(var_return_code, var_dob, var_adm_dtm, var_age_char);
                    ELSE
                        SELECT
                            NULL
                            INTO var_age_char;
                    END IF;
                    /* WITH age range specified */
                    IF var_s_from_age <> 0 OR var_s_to_age <> 0 THEN
                        BEGIN
                            IF var_dob is null OR var_age_char is null THEN
                                EXIT process_next;
                            END IF;
                            SELECT
                                CAST (LTRIM(RTRIM(SUBSTRING(var_age_char, 1, 3))) AS INTEGER)
                                INTO var_age_int;
                                -- raise notice 'var_age_char %, var_age_int %, var_s_from_age %, var_s_to_age %, var_dob %, var_s_from_unit %, var_s_to_unit %',var_age_char, var_age_int, var_s_from_age, var_s_to_age, var_dob, var_s_from_unit, var_s_to_unit;
                            /* filter admission smaller than from age lower range */
                            IF var_s_from_unit = 'da' THEN
                                BEGIN
                                    /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                                    /* if (@age_char like '%da') and (@age_int < @s_from_age) */
                                    IF (var_age_char LIKE '%d') AND (var_age_int < var_s_from_age) THEN
                                        /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                                        EXIT process_next;
                                    END IF;
                                END;
                            ELSE
                                IF var_s_from_unit = 'mo' THEN
                                    BEGIN
                                        /* --if datediff(mm,@dob,@adm_dtm) < @s_from_age */
                                        /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                                        /* if @age_char like '%da' */
                                        IF var_age_char LIKE '%d' THEN
                                            /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                                            EXIT process_next;
                                        END IF;
                                        /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                                        /* if (@age_char like '%mo') and (@age_int < @s_from_age) */
                                        IF (var_age_char LIKE '%m') AND (var_age_int < var_s_from_age) THEN
                                            /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                                            EXIT process_next;
                                        END IF;
                                    END;
                                ELSE
                                    IF var_s_from_unit = 'yr' THEN
                                        BEGIN
                                            /* --if datediff(yy,@dob,@adm_dtm) < @s_from_age */
                                            /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                                            /* if (@age_char like '%da') or (@age_char like '%mo') */
                                            IF (var_age_char LIKE '%d') OR (var_age_char LIKE '%m') THEN
                                                /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                                                EXIT process_next;
                                            END IF;
                                            /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                                            /* if (@age_char like '%yr') and  (@age_int < @s_from_age) */
                                            IF (var_age_char LIKE '%y') AND (var_age_int < var_s_from_age) THEN
                                                /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                                                EXIT process_next;
                                            END IF;
                                        END;
                                    ELSE
                                        EXIT process_next;
                                    END IF;
                                END IF;
                            END IF;
                            /* filter admission greater than from age lower range */
                            /* handle with lower range only */
                            IF (var_s_from_age <> 0) AND (var_s_to_age = 0) THEN
                                EXIT insert_tbl;
                            END IF;

                            IF var_s_to_unit = 'da' THEN
                                BEGIN
                                    /* --if datediff(dd,@dob,@adm_dtm) > @s_to_age */
                                    /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                                    /* if (@age_char like '%yr') or (@age_char like '%mo') */
                                    IF (var_age_char LIKE '%y') OR (var_age_char LIKE '%m') then
                                    -- raise notice 'exit bye';
                                        /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                                        EXIT process_next;
                                    END IF;
                                    /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                                    /* if (@age_char like '%da') and (@age_int > @s_to_age) */
                                    IF (var_age_char LIKE '%d') AND (var_age_int > var_s_to_age) THEN
                                        /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                                        EXIT process_next;
                                    END IF;
                                END;
                            ELSE
                                IF var_s_to_unit = 'mo' THEN
                                    BEGIN
                                        /* --if datediff(mm,@dob,@adm_dtm) > @s_to_age */
                                        /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                                        /* if @age_char like '%yr' */
                                        IF var_age_char LIKE '%y' THEN
                                            /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                                            EXIT process_next;
                                        END IF;
                                        /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                                        /* if (@age_char like '%mo') and (@age_int > @s_to_age) */
                                        IF (var_age_char LIKE '%m') AND (var_age_int > var_s_to_age) THEN
                                            /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                                            EXIT process_next;
                                        END IF;
                                    END;
                                ELSE
                                    IF var_s_to_unit = 'yr' THEN
                                        BEGIN
                                            /* --if datediff(yy,@dob,@adm_dtm) > @s_to_age */
                                            /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                                            /* if (@age_char like '%yr') and (@age_int > @s_to_age) */
                                            IF (var_age_char LIKE '%y') AND (var_age_int > var_s_to_age) THEN
                                                /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                                                EXIT process_next;
                                            END IF;
                                        END;
                                    ELSE
                                        EXIT process_next;
                                    END IF;
                                END IF;
                            END IF;
                        END;
                    END IF;
                END;

                IF NOT EXISTS (SELECT
                    *
                    FROM t$tmp_adm_tbl
                    WHERE hkid = var_hkid AND case_no = var_case_no) THEN
                    BEGIN
                        /*
                        if @dob is not null
                           exec hasp_cal_age @dob,@adm_dtm,@age_char out
                        else
                           select @age_char is null
                        */
                        INSERT INTO t$tmp_adm_tbl
                        VALUES (var_spec_code, var_case_no, var_adm_dtm, var_hkid, var_dob, var_age_char, var_sex);
                    END;
                END IF;
            END;
            FETCH adm_cur INTO var_spec_code, var_case_no, var_adm_dtm, var_hkid, var_dob, var_sex;
        END LOOP;
        CLOSE adm_cur;
        FETCH select_cur INTO var_s_spec, var_s_from_age, var_s_from_unit, var_s_to_age, var_s_to_unit, var_s_sex;
    END LOOP;
    OPEN p_refcur FOR
    SELECT
        spec_code, hkid, sex, age_char, case_no, adm_dtm
        FROM t$tmp_adm_tbl
        ORDER BY spec_code NULLS FIRST;
    return next p_refcur;
    CLOSE select_cur;
END;
$function$
;

;ALTER FUNCTION "hasp_get_adm_expt_rpt" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
