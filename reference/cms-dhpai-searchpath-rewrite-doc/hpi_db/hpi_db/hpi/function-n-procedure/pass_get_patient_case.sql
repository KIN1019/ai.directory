-- DROP PROCEDURE hpi.pass_get_patient_case(inout int4, in varchar, in varchar, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.pass_get_patient_case(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_case_no character varying DEFAULT NULL::character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_c_patient_key VARCHAR(16);
    var_error_msg VARCHAR(255);
    var_rowcount INTEGER;
    var_error INTEGER;
    var_pin VARCHAR(24);
    var_pin_len INTEGER;
    sql$rowcount BIGINT;
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
            INTO par_case_no;
    ELSE
        SELECT
            var_pin
            INTO par_case_no;
    END IF;

    IF par_case_no IS NOT NULL THEN
        BEGIN
            BEGIN
                SELECT
                    patient_key
                    INTO var_c_patient_key
                    FROM cpi_case
                    WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF (var_error != 0) OR (var_rowcount = 0) THEN
                BEGIN
                    pas_return_code := 200123;
                    RAISE EXCEPTION 'Case not found!';
                END;
            END IF;
        END;
    END IF;
    SELECT
        LTRIM(RTRIM(par_hkid))
        INTO var_pin;
    SELECT
        OCTET_LENGTH(var_pin)
        INTO var_pin_len;

    IF var_pin_len = 8 THEN
        SELECT
            CONCAT(' ', var_pin)
            INTO par_hkid;
    ELSE
        SELECT
            var_pin
            INTO par_hkid;
    END IF;
   
    DROP TABLE IF EXISTS t$temp_result;
    CREATE TEMPORARY TABLE t$temp_result
    (
        /* --Patient */
        patient_key VARCHAR(24),
        hkid VARCHAR(24),
        other_doc_no VARCHAR(24) NULL,
        patient_name VARCHAR(96),
        sex VARCHAR(2),
        dob VARCHAR(20) NULL,
        exact_dob_flag VARCHAR(2),
        death_indicator VARCHAR(2) NULL,
        death_date VARCHAR(20) NULL,
        unicode_int1 INTEGER NULL,
        unicode_int2 INTEGER NULL,
        unicode_int3 INTEGER NULL,
        unicode_int4 INTEGER NULL,
        unicode_int5 INTEGER NULL,
        unicode_int6 INTEGER NULL,
        home_phone VARCHAR(20) NULL,
        office_phone VARCHAR(20) NULL,
        office_phone_ext VARCHAR(8) NULL,
        other_phone VARCHAR(20) NULL,
        other_phone_ext VARCHAR(8) NULL,
        marital_status VARCHAR(2),
        race VARCHAR(4),
        religion VARCHAR(6) NULL,
        access_code INTEGER,
        /* --Case */
        hospital_code VARCHAR(6) NULL,
        mrn VARCHAR(16) NULL,
        case_no VARCHAR(24) NULL,
        case_type VARCHAR(2) NULL,
        admission_dtm VARCHAR(38) NULL,
        source_indicator VARCHAR(2) NULL,
        source_code VARCHAR(6) NULL,
        discharge_dtm VARCHAR(38) NULL,
        destination_code VARCHAR(10) NULL,
        last_specialty_code VARCHAR(8) NULL,
        last_ward_code VARCHAR(8) NULL,
        last_ward_class VARCHAR(2) NULL,
        last_bed_no VARCHAR(10) NULL,
        discharge_code VARCHAR(2) NULL,
        discharge_description VARCHAR(80) NULL,
        discharge_short_description VARCHAR(10) NULL,
        source_description VARCHAR(100) NULL,
        /* --Referring Doctor */
        pp_code VARCHAR(16) NULL,
        pp_name VARCHAR(96) NULL,
        pp_hkma_code VARCHAR(2) NULL,
        pp_first_name VARCHAR(160) NULL,
        pp_last_name VARCHAR(160) NULL
    /* --Preferred Language */
    /* language_code         VARCHAR(5) null, */
    /* language              varchar(50) null */
    );
    /* --Patient */
    insert into t$temp_result
            (patient_key, hkid, other_doc_no,
             patient_name, sex,
             dob, exact_dob_flag, death_indicator, death_date,
             unicode_int1,
             unicode_int2,
             unicode_int3,
             unicode_int4,
             unicode_int5,
             unicode_int6,
             home_phone,
             office_phone,
             office_phone_ext,
             other_phone,
             other_phone_ext,
             marital_status, race, religion,
             access_code
            )
    	select rtrim(patient_key) patient_key, rtrim(hkid) hkid, other_doc_no,
            rtrim(patient_name) patient_name, sex,
    	to_char(dob, 'dd-mm-yyyy') as dob, exact_dob_flag,
    	death_indicator, to_char(death_date, 'dd-mm-yyyy') as death_date,
    	c1.unicode_int unicode_int1,
    	c2.unicode_int unicode_int2,
    	c3.unicode_int unicode_int3,
    	c4.unicode_int unicode_int4,
    	c5.unicode_int unicode_int5,
    	c6.unicode_int unicode_int6,
        phone1,
	    phone2,
	    address_indicator,
	    mobile_phone,
	    sms_language,
        marital_status, race, religion,
        access_code & 1
    
        from cpi_patient p
			LEFT OUTER JOIN ccc_unicode AS c1 ON SAFE_SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SAFE_SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
			LEFT OUTER JOIN ccc_unicode AS c2 ON SAFE_SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SAFE_SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
			LEFT OUTER JOIN ccc_unicode AS c3 ON SAFE_SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SAFE_SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
			LEFT OUTER JOIN ccc_unicode AS c4 ON SAFE_SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SAFE_SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
			LEFT OUTER JOIN ccc_unicode AS c5 ON SAFE_SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SAFE_SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
			LEFT OUTER JOIN ccc_unicode AS c6 ON SAFE_SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SAFE_SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
    	where hkid = par_hkid;
    /* --MRN */
    UPDATE t$temp_result as tmp
    SET mrn = p.mrn
    FROM cpi_patient_hospital_data AS p
        WHERE tmp.patient_key = p.patient_key AND p.hospital_code = par_hospital_code;
    /* --Case */
	update t$temp_result as tmp
    set hospital_code         = par_hospital_code,
      case_no             = c.case_no,
      case_type           = c.case_type,
      admission_dtm       = to_char(c.admission_dtm, 'dd-mm-yyyy HH24:mi:ss'),
      source_indicator    = c.source_indicator,
      source_code         = c.source_code,
      discharge_dtm       = to_char(c.discharge_dtm, 'dd-mm-yyyy HH24:mi:ss'),
      destination_code    = c.destination_code,
      last_specialty_code = c.last_specialty,
      last_ward_code      = c.last_ward_code,
      last_ward_class     = c.last_ward_class,
      last_bed_no         = c.last_bed_no,
      discharge_code      = c.discharge_code,
      discharge_description = d.description,
      discharge_short_description = d.short_description,
      source_description    = s.description,
      --Referring Doctor
      pp_code             = c.pp_code
	from cpi_case as c
	LEFT JOIN discharge_type as d on c.discharge_code = d.discharge_code
	LEFT JOIN source as s on c.source_indicator = s.source_indicator
    where c.hospital_code = par_hospital_code
    and c.case_no = par_case_no;

    IF par_case_no LIKE 'SOPD%' THEN /* --simulate to call getSopdCaseWithPatientByCaseNoSpecialty from PAS_COMMON_SERVICE */
        BEGIN
            UPDATE t$temp_result
            SET pp_code = ' ';
            UPDATE t$temp_result AS tmp
            SET pp_code = o.pp_code
            FROM opas_pp_by_specialty AS o
                WHERE o.hospital_code = par_hospital_code AND o.case_no = par_case_no AND o.specialty = tmp.last_specialty_code AND tmp.case_no = o.case_no AND tmp.hospital_code = o.hospital_code;
        END;
    END IF;
    /* --Referring Doctor  --simulate to call getHospitalCaseWithPatientByCaseNo from PAS_COMMON_SERVICE */
    UPDATE t$temp_result AS tmp
    SET pp_name = p.pp_name, pp_hkma_code = p.hkma_code, pp_first_name = p.first_name, pp_last_name = p.last_name
    FROM pp AS p
        WHERE tmp.pp_code = p.pp_code;
    /* --Preferred Language can be retrieved from HKPMI only */
    OPEN p_refcur FOR
    /* --Patient */
    SELECT
        patient_key, hkid, other_doc_no, patient_name, sex, dob, exact_dob_flag, death_indicator, death_date, unicode_int1, unicode_int2, unicode_int3, unicode_int4, unicode_int5, unicode_int6, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, marital_status, race, religion, access_code,
        /* --Case */
        hospital_code, mrn, case_no, case_type, admission_dtm, source_indicator, source_code, discharge_dtm, destination_code, last_specialty_code, last_ward_code, last_ward_class, last_bed_no,
        /* --Referring Doctor */
        pp_code, pp_name, pp_hkma_code, pp_first_name, pp_last_name,
        /* --IPAS-618 */
        discharge_code, discharge_description, discharge_short_description, source_description
        FROM t$temp_result;

END;
$procedure$
;

;ALTER PROCEDURE "pass_get_patient_case" OWNER TO "HPI_SCHEMA_OWNER_ROLE";