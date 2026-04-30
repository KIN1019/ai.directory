-- DROP PROCEDURE hpi.hasp_get_ward_occupancy(inout int4, in varchar, in varchar, inout refcursor);

CREATE OR REPLACE FUNCTION hpi.hasp_get_ward_occupancy(IN par_no_day_bed character varying, IN par_ward_occ_group character varying DEFAULT NULL::character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_rowcount INTEGER;
    var_bed_allocation VARCHAR(255);
    p_refcur refcursor;
BEGIN
    /* create #temp_bed_table to include latest bed information */
    SELECT
        Text_value
        INTO var_bed_allocation
        FROM Hospital_control
        WHERE Type = 'bed_allocation';
    DROP TABLE IF EXISTS t$temp_bed_table;
    CREATE TEMPORARY TABLE t$temp_bed_table
    (Ward_code VARCHAR(4) NOT NULL,
        Cubicle_no VARCHAR(4) NULL,
        Bed_no VARCHAR(5) NOT NULL,
        Bed_type VARCHAR(1) NULL);
    CREATE UNIQUE INDEX temp_bed_table_index ON t$temp_bed_table
        (Ward_code, Cubicle_no, Bed_no);

    IF var_bed_allocation = 'Y' THEN
        BEGIN
            INSERT INTO t$temp_bed_table
            SELECT
                ungrouped_query.ward_code, cubicle_no, ungrouped_query.bed_no, bed_type
                FROM (SELECT
                    ward_code, cubicle_no, bed_no, bed_type, hospital_code, effective_datetime, active_status
                    FROM bed_history) AS ungrouped_query
                INNER JOIN (SELECT
                    hospital_code, ward_code, bed_no, MAX(effective_datetime) AS max_1
                    FROM bed_history
                    WHERE effective_datetime <= timestamp_convert(localtimestamp)
                    GROUP BY hospital_code, ward_code, bed_no) AS grouped_query
                ON COALESCE(ungrouped_query.hospital_code, '') = COALESCE(grouped_query.hospital_code, '')
                    AND COALESCE(ungrouped_query.ward_code, '') = COALESCE(grouped_query.ward_code, '')
                    AND COALESCE(ungrouped_query.bed_no, '') = COALESCE(grouped_query.bed_no, '')
                WHERE effective_datetime = max_1 AND active_status = 'A';
        END;
    ELSE
        BEGIN
            INSERT INTO t$temp_bed_table
            SELECT
                Ward_code, NULL, Bed_no, Bed_type
                FROM Bed;
        END;
    END IF;

    IF par_no_day_bed = 'Y' THEN
        BEGIN
            /* count the no. of official bed occupied */
            DROP TABLE IF EXISTS t$temp_table_off_occ;
            CREATE TEMPORARY TABLE t$temp_table_off_occ
            AS
            SELECT
                Ward_list.Ward_code, COUNT(*) AS Official_occ_bed
                FROM Ward_list, t$temp_bed_table AS b
                WHERE Ward_list.Ward_code = b.Ward_code AND Ward_list.Bed_no = b.Bed_no AND b.Bed_type <> 'E' AND b.Bed_type <> 'D' AND (COALESCE(Ward_list.Bed_no, 'Y') <> 'Y')
                GROUP BY Ward_list.Ward_code;
            /* count the no. of official bed in each ward */
            /* Adaptive Server has expanded all '*' elements in the following statement */
            DROP TABLE IF EXISTS t$temp_eff_sum;
            CREATE TEMPORARY TABLE t$temp_eff_sum
            AS
            SELECT
                Effective_date, ungrouped_query.Ward_code, ungrouped_query.Specialty_code, Official_bed, Day_bed, Close_date, System_datetime, User_ID
                FROM (SELECT
                    Effective_date, Ward_code, Specialty_code, Official_bed, Day_bed, Close_date, System_datetime, User_ID
                    FROM Ward_specialty) AS ungrouped_query
                INNER JOIN (SELECT
                    Ward_code, Specialty_code, MAX(Effective_date) AS max_2
                    FROM Ward_specialty
                    WHERE Effective_date < timestamp_convert(localtimestamp)
                    GROUP BY Ward_code, Specialty_code) AS grouped_query
                ON COALESCE(ungrouped_query.Ward_code, '') = COALESCE(grouped_query.Ward_code, '')
                    AND COALESCE(ungrouped_query.Specialty_code, '') = COALESCE(grouped_query.Specialty_code, '')
                    AND Effective_date = max_2
                ORDER BY Ward_code NULLS FIRST;
            DROP TABLE IF EXISTS t$temp_o_bed_to;
            CREATE TEMPORARY TABLE t$temp_o_bed_to
            AS
            SELECT
                Ward_code, SUM(Official_bed) AS Official_total
                FROM t$temp_eff_sum
                GROUP BY Ward_code;
            /* count the no. of temp bed occupied */
            DROP TABLE IF EXISTS t$temp_c_bed_null;
            CREATE TEMPORARY TABLE t$temp_c_bed_null
            AS
            SELECT
                Ward_code, COUNT(Case_no) AS Temp_occ
                FROM Ward_list
                WHERE COALESCE(Bed_no, 'Y') = 'Y'
                GROUP BY Ward_code;
            /* count the no. of camp bed occupied */
            DROP TABLE IF EXISTS t$temp_camp_occ;
            CREATE TEMPORARY TABLE t$temp_camp_occ
            AS
            SELECT
                Ward_list.Ward_code, COUNT(*) AS Camp_bed_occ
                FROM Ward_list, t$temp_bed_table AS b
                WHERE Ward_list.Ward_code = b.Ward_code AND Ward_list.Bed_no = b.Bed_no AND b.Bed_type = 'E' AND (COALESCE(Ward_list.Bed_no, 'Y') <> 'Y')
                GROUP BY Ward_list.Ward_code;
            /* count the total no. of camp bed */
            DROP TABLE IF EXISTS t$temp_c_bed_e;
            CREATE TEMPORARY TABLE t$temp_c_bed_e
            AS
            SELECT
                ward_code, COUNT(bed_no) AS Camp_bed
                FROM t$temp_bed_table
                WHERE bed_type = 'E'
                GROUP BY ward_code;
            /* count the no. of day bed occupied */
            DROP TABLE IF EXISTS t$temp_day_occ;
            CREATE TEMPORARY TABLE t$temp_day_occ
            AS
            SELECT
                Ward_list.Ward_code, COUNT(*) AS Day_bed_occ
                FROM Ward_list, t$temp_bed_table AS b
                WHERE Ward_list.Ward_code = b.Ward_code AND Ward_list.Bed_no = b.Bed_no AND b.Bed_type = 'D' AND (COALESCE(Ward_list.Bed_no, 'Y') <> 'Y')
                GROUP BY Ward_list.Ward_code;
            /* count the total no. of Day Bed */
            /* Adaptive Server has expanded all '*' elements in the following statement */
            DROP TABLE IF EXISTS t$temp_day_sum;
            CREATE TEMPORARY TABLE t$temp_day_sum
            AS
            SELECT
                Effective_date, ungrouped_query.Ward_code, ungrouped_query.Specialty_code, Official_bed, Day_bed, Close_date, System_datetime, User_ID
                FROM (SELECT
                    Effective_date, Ward_code, Specialty_code, Official_bed, Day_bed, Close_date, System_datetime, user_id
                    FROM Ward_specialty) AS ungrouped_query
                INNER JOIN (SELECT
                    Ward_code, Specialty_code, MAX(Effective_date) AS max_2
                    FROM Ward_specialty
                    WHERE Effective_date < timestamp_convert(localtimestamp)
                    GROUP BY Ward_code, Specialty_code) AS grouped_query
                ON COALESCE(ungrouped_query.Ward_code, '') = COALESCE(grouped_query.Ward_code, '')
                    AND COALESCE(ungrouped_query.Specialty_code, '') = COALESCE(grouped_query.Specialty_code, '')
                    AND Effective_date = max_2
                ORDER BY Ward_code NULLS FIRST;
            DROP TABLE IF EXISTS t$temp_d_bed_to;
            CREATE TEMPORARY TABLE t$temp_d_bed_to
            AS
            SELECT
                Ward_code, SUM(Day_bed) AS Day_bed
                FROM t$temp_day_sum
                GROUP BY Ward_code;
            /*
            join to form a table with ward code,
            occupied no. of bed, vacant bed and total bed
            */
            DROP TABLE IF EXISTS t$temp_off;
            CREATE TEMPORARY TABLE t$temp_off
            AS
            SELECT
                t$temp_table_off_occ.Ward_code, t$temp_table_off_occ.Official_occ_bed, (t$temp_o_bed_to.Official_total - t$temp_table_off_occ.Official_occ_bed) AS Official_vacant, t$temp_o_bed_to.Official_total, 0 AS Temp_occ_bed, 0 AS Camp_occ_bed, 0 AS Camp_vacant, 0 AS Camp_total, 0 AS Day_occ_bed, 0 AS Day_vacant, 0 AS Day_total
                FROM t$temp_table_off_occ, t$temp_o_bed_to
                WHERE t$temp_table_off_occ.Ward_code = t$temp_o_bed_to.Ward_code;
            DROP TABLE IF EXISTS t$temp_table_1;
            CREATE TEMPORARY TABLE t$temp_table_1
            AS
            SELECT
                t$temp_table_off_occ.Ward_code, t$temp_table_off_occ.Official_occ_bed
                FROM t$temp_table_off_occ, t$temp_o_bed_to
                WHERE t$temp_table_off_occ.Ward_code NOT IN (SELECT
                    t$temp_o_bed_to.Ward_code
                    FROM t$temp_o_bed_to);
            /*
            [7774 - Severity CRITICAL - Unable to perform an automated migration of the arithmetic operations with mixed types of operands. Make cast operands to the expected type.]
            insert t$temp_off (Ward_code, Official_occ_bed, Official_vacant, Official_total, Temp_occ_bed, Camp_occ_bed, Camp_vacant, Camp_total, Day_occ_bed, Day_vacant, Day_total)
                   	   select Ward_code, Official_occ_bed, Official_occ_bed*-1,0, 0, 0, 0, 0, 0, 0, 0
                       from #temp_table_1
            */
            DROP TABLE IF EXISTS t$temp_table_2;
            CREATE TEMPORARY TABLE t$temp_table_2
            AS
            SELECT
                t$temp_o_bed_to.Ward_code, t$temp_o_bed_to.Official_total
                FROM t$temp_o_bed_to
                WHERE t$temp_o_bed_to.Ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$temp_table_off_occ);
            INSERT INTO t$temp_off (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                Ward_code, 0, official_total, official_total, 0, 0, 0, 0, 0, 0, 0
                FROM t$temp_table_2;
            /* update the temp table to add the no. of camp bed occupied */
            UPDATE t$temp_off
            SET Camp_occ_bed = Camp_occ_bed + t$temp_camp_occ.Camp_bed_occ
            FROM t$temp_camp_occ
                WHERE t$temp_off.Ward_code = t$temp_camp_occ.Ward_code;
            INSERT INTO t$temp_off (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                Ward_code, 0, 0, 0, 0, Camp_bed_occ, 0, 0, 0, 0, 0
                FROM t$temp_camp_occ
                WHERE t$temp_camp_occ.Ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$temp_off);
            /* update the temp table to add the no. of temp bed occupied */
            UPDATE t$temp_off
            SET Temp_occ_bed = Temp_occ_bed + Temp_occ
            FROM t$temp_c_bed_null
                WHERE t$temp_off.Ward_code = t$temp_c_bed_null.Ward_code;
            INSERT INTO t$temp_off (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                Ward_code, 0, 0, 0, Temp_occ, 0, 0, 0, 0, 0, 0
                FROM t$temp_c_bed_null
                WHERE t$temp_c_bed_null.Ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$temp_off);
            /* update the temp table to add the no. of day bed occupied */
            UPDATE t$temp_off
            SET Day_occ_bed = Day_occ_bed + t$temp_day_occ.Day_bed_occ
            FROM t$temp_day_occ
                WHERE t$temp_off.Ward_code = t$temp_day_occ.Ward_code;
            INSERT INTO t$temp_off (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                Ward_code, 0, 0, 0, 0, 0, 0, 0, Day_bed_occ, 0, 0
                FROM t$temp_day_occ
                WHERE t$temp_day_occ.Ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$temp_off);
            /*
            update the temp table to add the total no. of camp bed,
            vacant camp bed in each ward
            */
            UPDATE t$temp_off
            SET Camp_total = Camp_total + Camp_bed
            FROM t$temp_c_bed_e
                WHERE t$temp_off.Ward_code = t$temp_c_bed_e.ward_code;
            INSERT INTO t$temp_off (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                ward_code, 0, 0, 0, 0, 0, 0, Camp_bed, 0, 0, 0
                FROM t$temp_c_bed_e
                WHERE t$temp_c_bed_e.ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$temp_off);
            UPDATE t$temp_off
            SET Camp_vacant = Camp_total - Camp_occ_bed
            FROM t$temp_c_bed_e
                WHERE t$temp_off.Ward_code = t$temp_c_bed_e.ward_code;
            /*
            [7774 - Severity CRITICAL - Unable to perform an automated migration of the arithmetic operations with mixed types of operands. Make cast operands to the expected type.]
            update t$temp_off
                    	set Camp_vacant = Camp_occ_bed * -1
            	        from t$temp_off, #temp_c_bed_e
                    	where t$temp_off.Ward_code not in
            	        (select Ward_code from #temp_c_bed_e)
            */
            /*
            update the temp table to add the total no. of day bed,
            vacant day bed in each ward
            */
            UPDATE t$temp_off
            SET Day_total = Day_total + Day_bed
            FROM t$temp_d_bed_to
                WHERE t$temp_off.Ward_code = t$temp_d_bed_to.Ward_code;
            INSERT INTO t$temp_off (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                Ward_code, 0, 0, 0, 0, 0, 0, 0, 0, 0, Day_bed
                FROM t$temp_d_bed_to
                WHERE t$temp_d_bed_to.Ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$temp_off);
            UPDATE t$temp_off
            SET Day_vacant = Day_total - Day_occ_bed
            FROM t$temp_d_bed_to
                WHERE t$temp_off.Ward_code = t$temp_d_bed_to.Ward_code;
            /*
            [7774 - Severity CRITICAL - Unable to perform an automated migration of the arithmetic operations with mixed types of operands. Make cast operands to the expected type.]
            update t$temp_off
            		set Day_vacant = Day_occ_bed * -1
            		from t$temp_off, #temp_d_bed_to
            		where t$temp_off.Ward_code not in
            		(select Ward_code from #temp_d_bed_to)
            */
            DROP TABLE IF EXISTS t$current_ward;
            CREATE TEMPORARY TABLE t$current_ward
            AS
            select t1.ward_code 
                from (select ward_code,Effective_date, Active_status from Ward) t1 
                inner join (select ward_code, MAX(Effective_date) max1 from Ward GROUP BY Ward_code) t2 
                on t1.ward_code = t2.ward_code and t1.effective_date = t2.max1 
                and t2.max1 <= timestamp_convert(localtimestamp) and t1.Active_status='A';
            INSERT INTO t$temp_off (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                Ward_code, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                FROM t$current_ward
                WHERE t$current_ward.Ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$temp_off);
            /* comment by ivy for eliminate some ward_code */
            /*
            select *
            from t$temp_off
            */
            /* Adaptive Server has expanded all '*' elements in the following statement */
            DROP TABLE IF EXISTS t$result_tmp;
            CREATE TEMPORARY TABLE t$result_tmp
            AS
            SELECT
                t$temp_off.Ward_code, t$temp_off.official_occ_bed, t$temp_off.Official_vacant, t$temp_off.official_total, t$temp_off.Temp_occ_bed, t$temp_off.Camp_occ_bed, t$temp_off.Camp_vacant, t$temp_off.Camp_total, t$temp_off.Day_occ_bed, t$temp_off.Day_vacant, t$temp_off.Day_total
                FROM t$temp_off
                WHERE t$temp_off.Ward_code IN (select t1.ward_code 
                        from (select ward_code,Effective_date, Active_status from Ward) t1 
                        inner join (select ward_code, MAX(Effective_date) max1 from Ward GROUP BY Ward_code) t2 
                        on t1.ward_code = t2.ward_code and t1.effective_date = t2.max1 
                        and t2.max1 <= timestamp_convert(localtimestamp) and t1.Active_status='A');
            /* kar13Aug00: get normal list or user preference list */
            IF (par_ward_occ_group <> '') AND (par_ward_occ_group is not NULL) THEN
                BEGIN
                    SELECT
                        COUNT(*)
                        INTO var_rowcount
                        FROM cms_ward_occ_preference
                        WHERE ward_occ_group = par_ward_occ_group;

                    IF var_rowcount > 0 THEN
                        BEGIN
                            /* Adaptive Server has expanded all '*' elements in the following statement */
                            OPEN p_refcur FOR
                            SELECT
                                t$result_tmp.Ward_code, t$result_tmp.official_occ_bed, t$result_tmp.official_vacant, t$result_tmp.official_total, t$result_tmp.temp_occ_bed, t$result_tmp.camp_occ_bed, t$result_tmp.camp_vacant, t$result_tmp.camp_total, t$result_tmp.day_occ_bed, t$result_tmp.day_vacant, t$result_tmp.day_total
                                FROM t$result_tmp
                                WHERE Ward_code IN (SELECT
                                    ward_code
                                    FROM cms_ward_occ_preference
                                    WHERE ward_occ_group = par_ward_occ_group)
                                ORDER BY Ward_code NULLS FIRST;
                            RETURN NEXT p_refcur;
                        END;
                    ELSE
                        /* Adaptive Server has expanded all '*' elements in the following statement */
                        OPEN p_refcur FOR
                        SELECT
                            t$result_tmp.Ward_code, t$result_tmp.official_occ_bed, t$result_tmp.official_vacant, t$result_tmp.official_total, t$result_tmp.temp_occ_bed, t$result_tmp.camp_occ_bed, t$result_tmp.camp_vacant, t$result_tmp.camp_total, t$result_tmp.day_occ_bed, t$result_tmp.day_vacant, t$result_tmp.day_total
                            FROM t$result_tmp
                            WHERE 1 = 2;
                    END IF;
                END;
            ELSE
                /* Adaptive Server has expanded all '*' elements in the following statement */
                OPEN p_refcur FOR
                SELECT
                    t$result_tmp.Ward_code, t$result_tmp.official_occ_bed, t$result_tmp.official_vacant, t$result_tmp.official_total, t$result_tmp.temp_occ_bed, t$result_tmp.camp_occ_bed, t$result_tmp.camp_vacant, t$result_tmp.camp_total, t$result_tmp.day_occ_bed, t$result_tmp.day_vacant, t$result_tmp.day_total
                    FROM t$result_tmp
                    ORDER BY Ward_code NULLS FIRST;
                RETURN NEXT p_refcur;
            END IF;
            /* end: kar08Jan01 */
            /* end: kar13Aug00 */
    
        END;
    END IF;

    IF par_no_day_bed = 'N' THEN
        BEGIN
            /* count the no. of official bed occupied */
            DROP TABLE IF EXISTS t$temptableoffocc;
            CREATE TEMPORARY TABLE t$temptableoffocc
            AS
            SELECT
                Ward_list.Ward_code, COUNT(*) AS Official_occ_bed
                FROM Ward_list, t$temp_bed_table AS b
                WHERE Ward_list.Ward_code = b.Ward_code AND Ward_list.Bed_no = b.Bed_no AND b.Bed_type <> 'E' AND (COALESCE(Ward_list.Bed_no, 'Y') <> 'Y')
                GROUP BY Ward_list.Ward_code;
            /* count the no. of official bed in each ward */
            /* Adaptive Server has expanded all '*' elements in the following statement */
            DROP TABLE IF EXISTS t$tempeffsum;
            CREATE TEMPORARY TABLE t$tempeffsum
            AS
            SELECT
                Effective_date, ungrouped_query.Ward_code, ungrouped_query.Specialty_code, Official_bed, Day_bed, Close_date, System_datetime, User_ID
                FROM (SELECT
                    Effective_date, Ward_code, Specialty_code, Official_bed, Day_bed, Close_date, System_datetime, User_ID
                    FROM Ward_specialty) AS ungrouped_query
                INNER JOIN (SELECT
                    Ward_code, Specialty_code, MAX(Effective_date) AS max_2
                    FROM Ward_specialty
                    WHERE Effective_date < timestamp_convert(localtimestamp)
                    GROUP BY Ward_code, Specialty_code) AS grouped_query
                ON COALESCE(ungrouped_query.Ward_code, '') = COALESCE(grouped_query.Ward_code, '')
                    AND COALESCE(ungrouped_query.Specialty_code, '') = COALESCE(grouped_query.Specialty_code, '')
                    AND Effective_date = max_2
                ORDER BY Ward_code NULLS FIRST;
            DROP TABLE IF EXISTS t$tempobedto;
            CREATE TEMPORARY TABLE t$tempobedto
            AS
            SELECT
                Ward_code, SUM(Official_bed + Day_bed) AS Official_total
                FROM t$tempeffsum
                GROUP BY Ward_code;
            /* count the no. of temp bed occupied */
            DROP TABLE IF EXISTS t$tempcbednull;
            CREATE TEMPORARY TABLE t$tempcbednull
            AS
            SELECT
                Ward_code, COUNT(Case_no) AS Temp_occ
                FROM Ward_list
                WHERE COALESCE(Bed_no, 'Y') = 'Y'
                GROUP BY Ward_code;
            /* count the no. of camp bed occupied */
            DROP TABLE IF EXISTS t$tempcampocc;
            CREATE TEMPORARY TABLE t$tempcampocc
            AS
            SELECT
                Ward_list.Ward_code, COUNT(*) AS Camp_bed_occ
                FROM Ward_list, t$temp_bed_table AS b
                WHERE Ward_list.Ward_code = b.Ward_code AND Ward_list.Bed_no = b.Bed_no AND b.Bed_type = 'E' AND (COALESCE(Ward_list.Bed_no, 'Y') <> 'Y')
                GROUP BY Ward_list.Ward_code;
            /* count the total no. of camp bed */
            DROP TABLE IF EXISTS t$tempcbede;
            CREATE TEMPORARY TABLE t$tempcbede
            AS
            SELECT
                ward_code, COUNT(bed_no) AS Camp_bed
                FROM t$temp_bed_table
                WHERE bed_type = 'E'
                GROUP BY ward_code;
            /* count the no. of day bed occupied */
            DROP TABLE IF EXISTS t$tempdayocc;
            CREATE TEMPORARY TABLE t$tempdayocc
            AS
            SELECT
                Ward_list.Ward_code, COUNT(*) AS Day_bed_occ
                FROM Ward_list, t$temp_bed_table AS b
                WHERE Ward_list.Ward_code = b.Ward_code AND Ward_list.Bed_no = b.Bed_no AND b.Bed_type = 'D' AND (COALESCE(Ward_list.Bed_no, 'Y') <> 'Y')
                GROUP BY Ward_list.Ward_code;
            /* count the total no. of Day Bed */
            /* Adaptive Server has expanded all '*' elements in the following statement */
            DROP TABLE IF EXISTS t$tempdaysum;
            CREATE TEMPORARY TABLE t$tempdaysum
            AS
            SELECT
                Effective_date, ungrouped_query.Ward_code, ungrouped_query.Specialty_code, Official_bed, Day_bed, Close_date, System_datetime, User_ID
                FROM (SELECT
                    Effective_date, Ward_code, Specialty_code, Official_bed, Day_bed, Close_date, System_datetime, User_ID
                    FROM Ward_specialty) AS ungrouped_query
                INNER JOIN (SELECT
                    Ward_code, Specialty_code, MAX(Effective_date) AS max_2
                    FROM Ward_specialty
                    WHERE Effective_date < timestamp_convert(localtimestamp)
                    GROUP BY Ward_code, Specialty_code) AS grouped_query
                ON COALESCE(ungrouped_query.Ward_code, '') = COALESCE(grouped_query.Ward_code, '')
                    AND COALESCE(ungrouped_query.Specialty_code, '') = COALESCE(grouped_query.Specialty_code, '')
                    AND Effective_date = max_2
                ORDER BY Ward_code NULLS FIRST;
            DROP TABLE IF EXISTS t$tempdbedto;
            CREATE TEMPORARY TABLE t$tempdbedto
            AS
            SELECT
                Ward_code, SUM(Day_bed) AS Day_bed
                FROM t$tempdaysum
                GROUP BY Ward_code;
            /*
            join to form a table with ward code,
            occupied no. of bed, vacant bed and total bed
            */
            DROP TABLE IF EXISTS t$tempoff;
            CREATE TEMPORARY TABLE t$tempoff
            AS
            SELECT
                t$temptableoffocc.Ward_code, t$temptableoffocc.Official_occ_bed, (t$tempobedto.Official_total - t$temptableoffocc.Official_occ_bed) AS Official_vacant, t$tempobedto.Official_total, 0 AS Temp_occ_bed, 0 AS Camp_occ_bed, 0 AS Camp_vacant, 0 AS Camp_total, 0 AS Day_occ_bed, 0 AS Day_vacant, 0 AS Day_total
                FROM t$temptableoffocc, t$tempobedto
                WHERE t$temptableoffocc.Ward_code = t$tempobedto.Ward_code;
            DROP TABLE IF EXISTS t$temptable1;
            CREATE TEMPORARY TABLE t$temptable1
            AS
            SELECT
                t$temptableoffocc.Ward_code, t$temptableoffocc.Official_occ_bed
                FROM t$temptableoffocc, t$tempobedto
                WHERE t$temptableoffocc.Ward_code NOT IN (SELECT
                    t$tempobedto.Ward_code
                    FROM t$tempobedto);
            /*
            [7774 - Severity CRITICAL - Unable to perform an automated migration of the arithmetic operations with mixed types of operands. Make cast operands to the expected type.]
            insert t$tempoff (Ward_code, Official_occ_bed, Official_vacant, Official_total, Temp_occ_bed, Camp_occ_bed, Camp_vacant, Camp_total, Day_occ_bed, Day_vacant, Day_total)
                   	   select Ward_code, Official_occ_bed, Official_occ_bed*-1,0, 0, 0, 0, 0, 0, 0, 0
                       from #temptable1
            */
            DROP TABLE IF EXISTS t$temptable2;
            CREATE TEMPORARY TABLE t$temptable2
            AS
            SELECT
                t$tempobedto.Ward_code, t$tempobedto.Official_total
                FROM t$tempobedto
                WHERE t$tempobedto.Ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$temptableoffocc);
            INSERT INTO t$tempoff (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                Ward_code, 0, official_total, official_total, 0, 0, 0, 0, 0, 0, 0
                FROM t$temptable2;
            /* update the temp table to add the no. of camp bed occupied */
            UPDATE t$tempoff
            SET Camp_occ_bed = Camp_occ_bed + t$tempcampocc.Camp_bed_occ
            FROM t$tempcampocc
                WHERE t$tempoff.Ward_code = t$tempcampocc.Ward_code;
            INSERT INTO t$tempoff (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                Ward_code, 0, 0, 0, 0, Camp_bed_occ, 0, 0, 0, 0, 0
                FROM t$tempcampocc
                WHERE t$tempcampocc.Ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$tempoff);
            /* update the temp table to add the no. of temp bed occupied */
            UPDATE t$tempoff
            SET Temp_occ_bed = Temp_occ_bed + Temp_occ
            FROM t$tempcbednull
                WHERE t$tempoff.Ward_code = t$tempcbednull.Ward_code;
            INSERT INTO t$tempoff (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                Ward_code, 0, 0, 0, Temp_occ, 0, 0, 0, 0, 0, 0
                FROM t$tempcbednull
                WHERE t$tempcbednull.Ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$tempoff);
            /* update the temp table to add the no. of day bed occupied */
            UPDATE t$tempoff
            SET Day_occ_bed = Day_occ_bed + t$tempdayocc.Day_bed_occ
            FROM t$tempdayocc
                WHERE t$tempoff.Ward_code = t$tempdayocc.Ward_code;
            INSERT INTO t$tempoff (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                Ward_code, 0, 0, 0, 0, 0, 0, 0, Day_bed_occ, 0, 0
                FROM t$tempdayocc
                WHERE t$tempdayocc.Ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$tempoff);
            /*
            update the temp table to add the total no. of camp bed,
            vacant camp bed in each ward
            */
            UPDATE t$tempoff
            SET Camp_total = Camp_total + Camp_bed
            FROM t$tempcbede
                WHERE t$tempoff.Ward_code = t$tempcbede.ward_code;
            INSERT INTO t$tempoff (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                ward_code, 0, 0, 0, 0, 0, 0, Camp_bed, 0, 0, 0
                FROM t$tempcbede
                WHERE t$tempcbede.ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$tempoff);
            UPDATE t$tempoff
            SET Camp_vacant = Camp_total - Camp_occ_bed
            FROM t$tempcbede
                WHERE t$tempoff.Ward_code = t$tempcbede.ward_code;
            /*
            [7774 - Severity CRITICAL - Unable to perform an automated migration of the arithmetic operations with mixed types of operands. Make cast operands to the expected type.]
            update t$tempoff
                    	set Camp_vacant = Camp_occ_bed * -1
            	        from t$tempoff, #tempcbede
                    	where t$tempoff.Ward_code not in
            	        (select Ward_code from #tempcbede)
            */
            /*
            update the temp table to add the total no. of day bed,
            vacant day bed in each ward
            */
            UPDATE t$tempoff
            SET Day_total = Day_total + Day_bed
            FROM t$tempdbedto
                WHERE t$tempoff.Ward_code = t$tempdbedto.Ward_code;
            INSERT INTO t$tempoff (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                Ward_code, 0, 0, 0, 0, 0, 0, 0, 0, 0, Day_bed
                FROM t$tempdbedto
                WHERE t$tempdbedto.Ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$tempoff);
            UPDATE t$tempoff
            SET Day_vacant = Day_total - Day_occ_bed
            FROM t$tempdbedto
                WHERE t$tempoff.Ward_code = t$tempdbedto.Ward_code;
            /*
            [7774 - Severity CRITICAL - Unable to perform an automated migration of the arithmetic operations with mixed types of operands. Make cast operands to the expected type.]
            update t$tempoff
            		set Day_vacant = Day_occ_bed * -1
            		from t$tempoff, #tempdbedto
            		where t$tempoff.Ward_code not in
            		(select Ward_code from #tempdbedto)
            */
            DROP TABLE IF EXISTS t$currentward;
            CREATE TEMPORARY TABLE t$currentward
            AS
            select t1.ward_code 
                from (select ward_code,Effective_date, Active_status from Ward) t1 
                inner join (select ward_code, MAX(Effective_date) max1 from Ward GROUP BY Ward_code) t2 
                on t1.ward_code = t2.ward_code and t1.effective_date = t2.max1 
                and t2.max1 <= timestamp_convert(localtimestamp) and t1.Active_status='A';
            INSERT INTO t$tempoff (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed, camp_vacant, camp_total, day_occ_bed, day_vacant, day_total)
            SELECT
                Ward_code, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                FROM t$currentward
                WHERE t$currentward.Ward_code NOT IN (SELECT
                    Ward_code
                    FROM t$tempoff);
            /* comment by ivy for eliminate some ward_code */
            /*
            select *
            from t$tempoff
            */
            /* Adaptive Server has expanded all '*' elements in the following statement */
            DROP TABLE IF EXISTS t$resulttmp;
            CREATE TEMPORARY TABLE t$resulttmp
            AS
            SELECT
                t$tempoff.Ward_code, t$tempoff.official_occ_bed, t$tempoff.Official_vacant, t$tempoff.official_total, t$tempoff.Temp_occ_bed, t$tempoff.Camp_occ_bed, t$tempoff.Camp_vacant, t$tempoff.Camp_total, t$tempoff.Day_occ_bed, t$tempoff.Day_vacant, t$tempoff.Day_total
                FROM t$tempoff
                WHERE t$tempoff.Ward_code IN (select t1.ward_code 
                        from (select ward_code,Effective_date, Active_status from Ward) t1 
                        inner join (select ward_code, MAX(Effective_date) max1 from Ward GROUP BY Ward_code) t2 
                        on t1.ward_code = t2.ward_code and t1.effective_date = t2.max1 
                        and t2.max1 <= timestamp_convert(localtimestamp) and t1.Active_status='A');
            /* kar08Jan01: modify ward_occ_preference */
            /* kar13Aug00: get normal list or user preference list */
            IF (par_ward_occ_group <> '') AND (par_ward_occ_group is not NULL) THEN
                BEGIN
                    SELECT
                        COUNT(*)
                        INTO var_rowcount
                        FROM cms_ward_occ_preference
                        WHERE ward_occ_group = par_ward_occ_group;

                    IF var_rowcount > 0 THEN
                        BEGIN
                            /* Adaptive Server has expanded all '*' elements in the following statement */
                            OPEN p_refcur FOR
                            SELECT
                                t$resulttmp.Ward_code, t$resulttmp.official_occ_bed::INTEGER, t$resulttmp.official_vacant::INTEGER, t$resulttmp.official_total::INTEGER, t$resulttmp.temp_occ_bed::INTEGER, t$resulttmp.camp_occ_bed::INTEGER, t$resulttmp.camp_vacant::INTEGER, t$resulttmp.camp_total::INTEGER, t$resulttmp.day_occ_bed::INTEGER, t$resulttmp.day_vacant::INTEGER, t$resulttmp.day_total::INTEGER
                                FROM t$resulttmp
                                WHERE Ward_code IN (SELECT
                                    ward_code
                                    FROM cms_ward_occ_preference
                                    WHERE ward_occ_group = par_ward_occ_group)
                                ORDER BY Ward_code NULLS FIRST;
                        END;
                    ELSE
                        /* Adaptive Server has expanded all '*' elements in the following statement */
                        OPEN p_refcur FOR
                        SELECT
                            t$resulttmp.Ward_code, t$resulttmp.official_occ_bed::INTEGER, t$resulttmp.official_vacant::INTEGER, t$resulttmp.official_total::INTEGER, t$resulttmp.temp_occ_bed::INTEGER, t$resulttmp.camp_occ_bed::INTEGER, t$resulttmp.camp_vacant::INTEGER, t$resulttmp.camp_total::INTEGER, t$resulttmp.day_occ_bed::INTEGER, t$resulttmp.day_vacant::INTEGER, t$resulttmp.day_total::INTEGER
                            FROM t$resulttmp
                            WHERE 1 = 2;
                    END IF;
                END;
            ELSE
                /* Adaptive Server has expanded all '*' elements in the following statement */
                OPEN p_refcur FOR
                SELECT
                    t$resulttmp.Ward_code, t$resulttmp.official_occ_bed::INTEGER, t$resulttmp.official_vacant::INTEGER, t$resulttmp.official_total::INTEGER, t$resulttmp.temp_occ_bed::INTEGER, t$resulttmp.camp_occ_bed::INTEGER, t$resulttmp.camp_vacant::INTEGER, t$resulttmp.camp_total::INTEGER, t$resulttmp.day_occ_bed::INTEGER, t$resulttmp.day_vacant::INTEGER, t$resulttmp.day_total::INTEGER
                    FROM t$resulttmp
                    ORDER BY Ward_code NULLS FIRST;
                RETURN NEXT p_refcur;
            END IF;
            /* end: kar13Aug00 */
            /* end: kar08Jan01 */
 
        END;
    END IF;
END;
$function$
;


;ALTER FUNCTION "hasp_get_ward_occupancy" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
