CREATE OR REPLACE function hasp_adm_dis_death(IN par_hosp_code CHAR, IN par_from_datetime TIMESTAMP WITHOUT TIME ZONE, IN par_to_datetime TIMESTAMP WITHOUT TIME ZONE)
RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_age_char VARCHAR(5);
    cura CURSOR FOR
    SELECT
        Case_no, Transaction_type, From_specialty_code
        FROM Transaction_log
        WHERE Transaction_datetime >= par_from_datetime AND Transaction_datetime < par_to_datetime AND (Transaction_type = '100' OR Transaction_type LIKE '13%') AND Cancel_flag is NULL AND Hospital_code = par_hosp_code;
    var_case_no VARCHAR(12);
    var_transaction_type VARCHAR(3);
    var_specialty_code VARCHAR(4);
    var_sex VARCHAR(1);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_age INTEGER;
    var_admission_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_discharge_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_type VARCHAR(1);
    var_age1 INTEGER;
    var_age2 INTEGER;
    var_age3 INTEGER;
    var_age4 INTEGER;
    var_age5 INTEGER;
    var_age6 INTEGER;
    var_age7 INTEGER;
    var_age8 INTEGER;
    var_age9 INTEGER;
    var_age10 INTEGER;
    var_age11 INTEGER;
    var_age12 INTEGER;
    var_age13 INTEGER;
    var_age14 INTEGER;
    var_age15 INTEGER;
    var_age16 INTEGER;
    var_age17 INTEGER;
    var_age18 INTEGER;
    var_age19 INTEGER;
    var_rowcount INTEGER;
    var_return_code int;
	p_refcur refcursor;
