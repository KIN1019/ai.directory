-- hpi.case_key_changed source

CREATE OR REPLACE VIEW hpi.case_key_changed with(security_invoker = on)
AS SELECT hospital_code,
    case_no,
    update_dtm AS system_datetime,
    hkid AS old_hkid,
    update_by AS user_id
   FROM hpi.cpi_case_key_changed c;






ALTER TABLE case_key_changed OWNER TO "HPI_SCHEMA_OWNER_ROLE";
