-- DROP FUNCTION hasp_web_letter_to_patient(varchar, timestamp, timestamp, varchar, varchar);

CREATE OR REPLACE FUNCTION hasp_web_letter_to_patient(par_hospital_code character varying, par_input_from_date timestamp without time zone, par_input_to_date timestamp without time zone, par_input_case_no character varying, par_input_hkid character varying)
 RETURNS TABLE(nok_name character varying, nok_chi_name character varying, building character varying, room character varying, floor character varying, block character varying, district_code character varying, name character varying, chi_name character varying, race_code character varying, hkid character varying, hospital_name character varying, hospital_chi_name character varying, hospital_address character varying, hospital_chi_address character varying, dept character varying, dept_chi character varying, fax_no character varying, phone_no character varying, nok_schi_name character varying, schi_name character varying, nok_int1 integer, nok_int2 integer, nok_int3 integer, nok_int4 integer, nok_int5 integer, nok_int6 integer, baby_int1 integer, baby_int2 integer, baby_int3 integer, baby_int4 integer, baby_int5 integer, baby_int6 integer)
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_count                INT;
    var_return_code          INT;
    var_record               RECORD;
    var_hkid                 VARCHAR(12);
    var_cccode1              VARCHAR(5);
    var_cccode2              VARCHAR(5);
    var_cccode3              VARCHAR(5);
    var_cccode4              VARCHAR(5);
    var_cccode5              VARCHAR(5);
    var_cccode6              VARCHAR(5);
    var_race_code            VARCHAR(2);
    var_building             VARCHAR(240);
    var_district_code        VARCHAR(5);
    var_nok_name             VARCHAR(48);
    var_nok_chi_name         VARCHAR(12);
    var_nok_hkid             VARCHAR(12);
    var_pcccode1             VARCHAR(5);
    var_pcccode2             VARCHAR(5);
    var_pcccode3             VARCHAR(5);
    var_pcccode4             VARCHAR(5);
    var_pcccode5             VARCHAR(5);
    var_pcccode6             VARCHAR(5);
    var_address_eng          VARCHAR(255);
    var_address_chi          VARCHAR(255);
    var_district             VARCHAR(5);
    var_eh_eng               VARCHAR(255);
    var_eh_chi               VARCHAR(255);
    var_hospital_name        VARCHAR(100);
    var_hospital_chi_name    VARCHAR(100);
    var_hospital_address     VARCHAR(100);
    var_hospital_chi_address VARCHAR(100);
    var_dept                 VARCHAR(100);
    var_dept_chi             VARCHAR(100);
    var_fax_no               VARCHAR(20);
    var_phone_no             VARCHAR(20);
    var_last_print_date      TIMESTAMP WITHOUT TIME ZONE;
    var_schi_name            VARCHAR(12);
    var_nok_schi_name        VARCHAR(12);
    var_is_schi_name         VARCHAR(1);
    var_record_id            INT;
    var_phonetic             VARCHAR(48);
    var_chi_name             VARCHAR(12); -- Declare var_chi_name
