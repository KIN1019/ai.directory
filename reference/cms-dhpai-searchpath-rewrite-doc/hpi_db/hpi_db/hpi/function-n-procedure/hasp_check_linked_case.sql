-- DROP PROCEDURE hpi.hasp_check_linked_case(inout int4, in varchar, in varchar, in timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_check_linked_case(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_hkid character varying, IN par_adm_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rtn_code INTEGER;
    var_prk_key VARCHAR(16);
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
    temp_lnk_csr CURSOR FOR
    SELECT
        lnk_hosp_code, lnk_case_no, lnk_doc_type
        FROM t$temp_linked_case;
    var_return_code int;
    sql$rowcount BIGINT;
BEGIN
    /* ** for check_local * */
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
    CREATE UNIQUE INDEX t$temp_linked_case_idx ON t$temp_linked_case
        (lnk_hosp_code, lnk_case_no);
    /* ** for check_local * */
    /* init */
    IF par_adm_dtm IS NULL THEN
        SELECT
            timestamp_convert(localtimestamp)
            INTO par_adm_dtm;
    END IF;
    /* --- CHECK HKPMI Alive --- */

    <<return_error>>
    BEGIN
        <<return_normal>>
        BEGIN
            <<check_local>>
            BEGIN
                /*SELECT
                    NULL
                    INTO var_hkpmi_srvr;
                CALL cpi_get_rpc_server(var_return_code, 'HKPMI_SERVER', var_hkpmi_srvr);

                IF var_hkpmi_srvr IS NULL THEN
                    EXIT check_local;
                END IF;
                /* A). check HKPMI */
                SELECT
                    'hkpmi_check_linked_case'
                    INTO var_pgm_name;
                SELECT
                    CONCAT(LTRIM(RTRIM(var_hkpmi_srvr)), '.hkpmi.dbo.', LTRIM(RTRIM(var_pgm_name)))
                    INTO var_rpc_call;
                /* --- 7223, the login may be kill or existed abnormally. */
                perform public.dblink_connect('rpc_server'::text,var_hkpmi_srvr);
				SELECT * FROM public.dblink('rpc_server'::text,'call '
                || var_rpc_call || '('
				|| case when par_hosp_code is null then 'null::varchar' else concat('''', par_staff_hkid, '''::varchar') end || ','
				|| case when par_hkid is null then 'null::varchar' else concat('''', var_str_dependent_dob , '''::varchar') end || ','
                || case when par_adm_dtm is null then 'null::timestamp without time zone' else concat('''', par_exact_dob_ind, '''::timestamp without time zone') end || ');'::text)
                as t1(var_retcode VARCHAR) into var_retcode;

				perform public.dblink_disconnect('rpc_server'::text);
                IF var_retcode = 7223 THEN
                    /* --- retry once again */
                    
                    BEGIN
                        perform public.dblink_connect('rpc_server'::text,var_hkpmi_srvr);
                        SELECT * FROM public.dblink('rpc_server'::text,'call '
                        || var_rpc_call || '('
                        || case when par_hosp_code is null then 'null::varchar' else concat('''', par_staff_hkid, '''::varchar') end || ','
                        || case when par_hkid is null then 'null::varchar' else concat('''', var_str_dependent_dob , '''::varchar') end || ','
                        || case when par_adm_dtm is null then 'null::timestamp without time zone' else concat('''', par_exact_dob_ind, '''::timestamp without time zone') end || ');'::text)
                        as t1(var_retcode VARCHAR) into var_retcode;

                        perform public.dblink_disconnect('rpc_server'::text);
                    END;
                END IF;*/
	            
	            -- replace_dblink_by_fdw	                    
        		call hkpmi.hkpmi_check_linked_case(var_retcode,par_hosp_code ,par_hkid, par_adm_dtm);
       			SET search_path TO hpi,public;

                IF var_retcode <> 0 THEN
                    EXIT check_local;
                ELSE
                    BEGIN
                        DROP TABLE t$temp_linked_case;
                        EXIT return_normal /* Result from hkpmi */;
                    END;
                END IF;
                /* B). Same logic as hkpmi_check_linked_case, EXCEPT doc_type is Cpi_case Level in CPI, doc_type is Patient Level in HKPMI */
            END;

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

            IF (var_error != 0) OR (var_rowcount = 0) THEN
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
                    WHERE patient_key = var_prk_key AND (case_no SIMILAR TO ' AE%' OR case_no SIMILAR TO ' HN%') AND
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

                IF (LTRIM(RTRIM(var_lnk_doc_code)) = '') OR (LTRIM(RTRIM(var_lnk_doc_code)) = NULL) THEN
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
            SELECT
                COUNT(*)
                INTO var_rowcount
                FROM t$temp_linked_case;

            IF var_rowcount = 0 THEN
                /* ---- NO found linked case in local ... */
                BEGIN
                    DROP TABLE t$temp_linked_case;
                    pas_return_code := 0;
                    RETURN;
                    /* --goto check_hkpmi */
                END;
            END IF;
            /* --Adaptive Server has expanded all '*' elements in the following statement */
            OPEN p_refcur FOR
            SELECT
                t$temp_linked_case.lnk_hosp_code, t$temp_linked_case.lnk_case_no, t$temp_linked_case.lnk_adm_dtm, t$temp_linked_case.lnk_dsch_dtm, t$temp_linked_case.lnk_last_ward, t$temp_linked_case.lnk_last_spec, t$temp_linked_case.lnk_dsch_code, t$temp_linked_case.lnk_dest_code, t$temp_linked_case.lnk_pay_code, t$temp_linked_case.lnk_eh_code, t$temp_linked_case.lnk_doc_type, t$temp_linked_case.lnk_pp_code
                FROM t$temp_linked_case;
            DROP TABLE t$temp_linked_case;
            pas_return_code := 0;
            RETURN;
        END;
        pas_return_code := 0;
        RETURN;
    END;
    DROP TABLE t$temp_linked_case;
    <<check_hkpmi>>
    BEGIN
        pas_return_code := - 1;
        RETURN;
    END;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_check_linked_case" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
