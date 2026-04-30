-- DROP FUNCTION hpi.cpi_ae_express_admission(varchar, varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION cpi_ae_express_admission(par_in_hospital_code character varying, par_in_status character varying DEFAULT 'all'::character varying, par_in_from_date timestamp without time zone DEFAULT NULL::timestamp without time zone, par_in_to_date timestamp without time zone DEFAULT NULL::timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/* ***** Object: Stored Procedure cpi_ae_express_admission Script Date: 07/2024 14:38:01 ***** */
/* 2025-01 Cathy Chen IPAS-764 A&E Express Reg phase-3 to mark if update patient major keys or not */
/* 2024-09 Cathy Chen IPAS-750 Enhance A&E Registration Report to support the creation of A&E express cases */
/* 2024-08 Jack Wen IPAS-738 A&E Express Register: Click new button ¡§Register by Claimed HKID¡¨ for claimed HKID patient add a flag column name as is_claimed_hkid; */
/* 2024-07 Jimmy Lu IPAS- A&E Express Admission Report List */
DECLARE
    var_ae_case_no VARCHAR(24);
    var_admit_to_ward_tmp VARCHAR(8);
    p_refcur refcursor;
    admission_list CURSOR FOR
    SELECT
        case_no
        FROM t$temp_ae_admission_list
        ORDER BY create_dtm DESC NULLS FIRST;
BEGIN
    DROP TABLE IF EXISTS t$temp_ae_admission_list;
    CREATE TEMPORARY TABLE t$temp_ae_admission_list
    (hospital_code VARCHAR(6) NULL,
        case_no VARCHAR(24) NULL,
        ocsss_status VARCHAR(20) NULL,
        by_smart_id VARCHAR(2) NULL,
        matched_hkpmi VARCHAR(2) NULL,
        is_new_patient VARCHAR(2) NULL,
        create_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
        hkic_symbol VARCHAR(2) NULL,
        patient_name VARCHAR(96) NULL,
        hkid VARCHAR(24) NULL,
        last_ward_code VARCHAR(8) NULL,
        last_specialty VARCHAR(8) NULL,
        sex VARCHAR(2) NULL,
        chi_name VARCHAR(24) NULL,
        patient_type VARCHAR(6) NULL,
        document_type VARCHAR(10) NULL,
        dob TIMESTAMP WITHOUT TIME ZONE NULL,
        update_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
        unicode_int1 INTEGER NULL,
        unicode_int2 INTEGER NULL,
        unicode_int3 INTEGER NULL,
        unicode_int4 INTEGER NULL,
        unicode_int5 INTEGER NULL,
        unicode_int6 INTEGER NULL,
        admit_to_ward VARCHAR(8) NULL,
        is_ae_reg VARCHAR(2) NULL,
        is_claimed_hkid VARCHAR(2) NULL,
        is_update_major_keys VARCHAR(2) NULL);
    /*
    [9996 - Severity CRITICAL - Transformer error occurred in fromClause. Please submit report to developers.]
    insert into #temp_ae_admission_list
    		select
    			express.hospital_code,
    			express.case_no,
    			express.ocsss_status,
    			express.by_smart_id,
    			express.matched_hkpmi,
    			express.is_new_patient,
    			express.create_dtm,
    			patient.hkic_symbol,
    			patient.patient_name,
    			patient.hkid,
    			cpicase.last_ward_code,
    			cpicase.last_specialty,
    			patient.sex,
    			patient.chi_name,
    			cpicase.patient_type,
    			doctype.document_type,
    			patient.dob,
    			case
    				when patient.update_dtm > cpicase.update_dtm then patient.update_dtm
    				else cpicase.update_dtm
    			end as update_dtm,
    			c1.unicode_int unicode_int1,
    			c2.unicode_int unicode_int2,
    			c3.unicode_int unicode_int3,
    			c4.unicode_int unicode_int4,
    			c5.unicode_int unicode_int5,
    			c6.unicode_int unicode_int6,
    			null admit_to_ward,
    			express.is_ae_reg is_ae_reg,
    			express.is_claimed_hkid is_claimed_hkid,
    			express.is_update_major_keys is_update_major_keys
    		from
    			dbo.cpi_ae_express_case express,
    			dbo.cpi_patient patient,
    			dbo.cpi_case cpicase,
    			dbo.document_type doctype,
    			dbo.ccc_unicode c1,
    			dbo.ccc_unicode c2,
    			dbo.ccc_unicode c3,
    			dbo.ccc_unicode c4,
    			dbo.ccc_unicode c5,
    			dbo.ccc_unicode c6
    		where
    			cpicase.patient_key = patient.patient_key
    			and express.case_no = cpicase.case_no
    			and cpicase.document_flag = doctype.document_code
    			and substring(patient.cccode1,1,4) *= c1.ccc_head
    			and substring(patient.cccode1,5,1) *= c1.ccc_tail
    			and substring(patient.cccode2,1,4) *= c2.ccc_head
    			and substring(patient.cccode2,5,1) *= c2.ccc_tail
    			and substring(patient.cccode3,1,4) *= c3.ccc_head
    			and substring(patient.cccode3,5,1) *= c3.ccc_tail
    			and substring(patient.cccode4,1,4) *= c4.ccc_head
    			and substring(patient.cccode4,5,1) *= c4.ccc_tail
    			and substring(patient.cccode5,1,4) *= c5.ccc_head
    			and substring(patient.cccode5,5,1) *= c5.ccc_tail
    			and substring(patient.cccode6,1,4) *= c6.ccc_head
    			and substring(patient.cccode6,5,1) *= c6.ccc_tail
    			and express.hospital_code = @in_hospital_code
    			and express.create_dtm >= @in_from_date
    			and express.create_dtm <= dateadd(dd,1,@in_to_date)
    */
    INSERT INTO t$temp_ae_admission_list
    		SELECT 
                express.hospital_code, 
                express.case_no, 
                express.ocsss_status, 
                express.by_smart_id, 
                express.matched_hkpmi, 
                express.is_new_patient, 
                express.create_dtm, 
                patient.hkic_symbol, 
                patient.patient_name, 
                patient.hkid, 
                cpicase.last_ward_code, 
                cpicase.last_specialty, 
                patient.sex, 
                patient.chi_name, 
                cpicase.patient_type, 
                doctype.document_type, 
                patient.dob, 
                CASE 
                    WHEN patient.update_dtm > cpicase.update_dtm THEN patient.update_dtm 
                    ELSE cpicase.update_dtm 
                END AS update_dtm, 
                c1.unicode_int AS unicode_int1, 
                c2.unicode_int AS unicode_int2, 
                c3.unicode_int AS unicode_int3, 
                c4.unicode_int AS unicode_int4, 
                c5.unicode_int AS unicode_int5, 
                c6.unicode_int AS unicode_int6, 
                NULL AS admit_to_ward, 
                express.is_ae_reg, 
                express.is_claimed_hkid, 
                express.is_update_major_keys 
            FROM 
                cpi_ae_express_case express
            JOIN 
                cpi_case cpicase ON express.case_no = cpicase.case_no
            JOIN 
                cpi_patient patient ON cpicase.patient_key = patient.patient_key
            JOIN 
                document_type doctype ON cpicase.document_flag = doctype.document_code
            LEFT JOIN 
                ccc_unicode c1 ON SUBSTRING(patient.cccode1 FROM 1 FOR 4) = c1.ccc_head 
                            AND SUBSTRING(patient.cccode1 FROM 5 FOR 1) = c1.ccc_tail
            LEFT JOIN 
                ccc_unicode c2 ON SUBSTRING(patient.cccode2 FROM 1 FOR 4) = c2.ccc_head 
                            AND SUBSTRING(patient.cccode2 FROM 5 FOR 1) = c2.ccc_tail
            LEFT JOIN 
                ccc_unicode c3 ON SUBSTRING(patient.cccode3 FROM 1 FOR 4) = c3.ccc_head 
                            AND SUBSTRING(patient.cccode3 FROM 5 FOR 1) = c3.ccc_tail
            LEFT JOIN 
                ccc_unicode c4 ON SUBSTRING(patient.cccode4 FROM 1 FOR 4) = c4.ccc_head 
                            AND SUBSTRING(patient.cccode4 FROM 5 FOR 1) = c4.ccc_tail
            LEFT JOIN 
                ccc_unicode c5 ON SUBSTRING(patient.cccode5 FROM 1 FOR 4) = c5.ccc_head 
                            AND SUBSTRING(patient.cccode5 FROM 5 FOR 1) = c5.ccc_tail
            LEFT JOIN 
                ccc_unicode c6 ON SUBSTRING(patient.cccode6 FROM 1 FOR 4) = c6.ccc_head 
                            AND SUBSTRING(patient.cccode6 FROM 5 FOR 1) = c6.ccc_tail
            WHERE 
                express.hospital_code = par_in_hospital_code 
                AND express.create_dtm >= par_in_from_date 
                AND express.create_dtm <= par_in_to_date + INTERVAL '1 day';
    CREATE INDEX temp_idx_create_dtm ON t$temp_ae_admission_list
        (create_dtm);

    IF par_in_status IS NOT NULL THEN
        BEGIN
            SELECT
                LTRIM(RTRIM(par_in_status))
                INTO par_in_status;

            IF par_in_status <> 'all' THEN
                BEGIN
                    DELETE FROM t$temp_ae_admission_list
                        WHERE LTRIM(RTRIM(ocsss_status)) <> par_in_status;
                END;
            END IF;
        END;
    END IF;
    OPEN admission_list;
    FETCH NEXT FROM admission_list INTO var_ae_case_no;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            ''
            INTO var_admit_to_ward_tmp;
        SELECT
            COALESCE(cpicase.last_ward_code, '')
            INTO var_admit_to_ward_tmp
            FROM cpi_linked_case AS linked
            JOIN cpi_case AS cpicase
                ON cpicase.case_no = linked.case_no
            WHERE linked.previous_hospital = par_in_hospital_code AND linked.previous_case = var_ae_case_no
            ORDER BY cpicase.create_dtm DESC NULLS FIRST
            LIMIT 1;

        IF var_admit_to_ward_tmp <> '' THEN
            BEGIN
                UPDATE t$temp_ae_admission_list
                SET admit_to_ward = var_admit_to_ward_tmp
                    WHERE case_no = var_ae_case_no;
                /*
                
                DROP TABLE IF EXISTS t$temp_ae_admission_list;
                */
                /*
                
                Temporary table must be removed before end of the function.
                */
            END;
        END IF;
        FETCH NEXT FROM admission_list INTO var_ae_case_no;
    END LOOP;
    CLOSE admission_list;
    --p_refcur := 'p_refcur';
    OPEN p_refcur FOR
    SELECT
        hospital_code, case_no, ocsss_status, by_smart_id, matched_hkpmi, is_new_patient, create_dtm, hkic_symbol, patient_name, hkid, last_ward_code, last_specialty, sex, chi_name, patient_type, document_type, dob, update_dtm, unicode_int1, unicode_int2, unicode_int3, unicode_int4, unicode_int5, unicode_int6, admit_to_ward, is_ae_reg, is_claimed_hkid, is_update_major_keys
        FROM t$temp_ae_admission_list
        ORDER BY create_dtm DESC NULLS FIRST;
    RETURN NEXT p_refcur;
END;
$function$
;

;ALTER FUNCTION "cpi_ae_express_admission" OWNER TO "HPI_SCHEMA_OWNER_ROLE";

