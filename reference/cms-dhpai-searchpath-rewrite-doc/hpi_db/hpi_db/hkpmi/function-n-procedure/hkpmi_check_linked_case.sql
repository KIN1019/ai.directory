-- DROP PROCEDURE hkpmi.hkpmi_check_linked_case(inout int4, in varchar, in varchar, in timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_check_linked_case(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_hkid character varying, IN par_adm_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE

    var_rtn_code INTEGER := 0;
    var_prk_key VARCHAR(8);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_pat_doc_type VARCHAR(2);
    var_pat_doc_code VARCHAR(1);
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
	    SET LOCAL search_path TO hkpmi,public;
	    drop table if exists t$temp_linked_case;
        CREATE TEMPORARY TABLE t$temp_linked_case
        (lnk_hosp_code varchar(3),
            lnk_case_no varchar(12),
            lnk_adm_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
            lnk_dsch_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
            lnk_last_ward varchar(4) NULL,
            lnk_last_spec varchar(4) NULL,
            lnk_dsch_code varchar(1) NULL,
            lnk_dest_code varchar(5) NULL,
            lnk_pay_code varchar(3) NULL,
            lnk_eh_code varchar(8) NULL,
            lnk_doc_type varchar(2) NULL,
            lnk_pp_code varchar(8) NULL) on commit drop;
        create UNIQUE INDEX temp_linked_case_idx ON t$temp_linked_case
            (lnk_hosp_code, lnk_case_no);
        /* init */
        IF par_adm_dtm IS NULL THEN
            SELECT
                localtimestamp
                INTO par_adm_dtm;
        END IF;
        /* ---- for New patient : return -1	 => proceed Adm without Linked Episode --- */

        BEGIN
            SELECT
                patient_key, RTRIM(LTRIM(SUBSTRING(filler, 1, 1)))
                INTO var_prk_key, var_pat_doc_code
                FROM patient
                WHERE hkid = par_hkid;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_rtn_code;
                EXIT return_error;
            END;
        END IF;

        IF (var_pat_doc_code IS NOT NULL) OR (var_pat_doc_code <> '') THEN
            SELECT
                document_type
                INTO var_pat_doc_type
                FROM document_type
                WHERE document_code = var_pat_doc_code;
        END IF;
        /* ----- cond.1 Non discharged Case  --- */

        BEGIN
            INSERT INTO t$temp_linked_case
            SELECT
                hospital_code, case_no, adm_dtm, discharge_dtm, last_ward_code, last_specialty_code, discharge_code, destination_code, patient_type, SUBSTRING(filler, 2, 8),
                /* --- EH_Code */
                var_pat_doc_type,
                /* --- for HKPMI, doc_type is patient level; for CPI, doc_type is cpi_case level --- */
                pp_code
                FROM pmi_case
                WHERE patient_key = var_prk_key AND (case_no LIKE ' AE%' OR case_no LIKE ' HN%') AND
                /* ----- AE/HN cases only */
                discharge_code IS NULL
                ORDER BY adm_dtm DESC NULLS FIRST;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) THEN /* or (@rowcount = 0) */
            BEGIN
                SELECT
                    - 1
                    INTO var_rtn_code;
                EXIT return_error;
            END;
        END IF;
        /* -----cond.2 Discharged case within 24 Hrs ---- */
        BEGIN
            INSERT INTO t$temp_linked_case
            SELECT
                hospital_code, case_no, adm_dtm, discharge_dtm, last_ward_code, last_specialty_code, discharge_code, destination_code, patient_type, SUBSTRING(filler, 2, 8),
                /* --- eh_code */
                var_pat_doc_type,
                /* --- for HKPMI, doc_type is patient level; for CPI, doc_type is cpi_case level --- */
                pp_code
                FROM pmi_case
                WHERE patient_key = var_prk_key AND (case_no LIKE ' AE%' OR case_no LIKE ' HN%') AND
                /* ----- AE/HN cases only */
                discharge_code IS NOT NULL AND discharge_dtm >= - 1 * INTERVAL '1 day' + par_adm_dtm::TIMESTAMP /* ---discharged cases within 24 hrs */
                ORDER BY adm_dtm DESC NULLS FIRST;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;
       
        IF (var_error != 0) THEN /* or (@rowcount = 0) */
            BEGIN
                SELECT
                    - 1
                    INTO var_rtn_code;
                EXIT return_error;
            END;
        END IF;
        OPEN p_refcur FOR
        SELECT
            t$temp_linked_case.lnk_hosp_code, t$temp_linked_case.lnk_case_no, t$temp_linked_case.lnk_adm_dtm, t$temp_linked_case.lnk_dsch_dtm, t$temp_linked_case.lnk_last_ward, t$temp_linked_case.lnk_last_spec, t$temp_linked_case.lnk_dsch_code, t$temp_linked_case.lnk_dest_code, t$temp_linked_case.lnk_pay_code, t$temp_linked_case.lnk_eh_code, t$temp_linked_case.lnk_doc_type, t$temp_linked_case.lnk_pp_code
            FROM t$temp_linked_case;
    END;
	
   	pas_return_code := var_rtn_code;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_check_linked_case" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";