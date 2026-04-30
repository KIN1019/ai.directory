CREATE OR REPLACE FUNCTION hasp_ae_disc_dest_sum(IN par_hosp_code CHAR, IN par_dest CHAR, IN par_from_date TIMESTAMP WITHOUT TIME ZONE, IN par_to_date TIMESTAMP WITHOUT TIME ZONE)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/*
- A&E discharge summary by destination

    Parameters to be used :-
	     Description               Data Type
	--------------------	       -------------
   1. Hospital code               VARCHAR(3)
	2. Destination code            VARCHAR(3)
	3. From date                   datetime
	4. To date                     datetime

   Modification History:
   ---------------------
   26.07.1999 - Add hospital code for HPI by Mabel LAU
*/
/* 2010-01-22 20017749 fx use d, m, y for age indicator */
DECLARE
	p_refcur refcursor;
    var_case_no VARCHAR(24);
    var_hkid VARCHAR(24);
    var_tran_dt TIMESTAMP WITHOUT TIME ZONE;
    var_pay_code VARCHAR(6);
    var_disc_dt TIMESTAMP WITHOUT TIME ZONE;
    var_disc_code VARCHAR(1);
    var_race_code VARCHAR(4);
    var_age_char VARCHAR(10);
    var_age INTEGER;
    var_dest_code VARCHAR(6);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_name VARCHAR(96);
    var_sex VARCHAR(2);
    var_marital_status VARCHAR(2);
    var_disc_type VARCHAR(10);
    tran_csr CURSOR FOR
    SELECT
        Case_no, Transaction_datetime
        /* --from Transaction_log */
        FROM Transaction_log
        WHERE Transaction_datetime >= par_from_date AND Transaction_datetime < par_to_date AND Transaction_type = '300' AND Cancel_flag IS NULL AND Hospital_code = par_hosp_code;
    var_return_code int;
