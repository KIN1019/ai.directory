-- DROP FUNCTION hkpmi.hkpmi_get_pat_postal_by_hkid(varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_pat_postal_by_hkid(par_hkid_list1 character varying, par_hkid_list2 character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
    var_string VARCHAR(255);
    var_pos NUMERIC(20, 0);
    var_piece VARCHAR(50);
    var_count INTEGER;
    var_max_loop_count INTEGER;
    var_loop_count INTEGER;
    var_hkid CHAR(12);
    var_patient_key CHAR(8);
    var_patient_name CHAR(48);
    var_cccode1 CHAR(5);
    var_cccode2 CHAR(5);
    var_cccode3 CHAR(5);
    var_cccode4 CHAR(5);
    var_cccode5 CHAR(5);
    var_cccode6 CHAR(5);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag CHAR(1);
    var_sex CHAR(1);
    var_marital_status CHAR(1);
    var_hkic_symbol CHAR(1);
    var_r_district CHAR(15);
    var_r_building VARCHAR(255);
    var_r_block CHAR(2);
    var_r_floor CHAR(2);
    var_r_room CHAR(5);
    var_c_district CHAR(15);
    var_c_building VARCHAR(255);
    var_c_block CHAR(5);
    var_c_floor CHAR(5);
    var_c_room CHAR(5);
    var_r_chi_district CHAR(30);
    var_r_chi_building VARCHAR(255);
    var_c_chi_district CHAR(30);
    var_c_chi_building VARCHAR(255);
    var_addr_code INTEGER;
    var_address_eng VARCHAR(255);
    var_address_chi VARCHAR(255);
    var_district_chi CHAR(30);
    var_eh_eng VARCHAR(255);
    var_eh_chi VARCHAR(255);
    patient_cursor CURSOR FOR
    SELECT
        p.hkid, p.patient_key, p.patient_name, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6, p.dob, p.exact_dob_flag, p.sex, p.marital_status, SUBSTRING(p.filler, 3, 1) AS "HKIC symbol code", d1.district_name, p.building, p.block, p.floor, p.room, d2.district_name, h.building, h.block, h.floor, h.room
        FROM t$temp_hkid AS t, hkpmi.patient AS p
        LEFT OUTER JOIN hkpmi.district AS d1
            ON (p.district = d1.district_code)
        LEFT OUTER JOIN hkpmi.hkpmi_patient_address_list AS h
            ON (p.patient_key = h.patient_key)
        LEFT OUTER JOIN hkpmi.district AS d2
            ON (h.district_code = d2.district_code)
        WHERE t.hkid = p.hkid;
BEGIN
   
    drop table if exists t$temp_hkid;
    CREATE TEMPORARY TABLE t$temp_hkid
    (hkid CHAR(12) NULL);
    SELECT
        30, 0
        INTO var_max_loop_count, var_loop_count;
    SELECT
        par_hkid_list1
        INTO var_string;
    var_pos := STRPOS(var_string, ',');

    WHILE var_pos <> 0 AND (var_loop_count < var_max_loop_count) LOOP
        var_piece := LEFT(var_string, var_pos - 1);
        INSERT INTO t$temp_hkid
        SELECT
            var_piece;
        var_string := OVERLAY(var_string PLACING NULL FROM 1 FOR var_pos);
        var_pos := STRPOS(var_string, ',');
        SELECT
            var_loop_count + 1
            INTO var_loop_count;
    END LOOP;
    INSERT INTO t$temp_hkid
    SELECT
        var_string;

    IF par_hkid_list2 IS NOT NULL AND par_hkid_list2 != '' THEN
        BEGIN
            SELECT
                par_hkid_list2
                INTO var_string;
            var_pos := STRPOS(var_string, ',');
            SELECT
                30, 0
                INTO var_max_loop_count, var_loop_count;

            WHILE var_pos <> 0 AND (var_loop_count < var_max_loop_count) LOOP
                var_piece := LEFT(var_string, var_pos - 1);
                INSERT INTO t$temp_hkid
                SELECT
                    var_piece;
                var_string := OVERLAY(var_string PLACING NULL FROM 1 FOR var_pos);
                var_pos := STRPOS(var_string, ',');
            END LOOP;
            INSERT INTO t$temp_hkid
            SELECT
                var_string;
            SELECT
                var_loop_count + 1
                INTO var_loop_count;
        END;
    END IF;
    SELECT
        COUNT(1)
        INTO var_count
        FROM t$temp_hkid;

    IF var_count > 30 THEN
        BEGIN
            RAISE EXCEPTION '%', format('Maximum number of HKID input is 30, your input (number of HKID input: %s) is exceeding the range!', var_count) USING ERRCODE = '99999';
            -- return_code := 0;
            RETURN;
        END;
    END IF;
    drop table if exists t$result;
    CREATE TEMPORARY TABLE t$result
    ("hkid" CHAR(12),
        "patient_key" CHAR(8),
        "patient_name" CHAR(48),
        "cccode1" CHAR(5) NULL,
        "cccode2" CHAR(5) NULL,
        "cccode3" CHAR(5) NULL,
        "cccode4" CHAR(5) NULL,
        "cccode5" CHAR(5) NULL,
        "cccode6" CHAR(5) NULL,
        "dob" TIMESTAMP WITHOUT TIME ZONE NULL,
        "exact_dob_flag" CHAR(1),
        "sex" CHAR(1),
        "marital_status" CHAR(1),
        "hkic_symbol" CHAR(1) NULL,
        "r_district" CHAR(15) NULL,
        "r_building" VARCHAR(255) NULL,
        "r_block" CHAR(2) NULL,
        "r_floor" CHAR(2) NULL,
        "r_room" CHAR(5) NULL,
        "c_district" CHAR(15) NULL,
        "c_building" VARCHAR(255) NULL,
        "c_block" CHAR(5) NULL,
        "c_floor" CHAR(5) NULL,
        "c_room" CHAR(5) NULL,
        "r_chi_district" CHAR(30) NULL,
        "r_chi_building" VARCHAR(255) NULL,
        "c_chi_district" CHAR(30) NULL,
        "c_chi_building" VARCHAR(255) NULL);
    OPEN patient_cursor;
    FETCH patient_cursor INTO var_hkid, var_patient_key, var_patient_name, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_dob, var_exact_dob_flag, var_sex, var_marital_status, var_hkic_symbol, var_r_district, var_r_building, var_r_block, var_r_floor, var_r_room, var_c_district, var_c_building, var_c_block, var_c_floor, var_c_room;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            NULL
            INTO var_r_chi_district;
        SELECT
            NULL
            INTO var_r_chi_building;

        IF SUBSTRING(var_r_building, 1, 7) = 'HACODE:' THEN
            BEGIN
                SELECT
                    CAST (RIGHT(RTRIM(var_r_building), CHAR_LENGTH(RTRIM(var_r_building)) - 7) AS INTEGER)
                    INTO var_addr_code;
                SELECT
                    ''
                    INTO var_address_eng;
                SELECT
                    ''
                    INTO var_address_chi;
                SELECT
                    ''
                    INTO var_district_chi;
                SELECT
                    ''
                    INTO var_eh_eng;
                SELECT
                    ''
                    INTO var_eh_chi;
                SELECT
                    ''
                    INTO var_r_building;
                SELECT
                    concat((CASE
                        WHEN bldg_eng IS NULL THEN NULL
                        ELSE concat(RTRIM(bldg_eng), (CASE
                            WHEN CONCAT(estate_eng, street_eng) IS NULL THEN NULL
                            ELSE ', '
                        END))
                    END), (CASE
                        WHEN estate_eng IS NULL THEN NULL
                        ELSE concat(RTRIM(estate_eng), (CASE
                            WHEN street_eng IS NULL THEN NULL
                            ELSE ', '
                        END))
                    END), (CASE
                        WHEN house_no IS NULL THEN NULL
                        ELSE CONCAT(RTRIM(house_no), ' ')
                    END), (CASE
                        WHEN street_eng IS NULL THEN NULL
                        ELSE RTRIM(street_eng)
                    END)),
                    /* rtrim(area_chi) + rtrim(district_chi) + */
                    concat((CASE
                        WHEN street_chi IS NULL THEN NULL
                        ELSE RTRIM(street_chi)
                    END), (CASE
                        WHEN house_no IS NULL THEN NULL
                        ELSE CONCAT(RTRIM(house_no),CHR(184),CHR(185))
                    END), (CASE
                        WHEN estate_chi IS NULL THEN NULL
                        ELSE RTRIM(estate_chi)
                    END), (CASE
                        WHEN bldg_chi IS NULL THEN NULL
                        ELSE RTRIM(bldg_chi)
                    END)), b.district_chi, d.eh_name, d.eh_chinese_name
                    INTO var_address_eng, var_address_chi, var_district_chi, var_eh_eng, var_eh_chi
                    FROM hkpmi.district AS b, hkpmi.district_area AS c, hkpmi.address_detail AS a
                    LEFT OUTER JOIN hkpmi.elderly_home_table AS d
                        ON (record_id = d.eh_address_id)
                    WHERE record_id = var_addr_code AND a.district_code = b.district_code AND b.district_area = c.area_code;
                SELECT
                    var_district_chi
                    INTO var_r_chi_district;

                IF var_eh_eng != '' AND var_eh_eng IS NOT NULL THEN
                    SELECT
                        CONCAT(var_eh_eng, '-', var_address_eng)
                        INTO var_r_building;
                ELSE
                    SELECT
                        var_address_eng
                        INTO var_r_building;
                END IF;

                IF var_eh_chi != '' AND var_eh_chi IS NOT NULL THEN
                    SELECT
                        CONCAT(var_eh_chi, '-', var_address_chi)
                        INTO var_r_chi_building;
                ELSE
                    SELECT
                        var_address_chi
                        INTO var_r_chi_building;
                END IF;
            END;
        END IF;
        SELECT
            NULL
            INTO var_c_chi_district;
        SELECT
            NULL
            INTO var_c_chi_building;

        IF SUBSTRING(var_c_building, 1, 7) = 'HACODE:' THEN
            BEGIN
                SELECT
                    CAST (RIGHT(RTRIM(var_c_building), CHAR_LENGTH(RTRIM(var_c_building)) - 7) AS INTEGER)
                    INTO var_addr_code;
                SELECT
                    ''
                    INTO var_address_eng;
                SELECT
                    ''
                    INTO var_address_chi;
                SELECT
                    ''
                    INTO var_district_chi;
                SELECT
                    ''
                    INTO var_eh_eng;
                SELECT
                    ''
                    INTO var_eh_chi;
                SELECT
                    ''
                    INTO var_c_building;
                SELECT
                    concat((CASE
                        WHEN bldg_eng IS NULL THEN NULL
                        ELSE concat(RTRIM(bldg_eng), (CASE
                            WHEN CONCAT(estate_eng, street_eng) IS NULL THEN NULL
                            ELSE ', '
                        END))
                    END), (CASE
                        WHEN estate_eng IS NULL THEN NULL
                        ELSE concat(RTRIM(estate_eng), (CASE
                            WHEN street_eng IS NULL THEN NULL
                            ELSE ', '
                        END))
                    END), (CASE
                        WHEN house_no IS NULL THEN NULL
                        ELSE CONCAT(RTRIM(house_no), ' ')
                    END), (CASE
                        WHEN street_eng IS NULL THEN NULL
                        ELSE RTRIM(street_eng)
                    END)),
                    /* rtrim(area_chi) + rtrim(district_chi) + */
                    concat((CASE
                        WHEN street_chi IS NULL THEN NULL
                        ELSE RTRIM(street_chi)
                    END), (CASE
                        WHEN house_no IS NULL THEN NULL
                        ELSE CONCAT(RTRIM(house_no), CHR(184), CHR(185))
                    END), (CASE
                        WHEN estate_chi IS NULL THEN NULL
                        ELSE RTRIM(estate_chi)
                    END), (CASE
                        WHEN bldg_chi IS NULL THEN NULL
                        ELSE RTRIM(bldg_chi)
                    END)), b.district_chi, d.eh_name, d.eh_chinese_name
                    INTO var_address_eng, var_address_chi, var_district_chi, var_eh_eng, var_eh_chi
                    FROM hkpmi.district AS b, hkpmi.district_area AS c, hkpmi.address_detail AS a
                    LEFT OUTER JOIN hkpmi.elderly_home_table AS d
                        ON (record_id = d.eh_address_id)
                    WHERE record_id = var_addr_code AND a.district_code = b.district_code AND b.district_area = c.area_code;
                SELECT
                    var_district_chi
                    INTO var_c_chi_district;

                IF var_eh_eng != '' AND var_eh_eng IS NOT NULL THEN
                    SELECT
                        CONCAT(var_eh_eng, '-', var_address_eng)
                        INTO var_c_building;
                ELSE
                    SELECT
                        var_address_eng
                        INTO var_c_building;
                END IF;

                IF var_eh_chi != '' AND var_eh_chi IS NOT NULL THEN
                    SELECT
                        CONCAT(var_eh_chi, '-', var_address_chi)
                        INTO var_c_chi_building;
                ELSE
                    SELECT
                        var_address_chi
                        INTO var_c_chi_building;
                END IF;
            END;
        END IF;
        INSERT INTO t$result (hkid, patient_key, patient_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, dob, exact_dob_flag, sex, marital_status, hkic_symbol, r_district, r_building, r_block, r_floor, r_room, c_district, c_building, c_block, c_floor, c_room, r_chi_district, r_chi_building, c_chi_district, c_chi_building)
        VALUES (var_hkid, var_patient_key, var_patient_name, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_dob, var_exact_dob_flag, var_sex, var_marital_status, var_hkic_symbol, var_r_district, var_r_building, var_r_block, var_r_floor, var_r_room, var_c_district, var_c_building, var_c_block, var_c_floor, var_c_room, var_r_chi_district, var_r_chi_building, var_c_chi_district, var_c_chi_building);
        FETCH patient_cursor INTO var_hkid, var_patient_key, var_patient_name, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_dob, var_exact_dob_flag, var_sex, var_marital_status, var_hkic_symbol, var_r_district, var_r_building, var_r_block, var_r_floor, var_r_room, var_c_district, var_c_building, var_c_block, var_c_floor, var_c_room;
    END LOOP;
    CLOSE patient_cursor;
    /* Adaptive Server has expanded all '*' elements in the following statement */
    OPEN p_refcur FOR
    SELECT
        t$result.hkid, t$result.patient_key, t$result.patient_name, t$result.cccode1, t$result.cccode2, t$result.cccode3, t$result.cccode4, t$result.cccode5, t$result.cccode6, t$result.dob, t$result.exact_dob_flag, t$result.sex, t$result.marital_status, t$result.hkic_symbol, t$result.r_district, t$result.r_building, t$result.r_block, t$result.r_floor, t$result.r_room, t$result.c_district, t$result.c_building, t$result.c_block, t$result.c_floor, t$result.c_room, t$result.r_chi_district, t$result.r_chi_building, t$result.c_chi_district, t$result.c_chi_building
        FROM t$result;
    RETURN NEXT p_refcur;
END;
$function$
;

ALTER FUNCTION "hkpmi_get_pat_postal_by_hkid" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
