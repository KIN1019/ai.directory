-- DROP FUNCTION hpi.pass_check_dup_name_same_ward(varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.pass_check_dup_name_same_ward(par_hospital character varying, par_case_no character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_last_ward_code VARCHAR(8);
    var_discharge_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_status_code VARCHAR(4);
    var_patient_name VARCHAR(96);
    var_cccode1 VARCHAR(10);
    var_cccode2 VARCHAR(10);
    var_cccode3 VARCHAR(10);
    var_cccode4 VARCHAR(10);
    var_cccode5 VARCHAR(10);
    var_cccode6 VARCHAR(10);
    var_unicode_int1 INTEGER;
    var_unicode_int2 INTEGER;
    var_unicode_int3 INTEGER;
    var_unicode_int4 INTEGER;
    var_unicode_int5 INTEGER;
    var_unicode_int6 INTEGER;
    var_dup_eng_name VARCHAR(2);
    var_dup_chin_name VARCHAR(2);
    p_refcur refcursor;
    sql$rowcount BIGINT;
BEGIN
    /* --Default setting */
    SELECT
        'N'
        INTO var_dup_eng_name;
    SELECT
        'N'
        INTO var_dup_chin_name;

    IF OCTET_LENGTH(LTRIM(RTRIM(par_case_no))) = 11 THEN
        SELECT
            CONCAT(' ', LTRIM(RTRIM(par_case_no)))
            INTO par_case_no;
    END IF;
    SELECT
        c.last_ward_code, c.discharge_dtm, c.status_code, p.patient_name, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6
        INTO var_last_ward_code, var_discharge_dtm, var_status_code, var_patient_name, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6
        FROM cpi_case AS c, cpi_patient AS p
        WHERE c.case_no = par_case_no AND c.hospital_code = par_hospital AND p.patient_key = c.patient_key;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount = 0 THEN
        BEGIN
            RAISE EXCEPTION '%', format('Case number %s was not found.', par_case_no) USING ERRCODE := '99999';
        END;
    ELSE
        IF var_discharge_dtm != NULL THEN
            BEGIN
                RAISE NOTICE 'Case number % was discharged.', par_case_no;
            END;
        ELSE
            IF var_status_code != 'AC' THEN
                BEGIN
                    RAISE NOTICE 'Case number % was cancelled.', par_case_no;
                END;
            ELSE
                IF var_last_ward_code = NULL THEN
                    BEGIN
                        RAISE EXCEPTION '%', format('Case number %s has no ward code.', par_case_no) USING ERRCODE := '99999';
                    END;
                ELSE
                    BEGIN
                        CREATE TEMPORARY TABLE t$ward_patient_list
                        (dup_eng_name VARCHAR(2) NULL,
                            dup_chin_name VARCHAR(2) NULL,
                            ward_code VARCHAR(8),
                            bed_no VARCHAR(10) NULL,
                            patient_name VARCHAR(96),
                            patient_key VARCHAR(16),
                            hkid VARCHAR(24),
                            sex VARCHAR(2),
                            admission_datetime VARCHAR(38),
                            case_no VARCHAR(24),
                            cccode1 VARCHAR(10) NULL,
                            cccode2 VARCHAR(10) NULL,
                            cccode3 VARCHAR(10) NULL,
                            cccode4 VARCHAR(10) NULL,
                            cccode5 VARCHAR(10) NULL,
                            cccode6 VARCHAR(10) NULL,
                            unicode_int1 INTEGER NULL,
                            unicode_int2 INTEGER NULL,
                            unicode_int3 INTEGER NULL,
                            unicode_int4 INTEGER NULL,
                            unicode_int5 INTEGER NULL,
                            unicode_int6 INTEGER NULL);
							
                        insert into t$ward_patient_list (ward_code, bed_no,patient_name, patient_key, hkid, sex,admission_datetime, case_no,
						cccode1, cccode2, cccode3, cccode4, cccode5, cccode6,
						unicode_int1, unicode_int2, unicode_int3, unicode_int4, unicode_int5, unicode_int6)
							select rtrim(w.ward_code) as ward_code, rtrim(w.bed_no) as bed_no, rtrim(p.patient_name) as patient_name, p.patient_key, rtrim(p.hkid) as hkid, p.sex,
								(case when c.admission_dtm is not null then to_char(c.admission_dtm, 'dd-mm-yyyy') || ' ' || to_char(c.admission_dtm, 'hh:mm:ss') else null end) as admission_dtm,
								rtrim(c.case_no), p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6, c1.unicode_int unicode_int1, c2.unicode_int unicode_int2, c3.unicode_int unicode_int3, c4.unicode_int unicode_int4,c5.unicode_int unicode_int5, c6.unicode_int unicode_int6
                            from cpi_ward_list w
								INNER JOIN cpi_case AS c on w.case_no = c.case_no and w.hospital_code = c.hospital_code
								INNER JOIN cpi_patient AS p on c.patient_key = p.patient_key
								LEFT OUTER JOIN ccc_unicode AS c1
									ON SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
								LEFT OUTER JOIN ccc_unicode AS c2
									ON SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
								LEFT OUTER JOIN ccc_unicode AS c3
									ON SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
								LEFT OUTER JOIN ccc_unicode AS c4
									ON SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
								LEFT OUTER JOIN ccc_unicode AS c5
									ON SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
								LEFT OUTER JOIN ccc_unicode AS c6
									ON SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
							where w.hospital_code = par_hospital
							and w.ward_code = var_last_ward_code
							and w.case_no <> par_case_no
							and (p.patient_name = var_patient_name or
								(p.cccode1 <> null and p.cccode1 = var_cccode1 and p.cccode2 = var_cccode2 and p.cccode3 = var_cccode3 and p.cccode4 = var_cccode4 and p.cccode5 = var_cccode5 and p.cccode6 = var_cccode6));
                        /* --update dup_eng_name */
                        UPDATE t$ward_patient_list
                        SET dup_eng_name = 'Y'
                        WHERE patient_name = var_patient_name;
                        /* --update dup_chin_name */
                        UPDATE t$ward_patient_list
                        SET dup_chin_name = 'Y'
                        WHERE cccode1 <> NULL AND cccode1 = var_cccode1 AND cccode2 = var_cccode2 AND cccode3 = var_cccode3 AND cccode4 = var_cccode4 AND cccode5 = var_cccode5 AND cccode6 = var_cccode6;
                        /*
                        select dup_eng_name,
                               dup_chin_name,
                               ward_code,
                               bed_no,
                               patient_name,
                               patient_key,
                               hkid,
                               sex,
                               admission_datetime,
                               case_no,
                               cccode1,
                               cccode2,
                               cccode3,
                               cccode4,
                               cccode5,
                               cccode6,
                               unicode_int1,
                               unicode_int2,
                               unicode_int3,
                               unicode_int4,
                               unicode_int5,
                               unicode_int6
                        from #ward_patient_list
                        */
                        /* --create result set */
                        IF EXISTS (SELECT
                            1
                            FROM t$ward_patient_list
                            WHERE dup_eng_name = 'Y') THEN
                            var_dup_eng_name := 'Y';
                        ELSE
                            var_dup_eng_name := 'N';
                        END IF;

                        IF EXISTS (SELECT
                            1
                            FROM t$ward_patient_list
                            WHERE dup_chin_name = 'Y') THEN
                            BEGIN
                                var_dup_chin_name := 'Y';
     
                                SELECT
                                    unicode_int1, unicode_int2, unicode_int3, unicode_int4, unicode_int5, unicode_int6
                                    INTO var_unicode_int1, var_unicode_int2, var_unicode_int3, var_unicode_int4, var_unicode_int5, var_unicode_int6
                                    FROM t$ward_patient_list
                                    WHERE dup_chin_name = 'Y'
									LIMIT 1;
                            END;
                        ELSE
                            var_dup_chin_name := 'N';
                        END IF;
                        DROP TABLE t$ward_patient_list;
                    END;
                END IF;
            END IF;
        END IF;
    END IF;
    OPEN p_refcur FOR
    SELECT
        var_dup_eng_name AS dup_eng_name, var_dup_chin_name AS dup_chin_name, var_last_ward_code AS ward_code, NULL AS bed_no, var_patient_name AS patient_name, NULL AS patient_key, NULL AS hkid, NULL AS sex, NULL AS admission_datetime, par_case_no AS case_no, var_cccode1 AS cccode1, var_cccode2 AS cccode2, var_cccode3 AS cccode3, var_cccode4 AS cccode4, var_cccode5 AS cccode5, var_cccode6 AS cccode6, var_unicode_int1 AS unicode_int1, var_unicode_int2 AS unicode_int2, var_unicode_int3 AS unicode_int3, var_unicode_int4 AS unicode_int4, var_unicode_int5 AS unicode_int5, var_unicode_int6 AS unicode_int6;

    DROP TABLE IF EXISTS t$ward_patient_list;

END;
$function$
;

;ALTER FUNCTION "pass_check_dup_name_same_ward" OWNER TO "HPI_SCHEMA_OWNER_ROLE";