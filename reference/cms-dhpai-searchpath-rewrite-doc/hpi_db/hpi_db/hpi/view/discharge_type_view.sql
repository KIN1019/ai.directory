-- hpi.discharge_type_view source

-- Sybase counterpart is "Discharge_type"

CREATE OR REPLACE VIEW hpi.discharge_type_view with(security_invoker = on)
AS SELECT discharge_code,
    description,
    short_description
   FROM hpi.discharge_type d;






ALTER TABLE discharge_type_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
