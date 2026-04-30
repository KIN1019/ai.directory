-- DROP PROCEDURE hpi.hasp_get_cutoff_datetime(inout int4, in varchar, in varchar, inout timestamp);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_cutoff_datetime(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_transaction_type character varying, INOUT par_cutoff_datetime timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_today TIMESTAMP WITHOUT TIME ZONE;
    var_error INTEGER;
    var_rowcount INTEGER;
    sql$rowcount BIGINT;
BEGIN
    IF par_cutoff_datetime IS NULL THEN
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_today;
    ELSE
        SELECT
            par_cutoff_datetime
            INTO var_today;
    END IF;

    BEGIN
        IF par_transaction_type = 'E' THEN
            SELECT
                MAX(transaction_datetime)
                INTO par_cutoff_datetime
                FROM payment_detail
                WHERE hospital_code = par_hosp_code AND transaction_type = 'E' AND transaction_datetime < var_today;
        ELSE
            SELECT
                MAX(transaction_datetime)
                INTO par_cutoff_datetime
                FROM payment_detail
                WHERE hospital_code = par_hosp_code AND transaction_type IN ('R', 'E') AND transaction_datetime < var_today;
        END IF;
        var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
    END;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
    var_rowcount := sql$rowcount;

    IF var_error <> 0 THEN
        pas_return_code := - 1;
        RETURN;
    ELSE
        BEGIN
            IF par_cutoff_datetime IS NULL THEN
                BEGIN
                    BEGIN
                        SELECT
                            MIN(transaction_datetime)
                            INTO par_cutoff_datetime
                            FROM payment_detail
                            WHERE hospital_code = par_hosp_code AND transaction_datetime < var_today;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    END;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                    var_rowcount := sql$rowcount;

                    IF var_error <> 0 THEN
                        pas_return_code := - 1;
                        RETURN;
                    ELSE
                        BEGIN
                            IF par_cutoff_datetime IS NULL THEN
                                SELECT
                                    --aws_sapase_ext.conv_datetime_to_string('VARCHAR (8)'::TEXT, 'DATETIME'::TEXT, var_today::TIMESTAMP WITHOUT TIME ZONE, 112)
                                    to_char(var_today::TIMESTAMP WITHOUT TIME ZONE,'YYYYMMDD')
                                    INTO par_cutoff_datetime;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_cutoff_datetime" OWNER TO "HPI_SCHEMA_OWNER_ROLE";