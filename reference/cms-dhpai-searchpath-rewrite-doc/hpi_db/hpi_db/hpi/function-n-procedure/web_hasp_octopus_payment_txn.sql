CREATE OR REPLACE PROCEDURE web_hasp_octopus_payment_txn(INOUT pas_return_code INTEGER,IN par_hospital_code CHAR, IN par_case_no CHAR, IN par_paid_amount INTEGER, IN par_remain_balance NUMERIC, IN par_term_id CHAR, INOUT par_card_no CHAR, IN par_update_by CHAR, IN par_workstation_id CHAR, IN par_usage_data CHAR, IN par_transaction_type CHAR, IN par_transaction_status CHAR, IN par_error_code INTEGER, INOUT par_transaction_datetime TIMESTAMP WITHOUT TIME ZONE, INOUT par_receipt_no CHAR, INOUT par_return_code INTEGER, INOUT par_receiptNoAscii1 INTEGER, INOUT par_receiptNoAscii2 INTEGER, IN par_octopus_type INTEGER DEFAULT null, IN par_last_add_value_type CHAR DEFAULT null, IN par_last_add_value_date TIMESTAMP WITHOUT TIME ZONE DEFAULT null, IN par_last_add_value_device_id VARCHAR DEFAULT null)
AS 
$BODY$
DECLARE
    var_trancount INTEGER;
BEGIN
	<<point_a>>
	BEGIN
			/* --End - jConnect 7 upgrade */
		IF par_transaction_type = 'I' THEN
			CALL web_cpi_insert_octopus_tran(par_return_code,par_hospital_code, par_case_no, par_paid_amount, par_term_id, par_card_no, par_update_by, par_workstation_id, par_usage_data, par_transaction_datetime, par_receipt_no, par_receiptNoAscii1, par_receiptNoAscii2);
		ELSE
			CALL cpi_update_octopus_transaction(par_return_code,par_hospital_code, par_case_no, par_paid_amount, par_remain_balance, par_term_id, par_card_no, par_update_by, par_workstation_id, par_usage_data, par_transaction_status, par_error_code, par_transaction_datetime, par_octopus_type, par_last_add_value_type, par_last_add_value_date, par_last_add_value_device_id);
		END IF;
		IF (par_return_code = 0) THEN
			exit point_a;
		else
			raise exception '';
		end if;
		exception when others then
			raise notice 'rollback transaction';
	end;	
	pas_return_code := par_return_code;
    RETURN;

END;
/* ### DEFNCOPY: END OF DEFINITION */
$BODY$
LANGUAGE plpgsql;


;ALTER PROCEDURE "web_hasp_octopus_payment_txn" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
