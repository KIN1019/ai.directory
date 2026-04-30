-- hpi.payment source

CREATE OR REPLACE VIEW hpi.payment with(security_invoker = on)
AS SELECT patient_type AS pay_code,
    description,
    effective_dtm,
    patient_group,
    pay_code_type,
    active_status,
    user_define
   FROM hpi.patient_type p;






ALTER TABLE payment OWNER TO "HPI_SCHEMA_OWNER_ROLE";
