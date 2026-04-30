-- DROP PROCEDURE hasp_pbrc_os_overriding_log(inout int4, in varchar, in int4, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in numeric, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, inout int4);

CREATE OR REPLACE PROCEDURE hasp_pbrc_os_overriding_log(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_func_id integer, IN par_hkid character varying, IN par_case_no character varying, IN par_adm_dtm timestamp without time zone, IN par_pay_code character varying, IN par_source_ind character varying, IN par_source_code character varying, IN par_ward_code character varying, IN par_ward_class character varying, IN par_spec_code character varying, IN par_eis_code character varying, IN par_os_amt numeric, IN par_overriding_reason character varying, IN par_action_code_type character varying, IN par_action_code character varying, IN par_term_id character varying, IN par_update_by character varying, IN par_update_dtm timestamp without time zone, IN par_source_system character varying, IN par_remark character varying, INOUT par_rtn_code integer)
 LANGUAGE plpgsql
AS $procedure$
/* --- return from PBRC */ 
/* ---xxxadt.user_action_code_list */ 
/* ---xxxadt.user_action_code_list */
DECLARE
    var_return_code INTEGER;
    var_success_flag VARCHAR(1);
    var_prk VARCHAR(8);
    var_valid_flag VARCHAR(1);
    var_case_type VARCHAR(1);
    var_prev_type VARCHAR(1);
    var_txn_type VARCHAR(3);
   	sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        IF par_func_id = 10 THEN
            SELECT
                '100'
                INTO var_txn_type;
        END IF;

        IF par_func_id = 30 THEN
            SELECT
                '300'
                INTO var_txn_type;
        END IF;
        SELECT
            - 1
            INTO par_rtn_code;
        /* Invalid Source System */
        IF par_source_system NOT IN ('ADT') THEN
            BEGIN
                SELECT
                    210001
                    INTO var_return_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* Invalid Transaction Type */
        IF par_source_system = 'ADT' THEN
            BEGIN
                IF var_txn_type NOT IN ('100', '300') THEN
                    BEGIN
                        SELECT
                            210001
                            INTO var_return_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* Validation for hkid and case */
        CALL cpi_pq_validate_hkid(pas_return_code, par_hkid, var_valid_flag);

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
        CALL cpi_pq_validate_caseno(pas_return_code, par_case_no, par_hospital_code, var_valid_flag);

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

        WHILE EXISTS (SELECT
            *
            FROM pbrc_os_overriding_log
            WHERE hospital_code = par_hospital_code AND update_dtm = par_update_dtm) LOOP
            SELECT
                timestamp_convert(localtimestamp)
                INTO par_update_dtm;
        END LOOP;
        INSERT INTO pbrc_os_overriding_log (hospital_code, txn_type, hkid, case_no, adm_dtm, pay_code, source_ind, source_code, ward_code, ward_class, spec_code, eis_code, os_amt, overriding_reason, action_code_type, action_code, term_id, update_by, update_dtm, source_system, remark)
        VALUES (par_hospital_code, var_txn_type, par_hkid, par_case_no, par_adm_dtm, par_pay_code, par_source_ind, par_source_code, par_ward_code, par_ward_class, par_spec_code, par_eis_code, par_os_amt, par_overriding_reason, par_action_code_type, par_action_code, par_term_id, par_update_by, par_update_dtm, par_source_system, par_remark);
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

	/* insert failed */
	IF sql$rowcount = 0 THEN
                BEGIN
                        RAISE exception '';
                END;
        END IF;
	EXCEPTION
		WHEN OTHERS then
		begin
			select 210001 into var_return_code;
			EXIT return_error;
		end;
	
        SELECT
            0
            INTO par_rtn_code;
        pas_return_code := 0;
        RETURN;
    END;
    SELECT
        var_return_code
        INTO par_rtn_code;
    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_pbrc_os_overriding_log" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
