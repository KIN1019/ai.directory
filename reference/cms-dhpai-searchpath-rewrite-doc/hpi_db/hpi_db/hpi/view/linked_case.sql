-- hpi.linked_case source

CREATE OR REPLACE VIEW hpi.linked_case with(security_invoker = on)
AS SELECT hospital_code,
    case_no,
    previous_hospital,
    previous_case,
    create_by,
    create_dtm,
    update_by,
    update_dtm
   FROM hpi.cpi_linked_case;






ALTER TABLE linked_case OWNER TO "HPI_SCHEMA_OWNER_ROLE";
