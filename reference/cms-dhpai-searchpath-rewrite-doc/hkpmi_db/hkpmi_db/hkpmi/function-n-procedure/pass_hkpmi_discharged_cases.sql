CREATE OR REPLACE FUNCTION pass_hkpmi_discharged_cases(IN par_hospital_code VARCHAR, IN par_patient_key VARCHAR, IN par_hkid VARCHAR, IN par_case_no VARCHAR, IN par_case_type VARCHAR DEFAULT null, IN par_from_dtm TIMESTAMP WITHOUT TIME ZONE DEFAULT null, IN par_to_dtm TIMESTAMP WITHOUT TIME ZONE DEFAULT null)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_pin VARCHAR(12);
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
                FROM patient
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
                FROM pmi_case
                WHERE hospital_code = par_hospital_code AND case_no = var_pin;
        END;
    END IF;

    IF par_case_type IS NULL OR par_case_type = '' THEN
        BEGIN
            /* select @case_type = 'I,A,O' */
            SELECT
                'I'
                INTO par_case_type /* --In patient type only be default */;
        END;
    END IF;

    /*IF par_from_dtm = '' THEN
        BEGIN
            SELECT
                NULL
                INTO par_from_dtm;
        END;
    END IF;

    IF par_to_dtm = '' THEN
        BEGIN
            SELECT
                NULL
                INTO par_to_dtm;
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
    END IF;*/
    /* --temp case type */
    DROP TABLE IF EXISTS t$temp_case_type;
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
    DROP TABLE IF EXISTS t$temp_result;
    CREATE TEMPORARY TABLE t$temp_result
    (hospital_code VARCHAR(3),
        case_no VARCHAR(12),
        patient_key VARCHAR(8),
        hkid VARCHAR(12),
        case_type VARCHAR(1),
        status VARCHAR(30),
        adm_dtm TIMESTAMP WITHOUT TIME ZONE,
        source_indicator VARCHAR(1) NULL,
        source_code VARCHAR(3) NULL,
        patient_type VARCHAR(3) NULL,
        discharge_code VARCHAR(1) NULL,
        discharge_dtm TIMESTAMP WITHOUT TIME ZONE,
        destination_code VARCHAR(5) NULL,
        adm_specialty_code VARCHAR(4) NULL,
        adm_ward_code VARCHAR(4) NULL,
        adm_ward_class VARCHAR(1) NULL,
        last_specialty_code VARCHAR(4) NULL,
        last_ward_code VARCHAR(4) NULL,
        last_ward_class VARCHAR(1) NULL,
        last_bed_no VARCHAR(5) NULL,
        pp_code VARCHAR(8) NULL,
        access_code INTEGER NULL,
        create_by VARCHAR(8),
        create_dtm TIMESTAMP WITHOUT TIME ZONE,
        update_by VARCHAR(8),
        source_system_dtm TIMESTAMP WITHOUT TIME ZONE,
        district VARCHAR(5) NULL,
        mrt_indicator VARCHAR(1) NULL,
        movement_count INTEGER NULL,
        security_count INTEGER NULL,
        source_system VARCHAR(5),
        filler VARCHAR(30) NULL);
    INSERT INTO t$temp_result (hospital_code, case_no, patient_key, hkid, case_type, status, adm_dtm, source_indicator, source_code, patient_type, discharge_code, discharge_dtm, destination_code, adm_specialty_code, adm_ward_code, adm_ward_class, last_specialty_code, last_ward_code, last_ward_class, last_bed_no, pp_code, access_code, create_by, create_dtm, update_by, source_system_dtm, district, mrt_indicator, movement_count, security_count, source_system, filler)
    /* --Case */
    SELECT
        c.hospital_code, c.case_no, c.patient_key, p.hkid, c.case_type, 'Inactive', c.adm_dtm,
        /* --convert(VARCHAR(10), c.adm_dtm, 105) +' '+convert(VARCHAR(8), c.adm_dtm, 108) adm_dtm, */
        c.source_indicator, c.source_code, c.patient_type, c.discharge_code, c.discharge_dtm,
        /* --convert(VARCHAR(10), c.discharge_dtm, 105) +' '+convert(VARCHAR(8), c.discharge_dtm, 108) discharge_dtm, */
        c.destination_code, c.adm_specialty_code, c.adm_ward_code, c.adm_ward_class, c.last_specialty_code, c.last_ward_code, c.last_ward_class, c.last_bed_no, c.pp_code, c.access_code, c.create_by, c.create_dtm,
        /* --convert(VARCHAR(10), c.create_dtm, 105) +' '+convert(VARCHAR(8), c.create_dtm, 108) create_dtm, */
        c.update_by, c.source_system_dtm,
        /* --convert(VARCHAR(10), c.source_system_dtm, 105) +' '+convert(VARCHAR(8), c.source_system_dtm, 108) source_system_dtm, */
        c.district, c.mrt_indicator, c.movement_count, c.security_count, c.source_system, c.filler
        FROM pmi_case AS c, patient AS p, t$temp_case_type AS ct
        WHERE c.patient_key = par_patient_key AND p.patient_key = par_patient_key AND (c.case_type = ct.case_type) AND c.discharge_code IS NOT NULL AND (par_from_dtm IS NULL OR c.discharge_dtm >= par_from_dtm) AND (par_to_dtm IS NULL OR c.discharge_dtm <= par_to_dtm);
    OPEN p_refcur FOR
    SELECT
        RTRIM(hospital_code) AS hospital_code, case_no, patient_key, RTRIM(hkid) AS hkid, case_type, status, RTRIM(CONCAT(to_char(adm_dtm,'DD-MM-YYYY'), ' ', to_char(adm_dtm,'HH24:MI:SS'))) AS adm_dtm, source_indicator, source_code, patient_type, discharge_code, RTRIM(CONCAT(to_char(discharge_dtm,'DD-MM-YYYY'), ' ', to_char(discharge_dtm,'HH24:MI:SS'))) AS discharge_dtm_formatted, RTRIM(destination_code) AS destination_code, adm_specialty_code, adm_ward_code, adm_ward_class, RTRIM(last_specialty_code) AS last_specialty_code, RTRIM(last_ward_code) AS last_ward_code, last_ward_class, RTRIM(last_bed_no) AS last_bed_no, pp_code, access_code, create_by, CONCAT(to_char(create_dtm,'DD-MM-YYYY'), ' ', to_char(create_dtm,'HH24:MI:SS')), update_by, CONCAT(to_char(source_system_dtm,'DD-MM-YYYY'), ' ', to_char(source_system_dtm,'HH24:MI:SS')), district, mrt_indicator, movement_count, security_count, source_system, filler
        FROM t$temp_result
        WHERE discharge_dtm = (SELECT
            MAX(discharge_dtm)
            FROM t$temp_result);
    /* --order by discharge_dtm desc */
    return next p_refcur;
END;
$function$
;

ALTER FUNCTION "pass_hkpmi_discharged_cases" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
