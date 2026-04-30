-- DROP PROCEDURE hpi_apj.cpi_insert_payment_detail(inout int4, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, in int4, in varchar, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout timestamp, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_insert_payment_detail(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_hkid character varying, IN par_case_no character varying, IN par_adm_dtm timestamp without time zone, IN par_pay_code character varying, IN par_payment_amount integer, IN par_paid_amount integer, IN par_no_charge_ind character varying, IN par_payment_means character varying, IN par_waiver_no character varying, IN par_waiver_eff_date timestamp without time zone, IN par_waiver_exp_date timestamp without time zone, IN par_waiver_type character varying, IN par_waiver_issue_party character varying, IN par_remark character varying, IN par_user_id character varying, IN par_term_id character varying, IN par_transaction_type character varying, IN par_receipt_no character varying, IN par_src_system character varying, INOUT par_transaction_datetime timestamp without time zone, IN par_nep_search_key character varying DEFAULT NULL::character varying, IN par_nep_add_key_1 character varying DEFAULT NULL::character varying, IN par_nep_add_key_2 character varying DEFAULT NULL::character varying, IN par_new_waiver_type character varying DEFAULT NULL::character varying, IN par_upd_sys character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_return_code INTEGER;
    var_success_flag VARCHAR(1);
    var_prk VARCHAR(8);
    var_valid_flag VARCHAR(1);
    var_case_type VARCHAR(1);
    var_prev_type VARCHAR(1);
	sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            0, 'Y'
            INTO var_return_code, var_success_flag;

        IF NOT EXISTS (SELECT
            *
            FROM hospital
            WHERE hospital_code = par_hosp_code) THEN
            BEGIN
                SELECT
                    200002
                    INTO var_return_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* Invalid Source System */
        IF par_src_system NOT IN ('ADT', 'PBRC') THEN
            BEGIN
                SELECT
                    200037
                    INTO var_return_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* Invalid Transaction Type */
        IF par_src_system = 'ADT' THEN
            BEGIN
                IF par_transaction_type NOT IN ('P', 'R', 'C', 'E') THEN
                    BEGIN
                        SELECT
                            200038
                            INTO var_return_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                IF par_transaction_type NOT IN ('P', 'C') THEN
                    BEGIN
                        SELECT
                            200038
                            INTO var_return_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* Validation for Payment and Cancal Payment */
        IF par_transaction_type IN ('P', 'C') THEN
            BEGIN
                CALL cpi_pq_validate_hkid(var_return_code, par_hkid, var_valid_flag);

                IF var_valid_flag = 'N' OR var_return_code <> 0 THEN
                    BEGIN
                        SELECT
                            200005
                            INTO var_return_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
                CALL cpi_pq_validate_caseno(var_return_code, par_case_no, par_hosp_code, var_valid_flag);

                IF var_valid_flag = 'N' OR var_return_code <> 0 THEN
                    BEGIN
                        SELECT
                            200004
                            INTO var_return_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
                /* HKID not exist */
                IF NOT EXISTS (SELECT
                    *
                    FROM cpi_patient
                    WHERE hkid = par_hkid) THEN
                    BEGIN
                        SELECT
                            200032
                            INTO var_return_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                ELSE
                    SELECT
                        patient_key
                        INTO var_prk
                        FROM cpi_patient
                        WHERE hkid = par_hkid;
                END IF;
                /* Case not exist */
                IF NOT EXISTS (SELECT
                    *
                    FROM cpi_case
                    WHERE hospital_code = par_hosp_code AND case_no = par_case_no AND patient_key = var_prk) THEN
                    BEGIN
                        SELECT
                            200033
                            INTO var_return_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* Validation for Payment */
        IF par_transaction_type = 'P' THEN
            BEGIN
                /* Charge has already been paid */
                IF EXISTS (SELECT
                    *
                    FROM cpi_payment_detail
                    WHERE case_no = par_case_no AND hospital_code = par_hosp_code) THEN
                    BEGIN
                        SELECT
                            transaction_type
                            INTO var_prev_type
                            FROM (SELECT
                                transaction_type, hospital_code, case_no, transaction_datetime
                                FROM cpi_payment_detail) AS ungrouped_query
                            INNER JOIN (SELECT
                                hospital_code, case_no, MAX(transaction_datetime) AS max_1
                                FROM cpi_payment_detail
                                WHERE hospital_code = par_hosp_code AND case_no = par_case_no
                                GROUP BY hospital_code, case_no) AS grouped_query
                                ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
                            WHERE transaction_datetime = max_1;

                        IF var_prev_type = 'P' AND (par_case_no SIMILAR TO ' AE%') THEN
                            /* ---- 20070718 : Allow multi P for HN case */
                            BEGIN
                                SELECT
                                    200035
                                    INTO var_return_code;
                                SELECT
                                    'N'
                                    INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
                /* Invalid No Charge Indicator */
                IF par_no_charge_ind IS NOT NULL THEN
                    BEGIN
                        IF NOT EXISTS (SELECT
                            *
                            FROM no_charge_table
                            WHERE no_charge_indicator = par_no_charge_ind) THEN
                            BEGIN
                                SELECT
                                    200039
                                    INTO var_return_code;
                                SELECT
                                    'N'
                                    INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
                /* Invalid Payment Means */
                IF par_payment_means IS NOT NULL THEN
                    BEGIN
                        IF NOT EXISTS (SELECT
                            *
                            FROM payment_table
                            WHERE payment_means = par_payment_means) THEN
                            BEGIN
                                SELECT
                                    200040
                                    INTO var_return_code;
                                SELECT
                                    'N'
                                    INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                        /*
                        20160929
                        If this is paid by Octopus, then table cpi_octopus_transaction should be
                        inserted a record before creating record in table cpi_payment_detail
                        This checking was added in Sep-2016 after an incident happened in KWH in which
                        an A&E case had "OC" record in cpi_payment_detail but somehow cpi_octopus_transaction
                        had no corresponding record
                        */
                        IF par_payment_means = 'OC' AND par_transaction_type = 'P' THEN
                            BEGIN
                                IF NOT EXISTS (SELECT
                                    1
                                    FROM cpi_octopus_transaction
                                    WHERE hospital_code = par_hosp_code AND case_no = par_case_no AND transaction_status = 'Y' AND card_no IS NOT NULL AND transaction_datetime = (SELECT
                                        MAX(c.transaction_datetime)
                                        FROM cpi_octopus_transaction AS c
                                        WHERE c.hospital_code = par_hosp_code AND c.case_no = par_case_no)) THEN
                                    BEGIN
                                        SELECT
                                            200040
                                            INTO var_return_code;
                                        SELECT
                                            'N'
                                            INTO var_success_flag;
                                        EXIT return_error;
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;
                /* Payment for registration date/time before 29/11/2002 */
                IF par_adm_dtm < '20021129' THEN
                    BEGIN
                        SELECT
                            200041
                            INTO var_return_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
                /* 20130402 : Payment for registration date/time before 1-Apr-2013 */
                IF par_adm_dtm < '20130401' AND (par_payment_amount = 990 OR par_pay_code LIKE 'NE%') THEN
                    BEGIN
                        SELECT
                            200041
                            INTO var_return_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
                /* Invalid Case Type */
                IF (par_case_no NOT SIMILAR TO ' AE%') AND (par_case_no NOT SIMILAR TO ' HN%') THEN
                    BEGIN
                        SELECT
                            200042
                            INTO var_return_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* Validate for Cancel Payment */
        IF par_transaction_type = 'C' THEN
            BEGIN
                /* No payment has been made */
                IF NOT EXISTS (SELECT
                    *
                    FROM cpi_payment_detail
                    WHERE hospital_code = par_hosp_code AND case_no = par_case_no) THEN
                    BEGIN
                        SELECT
                            200036
                            INTO var_return_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                ELSE
                    BEGIN
                        SELECT
                            transaction_type
                            INTO var_prev_type
                            FROM (SELECT
                                transaction_type, hospital_code, case_no, transaction_datetime
                                FROM cpi_payment_detail) AS ungrouped_query
                            INNER JOIN (SELECT
                                hospital_code, case_no, MAX(transaction_datetime) AS max_1
                                FROM cpi_payment_detail
                                WHERE hospital_code = par_hosp_code AND case_no = par_case_no
                                GROUP BY hospital_code, case_no) AS grouped_query
                                ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
                            WHERE transaction_datetime = max_1;

                        IF var_prev_type <> 'P' THEN
                            BEGIN
                                SELECT
                                    200036
                                    INTO var_return_code;
                                SELECT
                                    'N'
                                    INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;

        IF par_case_no SIMILAR TO ' AE%' THEN
            SELECT
                'A'
                INTO var_case_type;
        ELSE
            IF par_case_no SIMILAR TO ' HN%' THEN
                SELECT
                    'I'
                    INTO var_case_type;
            ELSE
                SELECT
                    'O'
                    INTO var_case_type;
            END IF;
        END IF;

        IF par_transaction_type IN ('R', 'E') THEN
            SELECT
                NULL
                INTO par_case_no;
        END IF;
        SELECT
            localtimestamp
            INTO par_transaction_datetime;

        WHILE EXISTS (SELECT
            *
            FROM cpi_payment_detail
            WHERE hospital_code = par_hosp_code AND transaction_datetime >= par_transaction_datetime) LOOP
            SELECT
                localtimestamp
                INTO par_transaction_datetime;
        END LOOP;
        /* ---- */

        IF par_waiver_no IS NULL OR LTRIM(RTRIM(par_waiver_no)) = '' THEN
            BEGIN
                SELECT
                    NULL
                    INTO par_new_waiver_type;
                SELECT
                    NULL
                    INTO par_upd_sys;
            END;
        END IF;
        /* ---- */
       	raise notice ' INSERT INTO cpi_payment_detail';
        INSERT INTO cpi_payment_detail (transaction_datetime, hospital_code, case_no, case_type, receipt_no, admission_dtm, pay_code, payment_means, waiver_no, waiver_type, waiver_issue_party, waiver_eff_date, waiver_exp_date, no_charge_indicator, payment_amount, paid_amount, transaction_type, remark, update_by, workstation_id, source_system, nep_search_key, nep_add_key_1, nep_add_key_2, new_waiver_type, upd_sys)
        VALUES (par_transaction_datetime, par_hosp_code, par_case_no, var_case_type, par_receipt_no, par_adm_dtm, par_pay_code, par_payment_means, par_waiver_no, par_waiver_type, par_waiver_issue_party, par_waiver_eff_date, par_waiver_exp_date, par_no_charge_ind, par_payment_amount, par_paid_amount, par_transaction_type, par_remark, par_user_id, par_term_id, par_src_system, par_nep_search_key, par_nep_add_key_1, par_nep_add_key_2, par_new_waiver_type, par_upd_sys);
        /* insert failed */
		GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF (sql$rowcount = 0) THEN
            BEGIN
                SELECT
                    200034
                    INTO var_return_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                RAISE exception '';
            END;
        END IF;
		EXCEPTION
			WHEN OTHERS then
			begin
				raise notice '%',sqlerrm;
				EXIT return_error;
			end;
    END;

    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_insert_payment_detail" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