BEGIN
    /* *************************************** */
    /* Modified by Winnie on 06 May 1997 */
    /* *************************************** */
    /* select @to_datetime = convert(char(8),@to_datetime,112) + ' 23:59' */
    SELECT
        1 * INTERVAL '1 day' + par_to_datetime::TIMESTAMP
        INTO par_to_datetime;
    /* -- Add Hospital code for HPI by ML on 23.07.1999 */
	DROP TABLE IF EXISTS t$adm_dis_death;
    CREATE TEMPORARY TABLE t$adm_dis_death
    (Record_type VARCHAR(1) NOT NULL,
        Specialty VARCHAR(4) NOT NULL,
        Type VARCHAR(1) NOT NULL,
        Sex VARCHAR(1) NOT NULL,
        age1 INTEGER DEFAULT 0 NULL,
        age2 INTEGER DEFAULT 0 NULL,
        age3 INTEGER DEFAULT 0 NULL,
        age4 INTEGER DEFAULT 0 NULL,
        age5 INTEGER DEFAULT 0 NULL,
        age6 INTEGER DEFAULT 0 NULL,
        age7 INTEGER DEFAULT 0 NULL,
        age8 INTEGER DEFAULT 0 NULL,
        age9 INTEGER DEFAULT 0 NULL,
        age10 INTEGER DEFAULT 0 NULL,
        age11 INTEGER DEFAULT 0 NULL,
        age12 INTEGER DEFAULT 0 NULL,
        age13 INTEGER DEFAULT 0 NULL,
        age14 INTEGER DEFAULT 0 NULL,
        age15 INTEGER DEFAULT 0 NULL,
        age16 INTEGER DEFAULT 0 NULL,
        age17 INTEGER DEFAULT 0 NULL,
        age18 INTEGER DEFAULT 0 NULL,
        age19 INTEGER DEFAULT 0 NULL,
        total INTEGER DEFAULT 0 NULL);
    CREATE INDEX IX1Eadm_dis_death ON t$adm_dis_death
        (Specialty, Type, Sex);
    OPEN cura;
    /*
    [3017 - Severity CRITICAL - PostgreSQL doesn't support the SET NOCOUNT. If need try another way to send message back to the client application.]
    set nocount on
    */
    FETCH cura INTO var_case_no, var_transaction_type, var_specialty_code;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            0
            INTO var_age1;
        SELECT
            0
            INTO var_age2;
        SELECT
            0
            INTO var_age3;
        SELECT
            0
            INTO var_age4;
        SELECT
            0
            INTO var_age5;
        SELECT
            0
            INTO var_age6;
        SELECT
            0
            INTO var_age7;
        SELECT
            0
            INTO var_age8;
        SELECT
            0
            INTO var_age9;
        SELECT
            0
            INTO var_age10;
        SELECT
            0
            INTO var_age11;
        SELECT
            0
            INTO var_age12;
        SELECT
            0
            INTO var_age13;
        SELECT
            0
            INTO var_age14;
        SELECT
            0
            INTO var_age15;
        SELECT
            0
            INTO var_age16;
        SELECT
            0
            INTO var_age17;
        SELECT
            0
            INTO var_age18;
        SELECT
            0
            INTO var_age19;
        SELECT
            NULL
            INTO var_age_char;
        SELECT
            NULL
            INTO var_age;
        /* -- modified for HPI by ML on 23.07.1999 */
        SELECT
            c.Admission_datetime, c.Discharge_datetime, p.DOB, p.Sex
            INTO var_admission_datetime, var_discharge_datetime, var_dob, var_sex
            /* --from PMI p, Case_view c */
            FROM PMI_wo_MRN AS p, Case_view AS c
            WHERE c.Case_no = var_case_no AND c.HKID = p.HKID AND c.Hospital_code = par_hosp_code;
        /* ************************************** */
        /* Modified by winnie on 06 May 1997 */
        /* @type = A ---- Admission */
        /* E ---- Death */
        /* D ---- Discharge */
        
        /* ************************************** */
        IF var_transaction_type = '100' THEN
            SELECT
                'A'
                INTO var_type;
        ELSE
            BEGIN
                IF var_transaction_type = '131' THEN
                    SELECT
                        'E'
                        INTO var_type;
                ELSE
                    SELECT
                        'D'
                        INTO var_type;
                END IF;
            END;
        END IF;

        IF var_dob is not NULL THEN
            BEGIN
                IF var_transaction_type = '100' THEN
                    BEGIN
                        /* select @type = 'A' */
                        /* *********************************** */
                        /* Modified by winnie on 06 May 97 */
                        /* for cal age */
                        /* *********************************** */
                        /* select @age=datediff(yy,@dob,@admission_datetime) */
                        CALL hasp_cal_age(var_return_code,var_dob, var_admission_datetime, var_age_char);

                        IF RIGHT(var_age_char, 2) = 'm' OR RIGHT(var_age_char, 2) = 'd' THEN
                            SELECT
                                0
                                INTO var_age;
                        ELSE
                            SELECT
                                CAST (SUBSTRING(var_age_char, 1, 3) AS INTEGER)
                                INTO var_age;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        /* select @age=datediff(yy,@dob,@discharge_datetime) */
                        CALL hasp_cal_age(var_return_code,var_dob, var_discharge_datetime, var_age_char);

                        IF RIGHT(var_age_char, 2) = 'm' OR RIGHT(var_age_char, 2) = 'd' THEN
                            SELECT
                                0
                                INTO var_age;
                        ELSE
                            SELECT
                                CAST (SUBSTRING(var_age_char, 1, 3) AS INTEGER)
                                INTO var_age;
                        END IF;
                        /*
                        if @transaction_type = '131'
                          begin
                        	  select @type = 'E'
                          end
                          else
                          begin
                        	  select @type = 'D'
                          end
                        */
                    END;
                END IF;

                IF var_age >= 0 AND var_age <= 4 THEN
                    SELECT
                        1
                        INTO var_age1;
                END IF;

                IF var_age >= 5 AND var_age <= 9 THEN
                    SELECT
                        1
                        INTO var_age2;
                END IF;

                IF var_age >= 10 AND var_age <= 14 THEN
                    SELECT
                        1
                        INTO var_age3;
                END IF;

                IF var_age >= 15 AND var_age <= 19 THEN
                    SELECT
                        1
                        INTO var_age4;
                END IF;

                IF var_age >= 20 AND var_age <= 24 THEN
                    SELECT
                        1
                        INTO var_age5;
                END IF;

                IF var_age >= 25 AND var_age <= 29 THEN
                    SELECT
                        1
                        INTO var_age6;
                END IF;

                IF var_age >= 30 AND var_age <= 34 THEN
                    SELECT
                        1
                        INTO var_age7;
                END IF;

                IF var_age >= 35 AND var_age <= 39 THEN
                    SELECT
                        1
                        INTO var_age8;
                END IF;

                IF var_age >= 40 AND var_age <= 44 THEN
                    SELECT
                        1
                        INTO var_age9;
                END IF;

                IF var_age >= 45 AND var_age <= 49 THEN
                    SELECT
                        1
                        INTO var_age10;
                END IF;

                IF var_age >= 50 AND var_age <= 54 THEN
                    SELECT
                        1
                        INTO var_age11;
                END IF;

                IF var_age >= 55 AND var_age <= 59 THEN
                    SELECT
                        1
                        INTO var_age12;
                END IF;

                IF var_age >= 60 AND var_age <= 64 THEN
                    SELECT
                        1
                        INTO var_age13;
                END IF;

                IF var_age >= 65 AND var_age <= 69 THEN
                    SELECT
                        1
                        INTO var_age14;
                END IF;

                IF var_age >= 70 AND var_age <= 74 THEN
                    SELECT
                        1
                        INTO var_age15;
                END IF;

                IF var_age >= 75 AND var_age <= 79 THEN
                    SELECT
                        1
                        INTO var_age16;
                END IF;

                IF var_age >= 80 AND var_age <= 84 THEN
                    SELECT
                        1
                        INTO var_age17;
                END IF;

                IF var_age >= 85 THEN
                    SELECT
                        1
                        INTO var_age18;
                END IF;
                /*
                if @age = null
                select @age19 = 1
                */
            END;
        ELSE
            IF var_dob is NULL THEN
                BEGIN
                    SELECT
                        1
                        INTO var_age19;
                    /* select @age = null */
                END;
            END IF;
        END IF;
        SELECT
            0
            INTO var_rowcount;
        SELECT
            COUNT(*)
            INTO var_rowcount
            FROM t$adm_dis_death
            WHERE specialty = var_specialty_code;

        IF var_rowcount = 0 THEN
            BEGIN
                INSERT INTO t$adm_dis_death (record_type, specialty, type, sex)
                VALUES ('0', var_specialty_code, 'A', 'F');
                INSERT INTO t$adm_dis_death (record_type, specialty, type, sex)
                VALUES ('0', var_specialty_code, 'A', 'M');
                INSERT INTO t$adm_dis_death (record_type, specialty, type, sex)
                VALUES ('0', var_specialty_code, 'A', 'U');
                INSERT INTO t$adm_dis_death (record_type, specialty, type, sex)
                VALUES ('0', var_specialty_code, 'D', 'F');
                INSERT INTO t$adm_dis_death (record_type, specialty, type, sex)
                VALUES ('0', var_specialty_code, 'D', 'M');
                INSERT INTO t$adm_dis_death (record_type, specialty, type, sex)
                VALUES ('0', var_specialty_code, 'D', 'U');
                INSERT INTO t$adm_dis_death (record_type, specialty, type, sex)
                VALUES ('0', var_specialty_code, 'E', 'F');
                INSERT INTO t$adm_dis_death (record_type, specialty, type, sex)
                VALUES ('0', var_specialty_code, 'E', 'M');
                INSERT INTO t$adm_dis_death (record_type, specialty, type, sex)
                VALUES ('0', var_specialty_code, 'E', 'U');
            END;
        END IF;
        UPDATE t$adm_dis_death
        SET age1 = age1 + var_age1, age2 = age2 + var_age2, age3 = age3 + var_age3, age4 = age4 + var_age4, age5 = age5 + var_age5, age6 = age6 + var_age6, age7 = age7 + var_age7, age8 = age8 + var_age8, age9 = age9 + var_age9, age10 = age10 + var_age10, age11 = age11 + var_age11, age12 = age12 + var_age12, age13 = age13 + var_age13, age14 = age14 + var_age14, age15 = age15 + var_age15, age16 = age16 + var_age16, age17 = age17 + var_age17, age18 = age18 + var_age18, age19 = age19 + var_age19
            WHERE specialty = var_specialty_code AND type = var_type AND sex = var_sex;
        FETCH cura INTO var_case_no, var_transaction_type, var_specialty_code;
    END LOOP;
    UPDATE t$adm_dis_death
    SET total = age1 + age2 + age3 + age4 + age5 + age6 + age7 + age8 + age9 + age10 + age11 + age12 + age13 + age14 + age15 + age16 + age17 + age18 + age19;
    /* -- Add Hospital code for HPI by ML on 23.07.1999 */
    OPEN p_refcur FOR
    SELECT
        s.Description, t.Type, t.Sex, t.age1, t.age2, t.age3, t.age4, t.age5, t.age6, t.age7, t.age8, t.age9, t.age10, t.age11, t.age12, t.age13, t.age14, t.age15, t.age16, t.age17, t.age18, t.age19, t.total
        FROM t$adm_dis_death AS t, Specialty AS s
        WHERE t.Specialty = s.Specialty_code AND s.Effective_date = (SELECT
            MAX(Effective_date)
            FROM Specialty
            WHERE Effective_date < par_to_datetime AND Specialty_code = t.Specialty AND Hospital_code = par_hosp_code) AND s.Hospital_code = par_hosp_code
        ORDER BY record_type NULLS FIRST, Specialty NULLS FIRST, type NULLS FIRST, sex NULLS FIRST;
	return next p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_adm_dis_death" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
