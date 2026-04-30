-- hpi.cpi_ward_list source

CREATE OR REPLACE VIEW hpi.cpi_ward_list with(security_invoker = on)
AS SELECT hospital_code,
    case_no,
    ward_code,
    bed_no,
    specialty_code
   FROM hpi.ward_list;






ALTER TABLE cpi_ward_list OWNER TO "HPI_SCHEMA_OWNER_ROLE";
