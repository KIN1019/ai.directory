CREATE OR REPLACE FUNCTION hasp_get_down_pat_loc(IN par_hosp_code VARCHAR)
RETURNS SETOF refcursor
LANGUAGE plpgsql
AS 
$function$
DECLARE
    var_hkid VARCHAR(12);
    var_case_no VARCHAR(12);
    var_name VARCHAR(96);
    var_chinese_name VARCHAR(24);
    var_home_phone_no VARCHAR(20);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
	p_refcur refcursor;
BEGIN
    DROP TABLE IF EXISTS t$down_table;
    CREATE TEMPORARY TABLE t$down_table
    (case_no VARCHAR(24),
        hkid VARCHAR(24),
        name VARCHAR(96) NULL,
        sex VARCHAR(2) NULL,
        dob TIMESTAMP WITHOUT TIME ZONE NULL,
        chinese_name VARCHAR(24) NULL,
        home_phone_no VARCHAR(20) NULL,
        race_code VARCHAR(4) NULL,
        medical_record_number VARCHAR(24) NULL,
        access_code INTEGER NULL,
        admission_datetime TIMESTAMP WITHOUT TIME ZONE NULL,
        discharge_datetime TIMESTAMP WITHOUT TIME ZONE NULL,
        destination_code VARCHAR(10) NULL,
        ward_code VARCHAR(8) NULL,
        bed_no VARCHAR(10) NULL,
        specialty_code VARCHAR(8) NULL,
        ward_class VARCHAR(2) NULL,
        movement_count INTEGER NULL);
    CREATE UNIQUE INDEX down_index ON t$down_table
        (case_no);
    CREATE INDEX down_index2 ON t$down_table
        (hkid);
    INSERT INTO t$down_table (case_no, hkid, name, sex, dob, chinese_name, home_phone_no)
    SELECT
        Case_no, HKID, Name, Sex, DOB, Chinese_name, mobile_phone
        FROM Patient_location;
    UPDATE t$down_table AS d
    SET race_code = p.Race_code, medical_record_number = p.Medical_record_number, access_code = p.Access_code
    FROM PMI AS p
        WHERE d.hkid = p.HKID AND p.Hospital_code = par_hosp_code;
    UPDATE t$down_table AS d
    SET admission_datetime = c.Admission_datetime, discharge_datetime = c.Discharge_datetime, destination_code = c.Destination_code, movement_count = c.Movement_count
    FROM ADT_Case AS c
        WHERE d.case_no = c.Case_no AND c.Case_no = Case_no AND c.Hospital_code = par_hosp_code;
    UPDATE t$down_table AS d
    SET ward_code = m.Ward_code, bed_no = m.Bed_no, specialty_code = m.Specialty_code, ward_class = m.Ward_class
    FROM Movement AS m
        WHERE d.case_no = m.Case_no AND d.movement_count = m.Movement_count AND m.Hospital_code = par_hosp_code;
    OPEN p_refcur FOR
    SELECT
        case_no, hkid, name, sex, dob, chinese_name, home_phone_no, race_code, medical_record_number, access_code, admission_datetime, discharge_datetime, destination_code, ward_code, bed_no, specialty_code, ward_class
        FROM t$down_table;
    -- DROP TABLE t$down_table;

    return next p_refcur;
    /*
    
    DROP TABLE IF EXISTS t$down_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$;