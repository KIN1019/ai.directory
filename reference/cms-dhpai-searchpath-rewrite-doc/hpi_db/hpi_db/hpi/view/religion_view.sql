-- hpi.religion_view source

-- Sybase counterpart is "Religion"

CREATE OR REPLACE VIEW hpi.religion_view with(security_invoker = on)
AS SELECT religion_code,
    religion_description
   FROM hpi.religion r;






ALTER TABLE religion_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
