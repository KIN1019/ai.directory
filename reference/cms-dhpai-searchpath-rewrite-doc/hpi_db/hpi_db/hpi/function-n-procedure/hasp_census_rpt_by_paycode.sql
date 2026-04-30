-- DROP FUNCTION hasp_census_rpt_by_paycode(varchar, varchar);

CREATE OR REPLACE FUNCTION hasp_census_rpt_by_paycode(par_hosp_code character varying, par_paycode character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
	p_refcur refcursor;
/* add hosp code for HPI by ML on 27.07.1999 */
BEGIN
	/* create temp table for census report */
	DROP TABLE IF EXISTS t$census_table;
	CREATE TEMPORARY TABLE t$census_table
	(ward_code VARCHAR(8) NOT NULL,
		spec_code VARCHAR(8) NOT NULL,
		case_no VARCHAR(24) NOT NULL,
		hkid VARCHAR(24) NOT NULL,
		paycode VARCHAR(6) NULL,
		adm_dtime TIMESTAMP WITHOUT TIME ZONE);
	INSERT INTO t$census_table (ward_code, spec_code, case_no, hkid, paycode, adm_dtime)
	SELECT
		w.Ward_code, w.Specialty_code, w.Case_no, c.HKID, c.Pay_code, c.Admission_datetime
		FROM Ward_list AS w, Case_view AS c
		WHERE c.Case_no = w.Case_no AND c.Pay_code LIKE par_paycode AND c.Hospital_code = par_hosp_code AND w.Hospital_code = par_hosp_code;
	DROP TABLE IF EXISTS t$census_rst_table;
	CREATE TEMPORARY TABLE t$census_rst_table
	(ward_cde VARCHAR(8) NOT NULL,
		spec_cde VARCHAR(8) NOT NULL,
		case_no VARCHAR(24) NOT NULL,
		name VARCHAR(96) NULL,
		hkid VARCHAR(24) NOT NULL,
		sex VARCHAR(2) NOT NULL,
		dob VARCHAR(24) NULL,
		paycde VARCHAR(6) NOT NULL,
		room VARCHAR(10) NULL,
		floor VARCHAR(4) NULL,
		bldg VARCHAR(94) NULL,
		block VARCHAR(4) NULL,
		district VARCHAR(30) NULL,
		adm_datet TIMESTAMP WITHOUT TIME ZONE,
		case_year VARCHAR(8) NULL);
	INSERT INTO t$census_rst_table
	SELECT
		ct.ward_code, ct.spec_code, ct.case_no, pmi.Name, ct.hkid, pmi.Sex,
		/* pmi.DOB, */
		TO_CHAR(pmi.DOB, 'DD/MM/YYYY'), ct.paycode,
		/* Room++ pmi.Room+  +pmi.Floor+/F+ +  Block++pmi.Block, */
		pmi.Room, pmi.Floor, pmi.Building, pmi.Block, pmi.District_code, ct.adm_dtime, NULL
		FROM PMI_wo_MRN AS pmi, t$census_table AS ct
		WHERE ct.hkid = pmi.HKID;
	/* modified for HPI by ML on 27.07.1999 */
	/* --from PMI pmi,#census_table ct */
	/* --where ct.hkid = pmi.HKID */
	/* update unknown dob to ? */
	UPDATE t$census_rst_table
	SET dob = '?'
		WHERE dob is NULL;
	/* update district code to district name */
	UPDATE t$census_rst_table
	SET district = District.District_name
	FROM District
		WHERE District.District_code = t$census_rst_table.district;
	UPDATE t$census_rst_table
	SET case_year = CONCAT('19', SUBSTRING(case_no, 4, 2))
		WHERE SUBSTRING(case_no, 4, 2) > '80';
	UPDATE t$census_rst_table
	SET case_year = CONCAT('20', SUBSTRING(case_no, 4, 2))
		WHERE SUBSTRING(case_no, 4, 2) <= '80';
	/* select * from #census_rst_table */
	/* order by paycde,ward_cde,spec_cde,case_no */
	OPEN p_refcur FOR
	SELECT
		ward_cde, spec_cde, case_no, name, hkid, sex, dob, paycde, room, floor, bldg, block, district, adm_datet
		FROM t$census_rst_table
		ORDER BY paycde NULLS FIRST, ward_cde NULLS FIRST, spec_cde NULLS FIRST, case_year NULLS FIRST, case_no NULLS FIRST;
	return next p_refcur;
END;
$function$
;

;ALTER FUNCTION "hasp_census_rpt_by_paycode" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
