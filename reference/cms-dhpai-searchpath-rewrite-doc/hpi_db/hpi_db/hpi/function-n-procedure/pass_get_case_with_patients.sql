CREATE OR REPLACE FUNCTION pass_get_case_with_patients(IN par_hospital VARCHAR, IN par_case_no_list VARCHAR, IN par_case_no_list2 VARCHAR DEFAULT null, IN par_case_no_list3 VARCHAR DEFAULT null, IN par_case_no_list4 VARCHAR DEFAULT null, IN par_case_no_list5 VARCHAR DEFAULT null, IN par_case_no_list6 VARCHAR DEFAULT null, IN par_forceReturn VARCHAR DEFAULT 'N')
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

    IF var_in_record_count <> var_out_record_count AND par_forceReturn <> 'Y' THEN
        BEGIN
            RAISE EXCEPTION 'Input and output total no. of case numbers do not match' USING ERRCODE := '99999';
        END;
    ELSE
        BEGIN
			select rtrim(p.patient_key), rtrim(hkid), rtrim(patient_name),
            		cccode1, cccode2, cccode3, cccode4, cccode5, cccode6,
            		sex, convert(p.dob, 'dd-mm-yyyy') as dob, exact_dob_flag,
            		death_indicator, convert(p.death_date, 'dd-mm-yyyy') as death_date,
            		c1.unicode_int unicode_int1,
            		c2.unicode_int unicode_int2,
            		c3.unicode_int unicode_int3,
            		c4.unicode_int unicode_int4,
            		c5.unicode_int unicode_int5,
            		c6.unicode_int unicode_int6,
            
            		rtrim(c.hospital_code),
            		rtrim(c.case_no),
            		rtrim(c.case_type),
            		(case when c.admission_dtm is not null
            		then convert(c.admission_dtm, 'dd-mm-yyyy')+' '+convert(c.admission_dtm, 'hh:mm:ss')
            		else null end) as admission_dtm,
            		rtrim(c.last_specialty),
            		rtrim(c.last_sub_specialty),
            		rtrim(c.last_ward_code),
            		rtrim(c.last_bed_no),
            		rtrim(c.discharge_code),
            		(case when c.discharge_dtm is not null
            		then convert(c.discharge_dtm, 'dd-mm-yyyy')+' '+convert(c.discharge_dtm, 'hh:mm:ss')
            		else null end) as discharge_dtm,
            		rtrim(c.destination_code),
            		case c.status_code
            			when 'AC' then 'Active'
            			when 'CC' then 'Cancelled'
            			else null
            		end,
            		c.patient_type
            
            		from cpi_patient p
						INNER JOIN cpi_case as c on p.patient_key = c.patient_key
						INNER JOIN t$temp_case_no_list as l on c.case_no = l.case_no
						LEFT JOIN ccc_unicode AS c1 ON SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
						LEFT JOIN ccc_unicode AS c2 ON SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
						LEFT JOIN ccc_unicode AS c3 ON SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
						LEFT JOIN ccc_unicode AS c4 ON SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
						LEFT JOIN ccc_unicode AS c5 ON SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
						LEFT JOIN ccc_unicode AS c6 ON SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
            		where c.hospital_code = par_hospital;
		
        END;
    END IF;
    DROP TABLE t$temp_case_no_list;
END;
$function$;