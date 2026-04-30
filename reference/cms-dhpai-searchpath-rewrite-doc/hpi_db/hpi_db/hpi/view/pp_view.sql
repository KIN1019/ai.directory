-- hpi.pp_view source

-- Sybase counterpart is "PP"

CREATE OR REPLACE VIEW hpi.pp_view with(security_invoker = on)
AS SELECT pp_code,
    pp_name,
    room,
    floor,
    block,
    building,
    district_code,
    phone,
    fax_no,
    email_address,
    remarks,
    hkma_code,
    expiry_date,
    last_name,
    first_name,
    chinese_name,
    address_1,
    address_2,
    address_3,
    address_4,
    chinese_address,
    office_phone
   FROM hpi.pp p;






ALTER TABLE pp_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
