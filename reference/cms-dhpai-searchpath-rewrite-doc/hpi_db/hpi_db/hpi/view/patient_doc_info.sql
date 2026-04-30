-- hpi.patient_doc_info source

CREATE OR REPLACE VIEW hpi.patient_doc_info with(security_invoker = on)
AS WITH combined_data AS (
         SELECT patient_doc_info_hkpmi.patient_key,
            patient_doc_info_hkpmi.doc_code,
            patient_doc_info_hkpmi.doc_no,
            patient_doc_info_hkpmi.upd_by,
            patient_doc_info_hkpmi.upd_hosp,
            patient_doc_info_hkpmi.upd_sys,
            patient_doc_info_hkpmi.upd_dtm
           FROM hkpmi.patient_doc_info_hkpmi
        UNION ALL
         SELECT patient_doc_info_op.patient_key,
            patient_doc_info_op.doc_code,
            patient_doc_info_op.doc_no,
            patient_doc_info_op.upd_by,
            patient_doc_info_op.upd_hosp,
            patient_doc_info_op.upd_sys,
            patient_doc_info_op.upd_dtm
           FROM hpi.patient_doc_info_op
        ), ranked_data AS (
         SELECT combined_data.patient_key,
            combined_data.doc_code,
            combined_data.doc_no,
            combined_data.upd_by,
            combined_data.upd_hosp,
            combined_data.upd_sys,
            combined_data.upd_dtm,
            row_number() OVER (PARTITION BY combined_data.patient_key ORDER BY combined_data.upd_dtm DESC NULLS LAST) AS rn
           FROM combined_data
        )
 SELECT patient_key,
    doc_code,
    doc_no,
    upd_by,
    upd_hosp,
    upd_sys,
    upd_dtm
   FROM ranked_data
  WHERE rn = 1;



ALTER TABLE patient_doc_info OWNER TO "HPI_SCHEMA_OWNER_ROLE";