-- DROP FUNCTION hpi.pass_get_discharged_cases(varchar, varchar, timestamp, timestamp, varchar);

CREATE OR REPLACE FUNCTION hpi.pass_get_discharged_cases(par_hospital character varying, par_ward_list character varying, par_from_discharge_dtm timestamp without time zone, par_to_discharge_dtm timestamp without time zone, par_specialty_list character varying DEFAULT NULL::character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_piece VARCHAR(255);
    var_pos INTEGER;
	p_refcur refcursor;
BEGIN
    CREATE TEMPORARY TABLE t$tmp_ward_list
    (ward_code VARCHAR(8) NULL);
    INSERT INTO t$tmp_ward_list
    VALUES (NULL);

    IF (par_ward_list IS NOT NULL) THEN
        BEGIN
            SELECT
                STRPOS(par_ward_list, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_ward_list, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        INSERT INTO t$tmp_ward_list
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
                    INSERT INTO t$tmp_ward_list
                    VALUES (par_ward_list);
                END;
            END IF;
        END;
    END IF;
    CREATE TEMPORARY TABLE t$tmp_specialty_list
    (specialty_code VARCHAR(8) NULL);
    INSERT INTO t$tmp_specialty_list
    VALUES (NULL);

    IF (par_specialty_list IS NOT NULL) THEN
        BEGIN
            SELECT
                STRPOS(par_specialty_list, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_specialty_list, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        INSERT INTO t$tmp_specialty_list
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_specialty_list PLACING NULL FROM 1 FOR var_pos)
                    INTO par_specialty_list;
                SELECT
                    STRPOS(par_specialty_list, ',')
                    INTO var_pos;
            END LOOP;

            IF par_specialty_list IS NOT NULL THEN
                BEGIN
                    INSERT INTO t$tmp_specialty_list
                    VALUES (par_specialty_list);
                END;
            END IF;
        END;
    END IF;

    IF par_to_discharge_dtm is not null  THEN
        SELECT
            1 * INTERVAL '1 day' + par_to_discharge_dtm::TIMESTAMP
            INTO par_to_discharge_dtm;
    END IF;

    IF (par_ward_list IS NOT NULL OR par_specialty_list IS NOT NULL) THEN
        begin
	        open p_refcur for
			select
				rtrim(c.last_ward_code) last_ward_code,
				rtrim(c.last_bed_no) last_bed_no,
				rtrim(p.patient_name) as patient_name,
				c.patient_key,
				rtrim(p.hkid) hkid,
				p.sex,
				to_char(dob, 'dd-mm-yyyy') as dob,
				p.exact_dob_flag,
				--c.admission_dtm,
				(case when c.admission_dtm is not null
				then to_char(c.admission_dtm, 'dd-mm-yyyy') || ' ' || to_char(c.admission_dtm, 'hh:mm:ss')
				else null end) as admission_dtm,
				c.case_no,
				rtrim(c.last_specialty) last_specialty,
				p.cccode1,
				p.cccode2,
				p.cccode3,
				p.cccode4,
				p.cccode5,
				p.cccode6,
				c1.unicode_int unicode_int1,
				c2.unicode_int unicode_int2,
				c3.unicode_int unicode_int3,
				c4.unicode_int unicode_int4,
				c5.unicode_int unicode_int5,
				c6.unicode_int unicode_int6,
				p.death_indicator,
				--p.death_date,
				case when p.death_date is not null
				then to_char(p.death_date, 'dd-mm-yyyy') || ' ' || to_char(p.death_date, 'yyyy-mm-dd hh:mm:ss')
				else null end as death_date,
				rtrim(c.source_code) as source_code,
				c.discharge_code,
				--c.discharge_dtm
				(case when c.discharge_dtm is not null
				then to_char(c.discharge_dtm, 'dd-mm-yyyy') || ' ' || to_char(c.discharge_dtm, 'hh:mm:ss')
				else null end) as discharge_dtm
			from cpi_patient p
				INNER JOIN cpi_case AS c on c.patient_key = p.patient_key
				INNER JOIN t$tmp_ward_list AS w on (par_ward_list is null or w.ward_code = c.last_ward_code)
				INNER JOIN t$tmp_specialty_list AS s on (par_specialty_list is null or s.specialty_code = c.last_specialty)
				LEFT JOIN ccc_unicode AS c1 ON SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
				LEFT JOIN ccc_unicode AS c2 ON SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
				LEFT JOIN ccc_unicode AS c3 ON SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
				LEFT JOIN ccc_unicode AS c4 ON SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
				LEFT JOIN ccc_unicode AS c5 ON SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
				LEFT JOIN ccc_unicode AS c6 ON SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
	--		and (@ward_list is null or c.last_ward_code = (select * from #tmp_ward_list))
	--		and (@specialty_list is null or c.last_specialty = (select * from #tmp_specialty_list))
			WHERE c.hospital_code = par_hospital
				and (c.discharge_dtm >= par_from_discharge_dtm)
				and (c.discharge_dtm < par_to_discharge_dtm);
			
        END;
    END IF;

    DROP TABLE t$tmp_ward_list;
    DROP TABLE t$tmp_specialty_list;

END;
$function$
;

;ALTER FUNCTION "pass_get_discharged_cases" OWNER TO "HPI_SCHEMA_OWNER_ROLE";