-- DROP FUNCTION hpi.fn_cpi_tu_case();

CREATE OR REPLACE FUNCTION hpi.fn_cpi_tu_case()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/*
19990202 multiple rows update of case is allowed as long as case_no,
          case_status, patient_type and hospital_code are not updated.
	- verify existence of cpi_new_born for mother's case by lschu on 28/5/2001
	- insert cpi_patient_location for cancel discharge case by lschu on 13/4/2002
	---20050922 SL :  Ensure ONLY one records for eache Baby HKID .NOTE: Move Case => Move mo_bb linkage too....
	---20070718 SL : ECS
	---20130805  : Add ROLLBACK
	--20130930 : allow to update pay code from TEP/TNE to EP/NE --
	--Same for CPI/HPI --
*/
/* --use cpi */
/* --go */
DECLARE
    var_old_hospital_code VARCHAR(3);
    var_new_hospital_code VARCHAR(3);
    var_old_case_no VARCHAR(12);
    var_new_case_no VARCHAR(12);
    var_patient_name VARCHAR(48);
    var_cccode1 VARCHAR(5);
    var_cccode2 VARCHAR(5);
    var_cccode3 VARCHAR(5);
    var_cccode4 VARCHAR(5);
    var_cccode5 VARCHAR(5);
    var_cccode6 VARCHAR(5);
    var_name_soundex VARCHAR(4);
    var_name_phonetic VARCHAR(48);
    var_chinese_name VARCHAR(12);
    var_sex VARCHAR(1);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_phone1 VARCHAR(10);
    var_phone2 VARCHAR(10);
    var_mobile_phone VARCHAR(10);
    var_old_status_code VARCHAR(2);
    var_new_status_code VARCHAR(2);
    var_cnt INTEGER;
    var_valid_flag VARCHAR(1);
    var_old_patient_key VARCHAR(8);
    var_new_patient_key VARCHAR(8);
    var_new_case_type VARCHAR(01);
    var_old_discharge_code VARCHAR(1);
    var_new_discharge_code VARCHAR(1);
    var_transaction_type VARCHAR(1);
    var_new_patient_type VARCHAR(3);
    var_old_patient_type VARCHAR(3);
    var_return_code INTEGER;
    var_rowcount INTEGER;
    var_dest VARCHAR(3);
    var_dist VARCHAR(5);
    var_patient_type VARCHAR(3);
    var_patient_key VARCHAR(8);
    var_nb_case VARCHAR(12);
    var_row INTEGER;
    var_rowcount$aws$ INTEGER;
    sql$rowcount BIGINT;
    update$case_no BOOLEAN = FALSE;
    update$hospital_code BOOLEAN = FALSE;
    update$patient_type BOOLEAN = FALSE;
    update$status_code BOOLEAN = FALSE;
    update$destination_code BOOLEAN = FALSE;
    update$district_code BOOLEAN = FALSE;
    update$patient_key BOOLEAN = FALSE;
