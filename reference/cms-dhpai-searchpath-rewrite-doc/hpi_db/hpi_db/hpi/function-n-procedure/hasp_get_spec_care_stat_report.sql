-- DROP FUNCTION hpi.hasp_get_spec_care_stat_report(varchar, timestamp, timestamp, varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_get_spec_care_stat_report(par_hosp_code character varying, par_from_date timestamp without time zone, par_to_date timestamp without time zone, par_input_spec_list character varying, par_input_care_list character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
	p_refcur refcursor;
	
	v_json JSON;
	var_temp_1	VARCHAR(128);
	var_temp_2	VARCHAR(128);
	var_temp_3	VARCHAR(128);
	var_temp_int_1	INT;
    var_hn_adm INT;
    var_ae_adm INT;
    var_tx_in INT;
    var_tx_out INT;
    var_td_in INT;
    var_td_out INT;
    var_dsch INT;
    var_deth INT;
    var_ae_day_dsch INT;
    var_ae_day_deth INT;
    var_day_dsch INT;
    var_day_deth INT;
    var_rtn_td_out INT;
    var_rtn_td_in INT;

    var_ip_bed INT;
    var_day_bed INT;
    var_bed_day_occ INT;
    var_bed_day_vac INT;
    var_bed_day_exc INT;
    var_loc_ip_bed INT;
    var_adj_remain INT;

    var_ttl_remain INT;
    var_ttl_bed_day_occ INT;
    var_ttl_bed_day_vac INT;
    var_ttl_bed_day_exc INT;
    var_bdo INT;

    var_tx_type VARCHAR(3);
    var_src_ind VARCHAR(1);
    var_from_ward VARCHAR(4);
    var_to_ward VARCHAR(4);
    var_from_spec VARCHAR(4);
    var_from_ward_loc VARCHAR(4);
    var_to_ward_loc VARCHAR(4);
    var_to_spec VARCHAR(4);
    var_from_care VARCHAR(1);
    var_to_care VARCHAR(1);
    var_tx_dtm TIMESTAMP;
    var_adm_dtm TIMESTAMP;
    var_case_no VARCHAR(12);
    var_from_loc VARCHAR(4);
    var_to_loc VARCHAR(4);

    var_date TIMESTAMP;
    var_hosp VARCHAR(3);
    var_spec VARCHAR(4);
    var_ward VARCHAR(4);
    var_care VARCHAR(1);
    var_loc VARCHAR(4);
    var_prev_remain INT;
    var_ward_loc VARCHAR(4);

    var_sum_ip_bed INT;
    var_sum_day_bed INT;
    var_sum_hn_adm INT;
    var_sum_ae_adm INT;
    var_sum_tx_in INT;
    var_sum_tx_out INT;
    var_sum_td_in INT;
    var_sum_td_out INT;
    var_sum_dsch INT;
    var_sum_deth INT;
    var_sum_ae_day_dsch INT;
    var_sum_ae_day_deth INT;
    var_sum_day_dsch INT;
    var_sum_remain INT;
    var_sum_bed_day_occ INT;
    var_sum_bed_day_vac INT;
    var_sum_bed_day_exc INT;
    var_sum_day_deth INT;
    var_sum_org_prev_remain INT;
    var_org_prev_remain INT;
    var_sum_rtn_td_out INT;
    var_sum_prev_remain INT;
    var_sum_rtn_td_in INT;

    var_sum_temp_org_prev_remain INT;
    var_sum_temp_prev_remain INT;
    var_sum_temp_ip_bed INT;
    var_sum_temp_day_bed INT;
    var_sum_temp_hn_adm INT;
    var_sum_temp_ae_adm INT;
    var_sum_temp_tx_in INT;
    var_sum_temp_tx_out INT;
    var_sum_temp_td_in INT;
    var_sum_temp_td_out INT;
    var_sum_temp_dsch INT;
    var_sum_temp_deth INT;
    var_sum_temp_day_dsch INT;
    var_sum_temp_day_deth INT;
    var_sum_temp_ae_day_dsch INT;
    var_sum_temp_ae_day_deth INT;
    var_sum_temp_remain INT;
    var_sum_temp_bed_day_occ INT;
    var_sum_temp_bed_day_vac INT;
    var_sum_temp_bed_day_exc INT;
    var_sum_temp_rtn_td_out INT;
    var_sum_temp_rtn_td_in INT;

    var_desc VARCHAR(48);
    var_care_count INT;
    var_prev_care VARCHAR(1);
    var_prev_spec VARCHAR(4);
    var_remain INT;
    var_prev_loc VARCHAR(4);
    var_prev_status VARCHAR(1);

    var_count INT;
    var_selected_care VARCHAR(1);
    var_selected_spec VARCHAR(4);
    var_insert_spec VARCHAR(4);
    var_insert_loc VARCHAR(30);

    var_test_spec VARCHAR(4);
    var_test_ward VARCHAR(4);
    var_test_output VARCHAR(128);

    var_show_prev_remain VARCHAR(5);
    var_record_count INT;
    var_active_status VARCHAR(1);
    var_upd_offset VARCHAR(1);
    var_spec_desc VARCHAR(30);

    var_test VARCHAR(3);

    -- Cursors
    ward_spec_csr CURSOR FOR
        WITH ranked_data AS (
            SELECT Specialty_code, Ward_code, Official_bed, Day_bed, Effective_date,
                ROW_NUMBER() OVER (
                    PARTITION BY Specialty_code, Ward_code 
                    ORDER BY Effective_date DESC
                ) as rn
            FROM Ward_specialty
            WHERE COALESCE(Specialty_code,'NULL') <> 'AE01' 
            AND COALESCE(Ward_code,'NULL') <> 'AE01'
            AND Effective_date <= var_date
        )
        SELECT Specialty_code, Ward_code, Official_bed, Day_bed
        FROM ranked_data
        WHERE rn = 1 
       	ORDER BY Ward_code NULLS FIRST , Specialty_code NULLS FIRST;

    tran_log_csr CURSOR FOR
        SELECT t.transaction_type, c.source_indicator, t.from_treatment_location, t.to_treatment_location, t.from_ward_code, t.to_ward_code,
               t.from_specialty_code, t.to_specialty_code, t.transaction_datetime, c.admission_datetime, t.case_no
        FROM transaction_log t, adt_case c
        WHERE transaction_datetime >= var_date
          AND transaction_datetime < var_date + INTERVAL '1 day'
          AND t.hospital_code = par_hosp_code
          AND t.case_no = c.case_no
          AND cancel_flag IS NULL
          AND post_datetime IS NOT NULL
          AND ((transaction_type LIKE '13_') OR
               (transaction_type IN ('100', '140', '141', '160', '170', '161', '171')));

    work_summ_csr CURSOR FOR
        SELECT wk_spec, wk_care, wk_loc, wk_org_prev_remain, wk_ip_bed, wk_day_bed, wk_hn_adm, wk_ae_adm, wk_tx_in, wk_tx_out,
               wk_td_in, wk_td_out, wk_dsch, wk_deth, wk_ae_day_dsch, wk_ae_day_deth, wk_day_dsch, wk_day_deth, wk_remain,
               wk_bed_day_occ, wk_bed_day_vac, wk_bed_day_exc, wk_rtn_td_out, wk_rtn_td_in
        FROM t$worktable_summ
        WHERE COALESCE(wk_spec, 'NULL') <> 'HOME'
        ORDER BY wk_spec NULLS FIRST , wk_care NULLS FIRST , wk_loc NULLS FIRST ;

    work_summ_loc_csr CURSOR FOR
        SELECT wk_spec, wk_care, wk_loc
        FROM t$worktable_summ
        WHERE COALESCE(wk_loc,'NULL') <> 'ADD'
        ORDER BY wk_spec NULLS FIRST , wk_care NULLS FIRST , wk_loc NULLS FIRST ;

    work_summ_loc_add_csr CURSOR FOR
        SELECT wk_spec, wk_care, wk_loc, wk_ip_bed
        FROM t$worktable_summ
        WHERE wk_loc = 'ADD'
        ORDER BY wk_spec NULLS FIRST , wk_care NULLS FIRST , wk_loc NULLS FIRST ;

    daily_csr CURSOR FOR
        SELECT day_spec, day_care, day_loc, day_ip_bed, day_day_bed, day_prev_remain, day_hn_adm, day_ae_adm, day_tx_in, day_tx_out,
               day_td_in, day_td_out, day_dsch, day_deth, day_ae_day_dsch, day_ae_day_deth, day_day_dsch, day_day_deth, day_rtn_td_out, day_rtn_td_in
        FROM t$daily_txn
        WHERE COALESCE(day_loc,'NULL') <> 'ADD'
        ORDER BY day_spec NULLS FIRST , day_care NULLS FIRST , day_loc NULLS FIRST ;

    daily_ward_csr CURSOR FOR
        SELECT ward_spec, ward_ward, ward_loc, ward_ip_bed, ward_day_bed, ward_prev_remain, ward_hn_adm, ward_ae_adm, ward_tx_in, ward_tx_out,
               ward_td_in, ward_td_out, ward_dsch, ward_deth, ward_ae_day_dsch, ward_ae_day_deth, ward_day_dsch, ward_day_deth, ward_rtn_td_out, ward_rtn_td_in
        FROM t$daily_ward_txn
        ORDER BY ward_spec NULLS FIRST , ward_ward NULLS FIRST , ward_loc NULLS FIRST ;

    daily_ward_spec_csr CURSOR FOR
        SELECT ward_spec, ward_loc
        FROM t$daily_ward_txn
        WHERE ward_ward = var_ward
        ORDER BY ward_ward NULLS FIRST , ward_spec NULLS FIRST ;

    ward_csr CURSOR FOR
        SELECT ward_code, treatment_location, active_status, care_category
        FROM ward
        WHERE effective_date = var_date;

    spec_csr CURSOR FOR
        SELECT specialty_code, active_status
        FROM specialty
        WHERE effective_date = var_date;

    start_table_csr CURSOR FOR
        SELECT ward_code, spec_code, treat_loc, prev_remain
        FROM t$start_table;

    daily_loc_csr CURSOR FOR
        SELECT loc_spec, loc_care, loc_loc, loc_ip_bed, loc_bed_day_occ
        FROM t$daily_loc_bed_day
        ORDER BY loc_spec NULLS FIRST , loc_care NULLS FIRST , loc_loc NULLS FIRST ;

BEGIN
    -- set nocount on not needed in PG

    -- Var Declaration
    var_test_spec := 'MED';
    --var_test_spec := 'ISUR';
    var_test_ward := 'D6';  ---loc = 'CCU'
    --var_test := 'YES';

    /* init */
    IF par_to_date IS NULL THEN
        par_to_date := par_from_date + INTERVAL '1 day';
    END IF;

    IF NULLIF(TRIM(par_input_spec_list),'') = 'null' THEN
        par_input_spec_list := NULL;
    END IF;

    IF NULLIF(TRIM(par_input_care_list),'') = 'null' THEN
        par_input_care_list := NULL;
    END IF;

    IF EXTRACT(DAY FROM (par_to_date - par_from_date)) = 0 THEN
        var_show_prev_remain := 'YES';
    ELSE
        var_show_prev_remain := 'NO';
    END IF;

    par_to_date := par_to_date + INTERVAL '1 day';

    DROP TABLE IF EXISTS t$dsptable;
    CREATE temporary TABLE t$dsptable (
    	id bigserial PRIMARY KEY,
        dp_spec VARCHAR(5),
        dp_care VARCHAR(1),
        dp_loc VARCHAR(30),
        dp_desc VARCHAR(48),
        dp_prev_remain INT DEFAULT 0,
        dp_hn_adm INT DEFAULT 0,
        dp_ae_adm INT DEFAULT 0,
        dp_tx_in INT DEFAULT 0,
        dp_tx_out INT DEFAULT 0,
        dp_dsch INT DEFAULT 0,
        dp_deth INT DEFAULT 0,
        dp_ae_day_dsch INT DEFAULT 0,
        dp_ae_day_deth INT DEFAULT 0,
        dp_remain INT DEFAULT 0,
        dp_bed_day_occ INT DEFAULT 0,
        dp_bed_day_vac INT DEFAULT 0,
        dp_ip_bed INT DEFAULT 0,
        dp_bed_day_exc INT DEFAULT 0,
        dp_occ_rate REAL DEFAULT 0,
        dp_day_dsch INT DEFAULT 0,
        dp_day_deth INT DEFAULT 0,
        dp_day_bed INT DEFAULT 0,
        dp_td_out INT DEFAULT 0,
        dp_rtn_td_out INT DEFAULT 0,
        dp_rtn_td_in INT DEFAULT 0
    );

    DROP TABLE IF EXISTS t$worktable;
    CREATE temporary TABLE t$worktable (
        wk_spec VARCHAR(4),
        wk_care VARCHAR(1),
        wk_loc VARCHAR(4),
        wk_org_prev_remain INT DEFAULT 0,
        wk_prev_remain INT DEFAULT 0,
        wk_ip_bed INT DEFAULT 0,
        wk_day_bed INT DEFAULT 0,
        wk_hn_adm INT DEFAULT 0,
        wk_ae_adm INT DEFAULT 0,
        wk_tx_in INT DEFAULT 0,
        wk_tx_out INT DEFAULT 0,
        wk_td_in INT DEFAULT 0,
        wk_td_out INT DEFAULT 0,
        wk_dsch INT DEFAULT 0,
        wk_deth INT DEFAULT 0,
        wk_day_dsch INT DEFAULT 0,
        wk_day_deth INT DEFAULT 0,
        wk_ae_day_dsch INT DEFAULT 0,
        wk_ae_day_deth INT DEFAULT 0,
        wk_remain INT DEFAULT 0,
        wk_bed_day_occ INT DEFAULT 0,
        wk_bed_day_vac INT DEFAULT 0,
        wk_bed_day_exc INT DEFAULT 0,
        wk_rtn_td_out INT DEFAULT 0,
        wk_rtn_td_in INT DEFAULT 0
    );

    CREATE UNIQUE INDEX t$worktable_index1 ON t$worktable (wk_spec, wk_care, wk_loc);

    DROP TABLE IF EXISTS t$daily_txn;
    CREATE temporary TABLE t$daily_txn (
        day_spec VARCHAR(4),
        day_care VARCHAR(1),
        day_loc VARCHAR(4),
        day_ip_bed INT DEFAULT 0,
        day_day_bed INT DEFAULT 0,
        day_prev_remain INT DEFAULT 0,
        day_bed_day_occ INT DEFAULT 0,
        day_bed_day_vac INT DEFAULT 0,
        day_bed_day_exc INT DEFAULT 0,
        day_hn_adm INT DEFAULT 0,
        day_ae_adm INT DEFAULT 0,
        day_tx_in INT DEFAULT 0,
        day_tx_out INT DEFAULT 0,
        day_td_in INT DEFAULT 0,
        day_td_out INT DEFAULT 0,
        day_dsch INT DEFAULT 0,
        day_deth INT DEFAULT 0,
        day_day_dsch INT DEFAULT 0,
        day_day_deth INT DEFAULT 0,
        day_ae_day_dsch INT DEFAULT 0,
        day_ae_day_deth INT DEFAULT 0,
        day_rtn_td_out INT DEFAULT 0,
        day_rtn_td_in INT DEFAULT 0
    );

    CREATE UNIQUE INDEX t$daily_txn_index1 ON t$daily_txn (day_spec, day_care, day_loc);

    DROP TABLE IF EXISTS t$daily_ward_txn;
    CREATE temporary TABLE t$daily_ward_txn (
        ward_spec VARCHAR(4),
        ward_ward VARCHAR(4),
        ward_loc VARCHAR(4),
        ward_ip_bed INT DEFAULT 0,
        ward_day_bed INT DEFAULT 0,
        ward_prev_remain INT DEFAULT 0,
        ward_bed_day_occ INT DEFAULT 0,
        ward_bed_day_vac INT DEFAULT 0,
        ward_bed_day_exc INT DEFAULT 0,
        ward_hn_adm INT DEFAULT 0,
        ward_ae_adm INT DEFAULT 0,
        ward_tx_in INT DEFAULT 0,
        ward_tx_out INT DEFAULT 0,
        ward_td_in INT DEFAULT 0,
        ward_td_out INT DEFAULT 0,
        ward_dsch INT DEFAULT 0,
        ward_deth INT DEFAULT 0,
        ward_day_dsch INT DEFAULT 0,
        ward_day_deth INT DEFAULT 0,
        ward_ae_day_dsch INT DEFAULT 0,
        ward_ae_day_deth INT DEFAULT 0,
        ward_rtn_td_out INT DEFAULT 0,
        ward_rtn_td_in INT DEFAULT 0
    );

    CREATE UNIQUE INDEX t$daily_ward_txn_index1 ON t$daily_ward_txn (ward_spec, ward_ward, ward_loc);

    DROP TABLE IF EXISTS t$wk_summ_tmp;
    CREATE temporary TABLE t$wk_summ_tmp (
        wk_spec VARCHAR(4),
        wk_care VARCHAR(1),
        wk_loc VARCHAR(4),
        wk_org_prev_remain INT DEFAULT 0,
        wk_prev_remain INT DEFAULT 0,
        wk_ip_bed INT DEFAULT 0,
        wk_day_bed INT DEFAULT 0,
        wk_hn_adm INT DEFAULT 0,
        wk_ae_adm INT DEFAULT 0,
        wk_tx_in INT DEFAULT 0,
        wk_tx_out INT DEFAULT 0,
        wk_td_in INT DEFAULT 0,
        wk_td_out INT DEFAULT 0,
        wk_dsch INT DEFAULT 0,
        wk_deth INT DEFAULT 0,
        wk_day_dsch INT DEFAULT 0,
        wk_day_deth INT DEFAULT 0,
        wk_ae_day_dsch INT DEFAULT 0,
        wk_ae_day_deth INT DEFAULT 0,
        wk_remain INT DEFAULT 0,
        wk_bed_day_occ INT DEFAULT 0,
        wk_bed_day_vac INT DEFAULT 0,
        wk_bed_day_exc INT DEFAULT 0,
        wk_rtn_td_out INT DEFAULT 0,
        wk_rtn_td_in INT DEFAULT 0
    );

    CREATE UNIQUE INDEX t$wk_summ_tmp_index1 ON t$wk_summ_tmp (wk_spec, wk_care, wk_loc);

    DROP TABLE IF EXISTS t$worktable_summ;
    CREATE temporary TABLE t$worktable_summ (
        wk_spec VARCHAR(4),
        wk_care VARCHAR(1),
        wk_loc VARCHAR(4),
        wk_org_prev_remain INT DEFAULT 0,
        wk_prev_remain INT DEFAULT 0,
        wk_ip_bed INT DEFAULT 0,
        wk_day_bed INT DEFAULT 0,
        wk_hn_adm INT DEFAULT 0,
        wk_ae_adm INT DEFAULT 0,
        wk_tx_in INT DEFAULT 0,
        wk_tx_out INT DEFAULT 0,
        wk_td_in INT DEFAULT 0,
        wk_td_out INT DEFAULT 0,
        wk_dsch INT DEFAULT 0,
        wk_deth INT DEFAULT 0,
        wk_day_dsch INT DEFAULT 0,
        wk_day_deth INT DEFAULT 0,
        wk_ae_day_dsch INT DEFAULT 0,
        wk_ae_day_deth INT DEFAULT 0,
        wk_remain INT DEFAULT 0,
        wk_bed_day_occ INT DEFAULT 0,
        wk_bed_day_vac INT DEFAULT 0,
        wk_bed_day_exc INT DEFAULT 0,
        wk_rtn_td_out INT DEFAULT 0,
        wk_rtn_td_in INT DEFAULT 0
    );

    CREATE UNIQUE INDEX t$worktable_summ_index1 ON t$worktable_summ (wk_spec, wk_care, wk_loc);

    DROP TABLE IF EXISTS t$worktable_offset_summ;
    CREATE temporary TABLE t$worktable_offset_summ (
        wk_spec VARCHAR(4),
        wk_care VARCHAR(1),
        wk_loc VARCHAR(4),
        wk_org_prev_remain INT DEFAULT 0,
        wk_prev_remain INT DEFAULT 0,
        wk_ip_bed INT DEFAULT 0,
        wk_day_bed INT DEFAULT 0,
        wk_hn_adm INT DEFAULT 0,
        wk_ae_adm INT DEFAULT 0,
        wk_tx_in INT DEFAULT 0,
        wk_tx_out INT DEFAULT 0,
        wk_td_in INT DEFAULT 0,
        wk_td_out INT DEFAULT 0,
        wk_dsch INT DEFAULT 0,
        wk_deth INT DEFAULT 0,
        wk_day_dsch INT DEFAULT 0,
        wk_day_deth INT DEFAULT 0,
        wk_ae_day_dsch INT DEFAULT 0,
        wk_ae_day_deth INT DEFAULT 0,
        wk_remain INT DEFAULT 0,
        wk_bed_day_occ INT DEFAULT 0,
        wk_bed_day_vac INT DEFAULT 0,
        wk_bed_day_exc INT DEFAULT 0,
        wk_rtn_td_out INT DEFAULT 0,
        wk_rtn_td_in INT DEFAULT 0
    );

    CREATE UNIQUE INDEX t$worktable_offset_summ_index1 ON t$worktable_offset_summ (wk_spec, wk_care, wk_loc);

    DROP TABLE IF EXISTS t$start_table;
    CREATE temporary TABLE t$start_table (
        ward_code VARCHAR(4),
        spec_code VARCHAR(4),
        treat_loc VARCHAR(4),
        prev_remain INT DEFAULT 0
    );

    CREATE UNIQUE INDEX t$start_table_index1 ON t$start_table (ward_code, spec_code, treat_loc);

    DROP TABLE IF EXISTS t$daily_loc_bed_day;
    CREATE temporary TABLE t$daily_loc_bed_day (
        loc_spec VARCHAR(4),
        loc_care VARCHAR(1),
        loc_loc VARCHAR(4),
        loc_ip_bed INT DEFAULT 0,
        loc_bed_day_occ INT DEFAULT 0
    );

    CREATE UNIQUE INDEX t$daily_loc_bed_day_index1 ON t$daily_loc_bed_day (loc_spec, loc_care);

    /* 2.	Extract the number of Previous Remaining by Ward and by Specialty into work table*/
    --------------------------------------------------------------
    DROP TABLE IF EXISTS t$tmp_start;
    CREATE TEMPORARY TABLE t$tmp_start AS
    SELECT 
        MAX(ward_spec_tx_date) AS tx_date,
        ward_code,
        specialty_code AS spec_code,
        treatment_location AS treat_loc
    FROM ward_spec_tx
    WHERE ward_spec_tx_date < par_from_date
    GROUP BY specialty_code, treatment_location, ward_code;

    INSERT INTO t$start_table (ward_code, spec_code, treat_loc, prev_remain)
    SELECT t.ward_code, t.spec_code, t.treat_loc,
           SUM(COALESCE(previous_remaining, 0))
           + SUM(COALESCE(admission, 0)) - SUM(COALESCE(canc_admission, 0))
           - SUM(COALESCE(discharge, 0)) + SUM(COALESCE(canc_discharge, 0))
           + SUM(COALESCE(transfer_in, 0)) - SUM(COALESCE(canc_transfer_in, 0))
           - SUM(COALESCE(transfer_out, 0)) + SUM(COALESCE(canc_transfer_out, 0))
           - SUM(COALESCE(death, 0)) + SUM(COALESCE(canc_death, 0))
           + SUM(COALESCE(transfer_in_from_td, 0)) - SUM(COALESCE(canc_transfer_in_from_td, 0))
           - SUM(COALESCE(transfer_out_to_td, 0)) + SUM(COALESCE(canc_transfer_out_to_td, 0))
    FROM t$tmp_start t, ward_spec_tx_adj_view v
    WHERE t.tx_date = v.ward_spec_tx_date
      AND t.ward_code = v.ward_code
      AND t.spec_code = v.specialty_code
      AND COALESCE(t.treat_loc, 'null') = COALESCE(treatment_location, 'null')
    GROUP BY t.ward_code, t.spec_code, t.treat_loc;
    --------------------------------------------------------------

    /* init the worktable from previous days' info */
    ---- clean the t$start_table ---
    --------------------------------------------------------------
    OPEN start_table_csr;
    FETCH start_table_csr INTO var_ward, var_spec, var_loc, var_prev_remain;
    WHILE (CASE WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 END) = 0 
    LOOP
        WITH ranked_ward AS (
            SELECT Care_category, Active_status,
                ROW_NUMBER() OVER (
                    PARTITION BY Ward_code 
                    ORDER BY Effective_date DESC
                ) as rn
            FROM Ward
            WHERE Ward_code = var_ward
            AND Effective_date <= par_from_date
        )
        SELECT Care_category, Active_status
        --INTO var_care, var_active_status
        INTO var_temp_1,var_temp_2
        FROM ranked_ward
        WHERE rn = 1;
		IF FOUND THEN
			var_care := var_temp_1;
			var_active_status := var_temp_2;
		END IF;

        ---- clean the prev_remain of t$start_table ------
        IF var_active_status = 'A' THEN  --- Skip the old Pre_remain which the Ward already in-active ---
            IF var_care IS NULL OR NULLIF(TRIM(var_care),'') IS NULL THEN
                var_care := 'M';
            END IF;

            var_loc := NULLIF(TRIM(var_loc),'');

            IF var_loc IS NULL OR NULLIF(TRIM(var_loc),'') IS NULL THEN
                var_loc := 'NULL';
            END IF;

            --- init t$worktable ---
            IF EXISTS (SELECT 1 FROM t$worktable WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = var_loc) THEN
                UPDATE t$worktable SET wk_prev_remain = wk_prev_remain + var_prev_remain,
                                       wk_org_prev_remain = wk_org_prev_remain + var_prev_remain
                WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = var_loc;
            ELSE
                INSERT INTO t$worktable VALUES (var_spec, var_care, var_loc, var_prev_remain, var_prev_remain, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            END IF;

            --- init t$daily_txn for first-day calc. & it will updated after daily tran  ---
            IF EXISTS (SELECT 1 FROM t$daily_txn WHERE day_spec = var_spec AND day_care = var_care AND day_loc = var_loc) THEN
                UPDATE t$daily_txn SET day_prev_remain = day_prev_remain + var_prev_remain
                WHERE day_spec = var_spec AND day_care = var_care AND day_loc = var_loc;
            ELSE
                INSERT INTO t$daily_txn VALUES (var_spec, var_care, var_loc, 0, 0, var_prev_remain, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            END IF;

            ----050503 ---
            --- init t$daily_ward_txn for first-day calc. & it will updated after daily tran  ---
            IF EXISTS (SELECT 1 FROM t$daily_ward_txn WHERE ward_spec = var_spec AND ward_ward = var_ward AND ward_loc = var_loc) THEN
                UPDATE t$daily_ward_txn SET ward_prev_remain = ward_prev_remain + var_prev_remain
                WHERE ward_spec = var_spec AND ward_ward = var_ward AND ward_loc = var_loc;
            ELSE
                INSERT INTO t$daily_ward_txn VALUES (var_spec, var_ward, var_loc, 0, 0, var_prev_remain, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            END IF;

            ----- for LOC -----
            --- if t$worktable's wk_loc = 'ADD' mean: the record create by Ward's Treatment_loc &  will no count in summary ---
            --- No 'ADD' record for t$daily_txn ?? - 050426--
            IF COALESCE(var_loc, 'null') <> 'NULL' AND var_loc IS NOT NULL AND COALESCE(var_loc,'NULL') <> COALESCE(var_spec,'NULL') THEN  --- to avoid : if spec='ICU' & loc = 'ICU'
                IF EXISTS (SELECT 1 FROM t$worktable WHERE wk_spec = var_loc AND wk_care = var_care AND wk_loc = 'ADD') THEN
                    UPDATE t$worktable SET wk_prev_remain = wk_prev_remain + var_prev_remain, -----050426---
                                           wk_org_prev_remain = wk_org_prev_remain + var_prev_remain
                    WHERE wk_spec = var_loc AND wk_care = var_care AND wk_loc = 'ADD';
                ELSE
                    INSERT INTO t$worktable VALUES (var_loc, var_care, 'ADD', var_prev_remain, var_prev_remain, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                END IF;
            END IF;
            ----- for LOC -----
        END IF; --- if var_active_status = 'A'		--- Skip the old Pre_remain  which the Ward in-active ---

        FETCH start_table_csr INTO var_ward, var_spec, var_loc, var_prev_remain;
    END LOOP;
    CLOSE start_table_csr;
    --------------------------------------------------------------

    IF var_test = 'YES' THEN
        RAISE NOTICE '---after init prev_remain before days loop ---';
        SELECT ward_code, spec_code, treat_loc, prev_remain FROM t$start_table WHERE spec_code = var_test_spec OR treat_loc = var_test_spec;
        SELECT wk_spec, wk_care, wk_loc, wk_org_prev_remain, wk_prev_remain, wk_ip_bed, wk_day_bed, wk_hn_adm, wk_ae_adm, wk_tx_in, wk_tx_out, wk_td_in, wk_td_out, wk_dsch, wk_deth, wk_day_dsch, wk_day_deth, wk_ae_day_dsch, wk_ae_day_deth, wk_remain, wk_bed_day_occ, wk_bed_day_vac, wk_bed_day_exc, wk_rtn_td_out, wk_rtn_td_in FROM t$worktable WHERE wk_spec = var_test_spec OR wk_loc = var_test_spec;
        SELECT day_spec, day_care, day_loc, day_ip_bed, day_day_bed, day_prev_remain, day_bed_day_occ, day_bed_day_vac, day_bed_day_exc, day_hn_adm, day_ae_adm, day_tx_in, day_tx_out, day_td_in, day_td_out, day_dsch, day_deth, day_day_dsch, day_day_deth, day_ae_day_dsch, day_ae_day_deth, day_rtn_td_out, day_rtn_td_in FROM t$daily_txn WHERE day_spec = var_test_spec OR day_loc = var_test_spec;
        SELECT ward_spec, ward_ward, ward_loc, ward_ip_bed, ward_day_bed, ward_prev_remain, ward_bed_day_occ, ward_bed_day_vac, ward_bed_day_exc, ward_hn_adm, ward_ae_adm, ward_tx_in, ward_tx_out, ward_td_in, ward_td_out, ward_dsch, ward_deth, ward_day_dsch, ward_day_deth, ward_ae_day_dsch, ward_ae_day_deth, ward_rtn_td_out, ward_rtn_td_in FROM t$daily_ward_txn WHERE ward_spec = var_test_spec OR ward_loc = var_test_spec;
    END IF;

    var_spec := NULL;
    var_ward := NULL;
    var_loc := NULL;
    var_prev_remain := 0;
    var_ip_bed := 0;
    var_day_bed := 0;
    var_prev_care := NULL;
    var_care := NULL;
    var_prev_loc := NULL;

    /* Loop by Date */
    var_date := par_from_date;
    WHILE var_date < par_to_date LOOP
        IF var_test = 'YES' THEN
            RAISE NOTICE '-------------------[%] ----------------- ', var_date;
        END IF;
        ------------------------------------------------------------------
        ---- 050429 TO :  init t$daily_txn & previous_remain if Ward's Care changed --- 
        ------------------------------------------------------------------
        ---- 050429 if care type changed and the report' date  over 2 days ----
        --- need to update/adj t$daily_txn's prev_remain for the change ----
        IF (var_show_prev_remain = 'NO') AND var_date > par_from_date THEN

            ---- Ward changed -----
            var_ward := NULL;
            var_loc := NULL;
            var_active_status := NULL;
            var_care := NULL;
            var_adj_remain := 0;
            var_prev_care := NULL;
            var_prev_loc := NULL;
            var_active_status := NULL;

            OPEN ward_csr;
            FETCH ward_csr INTO var_ward, var_loc, var_active_status, var_care;
            WHILE (CASE WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 END) = 0 
            LOOP
                --- check any change on Ward's Care/Loc ---
                WITH ranked_ward AS (
                    SELECT Care_category, Treatment_location, Active_status,
                        ROW_NUMBER() OVER (
                            PARTITION BY Ward_code 
                            ORDER BY Effective_date DESC
                        ) as rn
                    FROM Ward
                    WHERE Ward_code = var_ward
                    AND Effective_date < var_date
                )
                SELECT Care_category, Treatment_location, Active_status
                --INTO var_prev_care, var_prev_loc, var_prev_status
                INTO var_temp_1 ,var_temp_2 ,var_temp_3
                FROM ranked_ward
                WHERE rn = 1;
               	IF FOUND THEN
               		var_prev_care := var_temp_1;
               		var_prev_loc := var_temp_2;
               		var_prev_status := var_temp_3;
               	END IF;
               	

                IF var_care IS NULL OR NULLIF(TRIM(var_care),'') IS NULL THEN
                    var_care := 'M';
                END IF;
                IF var_prev_care IS NULL OR NULLIF(TRIM(var_prev_care),'') IS NULL THEN
                    var_prev_care := 'M';
                END IF;
                var_loc := NULLIF(TRIM(var_loc),'');
                var_prev_loc := NULLIF(TRIM(var_prev_loc),'');

                IF var_loc IS NULL OR NULLIF(TRIM(var_loc),'') IS NULL THEN
                    var_loc := 'NULL';
                END IF;

                IF var_prev_loc IS NULL OR NULLIF(TRIM(var_prev_loc),'') IS NULL THEN
                    var_prev_loc := 'NULL';
                END IF;

                --- if changed on care category or Treatment_loc or Active status--
                IF COALESCE(var_prev_care,'NULL') <> COALESCE(var_care,'NULL') OR COALESCE(var_prev_loc,'NULL') <> COALESCE(var_loc,'NULL') THEN
                    IF var_test = 'YES' AND var_spec = var_test_spec THEN
                        RAISE NOTICE '----before adj for changed wards pre_remain ----';
                        var_test_output := CAST(var_adj_remain AS VARCHAR(5));
                        RAISE NOTICE '--[%] [%] [%] [%] [%] [%] [%] --', var_ward, var_active_status, var_care, var_prev_care, var_loc, var_prev_loc, var_test_output;
                        SELECT * FROM t$daily_ward_txn WHERE ward_spec = var_test_spec;
                        SELECT * FROM t$daily_txn WHERE day_spec = var_test_spec;
                    END IF;

                    --- search var_spec from t$daily_ward_txn by var_ward
                    var_spec := NULL;
                    var_ward_loc := NULL;
                    OPEN daily_ward_spec_csr;
                    FETCH daily_ward_spec_csr INTO var_spec, var_ward_loc;
                    WHILE (CASE WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 END) = 0 
                    LOOP
                        IF var_ward_loc IS NULL OR NULLIF(TRIM(var_ward_loc),'') IS NULL THEN
                            var_ward_loc := 'NULL';
                        END IF;

                        ---- get pre_remain from changed care_category of Ward ---
                        SELECT ward_prev_remain 
                        --INTO var_adj_remain
                        INTO var_temp_int_1
                        FROM t$daily_ward_txn
                        WHERE ward_spec = var_spec AND ward_ward = var_ward AND ward_loc = var_ward_loc;
                       	IF FOUND THEN
                       		var_adj_remain := var_temp_int_1;
                       	END IF;
                       	

                        -- for changed care --
                        IF COALESCE(var_care,'NULL') <> COALESCE(var_prev_care,'NULL') THEN
                            UPDATE t$daily_txn
                            SET day_prev_remain = day_prev_remain - var_adj_remain
                            WHERE day_spec = var_spec AND day_care = var_prev_care AND day_loc = var_ward_loc;

                            IF EXISTS (SELECT 1 FROM t$daily_txn WHERE day_spec = var_spec AND day_care = var_care AND day_loc = var_ward_loc) THEN
                                UPDATE t$daily_txn SET day_prev_remain = day_prev_remain + var_adj_remain
                                WHERE day_spec = var_spec AND day_care = var_care AND day_loc = var_ward_loc;
                            ELSE
                                INSERT INTO t$daily_txn VALUES (var_spec, var_care, var_ward_loc, 0, 0, var_adj_remain, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                            END IF;
                        END IF;

                        ---for changed loc --
                        -- 3 conditions: HDU -> ICU or NULL->ICU or ICU -> NULL --
                        IF COALESCE(var_loc,'NULL') <> COALESCE(var_prev_loc,'NULL') THEN
                            IF COALESCE(var_prev_loc,'null') <> 'NULL' THEN  --- has 'ADD' record in t$worktable & need to update
                                UPDATE t$worktable SET wk_prev_remain = wk_prev_remain - var_adj_remain
                                WHERE wk_spec = var_prev_loc AND wk_care = var_prev_care AND wk_loc = 'ADD';
                            END IF;

                            IF COALESCE(var_loc,'null') <> 'NULL' THEN  ---need to update/create 'ADD' record for new var_loc
                                IF EXISTS (SELECT 1 FROM t$worktable WHERE wk_spec = var_loc AND wk_care = var_care AND wk_loc = 'ADD') THEN
                                    UPDATE t$worktable SET wk_prev_remain = wk_prev_remain + var_adj_remain
                                    WHERE wk_spec = var_loc AND wk_care = var_care AND wk_loc = 'ADD';
                                ELSE
                                    INSERT INTO t$worktable VALUES (var_loc, var_care, 'ADD', var_adj_remain, var_adj_remain, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                                END IF;
                            END IF;
                        END IF;
                        ----- for LOC -----

                        var_spec := NULL;
                        var_ward_loc := NULL;
                        FETCH daily_ward_spec_csr INTO var_spec, var_ward_loc;
                    END LOOP;
                    CLOSE daily_ward_spec_csr;

                    IF var_test = 'YES' AND var_spec = var_test_spec THEN
                        RAISE NOTICE '----after adj for changed ward pre_remain ----';
                        SELECT * FROM t$daily_ward_txn WHERE ward_spec = var_test_spec;
                        SELECT * FROM t$daily_txn WHERE day_spec = var_test_spec;
                    END IF;
                END IF;			----if var_prev_care <> var_care or var_prev_loc <>var_loc or var_prev_status <> var_active_status

                var_ward := NULL;
                var_loc := NULL;
                var_active_status := NULL;
                var_care := NULL;
                var_adj_remain := 0;
                var_prev_care := NULL;
                var_prev_loc := NULL;
                var_prev_status := NULL;
                FETCH ward_csr INTO var_ward, var_loc, var_active_status, var_care;
            END LOOP;
            CLOSE ward_csr;
        END IF;
        ---if (var_show_prev_remain = 'NO') and var_date >par_from_date
        ------------------------------------------------------------------
        ---- 050429 TO :  init t$daily_txn & previous_remain if Ward's Care changed --- 
        ------------------------------------------------------------------

        -----print 'whilp loop[%1!] - [%2!] - [%3!] - [%4!]',var_date,par_to_date,par_from_date,var_spec
        ---- loop for Ward_specialty to  init the worktable for all Spec & Care type of the Hosp
        ---- TO :  init t$daily_txn & update t$worktable  ip_bed/day_bed
        ------------------------------------------------------------------

        OPEN ward_spec_csr;
        FETCH ward_spec_csr INTO var_spec, var_ward, var_ip_bed, var_day_bed;
        WHILE (CASE WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 END) = 0 
        LOOP

            WITH ranked_ward AS (
                SELECT Care_category, Treatment_location,
                    ROW_NUMBER() OVER (
                        PARTITION BY Ward_code 
                        ORDER BY Effective_date DESC
                    ) as rn
                FROM Ward
                WHERE Ward_code = var_ward
                AND Effective_date <= var_date
                AND Active_status = 'A'         ---0429
            )
            SELECT Care_category, Treatment_location
            --INTO var_care, var_loc
            INTO var_temp_1 ,var_temp_2
            FROM ranked_ward
            WHERE rn = 1;
           	IF FOUND THEN
           		var_care := var_temp_1;
           		var_loc := var_temp_2;
           	END IF;

            IF var_care IS NULL OR NULLIF(TRIM(var_care),'') IS NULL THEN
                var_care := 'M';
            END IF;

            var_loc := NULLIF(TRIM(var_loc),'');

            IF var_loc IS NULL OR NULLIF(TRIM(var_loc),'') IS NULL THEN
                var_loc := 'NULL';
            END IF;

            ----- init/update t$daily_txn ip_bed & day_bed
            IF EXISTS (SELECT 1 FROM t$daily_txn WHERE day_spec = var_spec AND day_care = var_care AND day_loc = var_loc) THEN
                IF var_ip_bed > 0 OR var_day_bed > 0 THEN
                    UPDATE t$daily_txn SET day_ip_bed = day_ip_bed + var_ip_bed, day_day_bed = day_day_bed + var_day_bed
                    WHERE day_spec = var_spec AND day_care = var_care AND day_loc = var_loc;
                END IF;
            ELSE
                INSERT INTO t$daily_txn VALUES (var_spec, var_care, var_loc, var_ip_bed, var_day_bed, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            END IF;

            ------ init/update t$worktable ip_bed & day_bed
            IF EXISTS (SELECT 1 FROM t$worktable WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = var_loc) THEN
                IF var_ip_bed > 0 OR var_day_bed > 0 THEN
                    UPDATE t$worktable SET wk_ip_bed = wk_ip_bed + var_ip_bed, wk_day_bed = wk_day_bed + var_day_bed
                    WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = var_loc;
                END IF;
            ELSE
                INSERT INTO t$worktable VALUES (var_spec, var_care, var_loc, 0, 0, var_ip_bed, var_day_bed, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            END IF;

/*            ----- for LOC -----
            --- ip_bed info for t$daily_txn to calc bed_day_occ/vac/exc for 'ADD' records---
            --- No need ip_bed info for t$worktable ---
            ---if var_loc <> 'NULL' and var_loc is not null  ----and var_loc <> var_spec		--- to avoid : if spec='ICU' & loc ='ICU'
            IF COALESCE (var_loc, 'NULL') <> 'NULL' AND var_loc IS NOT NULL AND var_loc = var_spec THEN
                IF EXISTS (SELECT 1 FROM t$daily_txn WHERE day_spec = var_loc AND day_care = var_care AND day_loc = 'ADD') THEN
                    IF var_ip_bed > 0 OR var_day_bed > 0 THEN
                        UPDATE t$daily_txn SET day_ip_bed = day_ip_bed + var_ip_bed, day_day_bed = day_day_bed + var_day_bed
                        WHERE day_spec = var_loc AND day_care = var_care AND day_loc = 'ADD';
                    END IF;
                ELSE
                    INSERT INTO t$daily_txn VALUES (var_loc, var_care, 'ADD', var_ip_bed, var_day_bed, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                END IF;
            END IF;*/
            ----- for LOC -----

            var_spec := NULL;
            var_ward := NULL;
            var_loc := NULL;
            var_prev_remain := 0;
            var_ip_bed := 0;
            var_day_bed := 0;
            var_prev_care := NULL;
            var_care := NULL;
            var_prev_loc := NULL;
            FETCH ward_spec_csr INTO var_spec, var_ward, var_ip_bed, var_day_bed;
        END LOOP;
        CLOSE ward_spec_csr;
       
       	SELECT day_ip_bed INTO var_temp_int_1 FROM t$daily_txn WHERE var_spec = 'RMDA';
       	RAISE NOTICE 'var_date => [%],t$daily_txn RMDA -> day_ip_bed=> [%]',var_date,var_temp_int_1;
       
       	SELECT wk_ip_bed INTO var_temp_int_1 FROM t$worktable WHERE var_spec = 'RMDA';
       	RAISE NOTICE 'var_date => [%],t$worktable RMDA -> day_ip_bed=> [%]',var_date,var_temp_int_1;

        IF var_test = 'YES' THEN
            RAISE NOTICE '---t$daily_txn/t$daily_war_txn : prev_remain/ip_bed/day_bed ---';
            SELECT * FROM t$daily_txn WHERE day_spec = var_test_spec OR day_loc = var_test_spec;
            SELECT * FROM t$daily_ward_txn WHERE ward_spec = var_test_spec OR ward_loc = var_test_spec;
        END IF;

        --------------------------------------------------------------------
        ----update t$daily_txn for the Tran
        /* init */
        var_hn_adm := 0;
        var_ae_adm := 0;
        var_tx_in := 0;
        var_tx_out := 0;
        var_dsch := 0;
        var_deth := 0;
        var_day_dsch := 0;
        var_day_deth := 0;
        var_ae_day_deth := 0;
        var_ae_day_dsch := 0;
        var_td_in := 0;
        var_td_out := 0;
        var_rtn_td_in := 0;
        var_rtn_td_out := 0;
        var_loc := NULL;

        OPEN tran_log_csr;
        FETCH tran_log_csr INTO var_tx_type, var_src_ind, var_from_loc, var_to_loc, var_from_ward, var_to_ward, var_from_spec, var_to_spec, var_tx_dtm, var_adm_dtm, var_case_no;
        WHILE (CASE WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 END) = 0  
        LOOP

            ---- get var_from_care/var_to_care/var_from_loc/var_to_loc -----
            WITH ranked_ward AS (
                SELECT Care_category, Treatment_location,
                    ROW_NUMBER() OVER (
                        PARTITION BY Ward_code 
                        ORDER BY Effective_date DESC
                    ) as rn
                FROM Ward
                WHERE Ward_code = var_from_ward
                AND Effective_date <= var_date
            )
            SELECT Care_category, Treatment_location
            --INTO var_from_care, var_from_ward_loc
            INTO var_temp_1 ,var_temp_2
            FROM ranked_ward
            WHERE rn = 1;
                    ---and active_status = 'A'
           	IF FOUND THEN
           		var_from_care := var_temp_1;
           		var_from_ward_loc := var_temp_2;
           	END IF;
           	

            WITH ranked_ward AS (
                SELECT Care_category, Treatment_location,
                    ROW_NUMBER() OVER (
                        PARTITION BY Ward_code 
                        ORDER BY Effective_date DESC
                    ) as rn
                FROM Ward
                WHERE Ward_code = var_to_ward
                AND Effective_date <= var_date
            )
            SELECT Care_category, Treatment_location
            --INTO var_to_care, var_to_ward_loc
            INTO var_temp_1 ,var_temp_2 
            FROM ranked_ward
            WHERE rn = 1;
                    --and active_status = 'A'
           	IF FOUND THEN
           		var_to_care := var_temp_1;
           		var_to_ward_loc := var_temp_2;
           	END IF;

            IF var_from_care IS NULL OR NULLIF(TRIM(var_from_care),'') IS NULL THEN
                var_from_care := 'M';
            END IF;
            IF var_to_care IS NULL OR NULLIF(TRIM(var_to_care),'') IS NULL THEN
                var_to_care := 'M';
            END IF;

            var_from_ward_loc := NULLIF(TRIM(var_from_ward_loc),'');
            var_to_ward_loc := NULLIF(TRIM(var_to_ward_loc),'');

            IF var_from_ward_loc IS NULL THEN
                var_from_ward_loc := 'NULL';
            END IF;
            IF var_to_ward_loc IS NULL THEN
                var_to_ward_loc := 'NULL';
            END IF;

            var_from_loc := NULLIF(TRIM(var_from_loc),'');
            var_to_loc := NULLIF(TRIM(var_to_loc),'');

            IF var_from_loc IS NULL THEN
                var_from_loc := var_from_ward_loc;
            END IF;

            IF var_to_loc IS NULL THEN
                var_to_loc := var_to_ward_loc;
            END IF;

            --- 2 or More entries for var_loc ='NULL'/ 'ICU' / 'HDU' for same  var_spec && var_loc ---
            --- To update corresponding ICU/HDU/CCU/.. will base on the var_from_loc info ---
            ---- if var_from_loc is null, try to get var_loc from Ward ---
            --- i.e var_from_loc = 'ICU' but Ward' treatment_loc = null ---
            --------------------------------------------

            /*7.d.2*/
            IF var_tx_type = '100' THEN
                var_hn_adm := 1;
                IF var_src_ind = '3' THEN
                    var_ae_adm := 1;
                END IF;
            END IF;

            /*7.d.3-4*/
            IF var_tx_type = '141' AND (COALESCE(var_from_spec,'NULL') <> COALESCE(var_to_spec,'NULL') OR COALESCE(var_from_care,'NULL') <> COALESCE(var_to_care,'NULL') OR COALESCE(var_from_loc,'NULL') <> COALESCE(var_to_loc,'NULL')) THEN
                var_tx_in := 1;
            END IF;

            IF var_tx_type = '140' AND (COALESCE(var_from_spec,'NULL') <> COALESCE(var_to_spec,'NULL') OR COALESCE(var_from_care,'NULL') <> COALESCE(var_to_care,'NULL') OR COALESCE(var_from_loc,'NULL') <> COALESCE(var_to_loc,'NULL')) THEN
                var_tx_out := 1;
            END IF;

            /*7.d.5*/
            IF var_tx_type LIKE '13_' THEN

                IF var_tx_type = '131' THEN
                    var_deth := 1;
                ELSE
                    var_dsch := 1;
                END IF;

                IF var_src_ind = '3' AND EXTRACT(DAY FROM (var_tx_dtm - var_adm_dtm)) = 0 THEN
                    IF var_tx_type = '131' THEN
                        var_ae_day_deth := 1;
                    ELSE
                        var_ae_day_dsch := 1;
                    END IF;
                END IF;

                IF COALESCE(var_src_ind,'NULL') <> '3' AND EXTRACT(DAY FROM (var_tx_dtm - var_adm_dtm)) = 0 THEN
                    IF var_tx_type = '131' THEN
                        var_day_deth := 1;
                    ELSE
                        var_day_dsch := 1;
                    END IF;
                END IF;
            END IF;

            /*7.d.6-9 */
            IF var_tx_type = '161' THEN
                var_td_in := 1;
            END IF;
            IF var_tx_type = '160' THEN
                var_td_out := 1;
            END IF;
            IF var_tx_type = '170' THEN
                var_rtn_td_in := 1;
            END IF;
            IF var_tx_type = '171' THEN
                var_rtn_td_out := 1;
            END IF;

            -------------begin  Update t$daily_txn tran's values -----------------------------------
            IF EXISTS (SELECT 1 FROM t$daily_txn WHERE day_spec = var_from_spec AND day_care = var_from_care AND day_loc = var_from_loc) THEN
                UPDATE t$daily_txn SET
                    day_hn_adm = day_hn_adm + var_hn_adm,
                    day_ae_adm = day_ae_adm + var_ae_adm,
                    day_tx_in = day_tx_in + var_tx_in,
                    day_tx_out = day_tx_out + var_tx_out,
                    day_td_in = day_td_in + var_td_in,
                    day_td_out = day_td_out + var_td_out,
                    day_dsch = day_dsch + var_dsch,
                    day_deth = day_deth + var_deth,
                    day_ae_day_dsch = day_ae_day_dsch + var_ae_day_dsch,
                    day_ae_day_deth = day_ae_day_deth + var_ae_day_deth,
                    day_day_dsch = day_day_dsch + var_day_dsch,
                    day_day_deth = day_day_deth + var_day_deth,
                    day_rtn_td_out = day_rtn_td_out + var_rtn_td_out,
                    day_rtn_td_in = day_rtn_td_in + var_rtn_td_in
                WHERE day_spec = var_from_spec
                  AND day_care = var_from_care
                  AND day_loc = var_from_loc;
            ELSE
                INSERT INTO t$daily_txn VALUES (var_from_spec, var_from_care, var_from_loc, 0, 0, 0, 0, 0, 0,
                    var_hn_adm, var_ae_adm, var_tx_in, var_tx_out,
                    var_td_in, var_td_out, var_dsch, var_deth,
                    var_day_dsch, var_day_deth, var_ae_day_dsch, var_ae_day_deth,
                    var_rtn_td_out, var_rtn_td_in);
            END IF;

            -------------end of Update t$daily_txn tran's values --------------------------------

            -------------begin  Update t$daily_ward_txn tran's values -----------------------------------
            /*7.d.3-4*/
            /*	----050504 : pynadt
                Transaction_type Transaction_datetime       From_specialty_code To_specialty_code From_treatment_location To_treatment_location From_ward_code To_ward_code 
                141                     Mar 14 2005  5:09AM INEU                MED               ICU                     NULL                  B10H           A4           
                140                     Mar 14 2005 12:15PM INEU                NEU               ICU                     NULL                  B10H           A10          
                141                     Mar 14 2005 12:32PM INEU                NEU               ICU                     NULL                  B10I           A10          
                140                     Mar 14 2005 12:45PM INEU                INEU              ICU                     ICU                   B10I           B10H         
                141                     Mar 14 2005 12:45PM INEU                INEU              ICU                     ICU                   B10H           B10I         
                ==> t$daily_ward_txn's tx_in = 1 	for B10H
                ==> t$daily_txn's tx_in = 1 		for B10I
            */
            ---if var_tx_type = '141' and (var_from_spec <> var_to_spec or var_from_care <> var_to_care or var_from_loc <> var_to_loc )
            var_tx_in := 0;
            var_tx_out := 0;
            IF var_tx_type = '141' AND (COALESCE(var_from_spec,'NULL') <> COALESCE(var_to_spec,'NULL') OR COALESCE(var_from_ward,'NULL') <> COALESCE(var_to_ward,'NULL') OR COALESCE(var_from_loc,'NULL') <> COALESCE(var_to_loc,'NULL')) THEN
                var_tx_in := 1;
            END IF;

            ---if var_tx_type = '140' and (var_from_spec <> var_to_spec or var_from_care <> var_to_care or var_from_loc <> var_to_loc )
            IF var_tx_type = '140' AND (COALESCE(var_from_spec,'NULL') <> COALESCE(var_to_spec,'NULL') OR COALESCE(var_from_ward,'NULL') <> COALESCE(var_to_ward,'NULL') OR COALESCE(var_from_loc,'NULL') <> COALESCE(var_to_loc,'NULL')) THEN
                var_tx_out := 1;
            END IF;

            IF EXISTS (SELECT 1 FROM t$daily_ward_txn WHERE ward_spec = var_from_spec AND ward_ward = var_from_ward AND ward_loc = var_from_loc) THEN
                UPDATE t$daily_ward_txn SET
                    ward_hn_adm = ward_hn_adm + var_hn_adm,
                    ward_ae_adm = ward_ae_adm + var_ae_adm,
                    ward_tx_in = ward_tx_in + var_tx_in,
                    ward_tx_out = ward_tx_out + var_tx_out,
                    ward_td_in = ward_td_in + var_td_in,
                    ward_td_out = ward_td_out + var_td_out,
                    ward_dsch = ward_dsch + var_dsch,
                    ward_deth = ward_deth + var_deth,
                    ward_ae_day_dsch = ward_ae_day_dsch + var_ae_day_dsch,
                    ward_ae_day_deth = ward_ae_day_deth + var_ae_day_deth,
                    ward_day_dsch = ward_day_dsch + var_day_dsch,
                    ward_day_deth = ward_day_deth + var_day_deth,
                    ward_rtn_td_out = ward_rtn_td_out + var_rtn_td_out,
                    ward_rtn_td_in = ward_rtn_td_in + var_rtn_td_in
                WHERE ward_spec = var_from_spec
                  AND ward_ward = var_from_ward
                  AND ward_loc = var_from_loc;
            ELSE
                INSERT INTO t$daily_ward_txn VALUES (var_from_spec, var_from_ward, var_from_loc, 0, 0, 0, 0, 0, 0,
                    var_hn_adm, var_ae_adm, var_tx_in, var_tx_out,
                    var_td_in, var_td_out, var_dsch, var_deth,
                    var_day_dsch, var_day_deth, var_ae_day_dsch, var_ae_day_deth,
                    var_rtn_td_out, var_rtn_td_in);
            END IF;

            -------------end of Update t$daily_ward_txn tran's values --------------------------------

            /* Re-set*/
            var_hn_adm := 0;
            var_ae_adm := 0;
            var_tx_in := 0;
            var_tx_out := 0;
            var_dsch := 0;
            var_deth := 0;
            var_day_dsch := 0;
            var_day_deth := 0;
            var_ae_day_deth := 0;
            var_ae_day_dsch := 0;
            var_td_in := 0;
            var_td_out := 0;
            var_rtn_td_in := 0;
            var_rtn_td_out := 0;
            var_loc := NULL;

            FETCH tran_log_csr INTO var_tx_type, var_src_ind, var_from_loc, var_to_loc, var_from_ward, var_to_ward, var_from_spec, var_to_spec, var_tx_dtm, var_adm_dtm, var_case_no;
        END LOOP;
        CLOSE tran_log_csr;

        -------------------------------------------------------------------
        ---- Update t$daily_ward_txn's prev_remain  -----
        -------------------------------------------------------------------

        ----clean t$daily_ward_txn before open daily_ward_csr  ----
        DELETE FROM t$daily_ward_txn
        WHERE ward_prev_remain = 0
              AND ward_ip_bed = 0
              AND ward_day_bed = 0
              AND ward_hn_adm = 0
              AND ward_ae_adm = 0
              AND ward_tx_in = 0
              AND ward_tx_out = 0
              AND ward_td_in = 0
              AND ward_td_out = 0
              AND ward_dsch = 0
              AND ward_deth = 0
              AND ward_ae_day_dsch = 0
              AND ward_ae_day_deth = 0
              AND ward_day_dsch = 0
              AND ward_day_deth = 0
              AND ward_rtn_td_out = 0
              AND ward_rtn_td_in = 0
              AND ward_bed_day_occ = 0
              AND ward_bed_day_vac = 0
              AND ward_bed_day_exc = 0;

        IF var_test = 'YES' THEN
            RAISE NOTICE '---- t$daily_ward_txn info  ---';
            SELECT * FROM t$daily_ward_txn WHERE ward_spec = var_test_spec OR ward_loc = var_test_spec ORDER BY ward_spec;
        END IF;

        var_prev_remain := 0;
        var_hn_adm := 0;
        var_ae_adm := 0;
        var_tx_in := 0;
        var_tx_out := 0;
        var_dsch := 0;
        var_deth := 0;
        var_day_dsch := 0;
        var_day_deth := 0;
        var_ae_day_deth := 0;
        var_ae_day_dsch := 0;
        var_td_in := 0;
        var_td_out := 0;
        var_rtn_td_in := 0;
        var_rtn_td_out := 0;

        var_ttl_remain := 0;
        var_bdo := 0;
        var_ip_bed := 0;
        var_day_bed := 0;
        var_ttl_bed_day_occ := 0;
        var_ttl_bed_day_vac := 0;
        var_ttl_bed_day_exc := 0;

        OPEN daily_ward_csr;
        FETCH daily_ward_csr INTO var_spec, var_ward, var_loc, var_ip_bed, var_day_bed, var_prev_remain, var_hn_adm, var_ae_adm, var_tx_in, var_tx_out, var_td_in, var_td_out, var_dsch, var_deth, var_ae_day_dsch, var_ae_day_deth, var_day_dsch, var_day_deth, var_rtn_td_out, var_rtn_td_in;
        WHILE (CASE WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 END) = 0  
        LOOP
            var_ttl_remain := var_prev_remain + var_hn_adm + var_tx_in + var_td_in
                - var_tx_out - var_td_out - var_dsch - var_deth + var_rtn_td_out - var_rtn_td_in;
               
           	/*IF var_spec = 'RMDA' OR var_loc = 'RMDA' THEN
           		RAISE NOTICE 'RMDA var_ttl_remain=>[%]',var_ttl_remain;
           	END IF;*/
           	

            --- Reset daily_bed's daily tran. info ---
            UPDATE t$daily_ward_txn SET
                ward_prev_remain = var_ttl_remain, --- Update pre_remain for Next day's Calc.
                ward_ip_bed = 0,
                ward_day_bed = 0,
                ward_hn_adm = 0,
                ward_ae_adm = 0,
                ward_tx_in = 0,
                ward_tx_out = 0,
                ward_td_in = 0,
                ward_td_out = 0,
                ward_dsch = 0,
                ward_deth = 0,
                ward_ae_day_dsch = 0,
                ward_ae_day_deth = 0,
                ward_day_dsch = 0,
                ward_day_deth = 0,
                ward_rtn_td_out = 0,
                ward_rtn_td_in = 0
            WHERE ward_spec = var_spec AND ward_ward = var_ward AND ward_loc = var_loc;

            ---- re-init ----
            var_prev_remain := 0;
            var_hn_adm := 0;
            var_ae_adm := 0;
            var_tx_in := 0;
            var_tx_out := 0;
            var_dsch := 0;
            var_deth := 0;
            var_day_dsch := 0;
            var_day_deth := 0;
            var_ae_day_deth := 0;
            var_ae_day_dsch := 0;
            var_td_in := 0;
            var_td_out := 0;
            var_rtn_td_in := 0;
            var_rtn_td_out := 0;
            var_loc_ip_bed := 0;
            var_ttl_remain := 0;
            var_bdo := 0;
            var_ip_bed := 0;
            var_day_bed := 0;
            var_ttl_bed_day_occ := 0;
            var_ttl_bed_day_vac := 0;
            var_ttl_bed_day_exc := 0;

            FETCH daily_ward_csr INTO var_spec, var_ward, var_loc, var_ip_bed, var_day_bed, var_prev_remain, var_hn_adm, var_ae_adm, var_tx_in, var_tx_out, var_td_in, var_td_out, var_dsch, var_deth, var_ae_day_dsch, var_ae_day_deth, var_day_dsch, var_day_deth, var_rtn_td_out, var_rtn_td_in;
        END LOOP;
        CLOSE daily_ward_csr;
        -------------------------------------------------------------------
        ---- Update t$daily_ward_txn's prev_remain  -----
        -------------------------------------------------------------------

        -------------------------------------------------------------------
        ---- Update t$worktable  values day t$daily_txn  -----
        -------------------------------------------------------------------
        var_prev_remain := 0;
        var_hn_adm := 0;
        var_ae_adm := 0;
        var_tx_in := 0;
        var_tx_out := 0;
        var_dsch := 0;
        var_deth := 0;
        var_day_dsch := 0;
        var_day_deth := 0;
        var_ae_day_deth := 0;
        var_ae_day_dsch := 0;
        var_td_in := 0;
        var_td_out := 0;
        var_rtn_td_in := 0;
        var_rtn_td_out := 0;
        var_ttl_remain := 0;
        var_bdo := 0;
        var_ip_bed := 0;
        var_day_bed := 0;
        var_ttl_bed_day_occ := 0;
        var_ttl_bed_day_vac := 0;
        var_ttl_bed_day_exc := 0;

        ---050426 ---
        ----clean t$daily_txn before open daily_csr  ----
        DELETE FROM t$daily_txn
        WHERE day_prev_remain = 0
              AND day_ip_bed = 0
              AND day_day_bed = 0
              AND day_hn_adm = 0
              AND day_ae_adm = 0
              AND day_tx_in = 0
              AND day_tx_out = 0
              AND day_td_in = 0
              AND day_td_out = 0
              AND day_dsch = 0
              AND day_deth = 0
              AND day_ae_day_dsch = 0
              AND day_ae_day_deth = 0
              AND day_day_dsch = 0
              AND day_day_deth = 0
              AND day_rtn_td_out = 0
              AND day_rtn_td_in = 0
              AND day_bed_day_occ = 0
              AND day_bed_day_vac = 0
              AND day_bed_day_exc = 0;

        IF var_test = 'YES' THEN
            RAISE NOTICE '---- t$daily_txn info  ---';
            SELECT * FROM t$daily_txn WHERE day_spec = var_test_spec OR day_loc = var_test_spec ORDER BY day_spec;
        END IF;

        OPEN daily_csr;
        FETCH daily_csr INTO var_spec, var_care, var_loc, var_ip_bed, var_day_bed, var_prev_remain, var_hn_adm, var_ae_adm, var_tx_in, var_tx_out, var_td_in, var_td_out, var_dsch, var_deth, var_ae_day_dsch, var_ae_day_deth, var_day_dsch, var_day_deth, var_rtn_td_out, var_rtn_td_in;
        WHILE (CASE WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 END) = 0  
        LOOP

            IF var_hn_adm <> 0 OR var_ae_adm <> 0 OR var_tx_in <> 0 OR var_tx_out <> 0 OR var_td_in <> 0
        	OR var_td_out <> 0 OR var_dsch <> 0 OR var_deth <> 0 OR var_ae_day_dsch <> 0 OR var_ae_day_deth <> 0 
        	OR var_day_dsch <> 0 OR var_day_deth <> 0 OR var_rtn_td_out <> 0 OR var_rtn_td_in <> 0 OR var_prev_remain <> 0 OR var_ip_bed <> 0 THEN  --- or var_day_bed <> 0
                var_ttl_remain := var_prev_remain + var_hn_adm + var_tx_in + var_td_in
                    - var_tx_out - var_td_out - var_dsch - var_deth + var_rtn_td_out - var_rtn_td_in;

                var_bdo := var_ttl_remain + var_ae_day_dsch + var_ae_day_deth;

                IF var_bdo > var_ip_bed THEN
                    var_ttl_bed_day_vac := 0;
                    var_ttl_bed_day_exc := var_bdo - var_ip_bed;
                ELSIF var_bdo = var_ip_bed THEN
                    var_ttl_bed_day_exc := 0;
                    var_ttl_bed_day_vac := 0;
                ELSIF var_bdo < var_ip_bed THEN
                    var_ttl_bed_day_vac := var_ip_bed - var_bdo;
                    var_ttl_bed_day_exc := 0;
                END IF;
               
               	/*IF var_spec = 'RMDA' OR var_loc = 'RMDA' THEN
               		RAISE NOTICE 'daily_csr - var_care => [%],var_ttl_bed_day_exc => [%],var_ttl_bed_day_vac => [%]',var_care,var_ttl_bed_day_exc,var_ttl_bed_day_vac;
               	END IF;*/
               	

                ---- Update t$worktable's values ----
                IF EXISTS (SELECT 1 FROM t$worktable WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = var_loc) THEN
                    UPDATE t$worktable SET
                        wk_hn_adm = wk_hn_adm + var_hn_adm,
                        wk_ae_adm = wk_ae_adm + var_ae_adm,
                        wk_tx_in = wk_tx_in + var_tx_in,
                        wk_tx_out = wk_tx_out + var_tx_out,
                        wk_td_in = wk_td_in + var_td_in,
                        wk_td_out = wk_td_out + var_td_out,
                        wk_dsch = wk_dsch + var_dsch,
                        wk_deth = wk_deth + var_deth,
                        wk_ae_day_dsch = wk_ae_day_dsch + var_ae_day_dsch,
                        wk_ae_day_deth = wk_ae_day_deth + var_ae_day_deth,
                        wk_day_dsch = wk_day_dsch + var_day_dsch,
                        wk_day_deth = wk_day_deth + var_day_deth,
                        wk_rtn_td_out = wk_rtn_td_out + var_rtn_td_out,
                        wk_rtn_td_in = wk_rtn_td_in + var_rtn_td_in,
                        wk_prev_remain = var_ttl_remain,
                        wk_remain = wk_remain + var_ttl_remain,
                        wk_bed_day_occ = wk_bed_day_occ + var_bdo,
                        wk_bed_day_vac = wk_bed_day_vac + var_ttl_bed_day_vac,
                        wk_bed_day_exc = wk_bed_day_exc + var_ttl_bed_day_exc
                    WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = var_loc;
                ELSE  ----- For spec&care which didn't create during init. t$worktable
                    INSERT INTO t$worktable VALUES (var_spec, var_care, var_loc, 0, var_ttl_remain, 0, 0,
                        var_hn_adm, var_ae_adm, var_tx_in, var_tx_out,
                        var_td_in, var_td_out, var_dsch, var_deth,
                        var_day_dsch, var_day_deth, var_ae_day_dsch, var_ae_day_deth,
                        var_ttl_remain, var_bdo, var_ttl_bed_day_vac, var_ttl_bed_day_exc, var_rtn_td_out, var_rtn_td_in);
                END IF;

                ----------------------------------------------------------------------------------
                --- update For LOC which spec=var_loc
                --- 2 or More entries for var_loc ='NULL'/ 'ICU' / 'HDU' for same  var_spec && var_loc ---
                --- How to update corresponding ICU/HDU/CCU for var_loc ='NULL' ,etc base on tran_log_csr's var_from_loc---

                var_loc := NULLIF(TRIM(var_loc),'');

                IF (COALESCE(var_loc,'null') <> 'NULL') AND (var_loc IS NOT NULL) AND COALESCE(var_spec,'NULL') <> COALESCE(var_loc,'NULL') THEN

                    IF EXISTS (SELECT 1 FROM t$worktable WHERE wk_spec = var_loc AND wk_care = var_care AND wk_loc = 'ADD') THEN
                        UPDATE t$worktable SET
                            wk_hn_adm = wk_hn_adm + var_hn_adm,
                            wk_ae_adm = wk_ae_adm + var_ae_adm,
                            wk_tx_in = wk_tx_in + var_tx_in,
                            wk_tx_out = wk_tx_out + var_tx_out,
                            wk_td_in = wk_td_in + var_td_in,
                            wk_td_out = wk_td_out + var_td_out,
                            wk_dsch = wk_dsch + var_dsch,
                            wk_deth = wk_deth + var_deth,
                            wk_ae_day_dsch = wk_ae_day_dsch + var_ae_day_dsch,
                            wk_ae_day_deth = wk_ae_day_deth + var_ae_day_deth,
                            wk_day_dsch = wk_day_dsch + var_day_dsch,
                            wk_day_deth = wk_day_deth + var_day_deth,
                            wk_rtn_td_out = wk_rtn_td_out + var_rtn_td_out,
                            wk_rtn_td_in = wk_rtn_td_in + var_rtn_td_in,
                            wk_prev_remain = var_ttl_remain,
                            wk_remain = wk_remain + var_ttl_remain,
                            wk_bed_day_occ = wk_bed_day_occ + var_bdo
                            ---wk_bed_day_vac = wk_bed_day_vac + var_ttl_bed_day_vac,---050426 MUST remark ! to upd offset table  --
                            ---wk_bed_day_exc = wk_bed_day_exc + var_ttl_bed_day_exc
                        WHERE wk_spec = var_loc AND wk_care = var_care AND wk_loc = 'ADD';
                    ELSE
                        INSERT INTO t$worktable VALUES (var_loc, var_care, 'ADD', 0, var_ttl_remain, 0, 0,
                            var_hn_adm, var_ae_adm, var_tx_in, var_tx_out,
                            var_td_in, var_td_out, var_dsch, var_deth,
                            var_day_dsch, var_day_deth, var_ae_day_dsch, var_ae_day_deth,
                            --0503 var_ttl_remain, var_bdo, var_ttl_bed_day_vac, var_ttl_bed_day_exc, var_rtn_td_out, var_rtn_td_in);
                            var_ttl_remain, var_bdo, 0, 0, var_rtn_td_out, var_rtn_td_in);
                    END IF;

                END IF;	--- update For LOC ---

                ------------------------------------------------------------------------------------------
                ----- for spec with 'ADD' record ==> calc. bed_day_vac/exc by t$daily_loc_bed_day ---
                --- for spec =loc, like 'ICU/ICU', calc bed_day_vac/exc in 'ADD' --
                --- temp table to hold bed_day_occ to calc bed_day_vac/exec for LOC ---
                ---- for spec  with loc in('NULL','ADD',etc) --
                ---i.e ICU / NULL  will count under ICU/ADD if ICU/ADD found ---
                IF (var_loc = 'NULL') OR (var_loc IS NULL) THEN
                    --0503 if exists (select * from t$worktable where wk_spec =var_spec and wk_care = var_care and wk_loc='ADD')
                    --begin
                    SELECT SUM(COALESCE(day_ip_bed, 0)) INTO var_loc_ip_bed FROM t$daily_txn
                    WHERE day_spec = var_spec AND day_care = var_care
                    GROUP BY day_spec, day_care;

                    IF EXISTS (SELECT 1 FROM t$daily_loc_bed_day WHERE loc_spec = var_spec AND loc_care = var_care AND loc_loc = 'ADD') THEN
                        UPDATE t$daily_loc_bed_day SET loc_bed_day_occ = loc_bed_day_occ + var_bdo
                        WHERE loc_spec = var_spec AND loc_care = var_care AND loc_loc = 'ADD';
                    ELSE
                        INSERT INTO t$daily_loc_bed_day VALUES (var_spec, var_care, 'ADD', var_loc_ip_bed, var_bdo);
                    END IF;
                    --end
                    ---- No need to upd offset table AS the bed_day values create by SPEC ----
                END IF;

                --- i.e ICU/ICU or Others/ICU  will count under ICU/ADD if ICU/ADD found ---
                IF (COALESCE(var_loc,'null') <> 'NULL') OR (var_loc IS NOT NULL) THEN ---and var_spec = var_loc

                    --	0503	if exists (select * from t$worktable where wk_spec =var_loc and wk_care = var_care and wk_loc='ADD')
                    --		begin
                    SELECT SUM(COALESCE(day_ip_bed, 0)) INTO var_loc_ip_bed FROM t$daily_txn
                    WHERE day_spec = var_loc AND day_care = var_care
                    GROUP BY day_spec, day_care;

                    IF EXISTS (SELECT 1 FROM t$daily_loc_bed_day WHERE loc_spec = var_loc AND loc_care = var_care AND loc_loc = 'ADD') THEN
                        UPDATE t$daily_loc_bed_day SET loc_bed_day_occ = loc_bed_day_occ + var_bdo
                        WHERE loc_spec = var_loc AND loc_care = var_care AND loc_loc = 'ADD';
                    ELSE
                        INSERT INTO t$daily_loc_bed_day VALUES (var_loc, var_care, 'ADD', var_loc_ip_bed, var_bdo);
                    END IF;

                    ---- need to upd offset table of var_SPEC AS the bed_day values created by LOC ----
                    ------- upd offset table for bed_day_vac/exc As the values already count under loc ---
                    var_ttl_bed_day_vac := 0 - var_ttl_bed_day_vac;
                    var_ttl_bed_day_exc := 0 - var_ttl_bed_day_exc;

                    --- Upd Offset for var_SPEC as the bed_day_vac/exc already count under var_LOC ---
                    IF EXISTS (SELECT 1 FROM t$worktable_offset_summ WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = 'ADD') THEN
                        UPDATE t$worktable_offset_summ SET wk_bed_day_vac = wk_bed_day_vac + COALESCE(var_ttl_bed_day_vac, 0),
                                                           wk_bed_day_exc = wk_bed_day_exc + COALESCE(var_ttl_bed_day_exc, 0)
                        WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = 'ADD';
                    ELSE
                        ---insert into t$worktable_offset_summ values (var_loc,var_care,'ADD',0,0,0,0,
                        INSERT INTO t$worktable_offset_summ VALUES (var_spec, var_care, 'ADD', 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, var_ttl_bed_day_vac, var_ttl_bed_day_exc, 0, 0);
                    END IF;
                    --0503 end
                END IF;	----if ((var_loc <> 'NULL') or (var_loc is not null)) ---and var_spec = var_loc
                ------------------------------------------------------------------------------------------
                --- Reset daily_bed's daily tran. info ---
                UPDATE t$daily_txn SET
                    day_prev_remain = var_ttl_remain, --- Update pre_remain for Next day's Calc.
                    day_ip_bed = 0,
                    day_day_bed = 0,
                    day_hn_adm = 0,
                    day_ae_adm = 0,
                    day_tx_in = 0,
                    day_tx_out = 0,
                    day_td_in = 0,
                    day_td_out = 0,
                    day_dsch = 0,
                    day_deth = 0,
                    day_ae_day_dsch = 0,
                    day_ae_day_deth = 0,
                    day_day_dsch = 0,
                    day_day_deth = 0,
                    day_rtn_td_out = 0,
                    day_rtn_td_in = 0
                WHERE day_spec = var_spec AND day_care = var_care AND day_loc = var_loc;
            END IF; --- end of daily txn's values > 0 ---

            ---- re-init ----
            var_prev_remain := 0;
            var_hn_adm := 0;
            var_ae_adm := 0;
            var_tx_in := 0;
            var_tx_out := 0;
            var_dsch := 0;
            var_deth := 0;
            var_day_dsch := 0;
            var_day_deth := 0;
            var_ae_day_deth := 0;
            var_ae_day_dsch := 0;
            var_td_in := 0;
            var_td_out := 0;
            var_rtn_td_in := 0;
            var_rtn_td_out := 0;
            var_loc_ip_bed := 0;
            var_ttl_remain := 0;
            var_bdo := 0;
            var_ip_bed := 0;
            var_day_bed := 0;
            var_ttl_bed_day_occ := 0;
            var_ttl_bed_day_vac := 0;
            var_ttl_bed_day_exc := 0;

            FETCH daily_csr INTO var_spec, var_care, var_loc, var_ip_bed, var_day_bed, var_prev_remain, var_hn_adm, var_ae_adm, var_tx_in, var_tx_out, var_td_in, var_td_out, var_dsch, var_deth, var_ae_day_dsch, var_ae_day_deth, var_day_dsch, var_day_deth, var_rtn_td_out, var_rtn_td_in;
        END LOOP;
        CLOSE daily_csr;
        -------------------------------------------------------------------
        ---- END of - Update t$worktable  values day t$daily_txn  -----
        -------------------------------------------------------------------
        ----050426 clean the t$worktable ---
        DELETE FROM t$worktable
        WHERE wk_hn_adm = 0
           AND wk_ae_adm = 0
           AND wk_tx_in = 0
           AND wk_tx_out = 0
           AND wk_dsch = 0
           AND wk_deth = 0
           AND wk_ae_day_dsch = 0
           AND wk_ae_day_deth = 0
           AND wk_day_dsch = 0
           AND wk_day_deth = 0
           AND wk_td_in = 0
           AND wk_td_out = 0
           AND wk_rtn_td_out = 0
           AND wk_rtn_td_in = 0
           AND wk_remain = 0
           AND wk_bed_day_occ = 0
           AND wk_bed_day_vac = 0
           AND wk_bed_day_exc = 0
           AND wk_ip_bed = 0
           AND wk_day_bed = 0
           AND wk_prev_remain = 0
           AND wk_org_prev_remain = 0;
        --------------------------------------

        var_spec := NULL;
        var_care := NULL;
        var_loc := NULL;
        var_loc_ip_bed := 0;
        var_bdo := 0;
        var_ttl_bed_day_vac := 0;
        var_ttl_bed_day_exc := 0;

        -------------------------------------------------------------------
        ---- Update t$worktable  bed_day_vac/exc values by t$daily_loc_bed_day  -----
        ----delete from t$daily_loc_bed_day where loc_spec='NULL'
        --- Calc bed_day_vac/exc for SPEC which created by LOC i.e ICU/ICU & ISUR/ICU ---
        OPEN daily_loc_csr;
        FETCH daily_loc_csr INTO var_spec, var_care, var_loc, var_loc_ip_bed, var_bdo;
        WHILE (CASE WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 END) = 0  
        LOOP

            ----- calc bed_days for loc ----
            IF var_bdo > var_loc_ip_bed THEN
                var_ttl_bed_day_vac := 0;
                var_ttl_bed_day_exc := var_bdo - var_loc_ip_bed;
            ELSIF var_bdo = var_loc_ip_bed THEN
                var_ttl_bed_day_exc := 0;
                var_ttl_bed_day_vac := 0;
            ELSIF var_bdo < var_loc_ip_bed THEN
                var_ttl_bed_day_vac := var_loc_ip_bed - var_bdo;
                var_ttl_bed_day_exc := 0;
            END IF;
           
           	/*IF var_spec = 'RMDA' OR var_loc = 'RMDA' THEN
           		RAISE NOTICE 'daily_loc_csr - var_care => [%],var_ttl_bed_day_exc => [%],var_ttl_bed_day_vac => [%]',
           					var_care,var_ttl_bed_day_exc,var_ttl_bed_day_vac;
           	END IF;*/

            IF EXISTS (SELECT 1 FROM t$worktable WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = 'ADD') THEN
                UPDATE t$worktable SET
                    wk_bed_day_vac = wk_bed_day_vac + var_ttl_bed_day_vac,
                    wk_bed_day_exc = wk_bed_day_exc + var_ttl_bed_day_exc
                WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = 'ADD';

                ---- For spec/loc = ICU/ICU, bed_vac Calc under ICU/@care/ADD record , ---
                ----  reset bed_day ICU/@care/NULL as 0 ----
                UPDATE t$worktable SET
                    wk_bed_day_vac = 0,
                    wk_bed_day_exc = 0
                WHERE wk_spec = var_spec AND wk_care = var_care AND COALESCE(wk_loc,'NULL') <> 'ADD';
            END IF;

            var_spec := NULL;
            var_care := NULL;
            var_loc := NULL;
            var_loc_ip_bed := 0;
            var_bdo := 0;
            var_ttl_bed_day_vac := 0;
            var_ttl_bed_day_exc := 0;
            FETCH daily_loc_csr INTO var_spec, var_care, var_loc, var_loc_ip_bed, var_bdo;
        END LOOP;
        CLOSE daily_loc_csr;

        IF var_test = 'YES' THEN
            RAISE NOTICE '---- t$worktable info  ---';
            SELECT * FROM t$worktable WHERE wk_spec = var_test_spec OR wk_loc = var_test_spec;
            SELECT * FROM t$daily_loc_bed_day WHERE loc_spec = var_test_spec OR loc_loc = var_test_spec;
        END IF;

        DELETE FROM t$daily_loc_bed_day;

        -------------------------------------------------------------------
        ---- END of - Update t$worktable  bed_day_vac/exc values day t$daily_loc_bed_day -----
        -------------------------------------------------------------------

        var_date := var_date + INTERVAL '1 day';
    END LOOP;
    /* end of loop by Day  : 7.For each Processing Date >= From Date and <= To Date */

    IF var_test = 'YES' THEN
        RAISE NOTICE '------before format report--';
        SELECT * FROM t$daily_loc_bed_day WHERE loc_spec = var_test_spec OR loc_loc = var_test_spec;
        SELECT * FROM t$worktable WHERE wk_spec = var_test_spec OR wk_loc = var_test_spec;
        SELECT * FROM t$worktable_offset_summ WHERE wk_spec = var_test_spec;
    END IF;

    ----------------------------------------------------
    --- Format the output for report ---
    ----------------------------------------------------
    var_care_count := 0;
    var_prev_care := NULL;
    var_prev_spec := NULL;

    /* del from t$worktable according to par_input_spec_list /par_input_care_list*/
    IF par_input_care_list IS NOT NULL THEN
        var_count := 1;
        WHILE var_count <= 10 LOOP
            var_selected_care := SUBSTRING(par_input_care_list, var_count, 1);
            IF NULLIF(TRIM(var_selected_care),'') IS NULL THEN
                var_count := 100;
                EXIT;
            ELSE
                INSERT INTO t$wk_summ_tmp
                SELECT * FROM t$worktable
                WHERE wk_care = var_selected_care;
            END IF;

            var_count := var_count + 1;
        END LOOP;
    ELSE
        INSERT INTO t$wk_summ_tmp
        SELECT * FROM t$worktable;
    END IF;

    IF par_input_spec_list IS NOT NULL THEN
        var_count := 1;
        WHILE var_count <= 40 LOOP  ----max 10 Spec code
            var_selected_spec := SUBSTRING(par_input_spec_list, var_count, 4);
            var_selected_spec := NULLIF(TRIM(var_selected_spec),''); --- trim space like: 'MED '

            IF NULLIF(TRIM(var_selected_spec),'') IS NULL THEN
                var_count := 100;
                EXIT;
            ELSE
                INSERT INTO t$worktable_summ
                SELECT * FROM t$wk_summ_tmp
                WHERE wk_spec = var_selected_spec;
            END IF;
            var_count := var_count + 4;			---len(spec_code)=4
        END LOOP;
    ELSE
        INSERT INTO t$worktable_summ
        SELECT * FROM t$wk_summ_tmp;
       
    END IF;
   	
   	SELECT count(*) INTO var_temp_int_1 FROM t$worktable_summ WHERE wk_spec = 'RMDA';
   	RAISE NOTICE 'count RMDA 1701=> [%]',var_temp_int_1;
   
   	SELECT json_agg(t) INTO v_json FROM t$worktable_summ t WHERE wk_spec = 'RMDA';
   	RAISE NOTICE 'json  RMDA 1701=> [%]',v_json;
    -------------------------------------------------------------------

    --- init ---
    var_sum_remain := 0;
    var_sum_org_prev_remain := 0;
    var_sum_ip_bed := 0;
    var_sum_day_bed := 0;
    var_sum_hn_adm := 0;
    var_sum_ae_adm := 0;
    var_sum_tx_in := 0;
    var_sum_tx_out := 0;
    var_sum_td_in := 0;
    var_sum_td_out := 0;
    var_sum_dsch := 0;
    var_sum_deth := 0;
    var_sum_ae_day_dsch := 0;
    var_sum_ae_day_deth := 0;
    var_sum_day_dsch := 0;
    var_sum_day_deth := 0;
    var_sum_bed_day_occ := 0;
    var_sum_bed_day_vac := 0;
    var_sum_bed_day_exc := 0;
    var_sum_rtn_td_out := 0;
    var_sum_rtn_td_in := 0;
    var_sum_prev_remain := 0;
    var_record_count := 0;

    ---handle for wk_loc='ADD' ----
    -- clean the t$worktable_summ(i.e del Treat_loc 'ADD' records) for format t$dsptable ---
    -- t$worktable_summ only hold @spec/ @care / 'NULL' records with 'ADD'ed values --
    --- 'ADD' record temp store in t$worktable_offset_summ for calc hospital total--
    -------------------------------------------------------------------
    DELETE FROM t$worktable_summ
    WHERE wk_hn_adm = 0
       AND wk_ae_adm = 0
       AND wk_tx_in = 0
       AND wk_tx_out = 0
       AND wk_dsch = 0
       AND wk_deth = 0
       AND wk_ae_day_dsch = 0
       AND wk_ae_day_deth = 0
       AND wk_day_dsch = 0
       AND wk_day_deth = 0
       AND wk_td_in = 0
       AND wk_td_out = 0
       AND wk_rtn_td_out = 0
       AND wk_rtn_td_in = 0
       AND wk_remain = 0
       AND wk_bed_day_occ = 0
       AND wk_bed_day_vac = 0
       AND wk_bed_day_exc = 0
       AND wk_ip_bed = 0
       AND wk_day_bed = 0
       AND wk_prev_remain = 0;

    ----050428 ---
    -----for ICU/H/ADD ==> create new ICU/H/ICU to hold added values for work_summ_loc_csr --------------
    var_spec := NULL;
    var_care := NULL;
    var_loc := NULL;
    var_ip_bed := 0;

    OPEN work_summ_loc_add_csr;			--- where wk_loc = 'ADD' ----
    FETCH work_summ_loc_add_csr INTO var_spec, var_care, var_loc, var_ip_bed;
    WHILE (CASE WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 END) = 0  
    LOOP
        ---- only one record ICU/H/ADD found ----
        IF NOT EXISTS (SELECT 1 FROM t$worktable_summ WHERE wk_spec = var_spec AND wk_care = var_care AND COALESCE(wk_loc,'NULL') <> 'ADD') THEN
            INSERT INTO t$worktable_summ VALUES (var_spec, var_care, var_spec, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

        /* --- ICU/H/ADD & H=HDU have ip_bed > 0 => can't set bed_day_vac/exc = 0----
                if var_ip_bed = 0 
                begin
                    update t$worktable_summ
                    set wk_bed_day_vac = 0,
                        wk_bed_day_exc = 0
                    where wk_spec=var_spec and wk_care = var_care and wk_loc ='ADD' 
                    
                end
            */
        END IF;

        var_spec := NULL;
        var_care := NULL;
        var_loc := NULL;
        var_ip_bed := 0;

        FETCH work_summ_loc_add_csr INTO var_spec, var_care, var_loc, var_ip_bed;
    END LOOP;
    CLOSE work_summ_loc_add_csr;
   
   	SELECT count(*) INTO var_temp_int_1 FROM t$worktable_summ WHERE wk_spec = 'RMDA';
   	RAISE NOTICE 'count RMDA1795 => [%]',var_temp_int_1;
    --------------------------------------------

    IF var_test = 'YES' THEN
        RAISE NOTICE '--- before clean t$worktable_summ ---';
        SELECT * FROM t$worktable_summ;
    END IF;
    ------------------------------------------------------------------------------
    var_spec := NULL;
    var_care := NULL;
    var_loc := NULL;

    OPEN work_summ_loc_csr;			--- where wk_loc <> 'ADD' ----
    FETCH work_summ_loc_csr INTO var_spec, var_care, var_loc;
    WHILE (CASE WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 END) = 0  
    LOOP

        --- (ICU/H/ADD and ICU/U/ICU) how to handle for ICU/H/ADD ??---

        --- (GYN/A/NULL and no GYN/A/ADD) --- Nothing to do here ---
        --- (ICU/A/ICU and no ICU/A/ADD)	==> nothing to do ---
        --- (MED/A/ICU or ISUR/A/ICU )--- => @spec/A/ICU's bed_day_vac/exc is null ----
        -----------------------------------------------------------
        ---- HDU/A/ICU  ?? ----
        IF COALESCE(var_loc,'null') <> 'NULL' AND COALESCE(var_spec,'NULL') <> COALESCE(var_loc,'NULL') THEN
            SELECT COALESCE(wk_ip_bed, 0) INTO var_ip_bed
            FROM t$worktable_summ
            WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = var_loc;

            ---- HDU/A/ICU  which ip_bed >0 Which is different MED/A/ICU which ip_bed = 0 =>   ----

            IF EXISTS (SELECT 1 FROM t$worktable_summ WHERE wk_spec = var_loc) AND (var_ip_bed = 0) THEN
                ---if exists (select * from t$worktable_summ where wk_spec = var_loc )
                UPDATE t$worktable_summ SET wk_bed_day_vac = 0,
                                            wk_bed_day_exc = 0
                WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = var_loc;
            END IF;

            var_ip_bed := 0;
        END IF;

        --- (PICU/A/PICU and has PICU/A/NULL) ---
        ---- delete PICU/A/NULL record from t$worktable_summ ----
        IF COALESCE(var_loc,'null') <> 'NULL' AND COALESCE(var_spec,'NULL') = COALESCE(var_loc,'NULL') THEN
            var_record_count := 0;
            SELECT COUNT(*) INTO var_record_count FROM t$worktable_summ
            WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = 'NULL';

            IF var_record_count >= 1 THEN  ---- found 'NULL' record for spec/spec/NULL
                SELECT SUM(COALESCE(wk_remain, 0)),
                       SUM(COALESCE(wk_prev_remain, 0)),
                       SUM(COALESCE(wk_org_prev_remain, 0)),
                       SUM(COALESCE(wk_ip_bed, 0)),
                       SUM(COALESCE(wk_day_bed, 0)),
                       SUM(COALESCE(wk_hn_adm, 0)),
                       SUM(COALESCE(wk_ae_adm, 0)),
                       SUM(COALESCE(wk_tx_in, 0)),
                       SUM(COALESCE(wk_tx_out, 0)),
                       SUM(COALESCE(wk_td_in, 0)),
                       SUM(COALESCE(wk_td_out, 0)),
                       SUM(COALESCE(wk_dsch, 0)),
                       SUM(COALESCE(wk_deth, 0)),
                       SUM(COALESCE(wk_ae_day_dsch, 0)),
                       SUM(COALESCE(wk_ae_day_deth, 0)),
                       SUM(COALESCE(wk_day_dsch, 0)),
                       SUM(COALESCE(wk_day_deth, 0)),
                       SUM(COALESCE(wk_bed_day_occ, 0)),
                       SUM(COALESCE(wk_bed_day_vac, 0)),
                       SUM(COALESCE(wk_bed_day_exc, 0)),
                       SUM(COALESCE(wk_rtn_td_in, 0)),
                       SUM(COALESCE(wk_rtn_td_out, 0))
                INTO var_sum_remain, var_sum_prev_remain, var_sum_org_prev_remain, var_sum_ip_bed, var_sum_day_bed, var_sum_hn_adm, var_sum_ae_adm, var_sum_tx_in, var_sum_tx_out, var_sum_td_in, var_sum_td_out, var_sum_dsch, var_sum_deth, var_sum_ae_day_dsch, var_sum_ae_day_deth, var_sum_day_dsch, var_sum_day_deth, var_sum_bed_day_occ, var_sum_bed_day_vac, var_sum_bed_day_exc, var_sum_rtn_td_in, var_sum_rtn_td_out
                FROM t$worktable_summ
                WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = 'NULL'
                GROUP BY wk_spec, wk_care, wk_loc;

                ---- upd t$worktable_summ SPEC/CARE for 'ADD' record values ----
                --- i.e ICU/A/ADD's will count under ICU/A/ICU/ -----
                ---------------------------------------------------------------
                IF EXISTS (SELECT 1 FROM t$worktable_summ WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = var_loc) THEN
                    UPDATE t$worktable_summ SET
                        wk_org_prev_remain = wk_org_prev_remain + COALESCE(var_sum_org_prev_remain, 0),
                        wk_prev_remain = wk_prev_remain + COALESCE(var_sum_prev_remain, 0),
                        wk_ip_bed = wk_ip_bed + COALESCE(var_sum_ip_bed, 0),
                        wk_day_bed = wk_day_bed + COALESCE(var_sum_day_bed, 0),
                        wk_hn_adm = wk_hn_adm + COALESCE(var_sum_hn_adm, 0),
                        wk_ae_adm = wk_ae_adm + COALESCE(var_sum_ae_adm, 0),
                        wk_tx_in = wk_tx_in + COALESCE(var_sum_tx_in, 0),
                        wk_tx_out = wk_tx_out + COALESCE(var_sum_tx_out, 0),
                        wk_td_in = wk_td_in + COALESCE(var_sum_td_in, 0),
                        wk_td_out = wk_td_out + COALESCE(var_sum_td_out, 0),
                        wk_dsch = wk_dsch + COALESCE(var_sum_dsch, 0),
                        wk_deth = wk_deth + COALESCE(var_sum_deth, 0),
                        wk_day_dsch = wk_day_dsch + COALESCE(var_sum_day_dsch, 0),
                        wk_day_deth = wk_day_deth + COALESCE(var_sum_day_deth, 0),
                        wk_ae_day_dsch = wk_ae_day_dsch + COALESCE(var_sum_ae_day_dsch, 0),
                        wk_ae_day_deth = wk_ae_day_deth + COALESCE(var_sum_ae_day_deth, 0),
                        wk_remain = wk_remain + COALESCE(var_sum_remain, 0),
                        wk_bed_day_occ = wk_bed_day_occ + COALESCE(var_sum_bed_day_occ, 0),
                        wk_bed_day_vac = wk_bed_day_vac + COALESCE(var_sum_bed_day_vac, 0), -----
                        wk_bed_day_exc = wk_bed_day_exc + COALESCE(var_sum_bed_day_exc, 0), -----
                        wk_rtn_td_out = wk_rtn_td_out + COALESCE(var_sum_rtn_td_out, 0),
                        wk_rtn_td_in = wk_rtn_td_in + COALESCE(var_sum_rtn_td_in, 0)
                    WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = var_loc;

                ELSE
                    INSERT INTO t$worktable_summ VALUES (var_spec, var_care, var_loc, var_sum_org_prev_remain, var_sum_prev_remain, var_sum_ip_bed, var_sum_day_bed,
                        var_sum_hn_adm, var_sum_ae_adm, var_sum_tx_in, var_sum_tx_out,
                        var_sum_td_in, var_sum_td_out, var_sum_dsch, var_sum_deth,
                        var_sum_day_dsch, var_sum_day_deth, var_sum_ae_day_dsch, var_sum_ae_day_deth,
                        var_sum_remain, var_sum_bed_day_occ, var_sum_bed_day_vac, var_sum_bed_day_exc, var_sum_rtn_td_out, var_sum_rtn_td_in);
                       
                   	SELECT count(*) INTO var_temp_int_1 FROM t$worktable_summ WHERE wk_spec = 'RMDA';
					RAISE NOTICE 'count RMDA1908 => [%]',var_temp_int_1;
                END IF;

            END IF;  ----- if var_record_count >= 1 ---- found 'NULL' record for spec/spec/NULL

            DELETE FROM t$worktable_summ
            WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = 'NULL';

        END IF;  -----if var_loc <> 'NULL' and var_spec = var_loc

        --- (GYN/A/NULL and has GYN/A/ADD) or
        --- (ICU/A/ICU and has ICU/A/ADD)
        ---   ICU/A/ADD's will count under ICU/A/ICU/ -----
        ---   to delete 'ADD' from t$worktable_summ's wk_loc ---
        ---  ??? (ICU/H/ADD and ICU/U/ICU) how to handle for ICU/H/ADD ??---
        -----------------------------------------------------------
        var_record_count := 0;
        SELECT COUNT(*) INTO var_record_count FROM t$worktable_summ
        WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = 'ADD';

        IF var_record_count >= 1 THEN  ---- found 'ADD' record for spec/care/ADD
            SELECT SUM(COALESCE(wk_remain, 0)),
                   SUM(COALESCE(wk_prev_remain, 0)),
                   SUM(COALESCE(wk_org_prev_remain, 0)),
                   SUM(COALESCE(wk_ip_bed, 0)),
                   SUM(COALESCE(wk_day_bed, 0)),
                   SUM(COALESCE(wk_hn_adm, 0)),
                   SUM(COALESCE(wk_ae_adm, 0)),
                   SUM(COALESCE(wk_tx_in, 0)),
                   SUM(COALESCE(wk_tx_out, 0)),
                   SUM(COALESCE(wk_td_in, 0)),
                   SUM(COALESCE(wk_td_out, 0)),
                   SUM(COALESCE(wk_dsch, 0)),
                   SUM(COALESCE(wk_deth, 0)),
                   SUM(COALESCE(wk_ae_day_dsch, 0)),
                   SUM(COALESCE(wk_ae_day_deth, 0)),
                   SUM(COALESCE(wk_day_dsch, 0)),
                   SUM(COALESCE(wk_day_deth, 0)),
                   SUM(COALESCE(wk_bed_day_occ, 0)),
                   SUM(COALESCE(wk_bed_day_vac, 0)),
                   SUM(COALESCE(wk_bed_day_exc, 0)),
                   SUM(COALESCE(wk_rtn_td_in, 0)),
                   SUM(COALESCE(wk_rtn_td_out, 0))
            INTO var_sum_remain, var_sum_prev_remain, var_sum_org_prev_remain, var_sum_ip_bed, var_sum_day_bed, var_sum_hn_adm, var_sum_ae_adm, var_sum_tx_in, var_sum_tx_out, var_sum_td_in, var_sum_td_out, var_sum_dsch, var_sum_deth, var_sum_ae_day_dsch, var_sum_ae_day_deth, var_sum_day_dsch, var_sum_day_deth, var_sum_bed_day_occ, var_sum_bed_day_vac, var_sum_bed_day_exc, var_sum_rtn_td_in, var_sum_rtn_td_out
            FROM t$worktable_summ
            WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = 'ADD'
            GROUP BY wk_spec, wk_care, wk_loc;

            ---- upd t$worktable_summ SPEC/CARE for 'ADD' record values ----
            --- i.e ICU/A/ADD's will count under ICU/A/ICU/ -----
            ---------------------------------------------------------------
            IF EXISTS (SELECT 1 FROM t$worktable_summ WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = var_loc) THEN
                UPDATE t$worktable_summ SET
                    wk_org_prev_remain = wk_org_prev_remain + COALESCE(var_sum_org_prev_remain, 0),
                    wk_prev_remain = wk_prev_remain + COALESCE(var_sum_prev_remain, 0),
                    wk_ip_bed = wk_ip_bed + COALESCE(var_sum_ip_bed, 0),
                    wk_day_bed = wk_day_bed + COALESCE(var_sum_day_bed, 0),
                    wk_hn_adm = wk_hn_adm + COALESCE(var_sum_hn_adm, 0),
                    wk_ae_adm = wk_ae_adm + COALESCE(var_sum_ae_adm, 0),
                    wk_tx_in = wk_tx_in + COALESCE(var_sum_tx_in, 0),
                    wk_tx_out = wk_tx_out + COALESCE(var_sum_tx_out, 0),
                    wk_td_in = wk_td_in + COALESCE(var_sum_td_in, 0),
                    wk_td_out = wk_td_out + COALESCE(var_sum_td_out, 0),
                    wk_dsch = wk_dsch + COALESCE(var_sum_dsch, 0),
                    wk_deth = wk_deth + COALESCE(var_sum_deth, 0),
                    wk_day_dsch = wk_day_dsch + COALESCE(var_sum_day_dsch, 0),
                    wk_day_deth = wk_day_deth + COALESCE(var_sum_day_deth, 0),
                    wk_ae_day_dsch = wk_ae_day_dsch + COALESCE(var_sum_ae_day_dsch, 0),
                    wk_ae_day_deth = wk_ae_day_deth + COALESCE(var_sum_ae_day_deth, 0),
                    wk_remain = wk_remain + COALESCE(var_sum_remain, 0),
                    wk_bed_day_occ = wk_bed_day_occ + COALESCE(var_sum_bed_day_occ, 0),
                    wk_bed_day_vac = wk_bed_day_vac + COALESCE(var_sum_bed_day_vac, 0), ----- 
                    wk_bed_day_exc = wk_bed_day_exc + COALESCE(var_sum_bed_day_exc, 0), -----
                    wk_rtn_td_out = wk_rtn_td_out + COALESCE(var_sum_rtn_td_out, 0),
                    wk_rtn_td_in = wk_rtn_td_in + COALESCE(var_sum_rtn_td_in, 0)
                WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = var_loc;

            ELSE
                INSERT INTO t$worktable_summ VALUES (var_spec, var_care, var_loc, var_sum_org_prev_remain, var_sum_prev_remain, var_sum_ip_bed, var_sum_day_bed,
                    var_sum_hn_adm, var_sum_ae_adm, var_sum_tx_in, var_sum_tx_out,
                    var_sum_td_in, var_sum_td_out, var_sum_dsch, var_sum_deth,
                    var_sum_day_dsch, var_sum_day_deth, var_sum_ae_day_dsch, var_sum_ae_day_deth,
                    var_sum_remain, var_sum_bed_day_occ, var_sum_bed_day_vac, var_sum_bed_day_exc, var_sum_rtn_td_out, var_sum_rtn_td_in);
               	SELECT count(*) INTO var_temp_int_1 FROM t$worktable_summ WHERE wk_spec = 'RMDA';
   				RAISE NOTICE 'count RMDA1992 => [%]',var_temp_int_1;
            END IF;

            ---------------------------------------------------------------
            DELETE FROM t$worktable_summ
            WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = 'ADD';

            ---- update offset table for hospital total ---
            var_sum_temp_remain := 0 - var_sum_remain;
            var_sum_temp_prev_remain := 0 - var_sum_prev_remain;
            var_sum_temp_org_prev_remain := 0 - var_sum_org_prev_remain;
            var_sum_temp_ip_bed := 0 - var_sum_ip_bed;
            var_sum_temp_day_bed := 0 - var_sum_day_bed;
            var_sum_temp_hn_adm := 0 - var_sum_hn_adm;
            var_sum_temp_ae_adm := 0 - var_sum_ae_adm;
            var_sum_temp_tx_in := 0 - var_sum_tx_in;
            var_sum_temp_tx_out := 0 - var_sum_tx_out;
            var_sum_temp_td_in := 0 - var_sum_td_in;
            var_sum_temp_td_out := 0 - var_sum_td_out;
            var_sum_temp_dsch := 0 - var_sum_dsch;
            var_sum_temp_deth := 0 - var_sum_deth;
            var_sum_temp_ae_day_dsch := 0 - var_sum_ae_day_dsch;
            var_sum_temp_ae_day_deth := 0 - var_sum_ae_day_deth;
            var_sum_temp_day_dsch := 0 - var_sum_day_dsch;
            var_sum_temp_day_deth := 0 - var_sum_day_deth;
            var_sum_temp_bed_day_occ := 0 - var_sum_bed_day_occ;
            --var_sum_temp_bed_day_vac 	:= 0 - var_sum_bed_day_vac;
            --var_sum_temp_bed_day_exc	:= 0 - var_sum_bed_day_exc;
            var_sum_temp_rtn_td_in := 0 - var_sum_rtn_td_in;
            var_sum_temp_rtn_td_out := 0 - var_sum_rtn_td_out;

            IF var_sum_temp_remain <> 0 OR
               var_sum_temp_prev_remain <> 0 OR
               var_sum_temp_org_prev_remain <> 0 OR
               var_sum_temp_ip_bed <> 0 OR
               var_sum_temp_day_bed <> 0 OR
               var_sum_temp_hn_adm <> 0 OR
               var_sum_temp_ae_adm <> 0 OR
               var_sum_temp_tx_in <> 0 OR
               var_sum_temp_tx_out <> 0 OR
               var_sum_temp_td_in <> 0 OR
               var_sum_temp_td_out <> 0 OR
               var_sum_temp_dsch <> 0 OR
               var_sum_temp_deth <> 0 OR
               var_sum_temp_ae_day_dsch <> 0 OR
               var_sum_temp_ae_day_deth <> 0 OR
               var_sum_temp_day_dsch <> 0 OR
               var_sum_temp_day_deth <> 0 OR
               var_sum_temp_bed_day_occ <> 0 OR
               --var_sum_temp_bed_day_vac 	<> 0 or  ---- already upd offset values in daily_csr ---
               --var_sum_temp_bed_day_exc	<> 0 or
               var_sum_temp_rtn_td_in <> 0 OR
               var_sum_temp_rtn_td_out <> 0 THEN
                IF EXISTS (SELECT 1 FROM t$worktable_offset_summ WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = 'ADD') THEN
                    UPDATE t$worktable_offset_summ SET
                        wk_org_prev_remain = wk_org_prev_remain + COALESCE(var_sum_temp_org_prev_remain, 0),
                        wk_prev_remain = wk_prev_remain + COALESCE(var_sum_temp_prev_remain, 0),
                        wk_ip_bed = wk_ip_bed + COALESCE(var_sum_temp_ip_bed, 0),
                        wk_day_bed = wk_day_bed + COALESCE(var_sum_temp_day_bed, 0),
                        wk_hn_adm = wk_hn_adm + COALESCE(var_sum_temp_hn_adm, 0),
                        wk_ae_adm = wk_ae_adm + COALESCE(var_sum_temp_ae_adm, 0),
                        wk_tx_in = wk_tx_in + COALESCE(var_sum_temp_tx_in, 0),
                        wk_tx_out = wk_tx_out + COALESCE(var_sum_temp_tx_out, 0),
                        wk_td_in = wk_td_in + COALESCE(var_sum_temp_td_in, 0),
                        wk_td_out = wk_td_out + COALESCE(var_sum_temp_td_out, 0),
                        wk_dsch = wk_dsch + COALESCE(var_sum_temp_dsch, 0),
                        wk_deth = wk_deth + COALESCE(var_sum_temp_deth, 0),
                        wk_day_dsch = wk_day_dsch + COALESCE(var_sum_temp_day_dsch, 0),
                        wk_day_deth = wk_day_deth + COALESCE(var_sum_temp_day_deth, 0),
                        wk_ae_day_dsch = wk_ae_day_dsch + COALESCE(var_sum_temp_ae_day_dsch, 0),
                        wk_ae_day_deth = wk_ae_day_deth + COALESCE(var_sum_temp_ae_day_deth, 0),
                        wk_remain = wk_remain + COALESCE(var_sum_temp_remain, 0),
                        wk_bed_day_occ = wk_bed_day_occ + COALESCE(var_sum_temp_bed_day_occ, 0),
                        wk_rtn_td_out = wk_rtn_td_out + COALESCE(var_sum_temp_rtn_td_out, 0),
                        wk_rtn_td_in = wk_rtn_td_in + COALESCE(var_sum_temp_rtn_td_in, 0)
                    WHERE wk_spec = var_spec AND wk_care = var_care AND wk_loc = 'ADD';
                ELSE
                    INSERT INTO t$worktable_offset_summ VALUES (var_spec, var_care, 'ADD', var_sum_temp_org_prev_remain, var_sum_temp_prev_remain, var_sum_temp_ip_bed, var_sum_temp_day_bed,
                        var_sum_temp_hn_adm, var_sum_temp_ae_adm, var_sum_temp_tx_in, var_sum_temp_tx_out,
                        var_sum_temp_td_in, var_sum_temp_td_out, var_sum_temp_dsch, var_sum_temp_deth,
                        var_sum_temp_day_dsch, var_sum_temp_day_deth, var_sum_temp_ae_day_dsch, var_sum_temp_ae_day_deth,
                        var_sum_temp_remain, var_sum_temp_bed_day_occ, 0, 0, var_sum_temp_rtn_td_out, var_sum_temp_rtn_td_in);
                END IF;

            END IF;  --- end-of upd offset table -----
            -------------------------------------------------------------------------------------------
        END IF;  ----if var_record_count >= 1 ---- found 'ADD' record for spec/care/ADD

        --- re-init ---
        var_sum_temp_remain := 0;
        var_sum_temp_org_prev_remain := 0;
        var_sum_temp_ip_bed := 0;
        var_sum_temp_day_bed := 0;
        var_sum_temp_hn_adm := 0;
        var_sum_temp_ae_adm := 0;
        var_sum_temp_tx_in := 0;
        var_sum_temp_tx_out := 0;
        var_sum_temp_td_in := 0;
        var_sum_temp_td_out := 0;
        var_sum_temp_dsch := 0;
        var_sum_temp_deth := 0;
        var_sum_temp_ae_day_dsch := 0;
        var_sum_temp_ae_day_deth := 0;
        var_sum_temp_day_dsch := 0;
        var_sum_temp_day_deth := 0;
        var_sum_temp_bed_day_occ := 0;
        var_sum_temp_bed_day_vac := 0;
        var_sum_temp_bed_day_exc := 0;
        var_sum_temp_rtn_td_out := 0;
        var_sum_temp_rtn_td_in := 0;
        var_sum_temp_prev_remain := 0;
        var_record_count := 0;

        var_sum_remain := 0;
        var_sum_org_prev_remain := 0;
        var_sum_ip_bed := 0;
        var_sum_day_bed := 0;
        var_sum_hn_adm := 0;
        var_sum_ae_adm := 0;
        var_sum_tx_in := 0;
        var_sum_tx_out := 0;
        var_sum_td_in := 0;
        var_sum_td_out := 0;
        var_sum_dsch := 0;
        var_sum_deth := 0;
        var_sum_ae_day_dsch := 0;
        var_sum_ae_day_deth := 0;
        var_sum_day_dsch := 0;
        var_sum_day_deth := 0;
        var_sum_bed_day_occ := 0;
        var_sum_bed_day_vac := 0;
        var_sum_bed_day_exc := 0;
        var_sum_rtn_td_out := 0;
        var_sum_rtn_td_in := 0;
        var_sum_prev_remain := 0;
        var_record_count := 0;
        var_spec := NULL;
        var_care := NULL;
        var_loc := NULL;

        FETCH work_summ_loc_csr INTO var_spec, var_care, var_loc;
    END LOOP;
    CLOSE work_summ_loc_csr;
    --------------------------------------------------------------------

    DELETE FROM t$worktable_summ
    WHERE wk_hn_adm = 0
       AND wk_ae_adm = 0
       AND wk_tx_in = 0
       AND wk_tx_out = 0
       AND wk_dsch = 0
       AND wk_deth = 0
       AND wk_ae_day_dsch = 0
       AND wk_ae_day_deth = 0
       AND wk_day_dsch = 0
       AND wk_day_deth = 0
       AND wk_td_in = 0
       AND wk_td_out = 0
       AND wk_rtn_td_out = 0
       AND wk_rtn_td_in = 0
       AND wk_remain = 0
       AND wk_bed_day_occ = 0
       AND wk_bed_day_vac = 0
       AND wk_bed_day_exc = 0
       AND wk_ip_bed = 0
       AND wk_day_bed = 0
       AND wk_prev_remain = 0;

    IF var_test = 'YES' THEN
        RAISE NOTICE '---- after clean t$worktable_summ ---';
        SELECT * FROM t$worktable_summ ORDER BY wk_spec, wk_care;
        SELECT wk_spec, wk_care, wk_loc, wk_bed_day_occ, wk_bed_day_vac, wk_bed_day_exc FROM t$worktable_offset_summ ORDER BY wk_spec, wk_care;
    END IF;

    -------------------------------------------------------------------
    ---- create / format the dsptable for report for "SPECIALTY" level ----
    -------------------------------------------------------------------
    UPDATE t$worktable_summ
    SET wk_loc = NULL
    WHERE wk_loc = 'NULL';

    ---- init ----
    var_spec := NULL;
    var_care := NULL;
    var_loc := NULL;
    var_desc := NULL;
    var_insert_spec := NULL;
    var_org_prev_remain := 0;
    var_hn_adm := 0;
    var_ae_adm := 0;
    var_tx_in := 0;
    var_tx_out := 0;
    var_dsch := 0;
    var_deth := 0;
    var_day_dsch := 0;
    var_day_deth := 0;
    var_ae_day_deth := 0;
    var_ae_day_dsch := 0;
    var_td_in := 0;
    var_td_out := 0;
    var_rtn_td_in := 0;
    var_rtn_td_out := 0;
    var_remain := 0;
    var_bed_day_occ := 0;
    var_bed_day_vac := 0;
    var_bed_day_exc := 0;
    var_record_count := 0;
    var_upd_offset := 'N';
    var_sum_bed_day_vac := 0;
    var_sum_bed_day_exc := 0;
    var_sum_bed_day_occ := 0;
    var_sum_ip_bed := 0;
    var_care_count := 0;

    OPEN work_summ_csr;
    FETCH work_summ_csr INTO var_spec, var_care, var_loc, var_org_prev_remain, var_ip_bed, var_day_bed, var_hn_adm, var_ae_adm, var_tx_in, var_tx_out, var_td_in, var_td_out, var_dsch, var_deth, var_ae_day_dsch, var_ae_day_deth, var_day_dsch, var_day_deth, var_remain, var_bed_day_occ, var_bed_day_vac, var_bed_day_exc, var_rtn_td_out, var_rtn_td_in;
    WHILE (CASE WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 END) = 0  
    LOOP
	   			
        SELECT COUNT(*) INTO var_record_count FROM t$worktable_summ
        WHERE wk_spec = var_spec;
       
       	IF var_spec = 'RMDA' THEN
       		RAISE NOTICE 'RMDA-> var_record_count=>[%]',var_record_count;
       	END IF;
       	

        ---- For multi-care_type with same spec  => update offset table for bed_day_vac/exc  ---
        IF var_record_count > 1 THEN
            var_upd_offset := 'N';				---- no need upd offset AS offset values already done in daily_csr & dail_txn_csr
            ----var_upd_offset := 'Y';
        END IF;

        IF var_care_count = 0 THEN
            var_prev_care := var_care;
            var_prev_spec := var_spec;
        END IF;

        ---- spec code  changed --
        IF var_spec IS NOT NULL AND COALESCE(var_spec,'NULL') <> COALESCE(var_prev_spec,'NULL') THEN
            var_care_count := 0;
            var_prev_care := var_care;
            var_prev_spec := var_spec;
        END IF;

        var_care_count := var_care_count + 1;

        IF var_care = 'U' THEN var_desc := 'ICU';
        ELSIF var_care = 'H' THEN var_desc := 'HDU';
        ELSIF var_care = 'X' THEN var_desc := 'ICU IN NON-ICU';
        ELSIF var_care = 'Y' THEN var_desc := 'HDU IN NON-ICU';
        ELSIF var_care = 'A' THEN var_desc := 'ACUTE';
        ELSIF var_care = 'I' THEN var_desc := 'INFIMARY';
        --		else if var_care = 'R'	select var_desc = 'CONVALESCENCE/REHABILITATION'
        ELSIF var_care = 'R' THEN var_desc := 'CONV/REH';
        ELSIF var_care = 'M' THEN var_desc := 'MIXED';
        ELSE var_desc := var_care;
        END IF;

        IF var_care_count > 1 THEN
            var_insert_spec := NULL;		---- For same spec & diff Care, t$dsptable's spec set to null for display
        ELSE
            var_insert_spec := var_spec;
        END IF;

        /* insert for each spec&care type*/
        ---- print short-desc for var_spec if var_loc = 'NULL' ----
        --select var_spec_desc = null
        var_spec_desc := var_spec;     --- 050628: if desc is null => desc=var_spec
        var_insert_loc := var_loc;
        ---if var_loc = 'NULL'
        IF var_loc IS NULL THEN
            WITH ranked_specialty AS (
                SELECT Description,
                    ROW_NUMBER() OVER (
                        PARTITION BY Specialty_code 
                        ORDER BY Effective_date DESC
                    ) as rn
                FROM Specialty
                WHERE Specialty_code = var_spec
                AND Effective_date <= par_from_date
            )
            SELECT Description
            --INTO var_spec_desc
            INTO var_temp_1
            FROM ranked_specialty
            WHERE rn = 1;
           	IF FOUND THEN
           		var_spec_desc := var_temp_1;
           	END IF;

            IF var_care_count = 1 THEN
                var_insert_loc := var_spec_desc; 		---- print short-desc for var_spec if var_loc = 'NULL' ----
            END IF;
        END IF;
		
       	IF var_spec = 'RMDA' OR var_loc = 'RMDA' THEN
	    	RAISE NOTICE 'insert var_spec => [%] ,var_care => [%], var_loc => [%],var_bed_day_vac=>[%],var_bed_day_exc=>[%]',
       					var_insert_spec,var_care,var_insert_loc,var_bed_day_vac,var_bed_day_exc;
	    END IF;
        INSERT INTO t$dsptable VALUES (DEFAULT, var_insert_spec, var_care, var_insert_loc, var_desc, var_org_prev_remain,
                var_hn_adm, var_ae_adm, var_tx_in, var_tx_out,
                var_dsch, var_deth, var_ae_day_dsch, var_ae_day_deth, var_remain,
                var_bed_day_occ, var_bed_day_vac, var_ip_bed, var_bed_day_exc,
                0, var_day_dsch, var_day_deth, var_day_bed, var_td_out, var_rtn_td_out, var_rtn_td_in);

        --- upd offset table t$worktable_offset_summ for bed_day_vac/exc ----
        /*  offset values of bed_day_vac/exc already upd by daily_csr ----
        -------------------------------------------------------------
        */

        ---- if cursor end with multi-care spec ==> var_spec <> var_pre_spec condition will not encounter ---
        -------------------------------------------------------------
        IF var_care_count > 1 AND (var_care_count = var_record_count) THEN
            IF par_input_care_list IS NULL AND par_input_spec_list IS NULL THEN
                var_desc := 'SPECIALTY TOTAL';
            ELSE
                var_desc := 'SPECIALTY SUBTOTAL';
            END IF;

            var_sum_remain := 0;
            var_sum_org_prev_remain := 0;
            var_sum_ip_bed := 0;
            var_sum_day_bed := 0;
            var_sum_hn_adm := 0;
            var_sum_ae_adm := 0;
            var_sum_tx_in := 0;
            var_sum_tx_out := 0;
            var_sum_td_in := 0;
            var_sum_td_out := 0;
            var_sum_dsch := 0;
            var_sum_deth := 0;
            var_sum_ae_day_dsch := 0;
            var_sum_ae_day_deth := 0;
            var_sum_day_dsch := 0;
            var_sum_day_deth := 0;
            var_sum_bed_day_occ := 0;
            var_sum_bed_day_vac := 0;
            var_sum_bed_day_exc := 0;
            var_sum_rtn_td_out := 0;

            SELECT SUM(COALESCE(wk_remain, 0)),
                   SUM(COALESCE(wk_org_prev_remain, 0)),
                   SUM(COALESCE(wk_ip_bed, 0)),
                   SUM(COALESCE(wk_day_bed, 0)),
                   SUM(COALESCE(wk_hn_adm, 0)),
                   SUM(COALESCE(wk_ae_adm, 0)),
                   SUM(COALESCE(wk_tx_in, 0)),
                   SUM(COALESCE(wk_tx_out, 0)),
                   SUM(COALESCE(wk_td_in, 0)),
                   SUM(COALESCE(wk_td_out, 0)),
                   SUM(COALESCE(wk_dsch, 0)),
                   SUM(COALESCE(wk_deth, 0)),
                   SUM(COALESCE(wk_ae_day_dsch, 0)),
                   SUM(COALESCE(wk_ae_day_deth, 0)),
                   SUM(COALESCE(wk_day_dsch, 0)),
                   SUM(COALESCE(wk_day_deth, 0)),
                   SUM(COALESCE(wk_bed_day_occ, 0)),
                   SUM(COALESCE(wk_bed_day_vac, 0)),
                   SUM(COALESCE(wk_bed_day_exc, 0)),
                   SUM(COALESCE(wk_rtn_td_in, 0)),
                   SUM(COALESCE(wk_rtn_td_out, 0))
            INTO var_sum_remain, var_sum_org_prev_remain, var_sum_ip_bed, var_sum_day_bed, var_sum_hn_adm, var_sum_ae_adm, var_sum_tx_in, var_sum_tx_out, var_sum_td_in, var_sum_td_out, var_sum_dsch, var_sum_deth, var_sum_ae_day_dsch, var_sum_ae_day_deth, var_sum_day_dsch, var_sum_day_deth, var_sum_bed_day_occ, var_sum_bed_day_vac, var_sum_bed_day_exc, var_sum_rtn_td_in, var_sum_rtn_td_out
            FROM t$worktable_summ
            WHERE wk_spec = var_spec
            GROUP BY wk_spec;

            ---insert summ for the var_spec & null for bed_day_occ/vac/exc---
            INSERT INTO t$dsptable VALUES (DEFAULT, NULL, NULL, NULL, var_desc, var_sum_org_prev_remain,
                    var_sum_hn_adm, var_sum_ae_adm, var_sum_tx_in, var_sum_tx_out,
                    var_sum_dsch, var_sum_deth, var_sum_ae_day_dsch, var_sum_ae_day_deth, var_sum_remain,
                    var_sum_bed_day_occ, NULL, NULL, NULL,
                    ----var_sum_bed_day_occ,var_sum_bed_day_vac,var_sum_ip_bed,var_sum_bed_day_exc, ---050426 --
                    0, var_sum_day_dsch, var_sum_day_deth, var_sum_day_bed, var_sum_td_out, var_sum_rtn_td_out, var_sum_rtn_td_in);
    /*  offset values of bed_day_vac/exc already upd by daily_csr ----
    --------------------------------------------------
    */

            /* re-set for current changed var_spec  */
            var_care_count := 0;
            var_prev_care := var_care;
            var_prev_spec := var_spec;
        END IF; /* end of --- var_care_count >1 and (var_care_count =var_record_count) */

        -------------------------------------------------------------
        ---	end	---- END of - within same Same spec & diff Care type

        ---Re-init ---
        var_spec := NULL;
        var_care := NULL;
        var_loc := NULL;
        var_desc := NULL;
        var_insert_spec := NULL;
        var_org_prev_remain := 0;
        var_hn_adm := 0;
        var_ae_adm := 0;
        var_tx_in := 0;
        var_tx_out := 0;
        var_dsch := 0;
        var_deth := 0;
        var_day_dsch := 0;
        var_day_deth := 0;
        var_ae_day_deth := 0;
        var_ae_day_dsch := 0;
        var_td_in := 0;
        var_td_out := 0;
        var_rtn_td_in := 0;
        var_rtn_td_out := 0;
        var_remain := 0;
        var_bed_day_occ := 0;
        var_bed_day_vac := 0;
        var_bed_day_exc := 0;
        var_record_count := 0;
        var_upd_offset := 'N';
        var_sum_bed_day_vac := 0;
        var_sum_bed_day_exc := 0;
        var_sum_bed_day_occ := 0;
        var_sum_ip_bed := 0;

        FETCH work_summ_csr INTO var_spec, var_care, var_loc, var_org_prev_remain, var_ip_bed, var_day_bed, var_hn_adm, var_ae_adm, var_tx_in, var_tx_out, var_td_in, var_td_out, var_dsch, var_deth, var_ae_day_dsch, var_ae_day_deth, var_day_dsch, var_day_deth, var_remain, var_bed_day_occ, var_bed_day_vac, var_bed_day_exc, var_rtn_td_out, var_rtn_td_in;

    END LOOP;
    CLOSE work_summ_csr;
    -------------------------------------------------------------------
    ---- END of create / format the dsptable for report for "SPECIALTY" level ----
    -------------------------------------------------------------------

    IF var_test = 'YES' THEN
        RAISE NOTICE '----after format spec # ---';
        SELECT * FROM t$worktable_summ ORDER BY wk_spec, wk_care;
        SELECT * FROM t$dsptable;
    END IF;

    ---update t$worktable_summ by offset table t$worktable_offset_summ for Total Calc ----
    -------------------------------------------
    UPDATE t$worktable_offset_summ
    SET wk_bed_day_vac = 0,
        wk_bed_day_exc = 0
    WHERE wk_loc = 'ADD';

    INSERT INTO t$worktable_summ
    SELECT * FROM t$worktable_offset_summ
    WHERE wk_loc = 'ADD';
   
   	SELECT count(*) INTO var_temp_int_1 FROM t$worktable_summ WHERE wk_spec = 'RMDA';
   	RAISE NOTICE 'count RMDA2437 => [%]',var_temp_int_1;
    -------------------------------------------

    IF var_test = 'YES' THEN
        RAISE NOTICE '----**** before format Hospital# *** ---';
        SELECT * FROM t$worktable_summ ORDER BY wk_spec, wk_care;
        SELECT * FROM t$worktable_offset_summ ORDER BY wk_spec, wk_care;
    END IF;

    ---- Calc Hospital total -----
    IF par_input_care_list IS NULL AND par_input_spec_list IS NULL THEN
        var_desc := 'HOSPITAL TOTAL';
    ELSE
        var_desc := 'HOSPITAL SUBTOTAL';
    END IF;

    SELECT SUM(COALESCE(wk_ip_bed, 0)),
           SUM(COALESCE(wk_day_bed, 0)),
           SUM(COALESCE(wk_hn_adm, 0)),
           SUM(COALESCE(wk_ae_adm, 0)),
           SUM(COALESCE(wk_tx_in, 0)),
           SUM(COALESCE(wk_tx_out, 0)),
           SUM(COALESCE(wk_td_in, 0)),
           SUM(COALESCE(wk_td_out, 0)),
           SUM(COALESCE(wk_dsch, 0)),
           SUM(COALESCE(wk_deth, 0)),
           SUM(COALESCE(wk_ae_day_dsch, 0)),
           SUM(COALESCE(wk_ae_day_deth, 0)),
           SUM(COALESCE(wk_day_dsch, 0)),
           SUM(COALESCE(wk_day_deth, 0)),
           SUM(COALESCE(wk_remain, 0)),
           SUM(COALESCE(wk_org_prev_remain, 0)),
           SUM(COALESCE(wk_bed_day_occ, 0)),
           SUM(COALESCE(wk_bed_day_vac, 0)),
           SUM(COALESCE(wk_bed_day_exc, 0)),
           SUM(COALESCE(wk_rtn_td_in, 0)),
           SUM(COALESCE(wk_rtn_td_out, 0))
    INTO var_sum_ip_bed, var_sum_day_bed, var_sum_hn_adm, var_sum_ae_adm, var_sum_tx_in, var_sum_tx_out, var_sum_td_in, var_sum_td_out, var_sum_dsch, var_sum_deth, var_sum_ae_day_dsch, var_sum_ae_day_deth, var_sum_day_dsch, var_sum_day_deth, var_sum_remain, var_sum_org_prev_remain, var_sum_bed_day_occ, var_sum_bed_day_vac, var_sum_bed_day_exc, var_sum_rtn_td_in, var_sum_rtn_td_out
    FROM t$worktable_summ
    WHERE COALESCE(wk_spec,'NULL') <> 'HOME';

    INSERT INTO t$dsptable VALUES (DEFAULT, NULL, NULL, NULL, var_desc, var_sum_org_prev_remain,
            var_sum_hn_adm, var_sum_ae_adm, var_sum_tx_in, var_sum_tx_out,
            var_sum_dsch, var_sum_deth, var_sum_ae_day_dsch, var_sum_ae_day_deth, var_sum_remain,
            var_sum_bed_day_occ, var_sum_bed_day_vac, var_sum_ip_bed, var_sum_bed_day_exc,
            0, var_sum_day_dsch, var_sum_day_deth, var_sum_day_bed, var_sum_td_out, var_sum_rtn_td_out, var_sum_rtn_td_in);

    ---- Calc 'HOME' total -----
    IF EXISTS (SELECT 1 FROM t$worktable_summ WHERE wk_spec = 'HOME') THEN
        SELECT SUM(COALESCE(wk_ip_bed, 0)),
               SUM(COALESCE(wk_day_bed, 0)),
               SUM(COALESCE(wk_hn_adm, 0)),
               SUM(COALESCE(wk_ae_adm, 0)),
               SUM(COALESCE(wk_tx_in, 0)),
               SUM(COALESCE(wk_tx_out, 0)),
               SUM(COALESCE(wk_td_in, 0)),
               SUM(COALESCE(wk_td_out, 0)),
               SUM(COALESCE(wk_dsch, 0)),
               SUM(COALESCE(wk_deth, 0)),
               SUM(COALESCE(wk_ae_day_dsch, 0)),
               SUM(COALESCE(wk_ae_day_deth, 0)),
               SUM(COALESCE(wk_day_dsch, 0)),
               SUM(COALESCE(wk_day_deth, 0)),
               SUM(COALESCE(wk_remain, 0)),
               SUM(COALESCE(wk_org_prev_remain, 0)),
               SUM(COALESCE(wk_bed_day_occ, 0)),
               SUM(COALESCE(wk_bed_day_vac, 0)),
               SUM(COALESCE(wk_bed_day_exc, 0)),
               SUM(COALESCE(wk_rtn_td_in, 0)),
               SUM(COALESCE(wk_rtn_td_out, 0))
        INTO var_sum_ip_bed, var_sum_day_bed, var_sum_hn_adm, var_sum_ae_adm, var_sum_tx_in, var_sum_tx_out, var_sum_td_in, var_sum_td_out, var_sum_dsch, var_sum_deth, var_sum_ae_day_dsch, var_sum_ae_day_deth, var_sum_day_dsch, var_sum_day_deth, var_sum_remain, var_sum_org_prev_remain, var_sum_bed_day_occ, var_sum_bed_day_vac, var_sum_bed_day_exc, var_sum_rtn_td_in, var_sum_rtn_td_out
        FROM t$worktable_summ
        WHERE wk_spec = 'HOME';

        INSERT INTO t$dsptable VALUES (DEFAULT, 'HOME', NULL, NULL, 'HOME', var_sum_org_prev_remain,
                var_sum_hn_adm, var_sum_ae_adm, var_sum_tx_in, var_sum_tx_out,
                var_sum_dsch, var_sum_deth, var_sum_ae_day_dsch, var_sum_ae_day_deth, var_sum_remain,
                var_sum_bed_day_occ, var_sum_bed_day_vac, var_sum_ip_bed, var_sum_bed_day_exc,
                --0,var_sum_day_dsch,var_sum_day_deth,var_sum_day_bed,var_sum_td_out,var_sum_rtn_td_out,var_sum_rtn_td_in)
                0, var_sum_day_dsch, var_sum_day_deth, var_sum_day_bed, var_sum_rtn_td_in, var_sum_td_in, var_sum_rtn_td_out);

    END IF;

    ---- Calc Care Category total -----

    INSERT INTO t$dsptable
    ---select null,wk_care,null,'UNDEFINED',sum(wk_org_prev_remain),
    SELECT nextval(pg_get_serial_sequence('t$dsptable','id')),'TOTAL', wk_care, NULL, 'UNDEFINED', SUM(wk_org_prev_remain),
        SUM(wk_hn_adm), SUM(wk_ae_adm), SUM(wk_tx_in), SUM(wk_tx_out),
        SUM(wk_dsch), SUM(wk_deth), SUM(wk_ae_day_dsch), SUM(wk_ae_day_deth), SUM(wk_remain),
        SUM(wk_bed_day_occ), SUM(wk_bed_day_vac), SUM(wk_ip_bed), SUM(wk_bed_day_exc),
        0, SUM(wk_day_dsch), SUM(wk_day_deth), SUM(wk_day_bed), SUM(wk_td_out), SUM(wk_rtn_td_out), SUM(wk_rtn_td_in)
    FROM t$worktable_summ
    WHERE COALESCE(wk_spec,'NULL') <> 'HOME'
    GROUP BY wk_care;				---  by the Negative values of 'ADD' records

    UPDATE t$dsptable SET dp_desc = 'ICU' WHERE dp_desc = 'UNDEFINED' AND dp_care = 'U';
    UPDATE t$dsptable SET dp_desc = 'HDU' WHERE dp_desc = 'UNDEFINED' AND dp_care = 'H';
    UPDATE t$dsptable SET dp_desc = 'ICU IN NON-ICU' WHERE dp_desc = 'UNDEFINED' AND dp_care = 'X';
    UPDATE t$dsptable SET dp_desc = 'HDU IN NON-ICU' WHERE dp_desc = 'UNDEFINED' AND dp_care = 'Y';
    UPDATE t$dsptable SET dp_desc = 'ACUTE' WHERE dp_desc = 'UNDEFINED' AND dp_care = 'A';
    UPDATE t$dsptable SET dp_desc = 'INFIMARY' WHERE dp_desc = 'UNDEFINED' AND dp_care = 'I';
    UPDATE t$dsptable SET dp_desc = 'CONV/REH' WHERE dp_desc = 'UNDEFINED' AND dp_care = 'R';
    UPDATE t$dsptable SET dp_desc = 'MIXED' WHERE dp_desc = 'UNDEFINED' AND dp_care = 'M';

    var_spec := NULL;
    var_care := NULL;
    var_desc := NULL;

    --- for occ_rate = bdo / ip_bed * 100 % -- PBL set 100%
    UPDATE t$dsptable SET
    dp_occ_rate = (dp_bed_day_occ * 1.0 / dp_ip_bed)  ----* 1.0 to format real type
    ----dp_occ_rate = ((dp_remain + dp_ae_day_dsch + dp_ae_day_deth ) * 1.0 / dp_ip_bed)
    WHERE dp_ip_bed <> 0
        AND dp_ip_bed IS NOT NULL;

    IF var_show_prev_remain = 'NO' THEN
        UPDATE t$dsptable SET dp_prev_remain = NULL;		---- 'N/A' show in report
    END IF;

    open p_refcur for
    SELECT dp_spec, dp_desc, dp_loc, dp_prev_remain, dp_hn_adm, dp_ae_adm, dp_tx_in, dp_tx_out, dp_rtn_td_out, dp_td_out,
           dp_dsch, dp_deth, dp_ae_day_dsch, dp_ae_day_deth, dp_remain,
           dp_bed_day_occ, dp_bed_day_vac, dp_ip_bed, dp_bed_day_exc, dp_occ_rate, dp_day_bed, dp_day_dsch, dp_day_deth
    FROM t$dsptable
    ORDER BY id;
   	return next p_refcur;
    /*
    where dp_hn_adm <> 0
       or dp_ae_adm <> 0
       or dp_tx_in <> 0
       or dp_tx_out <> 0
       or dp_dsch <> 0
       or dp_deth <> 0
       or dp_ae_day_dsch <> 0
       or dp_ae_day_deth <> 0
        or dp_prev_remain <> 0
       or dp_remain <> 0
       or dp_bed_day_occ <> 0
       or dp_bed_day_vac <> 0
       or dp_ip_bed <> 0
       or dp_bed_day_exc <> 0
       or dp_occ_rate <> 0
       or dp_day_dsch <> 0
       or dp_day_deth <> 0
       or dp_day_bed <> 0
        or dp_td_out  <> 0
        or dp_rtn_td_out <> 0
        or dp_prev_remain <>0
    */	
END;
$function$
;

;ALTER FUNCTION "hasp_get_spec_care_stat_report" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
