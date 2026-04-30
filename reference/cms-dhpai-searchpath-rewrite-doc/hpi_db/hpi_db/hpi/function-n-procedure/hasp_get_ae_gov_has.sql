-- DROP PROCEDURE hpi.hasp_get_ae_gov_has(inout int4, in varchar, in timestamp, in timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_ae_gov_has(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_from_date timestamp without time zone, IN par_to_date timestamp without time zone, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    result_str_value VARCHAR(128);
    var_tx_date      TIMESTAMP WITHOUT TIME ZONE;
    var_case         VARCHAR(12);
    var_pay          VARCHAR(3);
    var_pay_amt      INTEGER;
    var_ws_id        VARCHAR(12);
    var_user         VARCHAR(12);
    var_name         VARCHAR(48);
    var_hkid         VARCHAR(12);
    csr CURSOR FOR
        SELECT transaction_datetime,
               case_no,
               pay_code,
               payment_amount,
               workstation_id,
               update_by
        FROM payment_detail
        WHERE hospital_code = par_hosp_code
          AND transaction_datetime >= par_from_date
          AND transaction_datetime <= par_to_date
          AND case_type = 'A'
          AND transaction_type = 'P';
BEGIN
    DROP TABLE IF EXISTS t$temp_gov_has;
    CREATE TEMPORARY TABLE t$temp_gov_has
    (
        tx_date      TIMESTAMP WITHOUT TIME ZONE,
        hkid         VARCHAR(12),
        patient_name VARCHAR(48),
        case_no      VARCHAR(12),
        pay_code     VARCHAR(3),
        pay_amt      INTEGER,
        ws_id        VARCHAR(12),
        user_id      VARCHAR(12)
    );
    CREATE UNIQUE INDEX temp_index ON t$temp_gov_has
        (tx_date, hkid, case_no);
    OPEN csr;
    FETCH csr INTO var_tx_date, var_case, var_pay, var_pay_amt, var_ws_id, var_user;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            /* check if paycode in display list */
            IF var_tx_date < '20100927' AND var_pay IN
                                            ('SPO', 'WV', 'HA1', 'HA2', 'HA3', 'HA', 'DH1', 'DH2', 'DH3', 'DHA', 'RH1',
                                             'RH2', 'RH3', 'RHA', 'SR1', 'SR2', 'SR3', 'SRH', 'TP', 'TDG', 'TGS',
                                             'TGR') OR var_tx_date >= '20100927' AND var_pay IN
                                                                                     ('WV', 'TP', 'TDG', 'TGS', 'TGR',
                                                                                      'TH1', 'TH2', 'TH3', 'TD1', 'TD2',
                                                                                      'TD3', 'TR1', 'TR2', 'TR3',
                                                                                      'SPO') THEN
                BEGIN
                    /* check if exist another payment transaction for the case */
                    IF NOT EXISTS (SELECT *
                                   FROM payment_detail
                                   WHERE hospital_code = par_hosp_code
                                     AND case_no = var_case
                                     AND transaction_datetime > var_tx_date) THEN
                        BEGIN
                            SELECT HKID
                            -- INTO var_hkid
                            INTO result_str_value
                            FROM Case_view
                            WHERE Case_no = var_case
                              AND Hospital_code = par_hosp_code;
                            IF FOUND THEN
                                var_hkid := result_str_value;
                            END IF;

                            SELECT Name
                            --INTO var_name
                            INTO result_str_value
                            FROM PMI_wo_MRN
                            WHERE HKID = var_hkid;
                            IF FOUND THEN
                                var_name := result_str_value;
                            END IF;

                            INSERT INTO t$temp_gov_has (tx_date, hkid, patient_name, case_no, pay_code, pay_amt, ws_id,
                                                        user_id)
                            VALUES (var_tx_date, var_hkid, var_name, var_case, var_pay, var_pay_amt, var_ws_id,
                                    var_user);
                        END;
                    END IF;
                END;
            END IF;
            FETCH csr INTO var_tx_date, var_case, var_pay, var_pay_amt, var_ws_id, var_user;
        END LOOP;
    CLOSE csr;

    CLUSTER t$temp_gov_has USING temp_index;
    OPEN p_refcur FOR
        SELECT tx_date,
               hkid,
               patient_name,
               case_no,
               pay_code,
               pay_amt,
               ws_id,
               user_id
        FROM t$temp_gov_has;

    pas_return_code := 0;
END ;
$procedure$
;

;ALTER PROCEDURE "hasp_get_ae_gov_has" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
