CREATE OR REPLACE FUNCTION pass_hkpmi_get_patient_by_id(IN par_patient_name VARCHAR, IN par_hkid VARCHAR DEFAULT null, IN par_document_type VARCHAR DEFAULT null, IN par_document_number VARCHAR DEFAULT null)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_rowcount INTEGER;
    var_ha_code VARCHAR(20);
    var_record_id INTEGER;
    sql$rowcount BIGINT;

    p_refcur refcursor;
BEGIN
    drop table if exists  t$temp_result;
    CREATE TEMPORARY TABLE t$temp_result
    (
        -- cccode1 VARCHAR(5) NULL,
        -- cccode2 VARCHAR(5) NULL,
        -- cccode3 VARCHAR(5) NULL,
        -- cccode4 VARCHAR(5) NULL,
        -- cccode5 VARCHAR(5) NULL,
        -- cccode6 VARCHAR(5) NULL,
        unicode1 INTEGER NULL,
        unicode2 INTEGER NULL,
        unicode3 INTEGER NULL,
        unicode4 INTEGER NULL,
        unicode5 INTEGER NULL,
        unicode6 INTEGER NULL,
        hkid VARCHAR(12) NULL,
        dob TIMESTAMP WITHOUT TIME ZONE NULL,
        exact_dob_flag VARCHAR(5) NULL,
        patient_name VARCHAR(48),
        sex VARCHAR(1),
        last_patient_status VARCHAR(3) NULL,
        patient_status_description VARCHAR(80) NULL,
        phone1 VARCHAR(10) NULL,
        phone2 VARCHAR(10) NULL,
        address_indicator VARCHAR(4) NULL,
        mobile_phone VARCHAR(10) NULL,
        sms_language VARCHAR(4) NULL,
        room VARCHAR(5) NULL,
        floor VARCHAR(2) NULL,
        block VARCHAR(2) NULL,
        eng_address VARCHAR(255) NULL,
        chi_address VARCHAR(255) NULL,
        eng_building VARCHAR(200) NULL,
        chi_building VARCHAR(100) NULL,
        eng_estate VARCHAR(100) NULL,
        chi_estate VARCHAR(80) NULL,
        street_no VARCHAR(10) NULL,
        eng_street VARCHAR(100) NULL,
        chi_street VARCHAR(50) NULL,
        district_code VARCHAR(5) NULL,
        eng_district VARCHAR(15) NULL,
        chi_district VARCHAR(30) NULL,
        eng_district_area VARCHAR(50) NULL,
        chi_district_area VARCHAR(50) NULL,
        rec_id INTEGER NULL,
        last_doc_type VARCHAR(5) NULL,
        last_doc_no VARCHAR(12) NULL,
        doc_type_description VARCHAR(255) NULL);
    /* If document type = BC, use HKID to search */

    IF par_document_type = 'BC' THEN
        BEGIN
            SELECT
                'ID'
                INTO par_document_type;
            SELECT
                RIGHT(CONCAT(REPEAT(' ', 12), RTRIM(par_document_number)), 9)
                INTO par_hkid;
        END;
    END IF;

    IF par_hkid IS NOT NULL THEN
        BEGIN
            /* --search by HKID */
            INSERT INTO t$temp_result (
                -- cccode1, cccode2, cccode3, cccode4, cccode5, cccode6,
                unicode1, unicode2, unicode3, unicode4, unicode5, unicode6, hkid, dob, exact_dob_flag, patient_name, sex, last_patient_status, patient_status_description, phone1, phone2, address_indicator, mobile_phone, sms_language, room, floor, block, last_doc_type, last_doc_no, doc_type_description, district_code, eng_district, chi_district, eng_building, eng_district_area, chi_district_area, rec_id)
            SELECT
                -- p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6, 
                c1.unicode_int AS unicode1, c2.unicode_int AS unicode2, c3.unicode_int AS unicode3, c4.unicode_int AS unicode4, c5.unicode_int AS unicode5, c6.unicode_int AS unicode6, p.hkid, p.dob,
                CASE
                    WHEN p.dob IS NOT NULL AND p.exact_dob_flag = 'Y' THEN 'YMD'
                    WHEN p.exact_dob_flag = 'N' THEN 'Y'
                    ELSE NULL
                END, p.patient_name, p.sex, p.patient_type, t.description, p.phone1, p.phone2, p.address_indicator, p.mobile_phone, p.sms_language, p.room, p.floor, p.block, dt.document_type, p.other_doc_no, dt.description, p.district, d.district_name, d.district_chi, p.building, da.area_name, da.area_chi, 0 /* --record_id default is 0 */
                FROM patient AS p
                LEFT OUTER JOIN ccc_unicode AS c1
                    ON SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
                LEFT OUTER JOIN ccc_unicode AS c2
                    ON SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
                LEFT OUTER JOIN ccc_unicode AS c3
                    ON SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
                LEFT OUTER JOIN ccc_unicode AS c4
                    ON SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
                LEFT OUTER JOIN ccc_unicode AS c5
                    ON SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
                LEFT OUTER JOIN ccc_unicode AS c6
                    ON SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
                LEFT OUTER JOIN district AS d
                    ON d.district_code = p.district
                LEFT OUTER JOIN district_area AS da
                    ON da.area_code = d.district_area
                LEFT OUTER JOIN patient_type AS t
                    ON p.patient_type = t.patient_type
                LEFT OUTER JOIN document_type AS dt
                    ON dt.document_code = SUBSTRING(p.filler, 1, 1)
                WHERE p.hkid = par_hkid AND p.patient_name = par_patient_name;
        END;
    ELSE
        IF par_document_type <> 'ID' AND par_document_number IS NOT NULL THEN
            BEGIN
                drop table if exists  t$temp_document_code;
                CREATE TEMPORARY TABLE t$temp_document_code
                (document_code VARCHAR(1) NULL);
                /* --map document_code */
                IF par_document_type IN ('AR') THEN
                    BEGIN
                        IF par_document_type = 'AR' THEN
                            BEGIN
                                INSERT INTO t$temp_document_code
                                SELECT
                                    document_code
                                    FROM document_type
                                    WHERE document_type IN ('AE', 'AN', 'AR');
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_document_code
                        SELECT
                            document_code
                            FROM document_type
                            WHERE document_type = par_document_type::VARCHAR;
                    END;
                END IF;
                /* --search by other document number, if rowcount > 1 then delete records */
                INSERT INTO t$temp_result (
                    -- cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, 
                    unicode1, unicode2, unicode3, unicode4, unicode5, unicode6, hkid, dob, exact_dob_flag, patient_name, sex, last_patient_status, patient_status_description, phone1, phone2, address_indicator, mobile_phone, sms_language, room, floor, block, last_doc_type, last_doc_no, doc_type_description, district_code, eng_district, chi_district, eng_building, eng_district_area, chi_district_area, rec_id)
                SELECT
                    -- p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6, 
                    c1.unicode_int AS unicode1, c2.unicode_int AS unicode2, c3.unicode_int AS unicode3, c4.unicode_int AS unicode4, c5.unicode_int AS unicode5, c6.unicode_int AS unicode6, p.hkid, p.dob,
                    CASE
                        WHEN p.dob IS NOT NULL AND p.exact_dob_flag = 'Y' THEN 'YMD'
                        WHEN p.exact_dob_flag = 'N' THEN 'Y'
                        ELSE NULL
                    END, p.patient_name, p.sex, p.patient_type, t.description, p.phone1, p.phone2, p.address_indicator, p.mobile_phone, p.sms_language, p.room, p.floor, p.block, dt.document_type, p.other_doc_no, dt.description, p.district, d.district_name, d.district_chi, p.building, da.area_name, da.area_chi, 0 /* --record_id default is 0 */
                    FROM patient AS p
                    LEFT OUTER JOIN ccc_unicode AS c1
                        ON SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
                    LEFT OUTER JOIN ccc_unicode AS c2
                        ON SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
                    LEFT OUTER JOIN ccc_unicode AS c3
                        ON SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
                    LEFT OUTER JOIN ccc_unicode AS c4
                        ON SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
                    LEFT OUTER JOIN ccc_unicode AS c5
                        ON SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
                    LEFT OUTER JOIN ccc_unicode AS c6
                        ON SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
                    LEFT OUTER JOIN district AS d
                        ON d.district_code = p.district
                    LEFT OUTER JOIN district_area AS da
                        ON da.area_code = d.district_area
                    LEFT OUTER JOIN patient_type AS t
                        ON p.patient_type = t.patient_type
                    LEFT OUTER JOIN document_type AS dt
                        ON dt.document_code = SUBSTRING(p.filler, 1, 1)
                    WHERE p.other_doc_no = par_document_number AND SUBSTRING(p.filler, 1, 1) IN (SELECT
                        document_code
                        FROM t$temp_document_code) AND p.patient_name = par_patient_name;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;
                /* --If 2 patient records found for document number search, indicate record not found */
                IF var_rowcount > 1 THEN
                    BEGIN
                        DELETE FROM t$temp_result;
                    END;
                END IF;
            END;
        END IF;
    END IF;

    IF EXISTS (SELECT
        1
        FROM t$temp_result
        WHERE eng_building LIKE 'HACODE%') THEN
        BEGIN
            SELECT
                SUBSTRING(eng_building, 8, 20)
                INTO var_ha_code
                FROM t$temp_result;
            SELECT
                CAST (var_ha_code AS INTEGER)
                INTO var_record_id;
            UPDATE t$temp_result
            SET rec_id = record_id, eng_building = bldg_eng, chi_building = bldg_chi, eng_estate = estate_eng, chi_estate = estate_chi, street_no = house_no, eng_street = street_eng, chi_street = street_chi
            FROM address_detail
                WHERE record_id = var_record_id;
        END;
    END IF;
    OPEN p_refcur FOR
    SELECT
        unicode1, unicode2, unicode3, unicode4, unicode5, unicode6, hkid, dob, exact_dob_flag, patient_name, sex, last_patient_status, patient_status_description, phone1, phone2, address_indicator, mobile_phone, sms_language, room, floor, block, eng_address, chi_address, eng_building, chi_building, eng_estate, chi_estate, street_no, eng_street, chi_street, district_code, eng_district, chi_district, eng_district_area, chi_district_area, rec_id, last_doc_type, last_doc_no, doc_type_description, 
        -- cccode1, cccode2, cccode3, cccode4, cccode5, cccode6
        null, null, null, null, null, null
        FROM t$temp_result;
    return next p_refcur;
    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$temp_result;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$temp_document_code;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;

ALTER FUNCTION "pass_hkpmi_get_patient_by_id" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
