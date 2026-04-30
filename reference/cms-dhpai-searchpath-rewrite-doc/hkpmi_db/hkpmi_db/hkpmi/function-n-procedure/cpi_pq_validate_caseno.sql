-- DROP PROCEDURE cpi_pq_validate_caseno(inout int4, in bpchar, in bpchar, inout bpchar, in bpchar);

CREATE OR REPLACE PROCEDURE cpi_pq_validate_caseno(INOUT pas_return_code integer, IN par_caseno character varying, IN par_hospital_code character varying, INOUT par_valid_flag character varying, IN par_hkid character varying DEFAULT NULL::character varying) 
LANGUAGE plpgsql
AS $procedure$
/*
Return values   Meaning
    2               Invalid check digit
* 20070611 SL :  new Parm : @hkid to check the Case belong to same patient or NOT,'
*   			3 - if the case don't belong to the @hkid,
*/
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_char_part VARCHAR(2);
    var_num_part VARCHAR(6);
    var_check_sum INTEGER;
    var_check_digit VARCHAR(01);
    var_idx INTEGER;
    var_shift_factor INTEGER;
    var_ck_digit_str VARCHAR(36);
    var_aeno VARCHAR(08);
    var_hnno VARCHAR(08);
    var_opcode VARCHAR(04);
    var_opno VARCHAR(07);
begin
	SET search_path TO hkpmi, public;
   SELECT
        'Y'
        INTO par_valid_flag;

    IF SUBSTRING(par_caseno, 1, 3) <> ' AE' AND SUBSTRING(par_caseno, 1, 3) <> ' HN' THEN
        SELECT
            CONCAT(RIGHT(CONCAT(REPEAT(' ', 04), RTRIM(SUBSTRING(par_caseno, 1, 4))), 4), SUBSTRING(par_caseno, 5, 8))
            INTO par_caseno;
    END IF;
    /* The first 2 digits does not used for check digit calculation */
    SELECT
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        INTO var_ck_digit_str;
    SELECT
        shift_factor
        INTO var_shift_factor
        FROM hospital
        WHERE hospital_code = par_hospital_code;
    /*
    For TMH, some of the old case no's shift factor is 0, but not 1
    the following routine reset the shift factor
    */
    IF par_hospital_code = 'TMH' THEN
        BEGIN
            IF SUBSTRING(par_caseno, 1, 3) = ' AE' AND SUBSTRING(par_caseno, 4, 2) < '93' AND SUBSTRING(par_caseno, 4, 2) > '80' THEN
                BEGIN
                    SELECT
                        SUBSTRING(par_caseno, 4, 8)
                        INTO var_aeno;

                    IF var_aeno < '92226791' OR var_aeno < '92900547' AND var_aeno >= '92900000' THEN
                        SELECT
                            0
                            INTO var_shift_factor;
                    END IF;
                END;
            ELSE
                IF SUBSTRING(par_caseno, 1, 3) = ' HN' AND SUBSTRING(par_caseno, 4, 2) < '93' AND SUBSTRING(par_caseno, 4, 2) > '80' THEN
                    BEGIN
                        SELECT
                            SUBSTRING(par_caseno, 4, 8)
                            INTO var_hnno;

                        IF var_hnno < '92028023' OR var_hnno < '92900118' AND var_hnno >= '92900000' OR var_hnno < '92800049' AND var_hnno >= '92800000' OR var_hnno < '92600026' AND var_hnno >= '92600000' THEN
                            SELECT
                                0
                                INTO var_shift_factor;
                        END IF;
                    END;
                ELSE
                    IF SUBSTRING(par_caseno, 5, 2) < '93' AND SUBSTRING(par_caseno, 5, 2) > '80' THEN
                        BEGIN
                            SELECT
                                SUBSTRING(par_caseno, 1, 4)
                                INTO var_opcode;
                            SELECT
                                SUBSTRING(par_caseno, 5, 7)
                                INTO var_opno;

                            IF var_opcode = ' ENT' AND var_opno < '9202168' OR var_opcode = ' GER' AND var_opno < '9203058' OR var_opcode = ' MED' AND var_opno < '9203180' OR var_opcode = ' PED' AND var_opno < '9203092' OR var_opcode = ' GYN' AND var_opno < '9203520' OR var_opcode = ' SUR' AND var_opno < '9204819' OR var_opcode = ' ORT' AND var_opno < '9204273' OR var_opcode = ' NEU' AND var_opno < '9200614' OR var_opcode = '  RT' AND var_opno < '9201503' THEN
                                SELECT
                                    0
                                    INTO var_shift_factor;
                            END IF;
                        END;
                    END IF;
                END IF;
            END IF;
        END;
    END IF;
    /*
    if substring(@caseno, 3, 1) = space(01)
       select @check_sum = 119 * 10
    else
    */
    SELECT
        (ASCII(SUBSTRING(par_caseno, 3, 1)) - 55) * 10
        INTO var_check_sum;

    IF SUBSTRING(par_caseno, 4, 1) >= '0' AND SUBSTRING(par_caseno, 4, 1) <= '9' THEN
        SELECT
            var_check_sum + CAST (SUBSTRING(par_caseno, 4, 1) AS INTEGER) * 9
            INTO var_check_sum;
    ELSE
        SELECT
            var_check_sum + (ASCII(SUBSTRING(par_caseno, 4, 1)) - 55) * 9
            INTO var_check_sum;
    END IF;
    SELECT
        5
        INTO var_idx;

    WHILE var_idx <= 11 LOOP
        SELECT
            var_check_sum + CAST (SUBSTRING(par_caseno, var_idx, 1) AS INTEGER) * (13 - var_idx)
            INTO var_check_sum;
        SELECT
            var_idx + 1
            INTO var_idx;
    END LOOP;
    SELECT
        (((11 - var_check_sum % 11) % 11 + var_shift_factor) % 36) + 1
        INTO var_check_sum;
    SELECT
        SUBSTRING(var_ck_digit_str, var_check_sum, 1)
        INTO var_check_digit;

    IF var_check_digit != SUBSTRING(par_caseno, 12, 1) THEN
        BEGIN
            SELECT
                'N'
                INTO par_valid_flag;
            pas_return_code := 2;
            RETURN;
        END;
    END IF;
    /* 20070611 check the case_no belong to same patient or NOT */
    IF (LTRIM(RTRIM(par_hkid)) = '') OR (LTRIM(RTRIM(par_hkid)) = NULL) THEN
        SELECT
            NULL
            INTO par_hkid;
    END IF;

    IF par_hkid IS NOT NULL THEN
        BEGIN
            IF EXISTS (SELECT
                case_no
                FROM pmi_case AS c, patient AS p
                WHERE c.patient_key = p.patient_key 
                	AND p.hkid = par_hkid 
                	AND c.hospital_code = par_hospital_code
                	AND c.case_no = par_caseno) THEN
                BEGIN
                    SELECT
                        'Y'
                        INTO par_valid_flag;
                    pas_return_code := 0;
                    RETURN;
                END;
            ELSE
                BEGIN
                    SELECT
                        'N'
                        INTO par_valid_flag;
                    pas_return_code := 3;
                    RETURN;
                END;
            END IF;
        END;
    END IF;
    /* 20070611 check the case_no belong to same patient or NOT */
    pas_return_code := 0;
    RETURN;
END;
$procedure$;

ALTER PROCEDURE "cpi_pq_validate_caseno" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

