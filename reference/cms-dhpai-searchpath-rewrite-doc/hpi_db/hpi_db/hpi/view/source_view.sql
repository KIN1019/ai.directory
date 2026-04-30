-- hpi.source_view source

-- Sybase counterpart is "Source"

CREATE OR REPLACE VIEW hpi.source_view with(security_invoker = on)
AS SELECT source_indicator,
    description
   FROM hpi.source s;






ALTER TABLE source_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
