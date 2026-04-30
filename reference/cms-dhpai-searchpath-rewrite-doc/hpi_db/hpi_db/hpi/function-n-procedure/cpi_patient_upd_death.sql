-- DROP PROCEDURE hpi.cpi_patient_upd_death(inout int4, in varchar, in varchar, in varchar, in timestamp, in varchar, in timestamp, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_patient_upd_death(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_patient_key character varying, IN par_death_date timestamp without time zone, IN par_death_indicator character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_hospital character varying, IN par_update_by character varying, IN par_last_update_datetime timestamp without time zone, IN par_source_system character varying, IN par_upload_status character varying DEFAULT 'P'::bpchar, IN par_body_category character varying DEFAULT NULL::bpchar)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
    var_success_flag VARCHAR(1);
    var_exit_flag VARCHAR(1);
    var_chk_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_return_error_code INTEGER;
    var_download_err_string VARCHAR(255);
    var_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_rep_hospital INTEGER;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_patient_name VARCHAR(48);
    var_sex VARCHAR(01);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_txn_type VARCHAR(3);
    var_cpi_filler VARCHAR(30);
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    begin

        /*
        if @@trancount = 0
           begin
              select @return_error_code = 20000
              select @success_flag = "N"
              goto return_error
           end
        */
        /*
        save transaction cpi_patient_upd_death
        */
--	SAVEPOINT cpi_patient_upd_death;
        IF NOT EXISTS (SELECT
            *
            FROM hospital
            WHERE hospital_code = par_hospital_code) THEN
            BEGIN
                SELECT
                    200002
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        SELECT
            '033'
            INTO var_txn_type;
        SELECT
            update_dtm, patient_name, sex, dob
            INTO var_chk_update_datetime, var_patient_name, var_sex, var_dob
            FROM cpi_patient
            WHERE patient_key = par_patient_key AND hkid = par_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF (sql$rowcount != 1) THEN
            BEGIN
                SELECT
                    7013
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;

        IF (var_chk_update_datetime != par_last_update_datetime) THEN
            BEGIN
                SELECT
                    7016
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /*
        Assign the transaction_datetime of source system
        to source_system_dtm
        */
        SELECT
            par_transaction_datetime
            INTO var_source_system_dtm;
        /* Use a common datetime to update all tables */
        /*
        if (@source_system = "DNL")
        begin
        	select @update_datetime = @transaction_datetime
        	select @transaction_datetime = getdate()
        end
        else
        begin
        	select @update_datetime = getdate()
        	select @transaction_datetime = @update_datetime
        end
        */
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_update_datetime;
        SELECT
            var_update_datetime
            INTO par_transaction_datetime;
        /* Set flags and variables */
        SELECT
            'Y'
            INTO var_success_flag;

        IF (par_source_system = 'DNL') THEN
            SELECT
                'N'
                INTO par_upload_status;
        END IF;
        /*
        else
        select	@upload_status = "Y"
        */
        /* Validate key fields */
        /* Get replicate bit values */
        SELECT
            bit_value
            INTO var_rep_hospital
            FROM rep_cluster_bits
            WHERE hospital_code = par_hospital_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF (sql$rowcount = 0) THEN
            BEGIN
                /*
                print "Fail to get bit values from rep_cluster_bits,
                patient update is rejected!"
                */
                SELECT
                    7001
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;

        BEGIN
            UPDATE cpi_patient
            SET death_date = par_death_date, death_indicator = par_death_indicator, update_hospital = par_update_hospital, update_by = par_update_by, update_dtm = var_update_datetime, rep_clusters = rep_clusters | var_rep_hospital, body_category = par_body_category
                WHERE patient_key = par_patient_key AND update_dtm = par_last_update_datetime;
            raise notice 'cpi_patient_upd_death(155)[INSERT]cpi_patient,par_patient_key=%',par_patient_key;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                SELECT
                    7003
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* insert transaction record */
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_transaction
            WHERE hospital_code = par_hospital_code AND transaction_datetime = par_transaction_datetime;

        IF (var_cnt != 0) THEN
            BEGIN
                SELECT
                    'N'
                    INTO var_exit_flag;

                WHILE (var_exit_flag = 'N') LOOP
                    SELECT
                        3 * INTERVAL '1 millisecond' + par_transaction_datetime::TIMESTAMP
                        INTO par_transaction_datetime;
                    SELECT
                        COUNT(*)
                        INTO var_cnt
                        FROM cpi_transaction
                        WHERE hospital_code = par_hospital_code AND transaction_datetime = par_transaction_datetime;

                    IF (var_cnt = 0) THEN
                        SELECT
                            'Y'
                            INTO var_exit_flag;
                    END IF;
                END LOOP;
            END;
        END IF;
        /* YL : Add body_category to cpi_filler */
        IF par_body_category IS NOT NULL THEN
            SELECT
                CONCAT(REPEAT(' ', 29), par_body_category)
                INTO var_cpi_filler;
        ELSE
            SELECT
                NULL
                INTO var_cpi_filler;
        END IF;

        BEGIN
            INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key, patient_name, sex, dob, death_indicator, death_date, update_hospital, update_by, update_datetime, source_system, success_indicator, upload_status, source_system_dtm, cpi_filler)
            VALUES (par_hospital_code, par_transaction_datetime, var_txn_type, par_hkid, par_patient_key, var_patient_name, var_sex, var_dob, par_death_indicator, par_death_date, par_update_hospital, par_update_by, timestamp_convert(localtimestamp), par_source_system, var_success_flag, par_upload_status, var_source_system_dtm, var_cpi_filler);
            raise notice 'cpi_patient_upd_death(220)[INSERT]cpi_transaction,par_patient_key=%',par_patient_key;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                SELECT
                    7015
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;

        <<insert_transaction>>
        BEGIN
        END;
    END;

    IF (var_success_flag = 'N') THEN
        BEGIN
            /*
            rollback cpi_patient_upd_death
            */
--	    ROLLBACK TO SAVEPOINT cpi_patient_upd_death;
--ROLLBACK;
            raise exception '';
            pas_return_code := var_return_error_code;
            RETURN;
        END;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_patient_upd_death" OWNER TO "HPI_SCHEMA_OWNER_ROLE";