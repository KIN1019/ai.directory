CREATE OR REPLACE FUNCTION pass_get_case_w_patients_addr(IN par_hospital VARCHAR, IN par_case_no_list VARCHAR, IN par_case_no_list2 VARCHAR DEFAULT null, IN par_case_no_list3 VARCHAR DEFAULT null, IN par_case_no_list4 VARCHAR DEFAULT null, IN par_case_no_list5 VARCHAR DEFAULT null, IN par_case_no_list6 VARCHAR DEFAULT null)
RETURNS SETOF refcursor
LANGUAGE plpgsql
AS 
$function$
DECLARE
    var_piece VARCHAR(255);
    var_pos INTEGER;
    var_in_record_count INTEGER;
    var_out_record_count INTEGER;
	p_refcur refcursor;
BEGIN
    CREATE TEMPORARY TABLE t$temp_case_no_list
    (case_no VARCHAR(24));
    /* --handle case_no_list */
    SELECT
        STRPOS(par_case_no_list, ',')
        INTO var_pos;

    WHILE var_pos <> 0 LOOP
        SELECT
            LEFT(par_case_no_list, var_pos - 1)
            INTO var_piece;

        IF var_piece IS NOT NULL THEN
            BEGIN
                SELECT
                    RIGHT(CONCAT('            ', var_piece), 12)
                    INTO var_piece;
                INSERT INTO t$temp_case_no_list
                VALUES (var_piece);
            END;
        END IF;
        SELECT
            OVERLAY(par_case_no_list PLACING NULL FROM 1 FOR var_pos)
            INTO par_case_no_list;
        SELECT
            STRPOS(par_case_no_list, ',')
            INTO var_pos;
    END LOOP;

    IF par_case_no_list IS NOT NULL THEN
        BEGIN
            SELECT
                RIGHT(CONCAT('            ', par_case_no_list), 12)
                INTO par_case_no_list;
            INSERT INTO t$temp_case_no_list
            VALUES (par_case_no_list);
        END;
    END IF;
    /* --handle case_no_list2 */
    IF par_case_no_list2 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_case_no_list2, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_case_no_list2, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        SELECT
                            RIGHT(CONCAT('            ', var_piece), 12)
                            INTO var_piece;
                        INSERT INTO t$temp_case_no_list
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_case_no_list2 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_case_no_list2;
                SELECT
                    STRPOS(par_case_no_list2, ',')
                    INTO var_pos;
            END LOOP;

            IF par_case_no_list2 IS NOT NULL THEN
                BEGIN
                    SELECT
                        RIGHT(CONCAT('            ', par_case_no_list2), 12)
                        INTO par_case_no_list2;
                    INSERT INTO t$temp_case_no_list
                    VALUES (par_case_no_list2);
                END;
            END IF;
        END;
    END IF;
    /* --handle case_no_list3 */
    IF par_case_no_list3 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_case_no_list3, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_case_no_list3, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        SELECT
                            RIGHT(CONCAT('            ', var_piece), 12)
                            INTO var_piece;
                        INSERT INTO t$temp_case_no_list
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_case_no_list3 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_case_no_list3;
                SELECT
                    STRPOS(par_case_no_list3, ',')
                    INTO var_pos;
            END LOOP;

            IF par_case_no_list3 IS NOT NULL THEN
                BEGIN
                    SELECT
                        RIGHT(CONCAT('            ', par_case_no_list3), 12)
                        INTO par_case_no_list3;
                    INSERT INTO t$temp_case_no_list
                    VALUES (par_case_no_list3);
                END;
            END IF;
        END;
    END IF;
    /* --handle case_no_list4 */
    IF par_case_no_list4 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_case_no_list4, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_case_no_list4, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        SELECT
                            RIGHT(CONCAT('            ', var_piece), 12)
                            INTO var_piece;
                        INSERT INTO t$temp_case_no_list
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_case_no_list4 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_case_no_list4;
                SELECT
                    STRPOS(par_case_no_list4, ',')
                    INTO var_pos;
            END LOOP;

            IF par_case_no_list4 IS NOT NULL THEN
                BEGIN
                    SELECT
                        RIGHT(CONCAT('            ', par_case_no_list4), 12)
                        INTO par_case_no_list4;
                    INSERT INTO t$temp_case_no_list
                    VALUES (par_case_no_list4);
                END;
            END IF;
        END;
    END IF;
    /* --handle case_no_list5 */
    IF par_case_no_list5 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_case_no_list5, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_case_no_list5, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        SELECT
                            RIGHT(CONCAT('            ', var_piece), 12)
                            INTO var_piece;
                        INSERT INTO t$temp_case_no_list
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_case_no_list5 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_case_no_list5;
                SELECT
                    STRPOS(par_case_no_list5, ',')
                    INTO var_pos;
            END LOOP;

            IF par_case_no_list5 IS NOT NULL THEN
                BEGIN
                    SELECT
                        RIGHT(CONCAT('            ', par_case_no_list5), 12)
                        INTO par_case_no_list5;
                    INSERT INTO t$temp_case_no_list
                    VALUES (par_case_no_list5);
                END;
            END IF;
        END;
    END IF;
    /* --handle case_no_list6 */
    IF par_case_no_list6 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_case_no_list6, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_case_no_list6, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        SELECT
                            RIGHT(CONCAT('            ', var_piece), 12)
                            INTO var_piece;
                        INSERT INTO t$temp_case_no_list
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_case_no_list6 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_case_no_list6;
                SELECT
                    STRPOS(par_case_no_list6, ',')
                    INTO var_pos;
            END LOOP;

            IF par_case_no_list6 IS NOT NULL THEN
                BEGIN
                    SELECT
                        RIGHT(CONCAT('            ', par_case_no_list6), 12)
                        INTO par_case_no_list6;
                    INSERT INTO t$temp_case_no_list
                    VALUES (par_case_no_list6);
                END;
            END IF;
        END;
    END IF;
    SELECT
        COUNT(1)
        INTO var_in_record_count
        FROM t$temp_case_no_list;
    SELECT
        COUNT(1)
        INTO var_out_record_count
        FROM cpi_patient AS p, cpi_case AS c, t$temp_case_no_list AS l
        WHERE p.patient_key = c.patient_key AND c.hospital_code = par_hospital AND c.case_no = l.case_no;

    IF var_in_record_count <> var_out_record_count THEN
        BEGIN
            RAISE EXCEPTION 'Input and output total no. of case numbers do not match' USING ERRCODE := '99999';
        END;
    ELSE
        BEGIN
            CREATE TEMPORARY TABLE t$temp_case_no_nok_list
            (case_no VARCHAR(24),
                record_id INTEGER,
                nok_record_id INTEGER);
            INSERT INTO t$temp_case_no_nok_list (case_no, record_id, nok_record_id)
            SELECT
                c.case_no,
                CASE SUBSTRING(p.building, 1, 6)
                    WHEN 'HACODE' THEN CAST (SUBSTRING(p.building, 8, 20) AS INTEGER)
                    ELSE 0
                END,
                CASE SUBSTRING(n.building, 1, 6)
                    WHEN 'HACODE' THEN CAST (SUBSTRING(n.building, 8, 20) AS INTEGER)
                    ELSE 0
                END
                FROM t$temp_case_no_list AS l, cpi_case AS c, cpi_patient AS p
                LEFT OUTER JOIN cpi_nok AS n
                    ON (p.patient_key = n.patient_key AND n.major_nok = 'Y')
                WHERE c.case_no = l.case_no AND c.hospital_code = par_hospital AND p.patient_key = c.patient_key;
				
			select rtrim(p.patient_key) patient_key,
					rtrim(p.hkid) hkid,
					rtrim(p.patient_name) patient_name,
					p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6, p.sex,
					convert(p.dob, 'dd-mm-yyyy') as dob,
					p.exact_dob_flag, p.death_indicator,
					convert(p.death_date, 'dd-mm-yyyy') as death_date,
            		c1.unicode_int unicode_int1,
            		c2.unicode_int unicode_int2,
            		c3.unicode_int unicode_int3,
            		c4.unicode_int unicode_int4,
            		c5.unicode_int unicode_int5,
            		c6.unicode_int unicode_int6,
            
            		rtrim(c.hospital_code) hospital_code,
            		rtrim(s.description) source_indicator,
            		rtrim(c.source_code) source_hospital,
            		rtrim(c.case_no) case_no,
            		rtrim(c.case_type) case_type,
					
            		(case when c.admission_dtm is not null then convert(c.admission_dtm, 'dd-mm-yyyy')+' '+convert(c.admission_dtm, 'hh:mm:ss') else null end) as admission_dtm,
					
            		rtrim(c.last_specialty) last_specialty,
            		rtrim(c.last_sub_specialty) last_sub_specialty,
            		rtrim(c.last_ward_code) last_ward_code,
            		rtrim(c.last_bed_no) last_bed_no,
            		rtrim(c.discharge_code) discharge_code,
					
            		(case when c.discharge_dtm is not null then convert(c.discharge_dtm, 'dd-mm-yyyy')+' '+convert(c.discharge_dtm, 'hh:mm:ss') else null end) as discharge_dtm,
					
            		rtrim(c.destination_code) destination_code,
					
            		case c.status_code when 'AC' then 'Active' when 'CC' then 'Cancelled' else null end status_code,
					p.home_phone, p.office_phone, p.office_phone_ext, p.other_phone, p.other_phone_ext, p.room, p.floor, p.block, p.building,
					
            		case substring(p.building, 1, 6) when 'HACODE' then convert (int, substring(p.building, 8, 20)) else 0 end record_id,
					
            		case l.record_id when 0 then p.building else a.bldg_eng end as eng_building,
            		a.bldg_chi chi_building,
            		a.estate_eng eng_estate,
            		a.estate_chi chi_estate,
            		a.house_no street_no,
            		a.street_eng eng_street,
            		a.street_chi chi_street,
            
            		p.district district_code,
            		d.district_name district_eng,
            		d.district_chi,
            		da.area_name area_eng,
            		da.area_chi,
            		c.patient_type,
            
            		e.eh_name eh_eng_name,
            		e.eh_chinese_name eh_chi_name,
            		e.eh_address,
            		e.eh_building,
            		null, --eh_room,
            		null, --eh_floor,
            		null, --eh_block,
            		case eha.district_code when null then e.eh_district_code else eha.district_code end as eh_district_code,
            		--e.eh_district,
            		e.eh_address_id,
            
            		eha.bldg_eng eh_eng_building,
            		eha.bldg_chi eh_chi_building,
            		eha.estate_eng eh_eng_estate,
            		eha.estate_chi eh_chi_estate,
            		eha.house_no eh_street_no,
            		eha.street_eng eh_eng_street,
            		eha.street_chi eh_chi_street,
            
            		ehd.district_name eh_district_eng,
            		ehd.district_chi eh_district_chi,
            		ehda.area_name eh_area_eng,
            		ehda.area_chi  eh_area_chi,
            
            		m.mrn,
            
            		-- create_by, create_dtm, update_by, update_dtm
            		rtrim(c.create_by) create_by,
            		--c.create_dtm,
            		(case when c.create_dtm is not null
            		then convert(c.create_dtm, 'dd-mm-yyyy')+' '+convert(c.create_dtm, 'hh:mm:ss')
            		else null end) as create_dtm,
            		rtrim(c.update_by) update_by,
            		--c.update_dtm,
            		(case when c.update_dtm is not null
            		then convert(c.update_dtm, 'dd-mm-yyyy')+' '+convert(c.update_dtm, 'hh:mm:ss')
            		else null end) as update_dtm,
            
            		n.priority nok_priority,
            		n.major_nok nok_major_nok,
            		rtrim(n.hkid) nok_hkid,
            		n.relationship nok_relationship,
            		nr.description nok_description,
            		rtrim(n.nok_name) nok_name,
            		n.home_phone nok_home_phone,
            		n.office_phone nok_office_phone,
            		n.office_phone_ext nok_office_phone_ext,
            		n.other_phone nok_other_phone,
            		n.other_phone_ext nok_other_phone_ext,
            		n.room nok_room,
            		n.floor nok_floor,
            		n.block nok_block,
            		l.nok_record_id,
            		ne.eh_name nok_eng_eh,
            		ne.eh_chinese_name nok_chi_eh,
            		case l.nok_record_id
            			when 0 then n.building
            			else na.bldg_eng
            		end as nok_eng_building,
            		na.bldg_chi nok_chi_building,
            		na.estate_eng nok_eng_estate,
            		na.estate_chi nok_chi_estate,
            		na.house_no nok_street_no,
            		na.street_eng nok_eng_street,
            		na.street_chi nok_chi_street,
            		case na.district_code
            			when null then n.district
            			else na.district_code
            		end as nok_district_code,
            		nd.district_name nok_district_eng,
            		nd.district_chi nok_district_chi,
            		nda.area_name nok_area_eng,
            		nda.area_chi nok_area_chi
            
            		from cpi_patient p
						INNER JOIN cpi_case as c on p.patient_key = c.patient_key
						INNER JOIN t$temp_case_no_nok_list as l on c.case_no = l.case_no
						LEFT JOIN source as s on c.source_indicator = s.source_indicator
						-- address
						LEFT JOIN address_detail as a on l.record_id = a.record_id
						LEFT JOIN district as d on p.district = d.district_code
						LEFT JOIN district_area as da on d.district_area = da.area_code
						-- elderly home address
						LEFT JOIN cpi_case_detail as cd on c.hospital_code = cd.hospital_code and c.case_no = cd.case_no
						LEFT JOIN elderly_home_table as e on cd.eh_code = e.eh_code
						LEFT JOIN address_detail as eha on e.eh_address_id = eha.record_id
						LEFT JOIN district as ehd on (eha.district_code = ehd.district_code or e.eh_district_code = ehd.district_code)
						LEFT JOIN district_area as ehda on ehd.district_area = ehda.area_code
						-- mrn
						LEFT JOIN cpi_patient_hospital_data as m on p.patient_key = m.patient_key and c.hospital_code = m.hospital_code
						-- nok
						LEFT JOIN cpi_nok as n on p.patient_key = n.patient_key
						LEFT JOIN nok_relation as nr on n.relationship = nr.nok_relation_code
						-- nok address
						LEFT JOIN address_detail as na on l.nok_record_id = na.record_id
						LEFT JOIN elderly_home_table as ne on l.nok_record_id = ne.eh_address_id
						LEFT JOIN district as nd on (na.district_code = nd.district_code or n.district = nd.district_code )
						LEFT JOIN district_area as nda on nd.district_area = nda.area_code
						LEFT JOIN ccc_unicode AS c1 ON SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
						LEFT JOIN ccc_unicode AS c2 ON SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
						LEFT JOIN ccc_unicode AS c3 ON SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
						LEFT JOIN ccc_unicode AS c4 ON SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
						LEFT JOIN ccc_unicode AS c5 ON SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
						LEFT JOIN ccc_unicode AS c6 ON SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
            		where c.hospital_code = par_hospital
            		and n.major_nok = 'Y'
            		order by patient_key;

            DROP TABLE t$temp_case_no_nok_list;
        END;
    END IF;

    DROP TABLE IF EXISTS t$temp_case_no_list;
    DROP TABLE IF EXISTS t$temp_case_no_nok_list;

END;
$function$;