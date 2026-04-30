-- DROP FUNCTION hpi.pass_get_patients_nok(varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.pass_get_patients_nok(par_patient_key_list1 character varying DEFAULT NULL::character varying, par_patient_key_list2 character varying DEFAULT NULL::character varying, par_patient_key_list3 character varying DEFAULT NULL::character varying, par_patient_key_list4 character varying DEFAULT NULL::character varying, par_patient_key_list5 character varying DEFAULT NULL::character varying, par_patient_key_list6 character varying DEFAULT NULL::character varying, par_hkid_list1 character varying DEFAULT NULL::character varying, par_hkid_list2 character varying DEFAULT NULL::character varying, par_hkid_list3 character varying DEFAULT NULL::character varying, par_hkid_list4 character varying DEFAULT NULL::character varying, par_hkid_list5 character varying DEFAULT NULL::character varying, par_hkid_list6 character varying DEFAULT NULL::character varying, par_project character varying DEFAULT NULL::character varying, par_getmorenok character varying DEFAULT 'N'::character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_piece VARCHAR(255);
    var_pos INTEGER;
    var_in_record_count INTEGER;
    var_out_record_count INTEGER;
    var_patient_key VARCHAR(16);
    var_hkid VARCHAR(24);
    var_nf_pk_list VARCHAR(255);
    var_nf_hkid_list VARCHAR(255);
	p_refcur refcursor;
BEGIN
    
    DROP TABLE IF EXISTS t$temp_patient_key_list; 
    DROP TABLE IF EXISTS t$temp_pk_hkid_list;
    DROP TABLE IF EXISTS t$temp_found_patient_key_list;
    DROP TABLE IF EXISTS t$temp_nok_list;

	
	CREATE TEMPORARY TABLE t$temp_patient_key_list
    (patient_key VARCHAR(16));
    CREATE TEMPORARY TABLE t$temp_pk_hkid_list
    (patient_key VARCHAR(16) NULL,
        hkid VARCHAR(24) NULL);
    CREATE TEMPORARY TABLE t$temp_found_patient_key_list
    (patient_key VARCHAR(16));

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
            SET patient_key = ' '
                WHERE hkid IS NOT NULL;
            UPDATE t$temp_pk_hkid_list AS tmp
            SET patient_key = p.patient_key
            FROM cpi_patient AS p
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
        FROM cpi_patient AS p, t$temp_patient_key_list AS l
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
            /*
            if @project = 'PMS'
                      begin
            
            		declare not_found_csr cursor for
            			select l.patient_key, l.hkid
            			from #temp_pk_hkid_list l
            			where not exists
            			(select patient_key from
            			#temp_found_patient_key_list f
            			where l.patient_key = f.patient_key
            			)
                            for read only
            		open not_found_csr
            		fetch not_found_csr into @patient_key, @hkid
                  		while @@sqlstatus = 0
                  		begin
                                  select @nf_pk_list = @nf_pk_list + ltrim(rtrim(@patient_key)) + ';'
                                  select @nf_hkid_list= @nf_hkid_list + ltrim(rtrim(@hkid)) + ';'
                    	      fetch not_found_csr into @patient_key, @hkid
                  		end
            		close not_found_csr
            		deallocate cursor not_found_csr
            
            		select @nf_pk_list = 'Patient key(s) NOT FOUND: ' + @nf_pk_list
            		select @nf_hkid_list = 'HKID(s) NOT FOUND: ' + @nf_hkid_list
            
                            if @hkid_list1 is not null
                            begin
            		     raiserror 99999 Input and output total no. of HKIDs do not match. %1!, @nf_hkid_list
                            end
                            else
                            begin
                                 raiserror 99999 Input and output total no. of patient keys do not match. %1!, @nf_pk_list
                            end
                      end
                      else
                      begin
                        raiserror 99999 Input and output total no. of HKIDs do not match.
                      end
            */
            RAISE EXCEPTION 'Input and output total no. of HKIDs do not match.' USING ERRCODE := '99999';
        END;
    ELSE
        BEGIN
            CREATE TEMPORARY TABLE t$temp_nok_list
            (patient_key VARCHAR(8),
                nok_record_id INTEGER,
                priority INTEGER);
            INSERT INTO t$temp_nok_list (patient_key, nok_record_id, priority)
            SELECT
                l.patient_key,
                CASE SUBSTRING(n.building, 1, 6)
                    WHEN 'HACODE' THEN CAST (SUBSTRING(n.building, 8, 20) AS INTEGER)
                    ELSE 0
                END, n.priority
                FROM t$temp_patient_key_list AS l, cpi_nok AS n
                WHERE l.patient_key = n.patient_key;
            /* --nok */
            OPEN p_refcur FOR
            SELECT
                RTRIM(n.patient_key) AS patient_key,
                n.priority AS nok_priority,
                n.major_nok AS nok_major_nok,
                RTRIM(n.hkid) AS nok_hkid,
                n.relationship AS nok_relationship,
                nr.description AS nok_description,
                RTRIM(n.nok_name) AS nok_name,
                n.phone1 AS nok_home_phone,
                n.phone2 AS nok_office_phone,
                n.address_indicator AS nok_office_phone_ext,
                n.mopbile_phone AS nok_other_phone,
                n.sms_language AS nok_other_phone_ext,
                n.room AS nok_room,
                n.floor AS nok_floor,
                n.block AS nok_block,
                l.nok_record_id,
                e.eh_name AS nok_eng_eh,
                e.eh_chinese_name AS nok_chi_eh,
                CASE l.nok_record_id
                    WHEN 0 THEN n.building
                    ELSE a.bldg_eng
                END AS nok_eng_building, a.bldg_chi AS nok_chi_building, a.estate_eng AS nok_eng_estate, a.estate_chi AS nok_chi_estate, a.house_no AS nok_street_no, a.street_eng AS nok_eng_street, a.street_chi AS nok_chi_street, n.district AS nok_district_code, d.district_name AS nok_district_eng, d.district_chi AS nok_district_chi, da.area_name AS nok_area_eng, da.area_chi AS nok_area_chi
                FROM t$temp_nok_list AS l
                LEFT OUTER JOIN elderly_home_table AS e
                    ON (l.nok_record_id = e.eh_address_id)
                LEFT OUTER JOIN address_detail AS a
                    ON (l.nok_record_id = a.record_id), cpi_nok AS n
                LEFT OUTER JOIN nok_relation AS nr
                    ON (n.relationship = nr.nok_relation_code)
                LEFT OUTER JOIN district AS d
                    ON (n.district = d.district_code)
                LEFT OUTER JOIN district_area AS da
                    ON (d.district_area = da.area_code)
                WHERE l.patient_key = n.patient_key AND l.priority = n.priority AND (n.major_nok = 'Y' OR par_getMoreNOK = 'Y')
                ORDER BY l.patient_key NULLS FIRST, n.priority NULLS FIRST;
            DROP TABLE t$temp_nok_list;
        END;
    END IF;

END;
$function$
;
;ALTER FUNCTION "pass_get_patients_nok" OWNER TO "HPI_SCHEMA_OWNER_ROLE";