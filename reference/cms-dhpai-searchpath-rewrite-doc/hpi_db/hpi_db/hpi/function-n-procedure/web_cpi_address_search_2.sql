-- DROP FUNCTION hpi.web_cpi_address_search_2(varchar, varchar, varchar, varchar, varchar, int4);

CREATE OR REPLACE FUNCTION web_cpi_address_search_2(par_region character varying, par_street_in character varying, par_build_land_in character varying, par_location_in character varying, par_location_all character varying, par_num_of_rows integer)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_v_statement VARCHAR(512);
    var_long_key VARCHAR(25);
    var_short_key VARCHAR(255);
    var_soundex_key VARCHAR(8);
    var_org_location_all VARCHAR(255);
    var_org_build_land_in VARCHAR(255);
    var_temp_location_all VARCHAR(255);
    var_district_name VARCHAR(15);
    var_pos1 INTEGER;
    var_pos2 INTEGER;
    var_temp_address_type VARCHAR(16);
    pas_return_code INTEGER;
    /* cpi_address_cut_type$refcur_1 refcursor; */
    /* cpi_address_cut_head$refcur_1 refcursor; */
    p_refcursor refcursor;
BEGIN
    <<final_result>>
    BEGIN
        <<return_result>>
        BEGIN
            /* Added by Ranger 2012-10-31 limit the rowcount */
            IF par_num_of_rows IS NULL THEN
                SELECT
                    300
                    INTO par_num_of_rows;
            END IF;
            DROP TABLE IF EXISTS t$temp_all;
            DROP TABLE IF EXISTS t$temp_final;
            DROP TABLE IF EXISTS t$temp_building;
            DROP TABLE IF EXISTS t$temp_location;
            DROP TABLE IF EXISTS t$temp_street;
            DROP TABLE IF EXISTS t$temp_result;
            CREATE TEMPORARY TABLE t$temp_all
            (record_id INTEGER,
                record_type VARCHAR(2),
                search_type INTEGER);
            CREATE TEMPORARY TABLE t$temp_final
            (record_id INTEGER,
                search_type INTEGER);
            CREATE TEMPORARY TABLE t$temp_building
            (record_id INTEGER,
                record_type VARCHAR(2),
                search_type INTEGER);
            CREATE TEMPORARY TABLE t$temp_location
            (record_id INTEGER,
                record_type VARCHAR(2),
                search_type INTEGER);
            CREATE TEMPORARY TABLE t$temp_street
            (record_id INTEGER,
                record_type VARCHAR(2),
                search_type INTEGER);
            CREATE TEMPORARY TABLE t$temp_result
            (record_id INTEGER,
                bldg_chi VARCHAR(100) NULL,
                bldg_eng VARCHAR(200) NULL,
                estate_chi VARCHAR(80) NULL,
                estate_eng VARCHAR(100) NULL,
                house_no VARCHAR(10) NULL,
                street_chi VARCHAR(50) NULL,
                street_eng VARCHAR(100) NULL,
                eh_chinese_name VARCHAR(40) NULL,
                area_chi VARCHAR(100) NULL,
                district_chi VARCHAR(60) NULL,
                district_code VARCHAR(10),
                district_name VARCHAR(30),
                search_type INTEGER);

            IF par_street_in IS NULL AND par_build_land_in IS NULL AND par_location_in IS NULL AND par_location_all IS NULL THEN
                EXIT final_result;
            END IF;
            SELECT
                UPPER(LTRIM(RTRIM(par_street_in)))
                INTO par_street_in;
            SELECT
                UPPER(LTRIM(RTRIM(par_build_land_in)))
                INTO par_build_land_in;
            SELECT
                UPPER(LTRIM(RTRIM(par_location_in)))
                INTO par_location_in;
            SELECT
                UPPER(LTRIM(RTRIM(par_location_all)))
                INTO par_location_all;

            IF CHAR_LENGTH(par_location_all) > 5 AND (SUBSTRING(par_location_all, 1, 5) = 'BLOCK' OR SUBSTRING(par_location_all, 1, 5) = 'TOWER' OR SUBSTRING(par_location_all, 1, 5) = 'HOUSE') THEN
                BEGIN
                    
                    SELECT
                        SUBSTRING(par_location_all, 7, CHAR_LENGTH(par_location_all) - 6)
                        INTO var_temp_location_all;

                    WHILE STRPOS(RTRIM(var_temp_location_all), ',') != 0 LOOP
                        SELECT
                            OVERLAY(var_temp_location_all PLACING REPEAT(' ', 1) FROM STRPOS(var_temp_location_all, ',') FOR 1)
                            INTO var_temp_location_all;
                    END LOOP;
                    SELECT
                        STRPOS(var_temp_location_all, ' ')
                        INTO var_pos2;

                    IF var_pos2 > 1 THEN
                        SELECT
                            SUBSTRING(var_temp_location_all, 1, var_pos2 - 1)
                            INTO var_org_location_all;
                    ELSE
                        SELECT
                            var_temp_location_all
                            INTO var_org_location_all;
                    END IF;
                END;
            ELSE
                BEGIN
                   
                    IF SUBSTRING(par_location_all, 1, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9') OR SUBSTRING(par_location_all, 2, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9') THEN
                        BEGIN
                            SELECT
                                STRPOS(par_location_all, ',')
                                INTO var_pos1;
                            SELECT
                                STRPOS(par_location_all, ' ')
                                INTO var_pos2;

                            IF var_pos1 > 1 AND var_pos2 > 1 THEN
                                IF var_pos1 > var_pos2 THEN
                                    SELECT
                                        SUBSTRING(par_location_all, 1, var_pos2 - 1)
                                        INTO var_org_location_all;
                                ELSE
                                    SELECT
                                        SUBSTRING(par_location_all, 1, var_pos1 - 1)
                                        INTO var_org_location_all;
                                END IF;
                            ELSE
                                SELECT
                                    par_location_all
                                    INTO var_org_location_all;
                            END IF;
                        END;
                    ELSE
                        SELECT
                            par_location_all
                            INTO var_org_location_all;
                    END IF;
                END;
            END IF;
            /* print  @org_location_all */
            IF SUBSTRING(par_build_land_in, 1, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9') OR SUBSTRING(par_build_land_in, 2, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9') OR par_build_land_in LIKE 'BLOCK%' OR par_build_land_in LIKE 'BLK%' OR par_build_land_in LIKE 'HOUSE%' OR par_build_land_in LIKE 'TOWER%' OR par_build_land_in LIKE 'NO%' THEN
                BEGIN
                    IF par_build_land_in LIKE 'BLK%' THEN
                        SELECT
                            CONCAT('BLOCK', SUBSTRING(par_build_land_in, 4, CHAR_LENGTH(par_build_land_in)))
                            INTO var_org_build_land_in;
                    ELSE
                        SELECT
                            par_build_land_in
                            INTO var_org_build_land_in;
                    END IF;
                    SELECT
                        NULL
                        INTO par_build_land_in;
                END;
            END IF;
            /* print @org_location_all */
            SELECT
                NULL
                INTO var_district_name;
            SELECT
                district_name
                INTO var_district_name
                FROM district
                WHERE RTRIM(var_org_location_all) LIKE CONCAT('%', RTRIM(district_name));
            /* print @district_name */
            IF var_district_name IS NOT NULL THEN
                IF CHAR_LENGTH(RTRIM(var_org_location_all)) != CHAR_LENGTH(RTRIM(var_district_name)) THEN
                    /*
                    goto final_result
                    else
                    */
                    SELECT
                        SUBSTRING(var_org_location_all, 1, CHAR_LENGTH(RTRIM(var_org_location_all)) - CHAR_LENGTH(RTRIM(var_district_name)))
                        INTO par_location_all;
                END IF;
            END IF;

           

            IF par_region = 'AL' THEN
                SELECT
                    '%'
                    INTO par_region;
            END IF;
            SELECT SUBSTRING(par_region, 1, 2)
                INTO par_region;
            SELECT
                ''
                INTO var_long_key;
            SELECT
                ''
                INTO var_short_key;
            SELECT
                ''
                INTO var_soundex_key;
            CALL cpi_address_phonetic_word(pas_return_code, par_build_land_in, par_build_land_in);
            CALL cpi_address_phonetic_word(pas_return_code, par_street_in, par_street_in);
            CALL cpi_address_phonetic_word(pas_return_code, par_location_in, par_location_in);
            CALL cpi_address_phonetic_word(pas_return_code, par_location_all, par_location_all);
            /* CALL cpi_address_cut_type(par_build_land_in, par_build_land_in, cpi_address_cut_type$refcur_1); */
            /* CLOSE cpi_address_cut_type$refcur_1; */
            CALL cpi_address_cut_type(pas_return_code, par_build_land_in, par_build_land_in);
            /* CALL cpi_address_cut_type(par_street_in, par_street_in, cpi_address_cut_type$refcur_1); */
            /* CLOSE cpi_address_cut_type$refcur_1; */
            CALL cpi_address_cut_type(pas_return_code, par_street_in, par_street_in);
            /* CALL cpi_address_cut_type(par_location_in, par_location_in, cpi_address_cut_type$refcur_1); */
            /* CLOSE cpi_address_cut_type$refcur_1; */
            CALL cpi_address_cut_type(pas_return_code, par_location_in, par_location_in);
            /*
            exec cpi_address_cut_type @location_all, @location_all output
            exec cpi_address_cut_head @build_land_in, @build_land_in output
            exec cpi_address_cut_head @street_in, @street_in output
            exec cpi_address_cut_head @location_in, @location_in output
            */
            /* CALL cpi_address_cut_head(par_location_all, par_location_all, cpi_address_cut_head$refcur_1); */
            /* CLOSE cpi_address_cut_head$refcur_1; */
            CALL cpi_address_cut_head(pas_return_code, par_location_all, par_location_all);
            /*
            print @build_land_in
            select '*'+ @street_in+'*'
            select '*'+@location_in+'*'
            print @build_land_in
            print @location_all
            print @street_in
            */
            /* --------------- */
            /* For all */
            /* ---------------- */
            IF NOT (par_location_all IS NULL) THEN
                BEGIN
                    /* --Use long key */
                 
                    CALL cpi_address_build_long_key(pas_return_code, par_location_all, var_long_key);
                   
                    /* --print @long_key */
                    /* For OAH */
                    IF var_long_key LIKE 'OAH%' THEN
                        IF var_long_key = 'OAH' THEN
                            SELECT
                                CONCAT(RTRIM(var_long_key), '%')
                                INTO var_long_key;
                        ELSE
                            SELECT
                                RTRIM(var_long_key)
                                INTO var_long_key;
                        END IF;
                    ELSE
                        SELECT
                            CONCAT(RTRIM(var_long_key), '%')
                            INTO var_long_key;
                    END IF;
                   
                    INSERT INTO t$temp_all
                    SELECT DISTINCT
                        record_id, record_type, 9
                        FROM address_key_new
                        WHERE long_key LIKE var_long_key AND record_type IN ('L', 'V') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_all);
                    INSERT INTO t$temp_all
                    SELECT DISTINCT
                        record_id, record_type, 8
                        FROM address_key_new
                        WHERE long_key LIKE var_long_key AND record_type = 'B' AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_all);
                    INSERT INTO t$temp_all
                    SELECT DISTINCT
                        record_id, record_type, 7
                        FROM address_key_new
                        WHERE long_key LIKE var_long_key AND record_type IN ('S', 'I') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_all);
                    INSERT INTO t$temp_all
                    SELECT DISTINCT
                        record_id, record_type, 7
                        FROM address_key_new
                        WHERE long_key LIKE var_long_key AND record_type IN ('U', 'O', 'T', 'A', 'G') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_all);
                    /*
                    --	if (@@rowcount > 0)
                    --		goto return_result
                    --	else
                    --	begin
                    */
                    /* Use short key */
                    CALL cpi_address_build_short_key(pas_return_code, par_location_all, var_short_key);
                    /* --print @short_key */
                     
                    SELECT
                        CONCAT(LTRIM(RTRIM(var_short_key)), '%')
                        INTO var_short_key;
                    INSERT INTO t$temp_all
                    SELECT DISTINCT
                        record_id, record_type, 6
                        FROM address_key_new
                        WHERE short_key LIKE var_short_key AND record_type IN ('L', 'V') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_all);
                    INSERT INTO t$temp_all
                    SELECT DISTINCT
                        record_id, record_type, 5
                        FROM address_key_new
                        WHERE short_key LIKE var_short_key AND record_type = 'B' AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_all);
                    INSERT INTO t$temp_all
                    SELECT DISTINCT
                        record_id, record_type, 4
                        FROM address_key_new
                        WHERE short_key LIKE var_short_key AND record_type IN ('S', 'I') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_all);
                    INSERT INTO t$temp_all
                    SELECT DISTINCT
                        record_id, record_type, 4
                        FROM address_key_new
                        WHERE short_key LIKE var_short_key AND record_type IN ('U', 'O', 'T', 'A', 'G') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_all);
                    /*
                    --		if (@@rowcount > 0)
                    --			goto return_result
                    --		else
                    --		begin
                    */
                    /* Use soundex key */
                   
                    CALL cpi_address_build_soundex_key(pas_return_code, par_location_all, var_soundex_key);
                    /* --print @soundex_key */
                    INSERT INTO t$temp_all
                    SELECT DISTINCT
                        record_id, record_type, 3
                        FROM address_key_new
                        WHERE soundex_key = var_soundex_key AND record_type IN ('L', 'V') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_all);
                    INSERT INTO t$temp_all
                    SELECT DISTINCT
                        record_id, record_type, 2
                        FROM address_key_new
                        WHERE soundex_key = var_soundex_key AND record_type = 'B' AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_all);
                    INSERT INTO t$temp_all
                    SELECT DISTINCT
                        record_id, record_type, 1
                        FROM address_key_new
                        WHERE soundex_key = var_soundex_key AND record_type IN ('S', 'I') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_all);
                    INSERT INTO t$temp_all
                    SELECT DISTINCT
                        record_id, record_type, 1
                        FROM address_key_new
                        WHERE soundex_key = var_soundex_key AND record_type IN ('U', 'O', 'T', 'A', 'G') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_all);
                    EXIT return_result;
                    /*
                    --		end
                    --	end
                    */
                END;
            END IF;
            /*
            -----------------------------------------
             For location e.g estate, villa, village
            -----------------------------------------
            */
            IF NOT (par_location_in IS NULL) THEN
                BEGIN
                    /* Use long key */
                    CALL cpi_address_build_long_key(pas_return_code, par_location_in, var_long_key);
                    SELECT
                        CONCAT(RTRIM(var_long_key), '%')
                        INTO var_long_key;
                    INSERT INTO t$temp_location
                    SELECT DISTINCT
                        record_id, record_type, 48
                        FROM address_key_new
                        WHERE long_key LIKE var_long_key AND record_type IN ('L', 'V') AND region LIKE par_region;
                    INSERT INTO t$temp_location
                    SELECT DISTINCT
                        record_id, record_type, 16
                        FROM address_key_new
                        WHERE long_key LIKE var_long_key AND record_type IN ('O', 'A') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_location);
                    /*
                    --	if (@@rowcount > 0)
                    --		goto search_street
                    --	else
                    --	begin
                    */
                    /* Use short key */
                    CALL cpi_address_build_short_key(pas_return_code, par_location_in, var_short_key);
                    SELECT
                        CONCAT(LTRIM(RTRIM(var_short_key)), '%')
                        INTO var_short_key;
                    INSERT INTO t$temp_location
                    SELECT DISTINCT
                        record_id, record_type, 32
                        FROM address_key_new
                        WHERE short_key LIKE var_short_key AND record_type IN ('L', 'V') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_location);
                    INSERT INTO t$temp_location
                    SELECT DISTINCT
                        record_id, record_type, 15
                        FROM address_key_new
                        WHERE short_key LIKE var_short_key AND record_type IN ('O', 'A') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_location);
                    /*
                    --		if (@@rowcount > 0)
                    --			goto search_street
                    --		else
                    --		begin
                    */
                    /* Use soundex key */
                    CALL cpi_address_build_soundex_key(pas_return_code, par_location_in, var_soundex_key);
                    INSERT INTO t$temp_location
                    SELECT DISTINCT
                        record_id, record_type, 16
                        FROM address_key_new
                        WHERE soundex_key = var_soundex_key AND record_type IN ('L', 'V') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_location);
                    INSERT INTO t$temp_location
                    SELECT DISTINCT
                        record_id, record_type, 14
                        FROM address_key_new
                        WHERE soundex_key = var_soundex_key AND record_type IN ('O', 'A') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_location);
                    /*
                    --			goto search_building
                    --		end
                    --	end
                    */
                END;
            END IF;
            /*
            -----------------------------------------
             For building
            -----------------------------------------
            */
            IF par_build_land_in IS NOT NULL THEN
                BEGIN
                    /* Use long key */
                    CALL cpi_address_build_long_key(pas_return_code, par_build_land_in, var_long_key);
                    
                    SELECT
                        CONCAT(RTRIM(var_long_key), '%')
                        INTO var_long_key;
                    /*
                    if (@location_in is null)
                    begin
                    */
                    INSERT INTO t$temp_building
                    SELECT DISTINCT
                        record_id, record_type, 12
                        FROM address_key_new
                        WHERE long_key LIKE var_long_key AND record_type = 'B' AND region LIKE par_region;
                    INSERT INTO t$temp_building
                    SELECT DISTINCT
                        record_id, record_type, 4
                        FROM address_key_new
                        WHERE long_key LIKE var_long_key AND record_type = 'U' AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_building);
                    /*
                    end
                    else
                    begin
                    	insert into #temp_building
                    	select distinct record_id, record_type, 12 from address_key_new
                    												where long_key like @long_key and record_type = 'B'
                    														and region like @region
                    														and record_id in (select record_id from #temp_location)
                    	insert into #temp_building
                    	select distinct record_id, record_type, 4 from address_key_new
                    												where long_key like @long_key and record_type = 'U'
                    													and region like @region
                    													and record_id in (select record_id from #temp_location)
                    													and record_id not in (select record_id from #temp_building)
                    end
                    */
                    /*
                    --	if (@@rowcount > 0)
                    --		goto search_location
                    --	else
                    --	begin
                    */
                    /* Use short key */
                    CALL cpi_address_build_short_key(pas_return_code, par_build_land_in, var_short_key);
                    SELECT
                        CONCAT(LTRIM(RTRIM(var_short_key)), '%')
                        INTO var_short_key;

                    IF par_location_in IS NULL THEN
                        BEGIN
                            INSERT INTO t$temp_building
                            SELECT DISTINCT
                                record_id, record_type, 8
                                FROM address_key_new
                                WHERE short_key LIKE var_short_key AND record_type = 'B' AND region LIKE par_region AND record_id NOT IN (SELECT
                                    record_id
                                    FROM t$temp_building);
                            INSERT INTO t$temp_building
                            SELECT DISTINCT
                                record_id, record_type, 3
                                FROM address_key_new
                                WHERE short_key LIKE var_short_key AND record_type = 'U' AND region LIKE par_region AND record_id NOT IN (SELECT
                                    record_id
                                    FROM t$temp_building);
                        END;
                    ELSE
                        BEGIN
                            INSERT INTO t$temp_building
                            SELECT DISTINCT
                                record_id, record_type, 8
                                FROM address_key_new
                                WHERE short_key LIKE var_short_key AND record_type = 'B' AND region LIKE par_region AND record_id IN (SELECT
                                    record_id
                                    FROM t$temp_location) AND record_id NOT IN (SELECT
                                    record_id
                                    FROM t$temp_building);
                            INSERT INTO t$temp_building
                            SELECT DISTINCT
                                record_id, record_type, 3
                                FROM address_key_new
                                WHERE short_key LIKE var_short_key AND record_type = 'U' AND region LIKE par_region AND record_id IN (SELECT
                                    record_id
                                    FROM t$temp_location) AND record_id NOT IN (SELECT
                                    record_id
                                    FROM t$temp_building);
                        END;
                    END IF;
                    /*
                    --		if (@@rowcount > 0)
                    --			goto search_location
                    --		else
                    --		begin
                    */
                    /* Use soundex key */
                    CALL cpi_address_build_soundex_key(pas_return_code, par_build_land_in, var_soundex_key);

                    IF par_location_in IS NULL THEN
                        BEGIN
                            INSERT INTO t$temp_building
                            SELECT DISTINCT
                                record_id, record_type, 4
                                FROM address_key_new
                                WHERE soundex_key = var_soundex_key AND record_type = 'B' AND region LIKE par_region AND record_id NOT IN (SELECT
                                    record_id
                                    FROM t$temp_building);
                            INSERT INTO t$temp_building
                            SELECT DISTINCT
                                record_id, record_type, 2
                                FROM address_key_new
                                WHERE soundex_key = var_soundex_key AND record_type = 'U' AND region LIKE par_region AND record_id NOT IN (SELECT
                                    record_id
                                    FROM t$temp_building);
                        END;
                    ELSE
                        BEGIN
                            INSERT INTO t$temp_building
                            SELECT DISTINCT
                                record_id, record_type, 4
                                FROM address_key_new
                                WHERE soundex_key = var_soundex_key AND record_type = 'B' AND region LIKE par_region AND record_id IN (SELECT
                                    record_id
                                    FROM t$temp_location) AND record_id NOT IN (SELECT
                                    record_id
                                    FROM t$temp_building);
                            INSERT INTO t$temp_building
                            SELECT DISTINCT
                                record_id, record_type, 2
                                FROM address_key_new
                                WHERE soundex_key = var_soundex_key AND record_type = 'U' AND region LIKE par_region AND record_id IN (SELECT
                                    record_id
                                    FROM t$temp_location) AND record_id NOT IN (SELECT
                                    record_id
                                    FROM t$temp_building);
                        END;
                    END IF;
                    /*
                    --			goto search_street
                    --		end
                    --	end
                    */
                END;
            END IF;
            /*
            -----------------------------------------
             For street
            -----------------------------------------
            */
            IF par_street_in IS NOT NULL THEN
                BEGIN
                    /* Use long key */
                    CALL cpi_address_build_long_key(pas_return_code, par_street_in, var_long_key);
                    /* print @long_key */
                    SELECT
                        CONCAT(var_long_key, '%')
                        INTO var_long_key;
                    INSERT INTO t$temp_street
                    SELECT DISTINCT
                        record_id, record_type, 3
                        FROM address_key_new
                        WHERE long_key LIKE var_long_key AND record_type IN ('S', 'I') AND region LIKE par_region;
                    INSERT INTO t$temp_street
                    SELECT DISTINCT
                        record_id, record_type, 1
                        FROM address_key_new
                        WHERE long_key LIKE var_long_key AND record_type IN ('T', 'G') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_street);
                    /*
                    --	if (@@rowcount > 0)
                    --		goto return_result
                    --	else
                    --	begin
                    */
                    /* Use short key */
                    CALL cpi_address_build_short_key(pas_return_code, par_street_in, var_short_key);
                    SELECT
                        CONCAT(LTRIM(RTRIM(var_short_key)), '%')
                        INTO var_short_key;
                    INSERT INTO t$temp_street
                    SELECT DISTINCT
                        record_id, record_type, 2
                        FROM address_key_new
                        WHERE short_key LIKE var_short_key AND record_type IN ('S', 'I') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_street);
                    INSERT INTO t$temp_street
                    SELECT DISTINCT
                        record_id, record_type, 1
                        FROM address_key_new
                        WHERE short_key LIKE var_short_key AND record_type IN ('T', 'G') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_street);
                    /*
                    --		if (@@rowcount > 0)
                    --			goto return_result
                    --		else
                    --		begin
                    */
                    /* Use soundex key */
                    CALL cpi_address_build_soundex_key(pas_return_code, par_street_in, var_soundex_key);
                    INSERT INTO t$temp_street
                    SELECT DISTINCT
                        record_id, record_type, 1
                        FROM address_key_new
                        WHERE soundex_key = var_soundex_key AND record_type IN ('S', 'I') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_street);
                    INSERT INTO t$temp_street
                    SELECT DISTINCT
                        record_id, record_type, 1
                        FROM address_key_new
                        WHERE soundex_key = var_soundex_key AND record_type IN ('T', 'G') AND region LIKE par_region AND record_id NOT IN (SELECT
                            record_id
                            FROM t$temp_street);
                    EXIT return_result;
                    /*
                    --		end
                    --	end
                    */
                END;
            END IF;

            <<search_location>>
            BEGIN
            END;

            <<search_building>>
            BEGIN
            END;

            <<search_street>>
            BEGIN
            END;
        END;

        IF par_build_land_in IS NULL THEN
            BEGIN
                INSERT INTO t$temp_building
                SELECT
                    record_id, record_type, 0
                    FROM t$temp_location;
                INSERT INTO t$temp_building
                SELECT
                    record_id, record_type, 0
                    FROM t$temp_street;
            END;
        END IF;

        IF par_location_in IS NULL THEN
            BEGIN
                INSERT INTO t$temp_location
                SELECT
                    record_id, record_type, 0
                    FROM t$temp_building;
                INSERT INTO t$temp_location
                SELECT
                    record_id, record_type, 0
                    FROM t$temp_street;
            END;
        END IF;

        IF par_street_in IS NULL THEN
            BEGIN
                INSERT INTO t$temp_street
                SELECT
                    record_id, record_type, 0
                    FROM t$temp_location;
                INSERT INTO t$temp_street
                SELECT
                    record_id, record_type, 0
                    FROM t$temp_building;
            END;
        END IF;
        /*
        ----------------------------
        	 Get the final result
        ----------------------------
        */
        IF par_location_all IS NULL THEN
            BEGIN
                INSERT INTO t$temp_all
                SELECT
                    t$temp_building.record_id, t$temp_building.record_type, t$temp_building.search_type
                    FROM t$temp_building
                    WHERE record_type NOT IN ('V', 'I', 'A', 'G');
                /* convert village key */
                INSERT INTO t$temp_all
                SELECT
                    a.record_id, a.record_type, b.search_type
                    FROM address_key_new AS a, t$temp_building AS b
                    WHERE b.record_type IN ('V', 'I', 'A', 'G') AND a.short_key = CAST (b.record_id AS VARCHAR(14));
                /* select * from #temp_building */
                INSERT INTO t$temp_all
                SELECT
                    t$temp_location.record_id, t$temp_location.record_type, t$temp_location.search_type
                    FROM t$temp_location
                    WHERE record_type NOT IN ('V', 'I', 'A', 'G');
                /* convert village key */
                INSERT INTO t$temp_all
                SELECT
                    a.record_id, a.record_type, b.search_type
                    FROM address_key_new AS a, t$temp_location AS b
                    WHERE b.record_type IN ('V', 'I', 'A', 'G') AND a.short_key = CAST (b.record_id AS VARCHAR(14));
                /* select * from #temp_location */
                INSERT INTO t$temp_all
                SELECT
                    t$temp_street.record_id, t$temp_street.record_type, t$temp_street.search_type
                    FROM t$temp_street
                    WHERE record_type NOT IN ('V', 'I', 'A', 'G');
                /* convert village key */
                INSERT INTO t$temp_all
                SELECT
                    a.record_id, a.record_type, b.search_type
                    FROM address_key_new AS a, t$temp_street AS b
                    WHERE b.record_type IN ('V', 'I', 'A', 'G') AND a.short_key = CAST (b.record_id AS VARCHAR(14));
                /* select * from #temp_street */
                INSERT INTO t$temp_final
                SELECT DISTINCT
                    record_id, SUM(search_type)
                    FROM t$temp_all
                    GROUP BY record_id
                    HAVING COUNT(*) >= 3;
            END;
        ELSE
            BEGIN
                INSERT INTO t$temp_final
                SELECT DISTINCT
                    record_id, SUM(search_type)
                    FROM t$temp_all
                    GROUP BY record_id;
                /* Needed to replace the village key record with the address record */
                /* select count(*) from #temp_final */
                /* 20041130 add code to avoid duplicate record */
                INSERT INTO t$temp_final
                SELECT
                    a.record_id, b.search_type
                    FROM address_key_new AS a, t$temp_final AS b
                    WHERE a.record_type = 'E' AND a.short_key = CAST (b.record_id AS VARCHAR(14)) AND a.record_id NOT IN (SELECT
                        record_id
                        FROM t$temp_final);
            END;
        END IF;
        /* select count(*) from #temp_final */
        /* return result set */
        INSERT INTO t$temp_result
        SELECT
            aa.record_id, aa.bldg_chi, aa.bldg_eng, aa.estate_chi, aa.estate_eng, aa.house_no, aa.street_chi, aa.street_eng, d.eh_chinese_name, ae.area_chi, ad.district_chi, aa.district_code, ad.district_name, search_type
            FROM district AS ad, district_area AS ae, t$temp_final AS ab, address_detail AS aa
            LEFT OUTER JOIN elderly_home_table AS d
                ON (aa.record_id = d.eh_address_id)
            WHERE aa.record_id = ab.record_id AND aa.district_code = ad.district_code AND ad.district_area = ae.area_code;
        /* add mark to these address that match house no or BLOCK, TOWER and NO */
        IF (par_location_all IS NULL) THEN
            BEGIN
                IF var_org_build_land_in IS NOT NULL THEN
                    BEGIN
                        UPDATE t$temp_result AS a
                        SET search_type = search_type + 1
                        FROM address_detail AS b
                            WHERE a.record_id = b.record_id AND (b.bldg_eng IS NULL AND (RTRIM(b.house_no)) LIKE CONCAT(RTRIM(var_org_build_land_in), '%') OR b.bldg_eng IS NOT NULL AND (RTRIM(b.bldg_eng)) LIKE CONCAT('%', var_org_build_land_in));
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                /* add mark to these address with district info that matched */
                UPDATE t$temp_result
                SET search_type = search_type * 2
                    WHERE var_org_location_all LIKE CONCAT('%', district_name);
                /* add mark to these address estate match of location_all */
                SELECT
                    NULL
                    INTO var_temp_address_type;
                SELECT
                    full_name
                    INTO var_temp_address_type
                    FROM address_type
                    WHERE var_org_location_all LIKE CONCAT('%', full_name);

                IF var_temp_address_type IS NOT NULL THEN
                    UPDATE t$temp_result
                    SET search_type = search_type + 1
                        WHERE (estate_eng IS NOT NULL AND (RTRIM(estate_eng)) LIKE CONCAT('%', RTRIM(var_temp_address_type)));
                END IF;
                /* add mark to these address building match house no , block, tower or house of location_all */
                UPDATE t$temp_result AS a
                SET search_type = search_type + 1
                FROM address_detail AS b
                    WHERE a.record_id = b.record_id AND (RIGHT(RTRIM(b.bldg_eng), 1) = ')' AND RTRIM(b.bldg_eng) LIKE CONCAT('%', RTRIM(SUBSTRING(var_org_location_all, 1, 2)), ')') OR RIGHT(RTRIM(b.bldg_eng), 1) <> ')' AND b.bldg_eng IS NOT NULL AND RTRIM(b.bldg_eng) LIKE CONCAT('%', SUBSTRING(var_org_location_all, 1, 2)) OR b.bldg_eng IS NULL AND (RTRIM(b.house_no)) LIKE CONCAT(SUBSTRING(var_org_location_all, 1, 3), '%') OR b.bldg_eng IS NOT NULL AND (RTRIM(b.bldg_eng)) LIKE CONCAT('%', SUBSTRING(var_org_location_all, 1, 3)));
            END;
        END IF;
    END;
    /*
    set rowcount @num_of_rows
    	select record_id, address_eng, address_chi, district_code from #temp_result
    		order by search_type desc, district_code asc,
    					estate_eng asc, bldg_eng asc, street_eng asc, house_no asc
    set rowcount 0
    */
    /* Added by Ranger 2012-10-31 limit the rowcount */
    SELECT
        CONCAT('select record_id , bldg_chi , 
bldg_eng ,estate_chi, 
estate_eng ,house_no , 
street_chi , street_eng , 
eh_chinese_name, area_chi ,
district_chi , district_code from t$temp_result', ' order by search_type desc, district_code collate "C" asc NULLS FIRST ,', ' estate_eng collate "C" asc NULLS FIRST , bldg_eng collate "C" asc NULLS FIRST , street_eng collate "C" asc NULLS FIRST , house_no collate "C" asc NULLS FIRST limit ',
        CASE CAST (par_num_of_rows AS VARCHAR)
            WHEN '' THEN '10'
            ELSE CAST (par_num_of_rows AS VARCHAR)
        END)
        INTO var_v_statement;
      
    /*
    [3031 - Severity CRITICAL - Automatic conversion of this command is not supported. Perform a manual conversion.]
    exec (@v_statement)
    */
    OPEN p_refcursor FOR
    EXECUTE var_v_statement;
    /* For package in ASA 7.0 */
    /*
    select record_id, address_eng, address_chi,
    rtrim(b.district_name) as district_name,
    rtrim(b.district_chi) as district_chi,
    rtrim(c.area_name) as area_name,
    rtrim(c.area_chi) as area_chi
    from #temp_result a, district b, district_area c
    	where a.district_code = b.district_code
    	and b.district_area = c.area_code
    	and record_id < 5000000
    		order by search_type desc, district_name asc, address_eng asc
    */
   
    -- DROP TABLE t$temp_result;
    RETURN NEXT p_refcursor;
    /*
    DROP TABLE IF EXISTS t$temp_all;
    
    Temporary table must be removed before end of the function.
    
    DROP TABLE IF EXISTS t$temp_final;
    
    Temporary table must be removed before end of the function.
    
    DROP TABLE IF EXISTS t$temp_building;
    
    Temporary table must be removed before end of the function.
    
    DROP TABLE IF EXISTS t$temp_location;
    
    Temporary table must be removed before end of the function.
    
    DROP TABLE IF EXISTS t$temp_street;
    
    Temporary table must be removed before end of the function.
    
    DROP TABLE IF EXISTS t$temp_result;
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;


;ALTER FUNCTION "web_cpi_address_search_2" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
