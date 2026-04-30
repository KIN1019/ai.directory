-- DROP PROCEDURE web_cpi_insert_octopus_tran(inout int4, in varchar, in varchar, in int4, in varchar, inout varchar, in varchar, in varchar, in varchar, inout timestamp, inout varchar, inout int4, inout int4);

CREATE OR REPLACE PROCEDURE web_cpi_insert_octopus_tran(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_paid_amount integer, IN par_term_id character varying, INOUT par_card_no character varying, IN par_update_by character varying, IN par_workstation_id character varying, IN par_usage_data character varying, INOUT par_transaction_datetime timestamp without time zone, INOUT par_receipt_no character varying, INOUT par_receiptnoascii1 integer, INOUT par_receiptnoascii2 integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_prev_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_prev_status VARCHAR(1);
    var_return_code INTEGER;
    var_success_flag VARCHAR(1);
    var_date_bin BYTEA;
    var_prev_card_no VARCHAR(20);
    var_prev_paid_amount INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            0, 'Y'
            INTO var_return_code, var_success_flag;
      
        SELECT
            transaction_datetime, transaction_status, card_no, paid_amount
            INTO var_prev_datetime, var_prev_status, var_prev_card_no, var_prev_paid_amount
            FROM (SELECT
                transaction_datetime, transaction_status, card_no, paid_amount, hospital_code, case_no
                FROM cpi_octopus_transaction) AS ungrouped_query
            INNER JOIN (SELECT
                hospital_code, case_no, MAX(transaction_datetime) AS max_1
                FROM cpi_octopus_transaction
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no
                GROUP BY hospital_code, case_no) AS grouped_query
                ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
            WHERE transaction_datetime = max_1;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            SELECT
                NULL, NULL
                INTO var_prev_datetime, var_prev_status;
        END IF;
        /*
        if prev_datetime is null, new transaction
        if prev_datetime is not null and prev_status = 'F', new transaction
        if prev_datetime is not null and prev_status = 'Y', new transaction
        if prev_datetime is not null and prev_status = 'N', redo transaction
        */
        IF (var_prev_datetime IS NULL) OR (var_prev_datetime IS NOT NULL AND var_prev_status <> 'N') THEN
            BEGIN
                SELECT
                    timestamp_convert(localtimestamp)
                    INTO par_transaction_datetime;

                WHILE EXISTS (SELECT
                    *
                    FROM cpi_octopus_transaction
                    WHERE hospital_code = par_hospital_code AND transaction_datetime >= par_transaction_datetime) LOOP
                    SELECT
                        timestamp_convert(localtimestamp)
                        INTO par_transaction_datetime;
                END LOOP;

                BEGIN
                    INSERT INTO cpi_octopus_transaction (hospital_code, case_no, transaction_datetime, term_id, card_no, paid_amount, update_by, workstation_id, transaction_status)
                    VALUES (par_hospital_code, par_case_no, par_transaction_datetime, par_term_id, par_card_no, par_paid_amount, par_update_by, par_workstation_id, 'N');
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF (sql$rowcount = 0) THEN
                        BEGIN
                            SELECT
                                200043
                                INTO var_return_code;
                            SELECT
                                'N'
                                INTO var_success_flag;
							raise exception '';
                        END;
                    END IF;
                END;
                SELECT
                    CAST (SUBSTRING(@transaction_datetime, 1, 8) AS BYTEA) || REPEAT(E'\\000', 8 - OCTET_LENGTH(@transaction_datetime))::BYTEA
                    INTO var_date_bin;
            END;
        ELSE
            BEGIN
                IF var_prev_card_no <> par_card_no OR var_prev_paid_amount <> par_paid_amount THEN
                    BEGIN
                        SELECT
                            200046
                            INTO var_return_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
						raise exception '';
                    END;
                END IF;
                SELECT
                    CAST (SUBSTRING(@prev_datetime, 1, 8) AS BYTEA) || REPEAT(E'\\000', 8 - OCTET_LENGTH(@prev_datetime))::BYTEA, var_prev_datetime, var_prev_card_no
                    INTO var_date_bin, par_transaction_datetime, par_card_no;
            END;
        END IF;
        SELECT
            RIGHT(CAST (var_date_bin AS VARCHAR(8)), 2)
            INTO par_receipt_no;
        SELECT
            ASCII(SUBSTRING(par_receipt_no, 1, 1))
            INTO par_receiptNoAscii1;
        SELECT
            ASCII(SUBSTRING(par_receipt_no, 2, 1))
            INTO par_receiptNoAscii2;
        /* --to extract the receipt no as ai with 2 digits only */
        /* --	select @receiptNoAscii1 = cast (SUBSTRING(STR(@receiptNoAscii1), len(STR(@receiptNoAscii1))-1, 2) as int) */
        /* --	select @receiptNoAscii2 = cast (SUBSTRING(STR(@receiptNoAscii2), len(STR(@receiptNoAscii2))-1, 2) as int) */
		
    END;
	
	exception when others then
		raise notice 'rollback transaction';

    pas_return_code := var_return_code;
    RETURN;
END;
/* ### DEFNCOPY: END OF DEFINITION */
$procedure$
;

;ALTER PROCEDURE "web_cpi_insert_octopus_tran" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
