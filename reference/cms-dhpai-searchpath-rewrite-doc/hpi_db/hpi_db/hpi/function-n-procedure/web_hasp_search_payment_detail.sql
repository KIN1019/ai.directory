-- DROP PROCEDURE hpi.web_hasp_search_payment_detail(inout int4, in varchar, in varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout timestamp, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout timestamp, inout varchar, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_search_payment_detail(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_case_no character varying, INOUT par_hkid character varying, INOUT par_patient_name character varying, INOUT par_chi_name character varying, INOUT par_sex character varying, INOUT par_dob timestamp without time zone, INOUT par_exact_dob_flag character varying, INOUT par_pay_code character varying, INOUT par_adm_dtm timestamp without time zone, INOUT par_payment_amount integer, INOUT par_payment_means character varying, INOUT par_waiver_no character varying, INOUT par_waiver_type character varying, INOUT par_waiver_issue_party character varying, INOUT par_waiver_eff_date timestamp without time zone, INOUT par_waiver_exp_date timestamp without time zone, INOUT par_no_charge_indicator character varying, INOUT par_paid_amount integer, INOUT par_transaction_type character varying, INOUT par_remark character varying, INOUT par_receipt_no character varying, INOUT par_card_id character varying, INOUT par_octopus_system_dtm timestamp without time zone, INOUT par_device_id character varying, INOUT par_schi_name character varying DEFAULT 'N'::bpchar, INOUT par_nep_search_key character varying DEFAULT NULL::bpchar, INOUT par_nep_add_key_1 character varying DEFAULT NULL::bpchar, INOUT par_nep_add_key_2 character varying DEFAULT NULL::bpchar, INOUT par_new_waiver_type character varying DEFAULT NULL::bpchar, INOUT par_upd_sys character varying DEFAULT NULL::bpchar, INOUT par_return_code integer DEFAULT NULL::integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE

BEGIN
    CALL hasp_search_payment_detail(par_return_code, par_hosp_code, par_case_no, par_hkid, par_patient_name, par_chi_name, par_sex, par_dob, par_exact_dob_flag, par_pay_code, par_adm_dtm, par_payment_amount, par_payment_means, par_waiver_no, par_waiver_type, par_waiver_issue_party, par_waiver_eff_date, par_waiver_exp_date, par_no_charge_indicator, par_paid_amount, par_transaction_type, par_remark, par_receipt_no, par_card_id, par_octopus_system_dtm, par_device_id, par_schi_name, par_nep_search_key, par_nep_add_key_1, par_nep_add_key_2, par_new_waiver_type, par_upd_sys);
    select par_return_code into pas_return_code;

END;
$procedure$
;


;ALTER PROCEDURE "web_hasp_search_payment_detail" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