BEGIN
    /* **************************** */
    /* declare variable */
    /* **************************** */
	DROP TABLE IF EXISTS t$dsp_table;
    SELECT
        1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
        INTO par_to_date;
    /*
    select Case.Case_no, Case.HKID,
    Case.Admission_datetime, Case.Pay_code, Case.Discharge_datetime,
    Case.Destination_code, PMI.Name, PMI.Sex, PMI.DOB, PMI.Marital_status,
    PMI.Race_code, datediff(month, PMI.DOB, getdate())/12
    from Case, PMI
    where (Case.HKID = PMI.HKID) and
          (Admission_datetime >= @from_date) and
          (Admission_datetime < @to_date) and
          (Discharge_datetime is not null) and
          (Case.Destination_code like @dest) and
          (Case_type = 'A')
    order by Case.Destination_code asc,
    	 Case.Case_no asc
    */
    /* changed by Karen at 1996-04-29 for cpi */
    /* before changes are comment for select from Case_view written below */
    /*
    select t.Case_no, c.HKID,
    Transaction_datetime, Pay_code, Discharge_datetime,
    Destination_code, Name, Sex, DOB, Marital_status,
    Race_code, datediff(month, DOB, getdate())/12
    from Transaction_log t, Case c, PMI p
    where Transaction_datetime >= @from_date
    and Transaction_datetime < @to_date
    and Transaction_type = '300'
    and Cancel_flag is null
    and t.Case_no = c.Case_no
    and c.HKID = p.HKID
    and Discharge_datetime is not null
    and Destination_code is not null
    and Destination_code like @dest
    order by Destination_code asc,
             t.Case_no asc
    */
    /* end of comment */
    /* modify start for select from Case_view */
    /*
    select t.Case_no, c.HKID,
    Transaction_datetime, Pay_code, Discharge_datetime,
    Destination_code, Name, Sex, DOB, Marital_status,
    Race_code, datediff(month, DOB, getdate())/12
    from Transaction_log t, Case_view c, PMI p
    where Transaction_datetime >= @from_date
    and Transaction_datetime < @to_date
    and Transaction_type = '300'
    and Cancel_flag is null
    and t.Case_no = c.Case_no
    and c.HKID = p.HKID
    and Discharge_datetime is not null
    and Destination_code is not null
    and Destination_code like @dest
    order by Destination_code asc,
             t.Case_no asc
    /* end of modify */
    */
    /* ********************************* */
    /* create tmp table for display */
    /* ********************************* */
    CREATE TEMPORARY TABLE t$dsp_table
    (case_no VARCHAR(24) NULL,
        hkid VARCHAR(24) NULL,
        tran_dt TIMESTAMP WITHOUT TIME ZONE NULL,
        pay_code VARCHAR(6) NULL,
        disc_dt TIMESTAMP WITHOUT TIME ZONE NULL,
        dest_code VARCHAR(10) NULL,
        name VARCHAR(96) NULL,
        sex VARCHAR(2) NULL,
        dob TIMESTAMP WITHOUT TIME ZONE NULL,
        marital_status VARCHAR(2) NULL,
        race_code VARCHAR(4) NULL,
        age INTEGER NULL,
        case_year VARCHAR(8) NULL,
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
        age_char VARCHAR(10) NULL
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */);
    /* **************************************** */
    /* Modified by Winnie to speed up the */
    /* retrieval time on 27 Jan 1997 */
    /* **************************************** */
    /* --- Add hospital code for HPI by ML on 26.07.1999 --- */
    OPEN tran_csr;
    FETCH tran_csr INTO var_case_no, var_tran_dt;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        /* print '>>> case_no = %1!', @case_no */
        /* --- Add hospital code for HPI by ML on 26.07.1999 --- */
        SELECT
            Discharge_datetime, Destination_code, HKID, Pay_code, Discharge_code
            INTO var_disc_dt, var_dest_code, var_hkid, var_pay_code, var_disc_code
            FROM Case_view
            WHERE Case_no = var_case_no AND (Destination_code LIKE par_dest OR (Destination_code IS NULL AND par_dest = '%')) AND Hospital_code = par_hosp_code;

        IF var_disc_code IS NOT NULL THEN
            BEGIN
                /* --- modified to use PMI_wo_MRN for HPI  --- */
                /* --- by ML on 26.07.1999                 --- */
                SELECT
                    Race_code, DOB, Name, Sex, Marital_status
                    INTO var_race_code, var_dob, var_name, var_sex, var_marital_status
                    /* --from PMI */
                    FROM PMI_wo_MRN
                    WHERE HKID = var_hkid;

                IF var_dob IS NOT NULL THEN
                    BEGIN
                        CALL hasp_cal_age(var_return_code,var_dob, var_disc_dt, var_age_char);
                        /* --if right(@age_char,2) = 'mo' or right(@age_char,2) = 'da' */
                        IF RIGHT(var_age_char, 1) = 'd' THEN
                            SELECT
                                0
                                INTO var_age;
                        ELSE
                            IF RIGHT(var_age_char, 1) = 'm' THEN
                                BEGIN
                                    SELECT
                                        CAST (SAFE_SUBSTRING(var_age_char, 1, 3) AS INTEGER)
                                        INTO var_age;

                                    IF var_age < 12 THEN
                                        SELECT
                                            0
                                            INTO var_age;
                                    ELSE
                                        IF var_age >= 12 AND var_age < 24 THEN
                                            SELECT
                                                1
                                                INTO var_age;
                                        ELSE
                                            IF var_age >= 24 THEN
                                                SELECT
                                                    2
                                                    INTO var_age;
                                            END IF;
                                        END IF;
                                    END IF;
                                END;
                            ELSE
                                SELECT
                                    CAST (SAFE_SUBSTRING(var_age_char, 1, 3) AS INTEGER)
                                    INTO var_age;
                            END IF;
                        END IF;

                        IF var_disc_code = '0' OR var_disc_code = '4' OR var_disc_code = '9' THEN
                            INSERT INTO t$dsp_table
                            VALUES (var_case_no, var_hkid, var_tran_dt, var_pay_code, var_disc_dt, var_dest_code, var_name, var_sex, var_dob, var_marital_status,
                            /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                            /* @race_code, @age, null) */
                            var_race_code, var_age, NULL, var_age_char);
                        /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                        ELSE
                            BEGIN
                                SELECT
                                    Short_description
                                    INTO var_disc_type
                                    FROM Discharge_type
                                    WHERE Discharge_code = var_disc_code;
                                INSERT INTO t$dsp_table
                                VALUES (var_case_no, var_hkid, var_tran_dt, var_pay_code, var_disc_dt, var_disc_type, var_name, var_sex, var_dob, var_marital_status,
                                /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                                /* @race_code, @age, null) */
                                var_race_code, var_age, NULL, var_age_char);
                                /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        IF var_disc_code = '0' OR var_disc_code = '4' OR var_disc_code = '9' THEN
                            INSERT INTO t$dsp_table
                            VALUES (var_case_no, var_hkid, var_tran_dt, var_pay_code, var_disc_dt, var_dest_code, var_name, var_sex, var_dob, var_marital_status,
                            /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                            /* @race_code, null, null) */
                            var_race_code, NULL, NULL, NULL);
                        /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                        ELSE
                            BEGIN
                                SELECT
                                    Short_description
                                    INTO var_disc_type
                                    FROM Discharge_type
                                    WHERE Discharge_code = var_disc_code;
                                INSERT INTO t$dsp_table
                                VALUES (var_case_no, var_hkid, var_tran_dt, var_pay_code, var_disc_dt, var_disc_type, var_name, var_sex, var_dob, var_marital_status,
                                /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                                /* @race_code, null, null) */
                                var_race_code, NULL, NULL, NULL);
                                /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        SELECT
            NULL, NULL, NULL, NULL, NULL
            INTO var_dest_code, var_disc_dt, var_disc_type, var_disc_code, var_dob;
        FETCH tran_csr INTO var_case_no, var_tran_dt;
    END LOOP;
    CLOSE tran_csr;
    /* ******************************** */
    /* display result */
    /* ******************************** */
    UPDATE t$dsp_table
    SET case_year = CONCAT('19', SAFE_SUBSTRING(case_no, 4, 2))
        WHERE SAFE_SUBSTRING(case_no, 4, 2) > '80';
    UPDATE t$dsp_table
    SET case_year = CONCAT('20', SAFE_SUBSTRING(case_no, 4, 2))
        WHERE SAFE_SUBSTRING(case_no, 4, 2) <= '80';
    /* select * */
    /* from #dsp_table */
    /* order by dest_code asc, case_no asc */
    OPEN p_refcur FOR
    SELECT
        case_no, hkid, tran_dt, pay_code, disc_dt, dest_code, name,
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
        /* sex, dob, marital_status, race_code, age */
        sex, dob, marital_status, race_code, age, age_char
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
        FROM t$dsp_table
        ORDER BY dest_code ASC NULLS FIRST, case_year NULLS FIRST, case_no ASC NULLS FIRST;
    return next p_refcur;
    /*


    */
    /*

    Temporary table must be removed before end of the function.
    */
END;
$function$
;

;ALTER FUNCTION "hasp_ae_disc_dest_sum" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
