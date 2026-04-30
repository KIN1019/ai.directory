-- DROP FUNCTION hkpmi.hkpmi_get_hkpmi_by_nok_v2(bpchar, bpchar, int4, bpchar, bpchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_hkpmi_by_nok_v2(par_nok_hkid varchar, par_nok_name varchar, par_authority_code integer, par_by varchar, par_hosp_code varchar)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_temp_int INTEGER;
    var_err INTEGER;
    var_t_dob TIMESTAMP WITHOUT TIME ZONE;
    var_t_mrn VARCHAR(16);
    var_t_hkid VARCHAR(24);
    var_t_name VARCHAR(96);
    var_t_tel VARCHAR(20);
    var_t_sex VARCHAR(2);
    var_i INTEGER;
    var_t_cccode1 VARCHAR(10);
    var_t_cccode2 VARCHAR(10);
    var_t_cccode3 VARCHAR(10);
    var_t_cccode4 VARCHAR(10);
    var_t_cccode5 VARCHAR(10);
    var_t_cccode6 VARCHAR(10);
    var_cccode1 VARCHAR(10);
    var_cccode2 VARCHAR(10);
    var_cccode3 VARCHAR(10);
    var_cccode4 VARCHAR(10);
    var_cccode5 VARCHAR(10);
    var_cccode6 VARCHAR(10);
    var_hkid VARCHAR(24);
    var_chi_name VARCHAR(24);
    var_schi_name VARCHAR(24);
    var_is_schi_name VARCHAR(2);
    var_tmp_phonetic VARCHAR(96);
    pas_return_code INTEGER;
    pmi_csr_1 CURSOR FOR
    SELECT
        p.hkid, p.patient_name, p.sex, p.dob, h.mrn, p.phone1, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6
        FROM nok AS n, patient AS p
        LEFT OUTER JOIN patient_hospital_data AS h
            ON (p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code)
        WHERE n.hkid = par_nok_hkid AND n.major_nok = 'Y' AND n.patient_key = p.patient_key AND (p.access_code & par_authority_code) > 0;
    pmi_csr_2 CURSOR FOR
    SELECT
        p.hkid, p.patient_name, p.sex, p.dob, h.mrn, p.phone1, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6
        FROM nok AS n, patient AS p
        LEFT OUTER JOIN patient_hospital_data AS h
            ON (p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code)
        WHERE n.nok_name LIKE par_nok_name AND n.major_nok = 'Y' AND n.patient_key = p.patient_key AND (p.access_code & par_authority_code) > 0;
    csr CURSOR FOR
    SELECT
        hkid, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6
        FROM t$temp_patient_list;
    var_return_code int;
BEGIN
    <<return_error>>
    BEGIN
        DROP TABLE IF EXISTS t$temp_patient_list;
        CREATE TEMPORARY TABLE t$temp_patient_list
        (row_no BIGINT GENERATED ALWAYS AS IDENTITY,
            /* ---- To fix: SRV 16  #311  The optimizer could not find a unique index which it could use to scan table '#temp_patient_list' for cursor 'csr'. */
            hkid VARCHAR(24) NULL,
            name VARCHAR(96) NULL,
            sex VARCHAR(2) NULL,
            dob TIMESTAMP WITHOUT TIME ZONE NULL,
            mrn VARCHAR(16) NULL,
            home_phone VARCHAR(20) NULL,
            cccode1 VARCHAR(10) NULL,
            cccode2 VARCHAR(10) NULL,
            cccode3 VARCHAR(10) NULL,
            cccode4 VARCHAR(10) NULL,
            cccode5 VARCHAR(10) NULL,
            cccode6 VARCHAR(10) NULL,
            chi_name VARCHAR(24) NULL,
            schi_name VARCHAR(24) NULL);
        CREATE UNIQUE INDEX temp_patient_list_idx ON t$temp_patient_list
            (row_no);
        CALL hkpmi_get_int_by_bit(pas_return_code, 'NNNNNNNNNNYYYYYYYYNNNNNNNNNNNNN', var_temp_int);
        SELECT
            par_authority_code & var_temp_int
            INTO par_authority_code;

        IF par_by = '3' THEN
            SELECT
                CONCAT(RTRIM(par_nok_name), '%')
                INTO par_nok_name;
        END IF;
        /* ---set rowcount  200 */
        IF par_by = '2' THEN
            /* --- by major nok hkid ----- */
			BEGIN
				OPEN pmi_csr_1;
                SELECT
                    0
                    INTO var_i;

                WHILE var_i < 200 LOOP
                    /* ---- set rowcount  200 */
                    FETCH pmi_csr_1 INTO var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6;

                    IF (CASE
                        WHEN FOUND THEN 0
                        WHEN NOT FOUND THEN 2
                        ELSE 1
                    END) != 0 THEN
                        EXIT;
                    END IF;
                    INSERT INTO t$temp_patient_list  (hkid, name,sex,dob,mrn,home_phone,cccode1,cccode2,cccode3,cccode4,cccode5,cccode6,chi_name,schi_name)
                    VALUES (var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6, NULL, NULL);
                    SELECT
                        var_i + 1
                        INTO var_i;
                END LOOP;
                CLOSE pmi_csr_1;
            END;
        ELSE
            /* ----- by major nok name ---- */
            BEGIN
			    OPEN pmi_csr_2;
                SELECT
                    0
                    INTO var_i;

                WHILE var_i < 200 LOOP
                    /* ---- set rowcount  200 */
                    FETCH pmi_csr_2 INTO var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6;

                    IF (CASE
                        WHEN FOUND THEN 0
                        WHEN NOT FOUND THEN 2
                        ELSE 1
                    END) != 0 THEN
                        EXIT;
                    END IF;
                    INSERT INTO t$temp_patient_list (hkid, name,sex,dob,mrn,home_phone,cccode1,cccode2,cccode3,cccode4,cccode5,cccode6,chi_name,schi_name)
                    VALUES (var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6, NULL, NULL);
                    SELECT
                        var_i + 1
                        INTO var_i;
                END LOOP;
                CLOSE pmi_csr_2;
            END;
        END IF;
        
        /* ---------chi_name/schi_name ------- */
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_hkid, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6;
        OPEN csr;
        FETCH csr INTO var_hkid, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            /* Get chinese name from ccc_big5 -> ccc_unicode table */
            BEGIN
                CALL cpi_get_phonetic_chin_name(var_return_code, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_tmp_phonetic, var_chi_name);
                var_err := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_err := 1;
            END;

            IF var_err <> 0 THEN
                EXIT return_error;
            END IF;
            SELECT
                NULL
                INTO var_schi_name;

            IF COALESCE(var_chi_name, '') <> '' THEN
                BEGIN
                    CALL hkpmi_check_schi_name(pas_return_code => pas_return_code, par_ccc1 => var_cccode1, par_ccc2 => var_cccode2, par_ccc3 => var_cccode3, par_ccc4 => var_cccode4, par_ccc5 => var_cccode5, par_ccc6 => var_cccode6, par_is_schi_name => var_is_schi_name);

                    IF var_is_schi_name = 'Y' THEN
                        BEGIN
                            SELECT
                                var_chi_name
                                INTO var_schi_name;
                            SELECT
                                NULL
                                INTO var_chi_name;
                        END;
                    END IF;
                END;
            END IF;
            UPDATE t$temp_patient_list
            SET chi_name = var_chi_name, schi_name = var_schi_name
                WHERE CURRENT OF csr;
            /* ---where hkid = @hkid */
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_hkid, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6;
            FETCH csr INTO var_hkid, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6;
        END LOOP;
        CLOSE csr;
        OPEN p_refcur FOR
        SELECT
            hkid, name, sex, dob, mrn, home_phone, chi_name, schi_name
            FROM t$temp_patient_list;
      	return next p_refcur;
        /* ----set rowcount 0 */

        RETURN;
    END;
    -- DROP TABLE t$temp_patient_list;

    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$temp_patient_list;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;


ALTER FUNCTION "hkpmi_get_hkpmi_by_nok_v2" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
