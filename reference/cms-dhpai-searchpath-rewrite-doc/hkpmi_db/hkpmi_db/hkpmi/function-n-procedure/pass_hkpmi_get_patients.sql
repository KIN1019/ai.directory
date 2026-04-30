-- DROP FUNCTION hkpmi.pass_hkpmi_get_patients(varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi.pass_hkpmi_get_patients(par_patient_key_list1 character varying DEFAULT NULL::character varying, par_patient_key_list2 character varying DEFAULT NULL::character varying, par_patient_key_list3 character varying DEFAULT NULL::character varying, par_patient_key_list4 character varying DEFAULT NULL::character varying, par_patient_key_list5 character varying DEFAULT NULL::character varying, par_patient_key_list6 character varying DEFAULT NULL::character varying, par_hkid_list1 character varying DEFAULT NULL::character varying, par_hkid_list2 character varying DEFAULT NULL::character varying, par_hkid_list3 character varying DEFAULT NULL::character varying, par_hkid_list4 character varying DEFAULT NULL::character varying, par_hkid_list5 character varying DEFAULT NULL::character varying, par_hkid_list6 character varying DEFAULT NULL::character varying, par_project character varying DEFAULT NULL::character varying, par_forcereturn character varying DEFAULT 'N'::character varying)
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
    (patient_key VARCHAR(8));
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

    IF var_in_record_count <> var_out_record_count AND par_forceReturn <> 'Y' THEN
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
            /*
            [9996 - Severity CRITICAL - Transformer error occurred in fromClause. Please submit report to developers.]
            select rtrim(p.patient_key) patient_key, rtrim(p.hkid) hkid, rtrim(patient_name) patient_name,
            		cccode1, cccode2, cccode3, cccode4, cccode5, cccode6,
            		sex, convert(VARCHAR(10), p.dob, 105) as dob, exact_dob_flag,
            		death_indicator, convert(VARCHAR(10), p.death_date, 105) as death_date,
            		c1.unicode_int unicode_int1,
            		c2.unicode_int unicode_int2,
            		c3.unicode_int unicode_int3,
            		c4.unicode_int unicode_int4,
            		c5.unicode_int unicode_int5,
            		c6.unicode_int unicode_int6,
            		p.phone1,
            		p.phone2,
            		p.address_indicator,
            		p.mobile_phone,
            		p.sms_language
            		from patient p, #temp_patient_key_list l,
            		ccc_big5 c1, ccc_big5 c2, ccc_big5 c3,
            		ccc_big5 c4, ccc_big5 c5, ccc_big5 c6
            		where p.patient_key = l.patient_key
            		and substring(p.cccode1,1,4) *= c1.ccc_head
            		and substring(p.cccode1,5,1) *= c1.ccc_tail

            		and substring(p.cccode2,1,4) *= c2.ccc_head
            		and substring(p.cccode2,5,1) *= c2.ccc_tail

            		and substring(p.cccode3,1,4) *= c3.ccc_head
            		and substring(p.cccode3,5,1) *= c3.ccc_tail

            		and substring(p.cccode4,1,4) *= c4.ccc_head
            		and substring(p.cccode4,5,1) *= c4.ccc_tail

            		and substring(p.cccode5,1,4) *= c5.ccc_head
            		and substring(p.cccode5,5,1) *= c5.ccc_tail

            		and substring(p.cccode6,1,4) *= c6.ccc_head
            		and substring(p.cccode6,5,1) *= c6.ccc_tail
            		order by p.patient_key
            */
            open p_refcur for
            select rtrim(p.patient_key) patient_key, rtrim(p.hkid) hkid, rtrim(patient_name) patient_name,
            		cccode1, cccode2, cccode3, cccode4, cccode5, cccode6,
            		sex, to_char( p.dob,'DD-MM-YYYY') as dob, exact_dob_flag,
            		death_indicator, to_char(p.death_date,'DD-MM-YYYY') as death_date,
            		c1.unicode_int unicode_int1,
            		c2.unicode_int unicode_int2,
            		c3.unicode_int unicode_int3,
            		c4.unicode_int unicode_int4,
            		c5.unicode_int unicode_int5,
            		c6.unicode_int unicode_int6,
            		p.phone1,
            		p.phone2,
            		p.address_indicator,
            		p.mobile_phone,
            		p.sms_language
            from patient p, t$temp_patient_key_list l
            left join ccc_unicode c1 on substring(p.cccode1,1,4) = c1.ccc_head and substring(p.cccode1,5,1) = c1.ccc_tail
            left join ccc_unicode c2 on substring(p.cccode2,1,4) = c2.ccc_head and substring(p.cccode2,5,1) = c2.ccc_tail
            left join ccc_unicode c3 on substring(p.cccode3,1,4) = c3.ccc_head and substring(p.cccode3,5,1) = c3.ccc_tail
            left join ccc_unicode c4 on substring(p.cccode4,1,4) = c4.ccc_head and substring(p.cccode4,5,1) = c4.ccc_tail
            left join ccc_unicode c5 on substring(p.cccode5,1,4) = c5.ccc_head and substring(p.cccode5,5,1) = c5.ccc_tail
            left join ccc_unicode c6 on substring(p.cccode6,1,4) = c6.ccc_head and substring(p.cccode6,5,1) = c6.ccc_tail
            where p.patient_key = l.patient_key
            order by p.patient_key;
            return next p_refcur;
            RETURN;

            BEGIN
            END;
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

ALTER FUNCTION "pass_hkpmi_get_patients" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
