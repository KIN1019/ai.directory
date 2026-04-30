-- DROP FUNCTION hpi.hasp_web_patient_location_chi(varchar, varchar, varchar, varchar, varchar, timestamp, timestamp, varchar, int4, varchar, varchar, varchar, varchar, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hasp_web_patient_location_chi(par_hosp_code character varying, par_as_name character varying, par_as_soundex character varying, par_as_phonetic character varying, par_as_sex character varying, par_adt_dob_from timestamp without time zone, par_adt_dob_to timestamp without time zone, par_as_phone_no character varying, par_ai_authority_code integer, par_as_is_chinese character varying, par_in_cccode1 character varying, par_in_cccode2 character varying, par_in_cccode3 character varying, par_in_cccode4 character varying, par_in_cccode5 character varying, par_in_cccode6 character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$ 
/* 
2014-08-05 Ray HA  Modify stored procedure to support chinese VARCHARacter search 
Chinese name search is base on five new parameters including six cccodes 
*/ 
/* 2014-08-05 Ray HA  - Start */ 
/* 2014-08-05 Ray HA  - End */ 
declare 
    p_refcur refcursor; 
	var_soundex_code VARCHAR(5); 
    var_temp_int INTEGER; 
    var_return_code INTEGER; 
    /* 2006-09-19 HK Fong SMR20015696 - Start */ 
    var_hkid VARCHAR(12); 
    var_case_no VARCHAR(12); 
    var_chi_name VARCHAR(12); 
    var_schi_name VARCHAR(12); 
    var_is_schi_name VARCHAR(01); 
    var_cccode1 VARCHAR(05); 
    var_cccode2 VARCHAR(05); 
    var_cccode3 VARCHAR(05); 
    var_cccode4 VARCHAR(05); 
    var_cccode5 VARCHAR(05); 
    var_cccode6 VARCHAR(05); 
    var_phonetic VARCHAR(48); 
    var_error INTEGER; 
    /* 2006-09-19 HK Fong SMR20015696 - End */ 
    /* 2014-08-05 Ray HA  - Start */ 
    var_chi_name_Len INTEGER; 
    csr CURSOR FOR 
		SELECT 
		    hkid, case_no, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6 
		FROM t$temptable2; 
BEGIN
    <<return_error>>
    BEGIN
        IF par_as_name = '%' THEN /* This part of IF statements is used */
            SELECT NULL
            INTO par_as_name;
        END IF; /* in order to allow the front and back */

        IF par_as_soundex = '%' THEN /* ends to distribute at different time. */
            SELECT NULL
            INTO par_as_soundex;
        END IF; /* Therefore, this part can be deleted */

        IF par_as_phonetic = '%' THEN /* after both front end and back end */
            SELECT NULL
            INTO par_as_phonetic;
        END IF;
        /* have been delivered. */
        /* 2014-08-05 Ray HA  - End */
        DROP TABLE IF EXISTS t$temptable2;
        CREATE TEMPORARY TABLE t$temptable2
        (
--        row_no BIGINT GENERATED ALWAYS AS IDENTITY, /* 2006-09-19 HK Fong SMR20015696 */ 
            hkid          VARCHAR(12)                 NULL,
            case_no       VARCHAR(12)                 NULL,
            dob           TIMESTAMP WITHOUT TIME ZONE NULL,
            patient_key   VARCHAR(8)                  NULL,
            access_code   INTEGER                     NULL,
            /* 2006-09-19 HK Fong SMR20015696 - Start */
            cccode1       VARCHAR(05)                 NULL,
            cccode2       VARCHAR(05)                 NULL,
            cccode3       VARCHAR(05)                 NULL,
            cccode4       VARCHAR(05)                 NULL,
            cccode5       VARCHAR(05)                 NULL,
            cccode6       VARCHAR(05)                 NULL,
            name_phonetic VARCHAR(48)                 NULL,
            chi_name      VARCHAR(12)                 NULL,
            schi_name     VARCHAR(12)                 NULL
        );
        --CREATE UNIQUE INDEX temptable2_idx ON t$temptable2
--    (row_no); 
-- 
/* 2006-09-19 HK Fong SMR20015696 - End */
/* modified for HPI by ML on 30.07.1999 */
/* --declare	@hosp_code	char(3) */
/* --select @hosp_code = Hospital_code from Hospital */
/* --exec cpi..cpi_get_int_by_bin NNNNNNNNNNYYYYYYYYNNNNNNNNNNNNN, */
        CALL cpi_get_int_by_bin(var_return_code, 'NNNNNNNNNNYYYYYYYYNNNNNNNNNNNNN', var_temp_int);

        SELECT par_ai_authority_code & var_temp_int
        INTO par_ai_authority_code;
/* remove cpi.. for HPI by ML on 30.07.1999 */
        IF par_as_name is not NULL THEN
            /* 2014-08-05 Ray HA  - Start */
            begin
                IF par_as_is_chinese = 'Y' THEN
                    BEGIN
                        SELECT LENGTH(RTRIM(par_as_name))
                        INTO var_chi_name_Len;
                        /* --select @chi_name_Len, @as_name */
                        INSERT INTO t$temptable2
                        SELECT pm.hkid,
                               pl.case_no,
                               pl.dob,
                               pm.patient_key,
                               pm.access_code,
                            /* 2006-09-01 HK Fong SMR20015696 - Start */
                               pm.cccode1,
                               pm.cccode2,
                               pm.cccode3,
                               pm.cccode4,
                               pm.cccode5,
                               pm.cccode6,
                               '',
                               '',
                               ''
                        /* 2006-09-01 HK Fong SMR20015696 - End */
                        FROM cpi_patient AS pm,
                             cpi_patient_location AS pl
                        WHERE pm.access_code & par_ai_authority_code > 0
                          AND pl.patient_key = pm.patient_key
                          AND pl.cccode1 = par_in_cccode1
                          AND (pl.cccode2 = par_in_cccode2 OR par_in_cccode2 = '')
                          AND (pl.cccode3 = par_in_cccode3 OR par_in_cccode3 = '')
                          AND (pl.cccode4 = par_in_cccode4 OR par_in_cccode4 = '')
                          AND (pl.cccode5 = par_in_cccode5 OR par_in_cccode5 = '')
                          AND (pl.cccode6 = par_in_cccode6 OR par_in_cccode6 = '')
                          AND (COALESCE(pl.sex, '') LIKE par_as_sex)
                          AND (COALESCE(pl.dob, '18000101') >= par_adt_dob_from)
                          AND (COALESCE(pl.dob, '18000101') <= par_adt_dob_to)
                          AND (pl.hospital_code = par_hosp_code);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temptable2
                        SELECT pm.hkid,
                               pl.case_no,
                               pl.dob,
                               pm.patient_key,
                               pm.access_code,
                            /* 2006-09-19 HK Fong SMR20015696 - Start */
                               pm.cccode1,
                               pm.cccode2,
                               pm.cccode3,
                               pm.cccode4,
                               pm.cccode5,
                               pm.cccode6,
                               '',
                               '',
                               ''
                        /* 2006-09-19 HK Fong SMR20015696 - End */
                        /* --from cpi..cpi_patient PM, cpi..cpi_patient_location PL */
                        FROM cpi_patient AS pm,
                             cpi_patient_location AS pl
                        WHERE pm.access_code & par_ai_authority_code > 0
                          AND pl.patient_key = pm.patient_key
                          AND pl.patient_name LIKE par_as_name
                          AND (COALESCE(pl.sex, '') LIKE par_as_sex)
                          AND (COALESCE(pl.dob, '18000101') >= par_adt_dob_from)
                          AND (COALESCE(pl.dob, '18000101') <= par_adt_dob_to)
                          AND (pl.hospital_code = par_hosp_code);


                    END;


                END IF;
            END;
        ELSE
            IF par_as_soundex is not NULL THEN
                BEGIN
                    select
                    -- soundex(par_as_soundex) || '%' 
                    --	 soundex(SUBSTRING(par_as_soundex FROM 1 FOR 4)) 
                    --	 soundex(SUBSTRING(par_as_soundex FROM 1 FOR 4)) || '%' 
                    --    soundex(translate(par_as_soundex, ',%','')) 
                    --    soundex(regexp_replace(par_as_soundex,'[^a-zA-Z]','','g')) 
                    soundex(SPLIT_PART(par_as_soundex, ',', 1))
                    INTO var_soundex_code;
                    raise notice 'var_soundex_code: %' , var_soundex_code;
                    INSERT INTO t$temptable2
                    SELECT pm.hkid,
                           pl.case_no,
                           pl.dob,
                           pm.patient_key,
                           pm.access_code,
                        /* 2006-09-19 HK Fong SMR20015696 - Start */
                           pm.cccode1,
                           pm.cccode2,
                           pm.cccode3,
                           pm.cccode4,
                           pm.cccode5,
                           pm.cccode6,
                           '',
                           '',
                           ''
                    /* 2006-09-19 HK Fong SMR20015696 - End */
/* --from cpi..cpi_patient PM, cpi..cpi_patient_location PL */
                    FROM cpi_patient AS pm,
                         cpi_patient_location AS pl
                    WHERE ((pm.access_code & par_ai_authority_code) > 0)
                      AND pl.patient_key = pm.patient_key
                      AND pl.name_soundex LIKE var_soundex_code
                      AND (COALESCE(pl.sex, '') LIKE par_as_sex)
                      AND (COALESCE(pl.dob, '18000101') >= par_adt_dob_from)
                      AND (COALESCE(pl.dob, '18000101') <= par_adt_dob_to)
                      AND (pl.hospital_code = par_hosp_code);


                END;
            ELSE
                IF par_as_phonetic is not NULL THEN
                    INSERT INTO t$temptable2
                    SELECT pm.hkid,
                           pl.case_no,
                           pl.dob,
                           pm.patient_key,
                           pm.access_code,
                        /* 2006-09-19 HK Fong SMR20015696 - Start */
                           pm.cccode1,
                           pm.cccode2,
                           pm.cccode3,
                           pm.cccode4,
                           pm.cccode5,
                           pm.cccode6,
                           '',
                           '',
                           ''
                    /* 2006-09-19 HK Fong SMR20015696 - End */
/* --from cpi..cpi_patient PM, cpi..cpi_patient_location PL */
                    FROM cpi_patient AS pm,
                         cpi_patient_location AS pl
                    WHERE ((pm.access_code & par_ai_authority_code) > 0)
                      AND pl.patient_key = pm.patient_key
                      AND pl.name_phonetic LIKE par_as_phonetic
                      AND (COALESCE(pl.sex, '') LIKE par_as_sex)
                      AND (COALESCE(pl.dob, '18000101') >= par_adt_dob_from)
                      AND (COALESCE(pl.dob, '18000101') <= par_adt_dob_to)
                      AND (pl.hospital_code = par_hosp_code);
                ELSE
                    IF par_as_phone_no is not NULL THEN
                        INSERT INTO t$temptable2
                        SELECT pm.hkid,
                               pl.case_no,
                               pl.dob,
                               pm.patient_key,
                               pm.access_code,
                            /* 2006-09-19 HK Fong SMR20015696 - Start */
                               pm.cccode1,
                               pm.cccode2,
                               pm.cccode3,
                               pm.cccode4,
                               pm.cccode5,
                               pm.cccode6,
                               '',
                               '',
                               ''
                        /* 2006-09-19 HK Fong SMR20015696 - End */
/* --from cpi..cpi_patient PM, cpi..cpi_patient_location PL */
                        FROM cpi_patient AS pm,
                             cpi_patient_location AS pl
                        WHERE ((pm.access_code & par_ai_authority_code) > 0)
                          AND pl.patient_key = pm.patient_key
                          AND pl.phone1 LIKE par_as_phone_no
                          AND (pl.hospital_code = par_hosp_code);
                    END IF;
                END IF;
            END IF;
        END IF;
        /* 2006-09-19 HK Fong SMR20015696 - Start */
        /* 2006-09-01 HK Fong SMR20015696 - Start */

        OPEN csr;
        FETCH csr INTO var_hkid, var_case_no, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6;

        WHILE (CASE
                   WHEN FOUND THEN 0
                   WHEN NOT FOUND THEN 2
                   ELSE 1
            END) = 0
            LOOP
                BEGIN
                    CALL hasp_get_phonetic_chin_name(var_return_code,var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5,
                                                     var_cccode6, var_phonetic, var_chi_name);
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;

                IF var_error <> 0 THEN
                    EXIT return_error;
                END IF;

                IF COALESCE(var_chi_name, '') <> '' THEN
                    BEGIN
                        CALL hasp_check_schi_name(pas_return_code=>var_return_code,par_ccc1 => var_cccode1, par_ccc2 => var_cccode2,
                                                  par_ccc3 => var_cccode3, par_ccc4 => var_cccode4,
                                                  par_ccc5 => var_cccode5, par_ccc6 => var_cccode6,
                                                  par_is_schi_name => var_is_schi_name);

                        IF var_is_schi_name = 'Y' THEN
                            SELECT var_chi_name
                            INTO var_schi_name;
                        ELSE
                            SELECT ''
                            INTO var_schi_name;
                        END IF;
                    END;
                ELSE
                    SELECT ''
                    INTO var_schi_name;
                END IF;
                UPDATE t$temptable2
                SET name_phonetic = var_phonetic,
                    chi_name      = var_chi_name,
                    schi_name     = var_schi_name
                WHERE CURRENT OF csr;
                FETCH csr INTO var_hkid, var_case_no, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6;
            END LOOP;
        CLOSE csr;
        /* 2006-09-19 HK Fong SMR20015696 - End */
/* 
select directly from cpi_case and cpi_movement due to wrong index 
used for view by ML on 11.08.1999 
*/
    END;

    OPEN p_refcur FOR
        SELECT t.hkid,
               t.case_no,
               pl.patient_name,
               pl.name_soundex,
            /* 2006-09-19 HK Fong SMR20015696 - Start */
            /* PL.name_phonetic, PL.sex, T.dob, PL.chinese_name, */
               t.name_phonetic,
               pl.sex,
               t.dob,
               t.chi_name,
            /* 2006-09-19 HK Fong SMR20015696 - End */
               pl.phone1,
               pl.phone2,
               pl.mobile_phone,
            /* C.Admission_datetime, */

            /* --	C.Discharge_datetime, */
               c.admission_dtm,
               c.discharge_dtm,
            /* MT.Ward_code, */
            /* MT.Bed_no, */
            /* MT.Specialty_code, */
               mt.ward_code,
               mt.bed_no,
               mt.specialty,
               REPEAT('', 5),
            /* --	C.Destination_code, */
            /* --	C.Discharge_code, */
            /* --	C.Case_type, */
               c.destination_code,
               c.discharge_code,
               c.case_type,
               t.access_code,
            /* 2006-09-19 HK Fong SMR20015696 - Start */
               t.schi_name,
            /* 2006-09-19 HK Fong SMR20015696 - End */
            /* 2009-10-12 Enquiry of Patient Location unicode problem solviing - Start */
               (SELECT unicode_int
                FROM ccc_unicode
                WHERE ccc_head = SUBSTRING(t.cccode1, 1, 4)
                  AND ccc_tail = SUBSTRING(t.cccode1, 5, 1)) AS unicode1,
               (SELECT unicode_int
                FROM ccc_unicode
                WHERE ccc_head = SUBSTRING(t.cccode2, 1, 4)
                  AND ccc_tail = SUBSTRING(t.cccode2, 5, 1)) AS unicode2,
               (SELECT unicode_int
                FROM ccc_unicode
                WHERE ccc_head = SUBSTRING(t.cccode3, 1, 4)
                  AND ccc_tail = SUBSTRING(t.cccode3, 5, 1)) AS unicode3,
               (SELECT unicode_int
                FROM ccc_unicode
                WHERE ccc_head = SUBSTRING(t.cccode4, 1, 4)
                  AND ccc_tail = SUBSTRING(t.cccode4, 5, 1)) AS unicode4,
               (SELECT unicode_int
                FROM ccc_unicode
                WHERE ccc_head = SUBSTRING(t.cccode5, 1, 4)
                  AND ccc_tail = SUBSTRING(t.cccode5, 5, 1)) AS unicode5,
               (SELECT unicode_int
                FROM ccc_unicode
                WHERE ccc_head = SUBSTRING(t.cccode6, 1, 4)
                  AND ccc_tail = SUBSTRING(t.cccode6, 5, 1)) AS unicode6,
               t.patient_key
        /* 2009-10-12 Enquiry of Patient Location unicode problem solviing - End */
/* FROM	Case C, Movement MT, cpi_patient_location PL, #temptable2 T */
        FROM cpi_case AS c,
             cpi_movement AS mt,
             cpi_patient_location AS pl,
             t$temptable2 AS t,
             cpi_active_case AS a
/* 
WHERE	( C.Case_no = T.case_no ) and 
( MT.Case_no = T.case_no ) and 
( MT.Movement_count = C.Movement_count) and 
*/
        WHERE (c.case_no = t.case_no)
          AND (a.case_no = c.case_no)
          AND (c.status_code <> 'CC')
          AND (mt.case_no = t.case_no)
          AND (mt.movement_count = c.movement_count)
          AND (pl.case_no = t.case_no)
          AND (pl.hospital_code = par_hosp_code)
          AND (mt.hospital_code = par_hosp_code)
          AND (c.hospital_code = par_hosp_code)
          AND (a.hospital_code = par_hosp_code)
         /* AND
            /* IPAS-124 - 20190814 - Ray - Hide all confidential patient no matter supervisor or super user */
            t.access_code & 1 = 1*/
        ORDER BY pl.patient_name::bytea NULLS first, c.admission_dtm asc nulls first, c.discharge_dtm nulls first;


    RETURN NEXT p_refcur;
  



END; 
$function$
;


;ALTER FUNCTION "hasp_web_patient_location_chi" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
