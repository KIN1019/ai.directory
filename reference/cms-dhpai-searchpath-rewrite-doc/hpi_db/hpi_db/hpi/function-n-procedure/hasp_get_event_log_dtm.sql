-- DROP PROCEDURE hasp_get_event_log_dtm(inout int4, in varchar, inout timestamp);

CREATE OR REPLACE PROCEDURE hasp_get_event_log_dtm(INOUT pas_return_code integer, IN par_hosp character varying, INOUT par_insert_dtm timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/* Return values   Meaning */
DECLARE
    var_cnt INTEGER;
    var_exit_flag VARCHAR(1);
BEGIN
    SELECT
        0, 'N'
        INTO var_cnt, var_exit_flag;
    SELECT
        COUNT(*)
        INTO var_cnt
        FROM Event_log
        WHERE Hospital_code = par_hosp AND System_datetime = par_insert_dtm;

    IF (var_cnt != 0) THEN
        BEGIN
            SELECT
                'N'
                INTO var_exit_flag;

            WHILE (var_exit_flag = 'N') LOOP
                SELECT
                    3 * INTERVAL '1 millisecond' + par_insert_dtm::TIMESTAMP
                    INTO par_insert_dtm;
                SELECT
                    COUNT(*)
                    INTO var_cnt
                    FROM Event_log
                    WHERE Hospital_code = par_hosp AND System_datetime = par_insert_dtm;

                IF (var_cnt = 0) THEN
                    SELECT
                        'Y'
                        INTO var_exit_flag;
                END IF;
            END LOOP /* end while */;
        END;
    END IF; /* end if */
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_event_log_dtm" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
