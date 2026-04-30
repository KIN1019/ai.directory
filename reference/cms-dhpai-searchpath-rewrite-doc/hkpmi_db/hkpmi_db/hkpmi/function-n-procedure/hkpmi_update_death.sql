-- DROP PROCEDURE hkpmi.hkpmi_update_death(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_update_death(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_txn_type character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_hkid character varying, IN par_death_indicator character varying, IN par_death_dtm timestamp without time zone, IN par_body_category character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_error INTEGER;
    var_return_error_code INTEGER;
    var_rowcount INTEGER;
    var_return_code INTEGER;
    var_begin_tran varchar(01);
    var_death_code varchar(5);
    var_patient_key varchar(8);
    var_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_filler VARCHAR(30);
    sql$rowcount BIGINT;
begin
	SET search_path TO hkpmi, public;
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN
            /* Declaration */
            select  'Y' into var_begin_tran;
            /* Validate key fields */
            IF NOT ((par_source_system = 'ADT' AND par_txn_type IN ('033')) OR (par_source_system = 'OPAS' AND par_txn_type IN ('033')) OR (par_source_system = 'OPAS2' AND par_txn_type IN ('033')) OR (par_source_system = 'CMS' AND par_txn_type IN ('033'))) THEN /* YL 20070820: for CMS to update body_category */
                BEGIN
                    /* Invalid transaction type. */
                    SELECT
                        200014
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            SELECT
                patient_key, row_update_datetime
                INTO var_patient_key, var_timestamp
                FROM patient
                WHERE hkid = par_hkid;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    /* Patient not found. */
                    SELECT
                        200012
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* update patient */
            IF par_death_indicator = 'Y' THEN
                SELECT
                    par_source_system
                    INTO var_death_code;
            ELSE
                SELECT
                    NULL
                    INTO var_death_code;
            END IF;
            /* YL 200708 update body_category to filler */
            BEGIN
                SELECT
                    filler
                    INTO var_filler
                    FROM patient
                    WHERE patient_key = var_patient_key;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;

            IF var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    EXIT return_system_error;
                END;
            END IF;

            IF par_body_category IS NOT NULL THEN
                SELECT
                    CONCAT(COALESCE(SUBSTRING(var_filler, 1, 1), REPEAT(' ', 1)), par_body_category, + SUBSTRING(var_filler, 3, 28))
                    INTO var_filler;
            ELSE
                IF var_filler IS NOT NULL THEN
                    SELECT
                        CONCAT(SUBSTRING(var_filler, 1, 1), REPEAT(' ', 1), SUBSTRING(var_filler, 3, 28))
                        INTO var_filler;
                END IF;
            END IF;

            begin
	            raise notice 'var_patient_key=%',var_patient_key;
                UPDATE patient
                SET death_indicator = var_death_code, death_date = par_death_dtm, source_system = par_source_system, system_dtm = localtimestamp, update_by = par_update_by, update_hospital = par_hospital_code, source_system_dtm = par_source_system_dtm, filler = var_filler
                    WHERE patient_key = var_patient_key AND row_update_datetime = var_timestamp;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    EXIT return_system_error;
                END;
            END IF;

            IF var_rowcount != 1 THEN
                BEGIN
                    /*
                    Patient not found or Patient has been updated between retrieved and upd
                    ate."
                    */
                    SELECT
                        200016
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            CALL hkpmi_patient_death_tx(var_return_code, par_hospital_code, '033', par_hkid, 'Y',null);

            IF var_return_code != 0 THEN
                BEGIN
                    SELECT
                        200121
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            pas_return_code := 0;
            RETURN;
        END;

        IF var_begin_tran = 'Y' THEN
            BEGIN
                --ROLLBACK;
                raise exception '';
            END;
        END IF;
--        RAISE EXCEPTION USING ERRCODE := var_return_error_code;
        pas_return_code := var_return_error_code;
        RETURN;
    END;

    IF var_begin_tran = 'Y' THEN
        BEGIN
            --ROLLBACK;
            raise exception '';
        END;
    END IF;
    pas_return_code := var_return_error_code;
    RETURN;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_update_death" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";