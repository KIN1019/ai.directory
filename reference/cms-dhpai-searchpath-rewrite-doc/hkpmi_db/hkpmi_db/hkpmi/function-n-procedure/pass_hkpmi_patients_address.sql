-- DROP FUNCTION hkpmi.pass_hkpmi_patients_address(varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi.pass_hkpmi_patients_address(par_patient_key_list1 character varying DEFAULT NULL::character varying, par_patient_key_list2 character varying DEFAULT NULL::character varying, par_patient_key_list3 character varying DEFAULT NULL::character varying, par_patient_key_list4 character varying DEFAULT NULL::character varying, par_patient_key_list5 character varying DEFAULT NULL::character varying, par_patient_key_list6 character varying DEFAULT NULL::character varying, par_hkid_list1 character varying DEFAULT NULL::character varying, par_hkid_list2 character varying DEFAULT NULL::character varying, par_hkid_list3 character varying DEFAULT NULL::character varying, par_hkid_list4 character varying DEFAULT NULL::character varying, par_hkid_list5 character varying DEFAULT NULL::character varying, par_hkid_list6 character varying DEFAULT NULL::character varying, par_project character varying DEFAULT NULL::character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_piece VARCHAR(255);
    var_pos INTEGER;
    var_in_record_count INTEGER;
    var_out_record_count INTEGER;
    var_patient_key VARCHAR(8);
    var_hkid VARCHAR(12);
    var_nf_pk_list VARCHAR(255);
    var_nf_hkid_list VARCHAR(255);

    p_refcur refcursor; 
BEGIN
    CREATE TEMPORARY TABLE t$temp_patient_key_list
    (patient_key VARCHAR(8),
        record_id INTEGER NULL);
    CREATE TEMPORARY TABLE t$temp_pk_hkid_list
    (patient_key VARCHAR(8) NULL,
        hkid VARCHAR(12) NULL);
    CREATE TEMPORARY TABLE t$temp_found_patient_key_list
    (patient_key VARCHAR(8));

    IF par_patient_key_list1 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_patient_key_list1, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_patient_key_list1, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        INSERT INTO t$temp_pk_hkid_list (patient_key)
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_patient_key_list1 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_patient_key_list1;
                SELECT
                    STRPOS(par_patient_key_list1, ',')
                    INTO var_pos;
            END LOOP;

            IF par_patient_key_list1 IS NOT NULL THEN
                BEGIN
                    INSERT INTO t$temp_pk_hkid_list (patient_key)
                    VALUES (par_patient_key_list1);
                END;
            END IF;
        END;
    END IF;

    IF par_patient_key_list2 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_patient_key_list2, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_patient_key_list2, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        INSERT INTO t$temp_pk_hkid_list (patient_key)
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_patient_key_list2 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_patient_key_list2;
                SELECT
                    STRPOS(par_patient_key_list2, ',')
                    INTO var_pos;
            END LOOP;

            IF par_patient_key_list2 IS NOT NULL THEN
                BEGIN
                    INSERT INTO t$temp_pk_hkid_list (patient_key)
                    VALUES (par_patient_key_list2);
                END;
            END IF;
        END;
    END IF;

    IF par_patient_key_list3 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_patient_key_list3, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_patient_key_list3, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        INSERT INTO t$temp_pk_hkid_list (patient_key)
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_patient_key_list3 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_patient_key_list3;
                SELECT
                    STRPOS(par_patient_key_list3, ',')
                    INTO var_pos;
            END LOOP;

            IF par_patient_key_list3 IS NOT NULL THEN
                BEGIN
                    INSERT INTO t$temp_pk_hkid_list (patient_key)
                    VALUES (par_patient_key_list3);
                END;
            END IF;
        END;
    END IF;

    IF par_patient_key_list4 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_patient_key_list4, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_patient_key_list4, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        INSERT INTO t$temp_pk_hkid_list (patient_key)
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_patient_key_list4 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_patient_key_list4;
                SELECT
                    STRPOS(par_patient_key_list4, ',')
                    INTO var_pos;
            END LOOP;

            IF par_patient_key_list4 IS NOT NULL THEN
                BEGIN
                    INSERT INTO t$temp_pk_hkid_list (patient_key)
                    VALUES (par_patient_key_list4);
                END;
            END IF;
        END;
    END IF;

    IF par_patient_key_list5 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_patient_key_list5, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_patient_key_list5, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        INSERT INTO t$temp_pk_hkid_list (patient_key)
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_patient_key_list5 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_patient_key_list5;
                SELECT
                    STRPOS(par_patient_key_list5, ',')
                    INTO var_pos;
            END LOOP;

            IF par_patient_key_list5 IS NOT NULL THEN
                BEGIN
                    INSERT INTO t$temp_pk_hkid_list (patient_key)
                    VALUES (par_patient_key_list5);
                END;
            END IF;
        END;
    END IF;

    IF par_patient_key_list6 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_patient_key_list6, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_patient_key_list6, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        INSERT INTO t$temp_pk_hkid_list (patient_key)
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_patient_key_list6 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_patient_key_list6;
                SELECT
                    STRPOS(par_patient_key_list6, ',')
                    INTO var_pos;
            END LOOP;

            IF par_patient_key_list6 IS NOT NULL THEN
                BEGIN
                    INSERT INTO t$temp_pk_hkid_list (patient_key)
                    VALUES (par_patient_key_list6);
                END;
            END IF;
        END;
    END IF;
    /* --HKID list Start */
    IF par_hkid_list1 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_hkid_list1, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_hkid_list1, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        IF OCTET_LENGTH(LTRIM(RTRIM(var_piece))) = 8 THEN
                            SELECT
                                CONCAT(' ', var_piece)
                                INTO var_piece;
                        END IF;
                        INSERT INTO t$temp_pk_hkid_list (hkid)
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_hkid_list1 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_hkid_list1;
                SELECT
                    STRPOS(par_hkid_list1, ',')
                    INTO var_pos;
            END LOOP;

            IF par_hkid_list1 IS NOT NULL THEN
                BEGIN
                    IF OCTET_LENGTH(LTRIM(RTRIM(par_hkid_list1))) = 8 THEN
                        SELECT
                            CONCAT(' ', par_hkid_list1)
                            INTO par_hkid_list1;
                    END IF;
                    INSERT INTO t$temp_pk_hkid_list (hkid)
                    VALUES (par_hkid_list1);
                END;
            END IF;
        END;
    END IF;

    IF par_hkid_list2 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_hkid_list2, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_hkid_list2, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        IF OCTET_LENGTH(LTRIM(RTRIM(var_piece))) = 8 THEN
                            SELECT
                                CONCAT(' ', var_piece)
                                INTO var_piece;
                        END IF;
                        INSERT INTO t$temp_pk_hkid_list (hkid)
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_hkid_list2 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_hkid_list2;
                SELECT
                    STRPOS(par_hkid_list2, ',')
                    INTO var_pos;
            END LOOP;

            IF par_hkid_list2 IS NOT NULL THEN
                BEGIN
                    IF OCTET_LENGTH(LTRIM(RTRIM(par_hkid_list2))) = 8 THEN
                        SELECT
                            CONCAT(' ', par_hkid_list2)
                            INTO par_hkid_list2;
                    END IF;
                    INSERT INTO t$temp_pk_hkid_list (hkid)
                    VALUES (par_hkid_list2);
                END;
            END IF;
        END;
    END IF;

    IF par_hkid_list3 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_hkid_list3, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_hkid_list3, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        IF OCTET_LENGTH(LTRIM(RTRIM(var_piece))) = 8 THEN
                            SELECT
                                CONCAT(' ', var_piece)
                                INTO var_piece;
                        END IF;
                        INSERT INTO t$temp_pk_hkid_list (hkid)
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_hkid_list3 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_hkid_list3;
                SELECT
                    STRPOS(par_hkid_list3, ',')
                    INTO var_pos;
            END LOOP;

            IF par_hkid_list3 IS NOT NULL THEN
                BEGIN
                    IF OCTET_LENGTH(LTRIM(RTRIM(par_hkid_list3))) = 8 THEN
                        SELECT
                            CONCAT(' ', par_hkid_list3)
                            INTO par_hkid_list3;
                    END IF;
                    INSERT INTO t$temp_pk_hkid_list (hkid)
                    VALUES (par_hkid_list3);
                END;
            END IF;
        END;
    END IF;

    IF par_hkid_list4 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_hkid_list4, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_hkid_list4, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        IF OCTET_LENGTH(LTRIM(RTRIM(var_piece))) = 8 THEN
                            SELECT
                                CONCAT(' ', var_piece)
                                INTO var_piece;
                        END IF;
                        INSERT INTO t$temp_pk_hkid_list (hkid)
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_hkid_list4 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_hkid_list4;
                SELECT
                    STRPOS(par_hkid_list4, ',')
                    INTO var_pos;
            END LOOP;

            IF par_hkid_list4 IS NOT NULL THEN
                BEGIN
                    IF OCTET_LENGTH(LTRIM(RTRIM(par_hkid_list4))) = 8 THEN
                        SELECT
                            CONCAT(' ', par_hkid_list4)
                            INTO par_hkid_list4;
                    END IF;
                    INSERT INTO t$temp_pk_hkid_list (hkid)
                    VALUES (par_hkid_list4);
                END;
            END IF;
        END;
    END IF;

    IF par_hkid_list5 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_hkid_list5, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_hkid_list5, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        IF OCTET_LENGTH(LTRIM(RTRIM(var_piece))) = 8 THEN
                            SELECT
                                CONCAT(' ', var_piece)
                                INTO var_piece;
                        END IF;
                        INSERT INTO t$temp_pk_hkid_list (hkid)
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_hkid_list5 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_hkid_list5;
                SELECT
                    STRPOS(par_hkid_list5, ',')
                    INTO var_pos;
            END LOOP;

            IF par_hkid_list5 IS NOT NULL THEN
                BEGIN
                    IF OCTET_LENGTH(LTRIM(RTRIM(par_hkid_list5))) = 8 THEN
                        SELECT
                            CONCAT(' ', par_hkid_list5)
                            INTO par_hkid_list5;
                    END IF;
                    INSERT INTO t$temp_pk_hkid_list (hkid)
                    VALUES (par_hkid_list5);
                END;
            END IF;
        END;
    END IF;

    IF par_hkid_list6 IS NOT NULL THEN
        BEGIN
            SELECT
                STRPOS(par_hkid_list6, ',')
                INTO var_pos;

            WHILE var_pos <> 0 LOOP
                SELECT
                    LEFT(par_hkid_list6, var_pos - 1)
                    INTO var_piece;

                IF var_piece IS NOT NULL THEN
                    BEGIN
                        IF OCTET_LENGTH(LTRIM(RTRIM(var_piece))) = 8 THEN
                            SELECT
                                CONCAT(' ', var_piece)
                                INTO var_piece;
                        END IF;
                        INSERT INTO t$temp_pk_hkid_list (hkid)
                        VALUES (var_piece);
                    END;
                END IF;
                SELECT
                    OVERLAY(par_hkid_list6 PLACING NULL FROM 1 FOR var_pos)
                    INTO par_hkid_list6;
                SELECT
                    STRPOS(par_hkid_list6, ',')
                    INTO var_pos;
            END LOOP;

            IF par_hkid_list6 IS NOT NULL THEN
                BEGIN
                    IF OCTET_LENGTH(LTRIM(RTRIM(par_hkid_list6))) = 8 THEN
                        SELECT
                            CONCAT(' ', par_hkid_list6)
                            INTO par_hkid_list6;
                    END IF;
                    INSERT INTO t$temp_pk_hkid_list (hkid)
                    VALUES (par_hkid_list6);
                END;
            END IF;
        END;
    END IF;

    IF par_hkid_list1 IS NOT NULL THEN
        BEGIN
            UPDATE t$temp_pk_hkid_list
            SET patient_key = ''
                WHERE hkid IS NOT NULL;
            UPDATE t$temp_pk_hkid_list AS tmp
            SET patient_key = p.patient_key
            FROM patient AS p
                WHERE tmp.hkid = p.hkid;
        END;
    END IF;
    /* --HKID list End */
    INSERT INTO t$temp_patient_key_list (patient_key)
    SELECT DISTINCT
        patient_key
        FROM t$temp_pk_hkid_list
        WHERE patient_key IS NOT NULL;
    SELECT
        COUNT(1)
        INTO var_in_record_count
        FROM t$temp_patient_key_list;
    INSERT INTO t$temp_found_patient_key_list (patient_key)
    SELECT
        p.patient_key
        FROM patient AS p, t$temp_patient_key_list AS l
        WHERE p.patient_key = l.patient_key;
    SELECT
        COUNT(1)
        INTO var_out_record_count
        FROM t$temp_found_patient_key_list;
    /* --Relax validation rule below as requested by project team */
    IF par_project = 'PMS' THEN
        BEGIN
            SELECT
                - 1
                INTO var_in_record_count;
            SELECT
                - 1
                INTO var_out_record_count;
        END;
    END IF;

    IF var_in_record_count <> var_out_record_count THEN
        BEGIN
            RAISE EXCEPTION 'Input and output total no. of HKIDs do not match.' USING ERRCODE := '99999';
        END;
    ELSE
        BEGIN
            UPDATE t$temp_patient_key_list AS l
            SET record_id =
            CASE SUBSTRING(p.building, 1, 6)
                WHEN 'HACODE' THEN CAST (SUBSTRING(p.building, 8, 20) AS INTEGER)
                ELSE 0
            END
            FROM hkpmi_patient_address_list AS p
                WHERE l.patient_key = p.patient_key AND p.address_type = 'C';
            OPEN p_refcur FOR
            SELECT
                RTRIM(l.patient_key) AS patient_key, p.room, p.floor, p.block, l.record_id, e.eh_name, e.eh_chinese_name,
                CASE l.record_id
                    WHEN 0 THEN p.building
                    ELSE a.bldg_eng
                END AS bldg_eng, a.bldg_chi, a.estate_eng, a.estate_chi, a.house_no, a.street_eng, a.street_chi, p.district_code, d.district_name, d.district_chi, da.area_name, da.area_chi
                FROM hkpmi_patient_address_list AS p
                LEFT OUTER JOIN district AS d
                    ON (p.district_code = d.district_code)
                LEFT OUTER JOIN district_area AS da
                    ON (d.district_area = da.area_code), t$temp_patient_key_list AS l
                LEFT OUTER JOIN elderly_home_table AS e
                    ON (l.record_id = e.eh_address_id)
                LEFT OUTER JOIN address_detail AS a
                    ON (l.record_id = a.record_id)
                WHERE l.patient_key = p.patient_key AND p.address_type = 'C'
                ORDER BY patient_key NULLS FIRST;
            return next p_refcur;
            RETURN;
        END;
    END IF;
    DROP TABLE t$temp_pk_hkid_list;
    DROP TABLE t$temp_patient_key_list;
    /*
    
    DROP TABLE IF EXISTS t$temp_patient_key_list;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$temp_pk_hkid_list;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$temp_found_patient_key_list;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;

ALTER FUNCTION "pass_hkpmi_patients_address" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
