-- DROP FUNCTION hpi.web_check_local_linked_case(varchar, varchar, timestamp);

CREATE OR REPLACE FUNCTION hpi.web_check_local_linked_case(par_hosp_code character varying, par_hkid character varying, par_adm_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_rtn_code INTEGER;
    var_prk_key VARCHAR(8);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_hkpmi_srvr VARCHAR(60);
    var_retcode INTEGER;
    var_rpc_call VARCHAR(200);
    var_pgm_name VARCHAR(100);
    var_lnk_hosp_code VARCHAR(6);
    var_lnk_case_no VARCHAR(24);
    var_lnk_doc_code VARCHAR(4);
    var_doc_type VARCHAR(4);
    var_lnk_eh_code VARCHAR(16);
    p_refcur refcursor;
    pas_return_code INTEGER;
    temp_lnk_csr CURSOR FOR
    SELECT
        lnk_hosp_code, lnk_case_no, lnk_doc_type
        FROM t$temp_linked_case;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        /* ** for check_local * */
        DROP TABLE IF EXISTS t$temp_linked_case;
        CREATE TEMPORARY TABLE t$temp_linked_case
        (lnk_hosp_code VARCHAR(6),
            lnk_case_no VARCHAR(24),
            lnk_adm_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
            lnk_dsch_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
            lnk_last_ward VARCHAR(8) NULL,
            lnk_last_spec VARCHAR(8) NULL,
            lnk_dsch_code VARCHAR(2) NULL,
            lnk_dest_code VARCHAR(10) NULL,
            lnk_pay_code VARCHAR(6) NULL,
            lnk_eh_code VARCHAR(16) NULL,
            lnk_doc_type VARCHAR(4) NULL,
            lnk_pp_code VARCHAR(16) NULL);
        CREATE UNIQUE INDEX IF NOT EXISTS temp_linked_case_idx ON t$temp_linked_case
            (lnk_hosp_code, lnk_case_no);
        /* ** for check_local * */
        /* init */
        IF par_adm_dtm IS NULL THEN
            SELECT
                timestamp_convert(localtimestamp)
                INTO par_adm_dtm;
        END IF;
        /* B). Same logic as hkpmi_check_linked_case, EXCEPT doc_type is Cpi_case Level in CPI, doc_type is Patient Level in HKPMI */
        <<check_local>>
        BEGIN
            SELECT
                patient_key
                INTO var_prk_key
                FROM cpi_patient
                WHERE hkid = par_hkid;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) THEN /* --or (@rowcount = 0) */
            EXIT return_error;
        END IF;
        /* ---	goto check_hkpmi		---For New Patient NOT existed in Local CPI ... */
        /* ----- cond.1 Non discharged Case  --- */
        BEGIN
            INSERT INTO t$temp_linked_case
            SELECT
                hospital_code, case_no, admission_dtm, discharge_dtm, last_ward_code, last_specialty, discharge_code, destination_code, patient_type, NULL,
                /* --- eh_code */
                document_flag,
                /* ---- for HKPMI, doc_type is patient level; for CPI, doc_type is cpi_case level --- */
                pp_code
                FROM cpi_case
                WHERE patient_key = var_prk_key AND (case_no LIKE ' AE%' OR case_no LIKE ' HN%') AND
                /* ----- AE/HN cases only */
                discharge_code IS NULL AND status_code != 'CC'
                ORDER BY admission_dtm DESC NULLS FIRST;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) THEN /* or (@rowcount = 0) */
            EXIT return_error;
        END IF;
        /* -----cond.2 Discharged case within 24 Hrs ---- */
        BEGIN
            INSERT INTO t$temp_linked_case
            SELECT
                hospital_code, case_no, admission_dtm, discharge_dtm, last_ward_code, last_specialty, discharge_code, destination_code, patient_type, NULL,
                /* --- eh_code */
                document_flag,
                /* ---- for HKPMI, doc_type is patient level; for CPI, doc_type is cpi_case level --- */
                pp_code
                FROM cpi_case
                WHERE patient_key = var_prk_key AND (case_no SIMILAR TO ' AE%' OR case_no SIMILAR TO ' HN%') AND
                /* ----- AE/HN cases only */
                discharge_code IS NOT NULL AND discharge_dtm >= - 1 * INTERVAL '1 day' + par_adm_dtm::TIMESTAMP AND status_code != 'CC'
                ORDER BY admission_dtm DESC NULLS FIRST;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) THEN /* or (@rowcount = 0) */
            EXIT return_error;
        END IF;
        /* update doc_type and eh_code */
        SELECT
            NULL, NULL, NULL, NULL, NULL
            INTO var_doc_type, var_lnk_hosp_code, var_lnk_case_no, var_lnk_doc_code, var_lnk_eh_code;
        OPEN temp_lnk_csr;
        FETCH temp_lnk_csr INTO var_lnk_hosp_code, var_lnk_case_no, var_lnk_doc_code;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            SELECT
                eh_code
                INTO var_lnk_eh_code
                FROM cpi_case_detail
                WHERE hospital_code = par_hosp_code AND case_no = var_lnk_case_no;

            IF var_lnk_doc_code IS NULL OR (LTRIM(RTRIM(var_lnk_doc_code)) = '') THEN
                SELECT
                    NULL
                    INTO var_lnk_doc_code;
            END IF;

            IF var_lnk_doc_code IS NOT NULL THEN
                BEGIN
                    SELECT
                        document_type
                        INTO var_doc_type
                        FROM document_type
                        WHERE document_code = var_lnk_doc_code;
                    UPDATE t$temp_linked_case
                    SET lnk_doc_type = var_doc_type, lnk_eh_code = var_lnk_eh_code
                        WHERE lnk_hosp_code = var_lnk_hosp_code AND lnk_case_no = var_lnk_case_no;
                END;
            END IF;
            SELECT
                NULL, NULL, NULL, NULL, NULL
                INTO var_doc_type, var_lnk_hosp_code, var_lnk_case_no, var_lnk_doc_code, var_lnk_eh_code;
            FETCH temp_lnk_csr INTO var_lnk_hosp_code, var_lnk_case_no, var_lnk_doc_code;
        END LOOP;
        CLOSE temp_lnk_csr;
        OPEN p_refcur FOR
        SELECT
            RTRIM(t$temp_linked_case.lnk_hosp_code) AS lnk_hosp_code, t$temp_linked_case.lnk_case_no, t$temp_linked_case.lnk_adm_dtm, t$temp_linked_case.lnk_dsch_dtm, t$temp_linked_case.lnk_last_ward, t$temp_linked_case.lnk_last_spec, t$temp_linked_case.lnk_dsch_code, t$temp_linked_case.lnk_dest_code, t$temp_linked_case.lnk_pay_code, t$temp_linked_case.lnk_eh_code, t$temp_linked_case.lnk_doc_type, t$temp_linked_case.lnk_pp_code
            FROM t$temp_linked_case;
        /* DROP TABLE t$temp_linked_case; */
        RETURN NEXT p_refcur;
    END;
    /* DROP TABLE t$temp_linked_case; */
    RETURN;
END;
$function$
;

;ALTER FUNCTION "web_check_local_linked_case" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
