-- hpi.octopus_transaction source

CREATE OR REPLACE VIEW hpi.octopus_transaction with(security_invoker = on)
AS SELECT hospital_code,
    case_no,
    transaction_datetime,
    term_id,
    card_no,
    paid_amount,
    remain_balance,
    update_by,
    workstation_id,
    usage_data,
    transaction_status,
    error_code
   FROM hpi.cpi_octopus_transaction;






ALTER TABLE octopus_transaction OWNER TO "HPI_SCHEMA_OWNER_ROLE";
