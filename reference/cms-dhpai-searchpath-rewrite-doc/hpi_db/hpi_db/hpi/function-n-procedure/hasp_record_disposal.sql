CREATE OR REPLACE PROCEDURE hasp_record_disposal(INOUT pas_return_code int, IN par_proc_date TIMESTAMP WITHOUT TIME ZONE, IN par_hosp_code VARCHAR)
AS 
$BODY$
DECLARE
    var_case VARCHAR(24);
    var_tx_date TIMESTAMP WITHOUT TIME ZONE;
    var_hkid VARCHAR(24);
    var_string VARCHAR(510);
    var_name VARCHAR(96);
    var_mrn VARCHAR(16);
    var_from_date TIMESTAMP WITHOUT TIME ZONE;
    var_to_date TIMESTAMP WITHOUT TIME ZONE;
    var_ret_per INTEGER;
    var_eis_code VARCHAR(6);
    var_min_ret_per INTEGER;
    var_dsch_date TIMESTAMP WITHOUT TIME ZONE;
    var_chk_case VARCHAR(24);
    var_case_exist VARCHAR(2);
    var_dsch_code VARCHAR(2);
    sql$rowcount BIGINT;
    csr CURSOR FOR
    SELECT
        case_no, transaction_datetime
        FROM transaction_log
        WHERE transaction_datetime < var_to_date AND transaction_type like '13_' AND cancel_flag IS NULL AND hospital_code = par_hosp_code;
    case_csr CURSOR FOR
    SELECT
        case_no, discharge_datetime, discharge_code
        FROM case_view
        WHERE hkid = var_hkid AND admission_datetime <= var_tx_date AND case_type = 'I' AND hospital_code = par_hosp_code;
BEGIN
    DELETE FROM disposal_table;

    IF par_proc_date IS NULL THEN
        BEGIN
            SELECT
                CONCAT(CAST (date_part('year', timestamp_convert(localtimestamp)) AS VARCHAR(8)), '0101')::TIMESTAMP WITHOUT TIME ZONE
                INTO par_proc_date;
            /* --	if @proc_date > getdate() */
            /* --		select @proc_date = dateadd(yy,-1,@proc_date) */
        END;
    END IF;
    SELECT
        retention_period
        INTO var_min_ret_per
        FROM specialty_retention
        WHERE hospital_code = par_hosp_code AND eis_specialty = '%';
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount = 0 THEN
        SELECT
            6
            INTO var_min_ret_per;
    END IF;
    SELECT
        0 - var_min_ret_per
        INTO var_ret_per;
    SELECT
        var_ret_per * INTERVAL '1 year' + par_proc_date::TIMESTAMP
        INTO var_to_date;
    OPEN csr;
    FETCH csr INTO var_case, var_tx_date;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            hkid
            INTO var_hkid
            FROM case_view
            WHERE case_no = var_case AND hospital_code = par_hosp_code;
        SELECT
            'N'
            INTO var_case_exist;
        OPEN case_csr;
        FETCH case_csr INTO var_chk_case, var_dsch_date, var_dsch_code;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 AND var_case_exist = 'N' LOOP
            SELECT
                MAX(retention_period)
                INTO var_ret_per
                FROM movement AS m, specialty AS s, specialty_retention AS r
                WHERE case_no = var_chk_case AND m.specialty_code = s.specialty_code AND m.hospital_code = par_hosp_code AND effective_date = (SELECT
                    MAX(effective_date)
                    FROM specialty
                    WHERE specialty_code = m.specialty_code AND hospital_code = par_hosp_code AND effective_date <= m.movement_datetime) AND imis_code = eis_specialty;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 OR var_ret_per IS NULL THEN
                SELECT
                    var_min_ret_per
                    INTO var_ret_per;
            END IF;
            /*
            if (not exists(select * from Case_view
            	where HKID = @hkid
            	and Admission_datetime >= @tx_date
            	and Admission_datetime <= dateadd(yy,@ret_per,@tx_date)
            	and Hospital_code = @hosp_code
            	and Case_no <> @case
            	and Case_no <> @chk_case
            	and Case_type = 'I')) and
            	(dateadd(yy,@ret_per,@tx_date) < @proc_date)
            	select @case_exist = 'N'
            else
            	select @case_exist = 'Y'
            */
            IF var_ret_per * INTERVAL '1 year' + var_dsch_date::TIMESTAMP >= par_proc_date THEN
                SELECT
                    'Y'
                    INTO var_case_exist;
            ELSE
                BEGIN
                    IF EXISTS (SELECT
                        *
                        FROM case_view
                        WHERE hkid = var_hkid AND admission_datetime >= var_tx_date AND
                        /* --				and Admission_datetime <= dateadd(yy,@ret_per,@tx_date) */
                        hospital_code = par_hosp_code AND case_no <> var_case AND case_no <> var_chk_case AND case_type = 'I') THEN
                        SELECT
                            'Y'
                            INTO var_case_exist;
                    END IF;
                END;
            END IF;

            IF var_dsch_code IS NULL THEN
                SELECT
                    'Y'
                    INTO var_case_exist;
            END IF;
            FETCH case_csr INTO var_chk_case, var_dsch_date, var_dsch_code;
        END LOOP;
        CLOSE case_csr;

        IF var_case_exist = 'N' THEN
            BEGIN
                SELECT
                    name, medical_record_number
                    INTO var_name, var_mrn
                    FROM pmi
                    WHERE hkid = var_hkid AND pmi_hospital_code = par_hosp_code;
                OPEN case_csr;
                FETCH case_csr INTO var_case, var_dsch_date, var_dsch_code;

                WHILE (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) = 0 LOOP
                    /*
                    select @string = substring(@hosp_code + space(3), 1, 3)
                    	+ substring(@hkid + space(12), 1, 12)
                    	+ substring(@name + space(48), 1, 48)
                    	+ substring(@mrn + space(8), 1, 8)
                    	+ substring(@case + space(12), 1, 12)
                    	+ substring(convert(VARCHAR(8),@dsch_date,112) + space(8), 1, 8)
                    	+ substring(convert(VARCHAR(8),@dsch_date,108) + space(8), 1, 2)
                    	+ substring(convert(VARCHAR(8),@dsch_date,108) + space(8), 4, 2)
                    	+ substring(convert(VARCHAR(8),@dsch_date,108) + space(8), 7, 2)
                    print @string
                    */
                    IF NOT EXISTS (SELECT
                        *
                        FROM disposal_table
                        WHERE hospital_code = par_hosp_code AND hkid = var_hkid AND case_no = var_case) THEN
                        INSERT INTO disposal_table (hospital_code, hkid, name, mrn, case_no, discharge_datetime)
                        VALUES (par_hosp_code, var_hkid, var_name, var_mrn, var_case, var_dsch_date);
                    END IF;
                    FETCH case_csr INTO var_case, var_dsch_date, var_dsch_code;
                END LOOP;
                CLOSE case_csr;
            END;
        END IF;
        FETCH csr INTO var_case, var_tx_date;
    END LOOP;
    CLOSE csr;
END;
$BODY$
LANGUAGE plpgsql;

ALTER PROCEDURE "hasp_record_disposal" OWNER TO "HPI_SCHEMA_OWNER_ROLE";