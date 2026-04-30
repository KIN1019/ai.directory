CREATE OR REPLACE FUNCTION pass_get_cases(IN par_hospital_code VARCHAR, IN par_patient_key VARCHAR, IN par_hkid VARCHAR, IN par_case_no VARCHAR, IN par_case_type VARCHAR DEFAULT null, IN par_isActiveCaseOnly VARCHAR DEFAULT null, IN par_mrn VARCHAR DEFAULT null, IN par_case_status_code VARCHAR DEFAULT null)
RETURNS SETOF refcursor
LANGUAGE plpgsql
AS 
$FUNCTION$
DECLARE
    var_pin VARCHAR(16);
    var_tmp_case_type VARCHAR(12);
    var_pin_len INTEGER;
    var_start INTEGER;
    var_counter INTEGER;
	p_refcur refcursor;
BEGIN
    IF par_patient_key = '' OR par_patient_key IS NULL THEN
        BEGIN
            SELECT
                LTRIM(RTRIM(par_hkid))
                INTO var_pin;
            SELECT
                OCTET_LENGTH(var_pin)
                INTO var_pin_len;

            IF var_pin_len = 8 THEN
                SELECT
                    CONCAT(' ', var_pin)
                    INTO var_pin;
            END IF;
            SELECT
                patient_key
                INTO par_patient_key
                FROM cpi_patient
                WHERE hkid = var_pin;
        END;
    END IF;

    IF par_patient_key = '' OR par_patient_key IS NULL THEN
        BEGIN
            SELECT
                LTRIM(RTRIM(par_case_no))
                INTO var_pin;
            SELECT
                OCTET_LENGTH(var_pin)
                INTO var_pin_len;

            IF var_pin_len = 11 THEN
                SELECT
                    CONCAT(' ', var_pin)
                    INTO var_pin;
            END IF;
            SELECT
                patient_key
                INTO par_patient_key
                FROM cpi_case
                WHERE hospital_code = par_hospital_code AND case_no = var_pin;
        END;
    END IF;

    IF par_patient_key = '' OR par_patient_key IS NULL THEN
        BEGIN
            SELECT
                LTRIM(RTRIM(par_mrn))
                INTO var_pin;
            SELECT
                CONCAT(REPEAT(' ', 08), var_pin)
                INTO var_pin;
            SELECT
                RIGHT(var_pin, 8)
                INTO var_pin;
            SELECT
                patient_key
                INTO par_patient_key
                FROM cpi_patient_hospital_data
                WHERE hospital_code = par_hospital_code AND mrn = var_pin;
        END;
    END IF;

    IF par_case_type IS NULL OR par_case_type = '' THEN
        BEGIN
            SELECT
                'I,A,O'
                INTO par_case_type;
        END;
    END IF;

    IF par_case_status_code IS NULL OR par_case_status_code = '' THEN
        BEGIN
            SELECT
                'all'
                INTO par_case_status_code;
            /*
            
            DROP TABLE IF EXISTS t$temp_case_type;
            */
            /*
            
            Temporary table must be removed before end of the function.
            */
            /*
            
            DROP TABLE IF EXISTS t$temp_result;
            */
            /*
            
            Temporary table must be removed before end of the function.
            */
        END;
    END IF;
    /* --temp case type */
    CREATE TEMPORARY TABLE t$temp_case_type
    (case_type VARCHAR(1) NULL);
    SELECT
        1
        INTO var_start;
    SELECT
        1
        INTO var_counter;

    WHILE 3 >= var_counter LOOP
        INSERT INTO t$temp_case_type
        SELECT
            SUBSTRING(par_case_type, var_start, 1);
        SELECT
            var_counter + 1
            INTO var_counter;
        SELECT
            var_start + 2
            INTO var_start;
    END LOOP;
    CREATE TEMPORARY TABLE t$temp_result
    (hospital_code VARCHAR(6),
        case_no VARCHAR(24),
        patient_key VARCHAR(16),
        hkid VARCHAR(24),
        case_type VARCHAR(2),
        status VARCHAR(60),
        admission_dtm VARCHAR(40),
        source_indicator VARCHAR(2) NULL,
        source_code VARCHAR(6) NULL,
        patient_type VARCHAR(6) NULL,
        discharge_code VARCHAR(2) NULL,
        discharge_dtm VARCHAR(40),
        destination_code VARCHAR(10) NULL,
        /* --adm_specialty_code  VARCHAR(4)  null, */
        /* --adm_ward_code       VARCHAR(4)  null, */
        /* --adm_ward_class      VARCHAR(1)  null, */
        last_specialty VARCHAR(8) NULL,
        last_ward_code VARCHAR(8) NULL,
        last_ward_class VARCHAR(2) NULL,
        last_bed_no VARCHAR(10) NULL,
        pp_code VARCHAR(16) NULL,
        access_code INTEGER NULL,
        create_by VARCHAR(16),
        create_dtm VARCHAR(40),
        update_by VARCHAR(16),
        /* --source_system_dtm   VARCHAR(20), */
        district VARCHAR(10) NULL,
        mrt_indicator VARCHAR(2) NULL,
        movement_count INTEGER NULL,
        /* --security_count      int      null, */
        /* --source_system       VARCHAR(5), */
        /* --filler              varchar(30) null, */
        mrn VARCHAR(16) NULL,
        ambulance_no VARCHAR(8) NULL);
    INSERT INTO t$temp_result (hospital_code, case_no, patient_key, hkid, case_type, status, admission_dtm, source_indicator, source_code, patient_type, discharge_code, discharge_dtm, destination_code,
    /* --adm_specialty_code, */
    /* --adm_ward_code, */
    /* --adm_ward_class, */
    last_specialty, last_ward_code, last_ward_class, last_bed_no, pp_code, access_code, create_by, create_dtm, update_by,
    /* --source_system_dtm, */
    district, mrt_indicator, movement_count)
    /* --security_count, */
    /* --source_system, */
    /* --filler */
    /* --Case */
    SELECT
        c.hospital_code, c.case_no, c.patient_key, p.hkid, c.case_type, 'Inactive',
        /* --c.adm_dtm, */
        CONCAT(to_char(c.admission_dtm, 'dd-mm-yyyy'), ' ', to_char(c.admission_dtm, 'yyyymmdd')) AS admission_dtm, c.source_indicator, c.source_code, c.patient_type, c.discharge_code,
        /* --c.discharge_dtm, */
        CONCAT(to_char(c.discharge_dtm, 'dd-mm-yyyy'), ' ', to_char(c.discharge_dtm, 'yyyymmdd')) AS discharge_dtm, c.destination_code,
        /* --c.adm_specialty_code, */
        /* --c.adm_ward_code, */
        /* --c.adm_ward_class, */
        c.last_specialty, c.last_ward_code, c.last_ward_class, c.last_bed_no, c.pp_code, c.access_code, c.create_by,
        /* --c.create_dtm, */
        CONCAT(to_char(c.create_dtm, 'dd-mm-yyyy'), ' ', to_char(c.create_dtm, 'yyyymmdd')) AS create_dtm, c.update_by,
        /* --c.source_system_dtm, */
        /* --convert(VARCHAR(10), c.source_system_dtm, 105) +' '+convert(VARCHAR(8), c.source_system_dtm, 108) source_system_dtm, */
        c.district_code, c.mrt_indicator, c.movement_count
        /* --c.security_count, */
        /* --c.source_system, */
        /* --c.filler */
        /* --c.status_code */
        FROM cpi_case AS c, cpi_patient AS p, t$temp_case_type AS ct
        WHERE c.patient_key = par_patient_key AND p.patient_key = par_patient_key AND (c.case_type = ct.case_type) AND (par_isActiveCaseOnly <> 'Y' OR (c.discharge_code IS NULL AND c.discharge_dtm IS NULL)) AND (par_case_status_code = 'all' OR (c.status_code = par_case_status_code));
    /* --update status */
    UPDATE t$temp_result
    SET status = 'Active'
        WHERE (discharge_code IS NULL OR discharge_code = '') AND (discharge_dtm IS NULL OR discharge_dtm = '');
    /* --update mrn */
    UPDATE t$temp_result
    SET mrn = m.mrn
    FROM cpi_patient_hospital_data AS m
        WHERE m.patient_key = par_patient_key AND m.hospital_code = par_hospital_code;
    /* --update ambulance_no */
    UPDATE t$temp_result AS t
    SET ambulance_no = a.ambulance_no
    FROM cpi_ae_case_detail AS a
        WHERE t.case_no = a.case_no AND t.hospital_code = a.hospital_code;
    OPEN p_refcur FOR
    SELECT
        RTRIM(hospital_code) AS hospital_code, case_no, patient_key, RTRIM(hkid) AS hkid, case_type, status, RTRIM(admission_dtm) AS admission_dtm, source_indicator, source_code, patient_type, discharge_code, RTRIM(discharge_dtm) AS discharge_dtm, RTRIM(destination_code) AS destination_code, '', /* --adm_specialty_code, */ '', /* --adm_ward_code, */ '', /* --adm_ward_class, */ RTRIM(last_specialty) AS last_specialty, RTRIM(last_ward_code) AS last_ward_code, last_ward_class, RTRIM(last_bed_no) AS last_bed_no, pp_code, access_code, create_by, create_dtm, update_by, '', /* --source_system_dtm, */ district, mrt_indicator, movement_count, '', /* --security_count, */ '', /* --source_system, */ '', /* --filler, */ mrn, ambulance_no
        FROM t$temp_result;
END;
$FUNCTION$;