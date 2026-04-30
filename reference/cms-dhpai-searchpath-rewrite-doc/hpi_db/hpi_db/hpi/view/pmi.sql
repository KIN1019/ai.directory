-- hpi.pmi source

CREATE OR REPLACE VIEW hpi.pmi with(security_invoker = on)
AS SELECT h.hospital_code AS pmi_hospital_code,
    p.hkid,
    p.religion AS religion_code,
    p.patient_name AS name,
    repeat(' '::text, 4) AS name_soundex,
    repeat(' '::text, 48) AS name_phonetic,
    p.sex,
    p.cccode1 AS ccc_1,
    p.cccode2 AS ccc_2,
    p.cccode3 AS ccc_3,
    p.cccode4 AS ccc_4,
    p.cccode5 AS ccc_5,
    p.cccode6 AS ccc_6,
    p.dob,
    p.exact_dob_flag,
    p.marital_status,
    p.race AS race_code,
    p.other_doc_no AS other_document_no,
    h.mrn AS medical_record_number,
    p.building,
    p.room,
    p.floor,
    p.block,
    p.district AS district_code,
    p.phone1,
    p.phone2,
    p.address_indicator,
    p.mobile_phone,
    p.sms_language,
    p.death_indicator,
    p.patient_key AS t_prk,
    p.death_date,
    p.access_code,
    p.update_dtm AS system_datetime,
    p.update_by AS user_id,
    p.update_hospital AS hospital_code,
    repeat(' '::text, 4) AS terminal_id,
    p.row_update_datetime,
    p.body_category
   FROM hpi.cpi_patient p,
    hpi.cpi_patient_hospital_data h
  WHERE p.patient_key::text = h.patient_key::text;






ALTER TABLE pmi OWNER TO "HPI_SCHEMA_OWNER_ROLE";