BEGIN
    -- Adjust input_to_date
    IF par_input_to_date IS NOT NULL THEN
        par_input_to_date := par_input_to_date + INTERVAL '1 day';
    END IF;

    -- Create temporary table
    DROP TABLE IF EXISTS t$temp_letter_info;
    CREATE TEMP TABLE t$temp_letter_info
    (
        nok_name      VARCHAR(48),
        nok_chi_name  VARCHAR(12),
        nok_hkid      VARCHAR(12),
        building      VARCHAR(240),
        room          VARCHAR(5),
        floor         VARCHAR(2),
        block         VARCHAR(2),
        district_code VARCHAR(5),
        name          VARCHAR(48),
        chi_name      VARCHAR(12),
        cccode1       VARCHAR(5),
        cccode2       VARCHAR(5),
        cccode3       VARCHAR(5),
        cccode4       VARCHAR(5),
        cccode5       VARCHAR(5),
        cccode6       VARCHAR(5),
        race_code     VARCHAR(2),
        hkid          VARCHAR(12),
        case_no       VARCHAR(12),
        nok_schi_name VARCHAR(12),
        schi_name     VARCHAR(12)
    );

    -- Insert logic based on conditions
    IF par_input_hkid IS NOT NULL THEN
        INSERT INTO t$temp_letter_info (hkid, case_no, name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6,
                                        race_code, building, room, floor, block, district_code)
        SELECT c.hkid,
               c.case_no,
               p.name,
               p.ccc_1,
               p.ccc_2,
               p.ccc_3,
               p.ccc_4,
               p.ccc_5,
               p.ccc_6,
               p.race_code,
               p.building,
               p.room,
               p.floor,
               p.block,
               p.district_code
        FROM case_view c
                 JOIN pmi_wo_mrn p ON c.hkid = p.hkid
        WHERE c.hospital_code = par_hospital_code
          AND c.hkid = par_input_hkid
          AND c.source_indicator = '8'
          AND c.case_type = 'I'
          AND COALESCE(p.death_indicator, 'N') = 'N';
    ELSIF par_input_case_no IS NOT NULL THEN
        INSERT INTO t$temp_letter_info (hkid, case_no, name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6,
                                        race_code, building, room, floor, block, district_code)
        SELECT c.hkid,
               c.case_no,
               p.name,
               p.ccc_1,
               p.ccc_2,
               p.ccc_3,
               p.ccc_4,
               p.ccc_5,
               p.ccc_6,
               p.race_code,
               p.building,
               p.room,
               p.floor,
               p.block,
               p.district_code
        FROM case_view c
                 JOIN pmi_wo_mrn p ON c.hkid = p.hkid
        WHERE c.hospital_code = par_hospital_code
          AND c.case_no = par_input_case_no
          AND c.source_indicator = '8'
          AND c.case_type = 'I'
          AND COALESCE(p.death_indicator, 'N') = 'N';
    ELSE
        INSERT INTO t$temp_letter_info (hkid, case_no, name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6,
                                        race_code, building, room, floor, block, district_code)
        SELECT c.hkid,
               c.case_no,
               p.name,
               p.ccc_1,
               p.ccc_2,
               p.ccc_3,
               p.ccc_4,
               p.ccc_5,
               p.ccc_6,
               p.race_code,
               p.building,
               p.room,
               p.floor,
               p.block,
               p.district_code
        FROM transaction_log t
                 JOIN case_view c ON t.case_no = c.case_no
                 JOIN pmi_wo_mrn p ON c.hkid = p.hkid
        WHERE t.hospital_code = par_hospital_code
          AND t.transaction_datetime >= par_input_from_date
          AND t.transaction_datetime < par_input_to_date
          AND t.transaction_type = '100'
          AND t.cancel_flag IS NULL
          AND c.source_indicator = '8'
          AND COALESCE(p.death_indicator, 'N') = 'N';
    END IF;

    -- Process each record
    FOR var_record IN SELECT *
                      FROM t$temp_letter_info t
                      WHERE t.hkid LIKE 'U%'
                        AND t.building IS NOT NULL
                        AND t.building <> 'UNKNOWN'
        LOOP
            var_hkid := var_record.hkid;
            var_building := var_record.building;
            var_cccode1 := var_record.cccode1;
            var_cccode2 := var_record.cccode2;
            var_cccode3 := var_record.cccode3;
            var_cccode4 := var_record.cccode4;
            var_cccode5 := var_record.cccode5;
            var_cccode6 := var_record.cccode6;
            var_race_code := var_record.race_code;
            var_district_code := var_record.district_code;

            -- Initialize variables
            var_nok_name := NULL;
            var_nok_chi_name := NULL;
            var_nok_hkid := NULL;
            var_pcccode1 := NULL;
            var_pcccode2 := NULL;
            var_pcccode3 := NULL;
            var_pcccode4 := NULL;
            var_pcccode5 := NULL;
            var_pcccode6 := NULL;
            var_record_id := NULL;
            var_address_eng := NULL;
            var_address_chi := NULL;
            var_eh_eng := NULL;
            var_eh_chi := NULL;

            /* Retrieve mother information */
            /* 2012-03-23 Edited by Terry Yeung - Start */
            SELECT p.name,
                   n.nok_hkid,
                   p.ccc_1,
                   p.ccc_2,
                   p.ccc_3,
                /* 2012-03-23 Edited by Terry Yeung - End */
                   p.ccc_4,
                   p.ccc_5,
                   p.ccc_6
            INTO var_nok_name, var_nok_hkid, var_pcccode1, var_pcccode2, var_pcccode3, var_pcccode4, var_pcccode5, var_pcccode6
            FROM nok n
                     JOIN pmi_wo_mrn p ON n.nok_hkid = p.hkid
            WHERE n.nok_relation_code = 'MO'
              AND n.hkid = var_record.hkid;

            IF NOT FOUND THEN
                /* Otherwise, retrieve father information */
                /* 2012-03-23 Edited by Terry Yeung - Start */
                SELECT p.name,
                       n.nok_hkid,
                       p.ccc_1,
                       p.ccc_2,
                       p.ccc_3,
                    /* 2012-03-23 Edited by Terry Yeung - End */
                       p.ccc_4,
                       p.ccc_5,
                       p.ccc_6
                INTO var_nok_name, var_nok_hkid, var_pcccode1, var_pcccode2, var_pcccode3, var_pcccode4, var_pcccode5, var_pcccode6
                FROM nok n
                         JOIN pmi_wo_mrn p ON n.nok_hkid = p.hkid
                WHERE n.nok_relation_code = 'FA'
                  AND n.hkid = var_record.hkid;
            END IF;
            IF var_nok_name IS NULL AND var_nok_hkid IS NULL THEN
                /* No NOK found */
                DELETE FROM t$temp_letter_info t WHERE t.hkid = var_record.hkid AND t.case_no = var_record.case_no;
            ELSE
                -- Further processing for chi_name and building
                IF (var_pcccode1 IS NOT NULL AND var_pcccode1 <> '')
                    OR (var_pcccode2 IS NOT NULL AND var_pcccode2 <> '')
                    OR (var_pcccode3 IS NOT NULL AND var_pcccode3 <> '')
                    OR (var_pcccode4 IS NOT NULL AND var_pcccode4 <> '')
                    OR (var_pcccode5 IS NOT NULL AND var_pcccode5 <> '')
                    OR (var_pcccode6 IS NOT NULL AND var_pcccode6 <> '') THEN

                    -- Call function to get phonetic Chinese name
                    CALL hasp_get_phonetic_chin_name(var_return_code, var_pcccode1, var_pcccode2, var_pcccode3,
                                                     var_pcccode4, var_pcccode5, var_pcccode6,
                                                     var_phonetic, var_nok_chi_name);

                    -- Check if NOK Chinese name exists
                    IF COALESCE(var_nok_chi_name, '') <> '' THEN
                        -- Call function to check SCHI name
                        CALL hasp_check_schi_name(var_return_code, var_pcccode1, var_pcccode2, var_pcccode3,
                                                  var_pcccode4, var_pcccode5, var_pcccode6,
                                                  var_is_schi_name);

                        IF var_is_schi_name = 'Y' THEN
                            var_nok_schi_name := var_nok_chi_name;
                        ELSE
                            var_nok_schi_name := '';
                        END IF;
                    ELSE
                        var_nok_schi_name := '';
                    END IF;

                    -- Update t$temp_letter_info with NOK details
                    IF var_nok_chi_name IS NOT NULL THEN
                        UPDATE t$temp_letter_info t
                        SET nok_name      = var_nok_name,
                            nok_chi_name  = var_nok_chi_name,
                            nok_hkid      = var_nok_hkid,
                            nok_schi_name = var_nok_schi_name
                        WHERE t.hkid = var_record.hkid
                          AND t.case_no = var_record.case_no;
                    END IF;
                ELSE
                    -- Update t$temp_letter_info with NOK name
                    UPDATE t$temp_letter_info t
                    SET nok_name = var_nok_name
                    WHERE t.hkid = var_record.hkid
                      AND t.case_no = var_record.case_no;
                END IF;

                -- Retrieve baby Chinese name and convert structured address
                CALL hasp_get_phonetic_chin_name(var_return_code, var_cccode1, var_cccode2, var_cccode3,
                                                 var_cccode4, var_cccode5, var_cccode6,
                                                 var_phonetic, var_chi_name);

                -- Check SCHI name
                IF COALESCE(var_schi_name, '') <> '' THEN
                    CALL hasp_check_schi_name(var_return_code, var_cccode1, var_cccode2, var_cccode3,
                                              var_cccode4, var_cccode5, var_cccode6,
                                              var_is_schi_name);

                    IF var_is_schi_name = 'Y' THEN
                        var_schi_name := var_chi_name;
                    ELSE
                        var_schi_name := '';
                    END IF;
                ELSE
                    var_schi_name := '';
                END IF;

                -- Handle address conversion if building starts with "HACODE"
                IF SUBSTRING(var_building, 1, 6) = 'HACODE' THEN
                    var_record_id := CAST(SUBSTRING(var_building, 8) AS INTEGER);
                    CALL hasp_get_address_detail(var_return_code, var_record_id, var_address_eng, var_address_chi,
                                                 var_district, var_eh_eng, var_eh_chi);

                    var_district_code := var_district;

                    IF var_address_chi IS NOT NULL AND var_race_code = 'CH' THEN
                        IF var_eh_chi IS NOT NULL THEN
                            var_building := var_eh_chi || '-' || var_address_chi;
                        ELSE
                            var_building := var_address_chi;
                        END IF;
                    ELSE
                        IF var_address_eng IS NOT NULL THEN
                            IF var_eh_eng IS NOT NULL THEN
                                var_building := var_eh_eng || '-' || var_address_eng;
                            ELSE
                                var_building := var_address_eng;
                            END IF;
                        END IF;
                    END IF;
                END IF;
                -- Update t$temp_letter_info with Chinese name and building
                UPDATE t$temp_letter_info t
                SET chi_name      = var_chi_name,
                    building      = var_building,
                    district_code = var_district_code,
                    schi_name     = var_schi_name
                WHERE t.hkid = var_record.hkid
                  AND t.case_no = var_record.case_no;
            END IF;
        END LOOP;

    -- Retrieve hospital information
    SELECT hc.text_value
    INTO var_hospital_name
    FROM hospital_control hc
    WHERE hc.hospital_code = par_hospital_code
      AND hc.type = 'hosp_name';

    SELECT hc.text_value
    INTO var_hospital_chi_name
    FROM hospital_control hc
    WHERE hc.hospital_code = par_hospital_code
      AND hc.type = 'hosp_chi_name';

    SELECT hc.text_value
    INTO var_hospital_address
    FROM hospital_control hc
    WHERE hc.hospital_code = par_hospital_code
      AND hc.type = 'hosp_address';

    SELECT hc.text_value
    INTO var_hospital_chi_address
    FROM hospital_control hc
    WHERE hc.hospital_code = par_hospital_code
      AND hc.type = 'hosp_chi_address';

    SELECT hc.text_value
    INTO var_dept
    FROM hospital_control hc
    WHERE hc.hospital_code = par_hospital_code
      AND hc.type = 'hosp_department';

    SELECT hc.text_value
    INTO var_dept_chi
    FROM hospital_control hc
    WHERE hc.hospital_code = par_hospital_code
      AND hc.type = 'hosp_chi_department';

    SELECT hc.text_value
    INTO var_fax_no
    FROM hospital_control hc
    WHERE hc.hospital_code = par_hospital_code
      AND hc.type = 'hosp_fax';

    SELECT hc.text_value
    INTO var_phone_no
    FROM hospital_control hc
    WHERE hc.hospital_code = par_hospital_code
      AND hc.type = 'hosp_phone';

    SELECT TO_TIMESTAMP(hc.text_value, 'DD/MM/YYYY')::TIMESTAMP
    INTO var_last_print_date
    FROM hospital_control hc
    WHERE hc.type = 'last_letter_print_date';

    -- Return the result set
    RETURN QUERY
        SELECT t.nok_name,
               COALESCE(t.nok_chi_name, ''),
               t.building,
               t.room,
               t.floor,
               t.block,
               t.district_code,
               t.name,
               t.chi_name,
               t.race_code,
               t.hkid,
               var_hospital_name        AS hospital_name,
               var_hospital_chi_name    AS hospital_chi_name,
               var_hospital_address     AS hospital_address,
               var_hospital_chi_address AS hospital_chi_address,
               var_dept                 AS dept,
               var_dept_chi             AS dept_chi,
               var_fax_no               AS fax_no,
               var_phone_no             AS phone_no,
               COALESCE(t.nok_schi_name, ''),
               COALESCE(t.schi_name, ''),
               c1.unicode_int           AS nok_int1,
               c2.unicode_int           AS nok_int2,
               c3.unicode_int           AS nok_int3,
               c4.unicode_int           AS nok_int4,
               c5.unicode_int           AS nok_int5,
               c6.unicode_int           AS nok_int6,
               c7.unicode_int           AS baby_int1,
               c8.unicode_int           AS baby_int2,
               c9.unicode_int           AS baby_int3,
               c10.unicode_int          AS baby_int4,
               c11.unicode_int          AS baby_int5,
               c12.unicode_int          AS baby_int6
        FROM t$temp_letter_info t
                 JOIN cpi_patient p1 ON t.nok_hkid = p1.hkid
                 JOIN cpi_patient p2 ON t.hkid = p2.hkid
                 LEFT JOIN ccc_unicode c1
                           ON SUBSTRING(p1.cccode1, 1, 4) = c1.ccc_head AND SUBSTRING(p1.cccode1, 5, 1) = c1.ccc_tail
                 LEFT JOIN ccc_unicode c2
                           ON SUBSTRING(p1.cccode2, 1, 4) = c2.ccc_head AND SUBSTRING(p1.cccode2, 5, 1) = c2.ccc_tail
                 LEFT JOIN ccc_unicode c3
                           ON SUBSTRING(p1.cccode3, 1, 4) = c3.ccc_head AND SUBSTRING(p1.cccode3, 5, 1) = c3.ccc_tail
                 LEFT JOIN ccc_unicode c4
                           ON SUBSTRING(p1.cccode4, 1, 4) = c4.ccc_head AND SUBSTRING(p1.cccode4, 5, 1) = c4.ccc_tail
                 LEFT JOIN ccc_unicode c5
                           ON SUBSTRING(p1.cccode5, 1, 4) = c5.ccc_head AND SUBSTRING(p1.cccode5, 5, 1) = c5.ccc_tail
                 LEFT JOIN ccc_unicode c6
                           ON SUBSTRING(p1.cccode6, 1, 4) = c6.ccc_head AND SUBSTRING(p1.cccode6, 5, 1) = c6.ccc_tail
                 LEFT JOIN ccc_unicode c7
                           ON SUBSTRING(p2.cccode1, 1, 4) = c7.ccc_head AND SUBSTRING(p2.cccode1, 5, 1) = c7.ccc_tail
                 LEFT JOIN ccc_unicode c8
                           ON SUBSTRING(p2.cccode2, 1, 4) = c8.ccc_head AND SUBSTRING(p2.cccode2, 5, 1) = c8.ccc_tail
                 LEFT JOIN ccc_unicode c9
                           ON SUBSTRING(p2.cccode3, 1, 4) = c9.ccc_head AND SUBSTRING(p2.cccode3, 5, 1) = c9.ccc_tail
                 LEFT JOIN ccc_unicode c10
                           ON SUBSTRING(p2.cccode4, 1, 4) = c10.ccc_head AND SUBSTRING(p2.cccode4, 5, 1) = c10.ccc_tail
                 LEFT JOIN ccc_unicode c11
                           ON SUBSTRING(p2.cccode5, 1, 4) = c11.ccc_head AND SUBSTRING(p2.cccode5, 5, 1) = c11.ccc_tail
                 LEFT JOIN ccc_unicode c12
                           ON SUBSTRING(p2.cccode6, 1, 4) = c12.ccc_head AND SUBSTRING(p2.cccode6, 5, 1) = c12.ccc_tail
        WHERE t.hkid LIKE 'U%'
          AND t.building IS NOT NULL
          AND t.building <> 'UNKNOWN'
        ORDER BY t.hkid, t.case_no;
    -- DROP TABLE IF EXISTS t$temp_letter_info;

    -- Update last print date if necessary
    IF par_input_to_date IS NOT NULL THEN
        IF var_last_print_date IS NULL THEN
            UPDATE hospital_control t
            SET text_value = TO_CHAR(par_input_to_date, 'DD/MM/YYYY')
            WHERE t.type = 'last_letter_print_date';
        ELSE
            IF par_input_to_date > var_last_print_date THEN
                UPDATE hospital_control t
                SET text_value = TO_CHAR(par_input_to_date, 'DD/MM/YYYY')
                WHERE TYPE = 'last_letter_print_date'
                  AND par_input_to_date > var_last_print_date;
                raise notice 'text_value=%', TO_CHAR(par_input_to_date, 'DD/MM/YYYY');
            END IF;
        END IF;
    END IF;
    DROP TABLE IF EXISTS t$temp_letter_info;
    RETURN;
END;
$function$
;

;ALTER FUNCTION "hasp_web_letter_to_patient" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