BEGIN
    CASE TG_OP
        WHEN 'INSERT' THEN
            update$case_no = TRUE;
        WHEN 'UPDATE' THEN
            update$case_no = ((SELECT
                array_agg(case_no)
                FROM deleted) != (SELECT
                array_agg(case_no)
                FROM inserted));
        ELSE
            update$case_no := FALSE;
    END CASE;
    CASE TG_OP
        WHEN 'INSERT' THEN
            update$hospital_code = TRUE;
        WHEN 'UPDATE' THEN
            update$hospital_code = ((SELECT
                array_agg(hospital_code)
                FROM deleted) != (SELECT
                array_agg(hospital_code)
                FROM inserted));
        ELSE
            update$hospital_code := FALSE;
    END CASE;
    CASE TG_OP
        WHEN 'INSERT' THEN
            update$patient_type = TRUE;
        WHEN 'UPDATE' THEN
            update$patient_type = ((SELECT
                array_agg(patient_type)
                FROM deleted) != (SELECT
                array_agg(patient_type)
                FROM inserted));
        ELSE
            update$patient_type := FALSE;
    END CASE;
    CASE TG_OP
        WHEN 'INSERT' THEN
            update$status_code = TRUE;
        WHEN 'UPDATE' THEN
            update$status_code = ((SELECT
                array_agg(status_code)
                FROM deleted) != (SELECT
                array_agg(status_code)
                FROM inserted));
        ELSE
            update$status_code := FALSE;
    END CASE;
    CASE TG_OP
        WHEN 'INSERT' THEN
            update$destination_code = TRUE;
        WHEN 'UPDATE' THEN
            update$destination_code = ((SELECT
                array_agg(destination_code)
                FROM deleted) != (SELECT
                array_agg(destination_code)
                FROM inserted));
        ELSE
            update$destination_code := FALSE;
    END CASE;
    CASE TG_OP
        WHEN 'INSERT' THEN
            update$district_code = TRUE;
        WHEN 'UPDATE' THEN
            update$district_code = ((SELECT
                array_agg(district_code)
                FROM deleted) != (SELECT
                array_agg(district_code)
                FROM inserted));
        ELSE
            update$district_code := FALSE;
    END CASE;
    CASE TG_OP
        WHEN 'INSERT' THEN
            update$patient_key = TRUE;
        WHEN 'UPDATE' THEN
            update$patient_key = ((SELECT
                array_agg(patient_key)
                FROM deleted) != (SELECT
                array_agg(patient_key)
                FROM inserted));
        ELSE
            update$patient_key := FALSE;
    END CASE;

    IF (TG_OP = 'INSERT') THEN
        SELECT
            count(1)
            FROM inserted
            INTO var_rowcount$aws$;
    ELSE
        SELECT
            count(1)
            FROM deleted
            INTO var_rowcount$aws$;
    END IF;
    var_rowcount := var_rowcount$aws$;

    IF var_rowcount > 1 AND
    /* GL 19990203 */
    (update$case_no OR update$hospital_code OR update$patient_type OR update$status_code OR (SELECT
        COUNT(DISTINCT patient_key)
        FROM deleted) > 1 OR (SELECT
        COUNT(DISTINCT patient_key)
        FROM inserted) > 1) THEN
        BEGIN
            RAISE EXCEPTION 'Multiple rows update of case are not allowed!' USING ERRCODE = '25000';
            ROLLBACK; /* ---20130805 */
            RETURN NULL;
        END;
    END IF;
    SELECT
        destination_code, district_code, patient_type, patient_key
        INTO var_dest, var_dist, var_patient_type, var_patient_key
        FROM inserted;

    IF update$destination_code THEN
        BEGIN
            IF var_dest IS NOT NULL THEN
                BEGIN
                    /* -- Modified by WL on 17 AUG 99 -- */
                    /* --exec @return_code = cpi_pq_validate_destination @dest, @valid_flag */
                    CALL cpi_pq_validate_destination(var_return_code, var_dest, var_valid_flag);

                    IF var_return_code <> 0 OR var_valid_flag <> 'Y' THEN
                        BEGIN
                            RAISE EXCEPTION '% % % ', 'UPDATE', 'cpi_case', 'destination' USING ERRCODE = '20012';
                            RETURN NULL;
                        END;
                    END IF;
                END;
            END IF;
        END;
    END IF;

    IF update$district_code THEN
        BEGIN
            IF var_dist IS NOT NULL THEN
                BEGIN
                    /* -- Modified by WL on 17 AUG 99 -- */
                    /* --exec @return_code = cpi_pq_validate_district @dist, @valid_flag */
                    CALL cpi_pq_validate_district(var_return_code, var_dist, var_valid_flag);

                    IF var_return_code <> 0 OR var_valid_flag <> 'Y' THEN
                        BEGIN
                            RAISE EXCEPTION '% % % ', 'UPDATE', 'cpi_case', 'district' USING ERRCODE = '20012';
                            RETURN NULL;
                        END;
                    END IF;
                END;
            END IF;
        END;
    END IF;

    IF update$patient_type THEN
        BEGIN
            CALL cpi_pq_validate_patient_type(var_return_code, var_patient_type, var_valid_flag );

            IF var_return_code <> 0 OR var_valid_flag <> 'Y' THEN
                BEGIN
                    RAISE EXCEPTION '% % % ', 'UPDATE', 'cpi_case', 'patient_type' USING ERRCODE = '20012';
                    RETURN NULL;
                END;
            END IF;
        END;
    END IF;

    IF update$patient_key THEN
        BEGIN
            IF NOT EXISTS (SELECT
                *
                FROM cpi_patient
                WHERE patient_key = var_patient_key) THEN
                BEGIN
                    RAISE EXCEPTION '% % % ', 'UPDATE', 'cpi_case', 'cpi_patient' USING ERRCODE = '20012';
                    RETURN NULL;
                END;
            END IF;
        END;
    END IF;
    SELECT
        hospital_code, case_no, patient_key, status_code, case_type, discharge_code, patient_type
        INTO var_new_hospital_code, var_new_case_no, var_new_patient_key, var_new_status_code, var_new_case_type, var_new_discharge_code, var_new_patient_type
        FROM inserted;
    SELECT
        hospital_code, case_no, patient_key, status_code, discharge_code, patient_type
        INTO var_old_hospital_code, var_old_case_no, var_old_patient_key, var_old_status_code, var_old_discharge_code, var_old_patient_type
        FROM deleted;

    IF var_old_hospital_code != var_new_hospital_code OR var_old_case_no != var_new_case_no THEN
        BEGIN
            RAISE EXCEPTION 'Hospital code or Case no is not allowed to changed' USING ERRCODE = '25000';
            RETURN NULL;
        END;
    END IF;
    /* ---20050922 --- */
    /* --- Ensure ONLY one records for eache Baby HKID --- */
 
    IF update$patient_key THEN
        BEGIN
            IF EXISTS (SELECT
                *
                FROM mother_baby_case
                WHERE baby_hospital_code = var_old_hospital_code AND baby_case_no = var_old_case_no) THEN
                BEGIN
                    SELECT
                        case_no
                        INTO var_nb_case
                        FROM cpi_case AS c
                        WHERE c.patient_key = var_new_patient_key AND c.hospital_code = var_old_hospital_code AND c.case_no <> var_old_case_no AND EXISTS (SELECT
                            *
                            FROM mother_baby_case
                            WHERE baby_hospital_code = c.hospital_code AND baby_case_no = c.case_no);

                    IF (TG_OP = 'INSERT') THEN
                        SELECT
                            count(1)
                            FROM inserted
                            INTO var_rowcount$aws$;
                    ELSE
                        SELECT
                            count(1)
                            FROM deleted
                            INTO var_rowcount$aws$;
                    END IF;
                    var_rowcount := var_rowcount$aws$;

                    IF var_rowcount > 1 THEN
                        /* -- Found mo_bb for the new_patient */
                        BEGIN
                            /* --print 'nb_case=%1! %2! %3! %4!',@nb_case,@row,@new_patient_key,@old_patient_key */
                            RAISE EXCEPTION 'The mother Baby Relationship already exists for the Patient !' USING ERRCODE = '25000';
                            RETURN NULL;
                        END;
                    END IF;
                END;
            END IF;
        END;
    END IF;
    /* ---20050922 --- */
    IF var_old_status_code != var_new_status_code AND var_new_status_code = 'CC' AND var_new_case_type != 'O' THEN
        BEGIN
            BEGIN
                DELETE FROM cpi_patient_location
                USING deleted
                    WHERE cpi_patient_location.hospital_code = deleted.hospital_code AND cpi_patient_location.case_no = deleted.case_no;
                EXCEPTION
                    WHEN OTHERS THEN
                        BEGIN
                            RAISE NOTICE 'Fail to delete cpi_patient_location!';
                        END;
            END;
        END;
    END IF;

    IF var_new_case_type = 'I' THEN
        BEGIN
            IF var_new_patient_key <> var_old_patient_key OR (var_new_status_code = 'CC' AND var_old_status_code = 'AC') THEN
                BEGIN
                    IF EXISTS (SELECT
                        *
                        FROM cpi_new_born
                        WHERE mother_patient_key = var_old_patient_key AND mother_case_no = var_old_case_no) THEN
                        BEGIN
                            RAISE EXCEPTION 'New Born Information exists for the case' USING ERRCODE = '25000';
                            RETURN NULL;
                        END;
                    END IF;
                END;
            END IF;
        END;
    END IF;

    IF (var_new_patient_type <> var_old_patient_type) OR (var_new_status_code = 'CC' AND var_old_status_code = 'AC') THEN
        BEGIN
            SELECT
                transaction_type
                INTO var_transaction_type
                FROM (SELECT
                    transaction_type, hospital_code, case_no, transaction_datetime
                    FROM cpi_payment_detail) AS ungrouped_query
                INNER JOIN (SELECT
                    hospital_code, case_no, MAX(transaction_datetime) AS max_1
                    FROM cpi_payment_detail
                    WHERE case_no = var_new_case_no AND hospital_code = var_new_hospital_code
                    GROUP BY hospital_code, case_no) AS grouped_query
                    ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
                WHERE transaction_datetime = max_1;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 1 THEN
                BEGIN
                    IF var_transaction_type = 'P' AND (var_new_case_type <> 'I') THEN /* ---20070718 Allow Multi-P for HN case */
                        BEGIN
                            /* -----20130930 allow TEP/TNE changed to EP1/NE9 ----- */
                            IF NOT ((var_old_patient_type = 'TEP' AND var_patient_type = 'EP1') OR (var_old_patient_type = 'TNE' AND var_patient_type = 'NE9')) THEN
                                BEGIN
                                    RAISE EXCEPTION 'Payment Information exists for the case' USING ERRCODE = '25000';
                                    RETURN NULL;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
        END;
    END IF;
    /* 19990130 GL */
    IF var_new_patient_key != var_old_patient_key THEN
        BEGIN
            IF EXISTS (SELECT
                *
                FROM cpi_patient_location AS p, deleted AS d
                WHERE p.hospital_code = d.hospital_code AND p.case_no = d.case_no) THEN
                BEGIN
                    SELECT
                        patient_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, soundex(patient_name), sex, dob, chi_name, phone1, phone2, mobile_phone
                        INTO var_patient_name, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_name_soundex, var_sex, var_dob, var_chinese_name, var_phone1, var_phone2, var_mobile_phone
                        FROM cpi_patient
                        WHERE patient_key = var_new_patient_key;
                    CALL cpi_get_phonetic_chin_name(var_return_code, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_name_phonetic, var_chinese_name );
                    UPDATE cpi_patient_location
                    SET patient_key = var_new_patient_key, patient_name = var_patient_name, name_soundex = var_name_soundex, name_phonetic = var_name_phonetic, sex = var_sex, dob = var_dob, chinese_name = var_chinese_name, phone1 = var_phone1, phone2 = var_phone2, mobile_phone = var_mobile_phone,
                    /* 20140822/Ray/Enquiry of Patient Location chinese name search begin */
                    /* new fields */
                    cccode1 = var_cccode1, cccode2 = var_cccode2, cccode3 = var_cccode3, cccode4 = var_cccode4, cccode5 = var_cccode5, cccode6 = var_cccode6
                    /* 20140822/Ray/Enquiry of Patient Location chinese name search end */
                    FROM deleted
                        WHERE cpi_patient_location.hospital_code = deleted.hospital_code AND cpi_patient_location.case_no = deleted.case_no;
                END;
            END IF;
        END;
    END IF;
    /* readmission */
    IF (var_old_status_code != var_new_status_code AND var_old_status_code = 'CC' AND var_new_case_type != 'O') OR (var_old_status_code = var_new_status_code AND var_old_status_code = 'AC' AND var_new_case_type <> 'O' AND var_old_discharge_code IS NOT NULL AND var_new_discharge_code IS NULL) THEN
        BEGIN
            SELECT
                patient_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, soundex(patient_name), sex, dob, chi_name, phone1, phone2, mobile_phone
                INTO var_patient_name, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_name_soundex, var_sex, var_dob, var_chinese_name, var_phone1, var_phone2, var_mobile_phone
                FROM cpi_patient
                WHERE patient_key = var_new_patient_key;
            CALL cpi_get_phonetic_chin_name(var_return_code, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_name_phonetic, var_chinese_name);
            /* 20140822/Ray/Enquiry of Patient Location chinese name search end */
            BEGIN
                IF NOT EXISTS (SELECT
                    *
                    FROM cpi_patient_location
                    WHERE hospital_code = var_new_hospital_code AND case_no = var_new_case_no) THEN
                    INSERT INTO cpi_patient_location (hospital_code, case_no, patient_key, patient_name, name_soundex, name_phonetic, sex, dob, chinese_name, phone1, phone2, mobile_phone,
                    /* 20140822/Ray/Enquiry of Patient Location chinese name search begin */
                    cccode1, cccode2, cccode3, cccode4, cccode5, cccode6)
                    VALUES (var_new_hospital_code, var_new_case_no, var_new_patient_key, var_patient_name, var_name_soundex, var_name_phonetic, var_sex, var_dob, var_chinese_name, var_phone1, var_phone2, var_mobile_phone,
                    /* new fields for inputting chinese */
                    var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6);
                END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        BEGIN
                            RAISE EXCEPTION 'Error in inserting cpi_patient_location!' USING ERRCODE = '25000';
                            RETURN NULL;
                        END;
            END;
        END;
    END IF;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_cpi_tu_case" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
