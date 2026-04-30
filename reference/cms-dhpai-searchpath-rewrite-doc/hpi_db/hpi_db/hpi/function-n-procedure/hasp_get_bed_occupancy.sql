-- DROP PROCEDURE hasp_get_bed_occupancy(inout int4, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_get_bed_occupancy(INOUT pas_return_code integer, IN par_hosp_code character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* add hosp code for HPI by ML on 05.08.1999 */
DECLARE
    var_bed_allocation VARCHAR(1);
    sql$rowcount BIGINT;
BEGIN
    BEGIN
        SELECT
            Text_value
            INTO var_bed_allocation
            FROM Hospital_control
            WHERE Type = 'bed_allocation';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            SELECT
                'N'
                INTO var_bed_allocation;
        END IF;
        EXCEPTION
            WHEN OTHERS THEN
                SELECT
                    'N'
                    INTO var_bed_allocation;
    END;
    /* count the no. of official bed occupied */
    /* add hosp code for HPI by ML on 05.08.1999 */
    DROP TABLE IF EXISTS t$temp_table_off_occ;
    CREATE TEMPORARY TABLE t$temp_table_off_occ
    (Ward_code VARCHAR(4),
        Official_occ_bed INTEGER);

    IF var_bed_allocation = 'Y' THEN
        INSERT INTO t$temp_table_off_occ (ward_code, official_occ_bed)
        SELECT
            w.Ward_code, COUNT(*)
            /* --			into #temp_table_off_occ */
            FROM Ward_list AS w, bed_history AS b
            WHERE w.Hospital_code = par_hosp_code AND w.Hospital_code = b.hospital_code AND w.Ward_code = b.ward_code AND w.Bed_no = b.bed_no AND effective_datetime = (SELECT
                MAX(effective_datetime)
                FROM bed_history
                WHERE ward_code = b.ward_code AND hospital_code = b.hospital_code AND bed_no = b.bed_no AND effective_datetime <= timestamp_convert(localtimestamp)) AND b.bed_type <> 'E' AND (COALESCE(w.Bed_no, 'Y') <> 'Y')
            GROUP BY w.Ward_code;
    ELSE
        INSERT INTO t$temp_table_off_occ (ward_code, official_occ_bed)
        /* select Ward_list.Ward_code,Official_occ_bed=count(*) */
        /* into #temp_table_off_occ */
        SELECT
            Ward_list.Ward_code, COUNT(*)
            FROM Ward_list, Bed
            WHERE Ward_list.Hospital_code = par_hosp_code AND Bed.Hospital_code = par_hosp_code AND Ward_list.Ward_code = Bed.Ward_code AND Ward_list.Bed_no = Bed.Bed_no AND Bed.Bed_type <> 'E' AND (COALESCE(Ward_list.Bed_no, 'Y') <> 'Y')
            GROUP BY Ward_list.Ward_code;
    END IF;
    /* count the no. of official bed in each ward */
    /* add hosp code for HPI by ML on 05.08.1999 */
    DROP TABLE IF EXISTS t$temp_eff_sum;
    CREATE TEMPORARY TABLE t$temp_eff_sum
    AS
    SELECT
        Hospital_code, Effective_date, ungrouped_query.Ward_code, ungrouped_query.Specialty_code, Official_bed, Day_bed, Close_date, System_datetime, User_ID
        FROM (SELECT
            Hospital_code, Effective_date, Ward_code, Specialty_code, Official_bed, Day_bed, Close_date, System_datetime, User_ID
            FROM Ward_specialty) AS ungrouped_query
        INNER JOIN (SELECT
            Ward_code, Specialty_code, MAX(Effective_date) AS max_1
            FROM Ward_specialty
            WHERE Hospital_code = par_hosp_code AND Effective_date < timestamp_convert(localtimestamp)
            GROUP BY Ward_code, Specialty_code) AS grouped_query
        ON COALESCE(ungrouped_query.Ward_code, '') = COALESCE(grouped_query.Ward_code, '')
            AND COALESCE(ungrouped_query.Specialty_code, '') = COALESCE(grouped_query.Specialty_code, '')
            AND Effective_date = max_1
        ORDER BY Ward_code NULLS FIRST;
    DROP TABLE IF EXISTS t$temp_o_bed_to;
    CREATE TEMPORARY TABLE t$temp_o_bed_to
    AS
    SELECT
        Ward_code, SUM(Official_bed) AS Official_total
        FROM t$temp_eff_sum
        GROUP BY Ward_code;
    /* count the no. of temp bed occupied */
    /* add hosp code for HPI by ML on 05.08.1999 */
    DROP TABLE IF EXISTS t$temp_c_bed_null;
    CREATE TEMPORARY TABLE t$temp_c_bed_null
    AS
    SELECT
        Ward_code, COUNT(Case_no) AS Temp_occ
        FROM Ward_list
        WHERE Hospital_code = par_hosp_code AND COALESCE(Bed_no, 'Y') = 'Y'
        GROUP BY Ward_code;
    /* count the no. of camp bed occupied */
    /* add hosp code for HPI by ML on 05.08.1999 */
    DROP TABLE IF EXISTS t$temp_camp_occ;
    CREATE TEMPORARY TABLE t$temp_camp_occ
    (Ward_code VARCHAR(4),
        Camp_bed_occ INTEGER);

    IF var_bed_allocation = 'Y' THEN
        INSERT INTO t$temp_camp_occ (ward_code, camp_bed_occ)
        /* select w.Ward_code,Camp_bed_occ=count(*) */
        /* into #temp_camp_occ */
        SELECT
            w.Ward_code, COUNT(*)
            FROM Ward_list AS w, bed_history AS b
            WHERE w.Hospital_code = par_hosp_code AND w.Ward_code = b.ward_code AND w.Hospital_code = b.hospital_code AND w.Bed_no = b.bed_no AND effective_datetime = (SELECT
                MAX(effective_datetime)
                FROM bed_history
                WHERE ward_code = b.ward_code AND hospital_code = b.hospital_code AND bed_no = b.bed_no AND effective_datetime <= timestamp_convert(localtimestamp)) AND b.bed_type = 'E' AND (COALESCE(w.Bed_no, 'Y') <> 'Y')
            GROUP BY w.Ward_code;
    ELSE
        INSERT INTO t$temp_camp_occ (ward_code, camp_bed_occ)
        /* select Ward_list.Ward_code,Camp_bed_occ=count(*) */
        /* into #temp_camp_occ */
        SELECT
            Ward_list.Ward_code, COUNT(*)
            FROM Ward_list, Bed
            WHERE Ward_list.Hospital_code = par_hosp_code AND Bed.Hospital_code = par_hosp_code AND Ward_list.Ward_code = Bed.Ward_code AND Ward_list.Bed_no = Bed.Bed_no AND Bed.Bed_type = 'E' AND (COALESCE(Ward_list.Bed_no, 'Y') <> 'Y')
            GROUP BY Ward_list.Ward_code;
    END IF;
    /*
    join to form a table with ward code,
    occupied no. of bed, vacant bed and total bed
    */
    DROP TABLE IF EXISTS t$temp_off;
    CREATE TEMPORARY TABLE t$temp_off
    AS
    SELECT
        t$temp_table_off_occ.ward_code, t$temp_table_off_occ.official_occ_bed, (t$temp_o_bed_to.Official_total - t$temp_table_off_occ.official_occ_bed) AS Official_vacant, t$temp_o_bed_to.Official_total, 0 AS Temp_occ_bed, 0 AS Camp_occ_bed, REPEAT(' ', 1) AS Active_status
        FROM t$temp_table_off_occ, t$temp_o_bed_to
        WHERE t$temp_table_off_occ.ward_code = t$temp_o_bed_to.Ward_code;
    DROP TABLE IF EXISTS t$temp_table_1;
    CREATE TEMPORARY TABLE t$temp_table_1
    AS
    SELECT
        t$temp_table_off_occ.ward_code, t$temp_table_off_occ.official_occ_bed
        FROM t$temp_table_off_occ, t$temp_o_bed_to
        WHERE t$temp_table_off_occ.ward_code NOT IN (SELECT
            t$temp_o_bed_to.Ward_code
            FROM t$temp_o_bed_to);
    INSERT INTO t$temp_off (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed)
    SELECT
        ward_code, official_occ_bed, official_occ_bed * - 1, 0, 0, 0
        FROM t$temp_table_1;
    /* modified by ML on 19041999 since multiple rows are */
    /* inserted */
    DROP TABLE IF EXISTS t$temp_table_2;
    CREATE TEMPORARY TABLE t$temp_table_2
    AS
    SELECT
        t$temp_o_bed_to.Ward_code, t$temp_o_bed_to.Official_total
        /* --from #temp_table_off_occ, */
        FROM t$temp_o_bed_to
        WHERE t$temp_o_bed_to.Ward_code NOT IN (SELECT
            ward_code
            FROM t$temp_table_off_occ);
    INSERT INTO t$temp_off (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed)
    SELECT
        Ward_code, 0, official_total, official_total, 0, 0
        FROM t$temp_table_2;
    /* update the temp table to add the no. of camp bed occupied */
    UPDATE t$temp_off
    SET Camp_occ_bed = Camp_occ_bed + t$temp_camp_occ.camp_bed_occ
    FROM t$temp_camp_occ
        WHERE t$temp_off.ward_code = t$temp_camp_occ.ward_code;
    INSERT INTO t$temp_off (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed)
    SELECT
        ward_code, 0, 0, 0, 0, camp_bed_occ
        FROM t$temp_camp_occ
        WHERE t$temp_camp_occ.ward_code NOT IN (SELECT
            ward_code
            FROM t$temp_off);
    /* update the temp table to add the no. of temp bed occupied */
    UPDATE t$temp_off
    SET Temp_occ_bed = Temp_occ_bed + Temp_occ
    FROM t$temp_c_bed_null
        WHERE t$temp_off.ward_code = t$temp_c_bed_null.Ward_code;
    INSERT INTO t$temp_off (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed)
    SELECT
        Ward_code, 0, 0, 0, Temp_occ, 0
        FROM t$temp_c_bed_null
        WHERE t$temp_c_bed_null.Ward_code NOT IN (SELECT
            ward_code
            FROM t$temp_off);
    /*
    add rows with ward_code without
    beds assigned and are not occupied
    */
    INSERT INTO t$temp_off (ward_code, official_occ_bed, official_vacant, official_total, temp_occ_bed, camp_occ_bed)
    SELECT
        Ward_code, 0, 0, 0, 0, 0
        FROM Ward
        WHERE Hospital_code = par_hosp_code AND Ward.Ward_code NOT IN (SELECT
            ward_code
            FROM t$temp_off);
    /*
    clean up the non-user defined ward code such as 'AE01' and 'HOME'
        before it is passed to front end.
    	 Changed by :Watson Tsui
    	 Changed on : 24/01/1996
    	 Reason: User request
    */
    DELETE FROM t$temp_off
    USING Ward
        WHERE Ward.Hospital_code = par_hosp_code AND t$temp_off.ward_code = Ward.Ward_code AND Ward.User_define = 'N';
    /*
    clean up the inactive ward and all zero result
        before it is passed to front end.
    	 Changed by :Winnie LAU
    	 Changed on : 28/08/1998
    	 Reason: User request
    */
    DROP TABLE IF EXISTS t$ward_active;
    CREATE TEMPORARY TABLE t$ward_active
    AS
    SELECT
        ungrouped_query.Ward_code, Active_status
        FROM (SELECT
            Ward_code, Active_status, Effective_date
            FROM Ward) AS ungrouped_query
        INNER JOIN (SELECT
            Ward_code, MAX(Effective_date) AS max_1
            FROM Ward
            WHERE Effective_date <= to_char(timestamp_convert(localtimestamp),'YYYYMMDD')::timestamp AND Hospital_code = par_hosp_code
            GROUP BY Ward_code) AS grouped_query
        ON COALESCE(ungrouped_query.Ward_code, '') = COALESCE(grouped_query.Ward_code, '')
        AND Effective_date = max_1;
    UPDATE t$temp_off AS t
    SET Active_status = w.Active_status
    FROM t$ward_active AS w
        WHERE w.Ward_code = t.Ward_code;
    OPEN p_refcur FOR
    SELECT
        ward_code, official_occ_bed::INTEGER, Official_vacant::INTEGER, official_total::INTEGER, Temp_occ_bed::INTEGER, Camp_occ_bed::INTEGER
        FROM t$temp_off
        WHERE Active_status <> 'D' OR official_occ_bed <> 0 OR Official_vacant <> 0 OR official_total <> 0 OR Temp_occ_bed <> 0 OR Camp_occ_bed <> 0;
	pas_return_code := 0;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_get_bed_occupancy" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
