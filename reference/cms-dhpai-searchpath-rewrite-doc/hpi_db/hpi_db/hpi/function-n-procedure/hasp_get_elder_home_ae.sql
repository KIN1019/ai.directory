CREATE OR REPLACE function hasp_get_elder_home_ae(IN par_hosp_code CHAR, IN par_from_date TIMESTAMP WITHOUT TIME ZONE, IN par_to_date TIMESTAMP WITHOUT TIME ZONE)
RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_eh_code VARCHAR(8);
    var_eh_dist VARCHAR(40);
    var_eh_name VARCHAR(255);
    var_ae_case_no VARCHAR(12);
    var_tx_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_dis_code VARCHAR(1);
    var_hkid VARCHAR(12);
    var_patient_name VARCHAR(48);
    var_dis_desc VARCHAR(5);
	p_refcur refcursor;
    csr CURSOR FOR
    SELECT
        Case_no, Transaction_datetime
        FROM Transaction_log
        WHERE Transaction_datetime >= par_from_date AND Transaction_datetime < par_to_date AND Transaction_type = '300' AND Cancel_flag IS NULL;
    sql$rowcount BIGINT;
BEGIN
    DROP TABLE IF EXISTS t$tmp_eh_ae;
    CREATE TEMPORARY TABLE t$tmp_eh_ae
    (eh_dist VARCHAR(40) NULL,
        eh_code VARCHAR(8),
        eh_name VARCHAR(255) NULL,
        adm_datetime TIMESTAMP WITHOUT TIME ZONE,
        dis_desc VARCHAR(5) NULL,
        hkid VARCHAR(12),
        case_no VARCHAR(12),
        patient_name VARCHAR(48));
    SELECT
        1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
        INTO par_to_date;
    OPEN csr;
    FETCH csr INTO var_ae_case_no, var_tx_datetime;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP /* Found AE case => Find EH & Patient info for Report */
        SELECT
            EH_code
            INTO var_eh_code
            FROM AE_case_detail
            WHERE Case_no = var_ae_case_no;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount <> 1 THEN
            SELECT
                NULL
                INTO var_eh_code;
        END IF;
        /* Found AE with  Elderly Home info => use for Report */
        IF var_eh_code IS NOT NULL THEN
            BEGIN
                SELECT
                    eh_district,
                    CASE
                        WHEN eh_name IS NULL OR eh_name = '' THEN eh_chinese_name
                        ELSE eh_name
                    END
                    INTO var_eh_dist, var_eh_name
                    FROM elderly_home_table
                    WHERE eh_code = var_eh_code;
                SELECT
                    HKID, Discharge_code, Destination_code
                    INTO var_hkid, var_dis_code, var_dis_desc
                    FROM Case_view
                    WHERE Case_no = var_ae_case_no;

                IF var_dis_code = NULL THEN
                    SELECT
                        NULL
                        INTO var_dis_desc;
                ELSE
                    IF var_dis_code NOT IN ('0', '4', '9') THEN
                        SELECT
                            Short_description
                            INTO var_dis_desc
                            FROM Discharge_type
                            WHERE Discharge_code = var_dis_code;
                    END IF;
                END IF;
                /* --			if @@rowcount !=1	/* No discharge */ */
                /* --				select @dis_desc=null */
                SELECT
                    patient_name
                    INTO var_patient_name
                    FROM cpi_patient
                    WHERE hkid = var_hkid;
                INSERT INTO t$tmp_eh_ae
                VALUES (var_eh_dist, var_eh_code, var_eh_name, var_tx_datetime, var_dis_desc, var_hkid, var_ae_case_no, var_patient_name);
            END;
        END IF;
        /* Searching for other AE Cases */
        FETCH csr INTO var_ae_case_no, var_tx_datetime;
    END LOOP;
    CLOSE csr;
    OPEN p_refcur FOR
    SELECT
        t$tmp_eh_ae.eh_dist, t$tmp_eh_ae.eh_code, t$tmp_eh_ae.eh_name, t$tmp_eh_ae.adm_datetime, t$tmp_eh_ae.dis_desc, t$tmp_eh_ae.hkid, t$tmp_eh_ae.case_no, t$tmp_eh_ae.patient_name
        FROM t$tmp_eh_ae
        ORDER BY eh_dist NULLS FIRST, eh_code NULLS FIRST, eh_name NULLS FIRST, adm_datetime NULLS FIRST, hkid NULLS FIRST;
    return next p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_get_elder_home_ae" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
