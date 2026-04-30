-- DROP FUNCTION hkpmi.hkpmi_aeis_disaster(bpchar, bpchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_aeis_disaster(par_hosp_code varchar, par_case_no varchar)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_district_area VARCHAR(2);
    var_patient_key VARCHAR(16);
    var_hkid VARCHAR(24);
    var_name VARCHAR(96);
    var_sex VARCHAR(1);
    var_ccc1 VARCHAR(10);
    var_ccc2 VARCHAR(10);
    var_ccc3 VARCHAR(10);
    var_ccc4 VARCHAR(10);
    var_ccc5 VARCHAR(10);
    var_ccc6 VARCHAR(10);
    var_dob_char VARCHAR(16);
    var_home_phone VARCHAR(20);
    var_building VARCHAR(94);
    var_room VARCHAR(10);
    var_floor VARCHAR(4);
    var_block VARCHAR(4);
    var_district VARCHAR(10);
    var_address VARCHAR(124);
BEGIN
    /* * get patient key * */
    SELECT
        patient_key
        INTO var_patient_key
        FROM pmi_case
        WHERE case_no = par_case_no AND hospital_code = par_hosp_code;
    /* * get patient demo * */
    SELECT
        hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, to_char(dob::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), building, room, floor, block, district, phone1
        INTO var_hkid, var_name, var_sex, var_ccc1, var_ccc2, var_ccc3, var_ccc4, var_ccc5, var_ccc6, var_dob_char, var_building, var_room, var_floor, var_block, var_district, var_home_phone
        FROM patient
        WHERE patient_key = var_patient_key;
    /* * get district area * */
    SELECT
        district_area
        INTO var_district_area
        FROM district
        WHERE district_code = var_district;
    /* * get address * */
    SELECT
        CONCAT(SUBSTRING(CONCAT(var_building, REPEAT(' ', 47)), 1, 37), SUBSTRING(CONCAT(var_district, REPEAT(' ', 5)), 1, 5), SUBSTRING(CONCAT(var_building, REPEAT(' ', 47)), 38, 10), SUBSTRING(CONCAT(var_district_area, REPEAT(' ', 1)), 1, 1), SUBSTRING(CONCAT(var_room, REPEAT(' ', 5)), 1, 5), SUBSTRING(CONCAT(var_floor, REPEAT(' ', 2)), 1, 2), SUBSTRING(CONCAT(var_block, REPEAT(' ', 2)), 1, 2))
        INTO var_address;
    /* * select cases * */
    OPEN p_refcur FOR
    SELECT
        var_hkid AS hkid, var_patient_key AS patient_key, var_name AS name, var_sex AS sex, var_dob_char AS dob, var_ccc1 AS cccode1, var_ccc2 AS cccode2, var_ccc3 AS cccode3, var_ccc4 AS cccode4, var_ccc5 AS cccode5, var_ccc6 AS cccode6, var_home_phone AS home_phone, var_address AS addr, hospital_code, case_no, to_char(adm_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') AS adm_date, 
        to_char(adm_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24MI') AS adm_time, 
        source_indicator, source_code, to_char(discharge_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') AS disc_date,
        to_char(discharge_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24MI') AS disc_time,
        discharge_code, destination_code, last_ward_code, last_specialty_code
        FROM pmi_case
        WHERE patient_key = var_patient_key;
	return next p_refcur;
END;
$function$
;


ALTER FUNCTION "hkpmi_aeis_disaster" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

