-- DROP PROCEDURE hpi.hasp_get_ward_stat_cte(inout int4, in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_ward_stat_cte(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, IN par_input_ward character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_days REAL;
    var_prev_date timestamp without time zone;

BEGIN

    SELECT DATE_PART('days', par_input_to_date::timestamp::date::timestamp
        - par_input_from_date::timestamp::date::timestamp) + 1
      INTO var_days;
   
   select par_input_from_date::timestamp::date::timestamp - interval '1 day' 
     into var_prev_date;

OPEN p_refcur FOR
    -- 日期范围内的日期记录集
    WITH date_range AS (
        SELECT * FROM generate_series(par_input_from_date::timestamp,
        par_input_to_date::timestamp, '1 day'::interval) AS tx_date)
    -- 病区列表
    , ward_list AS (
        SELECT DISTINCT Ward_code
        FROM Ward
        WHERE Ward_code LIKE par_input_ward
          AND Ward_code <> 'AE01'
          AND Hospital_code = par_hosp_code
    )
    -- 病区定义信息
    , ward_desc AS (
        SELECT w.Ward_code, w.Description AS ward_desc
        FROM Ward w, ward_list l
        WHERE w.ward_code = l.ward_code
          AND w.Hospital_code = par_hosp_code
          AND w.Effective_date = (
                SELECT MAX(w2.Effective_date)
                FROM Ward w2
                WHERE w2.Ward_code = w.Ward_code
                    AND w2.Effective_date <= par_input_to_date
                    AND w2.Hospital_code = par_hosp_code)
    )
    -- 病区和专业的唯一组合
    , ward_and_specialty AS (
        SELECT DISTINCT w.Ward_code, s.Specialty_code
        FROM Ward w,Ward_specialty s
        WHERE w.Ward_code LIKE par_input_ward
          AND w.Ward_code <> 'AE01'
          AND w.Hospital_code = par_hosp_code
          AND s.Hospital_code = w.Hospital_code
          AND s.Ward_code = w.Ward_code
          AND s.Specialty_code <> 'A&E'
    )
    -- 病区和专业的唯一组合，取某日的最大有效日期
    , ward_spec_max_effective AS (
        SELECT distinct r.tx_date,w.Ward_code, s.Specialty_code,
               MAX(s.Effective_date) AS max_effective_date
        FROM Ward_and_specialty w, Ward_specialty s,date_range r
        WHERE w.Ward_code = s.Ward_code
          AND w.Specialty_code = s.Specialty_code
          AND s.Hospital_code = par_hosp_code
          AND s.Effective_date <= r.tx_date
     group by r.tx_date,w.ward_code,s.specialty_code
    )
    -- 统计一天中不同病区的官方床和日间床
    , beds_of_day_and_ward AS (
        SELECT m.tx_date,s.ward_code,
               COALESCE(SUM(s.Official_bed), 0) AS var_ttl_ip_bed,
               COALESCE(SUM(s.Day_bed), 0) AS var_ttl_dp_bed
        FROM Ward_specialty s, ward_spec_max_effective m
        WHERE m.Ward_code = s.Ward_code
          AND m.Specialty_code = s.Specialty_code
          AND s.Effective_date = m.max_effective_date
          AND s.Hospital_code = par_hosp_code
        GROUP BY m.tx_date,s.ward_code
    )
    , ward_first_date AS (
        SELECT var_prev_date AS tx_date,
               b.Ward_code AS ward_code,
           (SUM(COALESCE(b.Previous_remaining, 0)) +
            SUM(COALESCE(b.Admission, 0))
                + SUM(COALESCE(b.Transfer_in, 0)) + SUM(COALESCE(b.Transfer_in_from_TD, 0))
                - SUM(COALESCE(b.Transfer_out, 0)) - SUM(COALESCE(b.Transfer_out_to_TD, 0))
                - SUM(COALESCE(b.Discharge, 0)) - SUM(COALESCE(b.Death, 0))
                - SUM(COALESCE(b.Canc_admission, 0))
                - SUM(COALESCE(b.Canc_transfer_in, 0)) - SUM(COALESCE(b.Canc_transfer_in_from_TD, 0))
               + SUM(COALESCE(b.Canc_transfer_out, 0)) + SUM(COALESCE(b.Canc_transfer_out_to_TD, 0))
               + SUM(COALESCE(b.Canc_discharge, 0)) + SUM(COALESCE(b.Canc_death, 0)))::integer AS var_prev_remain,
        0::integer AS var_sub_remain,
        0::integer AS var_bdo,
            0 AS var_adm, 0 AS var_txin, 0 AS var_txout, 0 AS var_td_txin, 0 AS var_td_txout,
            0 AS var_dsch, 0 AS var_deth, 0 AS var_ae_day_dsch, 0 AS var_ae_day_deth,
            0 AS var_ae_adm, 0 AS var_day_dsch, 0 AS var_day_deth,
            0 AS var_tx_within_ward,
            0 AS var_canc_adm, 0 AS var_canc_txin, 0 AS var_canc_txout,
            0 AS var_canc_td_txin, 0 AS var_canc_td_txout,
            0 AS var_canc_dsch, 0 AS var_canc_deth,
            0 AS var_canc_ae_day_dsch, 0 AS var_canc_ae_day_deth,
            0 AS var_canc_ae_adm, 0 AS var_canc_day_dsch, 0 AS var_canc_day_deth,
            0 AS var_canc_tx_within_ward
        FROM Ward_spec_tx_adj_view b,
          (SELECT MAX(Ward_spec_tx_date) AS tx_date,
                     Ward_code AS ward_code,
                     Specialty_code AS spec_code,
                     Treatment_location AS treat_loc
              FROM Ward_spec_tx
             WHERE Ward_spec_tx_date < par_input_from_date
               AND Hospital_code = par_hosp_code::VARCHAR
           GROUP BY ward_code, specialty_code, treatment_location) AS a
        WHERE  a.tx_date = b.Ward_spec_tx_date
          AND a.Ward_code = b.Ward_code
          AND a.spec_code = b.specialty_code
          AND b.Hospital_code = par_hosp_code
          AND COALESCE(a.treat_loc, 'null') = COALESCE(b.treatment_location, 'null')
        GROUP BY b.Ward_code
        ORDER BY b.Ward_code NULLS FIRST
    )
    -- 检查ward_list的ward_code是否存在与ward_first_date, 如果不存在则补充到ward_first_date数据集中国
    , ward_first_date1 as (
      select * from (
        (select * from ward_first_date)
        union all
        (select  var_prev_date::timestamp AS tx_date,
            a.Ward_code AS ward_code,
            0::integer AS var_prev_remain,
            0::integer AS var_sub_remain,
            0::integer AS var_bdo,
            0 AS var_adm, 0 AS var_txin, 0 AS var_txout, 0 AS var_td_txin, 0 AS var_td_txout,
            0 AS var_dsch, 0 AS var_deth, 0 AS var_ae_day_dsch, 0 AS var_ae_day_deth,
            0 AS var_ae_adm, 0 AS var_day_dsch, 0 AS var_day_deth,
            0 AS var_tx_within_ward,
            0 AS var_canc_adm, 0 AS var_canc_txin, 0 AS var_canc_txout,
            0 AS var_canc_td_txin, 0 AS var_canc_td_txout,
            0 AS var_canc_dsch, 0 AS var_canc_deth,
            0 AS var_canc_ae_day_dsch, 0 AS var_canc_ae_day_deth,
            0 AS var_canc_ae_adm, 0 AS var_canc_day_dsch, 0 AS var_canc_day_deth,
            0 AS var_canc_tx_within_ward
         from ward_list a left join ward_first_date b on a.ward_code = b.ward_code
         where b.ward_code is null)
      ) t1
    )
    -- date_range d, ward_list wl
    , date_join_ward AS (
        SELECT d.tx_date,wl.ward_code FROM date_range d, ward_list wl
    )
    --根据ward和日期范围，计算每个病区每天的统计数据
    , sum_of_day_and_ward AS (
      SELECT * FROM (
         (SELECT * FROM ward_first_date1)
        UNION ALL
          (SELECT
            wl.tx_date as tx_date,
            wl.ward_code as ward_code,
            0::integer AS var_prev_remain,
            SUM(COALESCE(t.Admission, 0))
            + SUM(COALESCE(t.Transfer_in, 0)) + SUM(COALESCE(t.Transfer_in_from_TD, 0))
            - SUM(COALESCE(t.Transfer_out, 0)) - SUM(COALESCE(t.Transfer_out_to_TD, 0))
            - SUM(COALESCE(t.Discharge, 0)) - SUM(COALESCE(t.Death, 0))
            - SUM(COALESCE(t.Canc_admission, 0))
            - SUM(COALESCE(t.Canc_transfer_in, 0)) - SUM(COALESCE(t.Canc_transfer_in_from_TD, 0))
            + SUM(COALESCE(t.Canc_transfer_out, 0)) + SUM(COALESCE(t.Canc_transfer_out_to_TD, 0))
            + SUM(COALESCE(t.Canc_discharge, 0)) + SUM(COALESCE(t.Canc_death, 0))
                AS var_sub_remain,
            SUM(COALESCE(t.AE_day_discharge, 0)) + SUM(COALESCE(t.AE_day_death, 0))
            - SUM(COALESCE(t.Canc_AE_day_discharge, 0)) - SUM(COALESCE(t.Canc_AE_day_death, 0))
               AS var_bdo,
            SUM(COALESCE(t.Admission, 0)) as var_adm,
               SUM(COALESCE(t.Transfer_in, 0)) as var_txin,
                SUM(COALESCE(t.Transfer_out, 0)) as var_txout,
                SUM(COALESCE(t.Transfer_in_from_TD, 0)) as var_td_txin,
                SUM(COALESCE(t.Transfer_out_to_TD, 0)) as var_td_txout,
                SUM(COALESCE(t.Discharge, 0)) as var_dsch,
                SUM(COALESCE(t.Death, 0)) as var_deth,
                SUM(COALESCE(t.AE_day_discharge, 0)) as var_ae_day_dsch,
                SUM(COALESCE(t.AE_day_death, 0)) as var_ae_day_deth,
                SUM(COALESCE(t.Admission_thru_AE, 0)) as var_ae_adm,
                SUM(COALESCE(t.Day_discharge, 0)) as var_day_dsch,
                SUM(COALESCE(t.Day_death, 0)) as var_day_deth,
                SUM(COALESCE(t.Transfer_within_ward, 0)) as var_tx_within_ward,
                SUM(COALESCE(t.Canc_admission, 0)) as var_canc_adm,
                SUM(COALESCE(t.Canc_transfer_in, 0)) as var_canc_txin,
                SUM(COALESCE(t.Canc_transfer_out, 0)) as var_canc_txout,
                SUM(COALESCE(t.Canc_transfer_in_from_TD, 0)) as var_canc_td_txin,
                SUM(COALESCE(t.Canc_transfer_out_to_TD, 0)) as var_canc_td_txout,
                SUM(COALESCE(t.Canc_discharge, 0)) as var_canc_dsch,
                SUM(COALESCE(t.Canc_death, 0)) as var_canc_deth,
                SUM(COALESCE(t.Canc_AE_day_discharge, 0)) as var_canc_ae_day_dsch,
                SUM(COALESCE(t.Canc_AE_day_death, 0)) as var_canc_ae_day_deth,
                SUM(COALESCE(t.Canc_admission_thru_AE, 0)) as var_canc_ae_adm,
                SUM(COALESCE(t.Canc_day_discharge, 0)) as var_canc_day_dsch,
                SUM(COALESCE(t.Canc_day_death, 0)) as var_canc_day_deth,
                SUM(COALESCE(t.Canc_transfer_within_ward, 0)) as var_canc_tx_within_ward
            FROM date_join_ward wl left join Ward_spec_tx_adj_view t ON
                 t.ward_code = wl.ward_code 
             AND t.ward_spec_tx_date = wl.tx_date
             and t.Hospital_code = par_hosp_code
            GROUP BY wl.Ward_code, wl.tx_date)
        ) AS ws
    )
    -- 统计病房的汇总信息
    , ward_sum_join_beds AS (
        SELECT ward_code,
                sum(var_prev_remain) as var_prev_remain,
                sum(var_sub_remain) AS stat_remain,
                sum(_var_vac) AS stat_vac,
                sum(_var_exc) AS stat_exc,
                sum(var_bdo) AS stat_bdo,
                sum(var_adm) AS stat_adm,
                sum(var_canc_adm) AS stat_canc_adm,
                sum(var_txin) AS stat_txin,
                sum(var_canc_txin) AS stat_canc_txin,
                sum(var_txout) AS stat_txout,
                sum(var_canc_txout) AS stat_canc_txout,
                sum(var_td_txin) AS stat_td_txin,
                sum(var_canc_td_txin) AS stat_canc_td_txin,
                sum(var_td_txout) AS stat_td_txout,
                sum(var_canc_td_txout) AS stat_canc_td_txout,
                sum(var_dsch) AS stat_dsch,
                sum(var_canc_dsch) AS stat_canc_dsch,
                sum(var_deth) AS stat_deth,
                sum(var_canc_deth) AS stat_canc_deth,
                sum(var_ae_day_dsch) AS stat_ae_day_dsch,
                sum(var_canc_ae_day_dsch) AS stat_canc_ae_day_dsch,
                sum(var_ae_day_deth) AS stat_ae_day_deth,
                sum(var_canc_ae_day_deth) AS stat_canc_ae_day_deth,
                sum(var_ae_adm) AS stat_ae_adm,
                sum(var_day_dsch) AS stat_day_dsch,
                sum(var_canc_day_dsch) AS stat_canc_day_dsch,
                sum(var_day_deth) AS stat_day_deth,
                sum(var_canc_day_deth) AS stat_canc_day_deth,
                sum(var_tx_within_ward) AS stat_tx_within_ward,
                sum(var_canc_tx_within_ward) AS stat_canc_tx_within_ward,
                sum(var_ttl_ip_bed) AS stat_ip_bed,
                sum(var_ttl_dp_bed) AS stat_dp_bed
        FROM (
            select *,
               (case when var_days > 1 and _rn = 1 then __var_prev_remain else _var_prev_remain end) as var_prev_remain,
               (case when _rnasc = 1 then 0 else _var_ttl_remain end) as var_sub_remain,
               (case when _rnasc = 1 then 0 else _var_ttl_bdo end) as var_bdo,
               (case when _rnasc = 1 then 0 else var_vac end) as _var_vac,
               (case when _rnasc = 1 then 0 else var_exc end) as _var_exc
            from (
	            SELECT *,
	                (case WHEN _rnasc = 1 then 0 WHEN _var_ttl_bdo > var_ttl_ip_bed THEN 0
	                      ELSE var_ttl_ip_bed - _var_ttl_bdo END) AS var_vac,
	                (CASE WHEN _rnasc = 1 then 0 WHEN _var_ttl_bdo > var_ttl_ip_bed THEN
	                    _var_ttl_bdo - var_ttl_ip_bed ELSE 0 END) AS var_exc,
	                (_var_ttl_remain - _var_sub_remain) as __var_prev_remain
	            FROM (
	                SELECT *,
                    (case when _rnasc = 1 then 0 ELSE _var_ttl_remain + _var_bdo end) as _var_ttl_bdo
	                FROM (
	                    SELECT
	                        s.tx_date,
	                        s.ward_code,
                    (sum(COALESCE(s.var_prev_remain, 0) + COALESCE(s.var_sub_remain, 0)) OVER (PARTITION BY s.ward_code ORDER BY s.tx_date)) AS _var_ttl_remain,
                    row_number() OVER (PARTITION BY s.ward_code ORDER BY s.tx_date DESC) AS _rn,
                    row_number() over (partition by s.ward_code order by s.tx_date) as _rnasc,
	                        COALESCE(s.var_prev_remain, 0) AS _var_prev_remain,
	                        COALESCE(s.var_sub_remain, 0) AS _var_sub_remain,
	                        COALESCE(s.var_bdo, 0) AS _var_bdo,
	                        COALESCE(s.var_adm, 0) AS var_adm,
	                        COALESCE(s.var_canc_adm, 0) AS var_canc_adm,
	                        COALESCE(s.var_txin, 0) AS var_txin,
	                        COALESCE(s.var_canc_txin, 0) AS var_canc_txin,
	                        COALESCE(s.var_txout, 0) AS var_txout,
	                        COALESCE(s.var_canc_txout, 0) AS var_canc_txout,
	                        COALESCE(s.var_td_txin, 0) AS var_td_txin,
	                        COALESCE(s.var_canc_td_txin, 0) AS var_canc_td_txin,
	                        COALESCE(s.var_td_txout, 0) AS var_td_txout,
	                        COALESCE(s.var_canc_td_txout, 0) AS var_canc_td_txout,
	                        COALESCE(s.var_dsch, 0) AS var_dsch,
	                        COALESCE(s.var_canc_dsch, 0) AS var_canc_dsch,
	                        COALESCE(s.var_deth, 0) AS var_deth,
	                        COALESCE(s.var_canc_deth, 0) AS var_canc_deth,
	                        COALESCE(s.var_ae_day_dsch, 0) AS var_ae_day_dsch,
	                        COALESCE(s.var_canc_ae_day_dsch, 0) AS var_canc_ae_day_dsch,
	                        COALESCE(s.var_ae_day_deth, 0) AS var_ae_day_deth,
	                        COALESCE(s.var_canc_ae_day_deth, 0) AS var_canc_ae_day_deth,
	                        COALESCE(s.var_ae_adm, 0) AS var_ae_adm,
	                        COALESCE(s.var_day_dsch, 0) AS var_day_dsch,
	                        COALESCE(s.var_canc_day_dsch, 0) AS var_canc_day_dsch,
	                        COALESCE(s.var_day_deth, 0) AS var_day_deth,
	                        COALESCE(s.var_canc_day_deth, 0) AS var_canc_day_deth,
	                        COALESCE(s.var_tx_within_ward, 0) AS var_tx_within_ward,
	                        COALESCE(s.var_canc_tx_within_ward, 0) AS var_canc_tx_within_ward,
	                        COALESCE(b.var_ttl_ip_bed, 0) AS var_ttl_ip_bed,
	                        COALESCE(b.var_ttl_dp_bed, 0) AS var_ttl_dp_bed
	                    FROM sum_of_day_and_ward s LEFT JOIN beds_of_day_and_ward b ON
	                        s.tx_date = b.tx_date AND s.ward_code = b.ward_code
	                ) a
	            ) c
	        ) d
        ) e
        GROUP BY ward_code
    )
    -- /* add hospital code for hpi by ML on 26.07.1999 */ 开始处理
    , ward_stat AS (
    select *,
            (CASE WHEN ward_code <> 'HOME' AND stat_inpat_treated <> 0 THEN
              stat_bdo / stat_inpat_treated ELSE NULL END)::REAL AS stat_los,
             (CASE WHEN ward_code <> 'HOME' AND stat_ip_bed <> 0 THEN
              stat_inpat_treated * var_days / stat_ip_bed ELSE NULL END)::REAL AS stat_turnover
    from (
        SELECT
            s.ward_code,
            d.ward_desc,
            CASE WHEN var_days > 1 THEN NULL ELSE var_prev_remain END AS stat_prev_remain,
            s.stat_remain,
            s.stat_vac, s.stat_exc, s.stat_bdo,
            s.stat_adm,            s.stat_canc_adm,
            s.stat_txin,           s.stat_canc_txin,
            s.stat_txout,          s.stat_canc_txout,
            s.stat_td_txin,        s.stat_canc_td_txin,
            s.stat_td_txout,       s.stat_canc_td_txout,
            s.stat_dsch,           s.stat_canc_dsch,
            s.stat_deth,           s.stat_canc_deth,
            s.stat_ae_day_dsch,    s.stat_canc_ae_day_dsch,
            s.stat_ae_day_deth,    s.stat_canc_ae_day_deth,
            s.stat_day_dsch,       s.stat_canc_day_dsch,
            s.stat_day_deth,       s.stat_canc_day_deth,
            s.stat_tx_within_ward, s.stat_canc_tx_within_ward,
            s.stat_ip_bed,  s.stat_dp_bed,
            (CASE WHEN s.ward_code <> 'HOME' THEN
               (s.stat_dsch - s.stat_canc_dsch + s.stat_deth - s.stat_canc_deth
             + s.stat_txout - s.stat_canc_txout
             - s.stat_day_dsch + s.stat_canc_day_dsch - s.stat_day_deth
             + s.stat_canc_day_deth - (s.stat_tx_within_ward / 2)
             + (s.stat_canc_tx_within_ward/2))  ELSE NULL END)::REAL AS stat_inpat_treated, -- Inpatient treated
            (CASE WHEN s.ward_code <> 'HOME' and s.stat_ip_bed <> 0 THEN s.stat_bdo * 100/s.stat_ip_bed ELSE NULL END)::REAL AS stat_occ_rate,
            (CASE WHEN s.ward_code <> 'HOME' AND s.stat_ip_bed <> 0 AND s.stat_vac >= s.stat_exc THEN
                (s.stat_vac - s.stat_exc) * var_days / s.stat_ip_bed ELSE NULL END)::REAL AS stat_turnover_interval
        FROM ward_sum_join_beds s left join ward_desc d
        on s.ward_code = d.ward_code) a1
    )
    -- 统计至 create temporary table t$dsp_table之前
    , non_home_total AS (
    select *,
          (CASE WHEN stat_inpat_treated <> 0 THEN stat_bdo /stat_inpat_treated  ELSE NULL END) as stat_los,
          (CASE WHEN stat_ip_bed <> 0 AND stat_vac >= stat_exc THEN
              stat_inpat_treated * var_days /stat_ip_bed ELSE NULL END) as stat_turnover
    from (
        SELECT
          NULL as ward_code, 'Hospital Total' as ward_desc,*,
          (stat_dsch - stat_canc_dsch + stat_deth - stat_canc_deth - stat_day_dsch + stat_canc_day_dsch
          - stat_day_deth + stat_canc_day_deth) as stat_inpat_treated,
          (CASE WHEN stat_ip_bed <> 0 THEN stat_bdo * 100 / stat_ip_bed ELSE NULL END) as stat_occ_rate,
          (CASE WHEN stat_ip_bed <> 0 AND stat_vac >= stat_exc THEN (stat_vac - stat_exc) * var_days/stat_ip_bed ELSE NULL END) as stat_turnover_interval
        FROM (
            SELECT
                (case when SUM(stat_prev_remain) = 0 then NULL else SUM(stat_prev_remain) end) AS stat_prev_remain,
                SUM(stat_remain) AS stat_remain,
                SUM(stat_vac) AS stat_vac,
                SUM(stat_exc) AS stat_exc,
                SUM(stat_bdo) AS stat_bdo,
                SUM(stat_adm) AS stat_adm,
                SUM(stat_canc_adm) AS stat_canc_adm,
                SUM(stat_txin) AS stat_txin,
                SUM(stat_canc_txin) AS stat_canc_txin,
                SUM(stat_txout) AS stat_txout,
                SUM(stat_canc_txout) AS stat_canc_txout,
                SUM(stat_td_txin) AS stat_td_txin,
                SUM(stat_canc_td_txin) AS stat_canc_td_txin,
                SUM(stat_td_txout) AS stat_td_txout,
                SUM(stat_canc_td_txout) AS stat_canc_td_txout,
                SUM(stat_dsch) AS stat_dsch,
                SUM(stat_canc_dsch) AS stat_canc_dsch,
                SUM(stat_deth) AS stat_deth,
                SUM(stat_canc_deth) AS stat_canc_deth,
                SUM(stat_ae_day_dsch) AS stat_ae_day_dsch,
                SUM(stat_canc_ae_day_dsch) AS stat_canc_ae_day_dsch,
                SUM(stat_ae_day_deth) AS stat_ae_day_deth,
                SUM(stat_canc_ae_day_deth) AS stat_canc_ae_day_deth,
                SUM(stat_day_dsch) as stat_day_dsch, -- Day discharge not calculated here
                SUM(stat_canc_day_dsch) as stat_canc_day_dsch, -- Canc day discharge not calculated here
                SUM(stat_day_deth) as stat_day_deth, -- Day death not calculated here
                SUM(stat_canc_day_deth) as stat_canc_day_deth, -- Canc day death not calculated here
                SUM(stat_tx_within_ward) as stat_tx_within_ward, -- Transfer within ward not calculated here
                SUM(stat_canc_tx_within_ward) as stat_canc_tx_within_ward, -- Canc transfer within ward not calculated here
                SUM(stat_ip_bed) as stat_ip_bed, -- Inpatient beds
                SUM(stat_dp_bed) as stat_dp_bed -- Day patient beds
            FROM ward_stat
            WHERE ward_code <> 'HOME') a) a1
    )
    -- 合并成一个数据集，并处理par_input_from_date <> par_input_to_date
    , t$dsp_table AS (
        SELECT
            ward_code as dsp_code,
            ward_desc as dsp_desc,
            stat_prev_remain as dsp_prev_remain,
            (CASE WHEN var_days > 1 THEN stat_adm - stat_canc_adm ELSE stat_adm END)  as dsp_adm,
            (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_adm END) as dsp_canc_adm,
            (CASE WHEN var_days > 1 THEN stat_txin - stat_canc_txin ELSE stat_txin END) as dsp_txin,
            (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_txin END) as dsp_canc_txin,
            (CASE WHEN var_days > 1 THEN stat_txout - stat_canc_txout ELSE stat_txout END) as dsp_txout,
            (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_txout END) as dsp_canc_txout,
            (CASE WHEN var_days > 1 THEN stat_tx_within_ward - stat_canc_tx_within_ward ELSE stat_tx_within_ward END) as dsp_tx_within_ward,
            (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_tx_within_ward END) as dsp_canc_tx_within_ward,
            (CASE WHEN var_days > 1 THEN stat_td_txin - stat_canc_td_txin ELSE stat_td_txin END) as dsp_td_txin,
            (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_td_txin END) as dsp_canc_td_txin,
            (CASE WHEN var_days > 1 THEN stat_td_txout - stat_canc_td_txout ELSE stat_td_txout END) as dsp_td_txout,
            (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_td_txout END) as dsp_canc_td_txout,
            (CASE WHEN var_days > 1 THEN stat_dsch - stat_canc_dsch ELSE stat_dsch END) as dsp_dsch,
            (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_dsch END) as dsp_canc_dsch,
            (CASE WHEN var_days > 1 THEN stat_deth - stat_canc_deth ELSE stat_deth END) as dsp_deth,
            (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_deth END) as dsp_canc_deth,
            (CASE WHEN var_days > 1 THEN stat_ae_day_dsch - stat_canc_ae_day_dsch ELSE stat_ae_day_dsch END) as dsp_ae_day_dsch,
            (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_ae_day_dsch END) as dsp_canc_ae_day_dsch,
            (CASE WHEN var_days > 1 THEN stat_ae_day_deth - stat_canc_ae_day_deth ELSE stat_ae_day_deth END) as dsp_ae_day_deth,
            (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_ae_day_deth END) as dsp_canc_ae_day_deth,
            stat_remain as dsp_remain,
            stat_bdo::REAL as dsp_bdo,
            stat_vac::REAL as dsp_vac,
            stat_ip_bed::REAL as dsp_ip_bed,
            stat_exc as dsp_exc,
            stat_dp_bed as dsp_dp_bed,
            (CASE WHEN var_days > 1 THEN stat_day_dsch - stat_canc_day_dsch ELSE stat_day_dsch END) as dsp_day_dsch,
            (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_day_dsch END) as dsp_canc_day_dsch,
            (CASE WHEN var_days > 1 THEN stat_day_deth - stat_canc_day_deth ELSE stat_day_deth END) as dsp_day_deth,
            (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_day_deth END) as dsp_canc_day_deth,
            stat_inpat_treated::REAL as dsp_inpat_treated,
            stat_occ_rate::REAL as dsp_occ_rate,
            stat_los::REAL as dsp_los,
            stat_turnover::REAL as dsp_turnover,
            stat_turnover_interval::REAL as dsp_turnover_interval
        FROM (
            (SELECT * FROM ward_stat WHERE ward_code <> 'HOME')
            UNION ALL
            (SELECT * FROM non_home_total)
            UNION ALL
            (SELECT * FROM ward_stat WHERE ward_code = 'HOME')
             ) as t
        WHERE ward_desc is not null
    )
    SELECT * FROM t$dsp_table WHERE dsp_adm <> 0 OR dsp_canc_adm <> 0
        OR dsp_txin <> 0 OR dsp_canc_txin <> 0
        OR dsp_txout <> 0 OR dsp_canc_txout <> 0
        OR dsp_tx_within_ward <> 0 OR dsp_canc_tx_within_ward <> 0
        OR dsp_td_txin <> 0 OR dsp_canc_td_txin <> 0
        OR dsp_td_txout <> 0 OR dsp_canc_td_txout <> 0
        OR dsp_dsch <> 0 OR dsp_canc_dsch <> 0
        OR dsp_deth <> 0 OR dsp_canc_deth <> 0
        OR dsp_ae_day_dsch <> 0 OR dsp_canc_ae_day_dsch <> 0
        OR dsp_ae_day_deth <> 0 OR dsp_canc_ae_day_deth <> 0
        OR dsp_remain <> 0 OR dsp_bdo <> 0 OR dsp_vac <> 0 OR dsp_ip_bed <> 0 OR dsp_exc <> 0 OR dsp_dp_bed <> 0
        OR dsp_day_dsch <> 0 OR dsp_canc_day_dsch <> 0
        OR dsp_day_deth <> 0 OR dsp_canc_day_deth <> 0;

    pas_return_code := 0;
    RETURN;
END ;
$procedure$
;


;ALTER PROCEDURE "hasp_get_ward_stat_cte" OWNER TO "HPI_SCHEMA_OWNER_ROLE";