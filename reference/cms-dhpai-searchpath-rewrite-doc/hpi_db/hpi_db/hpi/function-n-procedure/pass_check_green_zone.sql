CREATE OR REPLACE PROCEDURE pass_check_green_zone(INOUT pas_return_code int, IN par_hospital VARCHAR, IN par_hkid VARCHAR, INOUT p_refcur refcursor)
AS 
$BODY$
DECLARE
    var_Ip_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_Ae_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_discharge_code VARCHAR(2);
    var_discharge_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_today_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_latest_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_discharge_char VARCHAR(20);
    var_today_char VARCHAR(20);
    var_hosp_code VARCHAR(8);
    var_casecount INTEGER;
    var_return_code INTEGER;
    var_pin VARCHAR(24);
    var_pin_len INTEGER;
BEGIN
    SELECT
        LTRIM(RTRIM(par_hkid))
        INTO var_pin;
    SELECT
        OCTET_LENGTH(var_pin)
        INTO var_pin_len;

    IF var_pin_len = 8 THEN
        SELECT
            CONCAT(' ', var_pin)
            INTO par_hkid;
    ELSE
        SELECT
            var_pin
            INTO par_hkid;
    END IF;
    SELECT
        localtimestamp
        INTO var_today_dtm;
    CREATE TEMPORARY TABLE t$temp_tb
    AS
    SELECT
        c1.case_type, c1.last_ward_code, c1.case_no, c1.admission_dtm, c1.discharge_dtm, c1.discharge_code
        FROM cpi_case AS c1, cpi_patient AS p1
        WHERE p1.hkid = par_hkid AND p1.patient_key = c1.patient_key AND c1.hospital_code = par_hospital AND c1.status_code = 'AC' AND c1.case_type IN ('A', 'I');
    SELECT
        COUNT(*)
        INTO var_casecount
        FROM t$temp_tb
        WHERE discharge_code IS NULL;

    IF var_casecount > 0 THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                0;
            /* active case exists */
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    SELECT
        MAX(admission_dtm)
        INTO var_latest_datetime
        FROM t$temp_tb;

    IF var_latest_datetime = NULL THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                - 1;
            /* no case found */
            pas_return_code := 0;
            RETURN;
        END;
    ELSE
        BEGIN
            SELECT
                discharge_code, discharge_dtm
                INTO var_discharge_code, var_discharge_dtm
                FROM t$temp_tb
                WHERE (admission_dtm = var_latest_datetime);

            IF var_discharge_code <> NULL THEN
                BEGIN
                    IF DATE_PART('days', var_today_dtm::TIMESTAMP, var_discharge_dtm::TIMESTAMP) > 0 THEN
                        OPEN p_refcur FOR
                        SELECT
                            DATE_PART('days', var_today_dtm::TIMESTAMP, var_discharge_dtm::TIMESTAMP);
                    ELSE
                        OPEN p_refcur FOR
                        SELECT
                            1;
                    END IF;
                END;
            END IF;
            /*
            
            DROP TABLE IF EXISTS t$temp_tb;
            */
            /*
            
            Temporary table must be removed before end of the function.
            */
        END;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;