-- hpi.race_view source

-- Sybase counterpart is "Race"

CREATE OR REPLACE VIEW hpi.race_view with(security_invoker = on)
AS SELECT race_code,
    race_description
   FROM hpi.race r;






ALTER TABLE race_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
