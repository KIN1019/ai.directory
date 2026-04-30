-- hpi.major_key_changed source

CREATE OR REPLACE VIEW hpi.major_key_changed with(security_invoker = on)
AS SELECT patient_key AS t_prk,
    patient_key AS hkid,
    original_hkid,
    update_dtm AS system_datetime,
    patient_name AS old_name,
    cccode1 AS old_ccc_1,
    cccode2 AS old_ccc_2,
    cccode3 AS old_ccc_3,
    cccode4 AS old_ccc_4,
    cccode5 AS old_ccc_5,
    cccode6 AS old_ccc_6,
    sex AS old_sex,
    dob AS old_dob,
    hkid AS old_hkid,
    update_hospital AS hospital_code,
    update_by AS user_id
   FROM hpi.cpi_patient_key_changed m;






ALTER TABLE major_key_changed OWNER TO "HPI_SCHEMA_OWNER_ROLE";
