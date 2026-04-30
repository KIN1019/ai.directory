CREATE OR REPLACE FUNCTION pass_get_ward_spec_patient(IN par_hospital VARCHAR, IN par_ward_list VARCHAR DEFAULT null, IN par_spec_list VARCHAR DEFAULT null)
RETURNS SETOF refcursor
LANGUAGE plpgsql
AS
$function$
DECLARE
    var_piece VARCHAR(255);
    var_pos INTEGER;
	p_refcur refcursor;
BEGIN
    DROP TABLE IF EXISTS t$temp_ward_list;
    DROP TABLE IF EXISTS t$temp_spec_list;
    CREATE TEMPORARY TABLE t$temp_ward_list
    (ward_code VARCHAR(8) NULL);
    CREATE TEMPORARY TABLE t$temp_spec_list
    (spec_code VARCHAR(8) NULL);
    INSERT INTO t$temp_ward_list
    VALUES (NULL);
    INSERT INTO t$temp_spec_list
    VALUES (NULL);
    SELECT
        STRPOS(par_ward_list, ',')
        INTO var_pos;

    WHILE var_pos <> 0 LOOP
        SELECT
            LEFT(par_ward_list, var_pos - 1)
            INTO var_piece;

        IF var_piece IS NOT NULL THEN
            BEGIN
                INSERT INTO t$temp_ward_list
                VALUES (var_piece);
            END;
        END IF;
        SELECT
            OVERLAY(par_ward_list PLACING NULL FROM 1 FOR var_pos)
            INTO par_ward_list;
        SELECT
            STRPOS(par_ward_list, ',')
            INTO var_pos;
    END LOOP;

    IF par_ward_list IS NOT NULL THEN
        BEGIN
            INSERT INTO t$temp_ward_list
            VALUES (par_ward_list);
        END;
    END IF;
    SELECT
        STRPOS(par_spec_list, ',')
        INTO var_pos;

    WHILE var_pos <> 0 LOOP
        SELECT
            LEFT(par_spec_list, var_pos - 1)
            INTO var_piece;

        IF var_piece IS NOT NULL THEN
            BEGIN
                INSERT INTO t$temp_spec_list
                VALUES (var_piece);
            END;
        END IF;
        SELECT
            OVERLAY(par_spec_list PLACING NULL FROM 1 FOR var_pos)
            INTO par_spec_list;
        SELECT
            STRPOS(par_spec_list, ',')
            INTO var_pos;
    END LOOP;

    IF par_spec_list IS NOT NULL THEN
        BEGIN
            INSERT INTO t$temp_spec_list
            VALUES (par_spec_list);
        END;
    END IF;
	
	open p_refcur for select rtrim(w.ward_code) as ward_code, rtrim(w.bed_no) as bed_no,
        rtrim(p.patient_name) as patient_name, p.patient_key, rtrim(p.hkid) as hkid, p.sex,
        TO_CHAR(p.dob, 'dd-mm-yyyy') as dob, p.exact_dob_flag,
        (case when c.admission_dtm is not null
        then TO_CHAR(c.admission_dtm, 'dd-mm-yyyy hh:mm:ss')
        else null end) as admission_dtm, rtrim(c.case_no) case_no, rtrim(w.specialty_code) specialty_code,
        p.cccode1, p.cccode2, p.cccode3,
        p.cccode4, p.cccode5, p.cccode6,
        c1.unicode_int unicode_int1,
        c2.unicode_int unicode_int2,
        c3.unicode_int unicode_int3,
        c4.unicode_int unicode_int4,
        c5.unicode_int unicode_int5,
        c6.unicode_int unicode_int6,
        p.death_indicator,
        case when p.death_date is not null
        then TO_CHAR(p.death_date, 'dd-mm-yyyy  hh:mm:ss')
        else null end as death_date,
        rtrim(c.source_code) as source_code,
        ab.ambulance_no
        from cpi_patient p
			INNER JOIN cpi_case AS c on p.patient_key = c.patient_key
			INNER JOIN cpi_ward_list AS w on c.hospital_code = w.hospital_code and c.case_no = w.case_no
			INNER JOIN t$temp_ward_list AS wl on (par_ward_list is null or w.ward_code = wl.ward_code)
			INNER JOIN t$temp_spec_list AS sl on (par_spec_list is null or w.specialty_code = sl.spec_code)
			LEFT JOIN cpi_ae_case_detail AS ab on c.hospital_code = ab.hospital_code and c.case_no = ab.case_no
			LEFT OUTER JOIN ccc_unicode AS c1 ON SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
			LEFT OUTER JOIN ccc_unicode AS c2 ON SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
			LEFT OUTER JOIN ccc_unicode AS c3 ON SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
			LEFT OUTER JOIN ccc_unicode AS c4 ON SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
			LEFT OUTER JOIN ccc_unicode AS c5 ON SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
			LEFT OUTER JOIN ccc_unicode AS c6 ON SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
        where c.hospital_code = par_hospital
        order by w.ward_code;

    -- DROP TABLE t$temp_ward_list;
    -- DROP TABLE t$temp_spec_list;
    return next p_refcur;

END;
$function$;