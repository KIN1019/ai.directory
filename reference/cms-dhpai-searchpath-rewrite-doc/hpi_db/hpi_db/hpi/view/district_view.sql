-- hpi.district_view source

-- Sybase counterpart is "District"

CREATE OR REPLACE VIEW hpi.district_view with(security_invoker = on)
AS SELECT district_code,
    district_name,
    district_board,
    district_area,
    district_chi,
    district_board_chi
   FROM hpi.district d;






ALTER TABLE district_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
