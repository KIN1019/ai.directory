CREATE OR REPLACE PROCEDURE cpi_update_octopus_transaction(INOUT pas_return_code INTEGER,IN par_hospital_code VARCHAR, IN par_case_no VARCHAR, IN par_paid_amount INTEGER, IN par_remain_balance NUMERIC, IN par_term_id VARCHAR, IN par_card_no VARCHAR, IN par_update_by VARCHAR, IN par_workstation_id VARCHAR, IN par_usage_data VARCHAR, IN par_transaction_status VARCHAR, IN par_error_code INTEGER, IN par_transaction_datetime TIMESTAMP WITHOUT TIME ZONE, IN par_octopus_type INTEGER DEFAULT null, IN par_last_add_value_type VARCHAR DEFAULT null, IN par_last_add_value_date TIMESTAMP WITHOUT TIME ZONE DEFAULT null, IN par_last_add_value_device_id VARCHAR DEFAULT null)
AS
$BODY$
DECLARE
    var_return_code INTEGER;
    var_success_flag VARCHAR(1);
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            0, 'Y'
            INTO var_return_code, var_success_flag;
       
        IF EXISTS (SELECT
            *
            FROM cpi_octopus_transaction
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND transaction_datetime = par_transaction_datetime AND transaction_status = 'N') THEN
            BEGIN
                BEGIN
                    UPDATE cpi_octopus_transaction
                    SET term_id = par_term_id, card_no = par_card_no, paid_amount = par_paid_amount, remain_balance = par_remain_balance, update_by = par_update_by, workstation_id = par_workstation_id, usage_data = par_usage_data, transaction_status = par_transaction_status, error_code = par_error_code, octopus_type = par_octopus_type, last_add_value_type = par_last_add_value_type, last_add_value_date = par_last_add_value_date, last_add_value_device_id = par_last_add_value_device_id
                        WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND transaction_datetime = par_transaction_datetime;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF (sql$rowcount = 0) THEN
                        BEGIN
                            SELECT
                                200044
                                INTO var_return_code;
                            SELECT
                                'N'
                                INTO var_success_flag;
                            raise exception '';
                        END;
                    END IF;
                END;
            END;
        ELSE
            BEGIN
                SELECT
                    200045
                    INTO var_return_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
    END;

	exception when others then
		raise notice 'rollback transaction';

    pas_return_code := var_return_code;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;

;ALTER PROCEDURE "cpi_update_octopus_transaction" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
