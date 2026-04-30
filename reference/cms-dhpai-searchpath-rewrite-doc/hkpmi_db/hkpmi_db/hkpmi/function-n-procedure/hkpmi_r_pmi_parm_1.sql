-- DROP PROCEDURE hkpmi.hkpmi_r_pmi_parm_1(inout int4, in bpchar, in varchar, in varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout int4, inout varchar, inout varchar, in varchar, in varchar, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_r_pmi_parm_1(INOUT pas_return_code integer, IN par_hosp_code character, IN par_hkid character varying, IN par_return_type character varying, INOUT par_patient_name character varying, INOUT par_sex character varying, INOUT par_ccc1 character varying, INOUT par_ccc2 character varying, INOUT par_ccc3 character varying, INOUT par_ccc4 character varying, INOUT par_ccc5 character varying, INOUT par_ccc6 character varying, INOUT par_dob timestamp without time zone, INOUT par_exact_dob_flag character varying, INOUT par_marital character varying, INOUT par_race character varying, INOUT par_other_doc_no character varying, INOUT par_mrn character varying, INOUT par_building character varying, INOUT par_room character varying, INOUT par_floor character varying, INOUT par_block character varying, INOUT par_district character varying, INOUT par_religion character varying, INOUT par_phone1 character varying, INOUT par_death_ind character varying, INOUT par_patient_key character varying, INOUT par_nok_name character varying, INOUT par_nok_hkid character varying, INOUT par_nok_building character varying, INOUT par_nok_room character varying, INOUT par_nok_floor character varying, INOUT par_nok_block character varying, INOUT par_nok_district character varying, INOUT par_nok_phone1 character varying, INOUT par_nok_mobile_phone character varying, INOUT par_nok_sms_language character varying, INOUT par_nok_relation character varying, INOUT par_access_code integer, INOUT par_chi_name character varying, INOUT par_phone2 character varying, INOUT par_address_indicator character varying, INOUT par_mobile_phone character varying, INOUT par_sms_language character varying, INOUT par_death_date timestamp without time zone, INOUT par_death_diagnosis character varying, INOUT par_death_external_cause character varying, INOUT par_patient_type character varying, INOUT par_pcs_count integer, INOUT par_nok_phone2 character varying, INOUT par_nok_address_indicator character varying, IN par_local_saved character varying, IN par_source_system character varying, IN par_update_by character varying, INOUT par_hkic_symbol character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* --			@dob	char(8) output, */
/* @patient_key	char(3) output, */
/* by Winnie LAU */ /* by Winnie LAU */
/* --			@access_code	char(10) output, */
/* 19981102 GL, new added fields to enrich demo details */
/* 19981102 GL, fields need to set patient_detail_1 on */
DECLARE
    var_temp_patient_key VARCHAR(8);
    var_rowcount INTEGER;
    var_return_code INTEGER;
    var_return_error_code INTEGER;
    var_begin_tran VARCHAR(01);
    var_phonetic VARCHAR(48);
    sql$rowcount BIGINT;

BEGIN
    <<return_error>>
    begin
	    set search_path to hkpmi,public;
        /* 2007-01-09 Added by HK Fong SMR20015696 - Start */
        /* 2007-01-09 Added by HK Fong SMR20015696 - End */
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
        	begin
           	begin tran
        		select @begin_tran = "Y"
        	end
        	else
        		select @begin_tran = "N"
        */
        /*
        GL 19981201, add checking to avoid OPAS/OPAS2 directly update
        patient_detail_1
        */
        /*
        comment by LEO 19990409 for opas to perform remote booking
        if @local_saved = 'Y' and @source_system like 'OPAS%'
        begin
           select @return_error_code = 200170
           goto return_error
        end
        */
        SELECT
            patient_key
            INTO var_temp_patient_key
            FROM patient
            WHERE hkid = par_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF var_rowcount > 1 THEN
            BEGIN
                SELECT
                    200124
                    INTO var_return_error_code;
                RAISE exception '';
            END;
        END IF;

        IF (par_return_type = 'B') THEN
            BEGIN
                CALL hkpmi_r_pmi_result_1(var_return_code, par_hkid, par_hosp_code, 'N', par_source_system, par_update_by);

                IF var_return_code != 0 THEN
                    BEGIN
                        IF var_return_code > 200000 THEN
                            SELECT
                                var_return_code
                                INTO var_return_error_code;
                        ELSE
                            SELECT
                                200161
                                INTO var_return_error_code;
                        END IF;
                        RAISE exception '';
                    END;
                END IF;
            END;
        END IF;
        SELECT
            p.patient_name, p.sex, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6,
            /* @dob = convert(char(8), P.dob, 112), */
            p.dob, p.exact_dob_flag, p.marital_status, p.race, p.other_doc_no, p.building, p.room, p.floor, p.block, p.district, p.religion, p.phone1, p.death_indicator, p.patient_key,
            /* @access_code = convert(char(10), P.access_code), */
            p.access_code, p.chi_name, p.phone2, p.address_indicator, p.mobile_phone, p.sms_language, p.death_date, p.death_diagnosis, p.death_external_cause, p.patient_type, p.pcs_count, n.nok_name, n.hkid, n.building, n.room, n.floor, n.block, n.district, n.phone1, n.mobile_phone, n.sms_language,
            /* Add by GL 19981103 */
            n.phone2, n.address_indicator, n.relationship, m.mrn, SUBSTRING(p.filler, 3, 1)
            INTO par_patient_name, par_sex, par_ccc1, par_ccc2, par_ccc3, par_ccc4, par_ccc5, par_ccc6, par_dob, par_exact_dob_flag, par_marital, par_race, par_other_doc_no, par_building, par_room, par_floor, par_block, par_district, par_religion, par_phone1, par_death_ind, par_patient_key, par_access_code, par_chi_name, par_phone2, par_address_indicator, par_mobile_phone, par_sms_language, par_death_date, par_death_diagnosis, par_death_external_cause, par_patient_type, par_pcs_count, par_nok_name, par_nok_hkid, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district, par_nok_phone1, par_nok_mobile_phone, par_nok_sms_language, par_nok_phone2, par_nok_address_indicator, par_nok_relation, par_mrn, par_hkic_symbol /* --20100928 SL hkic */
            FROM patient AS p
            LEFT OUTER JOIN patient_hospital_data AS m
                ON (p.patient_key = m.patient_key AND m.hospital_code = par_hosp_code)
            LEFT OUTER JOIN nok AS n
                ON (p.patient_key = n.patient_key)
            WHERE p.hkid = par_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            BEGIN
                SELECT
                    200012
                    INTO var_return_error_code;
                RAISE exception '';
            END;
        END IF;
        /* 2007-01-09 Added by HK Fong SMR20015696 - Start */
        /* Get chinese name from ccc_unicode table */
        CALL cpi_get_phonetic_chin_name(var_return_code, par_ccc1, par_ccc2, par_ccc3, par_ccc4, par_ccc5, par_ccc6, var_phonetic, par_chi_name);
        /* 2007-01-09 Added by HK Fong SMR20015696 - End */
        /* Goya 19981102, set this hospital on for this patient */
        
       /* 2025-05-26 ,par_local_saved is allways N remove this code - Start*/
       /*
        IF par_local_saved = 'Y' THEN
            BEGIN
                IF par_hosp_code IS NULL OR par_source_system IS NULL THEN
                    BEGIN
                        SELECT
                            200162
                            INTO var_return_error_code;
                        RAISE exception '';
                    END;
                END IF;
                CALL hkpmi_set_on_patient_hosp(var_return_code, par_hkid, par_hosp_code, par_update_by, par_source_system);
                IF var_return_code != 0 THEN
                    BEGIN
                        IF var_return_code > 200000 THEN
                            SELECT
                                var_return_code
                                INTO var_return_error_code;
                        ELSE
                            SELECT
                                200158
                                INTO var_return_error_code;
                        END IF;
                        RAISE exception '';
                    END;
                END IF;
            END;
        END IF;*/
       /* 2025-05-26 ,par_local_saved is allways N remove this code - end*/

        EXCEPTION
			WHEN OTHERS then
			begin
				EXIT return_error;
			end;
        pas_return_code := 0;
        RETURN;
    END;

    IF var_return_error_code != 200012 THEN
        RAISE EXCEPTION USING ERRCODE := var_return_error_code;
    END IF;
    pas_return_code := var_return_error_code;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_r_pmi_parm_1" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

