-- DROP FUNCTION hpi.pas_erpt_harrpe_adm(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hpi.pas_erpt_harrpe_adm(par_hosp_code character varying, par_start_date timestamp without time zone DEFAULT NULL::timestamp without time zone, par_end_date timestamp without time zone DEFAULT NULL::timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    txn_csr CURSOR FOR
    SELECT
        t.Transaction_datetime, t.Transaction_type, t.Case_no, c.HKID, c.T_PRK, c.Admission_datetime, c.Pay_code, c.Discharge_code, c.Discharge_datetime, c.Destination_code, c.Source_indicator, c.Source_code, t.From_ward_code, t.From_specialty_code
        FROM Transaction_log AS t, Case_view AS c
        WHERE t.Hospital_code = par_hosp_code AND t.Transaction_datetime > par_start_date AND t.Transaction_datetime <= par_end_date AND t.Transaction_type IN ('100', '300') AND t.Case_no = c.Case_no AND t.Cancel_flag IS NULL;
    var_tran_type VARCHAR(6);
    var_case_no VARCHAR(24);
    var_hkid VARCHAR(24);
    var_pat_key VARCHAR(24);
    var_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_source_ind VARCHAR(2);
    var_source_code VARCHAR(6);
    var_patient_name VARCHAR(96);
    var_eh_code VARCHAR(16);
    var_pay_code VARCHAR(6);
    var_dsch_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_dsch_code VARCHAR(10);
    var_dest_code VARCHAR(6);
    var_adm_ward VARCHAR(8);
    var_adm_spec VARCHAR(8);
    var_dsch_ward VARCHAR(8);
    var_dsch_spec VARCHAR(8);
    var_tran_dtm TIMESTAMP WITHOUT TIME ZONE;
	p_refcur refcursor;
BEGIN
    SELECT
        to_char(par_start_date - 1 * INTERVAL '1 day', 'YYYYMMDD')
        INTO par_start_date;
    SELECT
        to_char(localtimestamp, 'YYYYMMDD')
        INTO par_end_date;
    /* --print Start[%1!] end [%2!],@start_date,@end_date */
    CREATE TEMPORARY TABLE t$harrpe_table
    (hosp_code VARCHAR(6),
        rpt_date TIMESTAMP WITHOUT TIME ZONE,
        hkid VARCHAR(24),
        patient_name VARCHAR(96) NULL,
        tran_type VARCHAR(6),
        case_no VARCHAR(24),
        adm_dtm TIMESTAMP WITHOUT TIME ZONE,
        source_ind VARCHAR(2) NULL,
        source_code VARCHAR(6) NULL,
        eh_code VARCHAR(16) NULL,
        pay_code VARCHAR(6) NULL,
        dsch_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
        dsch_code VARCHAR(10) NULL,
        dest_code VARCHAR(6) NULL,
        adm_ward VARCHAR(8) NULL,
        adm_spec VARCHAR(8) NULL,
        dsch_ward VARCHAR(8) NULL,
        dsch_spec VARCHAR(8) NULL);
    CREATE TEMPORARY TABLE t$harrpe_dsp
    (hosp_code VARCHAR(6),
        rpt_date TIMESTAMP WITHOUT TIME ZONE,
        hkid VARCHAR(24),
        patient_name VARCHAR(96) NULL,
        tran_type VARCHAR(60),
        case_no VARCHAR(24),
        adm_dtm TIMESTAMP WITHOUT TIME ZONE,
        source_ind VARCHAR(60) NULL,
        source_code VARCHAR(6) NULL,
        eh_code VARCHAR(16) NULL,
        pay_code VARCHAR(6) NULL,
        dsch_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
        dsch_code VARCHAR(60) NULL,
        dest_code VARCHAR(6) NULL,
        adm_ward VARCHAR(8) NULL,
        adm_spec VARCHAR(8) NULL,
        dsch_ward VARCHAR(8) NULL,
        dsch_spec VARCHAR(8) NULL);
    /*
    [3017 - Severity CRITICAL - PostgreSQL doesn't support the SET NOCOUNT. If need try another way to send message back to the client application.]
    set nocount on
    */
    SELECT
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        INTO var_tran_type, var_case_no, var_hkid, var_pat_key, var_adm_dtm, var_pay_code, var_dsch_code, var_dsch_dtm, var_dest_code, var_patient_name, var_eh_code, var_source_ind, var_source_code, var_adm_ward, var_adm_spec, var_dsch_ward, var_dsch_spec, var_tran_dtm;
    OPEN txn_csr;
    FETCH txn_csr INTO var_tran_dtm, var_tran_type, var_case_no, var_hkid, var_pat_key, var_adm_dtm, var_pay_code, var_dsch_code, var_dsch_dtm, var_dest_code, var_source_ind, var_source_code, var_adm_ward, var_adm_spec;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        /* --- check the HKID in ae_multi_registtion or NOT -- */
        
        /* record for multi_type =P -HAPPRE patient */
        
        /* --print HKID[%1!] case [%2!] adm_dtm [%3!],@hkid,@case_no,@adm_dtm */
        IF EXISTS (SELECT
            1
            FROM ae_multi_registration
            WHERE (close_date IS NULL OR close_date > var_adm_dtm) AND effective_date <= var_adm_dtm 
            GROUP BY hospital_code, hkid, multi_type
            HAVING hospital_code = par_hosp_code AND hkid = var_hkid AND multi_type = 'P') THEN
            BEGIN
                SELECT
                    Name
                    INTO var_patient_name
                    FROM PMI_wo_MRN
                    WHERE HKID = var_hkid;
                SELECT
                    EH_code
                    INTO var_eh_code
                    FROM AE_case_detail
                    WHERE Case_no = var_case_no;
                SELECT
                    last_ward_code, last_specialty
                    INTO var_dsch_ward, var_dsch_spec
                    FROM cpi_case
                    WHERE case_no = var_case_no;
                INSERT INTO t$harrpe_table
                VALUES (par_hosp_code, var_tran_dtm, var_hkid, var_patient_name, var_tran_type, var_case_no, var_adm_dtm, var_source_ind, var_source_code, var_eh_code, var_pay_code, var_dsch_dtm, var_dsch_code, var_dest_code, var_adm_ward, var_adm_spec, var_dsch_ward, var_dsch_spec);
            END;
        END IF;
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_tran_type, var_case_no, var_hkid, var_pat_key, var_adm_dtm, var_pay_code, var_dsch_code, var_dsch_dtm, var_dest_code, var_patient_name, var_eh_code, var_source_ind, var_source_code, var_adm_ward, var_adm_spec, var_dsch_ward, var_dsch_spec, var_tran_dtm;
        FETCH txn_csr INTO var_tran_dtm, var_tran_type, var_case_no, var_hkid, var_pat_key, var_adm_dtm, var_pay_code, var_dsch_code, var_dsch_dtm, var_dest_code, var_source_ind, var_source_code, var_adm_ward, var_adm_spec;
    END LOOP;
    CLOSE txn_csr;
    /*
    [3017 - Severity CRITICAL - PostgreSQL doesn't support the SET NOCOUNT. If need try another way to send message back to the client application.]
    set nocount on
    */ /* Adaptive Server has expanded all '*' elements in the following statement */
    INSERT INTO t$harrpe_dsp
    SELECT
        t$harrpe_table.hosp_code, t$harrpe_table.rpt_date, t$harrpe_table.hkid, t$harrpe_table.patient_name, t$harrpe_table.tran_type, t$harrpe_table.case_no, t$harrpe_table.adm_dtm, t$harrpe_table.source_ind, t$harrpe_table.source_code, t$harrpe_table.eh_code, t$harrpe_table.pay_code, t$harrpe_table.dsch_dtm, t$harrpe_table.dsch_code, t$harrpe_table.dest_code, t$harrpe_table.adm_ward, t$harrpe_table.adm_spec, t$harrpe_table.dsch_ward, t$harrpe_table.dsch_spec
        FROM t$harrpe_table;
    /*
    [3017 - Severity CRITICAL - PostgreSQL doesn't support the SET NOCOUNT. If need try another way to send message back to the client application.]
    set nocount on
    */
    UPDATE t$harrpe_dsp
    SET tran_type = 'A&E Registration', source_ind = NULL, adm_ward = NULL, adm_spec = NULL, dsch_ward = NULL, dsch_spec = NULL
        WHERE tran_type = '300';
    UPDATE t$harrpe_dsp
    SET tran_type = 'In-Patient Admission'
        WHERE tran_type = '100';
    /* ----Update discharge Code description */
    UPDATE t$harrpe_dsp AS r
    SET dsch_code = d.Short_description
    FROM Discharge_type AS d
        WHERE r.dsch_code = d.Discharge_code;
    /*
    select r.dsch_code,d.Short_description
    from #harrpe_dsp r
    join Discharge_type d on  r.dsch_code = d.Discharge_code
    */
    /* ---update Source Ind */
    UPDATE t$harrpe_dsp AS r
    SET source_ind = d.Description
    FROM Source AS d
        WHERE r.source_ind = d.Source_indicator;
    /* Adaptive Server has expanded all '*' elements in the following statement */
    OPEN p_refcur FOR
    SELECT
        t$harrpe_dsp.hosp_code, t$harrpe_dsp.rpt_date, t$harrpe_dsp.hkid, t$harrpe_dsp.patient_name, t$harrpe_dsp.tran_type, t$harrpe_dsp.case_no, t$harrpe_dsp.adm_dtm, t$harrpe_dsp.source_ind, t$harrpe_dsp.source_code, t$harrpe_dsp.eh_code, t$harrpe_dsp.pay_code, t$harrpe_dsp.dsch_dtm, t$harrpe_dsp.dsch_code, t$harrpe_dsp.dest_code, t$harrpe_dsp.adm_ward, t$harrpe_dsp.adm_spec, t$harrpe_dsp.dsch_ward, t$harrpe_dsp.dsch_spec
        FROM t$harrpe_dsp
        ORDER BY rpt_date NULLS FIRST;

    DROP TABLE IF EXISTS t$harrpe_table;
    DROP TABLE IF EXISTS t$harrpe_dsp;

END;
$function$
;

;ALTER FUNCTION "pas_erpt_harrpe_adm" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
