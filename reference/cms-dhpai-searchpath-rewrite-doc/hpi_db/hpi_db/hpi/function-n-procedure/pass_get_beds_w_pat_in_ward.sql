CREATE OR REPLACE PROCEDURE pass_get_beds_w_pat_in_ward(INOUT pas_return_code int, IN par_hospital_code VARCHAR, IN par_ward_code VARCHAR, IN par_includeVacent VARCHAR DEFAULT 'N', IN par_patientKey VARCHAR DEFAULT null, IN par_caseNumber VARCHAR DEFAULT null, INOUT p_refcur refcursor DEFAULT NULL)
AS 
$BODY$
DECLARE
    var_casePatientKey VARCHAR(8);
    var_bedNumber VARCHAR(5);
BEGIN
    CREATE TEMPORARY TABLE t$ward_with_patient
    (hospital_code VARCHAR(6),
        case_no VARCHAR(24),
        ward_code VARCHAR(8),
        bed_no VARCHAR(10) NULL,
        patient_key VARCHAR(16),
        patient_name VARCHAR(96),
        hkid VARCHAR(24),
        dob VARCHAR(20) NULL,
        sex VARCHAR(2),
        cccode1 VARCHAR(10) NULL,
        cccode2 VARCHAR(10) NULL,
        cccode3 VARCHAR(10) NULL,
        cccode4 VARCHAR(10) NULL,
        cccode5 VARCHAR(10) NULL,
        cccode6 VARCHAR(10) NULL);
    CREATE INDEX ward_with_patient_idx ON t$ward_with_patient
        (hospital_code, ward_code, bed_no);
    CREATE TEMPORARY TABLE t$result
    (hospital_code VARCHAR(6),
        ward_code VARCHAR(8),
        bed_no VARCHAR(10),
        bed_type VARCHAR(30),
        bed_status VARCHAR(30),
        case_no VARCHAR(24) NULL,
        patient_key VARCHAR(16) NULL,
        patient_name VARCHAR(96) NULL,
        hkid VARCHAR(24) NULL,
        dob VARCHAR(20) NULL,
        sex VARCHAR(2) NULL,
        cccode1 VARCHAR(10) NULL,
        cccode2 VARCHAR(10) NULL,
        cccode3 VARCHAR(10) NULL,
        cccode4 VARCHAR(10) NULL,
        cccode5 VARCHAR(10) NULL,
        cccode6 VARCHAR(10) NULL);

    IF OCTET_LENGTH(LTRIM(RTRIM(par_caseNumber))) = 11 THEN
        SELECT
            CONCAT(' ', LTRIM(RTRIM(par_caseNumber)))
            INTO par_caseNumber;
    END IF;
    SELECT
        T_PRK
        INTO var_casePatientKey
        FROM ADT_Case
        WHERE Case_no = par_caseNumber;

    IF par_patientKey = '' THEN
        BEGIN
            SELECT
                NULL
                INTO par_patientKey;
        END;
    END IF;

    IF var_casePatientKey = '' THEN
        BEGIN
            SELECT
                NULL
                INTO var_casePatientKey;
        END;
    END IF;

    IF var_casePatientKey IS NOT NULL AND par_patientKey IS NOT NULL AND par_patientKey != var_casePatientKey THEN
        BEGIN
            RAISE EXCEPTION 'Case number and patient key are not matched' USING ERRCODE := '99999';
            pas_return_code := 0;
            RETURN;
        END;
    END IF;

    IF var_casePatientKey IS NOT NULL AND par_patientKey IS NULL THEN
        BEGIN
            SELECT
                var_casePatientKey
                INTO par_patientKey;
        END;
    END IF;

    IF par_patientKey IS NOT NULL THEN
        BEGIN
            SELECT
                'N'
                INTO par_includeVacent;
            SELECT
                NULL
                INTO par_ward_code;
        END;
    END IF;
    INSERT INTO t$ward_with_patient
    SELECT
        w.Hospital_code, w.Case_no, w.Ward_code, w.Bed_no, p.T_PRK, p.Name, p.HKID, to_char(p.DOB, 'dd-mm-yyyy'), p.Sex, p.CCC_1, p.CCC_2, p.CCC_3, p.CCC_4, p.CCC_5, p.CCC_6
        FROM Ward_list AS w, ADT_Case AS c, PMI AS p
        WHERE w.Hospital_code = par_hospital_code AND (w.Ward_code = par_ward_code OR par_ward_code IS NULL) AND w.Bed_no <> NULL AND w.Case_no = c.Case_no AND c.Hospital_code = par_hospital_code AND c.T_PRK = p.T_PRK AND p.PMI_hospital_code = par_hospital_code AND (p.T_PRK = par_patientKey OR par_patientKey IS NULL);

    IF par_patientKey IS NOT NULL THEN
        BEGIN
            SELECT
                ward_code, bed_no
                INTO par_ward_code, var_bedNumber
                FROM t$ward_with_patient
                WHERE patient_key = par_patientKey;
        END;
    END IF;
    /* Adaptive Server has expanded all '*' elements in the following statement */
    INSERT INTO t$result
    SELECT
        bh.hospital_code, bh.ward_code, bh.bed_no,
        /* case */
        
        /* --		when bh.bed_type = 'E' then 'Added' */
        
        /* --		when bh.bed_type = 'D' then 'Day' */
        
        /* --		when bh.bed_type = 'R' then 'Official' */
        
        /* --	end bed_type, */
        bed_type,
        CASE
            WHEN (w.case_no IS NULL) THEN 'Vacant'
            ELSE 'Occupied'
        END AS bed_status, w.case_no, w.patient_key, w.patient_name, w.hkid, w.dob, w.sex, w.cccode1, w.cccode2, w.cccode3, w.cccode4, w.cccode5, w.cccode6
        FROM (SELECT
            ungrouped_query.hospital_code, ungrouped_query.ward_code, cubicle_no, ungrouped_query.bed_no, effective_datetime, active_status, bed_type, bed_category, specialty_code, in_service_specialty, row_no, col_no, update_datetime, update_by, source_system, ciwl_indicator, isolation_bed, bed_ready, physical_bed_no
            FROM (SELECT
                bed_history.hospital_code, bed_history.ward_code, bed_history.cubicle_no, bed_history.bed_no, bed_history.effective_datetime, bed_history.active_status, bed_history.bed_type, bed_history.bed_category, bed_history.specialty_code, bed_history.in_service_specialty, bed_history.row_no, bed_history.col_no, bed_history.update_datetime, bed_history.update_by, bed_history.source_system, bed_history.ciwl_indicator, bed_history.isolation_bed, bed_history.bed_ready, bed_history.physical_bed_no
                FROM bed_history) AS ungrouped_query
            INNER JOIN (SELECT
                hospital_code, ward_code, bed_no, MAX(effective_datetime) AS max_1
                FROM bed_history
                WHERE effective_datetime <= localtimestamp AND ward_code = par_ward_code AND hospital_code = par_hospital_code AND (bed_no = var_bedNumber OR var_bedNumber IS NULL)
                GROUP BY hospital_code, ward_code, bed_no) AS grouped_query
                ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
            WHERE effective_datetime = max_1 AND active_status = 'A' AND bed_type IN ('R', 'E', 'D')) AS bh
        LEFT OUTER JOIN t$ward_with_patient AS w
            ON bh.hospital_code = w.hospital_code AND bh.ward_code = w.ward_code AND bh.bed_no = w.bed_no
        WHERE bh.active_status = 'A' AND bh.bed_type IN ('R', 'E', 'D')
        ORDER BY bh.bed_no NULLS FIRST;
		
		select r.hospital_code, r.ward_code, r.bed_no, r.bed_type, r.bed_status, r.case_no, r.patient_key, r.patient_name, r.hkid, r.dob, r.sex, r.cccode1, r.cccode2, r.cccode3, r.cccode4, r.cccode5, r.cccode6          ,
					c1.Unicode_int unicode_int1, c2.Unicode_int unicode_int2, c3.Unicode_int unicode_int3,
					c4.Unicode_int unicode_int4, c5.Unicode_int unicode_int5, c6.Unicode_int unicode_int6
			from t$result r
				LEFT OUTER JOIN ccc_unicode AS c1 ON SUBSTRING(r.cccode1, 1, 4) = c1.ccc_head AND SUBSTRING(r.cccode1, 5, 1) = c1.ccc_tail
				LEFT OUTER JOIN ccc_unicode AS c2 ON SUBSTRING(r.cccode2, 1, 4) = c2.ccc_head AND SUBSTRING(r.cccode2, 5, 1) = c2.ccc_tail
				LEFT OUTER JOIN ccc_unicode AS c3 ON SUBSTRING(r.cccode3, 1, 4) = c3.ccc_head AND SUBSTRING(r.cccode3, 5, 1) = c3.ccc_tail
				LEFT OUTER JOIN ccc_unicode AS c4 ON SUBSTRING(r.cccode4, 1, 4) = c4.ccc_head AND SUBSTRING(r.cccode4, 5, 1) = c4.ccc_tail
				LEFT OUTER JOIN ccc_unicode AS c5 ON SUBSTRING(r.cccode5, 1, 4) = c5.ccc_head AND SUBSTRING(r.cccode5, 5, 1) = c5.ccc_tail
				LEFT OUTER JOIN ccc_unicode AS c6 ON SUBSTRING(r.cccode6, 1, 4) = c6.ccc_head AND SUBSTRING(r.cccode6, 5, 1) = c6.ccc_tail
			where (par_includeVacent = 'Y' or (par_includeVacent <> 'Y' and r.case_no <> null))
			order by r.bed_type desc, r.bed_no;

    DROP TABLE IF EXISTS t$ward_with_patient;
    DROP TABLE IF EXISTS t$result;

END;
$BODY$
LANGUAGE plpgsql;

;ALTER PROCEDURE "pass_get_beds_w_pat_in_ward" OWNER TO "HPI_SCHEMA_OWNER_ROLE";