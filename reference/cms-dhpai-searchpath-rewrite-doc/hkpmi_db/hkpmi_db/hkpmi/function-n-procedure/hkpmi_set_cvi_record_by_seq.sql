-- DROP PROCEDURE hkpmi.hkpmi_set_cvi_record_by_seq(inout int4, in bpchar, in bpchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_set_cvi_record_by_seq(INOUT pas_return_code integer, IN par_system_id varchar, IN par_patient_key varchar, IN par_vaccine_brand character varying DEFAULT NULL::character varying, IN par_dose_seq character varying DEFAULT NULL::character varying, IN par_dose_date character varying DEFAULT NULL::character varying, IN par_vac_center character varying DEFAULT NULL::character varying, IN par_vac_admin_premises character varying DEFAULT NULL::character varying, IN par_paper_name_eng character varying DEFAULT NULL::character varying, IN par_vaccine_trade_name_eng character varying DEFAULT NULL::character varying, IN par_paper_name_chi character varying DEFAULT NULL::character varying, IN par_check_datetime character varying DEFAULT NULL::character varying, IN par_batch_seq integer DEFAULT NULL::integer, INOUT par_return_code integer DEFAULT NULL::integer, INOUT par_return_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_hkid VARCHAR(12);
    var_source_system VARCHAR(5);
    var_status VARCHAR(20);
    var_vac_record_key VARCHAR(30);
    var_dt_check_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_dt_dose_date TIMESTAMP WITHOUT TIME ZONE;
    var_error_msg VARCHAR(255);
    var_error_code INTEGER;
    var_rowcount INTEGER;
    var_log_datetime TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            par_system_id
            INTO var_source_system;
        SELECT
            hkid
            INTO var_hkid
            FROM patient
            WHERE patient_key = par_patient_key;

        IF par_batch_seq <= 0 THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Batch seq. must be started from 1!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;

        IF var_hkid IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Patient record not found!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;

        IF var_source_system NOT IN ('ADT', 'OPAS', 'EAI', 'IPAS', 'CVSE') THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Source system code is invalid!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;

        IF par_check_datetime IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Check datetime is invalid!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;

        IF par_check_datetime IS NOT NULL AND LENGTH(par_check_datetime) >= 17 THEN
            BEGIN
                SELECT
                    CAST (par_check_datetime AS TIMESTAMP WITHOUT TIME ZONE)
                    INTO var_dt_check_datetime;
            END;
        ELSE
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Check datetime is invalid!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;

        IF par_dose_date = '' OR par_dose_date IS NULL THEN
            BEGIN
                IF par_vaccine_brand != '' THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Dose date is empty!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;
                SELECT
                    'NO_RECORD'
                    INTO var_status;
            END;
        ELSE
            BEGIN
                IF par_vaccine_brand = '' OR par_vaccine_brand IS NULL THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Vaccine brand is empty!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;
                SELECT
                    CAST (par_dose_date AS TIMESTAMP WITHOUT TIME ZONE)
                    INTO var_dt_dose_date;
                SELECT
                    'VACCINATED'
                    INTO var_status;
            END;
        END IF;
        SELECT
            vac_record_key
            INTO var_vac_record_key
            FROM hkpmi_patient_cvi_record
            WHERE patient_key = par_patient_key::VARCHAR;

        IF var_vac_record_key IS NOT NULL THEN
            BEGIN
                IF par_batch_seq = 1 THEN
                    BEGIN
                        UPDATE hkpmi_patient_cvi_record
                        SET update_datetime = localtimestamp
                            WHERE patient_key = par_patient_key::VARCHAR;
                    END;
                END IF;

                BEGIN
                    UPDATE hkpmi_patient_cvi_record
                    SET source_system = var_source_system, status = var_status, last_check_datetime = var_dt_check_datetime
                        WHERE patient_key = par_patient_key::VARCHAR;
                    var_error_code := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error_code := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_error_code <> 0 OR var_rowcount <> 1 THEN
                    BEGIN
                        SELECT
                            'Fail to update hkpmi_patient_cvi_record!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;
            END;
        ELSE
            BEGIN

	            select concat(par_patient_key,'_',to_char(localtimestamp,'YYYYMMDD') ) into var_vac_record_key;
                BEGIN
                    INSERT INTO hkpmi_patient_cvi_record (source_system, patient_key, vac_record_key, status, last_check_datetime, create_datetime, update_datetime)
                    VALUES (var_source_system, par_patient_key, var_vac_record_key, var_status, var_dt_check_datetime, localtimestamp, localtimestamp);
                    var_error_code := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error_code := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_error_code <> 0 OR var_rowcount <> 1 THEN
                    BEGIN
                        SELECT
                            'Fail to insert hkpmi_patient_cvi_record!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;

        IF par_dose_date != '' THEN
            BEGIN
                IF EXISTS (SELECT
                    1
                    FROM hkpmi_patient_cvi_dose_info
                    WHERE patient_key = par_patient_key::VARCHAR AND vaccine_brand = par_vaccine_brand::VARCHAR AND dose_date = var_dt_dose_date AND dose_order = par_dose_seq::VARCHAR) THEN
                    BEGIN
                        BEGIN
                            UPDATE hkpmi_patient_cvi_dose_info
                            SET source_system = var_source_system, vaccine_brand = par_vaccine_brand, dose_order = par_dose_seq, vac_center = par_vac_center, vac_admin_premises = par_vac_admin_premises, paper_name_eng = par_paper_name_eng, vaccine_trade_name_eng = par_vaccine_trade_name_eng, paper_name_chi = par_paper_name_chi, update_datetime = localtimestamp
                                WHERE patient_key = par_patient_key::VARCHAR AND dose_date = var_dt_dose_date AND vaccine_brand = par_vaccine_brand::VARCHAR AND dose_order = par_dose_seq::VARCHAR;
                            var_error_code := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error_code := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF var_error_code <> 0 OR var_rowcount <> 1 THEN
                            BEGIN
                                SELECT
                                    'Fail to update hkpmi_patient_cvi_dose_info!'
                                    INTO var_error_msg;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        BEGIN
                            INSERT INTO hkpmi_patient_cvi_dose_info (source_system, patient_key, vac_record_key, dose_order, vaccine_brand, dose_date, vac_center, vac_admin_premises, paper_name_eng, vaccine_trade_name_eng, paper_name_chi, create_datetime, update_datetime)
                            VALUES (var_source_system, par_patient_key, var_vac_record_key, par_dose_seq, par_vaccine_brand, var_dt_dose_date, par_vac_center, par_vac_admin_premises, par_paper_name_eng, par_vaccine_trade_name_eng, par_paper_name_chi, localtimestamp, localtimestamp);
                            var_error_code := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error_code := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF var_error_code <> 0 OR var_rowcount <> 1 THEN
                            BEGIN
                                SELECT
                                    'Fail to insert hkpmi_patient_cvi_dose_info!'
                                    INTO var_error_msg;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        SELECT
            NULL
            INTO par_return_message;
        SELECT
            0
            INTO par_return_code;

        pas_return_code := 0;
        RETURN;
    END;
    SELECT
        var_error_msg
        INTO par_return_message;
    SELECT
        - 1
        INTO par_return_code;
   	rollback;
    pas_return_code := - 1;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_set_cvi_record_by_seq" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
