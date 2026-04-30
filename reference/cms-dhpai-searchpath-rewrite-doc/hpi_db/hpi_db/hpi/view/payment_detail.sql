-- hpi.payment_detail source

CREATE OR REPLACE VIEW hpi.payment_detail with(security_invoker = on)
AS SELECT transaction_datetime,
    hospital_code,
    case_no,
    case_type,
    receipt_no,
    admission_dtm,
    pay_code,
    payment_means,
    waiver_no,
    waiver_type,
    waiver_issue_party,
    waiver_eff_date,
    waiver_exp_date,
    no_charge_indicator,
    payment_amount,
    paid_amount,
    transaction_type,
    remark,
    update_by,
    workstation_id,
    source_system,
    nep_search_key,
    nep_add_key_1,
    nep_add_key_2,
    new_waiver_type,
    upd_sys
   FROM hpi.cpi_payment_detail;






ALTER TABLE payment_detail OWNER TO "HPI_SCHEMA_OWNER_ROLE";
