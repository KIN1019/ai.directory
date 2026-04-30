CREATE OR REPLACE PROCEDURE ehr_gen_report(INOUT pas_return_code int, IN par_report_no VARCHAR, IN par_report_start_dtm TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL, IN par_report_end_dtm TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL, INOUT p_refcur refcursor DEFAULT NULL)
AS 
$BODY$
BEGIN
    /* ---------------------------------------------------------------------------------- */
    /* --																				-- */
    /* ---------------------------------------------------------------------------------- */
    IF (par_report_no = '1') THEN
        BEGIN
            OPEN p_refcur FOR
                SELECT
                    code_field, 
                    code_field_full_desc, 
                    COALESCE(ehr_cnt, 0) AS ehr_cnt, 
                    COALESCE(ppi_cnt, 0) AS ppi_cnt
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
                WHERE t.code_type = 'EHR_FLAG' AND t.code_name = 'ehr_flag'
                ORDER BY
                CASE
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
                            ELSE 12
                END NULLS FIRST;
                pas_return_code := 0;
                RETURN;
            END;
    END IF;

    IF (par_report_no = '2') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT t.ehr_flag
                ,t.ehr_number
                ,CASE uponafter
                    WHEN 1
                        THEN 'After'
                    ELSE 'Upon'
                    END AS uponafter
                ,COALESCE(TO_CHAR(t.ehr_start_date::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS ehr_start_date
                ,COALESCE(TO_CHAR(t.evt_txn_dtm, 'DD-Mon-YYYY'), 'N/A') AS evt_txn_dtm
                ,t.ehr_doc_type
                ,t.ehr_doc_no
                ,t.ehr_full_name
                ,t.ehr_sex
                ,COALESCE(TO_CHAR(t.ehr_dob::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS ehr_dob
                ,t.ehr_exact_dob
                ,t.hkid
                ,t.document_type
                ,t.other_doc_no
                ,t.patient_name
                ,t.sex
                ,COALESCE(TO_CHAR(t.dob, 'DD-Mon-YYYY'), 'N/A') AS dob
                ,t.exact_dob_flag
            FROM (
                SELECT t.ehr_flag
                    ,t.ehr_number
                    ,(
                        SELECT 1
                        WHERE EXISTS (
                                SELECT *
                                FROM ehr_event_txn n
                                WHERE n.ehr_number = t.ehr_number
                                    AND n.evt_txn_dtm < t.evt_txn_dtm
                                )
                        ) AS uponafter
                    ,t.ehr_start_date::TIMESTAMP AS ehr_start_date
                    ,t.evt_txn_dtm
                    ,ehr_doc_type
                    ,ehr_doc_no
                    ,ehr_full_name
                    ,ehr_sex
                    ,ehr_dob::TIMESTAMP AS ehr_dob
                    ,ehr_exact_dob
                    ,p.hkid
                    ,d.document_type
                    ,p.other_doc_no
                    ,p.patient_name
                    ,p.sex
                    ,p.dob AS dob
                    ,p.exact_dob_flag
                FROM ehr_event_txn t
                    ,patient p
                    ,document_type d
                WHERE ehr_number IN (
                        SELECT ehr_number
                        FROM (
                            SELECT t.evt_txn_dtm, t.evt_txn_type, t.evt_code, t.evt_log_type, t.evt_msg_no, t.evt_ack, t.ehr_flag, t.ehr_number, t.ehr_start_date, t.ehr_end_date, t.ehr_hkic, t.ehr_surname, t.ehr_givenname, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.ehr_doc_type, t.ehr_doc_no, t.ehr_death_date, t.ehr_death_time, t.ehr_exact_death, t.ehr_death_ind, t.old_ehr_number, t.old_ehr_flag, t.old_ehr_hkic, t.old_ehr_surname, t.old_ehr_givenname, t.old_ehr_full_name, t.old_ehr_sex, t.old_ehr_dob, t.old_ehr_exact_dob, t.old_ehr_doc_type, t.old_ehr_doc_no, t.pas_hosp, t.pas_hkic, t.pas_pky, t.pas_case, t.pas_surname, t.pas_givenname, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob, t.pas_doc_type, t.pas_doc_no, t.pas_death_date, t.pas_death_time, t.pas_exact_death, t.pas_death_ind, t.old_pas_hkic, t.old_pas_pky, t.old_pas_surname, t.old_pas_givenname, t.old_pas_full_name, t.old_pas_sex, t.old_pas_dob, t.old_pas_exact_dob, t.old_pas_doc_type, t.old_pas_doc_no, t.upd_by, t.upd_sys, t.upd_hosp, t.upd_host, t.sys_dtm, t.ehr_ppi_ind, t.ehr_non_ha_ind, t.ehr_status, t.old_ehr_ppi_ind, t.old_ehr_non_ha_ind, t.old_ehr_status
                            FROM ehr_event_txn t
                                ,ehr_patient_list l
                            WHERE l.ehr_ppi_ind = 'Y'
                                AND t.ehr_number = l.ehr_number
                                AND t.ehr_flag = l.ehr_flag
                                AND t.ehr_flag = 'NID'
                                AND t.ehr_doc_type <> 'ID'
                                AND t.sys_dtm BETWEEN CASE par_report_start_dtm
                                            WHEN NULL
                                                THEN '19700101'::TIMESTAMP
                                            ELSE par_report_start_dtm
                                            END
                                    AND CASE par_report_end_dtm
                                            WHEN NULL
                                                THEN timestamp_convert(localtimestamp)
                                            ELSE par_report_end_dtm
                                            END
                            ) t
                            ,patient p
                            ,document_type d
                        WHERE t.ehr_doc_no = p.other_doc_no
                            AND substring(p.filler, 1, 1) = d.document_code
                            AND t.ehr_doc_type = CASE d.document_type
                                WHEN 'AE'
                                    THEN 'AR'
                                WHEN 'AN'
                                    THEN 'AR'
                                WHEN 'BE'
                                    THEN 'BC'
                                WHEN 'BN'
                                    THEN 'BC'
                                ELSE d.document_type
                                END
                        GROUP BY ehr_number
                            ,evt_txn_type
                        HAVING count(ehr_number) > 1
                        )
                    AND ehr_flag = 'NID'
                    AND ehr_doc_type <> 'ID'
                    AND sys_dtm BETWEEN CASE par_report_start_dtm
                                WHEN NULL
                                    THEN '19700101'::TIMESTAMP
                                ELSE par_report_start_dtm
                                END
                        AND CASE par_report_end_dtm
                                WHEN NULL
                                    THEN timestamp_convert(localtimestamp)
                                ELSE par_report_end_dtm
                                END
                    AND t.ehr_doc_no = p.other_doc_no
                    AND substring(p.filler, 1, 1) = d.document_code
                    AND t.ehr_doc_type = CASE d.document_type
                        WHEN 'AE'
                            THEN 'AR'
                        WHEN 'AN'
                            THEN 'AR'
                        WHEN 'BE'
                            THEN 'BC'
                        WHEN 'BN'
                            THEN 'BC'
                        ELSE d.document_type
                        END
                ORDER BY ehr_number
                    ,evt_txn_dtm
                ) t;
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
            
    IF (par_report_no = '3') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                l.ehr_flag, 
                l.ehr_number, 
                COALESCE(TO_CHAR(l.ehr_start_date::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS ehr_start_date,
                CASE t.ehr_flag
                    WHEN 'MKD' THEN 'N/A'
                    ELSE COALESCE(TO_CHAR(t.evt_txn_dtm, 'DD-Mon-YYYY'), 'N/A')
                END AS upd_dtm,
                CASE
                    WHEN t.ehr_flag = 'MKD' THEN 'N/A'
                    WHEN t.evt_log_type = 'I' THEN 'eHR'
                    ELSE 'HA'
                END AS upd_by, t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, 
                COALESCE(TO_CHAR(t.ehr_dob::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS ehr_dob, 
                t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, 
                COALESCE(TO_CHAR(t.pas_dob::TIMESTAMP, 'DD-Mon-YYYY'), 'N/A') AS pas_dob, t.pas_exact_dob
                FROM ehr_event_txn AS t, ehr_patient_list AS l
                WHERE t.ehr_flag IN ('MKD', 'MKC', 'MKU', 'MKE', 'MKP', 'MKM') AND t.ehr_number = l.ehr_number AND t.ehr_flag = l.ehr_flag AND l.ehr_ppi_ind = 'Y' AND t.sys_dtm BETWEEN
                CASE par_report_start_dtm
                    WHEN NULL THEN '19700101'::TIMESTAMP
                    ELSE par_report_start_dtm
                END AND
                CASE par_report_end_dtm
                    WHEN NULL THEN timestamp_convert(localtimestamp)
                    ELSE par_report_end_dtm
                END
			UNION
	            SELECT
                l.ehr_flag, l.ehr_number, COALESCE(TO_CHAR(l.ehr_start_date::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS ehr_start_date, 'N/A', 'N/A', t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, 
                COALESCE(TO_CHAR(t.ehr_dob::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS ehr_dob, 
                t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, 
                COALESCE(TO_CHAR(t.pas_dob::TIMESTAMP, 'DD-Mon-YYYY'), 'N/A') AS pas_dob, 
                t.pas_exact_dob
                FROM ehr_event_txn AS t, ehr_patient_list AS l
                WHERE evt_code = 'EXG_EHR_PAS' AND t.ehr_ppi_ind = 'Y' AND t.evt_txn_dtm BETWEEN
                CASE par_report_start_dtm
                    WHEN NULL THEN '19700101'::TIMESTAMP
                    ELSE par_report_start_dtm
                END AND
                CASE par_report_end_dtm
                    WHEN NULL THEN timestamp_convert(localtimestamp)
                    ELSE par_report_end_dtm
                END AND t.old_ehr_ppi_ind IS NULL AND t.ehr_number = l.ehr_number AND l.ehr_flag IN ('MKD', 'MKU', 'MKC', 'MKE', 'MKP', 'MKM');

            pas_return_code := 0;
            RETURN;
        END;
    END IF;

    IF (par_report_no = '4') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                a.ehr_flag AS from_flag, 
                a.ehr_number, 
                a.ehr_start_date, 
                a.upd_dtm, 
                a.ehr_hkic, 
                a.ehr_doc_type, 
                a.ehr_doc_no, 
                a.ehr_full_name, 
                a.ehr_sex, 
                a.ehr_dob, 
                a.ehr_exact_dob, 
                a.reason, 
                a.old_pas_hkic, 
                a.old_pas_doc_type, 
                a.old_pas_doc_no, 
                a.old_pas_full_name, 
                a.old_pas_sex, 
                a.old_pas_dob, 
                a.old_pas_exact_dob, 
                a.pas_hkic, 
                a.pas_doc_type, 
                a.pas_doc_no, 
                a.pas_full_name, 
                a.pas_sex, 
                a.pas_dob, 
                a.pas_exact_dob,
                CASE l.ehr_number WHEN NULL THEN 'N' ELSE 'Y' END AS is_ehr, 
                l.ehr_number AS link_ehr_number, 
                l.ehr_flag AS link_ehr_flag, 
                a.old_ehr_flag AS to_flag
                FROM (SELECT
                    t.old_ehr_flag, l.ehr_flag, l.ehr_number, 
                    COALESCE(TO_CHAR(l.ehr_start_date::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS ehr_start_date, 
                    COALESCE(TO_CHAR(t.evt_txn_dtm, 'DD-Mon-YYYY'), 'N/A') AS upd_dtm, 
                    l.ehr_hkic, l.ehr_doc_type, l.ehr_doc_no, l.ehr_full_name, l.ehr_sex, 
                    COALESCE(TO_CHAR(l.ehr_dob::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS ehr_dob, 
                    l.ehr_exact_dob,
                    CASE t.evt_txn_type
                        WHEN '020' THEN 'Merge HKIDs'
                        WHEN '031' THEN 'Update HKID'
                        ELSE ''
                    END AS reason, t.old_pas_hkic, t.old_pas_doc_type, t.old_pas_doc_no, t.old_pas_full_name, t.old_pas_sex, 
                    COALESCE(TO_CHAR(t.old_ehr_dob::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS old_pas_dob, 
                    t.old_pas_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, 
                    COALESCE(TO_CHAR(t.pas_dob::TIMESTAMP, 'DD-Mon-YYYY'), 'N/A') AS pas_dob, t.pas_exact_dob
                    FROM ehr_patient_list AS l, ehr_event_txn AS t
                    WHERE l.ehr_flag = 'MID' AND l.ehr_number = t.ehr_number AND l.ehr_flag = t.ehr_flag AND l.upd_dtm = t.evt_txn_dtm AND l.ehr_ppi_ind = 'Y' AND t.sys_dtm BETWEEN
                CASE par_report_start_dtm
                    WHEN NULL THEN '19700101'::TIMESTAMP
                    ELSE par_report_start_dtm
                END AND
                CASE par_report_end_dtm
                    WHEN NULL THEN timestamp_convert(localtimestamp)
                    ELSE par_report_end_dtm
                END) AS a
                LEFT OUTER JOIN ehr_patient_list AS l
                    ON a.pas_doc_type = l.ehr_doc_type AND
                    CASE l.ehr_doc_type
                        WHEN 'ID' THEN l.ehr_hkic
                        ELSE l.ehr_doc_no
                    END =
                    CASE a.pas_doc_type
                        WHEN 'ID' THEN a.pas_hkic
                        ELSE a.pas_doc_no
                    END;
            pas_return_code := 0;
            RETURN;
        END;
    END IF;

    IF (par_report_no = '5') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT a.ehr_flag AS from_flag
                ,a.ehr_number
                ,COALESCE(TO_CHAR(a.ehr_start_date::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS ehr_start_date
                ,COALESCE(TO_CHAR(a.evt_txn_dtm, 'DD-Mon-YYYY'), 'N/A') AS evt_txn_dtm
                ,a.old_ehr_hkic
                ,a.old_ehr_doc_type
                ,a.old_ehr_doc_no
                ,a.old_ehr_full_name
                ,a.old_ehr_sex
                ,COALESCE(TO_CHAR(a.old_ehr_dob::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS old_ehr_dob
                ,a.old_ehr_exact_dob
                ,a.ehr_hkic
                ,a.ehr_doc_type
                ,a.ehr_doc_no
                ,a.ehr_full_name
                ,a.ehr_sex
                ,COALESCE(TO_CHAR(a.ehr_dob::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS ehr_dob
                ,a.ehr_exact_dob
                ,e.ehr_flag AS to_flag
            FROM (
                SELECT a.ehr_flag
                    ,a.ehr_number
                    ,a.ehr_start_date
                    ,a.evt_txn_dtm
                    ,a.old_ehr_hkic
                    ,a.old_ehr_doc_type
                    ,a.old_ehr_doc_no
                    ,a.old_ehr_full_name
                    ,a.old_ehr_sex
                    ,a.old_ehr_dob
                    ,a.old_ehr_exact_dob
                    ,a.ehr_hkic
                    ,a.ehr_doc_type
                    ,a.ehr_doc_no
                    ,a.ehr_full_name
                    ,a.ehr_sex
                    ,a.ehr_dob
                    ,a.ehr_exact_dob
                    ,a.sys_dtm
                    ,max(e.sys_dtm) AS sys_dtm1
                FROM (
                    SELECT t.ehr_flag
                        ,t.ehr_number
                        ,COALESCE(TO_CHAR(t.ehr_start_date::TIMESTAMP, 'YYYYMMDD'), 'N/A')::TIMESTAMP AS ehr_start_date
                        ,COALESCE(TO_CHAR(t.evt_txn_dtm, 'YYYYMMDD'), 'N/A')::TIMESTAMP AS evt_txn_dtm
                        ,old_ehr_hkic
                        ,old_ehr_doc_type
                        ,old_ehr_doc_no
                        ,old_ehr_full_name
                        ,old_ehr_sex
                        ,old_ehr_dob
                        ,old_ehr_exact_dob
                        ,t.ehr_hkic
                        ,t.ehr_doc_type
                        ,t.ehr_doc_no
                        ,t.ehr_full_name
                        ,t.ehr_sex
                        ,t.ehr_dob
                        ,t.ehr_exact_dob
                        ,t.sys_dtm
                    FROM ehr_event_txn t
                        ,ehr_patient_list l
                    WHERE t.evt_code = 'ADT_A47'
                        AND (
                            t.ehr_hkic <> t.old_ehr_hkic
                            OR t.ehr_doc_no <> t.old_ehr_doc_no
                            OR t.ehr_doc_type <> t.old_ehr_doc_type
                            )
                        AND t.evt_txn_type = 'MKC'
                        AND t.ehr_flag = 'NID'
                        AND t.ehr_flag = l.ehr_flag
                        AND t.ehr_number = l.ehr_number
                        AND l.ehr_ppi_ind = 'Y'
                    ) a
                    ,ehr_event_txn e
                WHERE a.ehr_number = e.ehr_number
                    AND coalesce(a.old_ehr_hkic, '') = coalesce(e.ehr_hkic, '')
                    AND a.old_ehr_doc_type = e.ehr_doc_type
                    AND coalesce(a.old_ehr_doc_no, '') = coalesce(e.ehr_doc_no, '')
                    AND a.old_ehr_full_name = e.ehr_full_name
                    AND a.old_ehr_sex = e.ehr_sex
                    AND a.old_ehr_dob = e.ehr_dob
                    AND a.old_ehr_exact_dob = e.ehr_exact_dob
                    AND e.sys_dtm < a.sys_dtm
                    AND a.sys_dtm BETWEEN CASE par_report_start_dtm
                                WHEN NULL
                                    THEN '19700101'::TIMESTAMP
                                ELSE par_report_start_dtm
                                END
                        AND CASE par_report_end_dtm
                                WHEN NULL
                                    THEN timestamp_convert(localtimestamp)
                                ELSE par_report_end_dtm
                                END
                GROUP BY a.ehr_flag
                    ,a.ehr_number
                    ,a.ehr_start_date
                    ,a.evt_txn_dtm
                    ,a.old_ehr_hkic
                    ,a.old_ehr_doc_type
                    ,a.old_ehr_doc_no
                    ,a.old_ehr_full_name
                    ,a.old_ehr_sex
                    ,a.old_ehr_dob
                    ,a.old_ehr_exact_dob
                    ,a.ehr_hkic
                    ,a.ehr_doc_type
                    ,a.ehr_doc_no
                    ,a.ehr_full_name
                    ,a.ehr_sex
                    ,a.ehr_dob
                    ,a.ehr_exact_dob
                    ,a.sys_dtm
                ) a
                ,ehr_event_txn e
            WHERE a.ehr_number = e.ehr_number
                AND a.sys_dtm1 = e.sys_dtm
                AND e.ehr_flag <> 'NID';
            pas_return_code := 0;
            RETURN;
        END;
    END IF;

    IF (par_report_no = '6') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                COALESCE(TO_CHAR(t.ehr_start_date::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS ehr_start_date, 
                t.ehr_number, t.ehr_doc_type AS u_ehr_doc_type, 
                t.ehr_doc_no AS u_ehr_doc_no, t.ehr_full_name AS u_ehr_full_name, 
                t.ehr_sex AS u_ehr_sex, 
                COALESCE(TO_CHAR(t.ehr_dob::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS u_ehr_dob, 
                t.ehr_exact_dob AS u_ehr_exact_dob, 
                COALESCE(TO_CHAR(r.evt_txn_dtm, 'DD-Mon-YYYY'), 'N/A') AS a_upd_dtm, 
                r.ehr_hkic AS a_ehr_hkic, 
                r.ehr_doc_type AS a_ehr_doc_type, 
                r.ehr_doc_no AS a_ehr_doc_no, 
                r.ehr_full_name AS a_ehr_full_name, 
                r.ehr_sex AS a_ehr_sex, 
                COALESCE(TO_CHAR(t.ehr_dob::TIMESTAMP, 'YYYYMMDD'), 'N/A') AS a_ehr_dob, 
                r.ehr_exact_dob AS a_ehr_exact_dob, 
                l.ehr_flag,
                CASE l.ehr_flag WHEN 'NID' THEN NULL WHEN 'DDR' THEN NULL ELSE l.pas_hkic END AS pas_hkic, 
                l.pas_doc_type, 
                l.pas_doc_no, 
                l.pas_full_name, 
                l.pas_sex, l.pas_dob, 
                l.pas_exact_dob
                FROM ehr_event_txn AS t, ehr_patient_list AS l
                LEFT OUTER JOIN ehr_event_txn AS r
                    ON l.ehr_number = r.ehr_number AND r.evt_txn_type = 'MKC' AND r.evt_code = 'ADT_A47' AND r.evt_txn_dtm = (SELECT
                        MAX(evt_txn_dtm)
                        FROM ehr_event_txn AS x
                        WHERE x.ehr_number = l.ehr_number AND x.evt_txn_type = 'MKC' AND x.evt_code = 'ADT_A47')
                                WHERE t.evt_txn_dtm = (SELECT
                    MIN(t2.evt_txn_dtm)
                    FROM ehr_event_txn AS t2
                    WHERE t.ehr_number = t2.ehr_number) AND t.evt_code = 'ADT_A28' AND t.ehr_doc_type = 'ED' AND t.evt_txn_type = 'ENT' AND t.ehr_number = l.ehr_number AND l.ehr_ppi_ind = 'Y';
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    /* ----------------------- */
    /* Invalid Report No -- */
    
    /* ----------------------- */
    pas_return_code := - 1;
    RETURN;
END;
/* ----------------------------------------------------------------------------- */
/* DDL for Stored Procedure 'hkpmi.dbo.ehr_pas_me_polling' */

/* ----------------------------------------------------------------------------- */
$BODY$
LANGUAGE plpgsql;

;ALTER PROCEDURE "ehr_gen_report" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";