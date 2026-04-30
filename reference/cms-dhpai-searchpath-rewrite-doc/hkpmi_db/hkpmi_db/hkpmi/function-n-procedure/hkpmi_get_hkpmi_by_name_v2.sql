-- DROP FUNCTION hkpmi.hkpmi_get_hkpmi_by_name_v2(bpchar, bpchar, timestamp, timestamp, int4, bpchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_hkpmi_by_name_v2(par_name varchar, par_sex varchar, par_from_dob timestamp without time zone, 
par_to_dob timestamp without time zone, par_authority_code integer, par_hosp_code varchar)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
    pas_return_code INTEGER;
/*
@name = name input from screen
@sex  = M, F, U / MU / FU / U
@from_dob, @to_dob  = if user has input age, place into from_dob, to_dob
                      else place null
*/
DECLARE
    var_temp_int INTEGER;
    var_err INTEGER;
    var_t_dob TIMESTAMP WITHOUT TIME ZONE;
    var_t_mrn VARCHAR(8);
    var_t_hkid VARCHAR(12);
    var_t_name VARCHAR(48);
    var_t_tel VARCHAR(10);
    var_t_sex VARCHAR(01);
    var_i INTEGER;
    var_t_cccode1 VARCHAR(5);
    var_t_cccode2 VARCHAR(5);
    var_t_cccode3 VARCHAR(5);
    var_t_cccode4 VARCHAR(5);
    var_t_cccode5 VARCHAR(5);
    var_t_cccode6 VARCHAR(5);
    var_cccode1 VARCHAR(5);
    var_cccode2 VARCHAR(5);
    var_cccode3 VARCHAR(5);
    var_cccode4 VARCHAR(5);
    var_cccode5 VARCHAR(5);
    var_cccode6 VARCHAR(5);
    var_hkid VARCHAR(12);
    var_chi_name VARCHAR(12);
    var_schi_name VARCHAR(12);
    var_is_schi_name VARCHAR(1);
    var_tmp_phonetic VARCHAR(48);
    
	pmi_csr_1 CURSOR FOR
    SELECT
        p.hkid, p.patient_name, p.sex, p.dob, h.mrn, p.phone1, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6
        FROM patient AS p
        LEFT OUTER JOIN patient_hospital_data AS h
            ON (p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code)
        WHERE p.patient_name LIKE par_name AND p.sex LIKE par_sex AND (p.access_code & par_authority_code) > 0;
   
	pmi_csr_2 CURSOR FOR
    SELECT
        p.hkid, p.patient_name, p.sex, p.dob, h.mrn, p.phone1, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6
        FROM patient AS p
        LEFT OUTER JOIN patient_hospital_data AS h
            ON (p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code)
        WHERE p.patient_name LIKE par_name AND p.sex LIKE par_sex AND p.dob >= par_from_dob AND p.dob <= par_to_dob AND (p.access_code & par_authority_code) > 0;
    csr CURSOR FOR
    SELECT
        hkid, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6
        FROM t$temp_patient_list;
    var_return_code int;
BEGIN
    <<return_error>>
    BEGIN
        SET search_path TO hkpmi, public;
        DROP TABLE IF EXISTS t$temp_patient_list;
        CREATE TEMPORARY TABLE t$temp_patient_list
        ("row_no" BIGINT GENERATED ALWAYS AS IDENTITY,
            /* ---- To fix: SRV 16  #311  The optimizer could not find a unique index which it could use to scan table '#temp_patient_list' for cursor 'csr'. */
            "hkid" VARCHAR(12) NULL,
            "name" VARCHAR(48) NULL,
            "sex" VARCHAR(1) NULL,
            "dob" TIMESTAMP WITHOUT TIME ZONE NULL,
            "mrn" VARCHAR(8) NULL,
            "phone1" VARCHAR(10) NULL,
            "cccode1" VARCHAR(05) NULL,
            "cccode2" VARCHAR(05) NULL,
            "cccode3" VARCHAR(05) NULL,
            "cccode4" VARCHAR(05) NULL,
            "cccode5" VARCHAR(05) NULL,
            "cccode6" VARCHAR(05) NULL,
            "chi_name" VARCHAR(12) NULL,
            "schi_name" VARCHAR(12) NULL);
        CREATE UNIQUE INDEX temp_patient_list_idx ON t$temp_patient_list
            ("row_no");
        SELECT
            CONCAT(RTRIM(par_name), '%'), CONCAT('[', RTRIM(par_sex), ']')
            INTO par_name, par_sex;
        CALL hkpmi_get_int_by_bit(pas_return_code, 'NNNNNNNNNNYYYYYYYYNNNNNNNNNNNNN', var_temp_int);
        SELECT
            par_authority_code & var_temp_int
            INTO par_authority_code;
        /* --- set rowcount  200 */
			SELECT
            0
            INTO var_i;
        IF par_from_dob = NULL THEN
            BEGIN
				OPEN pmi_csr_1;
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
            INSERT INTO t$temp_patient_list
            VALUES (var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6, NULL, NULL);
            SELECT
                var_i + 1
                INTO var_i;
        END LOOP;
        CLOSE pmi_csr_1;
            END;
        ELSE
            BEGIN
				OPEN pmi_csr_2;
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
            INSERT INTO t$temp_patient_list
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
            /* Get chinese name from ccc_big5 table */
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
            SET "chi_name" = var_chi_name, "schi_name" = var_schi_name
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
            hkid, name, sex, dob, mrn, phone1, chi_name, schi_name
            FROM t$temp_patient_list;
		return next p_refcur;
        /* ----set rowcount 0 */

        RETURN;
    END;

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

ALTER FUNCTION "hkpmi_get_hkpmi_by_name_v2" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
