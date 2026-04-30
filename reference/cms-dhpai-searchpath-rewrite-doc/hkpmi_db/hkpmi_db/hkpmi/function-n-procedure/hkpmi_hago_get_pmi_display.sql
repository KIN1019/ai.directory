-- DROP PROCEDURE hkpmi.hkpmi_hago_get_pmi_display(inout int4, in bpchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_hago_get_pmi_display(INOUT pas_return_code integer, IN par_hkid varchar DEFAULT NULL::varchar, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_patient_key VARCHAR(16);
    var_ha_code VARCHAR(40);
    var_record_id INTEGER;
begin
	DROP TABLE IF EXISTS t$temp_result;
    CREATE TEMPORARY TABLE t$temp_result
    (patient_key VARCHAR(16) NULL,
        hkid VARCHAR(25) NULL,
        chi_name_1 INTEGER NULL,
        chi_name_2 INTEGER NULL,
        chi_name_3 INTEGER NULL,
        chi_name_4 INTEGER NULL,
        chi_name_5 INTEGER NULL,
        chi_name_6 INTEGER NULL,
        dob TIMESTAMP WITHOUT TIME ZONE NULL,
        exact_dob_flag VARCHAR(10) NULL,
        patient_name VARCHAR(96),
        sex VARCHAR(2),
        religion VARCHAR(6) NULL,
        marital_status VARCHAR(2) NULL,
        /* --last_patient_status		char(3) null, */
        /* --patient_status_description	varchar(80) null, */
        phone1 VARCHAR(20) NULL,
        phone2 VARCHAR(20) NULL,
        address_indicator VARCHAR(8) NULL,
        mobile_phone VARCHAR(20) NULL,
        sms_language VARCHAR(8) NULL,
        room VARCHAR(10) NULL,
        floor VARCHAR(4) NULL,
        block VARCHAR(4) NULL,
        /* --eng_address	varchar(255) null, */
        /* --chi_address	varchar(255) null, */
        eng_building VARCHAR(400) NULL,
        chi_building VARCHAR(200) NULL,
        eng_estate VARCHAR(200) NULL,
        chi_estate VARCHAR(160) NULL,
        street_no VARCHAR(20) NULL,
        eng_street VARCHAR(200) NULL,
        chi_street VARCHAR(100) NULL,
        district_code VARCHAR(10) NULL,
        eng_district VARCHAR(30) NULL,
        chi_district VARCHAR(60) NULL,
        eng_district_area VARCHAR(100) NULL,
        chi_district_area VARCHAR(100) NULL,
        addr_rec_id INTEGER NULL,
        /* --postal address */
        c_room VARCHAR(10) NULL,
        c_floor VARCHAR(4) NULL,
        c_block VARCHAR(4) NULL,
        /* --c_eng_address	varchar(255) null, */
        /* --c_chi_address	varchar(255) null, */
        c_eng_building VARCHAR(400) NULL,
        c_chi_building VARCHAR(200) NULL,
        c_eng_estate VARCHAR(200) NULL,
        c_chi_estate VARCHAR(160) NULL,
        c_street_no VARCHAR(20) NULL,
        c_eng_street VARCHAR(200) NULL,
        c_chi_street VARCHAR(100) NULL,
        c_district_code VARCHAR(10) NULL,
        c_eng_district VARCHAR(30) NULL,
        c_chi_district VARCHAR(60) NULL,
        c_eng_district_area VARCHAR(100) NULL,
        c_chi_district_area VARCHAR(100) NULL,
        c_addr_rec_id INTEGER NULL,
        mobile_no VARCHAR(20) NULL,
        nok_sms_language VARCHAR(16) NULL,
        nok_name VARCHAR(96) NULL,
        nok_relation_code VARCHAR(4) NULL,
        /* --nok_relation_desc varchar(80) null, */
        nok_phone VARCHAR(20) NULL,
        nok_phone1 VARCHAR(20) NULL,
        nok_phone2 VARCHAR(20) NULL,
        nok_mobile_phone VARCHAR(20) NULL,
        nok_mobile_no VARCHAR(20) NULL,
        pat_demo_upd_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
        c_address_upd_dtm TIMESTAMP WITHOUT TIME ZONE NULL);

    IF par_hkid IS NOT NULL THEN
        BEGIN
            /* --Format HKID */
            SELECT
                RIGHT(CONCAT(REPEAT(' ', 12), RTRIM(par_hkid)), 9)
                INTO par_hkid;
            /* --search by HKID */
            INSERT INTO t$temp_result (patient_key, hkid, chi_name_1, chi_name_2, chi_name_3, chi_name_4, chi_name_5, chi_name_6, dob, exact_dob_flag, patient_name, sex, religion, marital_status,
            /* --last_patient_status,patient_status_description, */
            phone1, phone2, address_indicator, mobile_phone, sms_language, room, floor, block, district_code, eng_district, chi_district, eng_building, eng_district_area, chi_district_area, addr_rec_id, pat_demo_upd_dtm)
            SELECT
                p.patient_key, p.hkid, c1.unicode_int AS unicode1, c2.unicode_int AS unicode2, c3.unicode_int AS unicode3, c4.unicode_int AS unicode4, c5.unicode_int AS unicode5, c6.unicode_int AS unicode6, p.dob, p.exact_dob_flag, /* --case when p.dob is not null and p.exact_dob_flag='Y' then 'YMD' when p.exact_dob_flag='N' then 'Y' else null end, */ p.patient_name, p.sex, p.religion, p.marital_status,
                /* --p.patient_type, */
                /* --t.description, */
                p.phone1, p.phone2, p.address_indicator, p.mobile_phone, p.sms_language, p.room, p.floor, p.block, p.district, d.district_name, d.district_chi, p.building, da.area_name, da.area_chi, 0, /* --record_id default is 0 */ p.source_system_dtm /* --patient.source_system_dtm to match cpi_patient.update_dtm */
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
                    ON da.area_code = d.district_area::VARCHAR
                /* --left outer join patient_type t on p.patient_type = t.patient_type */
                WHERE p.hkid = par_hkid;
        END;
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
            SET addr_rec_id = record_id, eng_building = bldg_eng, chi_building = bldg_chi, eng_estate = estate_eng, chi_estate = estate_chi, street_no = house_no, eng_street = street_eng, chi_street = street_chi
            FROM address_detail
                WHERE record_id = var_record_id;
        END;
    END IF;
    SELECT
        patient_key
        INTO var_patient_key
        FROM t$temp_result;
    /* --postal address */
    IF EXISTS (SELECT
        1
        FROM hkpmi_patient_address_list
        WHERE patient_key = var_patient_key::VARCHAR AND address_type = 'C') THEN
        BEGIN
            update t$temp_result
                          set 	c_room	= a.room,
            					c_floor	= a.floor,
            					c_block	= a.block,
            					--c_eng_address = null,
            					--c_chi_address = null,
            					c_eng_building = a.building,
            					c_chi_building = null,
            					c_eng_estate = null,
            					c_chi_estate = null,
            					c_street_no = null,
            					c_eng_street = null,
            					c_chi_street = null,
            					c_district_code	= a.district_code,
            					c_eng_district	= d.district_name,
            					c_chi_district	= d.district_chi,
            					c_eng_district_area = da.area_name,
            					c_chi_district_area = da.area_chi,
            					c_addr_rec_id = 0, --record_id default is 0
            					c_address_upd_dtm = a.update_datetime
                          from hkpmi_patient_address_list  a
                          	left outer join district d on d.district_code = a.district_code
                          	left outer join district_area da on da.area_code = d.district_area
                          where a.patient_key = var_patient_key and a.address_type = 'C';
           
            IF EXISTS (SELECT
                1
                FROM t$temp_result
                WHERE c_eng_building LIKE 'HACODE%') THEN
                BEGIN
                    SELECT
                        SUBSTRING(c_eng_building, 8, 20)
                        INTO var_ha_code
                        FROM t$temp_result;
                    SELECT
                        CAST (var_ha_code AS INTEGER)
                        INTO var_record_id;
                    UPDATE t$temp_result
                    SET c_addr_rec_id = record_id, c_eng_building = bldg_eng, c_chi_building = bldg_chi, c_eng_estate = estate_eng, c_chi_estate = estate_chi, c_street_no = house_no, c_eng_street = street_eng, c_chi_street = street_chi
                    FROM address_detail
                        WHERE record_id = var_record_id;
                END;
            END IF;
        END;
    END IF;

    IF EXISTS (SELECT
        1
        FROM nok
        WHERE patient_key = var_patient_key AND major_nok = 'Y') THEN
        BEGIN
            UPDATE t$temp_result
            SET nok_name = n.nok_name, nok_relation_code = n.relationship,
            /* --nok_relation_desc = nr.description, */
            nok_phone = n.phone1, nok_phone1 = n.phone1, nok_phone2 = n.phone2, nok_mobile_phone = n.mobile_phone
            FROM nok AS n
                /* --left outer join nok_relation nr on nr.nok_relation_code = n.relationship */
                WHERE n.patient_key = var_patient_key AND major_nok = 'Y';
        END;
    END IF;
    /* Mask 'UNKNOWN' address building, district - start */
    UPDATE t$temp_result
    SET eng_building = NULL, chi_building = NULL
        WHERE eng_building = 'UNKNOWN';
    UPDATE t$temp_result
    SET eng_district = NULL, chi_district = NULL
        WHERE eng_district = 'UNKNOWN';
    /* Postal */
    UPDATE t$temp_result
    SET c_eng_building = NULL, c_chi_building = NULL
        WHERE c_eng_building = 'UNKNOWN';
    UPDATE t$temp_result
    SET c_eng_district = NULL, c_chi_district = NULL
        WHERE c_eng_district = 'UNKNOWN';
    /* Mask 'UNKNOWN' address building, district - end */
    OPEN p_refcur FOR
    SELECT
        t.patient_key, t.hkid, t.patient_name, t.chi_name_1, t.chi_name_2, t.chi_name_3, t.chi_name_4, t.chi_name_5, t.chi_name_6, t.sex, t.dob, t.exact_dob_flag, t.religion, t.marital_status, t.phone1, t.phone2, t.address_indicator, t.mobile_phone, t.sms_language other_phone_ext, t.room, t.floor, t.block,
        /* --eng_address,chi_address, */
        t.eng_building, t.chi_building, t.eng_estate, t.chi_estate, t.street_no, t.eng_street, t.chi_street, t.district_code, t.eng_district, t.chi_district, t.eng_district_area, t.chi_district_area, t.addr_rec_id,
        /* --Major NOK details */
        t.nok_name, t.nok_relation_code, t.nok_phone, t.nok_phone1, t.nok_phone2, t.nok_mobile_phone,
        /* --nok_relation_desc, */
        /* --Patient's mobile com no. and language */
        /* --mobile_no, sms_language, */
        CASE
            WHEN t.mobile_phone IS NOT NULL AND t.mobile_phone <> '' AND LENGTH(LTRIM(RTRIM(t.mobile_phone))) = 8 AND SUBSTRING(LTRIM(RTRIM(t.mobile_phone)), 1, 1) IN ('4', '5', '6', '7', '8', '9') THEN LTRIM(RTRIM(t.mobile_phone))
            ELSE NULL
        END AS mobile_no,
        CASE
            WHEN t.sms_language IS NOT NULL AND t.sms_language <> '' AND LTRIM(RTRIM(t.sms_language)) IN (SELECT DISTINCT
                sms_language_code
                FROM sms_language_table) THEN (SELECT
                sms_language
                FROM sms_language_table
                WHERE sms_language_code = LTRIM(RTRIM(t.sms_language)))
            ELSE NULL
        END AS sms_language,
        CASE
            WHEN t.nok_mobile_phone IS NOT NULL AND t.nok_mobile_phone <> '' AND LENGTH(LTRIM(RTRIM(t.nok_mobile_phone))) = 8 AND SUBSTRING(LTRIM(RTRIM(t.nok_mobile_phone)), 1, 1) IN ('4', '5', '6', '7', '8', '9') THEN LTRIM(RTRIM(t.nok_mobile_phone))
            ELSE NULL
        END AS nok_mobile_no,
        /* --postal/correspoding address */
        t.c_room, t.c_floor, t.c_block,
        /* --c_eng_address, c_chi_address, */
        t.c_eng_building, t.c_chi_building, t.c_eng_estate, t.c_chi_estate, t.c_street_no, t.c_eng_street, t.c_chi_street, t.c_district_code, t.c_eng_district, t.c_chi_district, t.c_eng_district_area, t.c_chi_district_area, t.c_addr_rec_id, t.pat_demo_upd_dtm, t.c_address_upd_dtm
        FROM t$temp_result AS t;
    /*
    
    DROP TABLE IF EXISTS t$temp_result;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_hago_get_pmi_display" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
