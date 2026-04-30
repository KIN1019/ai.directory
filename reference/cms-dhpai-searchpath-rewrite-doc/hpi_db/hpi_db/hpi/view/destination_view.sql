-- hpi.destination_view source

-- Sybase counterpart is "Destination"

CREATE OR REPLACE VIEW hpi.destination_view with(security_invoker = on)
AS SELECT destination_code,
    description
   FROM hpi.destination d;






ALTER TABLE destination_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
