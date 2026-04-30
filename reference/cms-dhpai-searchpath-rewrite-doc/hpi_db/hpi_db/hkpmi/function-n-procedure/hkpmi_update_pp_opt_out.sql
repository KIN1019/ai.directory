-- DROP PROCEDURE hkpmi_update_pp_opt_out(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in timestamp, inout varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi_update_pp_opt_out(INOUT pas_return_code integer, IN "par_HKID" character varying, IN par_req_type character varying, IN par_effective_dtm timestamp without time zone, IN par_req_hkid character varying, IN par_req_name character varying, IN par_req_sex character varying, IN par_req_phone character varying, IN par_req_nok character varying, IN par_req_address character varying, IN par_req_dtm timestamp without time zone, IN par_upd_hosp character varying, IN par_upd_by character varying, IN par_upd_dtm timestamp without time zone, INOUT par_rtn_msg character varying DEFAULT NULL::character varying, IN par_mode character varying DEFAULT 'U'::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* --- use HKID for update, prk may diff. between CPI/PMI */ 
/* ----/'U' update, 'C' Check only */
DECLARE
    var_prk VARCHAR(16);
    var_rtn_code INTEGER;
    var_err_msg VARCHAR(255);
    var_error_code INTEGER;
    var_prev_type VARCHAR(2);
    var_prev_eff_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_min_eff_dtm TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        <<return_normal>>
        BEGIN
            SET LOCAL search_path TO hkpmi,public;
            IF LTRIM(RTRIM(par_req_hkid)) = '' THEN
                SELECT
                    NULL
                    INTO par_req_hkid;
            END IF;

            IF LTRIM(RTRIM(par_req_name)) = '' THEN
                SELECT
                    NULL
                    INTO par_req_name;
            END IF;

            IF LTRIM(RTRIM(par_req_sex)) = '' THEN
                SELECT
                    NULL
                    INTO par_req_sex;
            END IF;

            IF LTRIM(RTRIM(par_req_phone)) = '' THEN
                SELECT
                    NULL
                    INTO par_req_phone;
            END IF;

            IF LTRIM(RTRIM(par_req_nok)) = '' THEN
                SELECT
                    NULL
                    INTO par_req_nok;
            END IF;

            IF LTRIM(RTRIM(par_req_address)) = '' THEN
                SELECT
                    NULL
                    INTO par_req_address;
            END IF;
            SELECT
                patient_key
                INTO var_prk
                FROM patient
                WHERE hkid = "par_HKID";
            /* ---NO Patient -- */
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount <> 1 THEN /* ----@@rowcount = 0 */
                BEGIN
                    SELECT
                        - 1
                        INTO var_rtn_code;
                    SELECT
                        'NO patient found !'
                        INTO var_err_msg;
                    EXIT return_error;
                END;
            END IF;
            /* --- rules checking --- */

            IF EXISTS (SELECT
                *
                FROM pp_opt_out
                WHERE patient_key = var_prk AND effective_datetime = par_effective_dtm) THEN
                BEGIN
                    SELECT
                        - 2
                        INTO var_rtn_code;
                    SELECT
                        'Opt-Out information record already found !'
                        INTO var_err_msg;
                    EXIT return_error;
                END;
            END IF;

            IF par_req_type NOT IN ('A', 'D') OR par_req_type IS NULL THEN
                BEGIN
                    SELECT
                        - 3
                        INTO var_rtn_code;
                    SELECT
                        'Incorrect request type!'
                        INTO var_err_msg;
                    EXIT return_error;
                END;
            END IF;
            /* --- requester is the patient --- */

            IF par_req_hkid = "par_HKID" THEN /* or @req_hkid is null */
                BEGIN
                    SELECT
                        NULL, NULL, NULL, NULL, NULL, NULL
                        INTO par_req_hkid, par_req_name, par_req_sex, par_req_phone, par_req_nok, par_req_address;
                END;
            END IF;
            /*
            ---check NON nullabl field ---
               if @req_hkid is not null
               begin
            		select @req_name = ltrim(rtrim(@req_name))
            
                  if @req_name is null or @req_name=''
                  begin
                     select @rtn_code = -4
                     select @err_msg = 'Requester name cannot be empty !'
                     goto return_error
                  end
            
                  if @req_sex NOT in ('M','F') or @req_sex is null
                  begin
                     select @rtn_code = -5
                     select @err_msg = 'Incorrect sex type !'
                     goto return_error
                  end
            
                  if NOT exists (select * from nok_relation where nok_relation_code = @req_nok)
            			or @req_nok is null
                  begin
                     select @rtn_code = -6
                     select @err_msg = 'Incorrect relationship !'
                     goto return_error
                  end
            
               end
            */
            SELECT
                NULL
                INTO var_min_eff_dtm;
            SELECT
                effective_datetime
                INTO var_min_eff_dtm
                FROM (SELECT
                    effective_datetime, patient_key
                    FROM pp_opt_out) AS ungrouped_query
                INNER JOIN (SELECT
                    patient_key, MIN(effective_datetime) AS min_1
                    FROM pp_opt_out
                    WHERE patient_key = var_prk
                    GROUP BY patient_key) AS grouped_query
                    ON (ungrouped_query.patient_key = grouped_query.patient_key OR (ungrouped_query.patient_key IS NULL AND grouped_query.patient_key IS NULL))
                /* ----      and effective_datetime <= @effective_dtm */
                WHERE effective_datetime = min_1;

            IF par_req_type = 'D' AND (par_effective_dtm < var_min_eff_dtm OR var_min_eff_dtm IS NULL) THEN
                BEGIN
                    SELECT
                        - 7
                        INTO var_rtn_code;
                    SELECT
                        'PP Opt-Out information first record must be Opt-Out !'
                        INTO var_err_msg;
                    EXIT return_error;
                END;
            END IF;
            SELECT
                request_type, effective_datetime
                INTO var_prev_type, var_prev_eff_dtm
                FROM (SELECT
                    request_type, effective_datetime, patient_key
                    FROM pp_opt_out) AS ungrouped_query
                INNER JOIN (SELECT
                    patient_key, MAX(effective_datetime) AS max_1
                    FROM pp_opt_out
                    WHERE patient_key = var_prk AND effective_datetime <= par_effective_dtm
                    GROUP BY patient_key) AS grouped_query
                    ON (ungrouped_query.patient_key = grouped_query.patient_key OR (ungrouped_query.patient_key IS NULL AND grouped_query.patient_key IS NULL))
                WHERE effective_datetime = max_1;

            IF par_req_type = 'D' AND var_prev_type = 'D' THEN
                BEGIN
                    SELECT
                        - 8
                        INTO var_rtn_code;
                    SELECT
                        'PP Opt-Out information already resumed !'
                        INTO var_err_msg;
                    /* ---select @err_msg = 'PP Opt-out information already in-active!' */
                    EXIT return_error;
                END;
            END IF;
            /*
            if @effective_datetime <= @prev_eff_dtm
            begin
            	select @rtn_code = -8
            	select @err_msg = 'Effective date must later than existing effective date !'
            	goto return_error
            end
            */
            /* Insert pp_opt_out ---- */
            IF par_mode = 'U' THEN
                BEGIN
                    /*
                    [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
                    BEGIN TRAN
                    */
                    /* --- ****BEGIN TRAN ****---- */
                    BEGIN
                        INSERT INTO pp_opt_out (patient_key, request_type, effective_datetime, request_hkid, request_name, request_sex, request_phone, request_relationship, request_address, request_datetime, update_hospital, update_by, update_datetime)
                        VALUES (var_prk, par_req_type, par_effective_dtm, par_req_hkid, par_req_name, par_req_sex, par_req_phone, par_req_nok, par_req_address, par_req_dtm, par_upd_hosp, par_upd_by, par_upd_dtm);
                        var_error_code := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error_code := 1;
                    END;

                    IF var_error_code <> 0 THEN
                        BEGIN
                            ROLLBACK;
                            /* --- ***ROLLBACK****--- */
                            SELECT
                                - 11
                                INTO var_rtn_code;
                            SELECT
                                'Insert pp_opt_out Failed !'
                                INTO var_err_msg;
                            EXIT return_error;
                        END;
                    ELSE
                        BEGIN
                            EXIT return_normal;
                        END;
                    END IF;
                END;
            END IF;
        END;
        SELECT
            NULL
            INTO par_rtn_msg;
        pas_return_code := 0;
        RETURN;
    END;
    SELECT
        var_err_msg
        INTO par_rtn_msg;
    pas_return_code := var_rtn_code;
   	RESET search_path;
    RETURN;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_update_pp_opt_out" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";