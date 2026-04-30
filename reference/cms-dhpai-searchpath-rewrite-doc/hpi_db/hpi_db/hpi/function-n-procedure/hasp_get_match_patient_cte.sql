-- DROP FUNCTION hpi.hasp_get_match_patient_cte(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hpi.hasp_get_match_patient_cte(par_hosp_code character varying, par_from_date timestamp without time zone, par_to_date timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
	p_refcur refcursor;
    adjusted_to_date TIMESTAMP := par_to_date + INTERVAL '1 day';
BEGIN
	
	OPEN p_refcur FOR
	WITH 
    -- 1. Get the initial patient dataset
    initial_patients AS (
        SELECT	DISTINCT 
            p.HKID, p.Name, p.DOB, p.Sex, p.Room, p.Floor, p.Block, 
            p.Building, p.District_code, p.phone1
        FROM 
            Transaction_log t
            JOIN cpi_case c ON c.case_no = t.Case_no
            JOIN cpi_active_case a ON a.case_no = c.case_no 
                AND a.hospital_code = c.hospital_code
            JOIN PMI_wo_MRN p ON c.patient_key = p.T_PRK
        WHERE 
            p.HKID LIKE 'U%' 
            AND t.Transaction_datetime >= par_from_date
            AND t.Transaction_datetime < adjusted_to_date
            AND t.Hospital_code = par_hosp_code 
            AND c.hospital_code = par_hosp_code 
            AND c.status_code <> 'CC'
    ),

    -- 2. Address translation processing
    address_transformations AS (
        SELECT 
            ip.*,
            CASE WHEN ip.Building IS NOT NULL AND SUBSTRING(ip.Building, 1, 7) = 'HACODE:'
                 THEN CAST (RIGHT(RTRIM(ip.Building), LENGTH(RTRIM(ip.Building)) - 7) AS INTEGER)
                 ELSE NULL 
            END AS address_id
        FROM initial_patients ip
    ),
    
    -- 3. Getting the formatted address
    address_details AS (
        SELECT 
            at.*,
            CASE WHEN at.address_id IS NOT NULL THEN
                (SELECT 
                	COALESCE(RTRIM(a.bldg_eng) || CASE WHEN a.estate_eng IS NOT NULL OR a.street_eng IS NOT NULL THEN ', ' ELSE '' END,'') ||
           			COALESCE(RTRIM(a.estate_eng) || CASE WHEN a.street_eng IS NOT NULL THEN ', ' ELSE '' END, '') ||
           			COALESCE(RTRIM(a.house_no) || ' ', '') || COALESCE(RTRIM(a.street_eng), '')
                FROM hpi.address_detail a
                WHERE a.record_id = at.address_id)
            ELSE at.Building
            END AS formatted_address
        FROM address_transformations at
    ),
    
    -- 4. Initial data after processing
    processed_initial AS (
        SELECT 
            ad.HKID, ad.Name, ad.DOB, ad.Sex, ad.Room, ad.Floor, ad.Block,
            ad.formatted_address AS Building,
            ad.District_code, ad.phone1
        FROM address_details ad
    ),
    
    -- 5. Get the matched patient data
    matched_patients AS (
        SELECT 
            pi.HKID, pi.Name, pi.Sex, pi.DOB, pi.Room, pi.Floor, pi.Block,
            pi.Building, pi.District_code, pi.phone1,
            m.HKID AS Match_HKID, m.Room AS Match_room, m.Floor AS Match_floor,
            m.Block AS Match_block,
            -- Format the address of the matching record
            CASE WHEN m.Building LIKE 'HACODE:%' THEN
                (SELECT TRIM(
                    COALESCE(RTRIM(a.bldg_eng) || CASE WHEN a.estate_eng IS NOT NULL OR a.street_eng IS NOT NULL THEN ', ' ELSE '' END,'') ||
           			COALESCE(RTRIM(a.estate_eng) || CASE WHEN a.street_eng IS NOT NULL THEN ', ' ELSE '' END, '') ||
           			COALESCE(RTRIM(a.house_no) || ' ', '') || COALESCE(RTRIM(a.street_eng), '')
                )
                FROM hpi.address_detail a
                WHERE a.record_id = CAST (RIGHT(RTRIM(m.Building), LENGTH(RTRIM(m.Building)) - 7) AS INTEGER))
            ELSE m.Building
            END AS Match_building,
            m.District_code AS Match_district_code,
            m.phone1 AS Match_phone1
        FROM processed_initial pi
        JOIN PMI_wo_MRN m ON 
        	m.Name = pi.Name 
          AND m.Sex = pi.Sex 
          AND (m.DOB = pi.DOB OR (pi.DOB IS NULL AND m.DOB IS NULL))
          AND m.HKID != pi.HKID
        WHERE EXISTS (
            SELECT 1 FROM PMI_wo_MRN pwr
            WHERE pwr.Name = pi.Name 
              AND pwr.Sex = pi.Sex 
              AND (pwr.DOB = pi.DOB OR (pi.DOB IS NULL ))
              AND pwr.HKID != pi.HKID
        )
    )       
   SELECT 
        mp.HKID, mp.Name, mp.Sex, mp.DOB, mp.Room, mp.Floor, mp.Block, mp.Building,
        mp.District_code, mp.phone1, mp.Match_HKID, mp.Match_room, mp.Match_floor,
        mp.Match_block, mp.Match_building, mp.Match_district_code, mp.Match_phone1
    FROM matched_patients mp
    ORDER BY mp.HKID, mp.Match_HKID;
	
   	return next p_refcur;
END;
$function$
;

;ALTER FUNCTION "hasp_get_match_patient_cte" OWNER TO "HPI_SCHEMA_OWNER_ROLE";