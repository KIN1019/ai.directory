-- hpi.pmi_wo_mrn source

CREATE OR REPLACE VIEW hpi.pmi_wo_mrn with(security_invoker = on)
AS SELECT hkid,
    religion AS religion_code,
    patient_name AS name,
    repeat(' '::text, 4) AS name_soundex,
    repeat(' '::text, 48) AS name_phonetic,
    sex,
    cccode1 AS ccc_1,
    cccode2 AS ccc_2,
    cccode3 AS ccc_3,
    cccode4 AS ccc_4,
    cccode5 AS ccc_5,
    cccode6 AS ccc_6,
    dob,
    exact_dob_flag,
    marital_status,
    race AS race_code,
    other_doc_no AS other_document_no,
    building,
    room,
    floor,
    block,
    district AS district_code,
    phone1,
    phone2,
    address_indicator,
    mobile_phone,
    sms_language,
    death_indicator,
    patient_key AS t_prk,
    death_date,
    access_code,
    update_dtm AS system_datetime,
    update_by AS user_id,
    update_hospital AS hospital_code,
    repeat(' '::text, 4) AS terminal_id,
    row_update_datetime,
    body_category
   FROM hpi.cpi_patient p;






ALTER TABLE pmi_wo_mrn OWNER TO "HPI_SCHEMA_OWNER_ROLE";
