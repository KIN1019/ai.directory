CREATE OR REPLACE PROCEDURE web_hasp_octopus_transaction(INOUT pas_return_code INTEGER,IN par_hospital_code VARCHAR, IN par_case_no VARCHAR, IN par_paid_amount INTEGER, IN par_remain_balance NUMERIC, IN par_term_id VARCHAR, INOUT par_card_no VARCHAR, IN par_update_by VARCHAR, IN par_workstation_id VARCHAR, IN par_usage_data VARCHAR, IN par_transaction_type VARCHAR, IN par_transaction_status VARCHAR, IN par_error_code INTEGER, INOUT par_transaction_datetime TIMESTAMP WITHOUT TIME ZONE, INOUT par_receipt_no VARCHAR, INOUT par_return_code INTEGER, INOUT "par_receiptNoAscii1" INTEGER, INOUT "par_receiptNoAscii2" INTEGER, IN par_octopus_type INTEGER DEFAULT null, IN par_last_add_value_type VARCHAR DEFAULT null, IN par_last_add_value_date TIMESTAMP WITHOUT TIME ZONE DEFAULT null, IN par_last_add_value_device_id VARCHAR DEFAULT null)
AS 
$BODY$
BEGIN
    IF par_transaction_type = 'I' THEN
        CALL web_cpi_insert_octopus_tran(par_return_code,par_hospital_code, par_case_no, par_paid_amount, par_term_id, par_card_no, par_update_by, par_workstation_id, par_usage_data, par_transaction_datetime, par_receipt_no, "par_receiptNoAscii1", "par_receiptNoAscii2");
    ELSE
        CALL cpi_update_octopus_transaction(par_return_code,par_hospital_code, par_case_no, par_paid_amount, par_remain_balance, par_term_id, par_card_no, par_update_by, par_workstation_id, par_usage_data, par_transaction_status, par_error_code, par_transaction_datetime, par_octopus_type, par_last_add_value_type, par_last_add_value_date, par_last_add_value_device_id);
    END IF;

    pas_return_code := par_return_code;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;


;ALTER PROCEDURE "web_hasp_octopus_transaction" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
