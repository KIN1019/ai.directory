-- hpi.nok source

CREATE OR REPLACE VIEW hpi.nok with(security_invoker = on)
AS SELECT p.hkid,
    n.nok_name AS name,
    n.hkid AS nok_hkid,
    n.building,
    n.room,
    n.floor,
    n.block,
    n.district AS district_code,
    n.phone1 AS home_phone_no,
    n.phone2 AS other_phone_no_1,
    n.address_indicator AS other_phone_ext_1,
    n.mobile_phone AS other_phone_no_2,
    n.sms_language AS other_phone_ext_2,
    n.relationship AS nok_relation_code,
    n.priority,
    n.major_nok
   FROM hpi.cpi_patient p,
    hpi.cpi_nok n
  WHERE n.patient_key::text = p.patient_key::text;




ALTER TABLE nok OWNER TO "HPI_SCHEMA_OWNER_ROLE";
