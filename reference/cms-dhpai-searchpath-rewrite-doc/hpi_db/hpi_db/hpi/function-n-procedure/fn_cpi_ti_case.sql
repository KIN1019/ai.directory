-- DROP FUNCTION hpi.fn_cpi_ti_case();

CREATE OR REPLACE FUNCTION hpi.fn_cpi_ti_case()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_hospital_code VARCHAR(3);
    var_case_no VARCHAR(12);
    var_patient_key VARCHAR(8);
    var_case_type VARCHAR(1);
    var_patient_name VARCHAR(48);
    var_cccode1 VARCHAR(5);
    var_cccode2 VARCHAR(5);
    var_cccode3 VARCHAR(5);
    var_cccode4 VARCHAR(5);
    var_cccode5 VARCHAR(5);
    var_cccode6 VARCHAR(5);
    var_name_soundex VARCHAR(4);
    var_name_phonetic VARCHAR(48);
    var_sex VARCHAR(1);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_chinese_name VARCHAR(12);
    var_phone1 VARCHAR(10);
    var_phone2 VARCHAR(10);
    var_mobile_phone VARCHAR(10);
    var_valid_flag VARCHAR(1);
    var_return_code INTEGER;
    var_dest VARCHAR(3);
    var_dist VARCHAR(5);
    var_patient_type VARCHAR(3);
    var_numrows INTEGER;
    var_rowcount$aws$ INTEGER;
    update$destination_code BOOLEAN = FALSE;
    update$district_code BOOLEAN = FALSE;
    update$patient_type BOOLEAN = FALSE;
    update$patient_key BOOLEAN = FALSE;
BEGIN
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
    var_numrows := var_rowcount$aws$;

    IF var_numrows > 1 THEN
        BEGIN
            /*
            print "multiple rows insert of case are not allowed!"
            return
            */
            RAISE EXCEPTION 'Multiple rows insert of case are not allowed!' USING ERRCODE = '25000';
            ROLLBACK; /* ---20130805 */
            RETURN NULL;
        END;
    END IF;
    SELECT
        case_type, patient_key, case_no, hospital_code, destination_code, district_code, patient_type
        INTO var_case_type, var_patient_key, var_case_no, var_hospital_code, var_dest, var_dist, var_patient_type
        FROM inserted;
    CALL cpi_pq_validate_caseno(var_return_code, var_case_no, var_hospital_code, var_valid_flag);

    IF (var_valid_flag = 'N') THEN
        BEGIN
            RAISE EXCEPTION 'Invalid case no, fail to insert case!' USING ERRCODE = '25000';
            RETURN NULL;
        END;
    END IF;

    IF update$destination_code THEN
        BEGIN
            IF var_dest IS NOT NULL THEN
                BEGIN
                    CALL cpi_pq_validate_destination(var_return_code, var_dest, var_valid_flag);

                    IF var_return_code <> 0 OR var_valid_flag <> 'Y' THEN
                        BEGIN
                            RAISE NOTICE '[fn_cpi_ti_case:133]var_retcode=>%,var_valid_flag=>%', var_return_code, var_valid_flag;
                            RAISE EXCEPTION '% % % ', 'INSERT', 'cpi_case', 'destination' USING ERRCODE = '200012';
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
                    CALL cpi_pq_validate_district(var_return_code, var_dist, var_valid_flag);

                    IF var_return_code <> 0 OR var_valid_flag <> 'Y' THEN
                        BEGIN
                            RAISE NOTICE '[fn_cpi_ti_case:151]var_retcode=>%,var_valid_flag=>%', var_return_code, var_valid_flag;
                            RAISE EXCEPTION '% % % ', 'INSERT', 'cpi_case', 'district' USING ERRCODE = '200012';
                            RETURN NULL;
                        END;
                    END IF;
                END;
            END IF;
        END;
    END IF;

    IF update$patient_type THEN
        BEGIN
            CALL cpi_pq_validate_patient_type(var_return_code, var_patient_type, var_valid_flag);

            IF var_return_code <> 0 OR var_valid_flag <> 'Y' THEN
                BEGIN
                    RAISE NOTICE '[fn_cpi_ti_case:167]var_retcode=>%,var_valid_flag=>%', var_return_code, var_valid_flag;
                    RAISE EXCEPTION '% % % ', 'INSERT', 'cpi_case', 'patient_type' USING ERRCODE = '200012';
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
                    RAISE NOTICE '[fn_cpi_ti_case:182]var_patient_key=>%', var_patient_key;
                    RAISE EXCEPTION '% % % ', 'INSERT', 'cpi_case', 'cpi_patient' USING ERRCODE = '200012';
                    RETURN NULL;
                END;
            END IF;
        END;
    END IF;

    IF var_case_type != 'O' THEN
        BEGIN
            SELECT
                patient_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, soundex(patient_name), sex, dob, chi_name, phone1, phone2, mobile_phone
                INTO var_patient_name, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_name_soundex, var_sex, var_dob, var_chinese_name, var_phone1, var_phone2, var_mobile_phone
                FROM cpi_patient
                WHERE patient_key = var_patient_key;
            CALL cpi_get_phonetic_chin_name(var_return_code, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_name_phonetic, var_chinese_name);
            /* 20140822/Ray/Enquiry of Patient Location chinese name search begin */
            /* 20140822/Ray/Enquiry of Patient Location chinese name search end */
            BEGIN
                INSERT INTO cpi_patient_location (hospital_code, case_no, patient_key, patient_name, name_soundex, name_phonetic, sex, dob, chinese_name, phone1, phone2, mobile_phone, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6)
                VALUES (var_hospital_code, var_case_no, var_patient_key, var_patient_name, var_name_soundex, var_name_phonetic, var_sex, var_dob, var_chinese_name, var_phone1, var_phone2, var_mobile_phone,
                /* new fields for inputting chinese */
                var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6);
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


;ALTER FUNCTION "fn_cpi_ti_case" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
