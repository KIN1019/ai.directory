-- DROP PROCEDURE hkpmi.hkpmi_r_pmi_result_1_outparm(inout int4, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout timestamp, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout int4, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout timestamp, inout bpchar, inout bpchar, inout bpchar, inout int4, inout bpchar, inout bpchar, inout bpchar, inout bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_r_pmi_result_1_outparm(INOUT pas_return_code integer, IN par_hkid varchar, IN par_hosp_code varchar, IN par_local_saved varchar, IN par_source_system varchar, IN par_update_by varchar, INOUT par_return_patient_name varchar, INOUT par_return_sex varchar, INOUT par_return_cccode1 varchar, INOUT par_return_cccode2 varchar, INOUT par_return_cccode3 varchar, INOUT par_return_cccode4 varchar, INOUT par_return_cccode5 varchar, INOUT par_return_cccode6 varchar, INOUT par_return_dob timestamp without time zone, INOUT par_return_exact_dob_flag varchar, INOUT par_return_marital_status varchar, INOUT par_return_race varchar, INOUT par_return_other_doc_no varchar, INOUT par_return_mrn varchar, INOUT par_return_building varchar, INOUT par_return_room varchar, INOUT par_return_floor varchar, INOUT par_return_block varchar, INOUT par_return_district varchar, INOUT par_return_religion varchar, INOUT par_return_home_phone varchar, INOUT par_return_death_indicator varchar, INOUT par_return_patient_key varchar, INOUT par_return_nok_name varchar, INOUT par_return_nok_hkid varchar, INOUT par_return_nok_building varchar, INOUT par_return_nok_room varchar, INOUT par_return_nok_floor varchar, INOUT par_return_nok_block varchar, INOUT par_return_nok_district varchar, INOUT par_return_nok_home_phone varchar, INOUT par_return_nok_other_phone varchar, INOUT par_return_nok_other_phone_ext varchar, INOUT par_return_nok_relationship varchar, INOUT par_return_access_code integer, INOUT par_return_chi_name varchar, INOUT par_return_office_phone varchar, INOUT par_return_office_phone_ext varchar, INOUT par_return_other_phone varchar, INOUT par_return_other_phone_ext varchar, INOUT par_return_death_date timestamp without time zone, INOUT par_return_death_diagnosis varchar, INOUT par_return_death_external_cause varchar, INOUT par_return_patient_type varchar, INOUT par_return_pcs_count integer, INOUT par_return_nok_office_phone varchar, INOUT par_return_nok_office_phone_ext varchar, INOUT par_return_death_source_ind varchar, INOUT par_return_hkic_symbol varchar DEFAULT NULL::varchar)
 LANGUAGE plpgsql
AS $procedure$
/* GL 19981113 */
DECLARE
    var_death_ind varchar(1);
    var_row_count INTEGER;
    var_return_code INTEGER;
    sql$rowcount BIGINT;
BEGIN
    /*
    GL 19981201, add checking to avoid OPAS/OPAS2 directly update
    patient_detail_1
    */
    /* 20180305 -- to replace temp_hkpmi_r_pmi_result_1 (Local ops_get_hkpmi RPC .temp_hkpmi_r_pmi_result_1(QMH/UCH)/hkpmi..hkpmi_r_pmi_result_1 (other Hospitals) */
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
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_r_pmi_result_1_outparm" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

