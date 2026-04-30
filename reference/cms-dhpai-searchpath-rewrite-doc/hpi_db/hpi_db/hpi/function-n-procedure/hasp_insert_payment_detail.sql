-- DROP PROCEDURE hpi.hasp_insert_payment_detail(inout int4, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, in int4, in varchar, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout varchar, inout timestamp, inout int4, in varchar, in varchar, in varchar, in varchar, in int4, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_insert_payment_detail(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_hkid character varying, IN par_case_no character varying, IN par_adm_dtm timestamp without time zone, IN par_pay_code character varying, IN par_payment_amount integer, IN par_paid_amount integer, IN par_no_charge_ind character varying, IN par_payment_means character varying, IN par_waiver_no character varying, IN par_waiver_eff_date timestamp without time zone, IN par_waiver_exp_date timestamp without time zone, IN par_waiver_type character varying, IN par_waiver_issue_party character varying, IN par_user_id character varying, IN par_term_id character varying, IN par_transaction_type character varying, IN par_remark character varying, INOUT par_receipt_no character varying, INOUT par_transaction_datetime timestamp without time zone, INOUT par_return_code integer, IN par_nep_search_key character varying DEFAULT NULL::character varying, IN par_nep_add_key_1 character varying DEFAULT NULL::character varying, IN par_nep_add_key_2 character varying DEFAULT NULL::character varying, IN par_source_system character varying DEFAULT 'ADT'::character varying, IN par_txn_type integer DEFAULT 30, IN par_auto_payment character varying DEFAULT 'N'::character varying, IN par_new_waiver_type character varying DEFAULT NULL::character varying, IN par_upd_sys character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_old_year VARCHAR(4);
    var_new_year VARCHAR(4);
    var_enable_ae_charging VARCHAR(1);
    var_rowcount INTEGER;
    var_case_type VARCHAR(1);
    sql$rowcount BIGINT;

BEGIN
    <<return_error>>
    BEGIN
        IF par_case_no SIMILAR TO ' HN%' THEN
            SELECT
                'I'
                INTO var_case_type;
        ELSE
            SELECT
                'A'
                INTO var_case_type;
        END IF;
        SELECT
            Text_value
            INTO var_enable_ae_charging
            FROM Hospital_control
            WHERE Type = 'ae_charging' AND Hospital_code = par_hosp_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_rowcount = 0 OR var_enable_ae_charging <> 'Y') AND var_case_type = 'A' THEN
            /* ---- For Non-Acute Hosp  ---- */
            BEGIN
                SELECT
                    - 1
                    INTO par_return_code;
                EXIT return_error;
            END;
        END IF;

        IF var_case_type = 'I' THEN
            SELECT
                'PBRC'
                INTO par_source_system;
        ELSE
            SELECT
                'ADT'
                INTO par_source_system;
        END IF;
        /* ---- 20070718 : NO need to generate receipt number for HN case ONLY */
        
        /* --if @transaction_type = 'P' */
        IF par_transaction_type = 'P' AND var_case_type = 'A' THEN
            BEGIN
                BEGIN
                    SELECT
                        RIGHT(CONCAT('0000000000', CAST (COALESCE(Next_available_AE_receipt, 0) AS CHAR(10))), 10)
                        INTO par_receipt_no
                        FROM hospital_config
                        WHERE Hospital_code = par_hosp_code;
                    EXCEPTION
                        WHEN others THEN
                            BEGIN
                                SELECT
                                    - 1
                                    INTO par_return_code;
                                EXIT return_error;
                            END;
                END;
                SELECT
                    SUBSTRING(RIGHT(CONCAT('0000000000', RTRIM(CAST (par_receipt_no AS CHAR(10)))), 10), 1, 2)
                    INTO var_old_year;
                SELECT
                    SUBSTRING(par_case_no, 4, 2)
                    INTO var_new_year;

                IF var_old_year >= '70' THEN
                    SELECT
                        CONCAT('19', LTRIM(var_old_year))
                        INTO var_old_year;
                ELSE
                    SELECT
                        CONCAT('20', LTRIM(var_old_year))
                        INTO var_old_year;
                END IF;

                IF var_new_year >= '70' THEN
                    SELECT
                        CONCAT('19', LTRIM(var_new_year))
                        INTO var_new_year;
                ELSE
                    SELECT
                        CONCAT('20', LTRIM(var_new_year))
                        INTO var_new_year;
                END IF;
                /* --20220101 / Freda, Jeffery, Ranger / Update / Fix int overflow issue, force year prefix using 21 for short term solution */
                /* --20220103 / Freda / Update / Permanent solution for int overflow issue, change data type to bigint */
                /* --select @new_year = '2021' */
                BEGIN
                    IF var_new_year > var_old_year THEN
                        BEGIN
                            SELECT
                                CONCAT(SUBSTRING(var_new_year, 3, 2), '00000001')
                                INTO par_receipt_no;
                            UPDATE hospital_config
                            SET Next_available_AE_receipt =
                            /* --20220103 / Freda / Update / Permanent solution for int overflow issue, change data type to bigint */
                            CAST (CONCAT(SUBSTRING(var_new_year, 3, 2), '00000002') AS BIGINT)
                                WHERE Hospital_code = par_hosp_code;
                        END;
                    ELSE
                        UPDATE hospital_config
                        SET Next_available_AE_receipt = COALESCE(Next_available_AE_receipt, 0) + 1
                            WHERE Hospital_code = par_hosp_code;
                    END IF;
                    EXCEPTION
                        WHEN others THEN
                            BEGIN
                                SELECT
                                    - 1
                                    INTO par_return_code;
                                EXIT return_error;
                            END;
                END;
            END;
        END IF;
        CALL cpi_insert_payment_detail(par_return_code,par_hosp_code, par_hkid, par_case_no, par_adm_dtm, par_pay_code, par_payment_amount, par_paid_amount, par_no_charge_ind, par_payment_means, par_waiver_no, par_waiver_eff_date, par_waiver_exp_date, par_waiver_type, par_waiver_issue_party, par_remark, par_user_id, par_term_id, par_transaction_type, par_receipt_no, par_source_system, par_transaction_datetime, par_nep_search_key, par_nep_add_key_1, par_nep_add_key_2, par_new_waiver_type, par_upd_sys);

        EXIT return_error;
    END;
    pas_return_code := par_return_code;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_insert_payment_detail" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
