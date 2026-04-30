-- hpi.pas_ci_active_user_table_view source

CREATE OR REPLACE VIEW hpi.pas_ci_active_user_table_view with(security_invoker = on)
AS SELECT 'USER_INFO'::text AS pas_ci_type,
    900000 AS pas_ci_id,
    'IPAS'::text AS ci_prj,
    '20181001'::text AS ci_eff_dtm,
    'A'::text AS ci_status,
    u.hospital_code AS ci_institute,
    u.user_id AS ci_user_id,
    u.hkid AS ci_user_hkid,
    u.name AS ci_user_name,
    u.department AS ci_user_dept,
    u.rank_code AS ci_user_rank_code,
    u.effective_date AS ci_user_effective_date,
    u.expiration_date AS ci_user_expiry_date,
    u.user_title AS ci_user_title,
    u.group_id AS ci_user_gp,
    g.group_description AS ci_user_gp_desc,
    LOCALTIMESTAMP AS ci_crt_dtm,
    'pas_adm_job'::text AS ci_upd_by,
    LOCALTIMESTAMP AS ci_upd_dtm,
    NULL::text AS ci_remark
   FROM hpi.user_profile u,
    hpi.user_group g
  WHERE COALESCE(u.expiration_date, '2099-01-01 00:00:00'::timestamp without time zone) > LOCALTIMESTAMP AND u.user_id::text !~~ '@%'::text AND u.user_id::text <> 'SIS'::text AND u.group_id::text = g.group_id::text;




ALTER TABLE pas_ci_active_user_table_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
