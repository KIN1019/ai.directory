CREATE OR REPLACE FUNCTION pass_hkpmi_get_patcase_by_id(IN par_hkid VARCHAR DEFAULT null, IN par_document_number VARCHAR DEFAULT null, IN "par_includeCase" VARCHAR DEFAULT 'Y')
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/* --	@patient_name		VARCHAR(48), */
/* --	@document_type		varchar(5) = null, */
DECLARE
    var_rowcount INTEGER;
    var_ha_code VARCHAR(20);
    var_record_id INTEGER;
    var_patient_key VARCHAR(8);
    var_pin VARCHAR(12);
    var_pin_len INTEGER;
    sql$rowcount BIGINT;
    patient_csr CURSOR FOR
    SELECT
        patient_key
        FROM t$temp_result;

    p_refcur refcursor;
BEGIN
    SELECT
        LTRIM(RTRIM(par_hkid))
        INTO var_pin;
    SELECT
        OCTET_LENGTH(var_pin)
        INTO var_pin_len;

    IF var_pin_len = 8 THEN
        SELECT
            CONCAT(' ', var_pin)
            INTO par_hkid;
    END IF;
    DROP TABLE IF EXISTS t$temp_result;
    CREATE TEMPORARY TABLE t$temp_result
    (patient_key VARCHAR(8),
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
        doc_type_description VARCHAR(255) NULL,
        cccode1 VARCHAR(5) NULL,
        cccode2 VARCHAR(5) NULL,
        cccode3 VARCHAR(5) NULL,
        cccode4 VARCHAR(5) NULL,
        cccode5 VARCHAR(5) NULL,
        cccode6 VARCHAR(5) NULL);
    /* If document type = BC, use HKID to search */
    
    /* --	if @document_type = 'BC' */
    
    /* --	begin */
    
    /* --		select @document_type = 'ID' */
    
    /* --		select @hkid = right(replicate(' ',12)+rtrim(@document_number), 9) */
    
    /* --	end */
    IF par_hkid IS NOT NULL THEN
        BEGIN
            /* --search by HKID */
            INSERT INTO t$temp_result (patient_key, unicode1, unicode2, unicode3, unicode4, unicode5, unicode6, hkid, dob, exact_dob_flag, patient_name, sex, last_patient_status, patient_status_description, phone1, phone2, address_indicator, mobile_phone, sms_language, room, floor, block, last_doc_type, last_doc_no, doc_type_description, district_code, eng_district, chi_district, eng_building, eng_district_area, chi_district_area, rec_id, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6)
            SELECT
                p.patient_key, c1.unicode_int AS unicode1, c2.unicode_int AS unicode2, c3.unicode_int AS unicode3, c4.unicode_int AS unicode4, c5.unicode_int AS unicode5, c6.unicode_int AS unicode6, p.hkid, p.dob,
                /* --		case when p.dob is not null and p.exact_dob_flag='Y' then 'YMD' when p.exact_dob_flag='N' then 'Y' else null end, */
                p.exact_dob_flag, p.patient_name, p.sex, p.patient_type, t.description, p.phone1, p.phone2, p.address_indicator, p.mobile_phone, p.sms_language, p.room, p.floor, p.block, dt.document_type, p.other_doc_no, dt.description, p.district, d.district_name, d.district_chi, p.building, da.area_name, da.area_chi, 0, /* --record_id default is 0 */ p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6
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
                WHERE p.hkid = par_hkid;
            /* --		and p.patient_name = @patient_name */
        END;
    ELSE
        /* --	if @document_type <> 'ID' and @document_number is not null */
        IF par_document_number IS NOT NULL THEN
            BEGIN
                DROP TABLE IF EXISTS t$temp_document_code;
                CREATE TEMPORARY TABLE t$temp_document_code
                (document_code VARCHAR(1) NULL);
                /* --map document_code */
                /* --		If @document_type in ('AR') */
                /* --		begin */
                /* --			if @document_type = 'AR' */
                /* --			begin */
                /* --				insert into #temp_document_code */
                /* --				select document_code */
                /* --				from document_type */
                /* --				where document_type in ('AE','AN','AR') */
                /* --			end */
                /* --		end */
                /* ---		else */
                /* --		begin */
                /* ---			insert into #temp_document_code */
                /* --			select document_code */
                /* --			from document_type */
                /* --			where document_type = @document_type */
                /* --		end */
                /* --search by other document number, if rowcount > 1 then delete records */
                INSERT INTO t$temp_result (patient_key, unicode1, unicode2, unicode3, unicode4, unicode5, unicode6, hkid, dob, exact_dob_flag, patient_name, sex, last_patient_status, patient_status_description, phone1, phone2, address_indicator, mobile_phone, sms_language, room, floor, block, last_doc_type, last_doc_no, doc_type_description, district_code, eng_district, chi_district, eng_building, eng_district_area, chi_district_area, rec_id, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6)
                SELECT
                    p.patient_key, c1.unicode_int AS unicode1, c2.unicode_int AS unicode2, c3.unicode_int AS unicode3, c4.unicode_int AS unicode4, c5.unicode_int AS unicode5, c6.unicode_int AS unicode6, p.hkid, p.dob,
                    /* --		case when p.dob is not null and p.exact_dob_flag='Y' then 'YMD' when p.exact_dob_flag='N' then 'Y' else null end, */
                    p.exact_dob_flag, p.patient_name, p.sex, p.patient_type, t.description, p.phone1, p.phone2, p.address_indicator, p.mobile_phone, p.sms_language, p.room, p.floor, p.block, dt.document_type, p.other_doc_no, dt.description, p.district, d.district_name, d.district_chi, p.building, da.area_name, da.area_chi, 0, /* --record_id default is 0 */ p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6
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
                    WHERE p.other_doc_no = par_document_number;
                /* --		and substring(p.filler, 1, 1) in (select document_code from #temp_document_code) */
                /* --		and p.patient_name = @patient_name */
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
    DROP TABLE IF EXISTS t$temp_case;
    CREATE TEMPORARY TABLE t$temp_case
    (access_code INTEGER NULL,
        adm_dtm TIMESTAMP WITHOUT TIME ZONE,
        adm_specialty_code VARCHAR(4) NULL,
        adm_ward_class VARCHAR(1) NULL,
        adm_ward_code VARCHAR(4) NULL,
        case_no VARCHAR(12),
        case_type VARCHAR(1),
        create_by VARCHAR(8),
        create_dtm TIMESTAMP WITHOUT TIME ZONE,
        destination_code VARCHAR(5) NULL,
        discharge_code VARCHAR(1) NULL,
        discharge_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
        district VARCHAR(5) NULL,
        filler VARCHAR(30) NULL,
        hospital_code VARCHAR(3),
        last_bed_no VARCHAR(5) NULL,
        last_specialty_code VARCHAR(4) NULL,
        last_ward_class VARCHAR(1) NULL,
        last_ward_code VARCHAR(4) NULL,
        movement_count INTEGER NULL,
        mrt_indicator VARCHAR(1) NULL,
        patient_key VARCHAR(8),
        patient_type VARCHAR(3) NULL,
        pp_code VARCHAR(8) NULL,
        security_count INTEGER NULL,
        source_code VARCHAR(3) NULL,
        source_indicator VARCHAR(1) NULL,
        source_system VARCHAR(5),
        source_system_dtm TIMESTAMP WITHOUT TIME ZONE,
        /* timestamp           datetime null, */
        update_by VARCHAR(8));
    /* select @patient_key = patient_key from #temp_result */

    IF "par_includeCase" = 'Y' THEN
        BEGIN
            OPEN patient_csr;
            FETCH patient_csr INTO var_patient_key;

            WHILE (CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
            END) = 0 LOOP
                INSERT INTO t$temp_case (access_code, adm_dtm, adm_specialty_code, adm_ward_class, adm_ward_code, case_no, case_type, create_by, create_dtm, destination_code, discharge_code, discharge_dtm, district, filler, hospital_code, last_bed_no, last_specialty_code, last_ward_class, last_ward_code, movement_count, mrt_indicator, patient_key, patient_type, pp_code, security_count, source_code, source_indicator, source_system, source_system_dtm, update_by)
                SELECT
                    c.access_code, c.adm_dtm, c.adm_specialty_code, c.adm_ward_class, c.adm_ward_code, c.case_no, c.case_type, c.create_by, c.create_dtm, c.destination_code, c.discharge_code, c.discharge_dtm, c.district, c.filler, c.hospital_code, c.last_bed_no, c.last_specialty_code, c.last_ward_class, c.last_ward_code, c.movement_count, c.mrt_indicator, c.patient_key, c.patient_type, c.pp_code, c.security_count, c.source_code, c.source_indicator, c.source_system, c.source_system_dtm, c.update_by
                    FROM pmi_case AS c
                    WHERE c.patient_key = var_patient_key AND (c.case_type = 'A' OR c.case_type = 'I') AND c.discharge_code IS NULL;
                /* group by c.patient_key, c.discharge_code */
                /* having adm_dtm = max(adm_dtm) */
                FETCH patient_csr INTO var_patient_key;
            END LOOP;
            CLOSE patient_csr;
        END;
    END IF;
    OPEN p_refcur FOR
    SELECT
        t.patient_key, t.unicode1, t.unicode2, t.unicode3, t.unicode4, t.unicode5, t.unicode6, RTRIM(t.hkid) AS hkid,
        /* t.dob, */
        to_char(t.dob,'DD-MM-YYYY') AS dob, RTRIM(t.exact_dob_flag) AS exact_dob_flag, RTRIM(t.patient_name) AS patient_name, t.sex, RTRIM(t.last_patient_status) AS last_patient_status, t.patient_status_description, RTRIM(t.phone1) AS home_phone, RTRIM(t.phone2) AS office_phone, RTRIM(t.address_indicator) AS office_phone_ext, RTRIM(t.mobile_phone) AS other_phone, RTRIM(t.sms_language) AS other_phone_ext, t.room, t.floor, t.block, t.eng_address, t.chi_address, t.eng_building, t.chi_building, t.eng_estate, t.chi_estate, t.street_no, t.eng_street, t.chi_street, t.district_code, RTRIM(t.eng_district) AS eng_district, RTRIM(t.chi_district) AS chi_district, RTRIM(t.eng_district_area) AS eng_district_area, RTRIM(t.chi_district_area) AS chi_district_area, t.rec_id, t.last_doc_type, t.last_doc_no, t.doc_type_description, t.cccode1, t.cccode2, t.cccode3, t.cccode4, t.cccode5, t.cccode6, c.access_code,
        /* c.adm_dtm, */
        to_char(c.adm_dtm,'DD-MM-YYYY HH24:MI:SS') AS adm_dtm_str, RTRIM(c.adm_specialty_code) AS adm_specialty_code, c.adm_ward_class, RTRIM(c.adm_ward_code) AS adm_ward_code, c.case_no, c.case_type, RTRIM(c.create_by) AS create_by,
        /* c.create_dtm, */
        to_char(c.create_dtm,'DD-MM-YYYY HH24:MI:SS') AS create_dtm, c.destination_code, c.discharge_code,
        /* c.discharge_dtm, */
        CASE
            WHEN (c.discharge_dtm IS NULL) THEN NULL
            ELSE to_char(c.discharge_dtm,'DD-MM-YYYY HH24:MI:SS')
        END AS discharge_dtm, RTRIM(c.district) AS district, c.filler, c.hospital_code, c.last_bed_no, RTRIM(c.last_specialty_code) AS last_specialty_code, c.last_ward_class, RTRIM(c.last_ward_code) AS last_ward_code, c.movement_count, c.mrt_indicator, c.patient_key, c.patient_type, RTRIM(c.pp_code) AS pp_code, c.security_count, c.source_code, RTRIM(c.source_indicator), RTRIM(c.source_system) AS source_system,
        /* c.source_system_dtm, */
        to_char(c.source_system_dtm,'DD-MM-YYYY HH24:MI:SS') AS source_system_dtm, RTRIM(c.update_by) AS update_by, RTRIM(t.hkid) AS hkid, c.adm_dtm
        /* for ordering only */
        
        /* --	from  #temp_result t, #temp_case c */
        
        /* --	where t.patient_key = c.patient_key */
        FROM t$temp_result AS t
        LEFT OUTER JOIN t$temp_case AS c
            ON c.patient_key = t.patient_key
        ORDER BY t.patient_key NULLS FIRST, c.adm_dtm DESC NULLS FIRST;
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
    /*
    
    DROP TABLE IF EXISTS t$temp_case;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;

ALTER FUNCTION "pass_hkpmi_get_patcase_by_id" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
