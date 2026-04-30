-- DROP FUNCTION hpi.pas_erpt_bed_occ(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hpi.pas_erpt_bed_occ(par_in_hosp character varying DEFAULT NULL::character varying, par_in_from_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, par_in_to_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_local_hosp VARCHAR(6);
    var_rpt_dtm_str VARCHAR(30);
    var_case_no VARCHAR(24);
    var_ward_code VARCHAR(8);
    var_bed_no VARCHAR(10);
    var_spec_code VARCHAR(8);
	p_refcur refcursor;
    ward_list_csr CURSOR FOR
    SELECT
        Case_no, Ward_code, Bed_no, Specialty_code
        FROM Ward_list;
BEGIN
    SELECT
        Hospital_code
        INTO var_local_hosp
        FROM Hospital;
    SELECT
        CONCAT(to_char(localtimestamp, 'YYYYMMDD'), REPEAT(' ', 1), to_char(localtimestamp, 'HH24:mi:ss'))
        INTO var_rpt_dtm_str;
    /* ----------------------------------------------------------- */
    /* --- 1). init bed_alloc table from bed_allocation  -- */
    
    /* ----------------------------------------------------------- */
    
    /*
    [3017 - Severity CRITICAL - PostgreSQL doesn't support the SET NOCOUNT. If need try another way to send message back to the client application.]
    set nocount on
    */
    CREATE TEMPORARY TABLE t$bed_alloc
    (hosp_code VARCHAR(6),
        ward_code VARCHAR(8),
        spec_code VARCHAR(8),
        eff_date TIMESTAMP WITHOUT TIME ZONE NULL,
        off_bed INTEGER NULL,
        day_bed INTEGER NULL,
        ward_occ INTEGER NULL,
        /* --- Number of patient staying@Ward (Ward_list) */
        spec_occ INTEGER NULL,
        /* --- Number of patient staying@Spec (Ward_list) */
        
        /* ---------------------------- */
        ward_treatment_loc VARCHAR(8) NULL,
        ward_loc VARCHAR(40) NULL,
        ward_care_cat VARCHAR(2) NULL,
        spec_treatment_loc VARCHAR(8) NULL,
        spec_sex VARCHAR(2) NULL,
        spec_imis_code VARCHAR(6) NULL,
        spec_eis_code VARCHAR(6) NULL);
    CREATE UNIQUE INDEX bed_alloc_pky ON t$bed_alloc
        (hosp_code, ward_code, spec_code /* ,eff_date */);
    /* ----------------------------------------------------- */
    /* --print '1) create #bed_alloc ' */
    /* ----------------------------------------------------- */
    INSERT INTO t$bed_alloc (hosp_code, ward_code, spec_code, eff_date, off_bed, day_bed)
    SELECT
        ungrouped_query.hospital_code, ungrouped_query.ward_code, specialty_code, effective_date, official_bed, day_bed
        FROM (SELECT
            hospital_code, ward_code, specialty_code, effective_date, official_bed, day_bed
            FROM bed_allocation) AS ungrouped_query
        INNER JOIN (SELECT
            hospital_code, ward_code, MAX(effective_date) AS max_1
            FROM bed_allocation
            WHERE effective_date <= localtimestamp
            GROUP BY hospital_code, ward_code) AS grouped_query
            ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL)) /* ,specialty_code */
        /* --- COULT NOT group by specialty as well !!, otherwise specialty already NOT exist in new eff_dtm will be counted as well */
        WHERE effective_date = max_1
        /* --and (official_bed >0 or day_bed > 0 ) */
        ORDER BY hospital_code NULLS FIRST, ward_code NULLS FIRST, specialty_code NULLS FIRST;
    /* ----------------------------------------------------- */
    /* ---2). init ward_info/spec_info to update bed_alloc ward/spec setting -- */
    /* ------------------------------------------------------ */
    /* Adaptive Server has expanded all '*' elements in the following statement */
    CREATE TEMPORARY TABLE t$ward_info
    AS
    SELECT
        ungrouped_query.Hospital_code, ungrouped_query.Ward_code, Description, Treatment_location, Location, Active_status, Effective_date, User_define, Care_category, Default_specialty, Wristband_no
        FROM (SELECT
            Hospital_code, Ward_code, Description, Treatment_location, Location, Active_status, Effective_date, User_define, Care_category, Default_specialty, Wristband_no
            FROM Ward) AS ungrouped_query
        INNER JOIN (SELECT
            Hospital_code, Ward_code, MAX(Effective_date) AS max_1
            FROM Ward as w
            WHERE Effective_date <= localtimestamp
            GROUP BY Hospital_code, Ward_code) AS grouped_query
        ON (ungrouped_query.Hospital_code = grouped_query.Hospital_code OR (ungrouped_query.Hospital_code IS NULL AND grouped_query.Hospital_code IS NULL))
        WHERE Effective_date = max_1;
    /* --and Active_status='A' */
    /* -------------------------------- */
    /* Adaptive Server has expanded all '*' elements in the following statement */
    CREATE TEMPORARY TABLE t$spec_info
    AS
    SELECT
        ungrouped_query.Hospital_code, ungrouped_query.Specialty_code, Description, Treatment_location, IMIS_code, From_age, To_age, Sex, Security_count, Active_status, Effective_date, User_define, Treatment_flag
        FROM (SELECT
            Specialty.Hospital_code, Specialty.Specialty_code, Specialty.Description, Specialty.Treatment_location, Specialty.IMIS_code, Specialty.From_age, Specialty.To_age, Specialty.Sex, Specialty.Security_count, Specialty.Active_status, Specialty.Effective_date, Specialty.User_define, Specialty.Treatment_flag
            FROM Specialty) AS ungrouped_query
        INNER JOIN (SELECT
            Hospital_code, Specialty_code, MAX(Effective_date) AS max_1
            FROM Specialty
            WHERE Effective_date <= localtimestamp
            GROUP BY Hospital_code, Specialty_code) AS grouped_query
            ON (ungrouped_query.Hospital_code = grouped_query.Hospital_code OR (ungrouped_query.Hospital_code IS NULL AND grouped_query.Hospital_code IS NULL))
        WHERE Effective_date = max_1;
    /* --and Active_status ='A' */
    /* ----------------------------------------------------------- */
    /* --- 3). update bed_alloc ward/spec occupied count from Ward_list   -- */
    
    /* ------------------------------------------------------------------------------------ */
    /* -------------------------------------------- */
    SELECT
        NULL, NULL, NULL, NULL
        INTO var_case_no, var_ward_code, var_bed_no, var_spec_code;
    OPEN ward_list_csr;
    FETCH ward_list_csr INTO var_case_no, var_ward_code, var_bed_no, var_spec_code;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        IF NOT EXISTS (SELECT
            1
            FROM t$bed_alloc
            WHERE hosp_code = var_local_hosp AND ward_code = var_ward_code AND spec_code = var_spec_code) THEN
            BEGIN
                INSERT INTO t$bed_alloc (hosp_code, ward_code, spec_code, off_bed, day_bed)
                VALUES (var_local_hosp, var_ward_code, var_spec_code, 0, 0);
            END;
        END IF;
        UPDATE t$bed_alloc
        SET ward_occ = COALESCE(ward_occ, 0) + 1, spec_occ = COALESCE(spec_occ, 0) + 1
            WHERE hosp_code = var_local_hosp AND ward_code = var_ward_code AND spec_code = var_spec_code;
        SELECT
            NULL, NULL, NULL, NULL
            INTO var_case_no, var_ward_code, var_bed_no, var_spec_code;
        FETCH ward_list_csr INTO var_case_no, var_ward_code, var_bed_no, var_spec_code;
    END LOOP;
    CLOSE ward_list_csr;
    /* ----------------------------------------------------------- */
    /* --- 4). update bed_alloc info   -- */
    
    /* ----------------------------------------------------------- */
    UPDATE t$bed_alloc AS b
    SET ward_loc = w.Location, ward_treatment_loc = w.Treatment_location, ward_care_cat = w.Care_category
    FROM t$ward_info AS w
        WHERE b.hosp_code = w.Hospital_code AND b.ward_code = w.Ward_code;
    /* --------------------------- */
    UPDATE t$bed_alloc AS b
    SET spec_imis_code = s.IMIS_code, spec_treatment_loc = s.Treatment_location, spec_sex = s.Sex
    FROM t$spec_info AS s
        WHERE b.hosp_code = s.Hospital_code AND b.spec_code = s.Specialty_code;
    /* --------------------------- */
    UPDATE t$bed_alloc AS b
    SET spec_eis_code = s.EIS_code
    FROM IMIS AS s
        WHERE b.spec_imis_code = s.IMIS_code;
    /* ------------------------------------------------------------------------------------ */
    /*
    [3017 - Severity CRITICAL - PostgreSQL doesn't support the SET NOCOUNT. If need try another way to send message back to the client application.]
    set nocount on
    */
    UPDATE t$bed_alloc
    SET ward_occ = 0
        WHERE ward_occ IS NULL;
    UPDATE t$bed_alloc
    SET spec_occ = 0
        WHERE spec_occ IS NULL;
    /* ------------------------------- */
    /* --select * from #bed_alloc where ward_treatment_loc in ('ICU','HDU') */
    /* --order by hosp_code,ward_code,spec_code */
    /* --------------------------------------------------------------- */
    /* ---select * into tempdb_support..temp_bed_alloc from #bed_alloc  ----  where ward_treatment_loc in ('ICU','HDU')  or  ward_code in ('1024','B6','B6HH','D6','G9H') */
    
    /* -----Gen Result 1: by Ward Treatment Location --- */
    
    /*
    [3017 - Severity CRITICAL - PostgreSQL doesn't support the SET NOCOUNT. If need try another way to send message back to the client application.]
    set nocount on
    */
    
    /* --select A). Bed Occupancy Rate by <Ward Treatment Loc>  */
    
    select var_rpt_dtm_str as "Report Date/Time", hosp_code as "Hospital", ward_treatment_loc as "Treatment Loc", sum(off_bed) as "Official Bed", sum(ward_occ) as "Number of Patient", (SUM(ward_occ)::float / NULLIF(SUM(off_bed), 0)::float * 100)::decimal(6,2) as "Occupancy Rate"
    from t$bed_alloc
    group by hosp_code,ward_treatment_loc
    order by ward_treatment_loc;

    /* --select B). Bed Occupancy Rate by <EIS Specialty>  */

    select var_rpt_dtm_str as "Report Date/Time", hosp_code as "Hospital", spec_imis_code as "Specialty", sum(off_bed) as "Official Bed", sum(spec_occ) as "Number of Patient" ,(SUM(ward_occ)::float / NULLIF(SUM(off_bed), 0)::float * 100)::decimal(6,2) as "Occupancy Rate"
    from t$bed_alloc
    group by hosp_code,spec_imis_code
    order by spec_imis_code;

    
    DROP TABLE IF EXISTS t$bed_alloc;
    DROP TABLE IF EXISTS t$ward_info;
    DROP TABLE IF EXISTS t$spec_info;

END;
$function$
;

;ALTER FUNCTION "pas_erpt_bed_occ" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
