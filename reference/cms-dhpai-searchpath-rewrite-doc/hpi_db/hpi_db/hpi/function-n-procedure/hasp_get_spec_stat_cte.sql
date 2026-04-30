-- DROP PROCEDURE hpi.hasp_get_spec_stat_cte(inout int4, in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_spec_stat_cte(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, IN par_input_spec character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_days REAL;
    var_prev_date timestamp without time zone;

begin
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
           -- 科室列表
           , spec_list AS (
            SELECT DISTINCT Specialty_code as spec_code
            FROM Specialty
            WHERE Specialty_code LIKE par_input_spec
              AND Specialty_code <> 'A&E'
              AND Hospital_code = par_hosp_code
        )
           -- 科室定义信息
           , spec_desc AS (
            SELECT w.Specialty_code as spec_code, w.Description AS spec_desc
            FROM Specialty w, spec_list l
            WHERE w.Specialty_code = l.spec_code
              AND w.Effective_date = (
                SELECT MAX(w2.Effective_date)
                FROM Specialty w2
                WHERE w2.Specialty_code = w.Specialty_code
                  AND w2.Effective_date <= par_input_to_date
                  AND w2.Hospital_code = par_hosp_code)
              AND w.Hospital_code = par_hosp_code
        )
           -- 病区和专业的唯一组合
           , ward_and_specialty AS (
            SELECT DISTINCT w.spec_code,s.Ward_code
            FROM spec_list w,Ward_specialty s
            WHERE w.spec_code = s.specialty_code
              AND s.Hospital_code = par_hosp_code
              AND s.Ward_code <> 'AE01'
        )
           -- 病区和专业的唯一组合，取某日的最大有效日期
           , ward_spec_max_effective AS (
            SELECT distinct r.tx_date,s.Specialty_code, w.Ward_code,
                            MAX(s.Effective_date) AS max_effective_date
            FROM Ward_and_specialty w, Ward_specialty s,date_range r
            WHERE w.Ward_code = s.Ward_code
              AND w.spec_code = s.Specialty_code
              AND s.Hospital_code = par_hosp_code
              AND s.Effective_date <= r.tx_date
            group by r.tx_date,s.specialty_code,w.ward_code
        )
           -- 统计一天中不同专业的床位数
           , beds_of_day_and_spec AS (
            SELECT m.tx_date,
                   s.specialty_code as spec_code,
                   s.specialty_code as treat_loc,
                   COALESCE(SUM(s.Official_bed), 0) AS var_ttl_ip_bed,
                   COALESCE(SUM(s.Day_bed), 0) AS var_ttl_dp_bed
            FROM Ward_specialty s, ward_spec_max_effective m
            WHERE m.Ward_code = s.Ward_code
              AND m.Specialty_code = s.Specialty_code
              AND s.Effective_date = m.max_effective_date
              AND s.Hospital_code = par_hosp_code
            GROUP BY m.tx_date,s.specialty_code
        )
           , spec_first_date AS (
            SELECT -- var_prev_date AS tx_date,
                   b.specialty_code AS spec_code,     -- 专科代码
                   b.treatment_location AS treat_loc, -- 治疗地点
                   (SUM(COALESCE(b.Previous_remaining, 0))
                        + SUM(COALESCE(b.Admission, 0)) - SUM(COALESCE(b.Canc_admission, 0))
                        + SUM(COALESCE(b.Transfer_in, 0)) + SUM(COALESCE(b.Transfer_in_from_TD, 0))
                        - SUM(COALESCE(b.Transfer_out, 0)) - SUM(COALESCE(b.Transfer_out_to_TD, 0))
                        - SUM(COALESCE(b.Discharge, 0)) - SUM(COALESCE(b.Death, 0))
                        - SUM(COALESCE(b.Canc_transfer_in, 0)) - SUM(COALESCE(b.Canc_transfer_in_from_TD, 0))
                       + SUM(COALESCE(b.Canc_transfer_out, 0)) + SUM(COALESCE(b.Canc_transfer_out_to_TD, 0))
                       + SUM(COALESCE(b.Canc_discharge, 0)) + SUM(COALESCE(b.Canc_death, 0)))::integer AS var_prev_remain
            FROM Ward_spec_tx_adj_view b,
                 (SELECT MAX(Ward_spec_tx_date) AS tx_date,
                         Ward_code AS ward_code,
                         Specialty_code AS spec_code,
                         Treatment_location AS treat_loc
                  FROM Ward_spec_tx
                  WHERE Ward_spec_tx_date < par_input_from_date
                    AND Hospital_code = par_hosp_code::VARCHAR
                  GROUP BY specialty_code, treatment_location, ward_code) AS a
            WHERE  a.tx_date  = b.Ward_spec_tx_date
              AND a.Ward_code = b.Ward_code
              AND a.spec_code = b.specialty_code
              AND b.Hospital_code = par_hosp_code
              AND COALESCE(a.treat_loc, 'null') = COALESCE(b.treatment_location, 'null')
            GROUP BY b.specialty_code, b.treatment_location
        )
        -- 补充完整treat_loc为null的记录,以及把非null的stat_prev_remain汇总到null记录的stat_prev_remain中
        , spec_first_date1 AS (
        SELECT * FROM (
           (SELECT * FROM spec_first_date WHERE treat_loc IS NOT NULL)
           UNION ALL
           (SELECT spec_code, treat_loc, sum(var_prev_remain) AS var_prev_remain -- 汇总treat_loc为null的记录
              FROM (
              (SELECT treat_loc AS spec_code, NULL::varchar treat_loc, var_prev_remain
                 FROM spec_first_date
                WHERE treat_loc IS NOT NULL) -- 把treat_loc的code作为spec_code，treat_loc为null
              UNION ALL
		      (SELECT * FROM spec_first_date WHERE treat_loc IS NULL) -- 保留treat_loc为null的记录
		   ) t1
			GROUP BY spec_code,treat_loc)) t2
		ORDER BY spec_code
		)
           -- 汇总生成spec_code,NULL 以及spec_code,treat_loc(spec_code)的记录集，且时间为from的前一天
           , spec_first_date2 AS (
            SELECT var_prev_date AS tx_date, spec_code, spec_code as treat_loc,var_prev_remain,
                   0::integer AS var_sub_remain, 0::integer AS var_bdo,
                   0 AS var_adm, 0 AS var_ae_adm,
                   0 AS var_txin, 0 AS var_txout, 0 AS var_td_txin, 0 AS var_td_txout,
                   0 AS var_dsch, 0 AS var_deth, 0 AS var_ae_day_dsch, 0 AS var_ae_day_deth, 0 AS var_day_dsch, 0 AS var_day_deth,
                   0 AS var_tx_within_spec,
                   0 AS var_canc_adm, 0 AS var_canc_ae_adm,
                   0 AS var_canc_txin, 0 AS var_canc_txout, 0 AS var_canc_td_txin, 0 AS var_canc_td_txout,
                   0 AS var_canc_dsch, 0 AS var_canc_deth, 0 AS var_canc_ae_day_dsch, 0 AS var_canc_ae_day_deth, 0 AS var_canc_day_dsch, 0 AS var_canc_day_deth,
                   0 AS var_canc_tx_within_spec
            FROM (
              (SELECT * FROM spec_first_date1 WHERE treat_loc IS NULL)
              UNION ALL
              (SELECT  a.spec_code AS spec_code,
                       a.spec_code AS treat_loc,
                       0::integer  AS var_prev_remain
               FROM spec_list a LEFT JOIN (SELECT * FROM spec_first_date1 WHERE treat_loc IS NULL) b ON a.spec_code = b.spec_code
               WHERE b.spec_code IS NULL)
          ) t1
        )

           -- date_range d, ward_list wl
           , date_join_spec AS (
            SELECT d.tx_date,wl.spec_code,wl.spec_code AS treat_loc FROM date_range d, spec_list wl
        )
           --根据专科代码和日期范围，计算每个专科每天的统计数据 (Treatment location = null) sum_of_day_and_spec_treat_is_null
           , sum_treat_null_of_days AS (
            SELECT * FROM (
                              (SELECT * FROM spec_first_date2)
                              UNION ALL
                              (SELECT
                                   wl.tx_date as tx_date,
                                   wl.spec_code as ward_code,
                                   wl.treat_loc as treat_loc,
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
                                   SUM(COALESCE(t.Admission, 0)) as var_adm,                          SUM(COALESCE(t.Admission_thru_AE, 0)) as var_ae_adm,
                                   SUM(COALESCE(t.Transfer_in, 0)) as var_txin,                       SUM(COALESCE(t.Transfer_out, 0)) as var_txout,
                                   SUM(COALESCE(t.Transfer_in_from_TD, 0)) as var_td_txin,            SUM(COALESCE(t.Transfer_out_to_TD, 0)) as var_td_txout,
                                   SUM(COALESCE(t.Discharge, 0)) as var_dsch,                         SUM(COALESCE(t.Death, 0)) as var_deth,
                                   SUM(COALESCE(t.AE_day_discharge, 0)) as var_ae_day_dsch,           SUM(COALESCE(t.AE_day_death, 0)) as var_ae_day_deth,
                                   SUM(COALESCE(t.Day_discharge, 0)) as var_day_dsch,                 SUM(COALESCE(t.Day_death, 0)) as var_day_deth,
                                   SUM(COALESCE(t.Transfer_within_specialty, 0)) as var_tx_within_spec,
                                   SUM(COALESCE(t.Canc_admission, 0)) as var_canc_adm,                SUM(COALESCE(t.Canc_admission_thru_AE, 0)) as var_canc_ae_adm,
                                   SUM(COALESCE(t.Canc_transfer_in, 0)) as var_canc_txin,             SUM(COALESCE(t.Canc_transfer_out, 0)) as var_canc_txout,
                                   SUM(COALESCE(t.Canc_transfer_in_from_TD, 0)) as var_canc_td_txin,  SUM(COALESCE(t.Canc_transfer_out_to_TD, 0)) as var_canc_td_txout,
                                   SUM(COALESCE(t.Canc_discharge, 0)) as var_canc_dsch,               SUM(COALESCE(t.Canc_death, 0)) as var_canc_deth,
                                   SUM(COALESCE(t.Canc_AE_day_discharge, 0)) as var_canc_ae_day_dsch, SUM(COALESCE(t.Canc_AE_day_death, 0)) as var_canc_ae_day_deth,
                                   SUM(COALESCE(t.Canc_day_discharge, 0)) as var_canc_day_dsch,       SUM(COALESCE(t.Canc_day_death, 0)) as var_canc_day_deth,
                                   SUM(COALESCE(t.Canc_transfer_within_specialty, 0)) as var_canc_tx_within_spec
                               FROM date_join_spec wl left join Ward_spec_tx_adj_view t ON
                                   t.Hospital_code = par_hosp_code
                                   AND t.ward_spec_tx_date = wl.tx_date
                                   AND ((t.Specialty_code = wl.spec_code AND t.Treatment_location IS NULL)
                                        OR t.Treatment_location = wl.spec_code)
                                   AND wl.spec_code = wl.treat_loc
                               GROUP BY wl.spec_code, wl.treat_loc, wl.tx_date)
                          ) AS ws
        )
           -- 统计专科的汇总信息 (Treatment location = null)   spec_sum_join_beds_treat_is_null
           , stat_treat_null_join_beds AS (
            SELECT spec_code,NULL::varchar AS treat_loc,
                   sum(var_prev_remain) as stat_prev_remain,
                   sum(var_sub_remain) AS stat_remain,
                   sum(_var_vac) AS stat_vac,                      sum(_var_exc) AS stat_exc,
                   sum(var_bdo) AS stat_bdo,
                   sum(var_adm) AS stat_adm,                       sum(var_canc_adm) AS stat_canc_adm,
                   sum(var_txin) AS stat_txin,                     sum(var_canc_txin) AS stat_canc_txin,
                   sum(var_txout) AS stat_txout,                   sum(var_canc_txout) AS stat_canc_txout,
                   sum(var_td_txin) AS stat_td_txin,               sum(var_canc_td_txin) AS stat_canc_td_txin,
                   sum(var_td_txout) AS stat_td_txout,             sum(var_canc_td_txout) AS stat_canc_td_txout,
                   sum(var_dsch) AS stat_dsch,                     sum(var_canc_dsch) AS stat_canc_dsch,
                   sum(var_deth) AS stat_deth,                     sum(var_canc_deth) AS stat_canc_deth,
                   sum(var_ae_day_dsch) AS stat_ae_day_dsch,       sum(var_canc_ae_day_dsch) AS stat_canc_ae_day_dsch,
                   sum(var_ae_day_deth) AS stat_ae_day_deth,       sum(var_canc_ae_day_deth) AS stat_canc_ae_day_deth,
                   sum(var_ae_adm) AS stat_ae_adm,                 sum(var_canc_ae_adm) AS stat_canc_ae_adm,
                   sum(var_day_dsch) AS stat_day_dsch,             sum(var_canc_day_dsch) AS stat_canc_day_dsch,
                   sum(var_day_deth) AS stat_day_deth,             sum(var_canc_day_deth) AS stat_canc_day_deth,
                   sum(var_tx_within_spec) AS stat_tx_within_spec, sum(var_canc_tx_within_spec) AS stat_canc_tx_within_spec,
                   sum(var_ttl_ip_bed) AS stat_ip_bed,             sum(var_ttl_dp_bed) AS stat_dp_bed
            FROM (
                     SELECT *,
                            (CASE WHEN var_days > 1 and _rn = 1 THEN __var_prev_remain ELSE _var_prev_remain END) as var_prev_remain,
                            (CASE WHEN _rnasc = 1 THEN 0 ELSE _var_ttl_remain END) as var_sub_remain,
                            (CASE WHEN _rnasc = 1 THEN 0 ELSE _var_ttl_bdo END) as var_bdo,
                            (CASE WHEN _rnasc = 1 THEN 0 ELSE var_vac END) as _var_vac,
                            (CASE WHEN _rnasc = 1 THEN 0 ELSE var_exc END) as _var_exc
                     FROM (
                              SELECT *,
                                     (CASE WHEN _rnasc = 1 THEN 0 WHEN _var_ttl_bdo > var_ttl_ip_bed THEN 0
                                           ELSE var_ttl_ip_bed - _var_ttl_bdo END) AS var_vac,
                                     (CASE WHEN _rnasc = 1 THEN 0 WHEN _var_ttl_bdo > var_ttl_ip_bed THEN
                                         _var_ttl_bdo - var_ttl_ip_bed ELSE 0 END) AS var_exc,
                                     (_var_ttl_remain - _var_sub_remain) as __var_prev_remain
                              FROM (
                                       SELECT *,
                                              (CASE WHEN _rnasc = 1 THEN 0 ELSE _var_ttl_remain + _var_bdo END) as _var_ttl_bdo
                                       FROM (
                                                SELECT
                                                    s.tx_date,
                                                    s.spec_code,
                                                    s.treat_loc,
                                                    (sum(COALESCE(s.var_prev_remain, 0) + COALESCE(s.var_sub_remain, 0)) OVER (PARTITION BY s.spec_code,s.treat_loc ORDER BY s.tx_date)) AS _var_ttl_remain,
                                                    row_number() OVER (PARTITION BY s.spec_code,s.treat_loc ORDER BY s.tx_date DESC) AS _rn,
                                                    row_number() OVER (PARTITION BY s.spec_code,s.treat_loc ORDER BY s.tx_date) as _rnasc,
                                                    COALESCE(s.var_prev_remain, 0) AS _var_prev_remain,
                                                    COALESCE(s.var_sub_remain, 0) AS _var_sub_remain,
                                                    COALESCE(s.var_bdo, 0) AS _var_bdo,
                                                    COALESCE(s.var_adm, 0) AS var_adm, COALESCE(s.var_canc_adm, 0) AS var_canc_adm,
                                                    COALESCE(s.var_txin, 0) AS var_txin, COALESCE(s.var_canc_txin, 0) AS var_canc_txin,
                                                    COALESCE(s.var_txout, 0) AS var_txout, COALESCE(s.var_canc_txout, 0) AS var_canc_txout,
                                                    COALESCE(s.var_td_txin, 0) AS var_td_txin, COALESCE(s.var_canc_td_txin, 0) AS var_canc_td_txin,
                                                    COALESCE(s.var_td_txout, 0) AS var_td_txout,  COALESCE(s.var_canc_td_txout, 0) AS var_canc_td_txout,
                                                    COALESCE(s.var_dsch, 0) AS var_dsch, COALESCE(s.var_canc_dsch, 0) AS var_canc_dsch,
                                                    COALESCE(s.var_deth, 0) AS var_deth, COALESCE(s.var_canc_deth, 0) AS var_canc_deth,
                                                    COALESCE(s.var_ae_day_dsch, 0) AS var_ae_day_dsch, COALESCE(s.var_canc_ae_day_dsch, 0) AS var_canc_ae_day_dsch,
                                                    COALESCE(s.var_ae_day_deth, 0) AS var_ae_day_deth, COALESCE(s.var_canc_ae_day_deth, 0) AS var_canc_ae_day_deth,
                                                    COALESCE(s.var_ae_adm, 0) AS var_ae_adm, COALESCE(s.var_canc_ae_adm, 0) AS var_canc_ae_adm,
                                                    COALESCE(s.var_day_dsch, 0) AS var_day_dsch, COALESCE(s.var_canc_day_dsch, 0) AS var_canc_day_dsch,
                                                    COALESCE(s.var_day_deth, 0) AS var_day_deth, COALESCE(s.var_canc_day_deth, 0) AS var_canc_day_deth,
                                                    COALESCE(s.var_tx_within_spec, 0) AS var_tx_within_spec, COALESCE(s.var_canc_tx_within_spec, 0) AS var_canc_tx_within_spec,
                                                    COALESCE(b.var_ttl_ip_bed, 0) AS var_ttl_ip_bed, COALESCE(b.var_ttl_dp_bed, 0) AS var_ttl_dp_bed
                                                FROM sum_treat_null_of_days s LEFT JOIN beds_of_day_and_spec b ON
                                                    s.tx_date = b.tx_date AND s.spec_code = b.spec_code AND s.treat_loc = b.treat_loc
                                            ) a
                                   ) c
                          ) d
                 ) e
            GROUP BY spec_code
        )
        -- /* Treatment location not is null (Calc tx summary) */
           --根据专科代码和日期范围，计算每个专科每天的统计数据 (Treatment location is not null)  sum_of_day_and_spec_treat
           , sum_treat_of_days AS (
                 SELECT wl.tx_date                                         AS tx_date,
                        wl.spec_code                                       AS spec_code,
                        t.Treatment_location                               AS treat_loc,
                        0::integer                                         AS var_prev_remain,
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
                        SUM(COALESCE(t.Admission, 0))                      as var_adm, SUM(COALESCE(t.Admission_thru_AE, 0))              as var_ae_adm,
                        SUM(COALESCE(t.Transfer_in, 0))                    as var_txin, SUM(COALESCE(t.Transfer_out, 0))                   as var_txout,
                        SUM(COALESCE(t.Transfer_in_from_TD, 0))            as var_td_txin, SUM(COALESCE(t.Transfer_out_to_TD, 0))             as var_td_txout,
                        SUM(COALESCE(t.Discharge, 0))                      as var_dsch, SUM(COALESCE(t.Death, 0))                          as var_deth,
                        SUM(COALESCE(t.AE_day_discharge, 0))               as var_ae_day_dsch,  SUM(COALESCE(t.AE_day_death, 0))                   as var_ae_day_deth,
                        SUM(COALESCE(t.Day_discharge, 0))                  as var_day_dsch, SUM(COALESCE(t.Day_death, 0))                      as var_day_deth,
                        SUM(COALESCE(t.Transfer_within_specialty, 0))      as var_tx_within_spec,
                        SUM(COALESCE(t.Canc_admission, 0))                 as var_canc_adm, SUM(COALESCE(t.Canc_admission_thru_AE, 0))         as var_canc_ae_adm,
                        SUM(COALESCE(t.Canc_transfer_in, 0))               as var_canc_txin, SUM(COALESCE(t.Canc_transfer_out, 0))              as var_canc_txout,
                        SUM(COALESCE(t.Canc_transfer_in_from_TD, 0))       as var_canc_td_txin, SUM(COALESCE(t.Canc_transfer_out_to_TD, 0))        as var_canc_td_txout,
                        SUM(COALESCE(t.Canc_discharge, 0))                 as var_canc_dsch, SUM(COALESCE(t.Canc_death, 0))                     as var_canc_deth,
                        SUM(COALESCE(t.Canc_AE_day_discharge, 0))          as var_canc_ae_day_dsch, SUM(COALESCE(t.Canc_AE_day_death, 0))              as var_canc_ae_day_deth,
                        SUM(COALESCE(t.Canc_day_discharge, 0))             as var_canc_day_dsch, SUM(COALESCE(t.Canc_day_death, 0))                 as var_canc_day_deth,
                        SUM(COALESCE(t.Canc_transfer_within_specialty, 0)) as var_canc_tx_within_spec,
                        1 as var_not_exist
                 FROM date_join_spec wl, Ward_spec_tx_adj_view t
                 WHERE t.Hospital_code     = par_hosp_code
                   AND t.ward_spec_tx_date = wl.tx_date
                   AND t.Specialty_code    = wl.spec_code
                   AND t.Treatment_location IS NOT NULL
                   AND t.Treatment_location <> t.Specialty_code
                 GROUP BY wl.tx_date, wl.spec_code, t.Treatment_location
        )
           -- 汇总生成spec_code,treat_loc 以及spec_code,treat_loc的记录集，且时间为from的前一天
           , spec_first_date3 as (
            SELECT var_prev_date AS tx_date, spec_code, treat_loc,var_prev_remain,
                   0::integer AS var_sub_remain, 0::integer AS var_bdo,
                   0 AS var_adm, 0 AS var_ae_adm,
                   0 AS var_txin, 0 AS var_txout,  0 AS var_td_txin, 0 AS var_td_txout,
                   0 AS var_dsch, 0 AS var_deth,  0 AS var_ae_day_dsch, 0 AS var_ae_day_deth,
                   0 AS var_day_dsch, 0 AS var_day_deth,
                   0 AS var_tx_within_spec,
                   0 AS var_canc_adm, 0 AS var_canc_ae_adm,
                   0 AS var_canc_txin, 0 AS var_canc_txout, 0 AS var_canc_td_txin, 0 AS var_canc_td_txout,
                   0 AS var_canc_dsch, 0 AS var_canc_deth, 0 AS var_canc_ae_day_dsch, 0 AS var_canc_ae_day_deth, 0 AS var_canc_day_dsch, 0 AS var_canc_day_deth,
                   0 AS var_canc_tx_within_spec,
                   0 AS var_not_exist,
                   0 as _var_not_exist
            FROM (
                     (SELECT * FROM spec_first_date1 WHERE treat_loc IS NOT NULL AND spec_code <> treat_loc)  -- from 的前一天已经存在的部分
                     UNION ALL
                     (SELECT  a.spec_code AS spec_code, a.treat_loc AS treat_loc, 0::integer  AS var_prev_remain -- 只在汇总阶段才出现的spec_code,treat_loc组合
                      FROM (SELECT DISTINCT spec_code, treat_loc FROM sum_treat_of_days) a -- 基于sum_of_day_and_spec_treat 生成spec_code,treat_loc的唯一组合，以及最早的时间
                          LEFT JOIN (SELECT * FROM spec_first_date1 WHERE treat_loc IS NOT NULL AND spec_code <> treat_loc) b
                          ON a.spec_code = b.spec_code AND a.treat_loc = b.treat_loc
                      WHERE b.spec_code IS NULL)
                 ) t1
        )
        -- date_range d, ward_list wl
           , dates_join_treat AS (
            SELECT d.tx_date,wl.spec_code,wl.treat_loc FROM date_range d, (SELECT DISTINCT spec_code,treat_loc FROM spec_first_date3) wl
        )
        -- 补齐上述已经统计的专科的记录的每一天(treat_loc is not null)
        , make_treat_of_days AS (
            SELECT t1.*,
                   (CASE WHEN NOT EXISTS(SELECT 1 FROM ward_spec_tx w 
                                                 WHERE t1.tx_date = w.ward_spec_tx_date  
                                                   AND t1.spec_code = w.specialty_code 
                                                   AND w.hospital_code = 'VH'  
                                                   AND COALESCE(t1.treat_loc, 'null') = COALESCE(w.treatment_location, 'null')) THEN 1 
                         WHEN t1.var_not_exist = 1 THEN 1 ELSE 0 END) AS _var_not_exist
              FROM
            (SELECT wl.tx_date, wl.spec_code, wl.treat_loc,
                   COALESCE(t.var_prev_remain, 0) AS var_prev_remain,
                   COALESCE(t.var_sub_remain, 0) AS var_sub_remain,
                   COALESCE(t.var_bdo, 0) AS var_bdo,
                   COALESCE(t.var_adm, 0) AS var_adm, COALESCE(t.var_ae_adm, 0) AS var_ae_adm,
                   COALESCE(t.var_txin, 0) AS var_txin, COALESCE(t.var_txout, 0) AS var_txout,
                   COALESCE(t.var_td_txin, 0) AS var_td_txin, COALESCE(t.var_td_txout, 0) AS var_td_txout,
                   COALESCE(t.var_dsch, 0) AS var_dsch, COALESCE(t.var_deth, 0) AS var_deth,
                   COALESCE(t.var_ae_day_dsch, 0) AS var_ae_day_dsch, COALESCE(t.var_ae_day_deth, 0) AS var_ae_day_deth,
                   COALESCE(t.var_day_dsch, 0) AS var_day_dsch, COALESCE(t.var_day_deth, 0) AS var_day_deth,
                   COALESCE(t.var_tx_within_spec, 0) AS var_tx_within_spec,
                   COALESCE(t.var_canc_adm, 0) AS var_canc_adm, COALESCE(t.var_canc_ae_adm, 0) AS var_canc_ae_adm,
                   COALESCE(t.var_canc_txin, 0) AS var_canc_txin, COALESCE(t.var_canc_txout, 0) AS var_canc_txout,
                   COALESCE(t.var_canc_td_txin, 0) AS var_canc_td_txin, COALESCE(t.var_canc_td_txout, 0) AS var_canc_td_txout,
                   COALESCE(t.var_canc_dsch, 0) AS var_canc_dsch, COALESCE(t.var_canc_deth, 0) AS var_canc_deth,
                   COALESCE(t.var_canc_ae_day_dsch, 0) AS var_canc_ae_day_dsch, COALESCE(t.var_canc_ae_day_deth, 0) AS var_canc_ae_day_deth,
                     COALESCE(t.var_canc_day_dsch, 0) AS var_canc_day_dsch, COALESCE(t.var_canc_day_deth, 0) AS var_canc_day_deth,
                     COALESCE(t.var_canc_tx_within_spec, 0) AS var_canc_tx_within_spec,
                     coalesce(t.var_not_exist, 0) as var_not_exist
              FROM dates_join_treat wl LEFT JOIN sum_treat_of_days t
                ON wl.tx_date = t.tx_date AND wl.spec_code = t.spec_code AND wl.treat_loc = t.treat_loc
            ) t1 
           )
           -- 统计专科的汇总信息 (Treatment location is not null)
           , stat_treat AS (
            SELECT spec_code, treat_loc,
                   sum(var_prev_remain) as stat_prev_remain,
                   sum(var_sub_remain) AS stat_remain,
                   sum(_var_vac) AS stat_vac,                      sum(_var_exc) AS stat_exc,
                   sum(var_bdo) AS stat_bdo,
                   sum(var_adm) AS stat_adm,                       sum(var_canc_adm) AS stat_canc_adm,
                   sum(var_txin) AS stat_txin,                     sum(var_canc_txin) AS stat_canc_txin,
                   sum(var_txout) AS stat_txout,                   sum(var_canc_txout) AS stat_canc_txout,
                   sum(var_td_txin) AS stat_td_txin,               sum(var_canc_td_txin) AS stat_canc_td_txin,
                   sum(var_td_txout) AS stat_td_txout,             sum(var_canc_td_txout) AS stat_canc_td_txout,
                   sum(var_dsch) AS stat_dsch,                     sum(var_canc_dsch) AS stat_canc_dsch,
                   sum(var_deth) AS stat_deth,                     sum(var_canc_deth) AS stat_canc_deth,
                   sum(var_ae_day_dsch) AS stat_ae_day_dsch,       sum(var_canc_ae_day_dsch) AS stat_canc_ae_day_dsch,
                   sum(var_ae_day_deth) AS stat_ae_day_deth,       sum(var_canc_ae_day_deth) AS stat_canc_ae_day_deth,
                   sum(var_ae_adm) AS stat_ae_adm,                 sum(var_canc_ae_adm) AS stat_canc_ae_adm,
                   sum(var_day_dsch) AS stat_day_dsch,             sum(var_canc_day_dsch) AS stat_canc_day_dsch,
                   sum(var_day_deth) AS stat_day_deth,             sum(var_canc_day_deth) AS stat_canc_day_deth,
                   sum(var_tx_within_spec) AS stat_tx_within_spec, sum(var_canc_tx_within_spec) AS stat_canc_tx_within_spec,
                   0::integer AS stat_ip_bed,             0::integer AS stat_dp_bed
            FROM (
                     SELECT *,
                            (CASE WHEN var_days > 1 and _rn = 1 THEN __var_prev_remain ELSE _var_prev_remain END) AS var_prev_remain,
                            (CASE WHEN _rn <> 1 THEN 0 ELSE _var_ttl_remain END) AS var_sub_remain,
                            (CASE WHEN _rn <> 1 THEN 0 ELSE _var_ttl_remain + _var_sum_bdo END)    AS var_bdo,
                            0::integer AS _var_vac,
                            0::integer AS _var_exc
                     FROM (
                           SELECT *,
                                  (_var_ttl_remain - _var_sub_remain) AS __var_prev_remain
                           FROM (
                           SELECT *,
                                  sum(_var_row_remain) OVER (PARTITION BY spec_code,treat_loc ORDER BY tx_date) as _var_ttl_remain
                           FROM (
                           SELECT *,
                                  (_var_prev_remain + _var_sub_remain) * _ttl_no_exist AS _var_row_remain
                           FROM (
                                    SELECT
                                        s.tx_date,
                                        s.spec_code,
                                        s.treat_loc,
                                        SUM(s._var_not_exist) OVER (partition by s.spec_code,s.treat_loc order by s.tx_date desc) as _ttl_no_exist, 
                                        sum(s.var_bdo) over (partition by s.spec_code,s.treat_loc) as _var_sum_bdo,
                                        row_number() OVER (PARTITION BY s.spec_code,s.treat_loc ORDER BY s.tx_date DESC) AS _rn,
                                        row_number() over (PARTITION BY s.spec_code,s.treat_loc ORDER BY s.tx_date) AS _rnasc,
                                        COALESCE(s.var_prev_remain, 0) AS _var_prev_remain,
                                        COALESCE(s.var_sub_remain, 0) AS _var_sub_remain,
                                        COALESCE(s.var_bdo, 0) AS _var_bdo,
                                        COALESCE(s.var_adm, 0) AS var_adm, COALESCE(s.var_canc_adm, 0) AS var_canc_adm,
                                        COALESCE(s.var_txin, 0) AS var_txin, COALESCE(s.var_canc_txin, 0) AS var_canc_txin,
                                        COALESCE(s.var_txout, 0) AS var_txout, COALESCE(s.var_canc_txout, 0) AS var_canc_txout,
                                        COALESCE(s.var_td_txin, 0) AS var_td_txin, COALESCE(s.var_canc_td_txin, 0) AS var_canc_td_txin,
                                        COALESCE(s.var_td_txout, 0) AS var_td_txout,  COALESCE(s.var_canc_td_txout, 0) AS var_canc_td_txout,
                                        COALESCE(s.var_dsch, 0) AS var_dsch, COALESCE(s.var_canc_dsch, 0) AS var_canc_dsch,
                                        COALESCE(s.var_deth, 0) AS var_deth, COALESCE(s.var_canc_deth, 0) AS var_canc_deth,
                                        COALESCE(s.var_ae_day_dsch, 0) AS var_ae_day_dsch, COALESCE(s.var_canc_ae_day_dsch, 0) AS var_canc_ae_day_dsch,
                                        COALESCE(s.var_ae_day_deth, 0) AS var_ae_day_deth, COALESCE(s.var_canc_ae_day_deth, 0) AS var_canc_ae_day_deth,
                                        COALESCE(s.var_ae_adm, 0) AS var_ae_adm, COALESCE(s.var_canc_ae_adm, 0) AS var_canc_ae_adm,
                                        COALESCE(s.var_day_dsch, 0) AS var_day_dsch, COALESCE(s.var_canc_day_dsch, 0) AS var_canc_day_dsch,
                                        COALESCE(s.var_day_deth, 0) AS var_day_deth, COALESCE(s.var_canc_day_deth, 0) AS var_canc_day_deth,
                                        COALESCE(s.var_tx_within_spec, 0) AS var_tx_within_spec, COALESCE(s.var_canc_tx_within_spec, 0) AS var_canc_tx_within_spec,
                                        0::integer AS var_ttl_ip_bed, 0::integer AS var_ttl_dp_bed,
                                        s._var_not_exist AS var_not_exist
                                    FROM ((SELECT *  FROM make_treat_of_days) UNION ALL (SELECT * FROM spec_first_date3)) s
                                ) a
                          ) d ) x ) y
                 ) e
            GROUP BY spec_code,treat_loc
        )
            -- 合并两个数据集,并剔除stat_loc is not null 以及 相关统计都为0
        , spec_stat AS (
            SELECT *
            FROM ((SELECT * FROM stat_treat_null_join_beds) UNION ALL (SELECT * FROM stat_treat)) t1
            WHERE NOT (treat_loc IS NOT NULL AND (
                stat_prev_remain = 0 AND stat_remain = 0 AND stat_vac = 0 AND stat_exc = 0 AND stat_bdo = 0
                    AND stat_adm = 0 AND stat_canc_adm = 0 AND stat_ae_adm = 0 AND stat_canc_ae_adm = 0
                    AND stat_txin = 0 AND stat_canc_txin = 0 AND stat_txout = 0 AND stat_canc_txout = 0
                    AND stat_td_txin = 0 AND stat_canc_td_txin = 0 AND stat_td_txout = 0 AND stat_canc_td_txout = 0
                    AND stat_dsch = 0 AND stat_canc_dsch = 0 AND stat_deth = 0 AND stat_canc_deth = 0
                    AND stat_ae_day_dsch = 0 AND stat_canc_ae_day_dsch = 0 AND stat_ae_day_deth = 0 AND stat_canc_ae_day_deth = 0
                    AND stat_day_dsch = 0 AND stat_canc_day_dsch = 0 AND stat_day_deth = 0 AND stat_canc_day_deth = 0
                    AND stat_tx_within_spec = 0 AND stat_canc_tx_within_spec = 0
                    AND stat_ip_bed = 0 AND stat_dp_bed = 0))
        )


        -- 以上统计数据是date loop结束
           -- 更新desc、第一轮统计数据、第二轮统计数据以及根据时间进行更新
           , spec_stat1 AS (
            SELECT spec_code,treat_loc,
                   (CASE WHEN treat_loc IS NOT NULL THEN treat_loc ELSE spec_desc END) AS spec_desc,
                   (CASE WHEN var_days > 1 THEN NULL ELSE stat_prev_remain END) AS stat_prev_remain,
                     stat_remain, stat_vac, stat_exc, stat_bdo,stat_ip_bed,stat_dp_bed,
                   (CASE WHEN var_days > 1 THEN stat_adm - stat_canc_adm ELSE stat_adm END) AS stat_adm,                                             (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_adm END) AS stat_canc_adm,
                   (CASE WHEN var_days > 1 THEN stat_ae_adm - stat_canc_ae_adm ELSE stat_ae_adm END) AS stat_ae_adm,                                 (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_ae_adm END) AS stat_canc_ae_adm,
                   (CASE WHEN var_days > 1 THEN stat_txin - stat_canc_txin ELSE stat_txin END) AS stat_txin,                                         (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_txin END) AS stat_canc_txin,
                   (CASE WHEN var_days > 1 THEN stat_td_txin - stat_canc_td_txin ELSE stat_td_txin END) AS stat_td_txin,                             (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_td_txin END) AS stat_canc_td_txin,
                   (CASE WHEN var_days > 1 THEN stat_txout - stat_canc_txout ELSE stat_txout END) AS stat_txout,                                     (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_txout END) AS stat_canc_txout,
                   (CASE WHEN var_days > 1 THEN stat_td_txout - stat_canc_td_txout ELSE stat_td_txout END) AS stat_td_txout,                         (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_td_txout END) AS stat_canc_td_txout,
                   (CASE WHEN var_days > 1 THEN stat_dsch - stat_canc_dsch ELSE stat_dsch END) AS stat_dsch,                                         (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_dsch END) AS stat_canc_dsch,
                   (CASE WHEN var_days > 1 THEN stat_day_dsch - stat_canc_day_dsch ELSE stat_day_dsch END) AS stat_day_dsch,                         (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_day_dsch END) AS stat_canc_day_dsch,
                   (CASE WHEN var_days > 1 THEN stat_ae_day_dsch - stat_canc_ae_day_dsch ELSE stat_ae_day_dsch END) AS stat_ae_day_dsch,             (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_ae_day_dsch END) AS stat_canc_ae_day_dsch,
                   (CASE WHEN var_days > 1 THEN stat_deth - stat_canc_deth ELSE stat_deth END) AS stat_deth,                                         (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_deth END) AS stat_canc_deth,
                   (CASE WHEN var_days > 1 THEN stat_day_deth - stat_canc_day_deth ELSE stat_day_deth END) AS stat_day_deth,                         (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_day_deth END) AS stat_canc_day_deth,
                   (CASE WHEN var_days > 1 THEN stat_ae_day_deth - stat_canc_ae_day_deth ELSE stat_ae_day_deth END) AS stat_ae_day_deth,             (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_ae_day_deth END) AS stat_canc_ae_day_deth,
                   (CASE WHEN var_days > 1 THEN stat_tx_within_spec - stat_canc_tx_within_spec ELSE stat_tx_within_spec END) AS stat_tx_within_spec, (CASE WHEN var_days > 1 THEN 0 ELSE stat_canc_tx_within_spec END) AS stat_canc_tx_within_spec,
                   stat_bed_comp, stat_in_day_treated, stat_inpat_treated, stat_occ_rate, stat_los, stat_turnover, stat_dba, stat_dbp, stat_deth_1000
            FROM
            (SELECT *,
                   (CASE WHEN treat_loc IS NULL AND stat_bed_comp <> 0 THEN stat_inpat_treated/stat_bed_comp WHEN treat_loc IS NULL THEN 0 ELSE NULL END)::REAL AS stat_turnover,
                   (CASE WHEN treat_loc IS NULL AND stat_bed_comp <> 0 THEN ABS(stat_vac - stat_exc)/stat_bed_comp WHEN treat_loc IS NULL THEN 0 ELSE NULL END)::REAL AS stat_dba,
                   (CASE WHEN stat_inpat_treated <> 0 THEN stat_bdo / stat_inpat_treated ELSE NULL END)::REAL AS stat_los,
                   (CASE WHEN treat_loc IS NULL AND stat_inpat_treated <> 0 THEN ABS(stat_vac - stat_exc) / stat_inpat_treated WHEN treat_loc IS NULL THEN 0 ELSE NULL END)::REAL AS stat_dbp,
                   (CASE WHEN treat_loc IS NULL AND stat_in_day_treated <> 0 THEN 1000 *(stat_deth - stat_canc_deth)/stat_in_day_treated WHEN treat_loc IS NULL THEN 0 ELSE NULL END)::REAL AS stat_deth_1000
            FROM
            (SELECT s.*, d.spec_desc AS spec_desc,
                   (CASE WHEN s.treat_loc IS NULL THEN s.stat_ip_bed / var_days ELSE NULL END)::REAL AS stat_bed_comp,
                   (s.stat_txout + s.stat_dsch + s.stat_deth - (s.stat_tx_within_spec/2) + (s.stat_canc_tx_within_spec/2)
                        - s.stat_canc_txout - s.stat_canc_dsch - s.stat_canc_deth)::REAL AS stat_in_day_treated,
                   (s.stat_txout + s.stat_dsch + s.stat_deth - (s.stat_tx_within_spec/2) + (s.stat_canc_tx_within_spec/2)
                        - s.stat_canc_txout - s.stat_canc_dsch - s.stat_canc_deth 
                        - s.stat_day_dsch - s.stat_day_deth  + s.stat_canc_day_dsch + s.stat_canc_day_deth)::REAL AS stat_inpat_treated,
                   (CASE WHEN s.treat_loc IS NULL AND s.stat_ip_bed <> 0 THEN 100 * s.stat_bdo / s.stat_ip_bed WHEN s.treat_loc IS NULL THEN 0 ELSE NULL END)::REAL AS stat_occ_rate
            FROM spec_stat s LEFT JOIN spec_desc d ON s.spec_code = d.spec_code AND s.treat_loc IS NULL) t1 ) t2
        )

        -- spec_code <> 'HOME' AND spec_code LIKE par_input_spec 的数据集
        , spec_stat2 AS (
            SELECT spec_code as _spec_code,
                   (case when treat_loc is null then ' ' else treat_loc end) as _treat_loc,
                   *,
                   row_number() OVER (PARTITION BY spec_code,_noequal ORDER BY treat_loc NULLS FIRST) AS _rn
            FROM
            (SELECT *,
                   (CASE WHEN COALESCE(spec_code, 'null') <> COALESCE(treat_loc, 'null') THEN 1 ELSE 0 END) as _noequal            FROM spec_stat1
            WHERE spec_code <> 'HOME'
              AND spec_code LIKE par_input_spec
              AND (stat_adm <> 0 OR stat_canc_adm <> 0 OR stat_canc_ae_adm <> 0 OR stat_txin <> 0 OR stat_canc_txin <> 0
                OR stat_txout <> 0 OR stat_canc_txout <> 0 OR stat_tx_within_spec <> 0 OR stat_canc_tx_within_spec <> 0 OR stat_td_txin <> 0
                OR stat_canc_td_txin <> 0 OR stat_td_txout <> 0 OR stat_canc_td_txout <> 0 OR stat_dsch <> 0 OR stat_canc_dsch <> 0 OR stat_deth <> 0
                OR stat_canc_deth <> 0 OR stat_ae_day_dsch <> 0 OR stat_canc_ae_day_dsch <> 0 OR stat_ae_day_deth <> 0 OR stat_canc_ae_day_deth <> 0
                OR stat_remain <> 0 OR stat_bdo <> 0 OR stat_vac <> 0 OR stat_ip_bed <> 0 OR stat_exc <> 0 OR stat_dp_bed <> 0 OR stat_day_dsch <> 0
                OR stat_canc_day_dsch <> 0 OR stat_day_deth <> 0 OR stat_canc_day_deth <> 0)
            ORDER BY spec_code NULLS FIRST, treat_loc NULLS FIRST) t1
        )
        -- 对原始明细进一步处理的结果集
        , spec_detail AS (
            select _spec_code,_treat_loc,
                   (CASE WHEN _noequal = 1 AND _rn > 1 THEN NULL ELSE spec_code END) AS spec_code, treat_loc,
                   (CASE WHEN _noequal = 1 AND _rn > 1 THEN treat_loc ELSE spec_desc END) AS spec_desc,
                   stat_prev_remain,stat_remain, stat_vac, stat_exc, stat_bdo,stat_ip_bed,stat_dp_bed,stat_adm,stat_canc_adm,stat_ae_adm,stat_canc_ae_adm,
                   stat_txin,stat_canc_txin,stat_td_txin,stat_canc_td_txin,
                   stat_txout,stat_canc_txout,stat_td_txout,stat_canc_td_txout,
                   stat_dsch,stat_canc_dsch,stat_day_dsch,stat_canc_day_dsch,stat_ae_day_dsch,stat_canc_ae_day_dsch,
                   stat_deth,stat_canc_deth,stat_day_deth,stat_canc_day_deth,stat_ae_day_deth,stat_canc_ae_day_deth,
                   stat_tx_within_spec,stat_canc_tx_within_spec,
                   stat_bed_comp, stat_in_day_treated, stat_inpat_treated, stat_occ_rate, stat_los, stat_turnover, stat_dba, stat_dbp, stat_deth_1000
            FROM spec_stat2
        )
        -- 生成spec维度的统计数据集
        , spec_total AS (
            SELECT spec_code as _spec_code, null::VARCHAR as _treat_loc,
            NULL::varchar AS spec_code, NULL::varchar AS treat_loc, 'Specialty Total'::varchar AS spec_desc,
                   stat_prev_remain,stat_remain,NULL::integer AS stat_vac,NULL::integer AS stat_exc,stat_bdo,NULL::integer AS stat_ip_bed,stat_dp_bed,stat_adm,stat_canc_adm,stat_ae_adm,stat_canc_ae_adm,
                   stat_txin,stat_canc_txin,stat_td_txin,stat_canc_td_txin,
                   stat_txout,stat_canc_txout,stat_td_txout,stat_canc_td_txout,
                   stat_dsch,stat_canc_dsch,stat_day_dsch,stat_canc_day_dsch,stat_ae_day_dsch,stat_canc_ae_day_dsch,
                   stat_deth,stat_canc_deth,stat_day_deth,stat_canc_day_deth,stat_ae_day_deth,stat_canc_ae_day_deth,
                   stat_tx_within_spec,stat_canc_tx_within_spec,
                   NULL::REAL AS stat_bed_comp, stat_in_day_treated, stat_inpat_treated, NULL::REAL AS stat_occ_rate, (CASE WHEN stat_inpat_treated = 0 THEN NULL ELSE stat_bdo/stat_inpat_treated END)::REAL AS stat_los, NULL::REAL AS stat_turnover, NULL::REAL AS stat_dba, NULL::REAL AS stat_dbp, NULL::REAL AS stat_deth_1000
            FROM
            (SELECT spec_code,MAX(_rn) AS _rn,
                   SUM(stat_prev_remain) AS stat_prev_remain,SUM(stat_remain) AS stat_remain, SUM(stat_adm) AS stat_adm,SUM(stat_canc_adm) AS stat_canc_adm,SUM(stat_ae_adm) AS stat_ae_adm, SUM(stat_canc_ae_adm) AS stat_canc_ae_adm,
                   SUM(stat_txin) AS stat_txin,SUM(stat_canc_txin) AS stat_canc_txin,SUM(stat_td_txin) AS stat_td_txin,SUM(stat_canc_td_txin) AS stat_canc_td_txin,
                   SUM(stat_txout) AS stat_txout,SUM(stat_canc_txout) AS stat_canc_txout,SUM(stat_td_txout) AS stat_td_txout,SUM(stat_canc_td_txout) AS stat_canc_td_txout,
                   SUM(stat_dsch) AS stat_dsch,SUM(stat_canc_dsch) AS stat_canc_dsch,SUM(stat_day_dsch) AS stat_day_dsch,SUM(stat_canc_day_dsch) AS stat_canc_day_dsch,
                   SUM(stat_ae_day_dsch) AS stat_ae_day_dsch,SUM(stat_canc_ae_day_dsch) AS stat_canc_ae_day_dsch,
                   SUM(stat_deth) AS stat_deth,SUM(stat_canc_deth) AS stat_canc_deth,SUM(stat_day_deth) AS stat_day_deth,SUM(stat_canc_day_deth) AS stat_canc_day_deth,
                   SUM(stat_ae_day_deth) AS stat_ae_day_deth,SUM(stat_canc_ae_day_deth) AS stat_canc_ae_day_deth,
                   SUM(stat_tx_within_spec) AS stat_tx_within_spec, SUM(stat_canc_tx_within_spec) AS stat_canc_tx_within_spec,
                   SUM(stat_vac) AS stat_vac, SUM(stat_exc) AS stat_exc, SUM(stat_bdo) AS stat_bdo, SUM(stat_ip_bed) AS stat_ip_bed, SUM(stat_dp_bed) AS stat_dp_bed,
                   SUM(stat_in_day_treated) AS stat_in_day_treated, SUM(stat_inpat_treated) AS stat_inpat_treated
            FROM spec_stat2 WHERE _noequal = 1 GROUP BY spec_code) t1
            WHERE _rn > 1
        )
        -- union all spec_total&spec_detail
        , spec_union AS (
           SELECT spec_code,treat_loc,spec_desc,
                  stat_prev_remain,stat_remain,stat_vac,stat_exc,stat_bdo,stat_ip_bed,stat_dp_bed,stat_adm,stat_canc_adm,stat_ae_adm,stat_canc_ae_adm,
                   stat_txin,stat_canc_txin,stat_td_txin,stat_canc_td_txin,
                   stat_txout,stat_canc_txout,stat_td_txout,stat_canc_td_txout,
                   stat_dsch,stat_canc_dsch,stat_day_dsch,stat_canc_day_dsch,stat_ae_day_dsch,stat_canc_ae_day_dsch,
                   stat_deth,stat_canc_deth,stat_day_deth,stat_canc_day_deth,stat_ae_day_deth,stat_canc_ae_day_deth,
                   stat_tx_within_spec,stat_canc_tx_within_spec,
                  stat_bed_comp, stat_in_day_treated, stat_inpat_treated,stat_occ_rate,stat_los,stat_turnover,stat_dba, stat_dbp, stat_deth_1000
           FROM (
             (SELECT * FROM spec_detail) UNION ALL (SELECT * FROM spec_total)
           ) t1
           ORDER BY _spec_code NULLS FIRST,_treat_loc NULLS LAST
        )
        -- 统计treat_loc is NULL数据集
        , hosp_total AS (
            SELECT NULL::varchar AS spec_code, NULL::varchar AS treat_loc, 'Hospital Total'::varchar AS spec_desc,
                   stat_prev_remain,stat_remain,stat_vac,stat_exc, stat_bdo, stat_ip_bed,stat_dp_bed,stat_adm,stat_canc_adm,stat_ae_adm,stat_canc_ae_adm,
                   stat_txin,stat_canc_txin,stat_td_txin,stat_canc_td_txin,
                   stat_txout,stat_canc_txout,stat_td_txout,stat_canc_td_txout,
                   stat_dsch,stat_canc_dsch,stat_day_dsch,stat_canc_day_dsch,stat_ae_day_dsch,stat_canc_ae_day_dsch,
                   stat_deth,stat_canc_deth,stat_day_deth,stat_canc_day_deth,stat_ae_day_deth,stat_canc_ae_day_deth,
                   stat_tx_within_spec,stat_canc_tx_within_spec,
                   (stat_ip_bed / var_days)::REAL AS stat_bed_comp, stat_in_day_treated, stat_inpat_treated, 
                   (CASE WHEN stat_ip_bed <> 0 THEN 100 * stat_bdo / stat_ip_bed ELSE NULL END)::REAL AS stat_occ_rate,
                   (CASE WHEN stat_inpat_treated <> 0 THEN stat_bdo / stat_inpat_treated ELSE NULL END)::REAL AS stat_los,
                   (CASE WHEN (stat_ip_bed / var_days) <> 0 THEN stat_inpat_treated / (stat_ip_bed / var_days) ELSE NULL END)::REAL AS stat_turnover,
                   (CASE WHEN (stat_ip_bed / var_days) <> 0 THEN ABS(stat_vac - stat_exc) / (stat_ip_bed / var_days) ELSE NULL END)::REAL AS stat_dba,
                   (CASE WHEN stat_inpat_treated <> 0 THEN ABS(stat_vac - stat_exc) / stat_inpat_treated ELSE NULL END)::REAL AS stat_dbp,
                   (CASE WHEN stat_in_day_treated <> 0 THEN 1000 * (stat_deth - stat_canc_deth) / stat_in_day_treated ELSE NULL END)::REAL AS stat_deth_1000
            FROM
                (SELECT
                   SUM(stat_prev_remain) AS stat_prev_remain,SUM(stat_remain) AS stat_remain, SUM(stat_adm) AS stat_adm,SUM(stat_canc_adm) AS stat_canc_adm,SUM(stat_ae_adm) AS stat_ae_adm, SUM(stat_canc_ae_adm) AS stat_canc_ae_adm,
                   SUM(stat_txin) AS stat_txin,SUM(stat_canc_txin) AS stat_canc_txin,SUM(stat_td_txin) AS stat_td_txin,SUM(stat_canc_td_txin) AS stat_canc_td_txin,
                   SUM(stat_txout) AS stat_txout,SUM(stat_canc_txout) AS stat_canc_txout,SUM(stat_td_txout) AS stat_td_txout,SUM(stat_canc_td_txout) AS stat_canc_td_txout,
                   SUM(stat_dsch) AS stat_dsch,SUM(stat_canc_dsch) AS stat_canc_dsch,SUM(stat_day_dsch) AS stat_day_dsch,SUM(stat_canc_day_dsch) AS stat_canc_day_dsch,
                   SUM(stat_ae_day_dsch) AS stat_ae_day_dsch,SUM(stat_canc_ae_day_dsch) AS stat_canc_ae_day_dsch,
                   SUM(stat_deth) AS stat_deth,SUM(stat_canc_deth) AS stat_canc_deth,SUM(stat_day_deth) AS stat_day_deth,SUM(stat_canc_day_deth) AS stat_canc_day_deth,
                   SUM(stat_ae_day_deth) AS stat_ae_day_deth,SUM(stat_canc_ae_day_deth) AS stat_canc_ae_day_deth,
                   SUM(stat_tx_within_spec) AS stat_tx_within_spec, SUM(stat_canc_tx_within_spec) AS stat_canc_tx_within_spec,
                   SUM(coalesce(stat_vac,0)) AS stat_vac, SUM(coalesce(stat_exc,0)) AS stat_exc, SUM(stat_bdo) AS stat_bdo, SUM(coalesce(stat_ip_bed,0)) AS stat_ip_bed, SUM(stat_dp_bed) AS stat_dp_bed,
                   SUM(stat_dsch + stat_deth - stat_canc_dsch - stat_canc_deth) AS stat_in_day_treated, 
                   SUM(stat_dsch + stat_deth - stat_canc_dsch - stat_canc_deth - stat_day_dsch - stat_day_deth + stat_canc_day_dsch + stat_canc_day_deth) AS stat_inpat_treated
            FROM spec_stat2 WHERE treat_loc IS NULL) t1
            WHERE par_input_spec = '%'
        )

           -- 合并成一个最终数据集
           , t$dsp_table AS (
            SELECT
                spec_code as dsp_code, treat_loc AS dsp_loc, spec_desc as dsp_desc,
                stat_prev_remain as dsp_prev_remain,
                stat_adm as dsp_adm,stat_canc_adm as dsp_canc_adm,
                stat_ae_adm as dsp_ae_adm,stat_canc_ae_adm as dsp_canc_ae_adm,
                stat_txin as dsp_txin,stat_canc_txin as dsp_canc_txin,
                stat_txout as dsp_txout,stat_canc_txout as dsp_canc_txout,
                stat_tx_within_spec as dsp_tx_within_spec,stat_canc_tx_within_spec as dsp_canc_tx_within_spec,
                stat_td_txin as dsp_td_txin,stat_canc_td_txin as dsp_canc_td_txin,
                stat_td_txout as dsp_td_txout,stat_canc_td_txout as dsp_canc_td_txout,
                stat_dsch as dsp_dsch,stat_canc_dsch as dsp_canc_dsch,
                stat_deth as dsp_deth,stat_canc_deth as dsp_canc_deth,
                stat_ae_day_dsch as dsp_ae_day_dsch,stat_canc_ae_day_dsch as dsp_canc_ae_day_dsch,
                stat_ae_day_deth as dsp_ae_day_deth,stat_canc_ae_day_deth as dsp_canc_ae_day_deth,
                stat_remain as dsp_remain,
                stat_bdo::REAL as dsp_bdo,stat_vac::REAL as dsp_vac,stat_ip_bed::REAL as dsp_ip_bed,stat_exc::REAL as dsp_exc,stat_dp_bed::INTEGER as dsp_dp_bed,
                stat_day_dsch as dsp_dp_dsch,stat_canc_day_dsch as dsp_canc_dp_dsch,
                stat_day_deth as dsp_dp_deth,stat_canc_day_deth as dsp_canc_dp_deth,
                stat_bed_comp::REAL as dsp_bed_comp,
                stat_in_day_treated::REAL as dsp_in_day_treated,
                stat_occ_rate::REAL as dsp_occ_rate, stat_los::REAL as dsp_los,
                stat_turnover::REAL as dsp_turnover,
                stat_dbp::REAL as dsp_dbp, stat_dba::REAL as dsp_dba,
                stat_deth_1000::REAL as dsp_deth_1000, stat_inpat_treated::REAL as dsp_inpat_treated
            FROM (
                     (SELECT * FROM spec_union)
                     UNION ALL
                     (SELECT * FROM hosp_total)
                     UNION ALL
                     (SELECT * FROM spec_stat1 WHERE spec_code = 'HOME')
                 ) as t
        )
        SELECT *
        FROM t$dsp_table
        WHERE dsp_adm <> 0 OR dsp_canc_adm <> 0
         OR dsp_txin <> 0 OR dsp_canc_txin <> 0
         OR dsp_txout <> 0 OR dsp_canc_txout <> 0
         OR dsp_tx_within_spec <> 0 OR dsp_canc_tx_within_spec <> 0
         OR dsp_td_txin <> 0 OR dsp_canc_td_txin <> 0
         OR dsp_td_txout <> 0 OR dsp_canc_td_txout <> 0
         OR dsp_dsch <> 0 OR dsp_canc_dsch <> 0
         OR dsp_deth <> 0 OR dsp_canc_deth <> 0
         OR dsp_ae_day_dsch <> 0 OR dsp_canc_ae_day_dsch <> 0
         OR dsp_ae_day_deth <> 0 OR dsp_canc_ae_day_deth <> 0
         OR dsp_remain <> 0 OR dsp_bdo <> 0 OR dsp_vac <> 0 OR dsp_ip_bed <> 0 OR dsp_exc <> 0 OR dsp_dp_bed <> 0
         OR dsp_dp_dsch <> 0 OR dsp_canc_dp_dsch <> 0
         OR dsp_dp_deth <> 0 OR dsp_canc_dp_deth <> 0;
    pas_return_code := 0;
RETURN;

END;
$procedure$
;


;ALTER PROCEDURE "hasp_get_spec_stat_cte" OWNER TO "HPI_SCHEMA_OWNER_ROLE";