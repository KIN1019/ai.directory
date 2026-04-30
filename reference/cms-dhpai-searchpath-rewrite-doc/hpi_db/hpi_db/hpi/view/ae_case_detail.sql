-- hpi.ae_case_detail source

CREATE OR REPLACE VIEW hpi.ae_case_detail with(security_invoker = on)
AS SELECT hospital_code,
    case_no,
    ambulance_no,
    police_case,
    labour_case_flag,
    ae_case_type,
    dba_flag,
    follow_up_datetime,
    eh_code,
    pp_code
   FROM hpi.cpi_ae_case_detail a;






ALTER TABLE ae_case_detail OWNER TO "HPI_SCHEMA_OWNER_ROLE";
