-- DROP PROCEDURE hkpmi_r_pmi_result_1_outparm(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout int4, inout varchar, inout varchar, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi_r_pmi_result_1_outparm(INOUT pas_return_code integer, IN par_hkid character varying, IN par_hosp_code character varying, IN par_local_saved character varying, IN par_source_system character varying, IN par_update_by character varying, INOUT par_return_patient_name character varying, INOUT par_return_sex character varying, INOUT par_return_cccode1 character varying, INOUT par_return_cccode2 character varying, INOUT par_return_cccode3 character varying, INOUT par_return_cccode4 character varying, INOUT par_return_cccode5 character varying, INOUT par_return_cccode6 character varying, INOUT par_return_dob timestamp without time zone, INOUT par_return_exact_dob_flag character varying, INOUT par_return_marital_status character varying, INOUT par_return_race character varying, INOUT par_return_other_doc_no character varying, INOUT par_return_mrn character varying, INOUT par_return_building character varying, INOUT par_return_room character varying, INOUT par_return_floor character varying, INOUT par_return_block character varying, INOUT par_return_district character varying, INOUT par_return_religion character varying, INOUT par_return_home_phone character varying, INOUT par_return_death_indicator character varying, INOUT par_return_patient_key character varying, INOUT par_return_nok_name character varying, INOUT par_return_nok_hkid character varying, INOUT par_return_nok_building character varying, INOUT par_return_nok_room character varying, INOUT par_return_nok_floor character varying, INOUT par_return_nok_block character varying, INOUT par_return_nok_district character varying, INOUT par_return_nok_home_phone character varying, INOUT par_return_nok_other_phone character varying, INOUT par_return_nok_other_phone_ext character varying, INOUT par_return_nok_relationship character varying, INOUT par_return_access_code integer, INOUT par_return_chi_name character varying, INOUT par_return_office_phone character varying, INOUT par_return_office_phone_ext character varying, INOUT par_return_other_phone character varying, INOUT par_return_other_phone_ext character varying, INOUT par_return_death_date timestamp without time zone, INOUT par_return_death_diagnosis character varying, INOUT par_return_death_external_cause character varying, INOUT par_return_patient_type character varying, INOUT par_return_pcs_count integer, INOUT par_return_nok_office_phone character varying, INOUT par_return_nok_office_phone_ext character varying, INOUT par_return_death_source_ind character varying, INOUT par_return_hkic_symbol character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* GL 19981113 */
DECLARE
    var_death_ind varchar(1);
    var_row_count INTEGER;
    var_return_code INTEGER;
    sql$rowcount BIGINT;
BEGIN
	SET LOCAL search_path TO hkpmi,public; 
    /*
    GL 19981201, add checking to avoid OPAS/OPAS2 directly update
    patient_detail_1
    */
    /* 20180305 -- to replace temp_hkpmi_r_pmi_result_1 (Local ops_get_hkpmi RPC .temp_hkpmi_r_pmi_result_1(QMH/UCH)/.hkpmi_r_pmi_result_1 (other Hospitals) */
    IF par_local_saved = 'Y' AND par_source_system LIKE 'OPAS%' THEN
        BEGIN
            RAISE EXCEPTION USING ERRCODE := '200170';
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    SELECT
        'Y'
        INTO var_death_ind
        FROM patient
        WHERE hkid = par_hkid AND death_indicator IS NOT NULL;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount = 0 THEN
        SELECT
            NULL
            INTO var_death_ind;
    END IF;
    SELECT
        p.patient_name, p.sex, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6, p.dob, p.exact_dob_flag, p.marital_status, p.race, p.other_doc_no, m.mrn, p.building, p.room, p.floor, p.block, p.district, p.religion, p.phone1, var_death_ind, p.patient_key, n.nok_name, n.hkid, n.building, n.room, n.floor, n.block, n.district, n.phone1, n.mobile_phone, n.sms_language, n.relationship, p.access_code, p.chi_name, p.phone2, p.address_indicator, p.mobile_phone, p.sms_language, p.death_date, p.death_diagnosis, p.death_external_cause, p.patient_type, p.pcs_count, n.phone2, n.address_indicator,
        /* GL 19981113 */
        p.death_indicator, SUBSTRING(p.filler, 3, 1)
        INTO par_return_patient_name, par_return_sex, par_return_cccode1, par_return_cccode2, par_return_cccode3, par_return_cccode4, par_return_cccode5, par_return_cccode6, par_return_dob, par_return_exact_dob_flag, par_return_marital_status, par_return_race, par_return_other_doc_no, par_return_mrn, par_return_building, par_return_room, par_return_floor, par_return_block, par_return_district, par_return_religion, par_return_home_phone, par_return_death_indicator, par_return_patient_key, par_return_nok_name, par_return_nok_hkid, par_return_nok_building, par_return_nok_room, par_return_nok_floor, par_return_nok_block, par_return_nok_district, par_return_nok_home_phone, par_return_nok_other_phone, par_return_nok_other_phone_ext, par_return_nok_relationship, par_return_access_code, par_return_chi_name, par_return_office_phone, par_return_office_phone_ext, par_return_other_phone, par_return_other_phone_ext, par_return_death_date, par_return_death_diagnosis, par_return_death_external_cause, par_return_patient_type, par_return_pcs_count, par_return_nok_office_phone, par_return_nok_office_phone_ext, par_return_death_source_ind, par_return_hkic_symbol /* --20100928 SL hkic */
        /* death_source_ind */
        FROM patient AS p
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
                    pas_return_code := 0;
                    RETURN;
                END;
            END IF;
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
    pas_return_code := 0;
   
   	RESET search_path;
    RETURN;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_r_pmi_result_1_outparm" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";