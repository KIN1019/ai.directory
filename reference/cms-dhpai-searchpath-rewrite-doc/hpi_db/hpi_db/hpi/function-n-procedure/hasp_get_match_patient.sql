-- DROP FUNCTION hpi.hasp_get_match_patient(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hpi.hasp_get_match_patient(par_hosp_code character varying, par_from_date timestamp without time zone, par_to_date timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/*
- Get the data of the other patient if the patient's name,
		sex and dob is identitical to the unknown id patient
    - Duplicate Patient Master Index Report
    - 27.07.1999 Add hosp code for HPI by Mabel LAU
*/

DECLARE
    p_refcur refcursor;
    var_addr_eng VARCHAR(255);
    var_addr_chi VARCHAR(255);
    var_addr_code INTEGER;
    var_addr_dist VARCHAR(5);
    var_return_code INTEGER;
    var_addr_eh_eng VARCHAR(255);
    var_addr_eh_chi VARCHAR(255);
    cura CURSOR FOR
		SELECT DISTINCT
		    HKID, Name, DOB, Sex, Room, Floor, Block, Building, District_code, phone1
		FROM t$abc;
	var_hkid VARCHAR(12);
    var_name VARCHAR(48);
    var_sex VARCHAR(1);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_room VARCHAR(5);
    var_floor VARCHAR(2);
    var_block VARCHAR(2);
    var_building VARCHAR(255);
    var_district_code VARCHAR(5);
    var_phone1 VARCHAR(10);
    var_rowcount INTEGER;
    var_match_hkid VARCHAR(12);
    var_match_room VARCHAR(5);
    var_match_floor VARCHAR(2);
    var_match_block VARCHAR(2);
    var_match_building VARCHAR(255);
    var_match_district_code VARCHAR(5);
    var_match_phone1 VARCHAR(10);
    csr CURSOR FOR
		SELECT
		    Match_building
		FROM t$demo_match
		WHERE Match_building LIKE 'HACODE:%';

BEGIN
	SELECT
	    1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
	INTO par_to_date;

	SELECT
	    0
	INTO var_return_code;

	drop table IF EXISTS t$demo_match;
	CREATE TEMPORARY TABLE t$demo_match
	    (HKID VARCHAR(12) NULL,
	        Name VARCHAR(48) NULL,
	        Sex VARCHAR(1) NULL,
	        DOB TIMESTAMP WITHOUT TIME ZONE NULL,
	        Room VARCHAR(5) NULL,
	        Floor VARCHAR(2) NULL,
	        Block VARCHAR(2) NULL,
	        /* --		  Building VARCHAR(47) null, */
	        Building VARCHAR(255) NULL,
	        District_code VARCHAR(5) NULL,
	        phone1 VARCHAR(10) NULL,
	        Match_HKID VARCHAR(12),
	        Match_room VARCHAR(5) NULL,
	        Match_floor VARCHAR(2) NULL,
	        Match_block VARCHAR(2) NULL,
	        /* --		  Match_building VARCHAR(47) null, */
	        Match_building VARCHAR(255) NULL,
	        Match_district_code VARCHAR(5) NULL,
	        Match_phone1 VARCHAR(10) NULL);
	CREATE UNIQUE INDEX demo_index ON t$demo_match
	    (HKID, Match_HKID);
	/* add hosp code for HPI on 27.07.1999 & */
	/* change to use PMI_wo_MRN instead of PMI by ML */
	/* add index for selection */
	/* change Case_view to cpi_case as wrong index are used */
	
	drop table IF EXISTS t$abc;
	CREATE TEMPORARY TABLE t$abc
	    AS
	SELECT
	    p.HKID, p.Name, p.DOB, p.Sex, p.Room, p.Floor, p.Block, p.Building, p.District_code, p.phone1
	/* --from Transaction_log t,Case_view c,PMI p */
	FROM Transaction_log AS t, cpi_case AS c, cpi_active_case AS a, PMI_wo_MRN AS p
	WHERE c.case_no = t.Case_no AND p.HKID LIKE 'U%' AND c.patient_key = p.T_PRK AND t.Transaction_datetime >= par_from_date AND t.Transaction_datetime < par_to_date 
		AND t.Hospital_code = par_hosp_code AND c.hospital_code = par_hosp_code AND a.hospital_code = par_hosp_code AND a.case_no = c.case_no AND c.status_code <> 'CC';


	OPEN cura;
	/* --		  declare @building VARCHAR(47),@district_code VARCHAR(5),@phone1 VARCHAR(10) */
	/* --		  declare @match_building VARCHAR(47),@match_district_code VARCHAR(5),@match_phone1 VARCHAR(10) */
	FETCH cura INTO var_hkid, var_name, var_dob, var_sex, var_room, var_floor, var_block, var_building, var_district_code, var_phone1;
	
	WHILE (CASE
	        WHEN FOUND THEN 0
	        WHEN NOT FOUND THEN 2
	        ELSE 1
	    END) = 0 LOOP
	        /* modified to use PMI_wo_MRN for HPI by ML on 27.07.199 */
		SELECT
		    COUNT(*)
		INTO var_rowcount
		/* --from PMI */
		FROM PMI_wo_MRN
		WHERE Name = var_name AND Sex = var_sex AND (DOB = var_dob or(var_dob is null)) AND HKID != var_hkid;

		IF var_rowcount > 0 then
			raise notice 'var_rowcount = % ,var_hkid = % , var_dob = %',var_rowcount,var_hkid, var_dob;
			BEGIN
		        /* added for format Address Code */
		        IF var_building IS NOT NULL THEN
					BEGIN
		                IF SUBSTRING(var_building, 1, 7) = 'HACODE:' THEN
							BEGIN
								SELECT
								    CAST (RIGHT(RTRIM(var_building), LENGTH(RTRIM(var_building)) - 7) AS INTEGER)
								INTO var_addr_code;
							
--								RAISE NOTICE 'var_addr_code => %',var_addr_code;
								CALL hasp_get_address_detail(var_return_code, var_addr_code, var_addr_eng, var_addr_chi, var_addr_dist, var_addr_eh_eng, var_addr_eh_chi);
								
								IF var_return_code = 0 AND var_addr_eng IS NOT NULL THEN
									SELECT
									    var_addr_eng
									INTO var_building;
								END IF;
							END;
						END IF;
					END;
				END IF;

				INSERT INTO t$demo_match (hkid, name, sex, dob, room, floor, block, building, district_code, phone1, match_hkid, match_room, match_floor, match_block, match_building, match_district_code, match_phone1)
				/* --select @hkid,@name,@sex,@dob,@room,@floor,@block,@building,@district_code,@phone1,HKID,Room,Floor,Block,Building,District_code,phone1 from PMI */
				/* modified to use PMI_wo_MRN for HPI by ML on 27.07.1999 */
				SELECT
				    var_hkid, var_name, var_sex, var_dob, var_room, var_floor, var_block, var_building, var_district_code, var_phone1, HKID, Room, Floor, Block, Building, District_code, phone1
				FROM PMI_wo_MRN
				WHERE Name = var_name AND Sex = var_sex AND (DOB = var_dob or(var_dob is null and dob is null)) AND HKID != var_hkid;
			END;
		END IF;
	
		FETCH cura INTO var_hkid, var_name, var_dob, var_sex, var_room, var_floor, var_block, var_building, var_district_code, var_phone1;
	END LOOP;

	OPEN csr;
	FETCH csr INTO var_building;

	WHILE (CASE
	        WHEN FOUND THEN 0
	        WHEN NOT FOUND THEN 2
	        ELSE 1
	    END) = 0 LOOP
		SELECT
		    CAST (RIGHT(RTRIM(var_building), LENGTH(RTRIM(var_building)) - 7) AS INTEGER)
		INTO var_addr_code;
	
		CALL hasp_get_address_detail(var_return_code, var_addr_code, var_addr_eng, var_addr_chi, var_addr_dist, var_addr_eh_eng, var_addr_eh_chi);
--			        RAISE NOTICE 'Updated Match_building % %', var_return_code, var_addr_eng;

		IF var_return_code = 0 AND var_addr_eng IS NOT NULL THEN
			UPDATE t$demo_match
			SET Match_building = var_addr_eng
			WHERE CURRENT OF csr;
--			where Match_building = CONCAT('HACODE:', var_addr_code);
		END IF;

		FETCH csr INTO var_building;
	END LOOP;

	CLOSE csr;

	OPEN p_refcur FOR
	SELECT
	    t$demo_match.hkid, t$demo_match.name, t$demo_match.sex, t$demo_match.dob, t$demo_match.room, t$demo_match.floor, t$demo_match.block, t$demo_match.building, t$demo_match.district_code, t$demo_match.phone1, t$demo_match.match_hkid, t$demo_match.match_room, t$demo_match.match_floor, t$demo_match.match_block, t$demo_match.match_building, t$demo_match.match_district_code, t$demo_match.match_phone1
	FROM t$demo_match
	order by t$demo_match.hkid,t$demo_match.match_hkid;
	
	return next p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_get_match_patient" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
