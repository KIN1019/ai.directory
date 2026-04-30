-- DROP FUNCTION download.hkpmi_poll_transaction(bpchar, int4, bpchar);

CREATE OR REPLACE FUNCTION download.hkpmi_poll_transaction(par_hospital_code character varying, par_input_record_count integer, par_last_download_key character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
    var_max_download_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_old_download_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_last_download_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_tmp_dtm_str VARCHAR(60);
    var_tmp_time_str VARCHAR(16);
    var_district_area VARCHAR(02);
    var_nok_district_area VARCHAR(02);
    var_return_error_code INTEGER;
    var_total_count INTEGER;
    var_max_record_count INTEGER;
    var_tmp_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_type VARCHAR(6);
    var_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_hkid VARCHAR(24);
    var_patient_key VARCHAR(16);
    var_patient_name VARCHAR(96);
    var_sex VARCHAR(2);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag VARCHAR(2);
    var_cccode1 VARCHAR(10);
    var_cccode2 VARCHAR(10);
    var_cccode3 VARCHAR(10);
    var_cccode4 VARCHAR(10);
    var_cccode5 VARCHAR(10);
    var_cccode6 VARCHAR(10);
    var_marital_status VARCHAR(2);
    var_race VARCHAR(4);
    var_other_doc_no VARCHAR(24);
    var_mrn VARCHAR(16);
    var_building VARCHAR(94);
    var_room VARCHAR(10);
    var_floor VARCHAR(4);
    var_block VARCHAR(4);
    var_district VARCHAR(10);
    var_religion VARCHAR(6);
    var_home_phone VARCHAR(20);
    var_death_indicator VARCHAR(8);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_nok_name VARCHAR(96);
    var_nok_hkid VARCHAR(24);
    var_nok_relationship VARCHAR(4);
    var_nok_building VARCHAR(95);
    var_nok_room VARCHAR(10);
    var_nok_floor VARCHAR(4);
    var_nok_block VARCHAR(4);
    var_nok_district VARCHAR(10);
    var_nok_home_phone VARCHAR(20);
    var_nok_office_phone VARCHAR(20);
    var_nok_office_phone_ext VARCHAR(8);
    var_case_no VARCHAR(24);
    var_source_indicator VARCHAR(2);
    var_source_code VARCHAR(6);
    var_patient_type VARCHAR(6);
    var_discharge_code VARCHAR(2);
    var_destination_code VARCHAR(10);
    var_case_type VARCHAR(2);
    var_pmi_access_code INTEGER;
    var_ambulance_no VARCHAR(8);
    var_police_case VARCHAR(2);
    var_labour_case VARCHAR(2);
    var_ae_case_type VARCHAR(2);
    var_ward_code VARCHAR(8);
    var_specialty_code VARCHAR(8);
    var_bed_no VARCHAR(10);
    var_ward_class VARCHAR(2);
    var_old_patient_key VARCHAR(16);
    var_old_patient_name VARCHAR(96);
    var_old_hkid VARCHAR(24);
    var_old_ward_class VARCHAR(2);
    var_old_ward_code VARCHAR(8);
    var_old_specialty_code VARCHAR(8);
    var_old_bed_no VARCHAR(10);
    var_update_hospital VARCHAR(6);
    var_source_system VARCHAR(10);
    var_doctor_code VARCHAR(16);
    var_mrt_indicator VARCHAR(02);
    var_transfer_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_discharge_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_update_by VARCHAR(24);
    /* download record */
    var_ixhosp VARCHAR(06);
    var_ixipdate VARCHAR(16);
    var_ixiptime VARCHAR(12);
    var_ixiseqn VARCHAR(12);
    var_ixiprk VARCHAR(16);
    var_ixcaseno VARCHAR(24);
    var_ixirecty VARCHAR(02);
    var_ixhkid VARCHAR(24);
    var_ixodocu VARCHAR(24);
    var_ixpname VARCHAR(96);
    var_ixpccc VARCHAR(60);
    var_ixpdob VARCHAR(16);
    var_ixpsex VARCHAR(02);
    var_ixpaddr VARCHAR(124);
    var_ixphone VARCHAR(20);
    var_ixpmari VARCHAR(02);
    var_ixpstatu VARCHAR(06);
    var_ixadmdt VARCHAR(16);
    var_ixadmtm VARCHAR(08);
    var_ixdschdt VARCHAR(16);
    var_ixdschtm VARCHAR(08);
    var_ixdschst VARCHAR(02);
    var_ixiward VARCHAR(08);
    var_ixspecty VARCHAR(08);
    var_ixibed VARCHAR(10);
    var_ixiclass VARCHAR(02);
    var_ixidest VARCHAR(10);
    var_ixnkname VARCHAR(96);
    var_ixnkhkid VARCHAR(24);
    var_ixnkaddr VARCHAR(124);
    var_ixnkrel VARCHAR(04);
    var_ixnkphon VARCHAR(20);
    var_ixnkoff VARCHAR(20);
    var_ixnkext VARCHAR(08);
    var_ixpphkid VARCHAR(24);
    var_ixpnprk VARCHAR(16);
    var_ixcward VARCHAR(08);
    var_ixcspec VARCHAR(08);
    var_ixcbed VARCHAR(10);
    var_ixcclass VARCHAR(02);
    var_ixiupdid VARCHAR(16);
    var_ixohosp VARCHAR(06);
    var_ixfiller VARCHAR(62);
    sql$rowcount BIGINT;
    err_msg TEXT;
    get_log CURSOR FOR
    SELECT
        system_dtm, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, home_phone, death_indicator, death_date, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_home_phone, nok_office_phone, nok_office_phone_ext, case_no, source_indicator, source_code, patient_type, discharge_code, destination_code, case_type, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, ward_code, specialty_code, bed_no, ward_class, old_patient_key, old_hkid, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, update_hospital, source_system, doctor_code, mrt_indicator, transfer_dtm, discharge_dtm, update_by
        FROM transaction_log
        WHERE hospital_code = par_hospital_code AND system_dtm > var_last_download_dtm AND system_dtm < var_tmp_system_dtm
        ORDER BY system_dtm ASC NULLS FIRST;
BEGIN
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN
            <<normal_end>>
            BEGIN
                /*
                check existing download key with the
                passed in download key
                */
                SELECT
                    last_download_dtm, max_record_count
                    INTO var_old_download_dtm, var_max_record_count
                    FROM poll_transaction_control
                    WHERE hospital_code = par_hospital_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount = 0 THEN
                    BEGIN
                        /* record not found */
                        SELECT
                            300001
                            INTO var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;
                SELECT
                    0
                    INTO var_total_count;
                SELECT
                    CONCAT(SUBSTRING(par_last_download_key, 1, 8), ' ', SUBSTRING(par_last_download_key, 9, 2), ':', SUBSTRING(par_last_download_key, 11, 2), ':', SUBSTRING(par_last_download_key, 13, 2), ':', SUBSTRING(par_last_download_key, 15, 3))
                    INTO var_last_download_dtm;
                /*
                comment as request by download server
                
                if @last_download_dtm > @old_download_dtm
                begin
                	/* the last download key cannot be
                	greater than the key stored in hkpmi */
                	select   @return_error_code = 300002
                	goto return_error
                end
                */
                IF par_input_record_count > var_max_record_count OR par_input_record_count < 1 THEN
                    BEGIN
                        /* invalid record count */
                        SELECT
                            300003
                            INTO var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;
                DROP TABLE IF EXISTS t$tmp_transaction_log;
                CREATE TEMPORARY TABLE t$tmp_transaction_log
                ("ixhosp" CHAR(03),
                    "ixipdate" CHAR(08),
                    "ixiptime" CHAR(06),
                    "ixiseqn" CHAR(06),
                    "ixiprk" CHAR(08),
                    "ixcaseno" CHAR(12),
                    "ixirecty" CHAR(01),
                    "ixhkid" CHAR(12),
                    "ixodocu" CHAR(12),
                    "ixpname" CHAR(48),
                    "ixpccc" CHAR(30),
                    "ixpdob" CHAR(08),
                    "ixpsex" CHAR(01),
                    "ixpaddr" CHAR(62),
                    "ixphone" CHAR(10),
                    "ixpmari" CHAR(01),
                    "ixpstatu" CHAR(03),
                    "ixadmdt" CHAR(08),
                    "ixadmtm" CHAR(04),
                    "ixdschdt" CHAR(08),
                    "ixdschtm" CHAR(04),
                    "ixdschst" CHAR(01),
                    "ixiward" CHAR(04),
                    "ixspecty" CHAR(04),
                    "ixibed" CHAR(05),
                    "ixiclass" CHAR(01),
                    "ixidest" CHAR(05),
                    "ixnkname" CHAR(48),
                    "ixnkhkid" CHAR(12),
                    "ixnkaddr" CHAR(62),
                    "ixnkrel" CHAR(02),
                    "ixnkphon" CHAR(10),
                    "ixnkoff" CHAR(10),
                    "ixnkext" CHAR(04),
                    "ixpphkid" CHAR(12),
                    "ixpnprk" CHAR(08),
                    "ixcward" CHAR(04),
                    "ixcspec" CHAR(04),
                    "ixcbed" CHAR(05),
                    "ixcclass" CHAR(01),
                    "ixiupdid" CHAR(08),
                    "ixohosp" CHAR(03),
                    "ixfiller" CHAR(31));
                SELECT
                    - 30 * INTERVAL '1 second' + system_dtm::TIMESTAMP
                    INTO var_tmp_system_dtm
                    FROM transaction_log_control;
                OPEN get_log;
                FETCH get_log INTO var_system_dtm, var_type, var_adm_dtm, var_hkid, var_patient_key, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_marital_status, var_race, var_other_doc_no, var_mrn, var_building, var_room, var_floor, var_block, var_district, var_religion, var_home_phone, var_death_indicator, var_death_date, var_nok_name, var_nok_hkid, var_nok_relationship, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district, var_nok_home_phone, var_nok_office_phone, var_nok_office_phone_ext, var_case_no, var_source_indicator, var_source_code, var_patient_type, var_discharge_code, var_destination_code, var_case_type, var_pmi_access_code, var_ambulance_no, var_police_case, var_labour_case, var_ae_case_type, var_ward_code, var_specialty_code, var_bed_no, var_ward_class, var_old_patient_key, var_old_hkid, var_old_ward_class, var_old_ward_code, var_old_specialty_code, var_old_bed_no, var_update_hospital, var_source_system, var_doctor_code, var_mrt_indicator, var_transfer_dtm, var_discharge_dtm, var_update_by;

                WHILE (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) = 0 LOOP
                    <<skip>>
                    BEGIN
                        <<insert_download>>
                        BEGIN
                            SELECT
                                REPEAT(' ', 03), REPEAT(' ', 06), REPEAT(' ', 06), REPEAT(' ', 06), REPEAT(' ', 08), REPEAT(' ', 12), REPEAT(' ', 01), REPEAT(' ', 12), REPEAT(' ', 12), REPEAT(' ', 48), REPEAT(' ', 30), REPEAT(' ', 08), REPEAT(' ', 01), REPEAT(' ', 62), REPEAT(' ', 10), REPEAT(' ', 01), REPEAT(' ', 03), REPEAT(' ', 08), REPEAT(' ', 04), REPEAT(' ', 08), REPEAT(' ', 04), REPEAT(' ', 01), REPEAT(' ', 04), REPEAT(' ', 04), REPEAT(' ', 05), REPEAT(' ', 01), REPEAT(' ', 05), REPEAT(' ', 48), REPEAT(' ', 12), REPEAT(' ', 62), REPEAT(' ', 02), REPEAT(' ', 10), REPEAT(' ', 10), REPEAT(' ', 04), REPEAT(' ', 12), REPEAT(' ', 08), REPEAT(' ', 04), REPEAT(' ', 04), REPEAT(' ', 05), REPEAT(' ', 01), REPEAT(' ', 08), REPEAT(' ', 03), REPEAT(' ', 31)
                                INTO var_ixhosp, var_ixipdate, var_ixiptime, var_ixiseqn, var_ixiprk, var_ixcaseno, var_ixirecty, var_ixhkid, var_ixodocu, var_ixpname, var_ixpccc, var_ixpdob, var_ixpsex, var_ixpaddr, var_ixphone, var_ixpmari, var_ixpstatu, var_ixadmdt, var_ixadmtm, var_ixdschdt, var_ixdschtm, var_ixdschst, var_ixiward, var_ixspecty, var_ixibed, var_ixiclass, var_ixidest, var_ixnkname, var_ixnkhkid, var_ixnkaddr, var_ixnkrel, var_ixnkphon, var_ixnkoff, var_ixnkext, var_ixpphkid, var_ixpnprk, var_ixcward, var_ixcspec, var_ixcbed, var_ixcclass, var_ixiupdid, var_ixohosp, var_ixfiller;
                            /* get district area */
                            IF var_district IS NOT NULL THEN
                                BEGIN
                                    SELECT
                                        district_area
                                        INTO var_district_area
                                        FROM hkpmi_dbo.district
                                        WHERE district_code = var_district;
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                    IF sql$rowcount = 0 THEN
                                        SELECT
                                            REPEAT(' ', 1)
                                            INTO var_district_area;
                                    END IF;
                                END;
                            ELSE
                                SELECT
                                    REPEAT(' ', 01)
                                    INTO var_district_area;
                            END IF;
                            /* get district area for NOK */
                            IF var_nok_district IS NOT NULL THEN
                                BEGIN
                                    SELECT
                                        district_area
                                        INTO var_nok_district_area
                                        FROM hkpmi_dbo.district
                                        WHERE district_code = var_nok_district;
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                    IF sql$rowcount = 0 THEN
                                        SELECT
                                            REPEAT(' ', 1)
                                            INTO var_nok_district_area;
                                    END IF;
                                END;
                            ELSE
                                SELECT
                                    REPEAT(' ', 01)
                                    INTO var_nok_district_area;
                            END IF;
                            SELECT
                                to_char(var_system_dtm::TIMESTAMP WITHOUT TIME ZONE, 'Mon DD YYYY HH:MI:SS.MSpm')
                                INTO var_tmp_dtm_str;
                            SELECT
                                to_char(var_system_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')
                                INTO var_tmp_time_str;
                            SELECT
                                par_hospital_code, to_char(var_system_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), CONCAT(SUBSTRING(var_tmp_time_str, 1, 2), SUBSTRING(var_tmp_time_str, 4, 2), SUBSTRING(var_tmp_time_str, 7, 2)), CONCAT(SUBSTRING(var_tmp_dtm_str, 22, 3), '000'), var_patient_key, var_hkid, var_patient_name, var_sex, var_update_hospital
                                INTO var_ixhosp, var_ixipdate, var_ixiptime, var_ixiseqn, var_ixiprk, var_ixhkid, var_ixpname, var_ixpsex, var_ixohosp;

                            IF var_source_system = 'DNL' THEN
                                SELECT
                                    SUBSTRING(var_update_by, 1, 8)
                                    INTO var_ixiupdid;
                            ELSE
                                SELECT
                                    CONCAT(RTRIM(var_update_hospital), var_source_system)
                                    INTO var_ixiupdid;
                            END IF;

                            IF var_dob IS NULL THEN
                                SELECT
                                    '99999999'
                                    INTO var_ixpdob;
                            ELSE
                                SELECT
                                    to_char(var_dob::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                                    INTO var_ixpdob;
                            END IF;

                            IF var_adm_dtm IS NOT NULL THEN
                                BEGIN
                                    SELECT
                                        to_char(var_adm_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')
                                        INTO var_tmp_time_str;
                                    SELECT
                                        to_char(var_adm_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), CONCAT(SUBSTRING(var_tmp_time_str, 1, 2), SUBSTRING(var_tmp_time_str, 4, 2), SUBSTRING(var_tmp_time_str, 7, 2))
                                        INTO var_ixadmdt, var_ixadmtm;
                                END;
                            END IF;
                            SELECT
                                COALESCE(CAST (var_case_no AS CHAR(12)), REPEAT(' ', 12)), COALESCE(CAST (var_other_doc_no AS CHAR(12)), REPEAT(' ', 12)), CONCAT(COALESCE(CAST (var_cccode1 AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_cccode2 AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_cccode3 AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_cccode4 AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_cccode5 AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_cccode6 AS CHAR(05)), REPEAT(' ', 05))), CONCAT(COALESCE(SUBSTRING(CAST (var_building AS CHAR(47)), 1, 37), REPEAT(' ', 37)), COALESCE(CAST (var_district AS CHAR(05)), REPEAT(' ', 05)), COALESCE(SUBSTRING(CAST (var_building AS CHAR(47)), 38, 10), REPEAT(' ', 10)), COALESCE(CAST (var_district_area AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_room AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_floor AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_block AS CHAR(02)), REPEAT(' ', 02))), COALESCE(CAST (LTRIM(var_home_phone) AS CHAR(10)), REPEAT(' ', 10)), COALESCE(CAST (var_marital_status AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_patient_type AS CHAR(03)), REPEAT(' ', 03))
                                INTO var_ixcaseno, var_ixodocu, var_ixpccc, var_ixpaddr, var_ixphone, var_ixpmari, var_ixpstatu;

                            IF var_discharge_dtm IS NOT NULL THEN
                                BEGIN
                                    SELECT
                                        to_char(var_discharge_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')
                                        INTO var_tmp_time_str;
                                    SELECT
                                        to_char(var_discharge_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), CONCAT(SUBSTRING(var_tmp_time_str, 1, 2), SUBSTRING(var_tmp_time_str, 4, 2), SUBSTRING(var_tmp_time_str, 7, 2))
                                        INTO var_ixdschdt, var_ixdschtm;
                                END;
                            END IF;
                            SELECT
                                COALESCE(CAST (var_discharge_code AS CHAR(01)), REPEAT(' ', 1)), COALESCE(CAST (var_ward_code AS CHAR(04)), REPEAT(' ', 04)), COALESCE(CAST (var_specialty_code AS CHAR(04)), REPEAT(' ', 04)), COALESCE(CAST (var_bed_no AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_ward_class AS CHAR(01)), REPEAT(' ', 1)), COALESCE(CAST (var_destination_code AS CHAR(05)), REPEAT(' ', 5)), COALESCE(CAST (var_nok_name AS CHAR(48)), REPEAT(' ', 48)), COALESCE(CAST (var_nok_hkid AS CHAR(12)), REPEAT(' ', 12)), CONCAT(COALESCE(SUBSTRING(CAST (var_nok_building AS CHAR(47)), 1, 37), REPEAT(' ', 37)), COALESCE(CAST (var_nok_district AS CHAR(05)), REPEAT(' ', 05)), COALESCE(SUBSTRING(CAST (var_nok_building AS CHAR(47)), 38, 10), REPEAT(' ', 10)), COALESCE(CAST (var_nok_district_area AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_nok_room AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_nok_floor AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_nok_block AS CHAR(02)), REPEAT(' ', 02))), COALESCE(CAST (var_nok_relationship AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (LTRIM(var_nok_home_phone) AS CHAR(10)), REPEAT(' ', 10)), COALESCE(CAST (LTRIM(var_nok_office_phone) AS CHAR(10)), REPEAT(' ', 10)), COALESCE(CAST (LTRIM(var_nok_office_phone_ext) AS CHAR(04)), REPEAT(' ', 04)), COALESCE(CAST (var_old_hkid AS CHAR(12)), REPEAT(' ', 12)), COALESCE(CAST (var_old_patient_key AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_old_ward_code AS CHAR(04)), REPEAT(' ', 04)), COALESCE(CAST (var_old_specialty_code AS CHAR(04)), REPEAT(' ', 04)), COALESCE(CAST (var_old_bed_no AS CHAR(05)), REPEAT(' ', 5)), COALESCE(CAST (var_old_ward_class AS CHAR(01)), REPEAT(' ', 01))
                                INTO var_ixdschst, var_ixiward, var_ixspecty, var_ixibed, var_ixiclass, var_ixidest, var_ixnkname, var_ixnkhkid, var_ixnkaddr, var_ixnkrel, var_ixnkphon, var_ixnkoff, var_ixnkext, var_ixpphkid, var_ixpnprk, var_ixcward, var_ixcspec, var_ixcbed, var_ixcclass;

                            IF var_type IN ('010', '030', '031') THEN
                                /* demo update */
                                BEGIN
                                    SELECT
                                        '1'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), COALESCE(CAST (var_mrn AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type IN ('100') AND var_case_type = 'I' THEN
                                /* in_patient admission */
                                BEGIN
                                    SELECT
                                        '2'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), COALESCE(CAST (var_mrn AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_source_indicator AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_source_code AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 01))
                                        INTO var_ixidest;
                                    EXIT insert_download;
                                END;
                            END IF;
                            /* --- Add by WL on 19981211, convert old case --- */

                            IF var_type = '090' AND var_case_type = 'I' THEN
                                /* convert old case */
                                BEGIN
                                    SELECT
                                        'V'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), COALESCE(CAST (var_source_indicator AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_source_code AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 11), COALESCE(CAST (var_mrn AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    /*
                                    select @ixidest = isnull(convert(char(01),@source_indicator)
                                    				, space(01)) +
                                    isnull(convert(char(03), @source_code)
                                    				, space(03)) +
                                    space(01)
                                    */
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type = '121' THEN
                                /* update admission */
                                BEGIN
                                    IF var_case_type = 'O' THEN
                                        SELECT
                                            'N'
                                            INTO var_ixirecty;
                                    ELSE
                                        SELECT
                                            '3'
                                            INTO var_ixirecty;
                                    END IF;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), REPEAT(' ', 08), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_source_indicator AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_source_code AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 01))
                                        INTO var_ixidest;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type IN ('140', '160', '170', '700') THEN
                                /*
                                transfer, trial discharge, return from trial discharge and
                                bed assignment
                                */
                                BEGIN
                                    SELECT
                                        '4'
                                        INTO var_ixirecty;

                                    IF var_transfer_dtm IS NOT NULL THEN
                                        BEGIN
                                            SELECT
                                                to_char(var_transfer_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')
                                                INTO var_tmp_time_str;
                                            SELECT
                                                to_char(var_transfer_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), CONCAT(SUBSTRING(var_tmp_time_str, 1, 2), SUBSTRING(var_tmp_time_str, 4, 2), SUBSTRING(var_tmp_time_str, 7, 2))
                                                INTO var_ixadmdt, var_ixadmtm;
                                        END;
                                    END IF;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), COALESCE(CAST (var_doctor_code AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type LIKE '13%' AND var_case_type = 'I' THEN
                                /* in-patient discharge */
                                BEGIN
                                    SELECT
                                        '5'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), COALESCE(CAST (var_doctor_code AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_mrt_indicator AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 01))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type = '201' AND var_case_type = 'I' THEN
                                /* cancel in-patient admission */
                                BEGIN
                                    SELECT
                                        '6'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), REPEAT(' ', 08), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;
                            /* --- add by WL on 19981211 - cancel convert old case 080 -- */

                            IF var_type = '080' AND var_case_type = 'I' THEN
                                /* cancel convert old case */
                                BEGIN
                                    SELECT
                                        'W'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), REPEAT(' ', 08), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type LIKE '21%' THEN
                                /* cancel in-patient discharge */
                                /* opas reopen case */
                                BEGIN
                                    IF var_case_type = 'O' THEN
                                        SELECT
                                            'P'
                                            INTO var_ixirecty;
                                    ELSE
                                        SELECT
                                            '7'
                                            INTO var_ixirecty;
                                    END IF;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), COALESCE(CAST (var_doctor_code AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type IN ('220', '230', '240', '710') THEN
                                /* cancel transfer, trial discharge, */
                                /* return from trial discharge and bed assignment */
                                BEGIN
                                    SELECT
                                        '8'
                                        INTO var_ixirecty;

                                    IF var_transfer_dtm IS NOT NULL THEN
                                        BEGIN
                                            SELECT
                                                to_char(var_transfer_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')
                                                INTO var_tmp_time_str;
                                            SELECT
                                                to_char(var_transfer_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), CONCAT(SUBSTRING(var_tmp_time_str, 1, 2), SUBSTRING(var_tmp_time_str, 4, 2), SUBSTRING(var_tmp_time_str, 7, 2))
                                                INTO var_ixadmdt, var_ixadmtm;
                                        END;
                                    END IF;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), REPEAT(' ', 08), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type = '020' THEN
                                /* merge hkid */
                                BEGIN
                                    SELECT
                                        '9'
                                        INTO var_ixirecty;
                                    SELECT
                                        var_old_patient_key, var_old_hkid, var_hkid, var_patient_key
                                        INTO var_ixiprk, var_ixhkid, var_ixpphkid, var_ixpnprk;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), REPEAT(' ', 08), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type = '300' THEN
                                /* A&E patient registration */
                                BEGIN
                                    SELECT
                                        'A'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), COALESCE(CAST (var_mrn AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    SELECT
                                        COALESCE(CAST (var_ambulance_no AS CHAR(04)), REPEAT(' ', 04))
                                        INTO var_ixcward;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_labour_case AS CHAR(01)), REPEAT(' ', 1)), COALESCE(CAST (var_police_case AS CHAR(01)), REPEAT(' ', 1)), COALESCE(CAST (var_ae_case_type AS CHAR(01)), REPEAT(' ', 1)), REPEAT(' ', 01))
                                        INTO var_ixcspec;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type LIKE '33%' THEN
                                /* discharge A&E case */
                                BEGIN
                                    SELECT
                                        'E'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), COALESCE(CAST (var_doctor_code AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_mrt_indicator AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 01))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type = '200' AND var_case_type = 'A' THEN
                                /* cancel admission of A&E case */
                                BEGIN
                                    SELECT
                                        'F'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), REPEAT(' ', 08), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type LIKE '35%' THEN
                                /* cancel of A&E discharge */
                                BEGIN
                                    SELECT
                                        'G'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), COALESCE(CAST (var_doctor_code AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type = '040' THEN
                                /* move episode */
                                BEGIN
                                    SELECT
                                        'I'
                                        INTO var_ixirecty;
                                    SELECT
                                        var_old_patient_key, var_old_hkid, var_hkid, var_patient_key
                                        INTO var_ixiprk, var_ixhkid, var_ixpphkid, var_ixpnprk;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), COALESCE(CAST (var_mrn AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type = '100' AND var_case_type = 'O' THEN
                                /* out-patient registration */
                                BEGIN
                                    SELECT
                                        'K'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), COALESCE(CAST (var_mrn AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type = '200' AND var_case_type = 'O' THEN
                                /* out-patient registration */
                                BEGIN
                                    SELECT
                                        'O'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), REPEAT(' ', 08), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type LIKE '13%' AND var_case_type = 'O' THEN
                                /* close out-patient registration */
                                BEGIN
                                    SELECT
                                        'L'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), COALESCE(CAST (var_mrn AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type = '341' THEN
                                /* update A&E patient registration */
                                BEGIN
                                    SELECT
                                        'C'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_race AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), REPEAT(' ', 15), REPEAT(' ', 08), COALESCE(CAST (var_exact_dob_flag AS CHAR(01)), REPEAT(' ', 01)), REPEAT(' ', 02))
                                        INTO var_ixfiller;
                                    SELECT
                                        COALESCE(CAST (var_ambulance_no AS CHAR(04)), REPEAT(' ', 04))
                                        INTO var_ixcward;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_labour_case AS CHAR(01)), REPEAT(' ', 1)), COALESCE(CAST (var_police_case AS CHAR(01)), REPEAT(' ', 1)), COALESCE(CAST (var_ae_case_type AS CHAR(01)), REPEAT(' ', 1)), REPEAT(' ', 01))
                                        INTO var_ixcspec;
                                    SELECT
                                        REPEAT(' ', 04), REPEAT(' ', 04), REPEAT(' ', 01), REPEAT(' ', 05)
                                        INTO var_ixiward, var_ixspecty, var_ixiclass, var_ixibed;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type = '033' THEN
                                /* update patient death indicator and death date */
                                BEGIN
                                    SELECT
                                        'X'
                                        INTO var_ixirecty;

                                    IF var_death_indicator IS NULL THEN
                                        BEGIN
                                            SELECT
                                                CONCAT(REPEAT(' ', 29), 'N', REPEAT(' ', 01))
                                                INTO var_ixfiller;
                                            SELECT
                                                REPEAT(' ', 08), REPEAT(' ', 04), REPEAT(' ', 01)
                                                INTO var_ixdschdt, var_ixdschtm, var_ixdschst;
                                        END;
                                    ELSE
                                        BEGIN
                                            IF var_death_date IS NULL AND var_death_indicator = 'DR' THEN
                                                BEGIN
                                                    SELECT
                                                        CONCAT(REPEAT(' ', 29), 'Y', REPEAT(' ', 01))
                                                        INTO var_ixfiller;
                                                    SELECT
                                                        REPEAT(' ', 08), REPEAT(' ', 04), '1'
                                                        INTO var_ixdschdt, var_ixdschtm, var_ixdschst;
                                                END;
                                            ELSE
                                                BEGIN
                                                    SELECT
                                                        CONCAT(REPEAT(' ', 29), 'Y', REPEAT(' ', 01))
                                                        INTO var_ixfiller;
                                                    SELECT
                                                        to_char(var_death_date::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')
                                                        INTO var_tmp_time_str;
                                                    SELECT
                                                        to_char(var_death_date::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), CONCAT(SUBSTRING(var_tmp_time_str, 1, 2), SUBSTRING(var_tmp_time_str, 4, 2), SUBSTRING(var_tmp_time_str, 7, 2)), '1'
                                                        INTO var_ixdschdt, var_ixdschtm, var_ixdschst;
                                                END;
                                            END IF;
                                        END;
                                    END IF;
                                    EXIT insert_download;
                                END;
                            END IF;

                            IF var_type = '034' THEN
                                /* update PMI confidential */
                                BEGIN
                                    SELECT
                                        'Y'
                                        INTO var_ixirecty;
                                    SELECT
                                        CONCAT(COALESCE(CAST (var_pmi_access_code AS CHAR(10)), REPEAT(' ', 10)), REPEAT(' ', 21))
                                        INTO var_ixfiller;
                                    EXIT insert_download;
                                END;
                            END IF;
                            /* --- added by WL for PMI Deletion on 22 MAY 2000-- */

                            IF var_type = '250' THEN
                                /* PMI deletion */
                                BEGIN
                                    SELECT
                                        'B'
                                        INTO var_ixirecty;
                                    EXIT insert_download;
                                END;
                            END IF;
                            /* --- end added by WL for PMI Deletion -- */
                            EXIT skip;
                        END;
                        /* special for bed no */
                        /* Add V and W by WL on 19981211 for convert old case */
                        /* and cancel convert old case */
                        IF var_ixirecty IN ('2', '3', '4', '5', '6', '7', '8', 'A', 'E', 'F', 'G', 'V', 'W') THEN
                            BEGIN
                                IF var_bed_no IS NULL THEN
                                    SELECT
                                        'T000 '
                                        INTO var_ixibed;
                                END IF;
                            END;
                        END IF;

                        IF var_ixirecty IN ('4', '8') THEN
                            BEGIN
                                IF var_old_bed_no IS NULL THEN
                                    SELECT
                                        'T000 '
                                        INTO var_ixcbed;
                                END IF;
                            END;
                        END IF;

                        IF var_ixirecty = '3' AND var_old_specialty_code IS NOT NULL AND var_old_ward_code IS NOT NULL AND var_old_ward_class IS NOT NULL THEN
                            BEGIN
                                IF var_old_bed_no IS NULL THEN
                                    SELECT
                                        'T000 '
                                        INTO var_ixcbed;
                                END IF;
                            END;
                        END IF;

                        BEGIN
                            INSERT INTO t$tmp_transaction_log
                            VALUES (var_ixhosp, var_ixipdate, var_ixiptime, var_ixiseqn, var_ixiprk, var_ixcaseno, var_ixirecty, var_ixhkid, var_ixodocu, var_ixpname, var_ixpccc, var_ixpdob, var_ixpsex, var_ixpaddr, var_ixphone, var_ixpmari, var_ixpstatu, var_ixadmdt, var_ixadmtm, var_ixdschdt, var_ixdschtm, var_ixdschst, var_ixiward, var_ixspecty, var_ixibed, var_ixiclass, var_ixidest, var_ixnkname, var_ixnkhkid, var_ixnkaddr, var_ixnkrel, var_ixnkphon, var_ixnkoff, var_ixnkext, var_ixpphkid, var_ixpnprk, var_ixcward, var_ixcspec, var_ixcbed, var_ixcclass, var_ixiupdid, var_ixohosp, var_ixfiller);
                            EXCEPTION
                                WHEN others THEN
                                    BEGIN
                                        GET STACKED DIAGNOSTICS err_msg = PG_EXCEPTION_CONTEXT;
                                        RAISE NOTICE 'hkpmi_poll_transaction INSERT t$tmp_transaction_log ERROR: %', err_msg;
                                        var_return_error_code := 9999;
                                        EXIT return_system_error;
                                    END;
                        END;
                        /* update the count */
                        SELECT
                            var_total_count + 1
                            INTO var_total_count;
                        SELECT
                            var_system_dtm
                            INTO var_max_download_dtm;

                        IF var_total_count = par_input_record_count THEN
                            EXIT normal_end;
                        END IF;
                    END;
                    FETCH get_log INTO var_system_dtm, var_type, var_adm_dtm, var_hkid, var_patient_key, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_marital_status, var_race, var_other_doc_no, var_mrn, var_building, var_room, var_floor, var_block, var_district, var_religion, var_home_phone, var_death_indicator, var_death_date, var_nok_name, var_nok_hkid, var_nok_relationship, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district, var_nok_home_phone, var_nok_office_phone, var_nok_office_phone_ext, var_case_no, var_source_indicator, var_source_code, var_patient_type, var_discharge_code, var_destination_code, var_case_type, var_pmi_access_code, var_ambulance_no, var_police_case, var_labour_case, var_ae_case_type, var_ward_code, var_specialty_code, var_bed_no, var_ward_class, var_old_patient_key, var_old_hkid, var_old_ward_class, var_old_ward_code, var_old_specialty_code, var_old_bed_no, var_update_hospital, var_source_system, var_doctor_code, var_mrt_indicator, var_transfer_dtm, var_discharge_dtm, var_update_by;
                END LOOP; /* end while @@sql_status = 0 */
            END;

            IF var_max_download_dtm IS NOT NULL THEN
                BEGIN
                    /* update the poll transaction control */
                    BEGIN
                        UPDATE poll_transaction_control
                        SET last_download_dtm = var_max_download_dtm
                            WHERE hospital_code = par_hospital_code;
                        EXCEPTION
                            WHEN others THEN
                                BEGIN
                                    GET STACKED DIAGNOSTICS err_msg = PG_EXCEPTION_CONTEXT;
                                    RAISE NOTICE 'hkpmi_poll_transaction UPDATE poll_transaction_control ERROR: %', err_msg;
                                    var_return_error_code := 9999;
                                    EXIT return_system_error;
                                END;
                    END;
                END;
            END IF;
            OPEN p_refcur FOR
            SELECT
                t$tmp_transaction_log.ixhosp, t$tmp_transaction_log.ixipdate, t$tmp_transaction_log.ixiptime, t$tmp_transaction_log.ixiseqn, t$tmp_transaction_log.ixiprk, t$tmp_transaction_log.ixcaseno, t$tmp_transaction_log.ixirecty, t$tmp_transaction_log.ixhkid, t$tmp_transaction_log.ixodocu, t$tmp_transaction_log.ixpname, t$tmp_transaction_log.ixpccc, t$tmp_transaction_log.ixpdob, t$tmp_transaction_log.ixpsex, t$tmp_transaction_log.ixpaddr, t$tmp_transaction_log.ixphone, t$tmp_transaction_log.ixpmari, t$tmp_transaction_log.ixpstatu, t$tmp_transaction_log.ixadmdt, t$tmp_transaction_log.ixadmtm, t$tmp_transaction_log.ixdschdt, t$tmp_transaction_log.ixdschtm, t$tmp_transaction_log.ixdschst, t$tmp_transaction_log.ixiward, t$tmp_transaction_log.ixspecty, t$tmp_transaction_log.ixibed, t$tmp_transaction_log.ixiclass, t$tmp_transaction_log.ixidest, t$tmp_transaction_log.ixnkname, t$tmp_transaction_log.ixnkhkid, t$tmp_transaction_log.ixnkaddr, t$tmp_transaction_log.ixnkrel, t$tmp_transaction_log.ixnkphon, t$tmp_transaction_log.ixnkoff, t$tmp_transaction_log.ixnkext, t$tmp_transaction_log.ixpphkid, t$tmp_transaction_log.ixpnprk, t$tmp_transaction_log.ixcward, t$tmp_transaction_log.ixcspec, t$tmp_transaction_log.ixcbed, t$tmp_transaction_log.ixcclass, t$tmp_transaction_log.ixiupdid, t$tmp_transaction_log.ixohosp, t$tmp_transaction_log.ixfiller
                FROM t$tmp_transaction_log;
            RETURN NEXT p_refcur;
        END;
        RAISE EXCEPTION USING ERRCODE := var_return_error_code;
    END;
    DROP TABLE IF EXISTS t$tmp_transaction_log;
    /*
    
    DROP TABLE IF EXISTS t$tmp_transaction_log;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;

ALTER FUNCTION "hkpmi_poll_transaction" OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";