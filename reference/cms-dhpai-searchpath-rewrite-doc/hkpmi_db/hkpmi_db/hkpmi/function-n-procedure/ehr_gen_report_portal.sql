-- DROP FUNCTION hkpmi.ehr_gen_report_portal(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hkpmi.ehr_gen_report_portal(par_report_no character varying, par_report_start_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, par_report_end_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_report_date DATE;
BEGIN
    SELECT
        timestamp_convert(localtimestamp)
        INTO var_report_date;

    IF (par_report_no = '1') THEN
        BEGIN
            BEGIN
                OPEN p_refcur FOR
                SELECT
                    REPLACE(to_char(var_report_date::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-') AS report_date, 1 AS report_id, code_field AS rpt_f1, code_field_full_desc AS rpt_f2,
                    CASE CAST (COALESCE(ehr_cnt, 0) AS VARCHAR)
                        WHEN '' THEN ''
                        ELSE CAST (COALESCE(ehr_cnt, 0) AS VARCHAR)
                    END AS rpt_f3,
                    CASE CAST (COALESCE(ppi_cnt, 0) AS VARCHAR)
                        WHEN '' THEN ''
                        ELSE CAST (COALESCE(ppi_cnt, 0) AS VARCHAR)
                    END AS rpt_f4,
                    CASE CAST (CASE
                        WHEN code_field = 'VAL' THEN 1
                        WHEN code_field = 'NID' THEN 2
                        WHEN code_field = 'MKD' THEN 3
                        WHEN code_field = 'MES' THEN 4
                        WHEN code_field = 'MKU' THEN 5
                        WHEN code_field = 'MKC' THEN 6
                        WHEN code_field = 'MKE' THEN 7
                        WHEN code_field = 'MKP' THEN 8
                        WHEN code_field = 'MKM' THEN 9
                        WHEN code_field = 'WHD' THEN 10
                        WHEN code_field = 'DDR' THEN 11
                        WHEN code_field = 'MID' THEN 12
                        WHEN code_field = 'MIC' THEN 13
                        WHEN code_field = 'MIE' THEN 14
                        WHEN code_field = 'MIM' THEN 15
                        WHEN code_field = 'MIP' THEN 16
                        WHEN code_field = 'MIU' THEN 17
                    END AS VARCHAR)
                        WHEN '' THEN ''
                        ELSE CAST (CASE
                            WHEN code_field = 'VAL' THEN 1
                            WHEN code_field = 'NID' THEN 2
                            WHEN code_field = 'MKD' THEN 3
                            WHEN code_field = 'MES' THEN 4
                            WHEN code_field = 'MKU' THEN 5
                            WHEN code_field = 'MKC' THEN 6
                            WHEN code_field = 'MKE' THEN 7
                            WHEN code_field = 'MKP' THEN 8
                            WHEN code_field = 'MKM' THEN 9
                            WHEN code_field = 'WHD' THEN 10
                            WHEN code_field = 'DDR' THEN 11
                            WHEN code_field = 'MID' THEN 12
                            WHEN code_field = 'MIC' THEN 13
                            WHEN code_field = 'MIE' THEN 14
                            WHEN code_field = 'MIM' THEN 15
                            WHEN code_field = 'MIP' THEN 16
                            WHEN code_field = 'MIU' THEN 17
                        END AS VARCHAR)
                    END AS rpt_f5, NULL AS rpt_f6, NULL AS rpt_f7, NULL AS rpt_f8, NULL AS rpt_f9, NULL AS rpt_f10, NULL AS rpt_f11, NULL AS rpt_f12, NULL AS rpt_f13, NULL AS rpt_f14, NULL AS rpt_f15, NULL AS rpt_f16, NULL AS rpt_f17, NULL AS rpt_f18, NULL AS rpt_f19, NULL AS rpt_f20, NULL AS rpt_f21, NULL AS rpt_f22, NULL AS rpt_f23, NULL AS rpt_f24, NULL AS rpt_f25, NULL AS rpt_f26, NULL AS rpt_f27, NULL AS rpt_f28, NULL AS rpt_f29, NULL AS rpt_f30, NULL AS rpt_f31, NULL AS rpt_f32
                    FROM ehr_code_table AS t
                    LEFT OUTER JOIN (SELECT
                        ehr_flag, SUM(CASE ehr_ppi_ind
                            WHEN 'Y' THEN 1
                            ELSE 0
                        END) AS ehr_cnt, SUM(CASE ehr_ppi_ind
                            WHEN 'Y' THEN 0
                            ELSE 1
                        END) AS ppi_cnt
                        FROM ehr_patient_list
                        GROUP BY ehr_flag) AS plist
                        ON t.code_field = plist.ehr_flag
                    WHERE t.code_type = 'EHR_FLAG' AND t.code_name = 'ehr_flag';
				return next p_refcur;
                EXCEPTION
                    WHEN others THEN
                        BEGIN
                            
                            RETURN;
                        END;
            END;
        END;
    END IF;

    IF (par_report_no = '2') THEN
        BEGIN
            /* Adaptive Server has expanded all '*' elements in the following statement */
            CREATE TEMPORARY TABLE t$tmp_2
            AS
            SELECT
                t.evt_txn_dtm, t.evt_txn_type, t.evt_code, t.evt_log_type, t.evt_msg_no, t.evt_ack, t.ehr_flag, t.ehr_number, t.ehr_start_date, t.ehr_end_date, t.ehr_hkic, t.ehr_surname, t.ehr_givenname, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.ehr_doc_type, t.ehr_doc_no, t.ehr_death_date, t.ehr_death_time, t.ehr_exact_death, t.ehr_death_ind, t.old_ehr_number, t.old_ehr_flag, t.old_ehr_hkic, t.old_ehr_surname, t.old_ehr_givenname, t.old_ehr_full_name, t.old_ehr_sex, t.old_ehr_dob, t.old_ehr_exact_dob, t.old_ehr_doc_type, t.old_ehr_doc_no, t.pas_hosp, t.pas_hkic, t.pas_pky, t.pas_case, t.pas_surname, t.pas_givenname, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob, t.pas_doc_type, t.pas_doc_no, t.pas_death_date, t.pas_death_time, t.pas_exact_death, t.pas_death_ind, t.old_pas_hkic, t.old_pas_pky, t.old_pas_surname, t.old_pas_givenname, t.old_pas_full_name, t.old_pas_sex, t.old_pas_dob, t.old_pas_exact_dob, t.old_pas_doc_type, t.old_pas_doc_no, t.upd_by, t.upd_sys, t.upd_hosp, t.upd_host, t.sys_dtm, t.ehr_ppi_ind, t.ehr_non_ha_ind, t.ehr_status, t.old_ehr_ppi_ind, t.old_ehr_non_ha_ind, t.old_ehr_status
                FROM ehr_patient_list AS p, ehr_event_txn AS t
                WHERE p.ehr_flag = 'NID' AND p.ehr_ppi_ind = 'Y' AND p.ehr_doc_type NOT IN ('ID', 'BC') AND p.ehr_number = t.ehr_number AND t.ehr_flag = 'NID' AND evt_txn_type IN ('ENT', 'MKC') AND t.sys_dtm BETWEEN
                CASE par_report_start_dtm
                    WHEN NULL THEN '19700101'
                    ELSE par_report_start_dtm
                END AND
                CASE par_report_end_dtm
                    WHEN NULL THEN timestamp_convert(localtimestamp)
                    ELSE par_report_end_dtm
                END;
            CREATE TEMPORARY TABLE t$tmp_2_1
            AS
            SELECT
                max_evt_txn, uponafter, t.ehr_start_date, t.ehr_number, t.ehr_doc_type, t.ehr_doc_no, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.ehr_full_name
                FROM (SELECT
                    ungrouped_query.ehr_number, min_1 AS min_evt_txn, max_1 AS max_evt_txn, ungrouped_query.uponafter
                    FROM (SELECT
                        ehr_number,
                        CASE MIN(evt_txn_dtm)
                            WHEN MAX(evt_txn_dtm) THEN 1
                            ELSE 0
                        END AS uponafter
                        FROM t$tmp_2) AS ungrouped_query
                    INNER JOIN (SELECT
                        ehr_number, MIN(evt_txn_dtm) AS min_1, MAX(evt_txn_dtm) AS max_1
                        FROM t$tmp_2
                        GROUP BY ehr_number) AS grouped_query
                        ON (ungrouped_query.ehr_number = grouped_query.ehr_number OR (ungrouped_query.ehr_number IS NULL AND grouped_query.ehr_number IS NULL))) AS p, ehr_event_txn AS t
                WHERE p.ehr_number = t.ehr_number AND p.max_evt_txn = t.evt_txn_dtm AND t.ehr_flag = 'NID' AND evt_txn_type IN ('ENT', 'MKC');
            OPEN p_refcur FOR
            SELECT
                REPLACE(to_char(var_report_date::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-') AS report_date, 2 AS report_id, 'NID' AS rpt_f1, ehr_number AS rpt_f2,
                CASE uponafter
                    WHEN 1 THEN 'UPON'
                    ELSE 'AFTER'
                END AS rpt_f3,
                /* --,isnull(str_replace(convert(VARCHAR(15), ehr_start_date, 106), ' ', '-'), 'N/A') rpt_f4 */
                COALESCE(REPLACE(TO_CHAR(ehr_start_date, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f4,
                COALESCE(CONCAT(REPLACE(to_char(max_evt_txn::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(max_evt_txn::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY')), 'N/A') AS rpt_f5, ehr_doc_type AS rpt_f6, ehr_doc_no AS rpt_f7, ehr_full_name AS rpt_f8, ehr_sex AS rpt_f9,
                /* --,isnull(str_replace(convert(VARCHAR(15), ehr_dob, 106), ' ', '-'), 'N/A') rpt_f10 */
                COALESCE(REPLACE(TO_CHAR(ehr_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f10,
                ehr_exact_dob AS rpt_f11, hkid AS rpt_f12, d.document_type AS rpt_f13, other_doc_no AS rpt_f14, patient_name AS rpt_f15, sex AS rpt_f16, 
                COALESCE(REPLACE(to_char(dob::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f17, exact_dob_flag AS rpt_f18, NULL AS rpt_f19, NULL AS rpt_f20, NULL AS rpt_f21, NULL AS rpt_f22, NULL AS rpt_f23, NULL AS rpt_f24, NULL AS rpt_f25, NULL AS rpt_f26, NULL AS rpt_f27, NULL AS rpt_f28, NULL AS rpt_f29, NULL AS rpt_f30, NULL AS rpt_f31, NULL AS rpt_f32
                FROM t$tmp_2_1, patient AS p, document_type AS d
                WHERE t$tmp_2_1.ehr_number IN (SELECT
                    ehr_number
                    FROM t$tmp_2 AS a, patient AS p, document_type AS d
                    WHERE UPPER(ehr_doc_no) = p.other_doc_no AND SUBSTRING(p.filler, 1, 1) = d.document_code AND a.ehr_doc_type =
                    CASE d.document_type
                        WHEN 'AE' THEN 'AR'
                        WHEN 'AN' THEN 'AR'
                        WHEN 'BE' THEN 'BC'
                        WHEN 'BN' THEN 'BC'
                        ELSE d.document_type
                    END
                    GROUP BY ehr_number
                    HAVING COUNT(ehr_number) > 1) AND UPPER(ehr_doc_no) = p.other_doc_no AND SUBSTRING(p.filler, 1, 1) = d.document_code AND t$tmp_2_1.ehr_doc_type =
                CASE d.document_type
                    WHEN 'AE' THEN 'AR'
                    WHEN 'AN' THEN 'AR'
                    WHEN 'BE' THEN 'BC'
                    WHEN 'BN' THEN 'BC'
                    ELSE d.document_type
                END;
			return next p_refcur;
            DROP TABLE t$tmp_2;
            DROP TABLE t$tmp_2_1;
        END;
    END IF;

    IF (par_report_no = '3') THEN
        BEGIN
            CREATE TEMPORARY TABLE t$tmp_3
            AS
            SELECT
                t.evt_txn_dtm, t.ehr_flag, t.ehr_number, t.ehr_start_date, 'N/A' AS update_dtm, 'N/A' AS update_by, t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob
                FROM ehr_event_txn AS t, ehr_patient_list AS p
                WHERE t.ehr_flag = 'MKD' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
            UNION
            SELECT
                t.evt_txn_dtm, t.ehr_flag, t.ehr_number, t.ehr_start_date, COALESCE(CONCAT(REPLACE(to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A'), 'eHR', t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob
                FROM ehr_event_txn AS t, ehr_patient_list AS p
                WHERE t.ehr_flag = 'MKU' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
            UNION
            SELECT
                t.evt_txn_dtm, t.ehr_flag, t.ehr_number, t.ehr_start_date, COALESCE(CONCAT(REPLACE(to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A'), 'HA', t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob
                FROM ehr_event_txn AS t, ehr_patient_list AS p
                WHERE t.ehr_flag = 'MKC' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
            UNION
            SELECT
                t.evt_txn_dtm, t.ehr_flag, t.ehr_number, t.ehr_start_date, COALESCE(CONCAT(REPLACE(to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A'), 'eHR', t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob
                FROM ehr_event_txn AS t, ehr_patient_list AS p
                WHERE t.ehr_flag = 'MKE' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
            UNION
            SELECT
                t.evt_txn_dtm, t.ehr_flag, t.ehr_number, t.ehr_start_date,
                 COALESCE(CONCAT(REPLACE(to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A'), 'HA', t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob
                FROM ehr_event_txn AS t, ehr_patient_list AS p
                WHERE t.ehr_flag = 'MKP' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
            UNION
            SELECT
                t.evt_txn_dtm, t.ehr_flag, t.ehr_number, t.ehr_start_date, COALESCE(CONCAT(REPLACE(to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A'),
                CASE evt_log_type
                    WHEN 'T' THEN 'HA'
                    ELSE 'eHR'
                END, t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob
                FROM ehr_event_txn AS t, ehr_patient_list AS p
                WHERE t.ehr_flag = 'MKM' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y';
            CREATE TEMPORARY TABLE t$tmp_3_1
            AS
            SELECT
                ehr_number, MAX(evt_txn_dtm) AS evt_txn_dtm
                FROM t$tmp_3
                WHERE evt_txn_dtm BETWEEN
                CASE par_report_start_dtm
                    WHEN NULL THEN '19700101'
                    ELSE par_report_start_dtm
                END AND
                CASE par_report_end_dtm
                    WHEN NULL THEN timestamp_convert(localtimestamp)
                    ELSE par_report_end_dtm
                END
                GROUP BY ehr_number;
            OPEN p_refcur FOR
            SELECT
                REPLACE(to_char(var_report_date::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-') AS report_date, 3 AS report_id, t.ehr_flag AS rpt_f1, t.ehr_number AS rpt_f2,
                /* --,isnull(str_replace(convert(VARCHAR(15), t.ehr_start_date, 106), ' ', '-'), 'N/A') rpt_f3 */
                COALESCE(REPLACE(TO_CHAR(t.ehr_start_date, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f3,
                t."update_dtm" AS rpt_f4, t."update_by" AS rpt_f5, t.ehr_hkic AS rpt_f6, t.ehr_doc_type AS rpt_f7, t.ehr_doc_no AS rpt_f8, t.ehr_full_name AS rpt_f9, t.ehr_sex AS rpt_f10,
                /* --,isnull(str_replace(convert(VARCHAR(15), t.ehr_dob, 106), ' ', '-'), 'N/A') rpt_f11 */
                COALESCE(REPLACE(TO_CHAR(t.ehr_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f11,
                t.ehr_exact_dob AS rpt_f12, t.pas_hkic AS rpt_f13, t.pas_doc_type AS rpt_f14, t.pas_doc_no AS rpt_f15, t.pas_full_name AS rpt_f16, t.pas_sex AS rpt_f17,
                /* --,isnull(str_replace(convert(VARCHAR(15), t.pas_dob, 106), ' ', '-'), 'N/A')  rpt_f18 */
                COALESCE(REPLACE(TO_CHAR(t.pas_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f18,
                t.pas_exact_dob AS rpt_f19, NULL AS rpt_f20, NULL AS rpt_f21, NULL AS rpt_f22, NULL AS rpt_f23, NULL AS rpt_f24, NULL AS rpt_f25, NULL AS rpt_f26, NULL AS rpt_f27, NULL AS rpt_f28, NULL AS rpt_f29, NULL AS rpt_f30, NULL AS rpt_f31, NULL AS rpt_f32
                FROM t$tmp_3 AS t, t$tmp_3_1 AS p
                WHERE t.ehr_number = p.ehr_number AND t.evt_txn_dtm = p.evt_txn_dtm;
				return next p_refcur;
            DROP TABLE t$tmp_3;
            DROP TABLE t$tmp_3_1;
        END;
    END IF;

    IF (par_report_no = '4') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                REPLACE(to_char(var_report_date::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-') AS report_date, 4 AS report_id, t.old_ehr_flag AS rpt_f1, t.ehr_flag AS rpt_f2, t.ehr_number AS rpt_f3,
                /* --,isnull(str_replace(convert(VARCHAR(15), t.ehr_start_date, 106), ' ', '-'), 'N/A') rpt_f4 */
                COALESCE(REPLACE(TO_CHAR(t.ehr_start_date, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f4,
                COALESCE(CONCAT(REPLACE(to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD MOn YYYY'), ' ', '-'), ' ', to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A') AS rpt_f5, t.ehr_hkic AS rpt_f6, t.ehr_doc_type AS rpt_f7, t.ehr_doc_no AS rpt_f8, t.ehr_full_name AS rpt_f9, t.ehr_sex AS rpt_f10,
                /* --,isnull(str_replace(convert(VARCHAR(15), t.ehr_dob, 106), ' ', '-'), 'N/A') rpt_f11 */
                COALESCE(REPLACE(TO_CHAR(t.ehr_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f11,
                t.ehr_exact_dob AS rpt_f12,
                CASE evt_txn_type
                    WHEN '020' THEN 'Merge HKIDs'
                    WHEN '031' THEN 'Update HKID'
                    ELSE ''
                END AS rpt_f13,
                CASE SUBSTRING(t.old_pas_hkic, 1, 1)
                    WHEN 'U' THEN 'N/A'
                    WHEN NULL THEN 'N/A'
                    ELSE t.old_pas_hkic
                END AS rpt_f14,
                CASE SUBSTRING(t.old_pas_hkic, 1, 1)
                    WHEN 'U' THEN t.old_pas_hkic
                    WHEN NULL THEN 'N/A'
                    ELSE 'N/A'
                END AS rpt_f15, t.old_pas_doc_type AS rpt_f16, t.old_pas_doc_no AS rpt_f17, t.old_pas_full_name AS rpt_f18, t.old_pas_sex AS rpt_f19,
                /* --,isnull(str_replace(convert(VARCHAR(15), t.old_pas_dob, 106), ' ', '-'), 'N/A') rpt_f20 */
                COALESCE(REPLACE(TO_CHAR(t.old_pas_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f20,
                t.old_pas_exact_dob AS rpt_f21,
                CASE SUBSTRING(t.pas_hkic, 1, 1)
                    WHEN 'U' THEN 'N/A'
                    WHEN NULL THEN 'N/A'
                    ELSE t.pas_hkic
                END AS rpt_f22,
                CASE SUBSTRING(t.pas_hkic, 1, 1)
                    WHEN 'U' THEN t.pas_hkic
                    WHEN NULL THEN 'N/A'
                    ELSE 'N/A'
                END AS rpt_f23, t.pas_doc_type AS rpt_f24, t.pas_doc_no AS rpt_f25, t.pas_full_name AS rpt_f26, t.pas_sex AS rpt_f27,
                /* --,isnull(str_replace(convert(VARCHAR(15), t.pas_dob, 106), ' ', '-'), 'N/A') rpt_f28 */
                COALESCE(REPLACE(TO_CHAR(t.pas_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f28,
                t.pas_exact_dob AS rpt_f29,
                CASE l.ehr_number
                    WHEN NULL THEN 'N'
                    ELSE 'Y'
                END AS rpt_f30, l.ehr_number AS rpt_f31, l.ehr_flag AS rpt_f32
                FROM ehr_event_txn AS t
                LEFT OUTER JOIN ehr_patient_list AS l
                    ON
                    CASE
                        WHEN SUBSTRING(t.pas_hkic, 1, 1) = 'U' THEN t.pas_doc_no
                        ELSE t.pas_hkic
                    END =
                    CASE l.ehr_doc_type
                        WHEN 'ID' THEN l.ehr_hkic
                        WHEN 'BC' THEN l.ehr_hkic
                        ELSE l.ehr_doc_no
                    END
                WHERE t.ehr_flag = 'MID' AND evt_txn_dtm BETWEEN
                CASE par_report_start_dtm
                    WHEN NULL THEN '19700101'
                    ELSE par_report_start_dtm
                END AND
                CASE par_report_end_dtm
                    WHEN NULL THEN timestamp_convert(localtimestamp)
                    ELSE par_report_end_dtm

                END;
				return next p_refcur;
        END;
    END IF;

    IF (par_report_no = '5') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                REPLACE(to_char(var_report_date::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-') AS report_date, 5 AS report_id, t.old_ehr_flag AS rpt_f1, t.ehr_flag AS rpt_f2, p.ehr_number AS rpt_f3,
                /* --,isnull(str_replace(convert(VARCHAR(15), p.ehr_start_date, 106), ' ', '-'), 'N/A') rpt_f4 */
                COALESCE(REPLACE(TO_CHAR(p.ehr_start_date, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f4,
                COALESCE(CONCAT(REPLACE(to_char(evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A') AS rpt_f5, old_ehr_hkic AS rpt_f6, old_ehr_doc_type AS rpt_f7, old_ehr_doc_no AS rpt_f8, old_ehr_full_name AS rpt_f9, old_ehr_sex AS rpt_f10,
                /* --,isnull(str_replace(convert(VARCHAR(15), old_ehr_dob, 106), ' ', '-'), 'N/A') rpt_f11 */
                COALESCE(REPLACE(TO_CHAR(old_ehr_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f11,
                old_ehr_exact_dob AS rpt_f12, t.ehr_hkic AS rpt_f13, t.ehr_doc_type AS rpt_f14, t.ehr_doc_no AS rpt_f15, t.ehr_full_name AS rpt_f16, t.ehr_sex AS rpt_f17,
                /* --,isnull(str_replace(convert(VARCHAR(15), t.ehr_dob, 106), ' ', '-'), 'N/A') rpt_f18 */
                COALESCE(REPLACE(TO_CHAR(t.ehr_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f18,
                t.ehr_exact_dob AS rpt_f19, NULL AS rpt_f20, NULL AS rpt_f21, NULL AS rpt_f22, NULL AS rpt_f23, NULL AS rpt_f24, NULL AS rpt_f25, NULL AS rpt_f26, NULL AS rpt_f27, NULL AS rpt_f28, NULL AS rpt_f29, NULL AS rpt_f30, NULL AS rpt_f31, NULL AS rpt_f32
                FROM ehr_event_txn AS t, ehr_patient_list AS p
                WHERE evt_txn_type = 'MKC' AND evt_code = 'ADT_A47' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y' AND t.sys_dtm BETWEEN
                CASE par_report_start_dtm
                    WHEN NULL THEN '19700101'
                    ELSE par_report_start_dtm
                END AND
                CASE par_report_end_dtm
                    WHEN NULL THEN timestamp_convert(localtimestamp)
                    ELSE par_report_end_dtm

                END;
				return next p_refcur;
        END;
    END IF;

    IF (par_report_no = '6') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                REPLACE(to_char(var_report_date::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-') AS report_date, 6 AS report_id,
                /* --,isnull(str_replace(convert(VARCHAR(15), t.ehr_start_date, 106), ' ', '-'), 'N/A') rpt_f1 */
                COALESCE(REPLACE(TO_CHAR(t.ehr_start_date, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f1,
                t.ehr_number AS rpt_f2, t.ehr_doc_type AS rpt_f3, t.ehr_doc_no AS rpt_f4, t.ehr_full_name AS rpt_f5, t.ehr_sex AS rpt_f6,
                /* --,isnull(str_replace(convert(VARCHAR(15), t.ehr_dob, 106), ' ', '-'), 'N/A') rpt_f7 */
                COALESCE(REPLACE(TO_CHAR(t.ehr_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f7,
                t.ehr_exact_dob AS rpt_f8, COALESCE(CONCAT(REPLACE(to_char(r.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(r.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A') AS rpt_f9, r.ehr_hkic AS rpt_f10, r.ehr_doc_type AS rpt_f11, r.ehr_full_name AS rpt_f12, r.ehr_sex AS rpt_f13,
                /* --,isnull(str_replace(convert(VARCHAR(15), r.ehr_dob, 106), ' ', '-'), 'N/A') rpt_f14 */
                COALESCE(REPLACE(TO_CHAR(r.ehr_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f14,
                r.ehr_exact_dob AS rpt_f15, p.ehr_flag AS rpt_f16, a.hkid AS rpt_f17, d.document_type AS rpt_f18, a.other_doc_no AS rpt_f19, a.patient_name AS rpt_f20, a.sex AS rpt_f21, a.dob AS rpt_f22, a.exact_dob_flag AS rpt_f23, NULL AS rpt_f24, NULL AS rpt_f25, NULL AS rpt_f26, NULL AS rpt_f27, NULL AS rpt_f28, NULL AS rpt_f29, NULL AS rpt_f30, NULL AS rpt_f31, NULL AS rpt_f32
                FROM ehr_event_txn AS t, ehr_patient_list AS p
                LEFT OUTER JOIN ehr_event_txn AS r
                    ON p.ehr_number = r.ehr_number AND r.evt_txn_type = 'MKC' AND r.evt_code = 'ADT_A47' AND r.evt_txn_dtm = (SELECT
                        MAX(evt_txn_dtm)
                        FROM ehr_event_txn AS x
                        WHERE p.ehr_number = x.ehr_number AND x.evt_txn_type = 'MKC' AND x.evt_code = 'ADT_A47')
                LEFT OUTER JOIN patient AS a
                    ON p.pas_pky = a.patient_key
                LEFT OUTER JOIN document_type AS d
                    ON SUBSTRING(a.filler, 1, 1) = d.document_code
                WHERE t.evt_txn_dtm = (SELECT
                    MIN(evt_txn_dtm)
                    FROM ehr_event_txn AS t2
                    WHERE t.ehr_number = t2.ehr_number) AND t.evt_code = 'ADT_A28' AND t.evt_txn_type = 'ENT' AND t.ehr_doc_type = 'ED' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y';
				return next p_refcur;        
END;
    END IF;
    /*
    
    DROP TABLE IF EXISTS t$tmp_2;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$tmp_2_1;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$tmp_3;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$tmp_3_1;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;


ALTER FUNCTION "ehr_gen_report_portal" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
