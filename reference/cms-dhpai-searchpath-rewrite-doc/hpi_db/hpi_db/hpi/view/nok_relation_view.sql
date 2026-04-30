-- hpi.nok_relation_view source

-- Sybase counterpart is "NOK_relation"

CREATE OR REPLACE VIEW hpi.nok_relation_view with(security_invoker = on)
AS SELECT nok_relation_code,
    description
   FROM hpi.nok_relation n;






ALTER TABLE nok_relation_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
