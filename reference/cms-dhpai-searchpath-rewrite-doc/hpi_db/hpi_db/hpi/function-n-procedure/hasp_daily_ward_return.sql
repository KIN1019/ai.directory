CREATE OR REPLACE FUNCTION hasp_daily_ward_return(IN par_hosp_code VARCHAR, IN par_from_datetime TIMESTAMP WITHOUT TIME ZONE, IN par_to_datetime TIMESTAMP WITHOUT TIME ZONE)
RETURNS SETOF refcursor
language plpgsql
AS $function$
/*
- Daily Ward Return

27.07.1999 - Add hosp code for HPI by Mabel LAU
*/
/* 2010-01-22 20017749 fx use d, m, y for age indicator */
DECLARE
    var_rowcount INTEGER;
    var_hkid VARCHAR(24);
    var_age_char VARCHAR(10);
    var_txn_dt TIMESTAMP WITHOUT TIME ZONE;
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    daily_ward_return_csr CURSOR FOR
    SELECT
        hkid, dob, tx_datetime
        FROM t$daily_ward_return
        ORDER BY hkid NULLS FIRST, dob NULLS FIRST, tx_datetime NULLS FIRST;
    var_return_code int;
	p_refcur refcursor;
BEGIN
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
    SELECT
        1 * INTERVAL '1 day' + par_to_datetime::TIMESTAMP
        INTO par_to_datetime;
    DROP TABLE IF EXISTS t$daily_ward_return;
    DROP TABLE IF EXISTS t$ward_code;
    CREATE TEMPORARY TABLE t$daily_ward_return
    (Ward_code VARCHAR(8) NOT NULL,
        Type VARCHAR(40) NOT NULL,
        Case_no VARCHAR(24) NULL,
        Sex VARCHAR(2) NULL,
        DOB TIMESTAMP WITHOUT TIME ZONE NULL,
        Age VARCHAR(10) NULL,
        Name VARCHAR(96) NULL,
        HKID VARCHAR(24) NULL,
        Tx_datetime TIMESTAMP WITHOUT TIME ZONE NULL,
        From_specialty_code VARCHAR(8) NULL,
        To_ward_code VARCHAR(8) NULL,
        To_specialty_code VARCHAR(8) NULL,
        Destination_code VARCHAR(10) NULL,
        Discharge_code VARCHAR(2) NULL,
        Source_indicator_plus_code VARCHAR(10) NULL,
        case_year VARCHAR(8) NULL,
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
        Age_char VARCHAR(10) NULL
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */);
    INSERT INTO t$daily_ward_return (ward_code, type, case_no, sex, dob, age, name, hkid, tx_datetime, from_specialty_code, to_ward_code, to_specialty_code,
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
    /* Destination_code,Discharge_code,Source_indicator_plus_code) */
    destination_code, discharge_code, source_indicator_plus_code, age_char)
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
    SELECT
        t.From_ward_code, 'Discharge', /* Discharge */ t.Case_no, p.Sex, p.DOB, NULL, p.Name, p.HKID, t.Transaction_datetime, t.From_specialty_code, t.To_ward_code, t.To_specialty_code, c.Destination_code, c.Discharge_code, CONCAT(c.Source_indicator, '-', c.Source_code),
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
        NULL
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
        /*
        change Case to Case_view for the implementation of CPI
        from  Transaction_log t,Case c,PMI p
        */
        /* change to use PMI_wo_MRN  & */
        /* add hosp code for HPI by ML on 27.07.1999 */
        /* --		  from  Transaction_log t,Case_view c,PMI p */
        FROM Transaction_log AS t, Case_view AS c, PMI_wo_MRN AS p
        WHERE t.Transaction_datetime BETWEEN par_from_datetime AND par_to_datetime AND t.Case_no = c.Case_no AND c.HKID = p.HKID AND t.Cancel_flag = NULL AND t.Transaction_type LIKE '13%' AND t.Transaction_type != '131' AND t.Hospital_code = par_hosp_code AND c.Hospital_code = par_hosp_code;
    UPDATE t$daily_ward_return
    SET Destination_code = (SELECT
        Short_description
        FROM Discharge_type
        WHERE t$daily_ward_return.discharge_code = Discharge_type.Discharge_code)
        WHERE type = 'Discharge';
    INSERT INTO t$daily_ward_return (ward_code, type, case_no, sex, dob, age, name, hkid, tx_datetime, from_specialty_code, to_ward_code, to_specialty_code,
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
    /* Destination_code,Discharge_code,Source_indicator_plus_code) */
    destination_code, discharge_code, source_indicator_plus_code, age_char)
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
    SELECT
        t.From_ward_code, 'Death', /* Death */ t.Case_no, p.Sex, p.DOB, NULL, p.Name, p.HKID, t.Transaction_datetime, t.From_specialty_code, t.To_ward_code, t.To_specialty_code, c.Destination_code, c.Discharge_code, CONCAT(c.Source_indicator, '-', c.Source_code),
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
        NULL
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
        /*
        change Case to Case_view for the implementation of cpi
        from  Transaction_log t,Case c,PMI p
        */
        /* change to use PMI_wo_MRN  & */
        /* add hosp code for HPI by ML on 27.07.1999 */
        /* from  Transaction_log t,Case_view c,PMI p */
        FROM Transaction_log AS t, Case_view AS c, PMI_wo_MRN AS p
        WHERE t.Transaction_datetime BETWEEN par_from_datetime AND par_to_datetime AND t.Case_no = c.Case_no AND c.HKID = p.HKID AND t.Cancel_flag = NULL AND t.Transaction_type = '131' AND t.Hospital_code = par_hosp_code AND c.Hospital_code = par_hosp_code;
    INSERT INTO t$daily_ward_return (ward_code, type, case_no, sex, dob, age, name, hkid, tx_datetime, from_specialty_code, to_ward_code, to_specialty_code,
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
    /* Destination_code,Discharge_code,Source_indicator_plus_code) */
    destination_code, discharge_code, source_indicator_plus_code, age_char)
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
    SELECT
        t.From_ward_code, 'Admission', /* Admission */ t.Case_no, p.Sex, p.DOB, NULL, p.Name, p.HKID, t.Transaction_datetime, t.From_specialty_code, t.To_ward_code, t.To_specialty_code, c.Destination_code, c.Discharge_code, CONCAT(c.Source_indicator, '-', c.Source_code),
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
        NULL
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
        /*
        change Case to Case_view for the implementation of cpi
        from  Transaction_log t,Case c,PMI p
        */
        /* change to use PMI_wo_MRN  & */
        /* add hosp code for HPI by ML on 27.07.1999 */
        /* --		  from  Transaction_log t,Case_view c,PMI p */
        FROM Transaction_log AS t, Case_view AS c, PMI_wo_MRN AS p
        WHERE t.Transaction_datetime BETWEEN par_from_datetime AND par_to_datetime AND t.Case_no = c.Case_no AND c.HKID = p.HKID AND t.Cancel_flag = NULL AND t.Transaction_type = '100' AND t.Hospital_code = par_hosp_code AND c.Hospital_code = par_hosp_code;
    INSERT INTO t$daily_ward_return (ward_code, type, case_no, sex, dob, age, name, hkid, tx_datetime, from_specialty_code, to_ward_code, to_specialty_code,
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
    /* Destination_code,Discharge_code,Source_indicator_plus_code) */
    destination_code, discharge_code, source_indicator_plus_code, age_char)
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
    SELECT
        t.From_ward_code, 'Transfer in', /* Transfer in */ t.Case_no, p.Sex, p.DOB, NULL, p.Name, p.HKID, t.Transaction_datetime, t.From_specialty_code, t.To_ward_code, t.To_specialty_code, c.Destination_code, c.Discharge_code, CONCAT(c.Source_indicator, '-', c.Source_code),
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
        NULL
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
        /*
        change Case to Case_view for the implementation of cpi
        from  Transaction_log t,Case c,PMI p
        */
        /*
        add hosp code for HPI  &
        change to use PMI_wo_MRN by ML on 27.07.1999
        */
        /* --		  from  Transaction_log t,Case_view c,PMI p */
        FROM Transaction_log AS t, Case_view AS c, PMI_wo_MRN AS p
        WHERE t.Transaction_datetime BETWEEN par_from_datetime AND par_to_datetime AND t.Case_no = c.Case_no AND c.HKID = p.HKID AND t.Cancel_flag = NULL AND t.Transaction_type = '141' AND t.Hospital_code = par_hosp_code AND c.Hospital_code = par_hosp_code;
    INSERT INTO t$daily_ward_return (ward_code, type, case_no, sex, dob, age, name, hkid, tx_datetime, from_specialty_code, to_ward_code, to_specialty_code,
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
    /* Destination_code,Discharge_code,Source_indicator_plus_code) */
    destination_code, discharge_code, source_indicator_plus_code, age_char)
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
    SELECT
        t.From_ward_code, 'Transfer out', /* Transfer out */ t.Case_no, p.Sex, p.DOB, NULL, p.Name, p.HKID, t.Transaction_datetime, t.From_specialty_code, t.To_ward_code, t.To_specialty_code, c.Destination_code, c.Discharge_code, CONCAT(c.Source_indicator, '-', c.Source_code),
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
        NULL
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
        /*
        change Case to Case_view for the implementation of cpi
        from  Transaction_log t,Case c,PMI p
        */
        /* change to use PMI_wo_MRN and */
        /* add hosp code for HPI by ML on 27.07.1999 */
        /* --		  from  Transaction_log t,Case_view c,PMI p */
        FROM Transaction_log AS t, Case_view AS c, PMI_wo_MRN AS p
        WHERE t.Transaction_datetime BETWEEN par_from_datetime AND par_to_datetime AND t.Case_no = c.Case_no AND c.HKID = p.HKID AND t.Cancel_flag = NULL AND t.Transaction_type = '140' AND t.Hospital_code = par_hosp_code AND c.Hospital_code = par_hosp_code;
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
    UPDATE t$daily_ward_return
    SET Age = CONCAT(Sex, '/', CAST (DATE_PART('year', Tx_datetime::TIMESTAMP) - DATE_PART('year', DOB::TIMESTAMP) AS VARCHAR(3)));
    OPEN daily_ward_return_csr;
    FETCH daily_ward_return_csr INTO var_hkid, var_dob, var_txn_dt;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        CALL hasp_cal_age(var_return_code, var_dob, var_txn_dt, var_age_char);
        UPDATE t$daily_ward_return
        SET Age_char = var_age_char
            WHERE hkid = var_hkid AND dob = var_dob AND tx_datetime = var_txn_dt AND var_dob IS NOT NULL;
        FETCH daily_ward_return_csr INTO var_hkid, var_dob, var_txn_dt;
    END LOOP;
    CLOSE daily_ward_return_csr;
    UPDATE t$daily_ward_return
    SET Age = CONCAT(Sex, '/', ' ')
        WHERE dob = NULL;
    /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
    CREATE TEMPORARY TABLE t$ward_code
    AS
    SELECT DISTINCT
        ward_code
        FROM t$daily_ward_return;
    UPDATE t$daily_ward_return
    SET case_year = CONCAT('19', SUBSTRING(Case_no, 4, 2))
        WHERE SUBSTRING(case_no, 4, 2) > '80';
    UPDATE t$daily_ward_return
    SET case_year = CONCAT('20', SUBSTRING(Case_no, 4, 2))
        WHERE SUBSTRING(case_no, 4, 2) <= '80';
    /* --		  select * from #daily_ward_return */
    /* --		  order by Ward_code,Type,Case_no */
    OPEN p_refcur FOR
    SELECT
        ward_code, type, case_no, sex, dob, age, name, hkid, tx_datetime, from_specialty_code, to_ward_code, to_specialty_code, destination_code, discharge_code,
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
        /* Source_indicator_plus_code */
        source_indicator_plus_code, age_char
        /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
        FROM t$daily_ward_return
        ORDER BY ward_code NULLS FIRST, type NULLS FIRST, case_year NULLS FIRST, case_no NULLS FIRST;
    return next p_refcur;
    /*
    
    DROP TABLE IF EXISTS t$daily_ward_return;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$ward_code;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;