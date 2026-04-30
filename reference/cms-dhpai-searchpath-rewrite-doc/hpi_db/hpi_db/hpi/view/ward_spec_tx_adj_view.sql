-- hpi.ward_spec_tx_adj_view source

CREATE OR REPLACE VIEW hpi.ward_spec_tx_adj_view with(security_invoker = on)
AS SELECT a.hospital_code,
    a.ward_spec_tx_date,
    a.ward_code,
    a.specialty_code,
    a.treatment_location,
    a.previous_remaining,
    a.admission,
    a.discharge,
    a.transfer_in,
    a.transfer_out,
    a.death,
    a.day_discharge,
    a.day_death,
    a.admission_thru_ae,
    a.transfer_in_from_td,
    a.transfer_out_to_td,
    a.ae_day_discharge,
    a.ae_day_death,
    a.transfer_within_specialty,
    a.transfer_within_ward,
    b.canc_admission,
    b.canc_discharge,
    b.canc_transfer_in,
    b.canc_transfer_out,
    b.canc_death,
    b.canc_day_discharge,
    b.canc_day_death,
    b.canc_admission_thru_ae,
    b.canc_transfer_in_from_td,
    b.canc_transfer_out_to_td,
    b.canc_ae_day_discharge,
    b.canc_ae_day_death,
    b.canc_transfer_within_specialty,
    b.canc_transfer_within_ward
   FROM hpi.ward_spec_tx a
     LEFT JOIN hpi.ward_spec_adj b ON a.ward_code::text = b.ward_code::text AND a.ward_spec_tx_date = b.ward_spec_adj_date AND a.specialty_code::text = b.specialty_code::text AND COALESCE(a.treatment_location, 'null'::bpchar::character varying)::text = COALESCE(b.treatment_location, 'null'::bpchar::character varying)::text AND a.hospital_code::text = b.hospital_code::text;






ALTER TABLE ward_spec_tx_adj_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
