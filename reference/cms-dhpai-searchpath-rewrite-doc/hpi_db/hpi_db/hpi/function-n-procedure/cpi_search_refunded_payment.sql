-- DROP PROCEDURE hpi.cpi_search_refunded_payment(inout int4, in varchar, in varchar, in varchar, inout varchar, inout varchar, inout timestamp);

CREATE OR REPLACE PROCEDURE hpi.cpi_search_refunded_payment(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_receipt_no character varying, INOUT par_status character varying, INOUT par_err_msg character varying, INOUT par_transaction_datetime timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rowcount INTEGER;
    var_error INTEGER;
    var_return_code INTEGER;
    var_discharge_code VARCHAR(1);
    var_discharge_desc VARCHAR(5);
    var_transaction_type VARCHAR(1);
    var_no_charge_indicator VARCHAR(5);
    var_source_system VARCHAR(8);
    var_paid_amount INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO par_status, par_err_msg, var_discharge_code, par_transaction_datetime, var_transaction_type, var_no_charge_indicator, var_source_system;
        /* Get Case detail */
        SELECT
            discharge_code
            INTO var_discharge_code
            FROM cpi_case
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND status_code = 'AC';
        /* Check case no. exist */
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            BEGIN
                SELECT
                    - 1, 'N', 'Case number not found or cancelled'
                    INTO var_return_code, par_status, par_err_msg;
                raise exception '';
            END;
        END IF;
        /* return if case discharged without 'M' */
        /* 'M' = Walk away/A&E Refund */
        IF var_discharge_code IS NOT NULL AND var_discharge_code <> 'M' THEN
            BEGIN
                SELECT
                    RTRIM(short_description)
                    INTO var_discharge_desc
                    FROM discharge_type
                    WHERE discharge_code = var_discharge_code;
                SELECT
                    - 1, 'N', CONCAT('Case already discharged with discharge code ', var_discharge_code, ' (', var_discharge_desc, ')')
                    INTO var_return_code, par_status, par_err_msg;
                raise exception '';
            END;
        END IF;
        /* Select the last payment transaction */
        /* Search by Case Number */
        IF (par_receipt_no IS NULL) THEN
            BEGIN
                SELECT
                    transaction_type, no_charge_indicator, transaction_datetime, source_system, paid_amount
                    INTO var_transaction_type, var_no_charge_indicator, par_transaction_datetime, var_source_system, var_paid_amount
                    FROM (SELECT
                        transaction_type, no_charge_indicator, transaction_datetime, source_system, paid_amount, hospital_code, case_no
                        FROM cpi_payment_detail) AS ungrouped_query
                    INNER JOIN (SELECT
                        hospital_code, case_no, MAX(transaction_datetime) AS max_1
                        FROM cpi_payment_detail
                        WHERE hospital_code = par_hospital_code AND case_no = par_case_no
                        GROUP BY hospital_code, case_no) AS grouped_query
                        ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
                    WHERE transaction_datetime = max_1;
            END;
        ELSE
            /* Search by Case Number & Receipt Number */
            BEGIN
                SELECT
                    transaction_type, no_charge_indicator, transaction_datetime, source_system, paid_amount
                    INTO var_transaction_type, var_no_charge_indicator, par_transaction_datetime, var_source_system, var_paid_amount
                    FROM (SELECT
                        transaction_type, no_charge_indicator, transaction_datetime, source_system, paid_amount, hospital_code, case_no
                        FROM cpi_payment_detail) AS ungrouped_query
                    INNER JOIN (SELECT
                        hospital_code, case_no, MAX(transaction_datetime) AS max_1
                        FROM cpi_payment_detail
                        WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND receipt_no = par_receipt_no
                        GROUP BY hospital_code, case_no) AS grouped_query
                        ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
                    WHERE transaction_datetime = max_1;
            END;
        END IF;
        /*
        [3047 - Severity CRITICAL - Migration @@rowcount function in current context is not supported. Perform a manual conversion.]
        if @@rowcount = 0
        	begin
        		select @return_code = -1,
        			@status = 'N',
        			@err_msg = 'Receipt number not found'
        		goto return_error
        	end
        	else
        	begin
        		/*Txn updated by PBRC*/
        		if @source_system not in ('ADT')
        		begin
        			select @return_code = 0,
        				@status = 'N',
        				@err_msg = 'The payment has been made in PBRC system. No cancellation can be performed'
        			goto return_error
        		end
        
        		/*Cancelled payment txn*/
        		if @transaction_type = 'C'
        		begin
        			select @return_code = 0,
        				@status = 'C',
        				@err_msg = 'The payment transaction has been cancelled'
        			goto return_error
        		end
        
        		if @transaction_type = 'P'
        		begin
        			/*Refunded payment transaction*/
        			if @no_charge_indicator = 'RR'
        			begin
        				select @return_code = 0,
        					@status = 'R',
        					@err_msg = 'The case has been refunded'
        				goto return_error
        			end
        			else
        			begin
        				if @discharge_code is not null
        				begin
        
        					select @discharge_desc = RTRIM(short_description) from discharge_type
        					where discharge_code = @discharge_code
        
        					select @return_code = -1,
        					@status = 'N',
        					@err_msg = 'Case already discharged with discharge code ' + @discharge_code + ' (' + @discharge_desc + ')'
        					goto return_error
        				end
        
        				/* Paid amount is 0*/
        				if (@paid_amount = 0)
        				begin
        					select @return_code = 0,
        						@status = 'N',
        						@err_msg = 'The paid amount is $0.00'
        					goto return_error
        				end
        
        				/*Not Yet Refunded*/
        				if (@no_charge_indicator is null or @no_charge_indicator = '')
        				begin
        					select @return_code = 0,
        						@status = 'Y',
        						@err_msg = 'Refunded payment transaction not found'
        					goto return_error
        				end
        				else
        				begin
        					/*Already marked with No Charge*/
        					select @return_code = 0,
        						@status = 'N',
        						@err_msg = 'The case is already marked with no charge'
        					goto return_error
        				end
        			end
        		end
        		else
        		begin
        			select @return_code = 0,
        				@status = 'N',
        				@err_msg = 'The last payment transaction is not type P or C'
        			goto return_error
        
        		end
        	end
        */
        raise exception '';
    END;
    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "cpi_search_refunded_payment" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
