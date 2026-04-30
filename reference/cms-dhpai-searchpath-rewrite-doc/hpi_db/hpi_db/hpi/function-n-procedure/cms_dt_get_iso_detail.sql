-- DROP FUNCTION hpi.cms_dt_get_iso_detail(varchar, varchar, timestamp);

CREATE OR REPLACE FUNCTION hpi.cms_dt_get_iso_detail(par_hospital_code character varying, par_case_no character varying, par_time timestamp without time zone DEFAULT NULL::timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_ward_code VARCHAR(4);
    var_bed_no VARCHAR(5);
    var_cubicle_no VARCHAR(4);
    var_isolation_facilities VARCHAR(10);
    var_cubicle_service_desc VARCHAR(80);
    var_cubicle_service VARCHAR(3);
    var_sex VARCHAR(1);
    var_sex_description VARCHAR(10);
    var_cubicle_header VARCHAR(100);
    var_iso_status VARCHAR(2);
    var_patient_iso_status VARCHAR(80);
    var_update_datetime VARCHAR(30);
    var_update_by VARCHAR(12);
    var_movement_count INTEGER;
    var_effective_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_is_iso_bed CHAR(1);
    var_error_msg VARCHAR(255);
    var_error_code INTEGER;
    var_rowcount INTEGER;
    p_refcur refcursor;
BEGIN
    <<error>>
    BEGIN
        SELECT
            299999
            INTO var_error_code;
        IF par_time is NULL THEN
            BEGIN
                SELECT
                    localtimestamp
                    INTO par_time;
            END;
        END IF;
        /* check hospital code */
        IF par_hospital_code IS NULL OR (RTRIM(par_hospital_code) = '') THEN
            BEGIN
                SELECT
                    'Hospital code cannot be blank'
                    INTO var_error_msg;
                RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := var_error_code;
                EXIT error;
            END;
        END IF;
        /* check case number */
        IF par_case_no IS NULL OR (RTRIM(par_case_no) = '') THEN
            BEGIN
                SELECT
                    'Case number cannot be blank'
                    INTO var_error_msg;
                RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := var_error_code;
                EXIT error;
            END;
        END IF;
        /* get case with case number and ward bed */
        SELECT
            ward_code, bed_no
            INTO var_ward_code, var_bed_no
            FROM ward_list
            WHERE case_no = par_case_no;

        IF var_bed_no IS NOT NULL THEN
            BEGIN
                select
					cubicle_no,  effective_datetime
					INTO var_cubicle_no, var_effective_dtm
					from bed_history
					where effective_datetime <= par_time
					and hospital_code = par_hospital_code
					and bed_no = var_bed_no
					and ward_code = var_ward_code
					and effective_datetime = (select max(effective_datetime) from bed_history
					where effective_datetime <= par_time
					and hospital_code = par_hospital_code
					and bed_no = var_bed_no
					and ward_code = var_ward_code
					group by hospital_code, ward_code, bed_no);
                SELECT
                    CASE
                        WHEN isolation_facilities IS NOT NULL AND LENGTH(LTRIM(c.isolation_facilities)) > 0 THEN SUBSTRING(isolation_facilities, 1, 1)
                        ELSE 'general'
                    END,
                    CASE
                        WHEN (c.cubicle_service = 'NI' OR c.cubicle_service IS NULL OR LTRIM(c.cubicle_service) = '') THEN 'General'
                        WHEN (NOT (b.description IS NULL OR LTRIM(b.description) = '')) THEN b.description
                        ELSE 'General'
                    END, c.cubicle_service,
                    CASE
                        WHEN (c.isolation_facilities IN ('A', 'AG', 'AN', 'AP', 'AI', 'B', 'BG', 'BN', 'BI', 'BP') AND c.cubicle_service IN ('A', 'I')) THEN 'Y'
                        ELSE 'N'
                    END
                    INTO var_isolation_facilities, var_cubicle_service_desc, var_cubicle_service, var_is_iso_bed
                    FROM cubicle AS c, bed_service_type AS b
                    WHERE hospital_code = par_hospital_code AND ward_code = var_ward_code AND cubicle_no = var_cubicle_no AND effective_date = var_effective_dtm AND c.cubicle_service = b.bed_service;
                    /* get last movement count */
                SELECT
                    movement_count
                    INTO var_movement_count
                    FROM cpi_case
                    WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
                /* get isolation status */
                SELECT
                    icc.iso_code, to_char(localtimestamp, 'Mon DD YYYY HH24:MI:SS'), update_by, code_description
                    INTO var_iso_status, var_update_datetime, var_update_by, var_patient_iso_status
                    FROM isolation_case AS ic
                    LEFT OUTER JOIN isolation_case_code_table AS icc
                        ON ic.iso_status = icc.iso_code
                    WHERE ic.hospital_code = par_hospital_code AND ic.case_no = par_case_no AND ic.movement_count = var_movement_count;
                /* format the cubicle description */
                SELECT
                    CASE
                        WHEN var_sex = 'M' THEN 'male'
                        WHEN var_sex = 'F' THEN 'female'
                        ELSE 'mixed'
                    END
                    INTO var_sex_description;
                SELECT
                    CONCAT(var_cubicle_no, ' - Facility: ', var_isolation_facilities, ' / Service: ', var_cubicle_service_desc, ' / Sex: ', var_sex_description)
                    INTO var_cubicle_header;
            END;
        END IF;
        /* return result */
        OPEN p_refcur FOR
        select c.hospital_code, c.case_no,
        	p.patient_name,
        	p.hkid, h.mrn, p.dob, p.sex,
        	c.last_ward_code,
        	c.last_ward_class,
        	c.last_specialty,
        	c.last_bed_no bed_no,
        	var_is_iso_bed is_iso_bed,
        	c1.unicode_int unicode_int1,
        	c2.unicode_int unicode_int2,
        	c3.unicode_int unicode_int3,
        	c4.unicode_int unicode_int4,
        	c5.unicode_int unicode_int5,
        	c6.unicode_int unicode_int6,
        	var_iso_status patient_iso_status,
        	var_patient_iso_status patient_iso_description,
        	var_isolation_facilities isolation_facilities,
        	var_cubicle_service cubicle_service,
        	var_update_datetime update_datetime,
        	var_update_by update_by,
        	c.update_dtm case_update_datetime,
        	var_cubicle_header cubicleHeader
        	from cpi_patient_hospital_data h,
        	cpi_case c, cpi_patient p
            left join ccc_unicode c1 on substring(p.cccode1,1,4) = c1.ccc_head and substring(p.cccode1,5,1) = c1.ccc_tail
            left join ccc_unicode c2 on substring(p.cccode2,1,4) = c2.ccc_head and substring(p.cccode2,5,1) = c2.ccc_tail
            left join ccc_unicode c3 on substring(p.cccode3,1,4) = c3.ccc_head and substring(p.cccode3,5,1) = c3.ccc_tail
            left join ccc_unicode c4 on substring(p.cccode4,1,4) = c4.ccc_head and substring(p.cccode4,5,1) = c4.ccc_tail
            left join ccc_unicode c5 on substring(p.cccode5,1,4) = c5.ccc_head and substring(p.cccode5,5,1) = c5.ccc_tail
            left join ccc_unicode c6 on substring(p.cccode6,1,4) = c6.ccc_head and substring(p.cccode6,5,1) = c6.ccc_tail
        	where c.patient_key = p.patient_key
        	and c.hospital_code = par_hospital_code
        	and c.case_no = par_case_no
        	and c.hospital_code = h.hospital_code
        	and c.patient_key = h.patient_key;
        RETURN NEXT p_refcur;
        RETURN;
    END;
    RETURN;
END;
$function$
;




;ALTER FUNCTION "cms_dt_get_iso_detail" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
