-- DROP PROCEDURE hpi.cpi_search_payment_detail(inout int4, in varchar, in varchar, inout timestamp, inout timestamp, inout varchar, inout varchar, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout timestamp, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_search_payment_detail(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, INOUT par_admission_dtm timestamp without time zone, INOUT par_transaction_datetime timestamp without time zone, INOUT par_receipt_no character varying, INOUT par_pay_code character varying, INOUT par_payment_amount integer, INOUT par_no_charge_indicator character varying, INOUT par_payment_means character varying, INOUT par_waiver_no character varying, INOUT par_waiver_type character varying, INOUT par_waiver_issue_party character varying, INOUT par_waiver_eff_date timestamp without time zone, INOUT par_waiver_exp_date timestamp without time zone, INOUT par_paid_amount integer, INOUT par_update_by character varying, INOUT par_workstation_id character varying, INOUT par_source_system character varying, INOUT par_err_msg character varying, INOUT par_new_waiver_type character varying DEFAULT NULL::character varying, INOUT par_upd_sys character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rowcount INTEGER;
    var_error INTEGER;
    var_return_code INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO par_admission_dtm, par_transaction_datetime, par_pay_code, par_payment_amount, par_no_charge_indicator, par_payment_means, par_waiver_no, par_waiver_type, par_waiver_issue_party, par_waiver_eff_date, par_waiver_exp_date, par_paid_amount, par_update_by, par_workstation_id, par_source_system, par_err_msg, par_receipt_no, par_new_waiver_type, par_upd_sys;

        IF NOT EXISTS (SELECT
            *
            FROM cpi_case
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND status_code = 'AC') THEN
            BEGIN
                SELECT
                    -1, 'Case Number not found or cancelled'
                    INTO var_return_code, par_err_msg;
                RAISE exception '';
            END;
        END IF;
        SELECT
		admission_dtm, pay_code, transaction_datetime, payment_amount, no_charge_indicator, payment_means, waiver_no,
		waiver_type, waiver_issue_party, waiver_eff_date, waiver_exp_date, paid_amount, update_by, workstation_id, source_system, new_waiver_type, upd_sys, receipt_no
		into par_admission_dtm, par_pay_code,  par_transaction_datetime,par_payment_amount, par_no_charge_indicator, par_payment_means, par_waiver_no, 
		par_waiver_type, par_waiver_issue_party, par_waiver_eff_date, par_waiver_exp_date, par_paid_amount, par_update_by, par_workstation_id, par_source_system, par_new_waiver_type,par_upd_sys,par_receipt_no
		FROM cpi_payment_detail
		where hospital_code = par_hospital_code
		and case_no = par_case_no
		GROUP BY hospital_code, case_no,admission_dtm, pay_code, transaction_datetime, payment_amount, no_charge_indicator, payment_means, waiver_no,
		waiver_type, waiver_issue_party, waiver_eff_date, waiver_exp_date, paid_amount, update_by, workstation_id, source_system, new_waiver_type, upd_sys, receipt_no,transaction_type
		having transaction_datetime = max(transaction_datetime) AND transaction_type = 'P';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            SELECT
                -2, 'No Payment record found'
                INTO var_return_code, par_err_msg;
        ELSE
            SELECT
                0
                INTO var_return_code;
        END IF;
       RAISE exception '';
    END;
    exception when others then
    	begin
	    	pas_return_code := var_return_code;
    		RETURN;
	   	end;
END;
$procedure$
;
