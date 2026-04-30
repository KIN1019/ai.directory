-- DROP FUNCTION hkpmi_r_pmi_result_1(varchar, varchar, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi_r_pmi_result_1(par_hkid character varying, par_hosp_code character varying, par_local_saved character varying, par_source_system character varying, par_update_by character varying)
 RETURNS TABLE(patient_name character varying, sex character varying, cccode1 character varying, cccode2 character varying, cccode3 character varying, cccode4 character varying, cccode5 character varying, cccode6 character varying, dob timestamp without time zone, exact_dob_flag character varying, marital_status character varying, race character varying, other_doc_no character varying, mrn character varying, building character varying, room character varying, floor character varying, block character varying, district character varying, religion character varying, phone1 character varying, death_indicator character varying, patient_key character varying, nok_name character varying, hkid character varying, building_1 character varying, room_1 character varying, floor_1 character varying, block_1 character varying, district_1 character varying, phone1_1 character varying, mobile_phone character varying, sms_language character varying, relationship character varying, access_code integer, chi_name character varying, phone2 character varying, address_indicator character varying, mobile_phone_1 character varying, sms_language_1 character varying, death_date timestamp without time zone, death_diagnosis character varying, death_external_cause character varying, patient_type character varying, pcs_count integer, phone2_1 character varying, address_indicator_1 character varying, death_source_ind character varying, hkic_symbol text)
 LANGUAGE plpgsql
AS $function$
/* GL 19981113 */
DECLARE
    var_death_ind VARCHAR(1);
    var_row_count INTEGER;
    var_return_code INTEGER;
    var_phonetic VARCHAR(48);
    var_ccc1 VARCHAR(5);
    var_ccc2 VARCHAR(5);
    var_ccc3 VARCHAR(5);
    var_ccc4 VARCHAR(5);
    var_ccc5 VARCHAR(5);
    var_ccc6 VARCHAR(5);
    var_chi_name VARCHAR(12);
    sql$rowcount BIGINT;
	p_refcur refcursor;
begin
	SET LOCAL search_path TO hkpmi,public; 
	 
	drop TABLE if EXISTS t$result;
	CREATE TEMPORARY TABLE t$result(patient_name varchar,sex varchar,cccode1 VARCHAR,cccode2 VARCHAR,cccode3 VARCHAR,cccode4 VARCHAR,cccode5 VARCHAR,cccode6 VARCHAR,dob timestamp,exact_dob_flag VARCHAR,marital_status VARCHAR,race VARCHAR,other_doc_no VARCHAR,mrn VARCHAR,building VARCHAR,room VARCHAR,floor VARCHAR,block VARCHAR,district VARCHAR,religion VARCHAR,phone1 VARCHAR,death_indicator VARCHAR,patient_key VARCHAR,nok_name VARCHAR,hkid VARCHAR,building_1 VARCHAR,room_1 VARCHAR,floor_1 VARCHAR,block_1 VARCHAR,district_1 VARCHAR,phone1_1 VARCHAR,mobile_phone VARCHAR,sms_language VARCHAR,relationship VARCHAR,access_code int,chi_name VARCHAR,phone2 VARCHAR,address_indicator VARCHAR,mobile_phone_1 VARCHAR,sms_language_1 VARCHAR,death_date timestamp,death_diagnosis VARCHAR,death_external_cause VARCHAR,patient_type VARCHAR,pcs_count int,phone2_1 VARCHAR,address_indicator_1 VARCHAR,death_source_ind VARCHAR,hkic_symbol text
	);
	
	
    /* 2007-01-10 Added by HK Fong SMR20015696 - Start */
    /* 2007-01-10 Added by HK Fong SMR20015696 - End */
    /*
    GL 19981201, add checking to avoid OPAS/OPAS2 directly update
    patient_detail_1
    */
	
    IF par_local_saved = 'Y' AND par_source_system LIKE 'OPAS%' THEN
        BEGIN
            RAISE EXCEPTION USING ERRCODE := '200170';
            return QUERY select * from t$result;
           
        END;
    END IF;
    SELECT
        'Y'
        INTO var_death_ind
        FROM patient as p
        WHERE p.hkid = par_hkid AND p.death_indicator IS NOT NULL;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount = 0 THEN
        SELECT
            NULL
            INTO var_death_ind;
    END IF;
    /* 2007-01-10 Added by HK Fong SMR20015696 - Start */
    SELECT
        p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6
        INTO var_ccc1, var_ccc2, var_ccc3, var_ccc4, var_ccc5, var_ccc6
        FROM patient as p
        WHERE p.hkid = par_hkid;
    /* Get chinese name from ccc_unicode table */
    CALL cpi_get_phonetic_chin_name(var_return_code, var_ccc1, var_ccc2, var_ccc3, var_ccc4, var_ccc5, var_ccc6, var_phonetic, var_chi_name);
    /* 2007-01-10 Added by HK Fong SMR20015696 - End */
	
   	

   	insert into t$result
    SELECT
        p.patient_name, p.sex,
        /* 2007-01-10 Added by HK Fong SMR20015696 - Start */
        /*
        P.cccode1, P.cccode2, P.cccode3,
        P.cccode4, P.cccode5, P.cccode6,
        */
        var_ccc1 AS cccode1, var_ccc2 AS cccode2, var_ccc3 AS cccode3, var_ccc4 AS cccode4, var_ccc5 AS cccode5, var_ccc6 AS cccode6,
        /* 2007-01-10 Added by HK Fong SMR20015696 - End */
        /* convert(char(8), P.dob,112) dob, */
        p.dob, p.exact_dob_flag, p.marital_status, p.race, p.other_doc_no, m.mrn, p.building, p.room, p.floor, p.block, p.district, p.religion, p.phone1,
        /* P.death_indicator, */
        var_death_ind AS death_indicator, p.patient_key, n.nok_name, n.hkid, n.building as building_1, n.room as room_1, n.floor as floor_1, n.block as block_1, n.district as district_1, n.phone1 as phone1_1, n.mobile_phone, n.sms_language, n.relationship,
        /* convert(char(10), P.access_code) access_code, */
        p.access_code,
        /* 2007-01-10 Added by HK Fong SMR20015696 - Start */
        /* P.chi_name, */
        var_chi_name AS chi_name,
        /* 2007-01-10 Added by HK Fong SMR20015696 - End */
        p.phone2, p.address_indicator, p.mobile_phone as mobile_phone_1, p.sms_language as sms_language_1, p.death_date, p.death_diagnosis, p.death_external_cause, p.patient_type, p.pcs_count, n.phone2 as phone2_1, n.address_indicator as address_indicator_1,
        /* GL 19981113 */
        p.death_indicator AS death_source_ind, SUBSTRING(p.filler, 3, 1) AS hkic_symbol
        /* --from nok N, patient P, patient_hospital_data M */
        FROM patient AS p  --+ index(XPKpatient_hospital_data) 
        LEFT OUTER JOIN patient_hospital_data AS m
            ON (p.patient_key = m.patient_key AND m.hospital_code = par_hosp_code)
        LEFT OUTER JOIN nok AS n
            ON (p.patient_key = n.patient_key)
        WHERE p.hkid = par_hkid;
    /* GL 19981113, set this hospital on for this patient */
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
    var_row_count := sql$rowcount;

    IF var_row_count = 1 AND par_local_saved = 'Y' THEN
        BEGIN
            IF par_hosp_code IS NULL OR par_source_system IS NULL THEN
                BEGIN
                    RAISE EXCEPTION USING ERRCODE := '200162';
                    return QUERY select * from t$result;
                    
                END;
            END IF;
           raise notice 'hkpmi_set_on_patient_hosp:%,%,%,%,%',var_return_code, par_hkid, par_hosp_code, par_update_by, par_source_system;
            CALL hkpmi_set_on_patient_hosp(var_return_code, par_hkid, par_hosp_code, par_update_by, par_source_system);


            IF var_return_code != 0 THEN
                BEGIN
                    IF var_return_code > 200000 THEN
                        RAISE EXCEPTION USING ERRCODE := var_return_code;
                    ELSE
                        RAISE EXCEPTION USING ERRCODE := '200158';
                    END IF;
                END;
            END IF;
        END;
    END IF;

   	RESET search_path;
   	return QUERY select * from t$result;
 
END;
$function$
;

ALTER FUNCTION "hkpmi_r_pmi_result_1" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";