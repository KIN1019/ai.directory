-- DROP PROCEDURE hpi.hasp_web_get_strange_name(inout int4, in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_web_get_strange_name(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_from_date timestamp without time zone, IN par_to_date timestamp without time zone, IN par_input_type character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_case         VARCHAR(24);
    var_spec         VARCHAR(8);
    var_ward         VARCHAR(8);
    var_tx_date      TIMESTAMP WITHOUT TIME ZONE;
    var_hkid         VARCHAR(24);
    var_name         VARCHAR(96);
    var_ccc1         VARCHAR(10);
    var_ccc2         VARCHAR(10);
    var_ccc3         VARCHAR(10);
    var_ccc4         VARCHAR(10);
    var_ccc5         VARCHAR(10);
    var_ccc6         VARCHAR(10);
    var_sex          VARCHAR(2);
    var_dob          TIMESTAMP WITHOUT TIME ZONE;
    var_name_flag    VARCHAR(2);
    var_name_count   INTEGER;
    var_pos          INTEGER;
    var_name_rest    VARCHAR(96);
    var_chi_char1    VARCHAR(4);
    var_chi_char2    VARCHAR(4);
    var_chi_char3    VARCHAR(4);
    var_chi_char4    VARCHAR(4);
    var_chi_char5    VARCHAR(4);
    var_chi_char6    VARCHAR(4);
    var_chi_name     VARCHAR(24);
    var_name_err     VARCHAR(2);
    var_chi_name_err VARCHAR(2);
    var_schi_name    VARCHAR(24);
    var_is_schi_name VARCHAR(2);
    var_phonetic     VARCHAR(96);
    var_unicode_int1 INTEGER;
    var_unicode_int2 INTEGER;
    var_unicode_int3 INTEGER;
    var_unicode_int4 INTEGER;
    var_unicode_int5 INTEGER;
    var_unicode_int6 INTEGER;
    csr CURSOR FOR
        SELECT Case_no,
               From_ward_code,
               From_specialty_code,
               Transaction_datetime
        FROM Transaction_log
        WHERE Transaction_datetime >= par_from_date
          AND Transaction_datetime < 1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
          AND Cancel_flag IS NULL
          AND Transaction_type = par_input_type
          AND Hospital_code = par_hospital_code;
BEGIN
    /* 2006-09-18 Addeded by HK Fong SMR20015696 - Start */
    /* 2006-09-18 Addeded by HK Fong SMR20015696 - End */
	DROP TABLE IF EXISTS t$str_name;
    CREATE TEMPORARY TABLE t$str_name
    (
        hkid         VARCHAR(24),
        name         VARCHAR(96),
        ccc1         VARCHAR(10)  NULL,
        ccc2         VARCHAR(10)  NULL,
        ccc3         VARCHAR(10)  NULL,
        ccc4         VARCHAR(10)  NULL,
        ccc5         VARCHAR(10)  NULL,
        ccc6         VARCHAR(10)  NULL,
        chi_name     VARCHAR(24) NULL,
        case_no      VARCHAR(24),
        adm_date     TIMESTAMP WITHOUT TIME ZONE,
        adm_ward     VARCHAR(8),
        adm_spec     VARCHAR(8),
        name_err     VARCHAR(2),
        chi_name_err VARCHAR(2),
        schi_name    VARCHAR(24) NULL, /* 2006-09-18 Addeded by HK Fong SMR20015696 */
        unicode_int1 INTEGER     NULL,
        unicode_int2 INTEGER     NULL,
        unicode_int3 INTEGER     NULL,
        unicode_int4 INTEGER     NULL,
        unicode_int5 INTEGER     NULL,
        unicode_int6 INTEGER     NULL
    );
    CREATE UNIQUE INDEX str_index_unique ON t$str_name
        (hkid, case_no, adm_date);
    OPEN csr;
    FETCH csr INTO var_case, var_ward, var_spec, var_tx_date;

    WHILE (CASE
               WHEN FOUND THEN 0
               WHEN NOT FOUND THEN 2
               ELSE 1
        END) = 0
        LOOP
            SELECT HKID
            INTO var_hkid
            FROM Case_view
            WHERE Case_no = var_case
              AND Hospital_code = par_hospital_code;
            SELECT Name,
                   Sex,
                   DOB,
                   CCC_1,
                   CCC_2,
                   CCC_3,
                   CCC_4,
                   CCC_5,
                   CCC_6
            INTO var_name, var_sex, var_dob, var_ccc1, var_ccc2, var_ccc3, var_ccc4, var_ccc5, var_ccc6
            FROM PMI
            WHERE HKID = var_hkid
              AND PMI_hospital_code = par_hospital_code;
            SELECT 'N',
                   1,
                   'N',
                   'N'
            INTO var_name_flag, var_name_count, var_name_err, var_chi_name_err;

            WHILE var_name_count <= 48
                LOOP
                    IF SAFE_SUBSTRING(var_name, var_name_count, 1) = ',' THEN
                        SELECT var_name_count + 1
                        INTO var_pos;
                    END IF;
                    SELECT var_name_count + 1
                    INTO var_name_count;
                END LOOP;
            SELECT SAFE_SUBSTRING(RTRIM(var_name), var_pos, 49 - var_pos)
            INTO var_name_rest;

            IF (var_name_rest IS null or length(var_name_rest) = 0) AND (var_name <> 'UNKNOWN,' OR var_name IS NULL) THEN
                SELECT 'Y',
                       'Y'
                INTO var_name_flag, var_name_err;
            END IF;

            IF var_ccc5 IS NOT NULL THEN
                BEGIN
                    IF NOT ((var_ccc3 = '00371' AND var_ccc5 IN ('13111', '11661') AND var_ccc4 IN
                                                                                       ('11291', '00591', '00051',
                                                                                        '09341', '00631', '03621',
                                                                                        '00031', '03601', '00461',
                                                                                        '05771')) OR
                            (var_ccc4 = '00371' AND var_ccc6 IN ('13111', '11661') AND var_ccc5 IN
                                                                                       ('11291', '00591', '00051',
                                                                                        '09341', '00631', '03621',
                                                                                        '00031', '03601', '00461',
                                                                                        '05771')) OR
                            (var_ccc4 = '00371' AND var_ccc5 IN ('13111', '11661')) OR
                            (var_ccc5 = '00371' AND var_ccc6 IN ('13111', '11661'))) THEN
                        SELECT 'Y',
                               'Y'
                        INTO var_name_flag, var_chi_name_err;
                    END IF;
                END;
            END IF;

            IF var_name_flag = 'Y' THEN
                BEGIN
                    SELECT NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL
                    INTO var_unicode_int1, var_unicode_int2, var_unicode_int3, var_unicode_int4, var_unicode_int5, var_unicode_int6;

                    IF var_ccc1 IS NOT NULL THEN
                        SELECT Unicode_int
                        INTO var_unicode_int1
                        FROM ccc_unicode
                        WHERE CCC_head = SAFE_SUBSTRING(var_ccc1, 1, 4)
                          AND CCC_tail = SAFE_SUBSTRING(var_ccc1, 5, 1);
                    END IF;

                    IF var_ccc2 IS NOT NULL THEN
                        SELECT Unicode_int
                        INTO var_unicode_int2
                        FROM ccc_unicode
                        WHERE CCC_head = SAFE_SUBSTRING(var_ccc2, 1, 4)
                          AND CCC_tail = SAFE_SUBSTRING(var_ccc2, 5, 1);
                    END IF;

                    IF var_ccc3 IS NOT NULL THEN
                        SELECT Unicode_int
                        INTO var_unicode_int3
                        FROM ccc_unicode
                        WHERE CCC_head = SAFE_SUBSTRING(var_ccc3, 1, 4)
                          AND CCC_tail = SAFE_SUBSTRING(var_ccc3, 5, 1);
                    END IF;

                    IF var_ccc4 IS NOT NULL THEN
                        SELECT Unicode_int
                        INTO var_unicode_int4
                        FROM ccc_unicode
                        WHERE CCC_head = SAFE_SUBSTRING(var_ccc4, 1, 4)
                          AND CCC_tail = SAFE_SUBSTRING(var_ccc4, 5, 1);
                    END IF;

                    IF var_ccc5 IS NOT NULL THEN
                        SELECT Unicode_int
                        INTO var_unicode_int5
                        FROM ccc_unicode
                        WHERE CCC_head = SAFE_SUBSTRING(var_ccc5, 1, 4)
                          AND CCC_tail = SAFE_SUBSTRING(var_ccc5, 5, 1);
                    END IF;

                    IF var_ccc6 IS NOT NULL THEN
                        SELECT Unicode_int
                        INTO var_unicode_int6
                        FROM ccc_unicode
                        WHERE CCC_head = SAFE_SUBSTRING(var_ccc6, 1, 4)
                          AND CCC_tail = SAFE_SUBSTRING(var_ccc6, 5, 1);
                    END IF;
                    SELECT ''
                    INTO var_chi_name;
                    SELECT ''
                    INTO var_schi_name;
                    /*
                    /* 2006-09-18 Addeded by HK Fong SMR20015696 - Start */
                    if IsNull(@chi_name, '') <> ''
                    begin
                        exec hasp_check_schi_name
                            @ccc1 = @ccc1, @ccc2 = @ccc2, @ccc3 = @ccc3,
                            @ccc4 = @ccc4, @ccc5 = @ccc5, @ccc6 = @ccc6,
                            @is_schi_name = @is_schi_name output
                        if @is_schi_name = 'Y'
                            select @schi_name = @chi_name
                        else
                            select @schi_name = ''
                    end
                    else
                        select @schi_name = ''
                    /* 2006-09-18 Addeded by HK Fong SMR20015696 - End */
                    */
                    INSERT INTO t$str_name
                    VALUES (var_hkid, var_name, var_ccc1, var_ccc2, var_ccc3, var_ccc4, var_ccc5, var_ccc6,
                            var_chi_name, var_case, var_tx_date, var_ward, var_spec, var_name_err, var_chi_name_err,
                            var_schi_name, /* 2006-09-18 Addeded by HK Fong SMR20015696 */ var_unicode_int1,
                            var_unicode_int2, var_unicode_int3, var_unicode_int4, var_unicode_int5, var_unicode_int6);
                END;
            END IF;
            FETCH csr INTO var_case, var_ward, var_spec, var_tx_date;
        END LOOP;
    CLOSE csr;
    /* Adaptive Server has expanded all '*' elements in the following statement */
    OPEN p_refcur FOR
        SELECT t$str_name.hkid,
               t$str_name.name,
               t$str_name.ccc1,
               t$str_name.ccc2,
               t$str_name.ccc3,
               t$str_name.ccc4,
               t$str_name.ccc5,
               t$str_name.ccc6,
               t$str_name.chi_name,
               t$str_name.case_no,
               t$str_name.adm_date,
               t$str_name.adm_ward,
               t$str_name.adm_spec,
               t$str_name.name_err,
               t$str_name.chi_name_err,
               t$str_name.schi_name,
               t$str_name.unicode_int1,
               t$str_name.unicode_int2,
               t$str_name.unicode_int3,
               t$str_name.unicode_int4,
               t$str_name.unicode_int5,
               t$str_name.unicode_int6
        FROM t$str_name ORDER BY t$str_name.hkid,t$str_name.case_no,t$str_name.adm_date;
    pas_return_code := 0;
    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$str_name;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$procedure$
;

;ALTER PROCEDURE "hasp_web_get_strange_name" OWNER TO "HPI_SCHEMA_OWNER_ROLE";