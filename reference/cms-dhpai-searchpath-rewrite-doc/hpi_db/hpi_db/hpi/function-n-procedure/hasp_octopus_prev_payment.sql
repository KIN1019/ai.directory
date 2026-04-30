CREATE OR REPLACE PROCEDURE hpi.hasp_octopus_prev_payment(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, INOUT par_prev_octopus_payment character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    IF EXISTS (SELECT
        *
        FROM payment_detail
        WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND transaction_type = 'P' AND payment_means = 'OC') THEN
        SELECT
            'Y'
            INTO par_prev_octopus_payment;
    ELSE
        SELECT
            'N'
            INTO par_prev_octopus_payment;
    END IF;
   pas_return_code := 0;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_octopus_prev_payment" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
