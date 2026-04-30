-- DROP FUNCTION download.pas_get_pmi_trx_v2_lt(varchar);

CREATE OR REPLACE FUNCTION download.pas_get_pmi_trx_v2_lt(par_last_poll_mark character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
    var_curr_dt TIMESTAMP WITHOUT TIME ZONE;
    var_last_poll_mark_in_dt TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    /* 2011-08-08 Sam - Enhancement to limit the transaction volume to a reasonable value - START */
    SELECT
        timestamp_convert(localtimestamp), CAST (CONCAT(SUBSTRING(par_last_poll_mark, 1, 8), ' ', SUBSTRING(par_last_poll_mark, 9, 2), ':', SUBSTRING(par_last_poll_mark, 11, 2), ':', SUBSTRING(par_last_poll_mark, 13, 6)) AS TIMESTAMP WITHOUT TIME ZONE)
        INTO var_curr_dt, var_last_poll_mark_in_dt;
    /* 2011-04-13 Sam - Use #temp table instead of real table - START */
    /* DELETE FROM transaction_log_tobar */
    DROP TABLE IF EXISTS t$transaction_log_tobar;
    CREATE TEMPORARY TABLE t$transaction_log_tobar
    ("system_dtm" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        "hospital_code" CHAR(3) NOT NULL,
        "type" CHAR(3) NOT NULL,
        "adm_dtm" TIMESTAMP WITHOUT TIME ZONE NULL,
        "hkid" CHAR(12) NULL,
        "patient_key" CHAR(8) NULL,
        "patient_name" CHAR(48) NULL,
        "sex" CHAR(1) NULL,
        "dob" TIMESTAMP WITHOUT TIME ZONE NULL,
        "exact_dob_flag" CHAR(1) NULL,
        "cccode1" CHAR(5) NULL,
        "cccode2" CHAR(5) NULL,
        "cccode3" CHAR(5) NULL,
        "cccode4" CHAR(5) NULL,
        "cccode5" CHAR(5) NULL,
        "cccode6" CHAR(5) NULL,
        "chi_name" CHAR(12) NULL,
        "marital_status" CHAR(1) NULL,
        "race" CHAR(2) NULL,
        "other_doc_no" CHAR(12) NULL,
        "mrn" CHAR(8) NULL,
        "building" CHAR(47) NULL,
        "room" CHAR(5) NULL,
        "floor" CHAR(2) NULL,
        "block" CHAR(2) NULL,
        "district" CHAR(5) NULL,
        "religion" CHAR(3) NULL,
        "home_phone" CHAR(10) NULL,
        "office_phone" CHAR(10) NULL,
        "office_phone_ext" CHAR(4) NULL,
        "other_phone" CHAR(10) NULL,
        "other_phone_ext" CHAR(4) NULL,
        "death_indicator" CHAR(4) NULL,
        "death_date" TIMESTAMP WITHOUT TIME ZONE NULL,
        "death_external_cause" CHAR(4) NULL,
        "death_diagnosis" CHAR(4) NULL,
        "pcs_count" INTEGER NULL,
        "priority" INTEGER NULL,
        "major_nok" CHAR(1) NULL,
        "nok_name" CHAR(48) NULL,
        "nok_hkid" CHAR(12) NULL,
        "nok_relationship" CHAR(2) NULL,
        "nok_building" CHAR(47) NULL,
        "nok_room" CHAR(5) NULL,
        "nok_floor" CHAR(2) NULL,
        "nok_block" CHAR(2) NULL,
        "nok_district" CHAR(5) NULL,
        "nok_home_phone" CHAR(10) NULL,
        "nok_office_phone" CHAR(10) NULL,
        "nok_office_phone_ext" CHAR(4) NULL,
        "nok_other_phone" CHAR(10) NULL,
        "nok_other_phone_ext" CHAR(4) NULL,
        "case_no" CHAR(12) NULL,
        "source_indicator" CHAR(1) NULL,
        "source_code" CHAR(3) NULL,
        "patient_type" CHAR(3) NULL,
        "discharge_code" CHAR(1) NULL,
        "destination_code" CHAR(5) NULL,
        "case_type" CHAR(1) NULL,
        "security_count" INTEGER NULL,
        "case_access_code" INTEGER NULL,
        "pmi_access_code" INTEGER NULL,
        "ambulance_no" CHAR(4) NULL,
        "police_case" CHAR(1) NULL,
        "labour_case" CHAR(1) NULL,
        "ae_case_type" CHAR(1) NULL,
        "dba" CHAR(1) NULL,
        "ward_code" CHAR(4) NULL,
        "specialty_code" CHAR(4) NULL,
        "bed_no" CHAR(5) NULL,
        "ward_class" CHAR(1) NULL,
        "old_patient_key" CHAR(8) NULL,
        "old_patient_name" CHAR(48) NULL,
        "old_hkid" CHAR(12) NULL,
        "old_sex" CHAR(1) NULL,
        "old_dob" TIMESTAMP WITHOUT TIME ZONE NULL,
        "old_ward_class" CHAR(1) NULL,
        "old_ward_code" CHAR(4) NULL,
        "old_specialty_code" CHAR(4) NULL,
        "old_bed_no" CHAR(5) NULL,
        "pp_code" CHAR(8) NULL,
        "update_by" CHAR(12) NOT NULL,
        "update_hospital" CHAR(3) NOT NULL,
        "source_system" CHAR(5) NOT NULL,
        "source_system_dtm" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        "upload_status" CHAR(1) NOT NULL,
        "filler" VARCHAR(30) NULL,
        "timestamp"   				timestamp(6)  	NULL,
        "doctor_code" CHAR(8) NULL,
        "mrt_indicator" CHAR(1) NULL,
        "transfer_dtm" TIMESTAMP WITHOUT TIME ZONE NULL,
        "discharge_dtm" TIMESTAMP WITHOUT TIME ZONE NULL,
        "update_type" CHAR(3) NULL /* 2011-11-16 Sam - Add an indicator to distinguish the type of txn type 121: either is to update admission datetime or other */);
    /* 2011-04-13 Sam - Use #temp table instead of real table - END */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 800 clause of SET statement is not supported. Perform a manual conversion.]
    SET ROWCOUNT 800
    */
    /* 2011-04-13 Sam - Use #temp table instead of real table - START */
    /* INSERT INTO transaction_log_tobar ( */
    INSERT INTO t$transaction_log_tobar
    /* 2011-04-13 Sam - Use #temp table instead of real table - END */
    (system_dtm, hospital_code, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_external_cause, death_diagnosis, pcs_count, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_home_phone, nok_office_phone, nok_office_phone_ext, nok_other_phone, nok_other_phone_ext, case_no, source_indicator, source_code, patient_type, discharge_code, destination_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba, ward_code, specialty_code, bed_no, ward_class, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, pp_code, update_by, update_hospital, source_system, source_system_dtm, upload_status, filler, "timestamp", doctor_code, mrt_indicator, transfer_dtm, discharge_dtm, update_type /* 2011-11-16 Sam - Add an indicator to distinguish the type of txn type 121: either is to update admission datetime or other */)
    SELECT
        system_dtm, hospital_code, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_external_cause, death_diagnosis, pcs_count, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_home_phone, nok_office_phone, nok_office_phone_ext, nok_other_phone, nok_other_phone_ext, case_no, source_indicator, source_code, patient_type, discharge_code, destination_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba, ward_code, specialty_code, bed_no, ward_class, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, pp_code, update_by, update_hospital, source_system, source_system_dtm, upload_status, filler, "timestamp", doctor_code, mrt_indicator, transfer_dtm, discharge_dtm, '' /* 2011-11-16 Sam - Add an indicator to distinguish the type of txn type 121: either is to update admission datetime or other */
        FROM transaction_log AS a
        /* 2011-08-08 Sam - Enhancement to limit the transaction volume to a reasonable value - START */
        /* WHERE a.system_dtm > CONVERT(datetime, SUBSTRING(@last_poll_mark, 1, 8) + ' ' + SUBSTRING(@last_poll_mark, 9, 2) + ':' + SUBSTRING(@last_poll_mark, 11, 2) + ':' + SUBSTRING(@last_poll_mark, 13, 6)) */
        WHERE a.system_dtm > var_last_poll_mark_in_dt AND a.system_dtm <= var_curr_dt AND
        /* 2011-08-08 Sam - Enhancement to limit the transaction volume to a reasonable value - END */
        /* 2013-10-29 Sam - Enhancement to include 033 transaction issued by DR - START */
        /* AND   a.hospital_code = a.update_hospital */
        (a.hospital_code = a.update_hospital OR a.update_hospital = 'DR')
        /* 2013-10-29 Sam - Enhancement to include 033 transaction issued by DR - END */
        ORDER BY a.system_dtm NULLS FIRST;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
    SET ROWCOUNT 0
    */
    PERFORM pg_sleep(16);
    /* Handle 261 Update Month-Baby Link - Start */
    /* 2011-04-13 Sam - Use #temp table instead of real table - START */
    /* INSERT INTO transaction_log_tobar ( */
    INSERT INTO t$transaction_log_tobar
    /* 2011-04-13 Sam - Use #temp table instead of real table - END */
    (system_dtm, hospital_code, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_external_cause, death_diagnosis, pcs_count, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_home_phone, nok_office_phone, nok_office_phone_ext, nok_other_phone, nok_other_phone_ext, case_no, source_indicator, source_code, patient_type, discharge_code, destination_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba, ward_code, specialty_code, bed_no, ward_class, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, pp_code, update_by, update_hospital, source_system, source_system_dtm, upload_status, filler, "timestamp", doctor_code, mrt_indicator, transfer_dtm, discharge_dtm, update_type /* 2011-11-16 Sam - Add an indicator to distinguish the type of txn type 121: either is to update admission datetime or other */)
    SELECT
        system_dtm, hospital_code, '262', adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_external_cause, death_diagnosis, pcs_count, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_home_phone, nok_office_phone, nok_office_phone_ext, nok_other_phone, nok_other_phone_ext, case_no, source_indicator, source_code, patient_type, discharge_code, destination_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba, ward_code, specialty_code, bed_no, ward_class, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, pp_code, update_by, update_hospital, source_system, source_system_dtm, upload_status, filler, "timestamp", doctor_code, mrt_indicator, transfer_dtm, discharge_dtm, '' /* 2011-11-16 Sam - Add an indicator to distinguish the type of txn type 121: either is to update admission datetime or other */
        /* 2011-04-13 Sam - Use #temp table instead of real table - START */
        /* FROM transaction_log_tobar */
        FROM t$transaction_log_tobar
        /* 2011-04-13 Sam - Use #temp table instead of real table - END */
        WHERE type = '261';
    /* 2011-04-13 Sam - Use #temp table instead of real table - START */
    /* INSERT INTO transaction_log_tobar ( */
    INSERT INTO t$transaction_log_tobar
    /* 2011-04-13 Sam - Use #temp table instead of real table - END */
    (system_dtm, hospital_code, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_external_cause, death_diagnosis, pcs_count, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_home_phone, nok_office_phone, nok_office_phone_ext, nok_other_phone, nok_other_phone_ext, case_no, source_indicator, source_code, patient_type, discharge_code, destination_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba, ward_code, specialty_code, bed_no, ward_class, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, pp_code, update_by, update_hospital, source_system, source_system_dtm, upload_status, filler, "timestamp", doctor_code, mrt_indicator, transfer_dtm, discharge_dtm, update_type /* 2011-11-16 Sam - Add an indicator to distinguish the type of txn type 121: either is to update admission datetime or other */)
    SELECT
        system_dtm, hospital_code, '260', adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_external_cause, death_diagnosis, pcs_count, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_home_phone, nok_office_phone, nok_office_phone_ext, nok_other_phone, nok_other_phone_ext, case_no, source_indicator, source_code, patient_type, discharge_code, destination_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba, ward_code, specialty_code, bed_no, ward_class, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, pp_code, update_by, update_hospital, source_system, source_system_dtm, upload_status, filler, "timestamp", doctor_code, mrt_indicator, transfer_dtm, discharge_dtm, '' /* 2011-11-16 Sam - Add an indicator to distinguish the type of txn type 121: either is to update admission datetime or other */
        /* 2011-04-13 Sam - Use #temp table instead of real table - START */
        /* FROM transaction_log_tobar */
        FROM t$transaction_log_tobar
        /* 2011-04-13 Sam - Use #temp table instead of real table - END */
        WHERE type = '261';
    /* 2011-04-13 Sam - Use #temp table instead of real table - START */
    /* DELETE FROM transaction_log_tobar */
    DELETE FROM t$transaction_log_tobar
        WHERE type = '261';
    /* 2011-04-13 Sam - Use #temp table instead of real table - END */
    /* Handle 261 Update Month-Baby Link - END */
    /* 2011-04-14 Sam - Txn type 100 use A01 if case_type = 'I', A04 otherwise - START */
    UPDATE t$transaction_log_tobar
    SET "type" = '10X'
        WHERE type = '100' AND case_type <> 'I';
    /* 2011-04-14 Sam - Txn type 100 use A01 if case_type = 'I', A04 otherwise - END */
    /* 2011-11-16 Sam - Add an indicator to distinguish the type of txn type 121: either is to update admission datetime or other - START */
    UPDATE t$transaction_log_tobar
    SET "update_type" = (SELECT
        CASE c.movement_count
            WHEN 1 THEN 'A'
            ELSE 'O'
        END
        FROM hkpmi_dbo.pmi_case AS c
        WHERE c.hospital_code = t$transaction_log_tobar.hospital_code AND c.case_no = t$transaction_log_tobar.case_no)
        WHERE t$transaction_log_tobar.type = '121' AND system_dtm < '20130109'; /* 2013-01-08 Sam - Enhancement on update_type of 121: uses new table hkpmi_pas_bar_ind */
    /* 2011-11-16 Sam - Add an indicator to distinguish the type of txn type 121: either is to update admission datetime or other - END */
    /* 2013-01-08 Sam - Enhancement on update_type of 121: uses new table hkpmi_pas_bar_ind - START */
    UPDATE t$transaction_log_tobar
    SET "update_type" = (SELECT
        COALESCE(h.txn_type_ind, 'O')
        FROM hkpmi_dbo.hkpmi_pas_bar_ind AS h
        WHERE h.hospital_code = t$transaction_log_tobar.hospital_code AND h.system_dtm = t$transaction_log_tobar.system_dtm AND h.case_no = t$transaction_log_tobar.case_no)
        WHERE t$transaction_log_tobar.type = '121' AND system_dtm >= '20130109';
    /* ---20130119 -- No records found in hkpmi_pas_bar_ind --- */
    UPDATE t$transaction_log_tobar
    SET "update_type" = (SELECT
        CASE c.movement_count
            WHEN 1 THEN 'A'
            ELSE 'O'
        END
        FROM hkpmi_dbo.pmi_case AS c
        WHERE c.hospital_code = t$transaction_log_tobar.hospital_code AND c.case_no = t$transaction_log_tobar.case_no)
        WHERE t$transaction_log_tobar.type = '121' AND (update_type IS NULL OR LTRIM(RTRIM(update_type)) = '');
    /* --	UPDATE #transaction_log_tobar */
    /* --	SET update_type = 'O' */
    /* --	WHERE #transaction_log_tobar.type = '121' */
    /* --	AND (update_type IS NULL OR ltrim(rtrim(update_type)) = '') */
    /* 2013-01-08 Sam - Enhancement on update_type of 121: uses new table hkpmi_pas_bar_ind - END */
    /* 2012-06-25 Sam - Include admission datetme in A45 message for Txn type 040 - START */
    UPDATE t$transaction_log_tobar
    SET "adm_dtm" = c.adm_dtm
    FROM hkpmi_dbo.pmi_case AS c
        WHERE t$transaction_log_tobar.type = '040' AND t$transaction_log_tobar.hospital_code = c.hospital_code AND t$transaction_log_tobar.case_no = c.case_no;
    /* 2012-06-25 Sam - Include admission datetme in A45 message for Txn type 040 - END */
    /* 2011-07-13 Sam - Minor enhancement before production release - START */
    PERFORM pg_sleep(0); /* to prevent CPU 100% loading */
    /* 2011-07-13 Sam - Minor enhancement before production release - END */
    OPEN p_refcur FOR
    SELECT
        CASE m.hospital_code
            WHEN 'M' THEN COALESCE(CASE a."hospital_code"
                WHEN '' THEN '""'
                ELSE a."hospital_code"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."hospital_code"
                WHEN '' THEN '""'
                ELSE a."hospital_code"
            END, '""')
            ELSE ''
        END AS hospital_code, COALESCE(CASE m.system_dtm
            WHEN 'M' THEN CONCAT(to_char(a."system_dtm"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), '.', SUBSTRING(CAST (date_part('millisecond', a."system_dtm"::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3))
            WHEN 'R' THEN CONCAT(to_char(a."system_dtm"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), '.', SUBSTRING(CAST (date_part('millisecond', a."system_dtm"::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3))
            ELSE ''
        END, '""') AS transaction_datetime,
        CASE m.type
            WHEN 'M' THEN COALESCE(CASE a."type"
                WHEN '' THEN '""'
                ELSE a."type"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."type"
                WHEN '' THEN '""'
                ELSE a."type"
            END, '""')
            ELSE ''
        END AS transaction_type,
        CASE m.hkid
            WHEN 'M' THEN COALESCE(CASE a."hkid"
                WHEN '' THEN '""'
                ELSE a."hkid"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."hkid"
                WHEN '' THEN '""'
                ELSE a."hkid"
            END, '""')
            ELSE ''
        END AS hkid,
        CASE m.patient_key
            WHEN 'M' THEN COALESCE(CASE a."patient_key"
                WHEN '' THEN '""'
                ELSE a."patient_key"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."patient_key"
                WHEN '' THEN '""'
                ELSE a."patient_key"
            END, '""')
            ELSE ''
        END AS patient_key,
        CASE m.patient_name
            WHEN 'M' THEN COALESCE(CASE a."patient_name"
                WHEN '' THEN '""'
                ELSE a."patient_name"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."patient_name"
                WHEN '' THEN '""'
                ELSE a."patient_name"
            END, '""')
            ELSE ''
        END AS patient_name,
        CASE m.sex
            WHEN 'M' THEN COALESCE(CASE a."sex"
                WHEN '' THEN '""'
                ELSE a."sex"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."sex"
                WHEN '' THEN '""'
                ELSE a."sex"
            END, '""')
            ELSE ''
        END AS sex,
        CASE m.dob
            WHEN 'M' THEN COALESCE(to_char(a."dob"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), '""')
            WHEN 'R' THEN COALESCE(to_char(a."dob"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), '""')
            ELSE ''
        END AS dob,
        CASE m.exact_dob_flag
            WHEN 'M' THEN COALESCE(CASE a."exact_dob_flag"
                WHEN '' THEN '""'
                ELSE a."exact_dob_flag"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."exact_dob_flag"
                WHEN '' THEN '""'
                ELSE a."exact_dob_flag"
            END, '""')
            ELSE ''
        END AS exact_dob_flag,
        CASE m.cccode1
            WHEN 'M' THEN COALESCE(CASE a."cccode1"
                WHEN '' THEN '""'
                ELSE a."cccode1"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."cccode1"
                WHEN '' THEN '""'
                ELSE a."cccode1"
            END, '""')
            ELSE ''
        END AS ccc1,
        CASE m.cccode2
            WHEN 'M' THEN COALESCE(CASE a."cccode2"
                WHEN '' THEN '""'
                ELSE a."cccode2"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."cccode2"
                WHEN '' THEN '""'
                ELSE a."cccode2"
            END, '""')
            ELSE ''
        END AS ccc2,
        CASE m.cccode3
            WHEN 'M' THEN COALESCE(CASE a."cccode3"
                WHEN '' THEN '""'
                ELSE a."cccode3"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."cccode3"
                WHEN '' THEN '""'
                ELSE a."cccode3"
            END, '""')
            ELSE ''
        END AS ccc3,
        CASE m.cccode4
            WHEN 'M' THEN COALESCE(CASE a."cccode4"
                WHEN '' THEN '""'
                ELSE a."cccode4"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."cccode4"
                WHEN '' THEN '""'
                ELSE a."cccode4"
            END, '""')
            ELSE ''
        END AS ccc4,
        CASE m.cccode5
            WHEN 'M' THEN COALESCE(CASE a."cccode5"
                WHEN '' THEN '""'
                ELSE a."cccode5"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."cccode5"
                WHEN '' THEN '""'
                ELSE a."cccode5"
            END, '""')
            ELSE ''
        END AS ccc5,
        CASE m.cccode6
            WHEN 'M' THEN COALESCE(CASE a."cccode6"
                WHEN '' THEN '""'
                ELSE a."cccode6"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."cccode6"
                WHEN '' THEN '""'
                ELSE a."cccode6"
            END, '""')
            ELSE ''
        END AS ccc6,
        CASE m.chi_name
            WHEN 'M' THEN COALESCE(CASE a."chi_name"
                WHEN '' THEN '""'
                ELSE a."chi_name"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."chi_name"
                WHEN '' THEN '""'
                ELSE a."chi_name"
            END, '""')
            ELSE ''
        END AS chi_name,
        CASE m.marital_status
            WHEN 'M' THEN COALESCE(CASE a."marital_status"
                WHEN '' THEN '""'
                ELSE a."marital_status"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."marital_status"
                WHEN '' THEN '""'
                ELSE a."marital_status"
            END, '""')
            ELSE ''
        END AS marital_status,
        CASE m.race
            WHEN 'M' THEN COALESCE(CASE a."race"
                WHEN '' THEN '""'
                ELSE a."race"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."race"
                WHEN '' THEN '""'
                ELSE a."race"
            END, '""')
            ELSE ''
        END AS race_code,
        CASE m.other_doc_no
            WHEN 'M' THEN COALESCE(CASE a."other_doc_no"
                WHEN '' THEN '""'
                ELSE a."other_doc_no"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."other_doc_no"
                WHEN '' THEN '""'
                ELSE a."other_doc_no"
            END, '""')
            ELSE ''
        END AS other_document_no, '' AS reference,
        CASE m.mrn
            WHEN 'M' THEN COALESCE(CASE a."mrn"
                WHEN '' THEN '""'
                ELSE a."mrn"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."mrn"
                WHEN '' THEN '""'
                ELSE a."mrn"
            END, '""')
            ELSE ''
        END AS medical_record_number, '' AS remark,
        CASE m.room
            WHEN 'M' THEN COALESCE(CASE a."room"
                WHEN '' THEN '""'
                ELSE a."room"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."room"
                WHEN '' THEN '""'
                ELSE a."room"
            END, '""')
            ELSE ''
        END AS room,
        CASE m.floor
            WHEN 'M' THEN COALESCE(CASE a."floor"
                WHEN '' THEN '""'
                ELSE a."floor"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."floor"
                WHEN '' THEN '""'
                ELSE a."floor"
            END, '""')
            ELSE ''
        END AS floor,
        CASE m.block
            WHEN 'M' THEN COALESCE(CASE a."block"
                WHEN '' THEN '""'
                ELSE a."block"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."block"
                WHEN '' THEN '""'
                ELSE a."block"
            END, '""')
            ELSE ''
        END AS block,
        CASE m.district
            WHEN 'M' THEN COALESCE(CASE a."district"
                WHEN '' THEN '""'
                ELSE a."district"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."district"
                WHEN '' THEN '""'
                ELSE a."district"
            END, '""')
            ELSE ''
        END AS district_code,
        CASE m.building
            WHEN 'M' THEN COALESCE(CASE
                WHEN a."building" LIKE 'HACODE%' THEN ''
                WHEN a."building" = '' THEN '""'
                ELSE a."building"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE
                WHEN a."building" LIKE 'HACODE%' THEN ''
                WHEN a."building" = '' THEN '""'
                ELSE a."building"
            END, '""')
            ELSE ''
        END AS building,
        CASE m.building
            WHEN 'M' THEN COALESCE(CASE
                WHEN a."building" LIKE 'HACODE%' THEN a."building"
                ELSE ''
            END, '""')
            WHEN 'R' THEN COALESCE(CASE
                WHEN a."building" LIKE 'HACODE%' THEN a."building"
                ELSE ''
            END, '""')
            ELSE ''
        END AS hacode,
        /*
        CASE WHEN building LIKE 'HACODE%' THEN ''
                		ELSE building END building,
                  CASE WHEN building LIKE 'HACODE%' THEN (select rtrim(bldg_eng)
                  		from tmhopas_db..address_detail a, tmhopas_db..district b, tmhopas_db..district_area c
        				where record_id = CONVERT(int, SUBSTRING(building, 8, 10))
                 		and a.district_code = b.code
                		and b.area = c.area_code)
                		ELSE '' END building_eng,
        		CASE WHEN building LIKE 'HACODE%' THEN (select rtrim(estate_eng)
                  		from tmhopas_db..address_detail a, tmhopas_db..district b, tmhopas_db..district_area c
        				where record_id = CONVERT(int, SUBSTRING(building, 8, 10))
                 		and a.district_code = b.code
                		and b.area = c.area_code)
                		ELSE '' END estate_eng,
                CASE WHEN building LIKE 'HACODE%' THEN (select rtrim(house_no)
                  		from tmhopas_db..address_detail a, tmhopas_db..district b, tmhopas_db..district_area c
        				where record_id = CONVERT(int, SUBSTRING(building, 8, 10))
                 		and a.district_code = b.code
                		and b.area = c.area_code)
                		ELSE '' END house_no,
                CASE WHEN building LIKE 'HACODE%' THEN (select rtrim(street_eng)
                  		from tmhopas_db..address_detail a, tmhopas_db..district b, tmhopas_db..district_area c
        				where record_id = CONVERT(int, SUBSTRING(building, 8, 10))
                 		and a.district_code = b.code
                		and b.area = c.area_code)
                		ELSE '' END street_eng,
        */
        CASE m.religion
            WHEN 'M' THEN COALESCE(CASE a."religion"
                WHEN '' THEN '""'
                ELSE a."religion"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."religion"
                WHEN '' THEN '""'
                ELSE a."religion"
            END, '""')
            ELSE ''
        END AS religion_code,
        CASE m.home_phone
            WHEN 'M' THEN COALESCE(CASE a."home_phone"
                WHEN '' THEN '""'
                ELSE a."home_phone"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."home_phone"
                WHEN '' THEN '""'
                ELSE a."home_phone"
            END, '""')
            ELSE ''
        END AS home_phone_no,
        CASE m.office_phone
            WHEN 'M' THEN COALESCE(CASE a."office_phone"
                WHEN '' THEN '""'
                ELSE a."office_phone"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."office_phone"
                WHEN '' THEN '""'
                ELSE a."office_phone"
            END, '""')
            ELSE ''
        END AS other_phone_no_1,
        CASE m.office_phone_ext
            WHEN 'M' THEN COALESCE(CASE a."office_phone_ext"
                WHEN '' THEN '""'
                ELSE a."office_phone_ext"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."office_phone_ext"
                WHEN '' THEN '""'
                ELSE a."office_phone_ext"
            END, '""')
            ELSE ''
        END AS other_phone_ext_1,
        CASE m.other_phone
            WHEN 'M' THEN COALESCE(CASE a."other_phone"
                WHEN '' THEN '""'
                ELSE a."other_phone"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."other_phone"
                WHEN '' THEN '""'
                ELSE a."other_phone"
            END, '""')
            ELSE ''
        END AS other_phone_no_2,
        CASE m.other_phone_ext
            WHEN 'M' THEN COALESCE(CASE a."other_phone_ext"
                WHEN '' THEN '""'
                ELSE a."other_phone_ext"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."other_phone_ext"
                WHEN '' THEN '""'
                ELSE a."other_phone_ext"
            END, '""')
            ELSE ''
        END AS other_phone_ext_2,
        CASE m.death_indicator
            WHEN 'M' THEN COALESCE(CASE a."death_indicator"
                WHEN '' THEN '""'
                ELSE a."death_indicator"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."death_indicator"
                WHEN '' THEN '""'
                ELSE a."death_indicator"
            END, '""')
            ELSE ''
        END AS death_indicator,
        CASE m.death_date
            WHEN 'M' THEN COALESCE(to_char(a."death_date"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), '""')
            WHEN 'R' THEN COALESCE(to_char(a."death_date"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), '""')
            ELSE ''
        END AS death_date,
        CASE m.death_external_cause
            WHEN 'M' THEN COALESCE(CASE a."death_external_cause"
                WHEN '' THEN '""'
                ELSE a."death_external_cause"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."death_external_cause"
                WHEN '' THEN '""'
                ELSE a."death_external_cause"
            END, '""')
            ELSE ''
        END AS death_external_cause,
        CASE m.death_diagnosis
            WHEN 'M' THEN COALESCE(CASE a."death_diagnosis"
                WHEN '' THEN '""'
                ELSE a."death_diagnosis"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."death_diagnosis"
                WHEN '' THEN '""'
                ELSE a."death_diagnosis"
            END, '""')
            ELSE ''
        END AS death_diagnosis, '' AS card_holder,
        CASE m.priority
            WHEN 'M' THEN COALESCE(CASE CAST (a."priority" AS CHAR(30))
                WHEN '' THEN '""'
                ELSE CAST (a."priority" AS CHAR(30))
            END, '""')
            WHEN 'R' THEN COALESCE(CASE CAST (a."priority" AS CHAR(30))
                WHEN '' THEN '""'
                ELSE CAST (a."priority" AS CHAR(30))
            END, '""')
            ELSE ''
        END AS priority,
        CASE m.major_nok
            WHEN 'M' THEN COALESCE(CASE a."major_nok"
                WHEN '' THEN '""'
                ELSE a."major_nok"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."major_nok"
                WHEN '' THEN '""'
                ELSE a."major_nok"
            END, '""')
            ELSE ''
        END AS major_nok,
        CASE m.nok_name
            WHEN 'M' THEN COALESCE(CASE a."nok_name"
                WHEN '' THEN '""'
                ELSE a."nok_name"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."nok_name"
                WHEN '' THEN '""'
                ELSE a."nok_name"
            END, '""')
            ELSE ''
        END AS nok_name,
        CASE m.nok_hkid
            WHEN 'M' THEN COALESCE(CASE a."nok_hkid"
                WHEN '' THEN '""'
                ELSE a."nok_hkid"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."nok_hkid"
                WHEN '' THEN '""'
                ELSE a."nok_hkid"
            END, '""')
            ELSE ''
        END AS nok_hkid,
        CASE m.nok_relationship
            WHEN 'M' THEN COALESCE(CASE a."nok_relationship"
                WHEN '' THEN '""'
                ELSE a."nok_relationship"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."nok_relationship"
                WHEN '' THEN '""'
                ELSE a."nok_relationship"
            END, '""')
            ELSE ''
        END AS nok_relation_code,
        CASE m.nok_building
            WHEN 'M' THEN COALESCE(CASE a."nok_building"
                WHEN '' THEN '""'
                ELSE a."nok_building"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."nok_building"
                WHEN '' THEN '""'
                ELSE a."nok_building"
            END, '""')
            ELSE ''
        END AS nok_building,
        CASE m.nok_room
            WHEN 'M' THEN COALESCE(CASE a."nok_room"
                WHEN '' THEN '""'
                ELSE a."nok_room"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."nok_room"
                WHEN '' THEN '""'
                ELSE a."nok_room"
            END, '""')
            ELSE ''
        END AS nok_room,
        CASE m.nok_floor
            WHEN 'M' THEN COALESCE(CASE a."nok_floor"
                WHEN '' THEN '""'
                ELSE a."nok_floor"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."nok_floor"
                WHEN '' THEN '""'
                ELSE a."nok_floor"
            END, '""')
            ELSE ''
        END AS nok_floor,
        CASE m.nok_block
            WHEN 'M' THEN COALESCE(CASE a."nok_block"
                WHEN '' THEN '""'
                ELSE a."nok_block"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."nok_block"
                WHEN '' THEN '""'
                ELSE a."nok_block"
            END, '""')
            ELSE ''
        END AS nok_block,
        CASE m.nok_district
            WHEN 'M' THEN COALESCE(CASE a."nok_district"
                WHEN '' THEN '""'
                ELSE a."nok_district"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."nok_district"
                WHEN '' THEN '""'
                ELSE a."nok_district"
            END, '""')
            ELSE ''
        END AS nok_district_code,
        CASE m.nok_home_phone
            WHEN 'M' THEN COALESCE(CASE a."nok_home_phone"
                WHEN '' THEN '""'
                ELSE a."nok_home_phone"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."nok_home_phone"
                WHEN '' THEN '""'
                ELSE a."nok_home_phone"
            END, '""')
            ELSE ''
        END AS nok_home_phone,
        CASE m.nok_office_phone
            WHEN 'M' THEN COALESCE(CASE a."nok_office_phone"
                WHEN '' THEN '""'
                ELSE a."nok_office_phone"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."nok_office_phone"
                WHEN '' THEN '""'
                ELSE a."nok_office_phone"
            END, '""')
            ELSE ''
        END AS nok_other_phone_no_1,
        CASE m.nok_office_phone_ext
            WHEN 'M' THEN COALESCE(CASE a."nok_office_phone_ext"
                WHEN '' THEN '""'
                ELSE a."nok_office_phone_ext"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."nok_office_phone_ext"
                WHEN '' THEN '""'
                ELSE a."nok_office_phone_ext"
            END, '""')
            ELSE ''
        END AS nok_other_phone_ext_1,
        CASE m.nok_other_phone
            WHEN 'M' THEN COALESCE(CASE a."nok_other_phone"
                WHEN '' THEN '""'
                ELSE a."nok_other_phone"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."nok_other_phone"
                WHEN '' THEN '""'
                ELSE a."nok_other_phone"
            END, '""')
            ELSE ''
        END AS nok_other_phone_no_2,
        CASE m.nok_other_phone_ext
            WHEN 'M' THEN COALESCE(CASE a."nok_other_phone_ext"
                WHEN '' THEN '""'
                ELSE a."nok_other_phone_ext"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."nok_other_phone_ext"
                WHEN '' THEN '""'
                ELSE a."nok_other_phone_ext"
            END, '""')
            ELSE ''
        END AS nok_other_phone_ext_2,
        CASE m.case_no
            WHEN 'M' THEN COALESCE(CASE a."case_no"
                WHEN '' THEN '""'
                ELSE a."case_no"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."case_no"
                WHEN '' THEN '""'
                ELSE a."case_no"
            END, '""')
            ELSE ''
        END AS case_no, COALESCE(CASE m.adm_dtm
            WHEN 'M' THEN CONCAT(to_char(a."adm_dtm"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', a."adm_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', a."adm_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', a."adm_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), '.', SUBSTRING(CAST (date_part('millisecond', a."adm_dtm"::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3))
            WHEN 'R' THEN CONCAT(to_char(a."adm_dtm"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', a."adm_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', a."adm_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', a."adm_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), '.', SUBSTRING(CAST (date_part('millisecond', a."adm_dtm"::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3))
            ELSE ''
        END, '""') AS admission_datetime,
        CASE m.source_indicator
            WHEN 'M' THEN COALESCE(CASE a."source_indicator"
                WHEN '' THEN '""'
                ELSE a."source_indicator"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."source_indicator"
                WHEN '' THEN '""'
                ELSE a."source_indicator"
            END, '""')
            ELSE ''
        END AS source_indicator,
        CASE m.source_code
            WHEN 'M' THEN COALESCE(CASE a."source_code"
                WHEN '' THEN '""'
                ELSE a."source_code"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."source_code"
                WHEN '' THEN '""'
                ELSE a."source_code"
            END, '""')
            ELSE ''
        END AS source_code,
        CASE m.patient_type
            WHEN 'M' THEN COALESCE(CASE a."patient_type"
                WHEN '' THEN '""'
                ELSE a."patient_type"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."patient_type"
                WHEN '' THEN '""'
                ELSE a."patient_type"
            END, '""')
            ELSE ''
        END AS patient_type,
        CASE m.discharge_code
            WHEN 'M' THEN COALESCE(CASE a."discharge_code"
                WHEN '' THEN '""'
                ELSE a."discharge_code"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."discharge_code"
                WHEN '' THEN '""'
                ELSE a."discharge_code"
            END, '""')
            ELSE ''
        END AS discharge_code, COALESCE(CASE m.discharge_dtm
            WHEN 'M' THEN CONCAT(to_char(a."discharge_dtm"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', a."discharge_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', a."discharge_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', a."discharge_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), '.', SUBSTRING(CAST (date_part('millisecond', a."discharge_dtm"::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3))
            WHEN 'R' THEN CONCAT(to_char(a."discharge_dtm"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', a."discharge_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', a."discharge_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', a."discharge_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), '.', SUBSTRING(CAST (date_part('millisecond', a."discharge_dtm"::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3))
            ELSE ''
        END, '""') AS discharge_datetime,
        CASE m.destination_code
            WHEN 'M' THEN COALESCE(CASE a."destination_code"
                WHEN '' THEN '""'
                ELSE a."destination_code"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."destination_code"
                WHEN '' THEN '""'
                ELSE a."destination_code"
            END, '""')
            ELSE ''
        END AS destination_code,
        CASE m.doctor_code
            WHEN 'M' THEN COALESCE(CASE a."doctor_code"
                WHEN '' THEN '""'
                ELSE a."doctor_code"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."doctor_code"
                WHEN '' THEN '""'
                ELSE a."doctor_code"
            END, '""')
            ELSE ''
        END AS doctor_code,
        CASE m.case_type
            WHEN 'M' THEN (CASE COALESCE(a."case_type", 'P')
                WHEN 'A' THEN 'E'
                WHEN 'P' THEN 'P'
                ELSE a."case_type"
            END)
            WHEN 'R' THEN (CASE COALESCE(a."case_type", 'P')
                WHEN 'A' THEN 'E'
                WHEN 'P' THEN 'P'
                ELSE a."case_type"
            END)
            ELSE ''
        END AS case_type,
        CASE m.security_count
            WHEN 'M' THEN COALESCE(CASE CAST (a."security_count" AS CHAR(30))
                WHEN '' THEN '""'
                ELSE CAST (a."security_count" AS CHAR(30))
            END, '""')
            WHEN 'R' THEN COALESCE(CASE CAST (a."security_count" AS CHAR(30))
                WHEN '' THEN '""'
                ELSE CAST (a."security_count" AS CHAR(30))
            END, '""')
            ELSE ''
        END AS security_count,
        CASE m.case_access_code
            WHEN 'M' THEN COALESCE(CASE CAST (a."case_access_code" AS CHAR(30))
                WHEN '' THEN '""'
                ELSE CAST (a."case_access_code" AS CHAR(30))
            END, '""')
            WHEN 'R' THEN COALESCE(CASE CAST (a."case_access_code" AS CHAR(30))
                WHEN '' THEN '""'
                ELSE CAST (a."case_access_code" AS CHAR(30))
            END, '""')
            ELSE ''
        END AS case_access_code,
        CASE m.pmi_access_code
            WHEN 'M' THEN COALESCE(CASE CAST (a."pmi_access_code" AS CHAR(30))
                WHEN '' THEN '""'
                ELSE CAST (a."pmi_access_code" AS CHAR(30))
            END, '""')
            WHEN 'R' THEN COALESCE(CASE CAST (a."pmi_access_code" AS CHAR(30))
                WHEN '' THEN '""'
                ELSE CAST (a."pmi_access_code" AS CHAR(30))
            END, '""')
            ELSE ''
        END AS pmi_access_code,
        CASE m.ambulance_no
            WHEN 'M' THEN COALESCE(a."ambulance_no", '""')
            WHEN 'R' THEN COALESCE(a."ambulance_no", '""')
            ELSE ''
        END AS ambulance_no,
        CASE m.police_case
            WHEN 'M' THEN COALESCE(CASE a."police_case"
                WHEN '' THEN '""'
                ELSE a."police_case"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."police_case"
                WHEN '' THEN '""'
                ELSE a."police_case"
            END, '""')
            ELSE ''
        END AS police_case,
        CASE m.labour_case
            WHEN 'M' THEN COALESCE(CASE a."labour_case"
                WHEN '' THEN '""'
                ELSE a."labour_case"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."labour_case"
                WHEN '' THEN '""'
                ELSE a."labour_case"
            END, '""')
            ELSE ''
        END AS labour_case,
        CASE m.ae_case_type
            WHEN 'M' THEN COALESCE(CASE a."ae_case_type"
                WHEN '' THEN '""'
                ELSE a."ae_case_type"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."ae_case_type"
                WHEN '' THEN '""'
                ELSE a."ae_case_type"
            END, '""')
            ELSE ''
        END AS ae_case_type,
        CASE m.dba
            WHEN 'M' THEN COALESCE(CASE a."dba"
                WHEN '' THEN '""'
                ELSE a."dba"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."dba"
                WHEN '' THEN '""'
                ELSE a."dba"
            END, '""')
            ELSE ''
        END AS dba_flag, '' AS follow_up_datetime,
        CASE m.ward_code
            WHEN 'M' THEN COALESCE(CASE a."ward_code"
                WHEN '' THEN '""'
                ELSE a."ward_code"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."ward_code"
                WHEN '' THEN '""'
                ELSE a."ward_code"
            END, '""')
            ELSE ''
        END AS ward_code,
        CASE m.specialty_code
            WHEN 'M' THEN COALESCE(CASE a."specialty_code"
                WHEN '' THEN '""'
                ELSE a."specialty_code"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."specialty_code"
                WHEN '' THEN '""'
                ELSE a."specialty_code"
            END, '""')
            ELSE ''
        END AS specialty_code,
        CASE m.bed_no
            WHEN 'M' THEN COALESCE(CASE a."bed_no"
                WHEN '' THEN '""'
                ELSE a."bed_no"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."bed_no"
                WHEN '' THEN '""'
                ELSE a."bed_no"
            END, '""')
            ELSE ''
        END AS bed_no,
        CASE m.ward_class
            WHEN 'M' THEN COALESCE(CASE a."ward_class"
                WHEN '' THEN '""'
                ELSE a."ward_class"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."ward_class"
                WHEN '' THEN '""'
                ELSE a."ward_class"
            END, '""')
            ELSE ''
        END AS ward_class, COALESCE(CASE m.transfer_dtm
            WHEN 'M' THEN CONCAT(to_char(a."transfer_dtm"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', a."transfer_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', a."transfer_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', a."transfer_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), '.', SUBSTRING(CAST (date_part('millisecond', a."transfer_dtm"::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3))
            WHEN 'R' THEN CONCAT(to_char(a."transfer_dtm"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', a."transfer_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', a."transfer_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', a."transfer_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), '.', SUBSTRING(CAST (date_part('millisecond', a."transfer_dtm"::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3))
            ELSE ''
        END, '""') AS transfer_datetime,
        CASE m.old_patient_key
            WHEN 'M' THEN COALESCE(CASE a."old_patient_key"
                WHEN '' THEN '""'
                ELSE a."old_patient_key"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."old_patient_key"
                WHEN '' THEN '""'
                ELSE a."old_patient_key"
            END, '""')
            ELSE ''
        END AS old_patient_key,
        CASE m.old_patient_name
            WHEN 'M' THEN COALESCE(CASE a."old_patient_name"
                WHEN '' THEN '""'
                ELSE a."old_patient_name"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."old_patient_name"
                WHEN '' THEN '""'
                ELSE a."old_patient_name"
            END, '""')
            ELSE ''
        END AS old_name,
        CASE m.old_hkid
            WHEN 'M' THEN COALESCE(CASE a."old_hkid"
                WHEN '' THEN '""'
                ELSE a."old_hkid"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."old_hkid"
                WHEN '' THEN '""'
                ELSE a."old_hkid"
            END, '""')
            ELSE ''
        END AS old_hkid,
        CASE m.old_sex
            WHEN 'M' THEN COALESCE(CASE a."old_sex"
                WHEN '' THEN '""'
                ELSE a."old_sex"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."old_sex"
                WHEN '' THEN '""'
                ELSE a."old_sex"
            END, '""')
            ELSE ''
        END AS old_sex,
        CASE m.old_dob
            WHEN 'M' THEN COALESCE(to_char(a."old_dob"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), '""')
            WHEN 'R' THEN COALESCE(to_char(a."old_dob"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), '""')
            ELSE ''
        END AS old_dob,
        CASE m.old_ward_class
            WHEN 'M' THEN COALESCE(CASE a."old_ward_class"
                WHEN '' THEN '""'
                ELSE a."old_ward_class"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."old_ward_class"
                WHEN '' THEN '""'
                ELSE a."old_ward_class"
            END, '""')
            ELSE ''
        END AS old_ward_class,
        CASE m.old_ward_code
            WHEN 'M' THEN COALESCE(CASE a."old_ward_code"
                WHEN '' THEN '""'
                ELSE a."old_ward_code"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."old_ward_code"
                WHEN '' THEN '""'
                ELSE a."old_ward_code"
            END, '""')
            ELSE ''
        END AS old_ward_code,
        CASE m.old_specialty_code
            WHEN 'M' THEN COALESCE(CASE a."old_specialty_code"
                WHEN '' THEN '""'
                ELSE a."old_specialty_code"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."old_specialty_code"
                WHEN '' THEN '""'
                ELSE a."old_specialty_code"
            END, '""')
            ELSE ''
        END AS old_specialty_code,
        CASE m.old_bed_no
            WHEN 'M' THEN COALESCE(CASE a."old_bed_no"
                WHEN '' THEN '""'
                ELSE a."old_bed_no"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."old_bed_no"
                WHEN '' THEN '""'
                ELSE a."old_bed_no"
            END, '""')
            ELSE ''
        END AS old_bed_no, '' AS old_doctor_code,
        CASE m.pp_code
            WHEN 'M' THEN COALESCE(CASE a."pp_code"
                WHEN '' THEN '""'
                ELSE a."pp_code"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."pp_code"
                WHEN '' THEN '""'
                ELSE a."pp_code"
            END, '""')
            ELSE ''
        END AS pp_code,
        CASE m.update_hospital
            WHEN 'M' THEN COALESCE(CASE a."update_hospital"
                WHEN '' THEN '""'
                ELSE a."update_hospital"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."update_hospital"
                WHEN '' THEN '""'
                ELSE a."update_hospital"
            END, '""')
            ELSE ''
        END AS update_hospital, COALESCE(CASE m.system_dtm
            WHEN 'M' THEN CONCAT(to_char(a."system_dtm"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), '.', SUBSTRING(CAST (date_part('millisecond', a."system_dtm"::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3))
            WHEN 'R' THEN CONCAT(to_char(a."system_dtm"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), '.', SUBSTRING(CAST (date_part('millisecond', a."system_dtm"::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3))
            ELSE ''
        END, '""') AS update_datetime,
        /* Sam 2010-07-15 Include update_by - START */
        CASE m.update_by
            WHEN 'M' THEN COALESCE(CASE a."update_by"
                WHEN '' THEN '""'
                ELSE a."update_by"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."update_by"
                WHEN '' THEN '""'
                ELSE a."update_by"
            END, '""')
            ELSE ''
        END AS update_by,
        /* Sam 2010-07-15 Include update_by - END */
        CASE m.source_system
            WHEN 'M' THEN COALESCE(CASE a."source_system"
                WHEN '' THEN '""'
                ELSE a."source_system"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."source_system"
                WHEN '' THEN '""'
                ELSE a."source_system"
            END, '""')
            ELSE ''
        END AS source_system, '' AS success_indicator,
        CASE m.upload_status
            WHEN 'M' THEN COALESCE(CASE a."upload_status"
                WHEN '' THEN '""'
                ELSE a."upload_status"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."upload_status"
                WHEN '' THEN '""'
                ELSE a."upload_status"
            END, '""')
            ELSE ''
        END AS upload_status, COALESCE(CASE m.source_system_dtm
            WHEN 'M' THEN CONCAT(to_char(a."source_system_dtm"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', a."source_system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', a."source_system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', a."source_system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), '.', SUBSTRING(CAST (date_part('millisecond', a."source_system_dtm"::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3))
            WHEN 'R' THEN CONCAT(to_char(a."source_system_dtm"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', a."source_system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', a."source_system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', a."source_system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), '.', SUBSTRING(CAST (date_part('millisecond', a."source_system_dtm"::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3))
            ELSE ''
        END, '""') AS source_system_dtm,
        CASE m.pmi_access_code
            WHEN 'M' THEN COALESCE(CASE a."pmi_access_code" & 2
                WHEN 0 THEN 'UA'
                ELSE '""'
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."pmi_access_code" & 2
                WHEN 0 THEN 'UA'
                ELSE '""'
            END, '""')
            ELSE ''
        END AS mail_indicator,
        CASE m.filler
            WHEN 'M' THEN COALESCE(CASE a."filler"
                WHEN '' THEN '""'
                ELSE a."filler"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."filler"
                WHEN '' THEN '""'
                ELSE a."filler"
            END, '""')
            ELSE ''
        END AS cpi_filler,
        CASE m.document_flag
            WHEN 'M' THEN COALESCE(CASE SUBSTRING(a."filler", 1, 1)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 1, 1)
            END, '""')
            WHEN 'R' THEN COALESCE(CASE SUBSTRING(a."filler", 1, 1)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 1, 1)
            END, '""')
            ELSE ''
        END AS document_flag,
        CASE m.elderly_home_code
            WHEN 'M' THEN COALESCE(CASE SUBSTRING(a."filler", 2, 8)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 2, 8)
            END, '""')
            WHEN 'R' THEN COALESCE(CASE SUBSTRING(a."filler", 2, 8)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 2, 8)
            END, '""')
            ELSE ''
        END AS elderly_home_code,
        CASE m.exact_death_date
            WHEN 'M' THEN COALESCE(CASE SUBSTRING(a."filler", 10, 1)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 10, 1)
            END, '""')
            WHEN 'R' THEN COALESCE(CASE SUBSTRING(a."filler", 10, 1)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 10, 1)
            END, '""')
            ELSE ''
        END AS exact_dod_flag,
        CASE m.patient_remove_flag
            WHEN 'M' THEN COALESCE(CASE SUBSTRING(a."filler", 11, 1)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 11, 1)
            END, '""')
            WHEN 'R' THEN COALESCE(CASE SUBSTRING(a."filler", 11, 1)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 11, 1)
            END, '""')
            ELSE ''
        END AS patient_remove_flag,
        CASE a."type"
            WHEN '260' THEN 'NB'
            WHEN '261' THEN 'NB'
            WHEN '262' THEN 'NB'
            ELSE ''
        END AS relationship,
        CASE m.mother_hospital_code
            WHEN 'M' THEN COALESCE(CASE SUBSTRING(a."filler", 12, 3)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 12, 3)
            END, '""')
            WHEN 'R' THEN COALESCE(CASE SUBSTRING(a."filler", 12, 3)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 12, 3)
            END, '""')
            ELSE ''
        END AS mother_hospital_code,
        CASE m.baby_hospital_code
            WHEN 'M' THEN COALESCE(CASE SUBSTRING(a."filler", 15, 3)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 15, 3)
            END, '""')
            WHEN 'R' THEN COALESCE(CASE SUBSTRING(a."filler", 15, 3)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 15, 3)
            END, '""')
            ELSE ''
        END AS baby_hospital_code,
        CASE m.baby_case_no
            WHEN 'M' THEN COALESCE(CASE SUBSTRING(a."filler", 18, 12)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 18, 12)
            END, '""')
            WHEN 'R' THEN COALESCE(CASE SUBSTRING(a."filler", 18, 12)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 18, 12)
            END, '""')
            ELSE ''
        END AS baby_case_no,
        CASE m.linked_hospital_code
            WHEN 'M' THEN COALESCE(CASE SUBSTRING(a."filler", 12, 3)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 12, 3)
            END, '""')
            WHEN 'R' THEN COALESCE(CASE SUBSTRING(a."filler", 12, 3)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 12, 3)
            END, '""')
            ELSE ''
        END AS linked_hospital_code,
        CASE m.linked_case_no
            WHEN 'M' THEN COALESCE(CASE SUBSTRING(a."filler", 15, 12)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 15, 12)
            END, '""')
            WHEN 'R' THEN COALESCE(CASE SUBSTRING(a."filler", 15, 12)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 15, 12)
            END, '""')
            ELSE ''
        END AS linked_case_no, SUBSTRING(a."filler", 31, 1) AS body_category,
        /* 2011-11-16 Sam - Add an indicator to distinguish the type of txn type 121: either is to update admission datetime or other - START */
        CASE m.update_type
            WHEN 'M' THEN COALESCE(CASE a."update_type"
                WHEN '' THEN '""'
                ELSE a."update_type"
            END, '""')
            WHEN 'R' THEN COALESCE(CASE a."update_type"
                WHEN '' THEN '""'
                ELSE a."update_type"
            END, '""')
            ELSE ''
        END AS update_type,
        /* 2011-11-16 Sam - Add an indicator to distinguish the type of txn type 121: either is to update admission datetime or other - END */
        /* 2013-01-22 Sam - Include HKIC symbol - START */
        CASE m.hkic_symbol
            WHEN 'M' THEN COALESCE(CASE SUBSTRING(a."filler", 30, 1)
                WHEN '' THEN '""'
                ELSE SUBSTRING(a."filler", 30, 1)
            END, '""')
            WHEN 'R' THEN COALESCE(CASE SUBSTRING(a."filler", 30, 1)
                WHEN '' THEN ''
                ELSE SUBSTRING(a."filler", 30, 1)
            END, '')
            ELSE ''
        END AS hkic_symbol,
        /* 2013-01-22 Sam - Include HKIC symbol - END */
        CONCAT(to_char(localtimestamp::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', localtimestamp::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', localtimestamp::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', localtimestamp::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), '.', SUBSTRING(CAST (date_part('millisecond', localtimestamp::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3)) AS current_datetime, CONCAT(to_char(a."system_dtm"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), SUBSTRING(CAST (date_part('hour', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('minute', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('second', a."system_dtm"::TIMESTAMP) + 100 AS CHAR(3)), 2, 2), SUBSTRING(CAST (date_part('millisecond', a."system_dtm"::TIMESTAMP) + 1000 AS CHAR(4)), 2, 3)) AS message_key
        /* 2011-04-13 Sam - Use #temp table instead of real table - START */
        /* FROM transaction_log_tobar a, transaction_log_mandatory m */
        FROM t$transaction_log_tobar AS a, transaction_log_mandatory AS m
        /* 2011-04-13 Sam - Use #temp table instead of real table - END */
        WHERE a."type" = m.transaction_type
        ORDER BY a."system_dtm" NULLS FIRST, a."hospital_code" NULLS FIRST, a."timestamp" NULLS FIRST /* Sam 2010-08-03 Include timestamp to sort 261 (262 + 260) correctly */;
    RETURN NEXT p_refcur;

    DROP TABLE IF EXISTS t$transaction_log_tobar;
END;
$function$
;

ALTER FUNCTION "pas_get_pmi_trx_v2_lt" OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";