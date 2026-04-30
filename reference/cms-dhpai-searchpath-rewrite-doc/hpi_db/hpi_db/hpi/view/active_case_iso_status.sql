-- hpi.active_case_iso_status source

CREATE OR REPLACE VIEW hpi.active_case_iso_status with(security_invoker = on)
AS SELECT active_case.hospital_code,
    active_case.case_no,
    i.movement_count,
    i.iso_status,
    i.update_datetime,
    i.update_by
   FROM ( SELECT w.hospital_code,
            w.case_no,
            c.movement_count
           FROM hpi.cpi_ward_list w,
            hpi.cpi_case c
          WHERE w.case_no::text ~ similar_to_escape(' HN%'::text) AND (w.ward_code::bpchar <> ALL (ARRAY['HOME'::bpchar, 'AE01'::bpchar])) AND (w.specialty_code::bpchar <> ALL (ARRAY['HOME'::bpchar, 'A&E'::bpchar])) AND c.hospital_code::text = w.hospital_code::text AND c.case_no::text = w.case_no::text) active_case,
    hpi.isolation_case i
  WHERE i.hospital_code::text = active_case.hospital_code::text AND i.case_no::text = active_case.case_no::text AND i.movement_count = (( SELECT max(i_1.movement_count) AS max
           FROM hpi.isolation_case i_1
          WHERE i_1.hospital_code::text = active_case.hospital_code::text AND i_1.case_no::text = active_case.case_no::text
          GROUP BY i_1.hospital_code, i_1.case_no)) AND i.movement_count = active_case.movement_count;


ALTER TABLE active_case_iso_status OWNER TO "HPI_SCHEMA_OWNER_ROLE";
