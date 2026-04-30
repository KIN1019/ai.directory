-- DROP FUNCTION hkpmi."fn_tU_patient"();

CREATE OR REPLACE FUNCTION hkpmi."fn_tU_patient"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* UPDATE trigger on patient */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    var_inspatient_key VARCHAR(08);
    var_delhkid VARCHAR(12);
    var_delpatient_type VARCHAR(03);
    var_delpatient_key VARCHAR(08);
    var_delsource_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_delsystem_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_delcccode1 VARCHAR(5);
    var_delcccode2 VARCHAR(5);
    var_delcccode3 VARCHAR(5);
    var_delcccode4 VARCHAR(5);
    var_delcccode5 VARCHAR(5);
    var_delcccode6 VARCHAR(5);
    var_delpatient_name VARCHAR(48);
    var_delsex VARCHAR(01);
    var_deldob TIMESTAMP WITHOUT TIME ZONE;
    var_inssource_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_inssystem_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_inspatient_type VARCHAR(03);
    var_inshkid VARCHAR(12);
    var_inscccode1 VARCHAR(5);
    var_inscccode2 VARCHAR(5);
    var_inscccode3 VARCHAR(5);
    var_inscccode4 VARCHAR(5);
    var_inscccode5 VARCHAR(5);
    var_inscccode6 VARCHAR(5);
    var_inspatient_name VARCHAR(48);
    var_inssex VARCHAR(01);
    var_insdob TIMESTAMP WITHOUT TIME ZONE;
    var_errno INTEGER;
    var_errmsg VARCHAR(255);
    var_valid_flag VARCHAR(1);
    var_return_code INTEGER;
    var_ins_doc_code VARCHAR(1); /* --20130508 */
    var_del_doc_code VARCHAR(1);
    var_ins_doc_no VARCHAR(30);
    var_del_doc_no VARCHAR(30);
    var_ins_hkic_sym VARCHAR(1); /* --20130930 */
    var_del_hkic_sym VARCHAR(1);
    var_ins_upd_by VARCHAR(12);
    var_ins_upd_hosp VARCHAR(3);
    var_ins_upd_sys VARCHAR(12);
    var_org_patient_doc_info_doc VARCHAR(1);
    var_rowcount$aws$ INTEGER;
    update$patient_key BOOLEAN = false;
    update$religion BOOLEAN = false;
    update$hkid BOOLEAN = false;
    update$cccode1 BOOLEAN = false;
    update$cccode2 BOOLEAN = false;
    update$cccode3 BOOLEAN = false;
    update$cccode4 BOOLEAN = false;
    update$cccode5 BOOLEAN = false;
    update$cccode6 BOOLEAN = false;
    update$dob BOOLEAN = false;
    update$exact_dob_flag BOOLEAN = false;
    update$race BOOLEAN = false;
    update$district BOOLEAN = false;
    update$building BOOLEAN = false;
    update$floor BOOLEAN = false;
    update$block BOOLEAN = false;
    update$room BOOLEAN = false;
    update$update_hospital BOOLEAN = false;
    update$source_system_dtm BOOLEAN = false;
    update$system_dtm BOOLEAN = false;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$patient_key = TRUE;
            WHEN 'UPDATE' THEN
                update$patient_key = ((SELECT
                    array_agg(patient_key)
                    FROM deleted) != (SELECT
                    array_agg(patient_key)
                    FROM inserted));
            ELSE
                update$patient_key := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$religion = TRUE;
            WHEN 'UPDATE' THEN
                update$religion = ((SELECT
                    array_agg(religion)
                    FROM deleted) != (SELECT
                    array_agg(religion)
                    FROM inserted));
            ELSE
                update$religion := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$hkid = TRUE;
            WHEN 'UPDATE' THEN
                update$hkid = ((SELECT
                    array_agg(hkid)
                    FROM deleted) != (SELECT
                    array_agg(hkid)
                    FROM inserted));
            ELSE
                update$hkid := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$cccode1 = TRUE;
            WHEN 'UPDATE' THEN
                update$cccode1 = ((SELECT
                    array_agg(cccode1)
                    FROM deleted) != (SELECT
                    array_agg(cccode1)
                    FROM inserted));
            ELSE
                update$cccode1 := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$cccode2 = TRUE;
            WHEN 'UPDATE' THEN
                update$cccode2 = ((SELECT
                    array_agg(cccode2)
                    FROM deleted) != (SELECT
                    array_agg(cccode2)
                    FROM inserted));
            ELSE
                update$cccode2 := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$cccode3 = TRUE;
            WHEN 'UPDATE' THEN
                update$cccode3 = ((SELECT
                    array_agg(cccode3)
                    FROM deleted) != (SELECT
                    array_agg(cccode3)
                    FROM inserted));
            ELSE
                update$cccode3 := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$cccode4 = TRUE;
            WHEN 'UPDATE' THEN
                update$cccode4 = ((SELECT
                    array_agg(cccode4)
                    FROM deleted) != (SELECT
                    array_agg(cccode4)
                    FROM inserted));
            ELSE
                update$cccode4 := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$cccode5 = TRUE;
            WHEN 'UPDATE' THEN
                update$cccode5 = ((SELECT
                    array_agg(cccode5)
                    FROM deleted) != (SELECT
                    array_agg(cccode5)
                    FROM inserted));
            ELSE
                update$cccode5 := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$cccode6 = TRUE;
            WHEN 'UPDATE' THEN
                update$cccode6 = ((SELECT
                    array_agg(cccode6)
                    FROM deleted) != (SELECT
                    array_agg(cccode6)
                    FROM inserted));
            ELSE
                update$cccode6 := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$dob = TRUE;
            WHEN 'UPDATE' THEN
                update$dob = ((SELECT
                    array_agg(dob)
                    FROM deleted) != (SELECT
                    array_agg(dob)
                    FROM inserted));
            ELSE
                update$dob := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$exact_dob_flag = TRUE;
            WHEN 'UPDATE' THEN
                update$exact_dob_flag = ((SELECT
                    array_agg(exact_dob_flag)
                    FROM deleted) != (SELECT
                    array_agg(exact_dob_flag)
                    FROM inserted));
            ELSE
                update$exact_dob_flag := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$race = TRUE;
            WHEN 'UPDATE' THEN
                update$race = ((SELECT
                    array_agg(race)
                    FROM deleted) != (SELECT
                    array_agg(race)
                    FROM inserted));
            ELSE
                update$race := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$district = TRUE;
            WHEN 'UPDATE' THEN
                update$district = ((SELECT
                    array_agg(district)
                    FROM deleted) != (SELECT
                    array_agg(district)
                    FROM inserted));
            ELSE
                update$district := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$building = TRUE;
            WHEN 'UPDATE' THEN
                update$building = ((SELECT
                    array_agg(building)
                    FROM deleted) != (SELECT
                    array_agg(building)
                    FROM inserted));
            ELSE
                update$building := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$floor = TRUE;
            WHEN 'UPDATE' THEN
                update$floor = ((SELECT
                    array_agg(floor)
                    FROM deleted) != (SELECT
                    array_agg(floor)
                    FROM inserted));
            ELSE
                update$floor := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$block = TRUE;
            WHEN 'UPDATE' THEN
                update$block = ((SELECT
                    array_agg(block)
                    FROM deleted) != (SELECT
                    array_agg(block)
                    FROM inserted));
            ELSE
                update$block := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$room = TRUE;
            WHEN 'UPDATE' THEN
                update$room = ((SELECT
                    array_agg(room)
                    FROM deleted) != (SELECT
                    array_agg(room)
                    FROM inserted));
            ELSE
                update$room := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$update_hospital = TRUE;
            WHEN 'UPDATE' THEN
                update$update_hospital = ((SELECT
                    array_agg(update_hospital)
                    FROM deleted) != (SELECT
                    array_agg(update_hospital)
                    FROM inserted));
            ELSE
                update$update_hospital := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$source_system_dtm = TRUE;
            WHEN 'UPDATE' THEN
                update$source_system_dtm = ((SELECT
                    array_agg(source_system_dtm)
                    FROM deleted) != (SELECT
                    array_agg(source_system_dtm)
                    FROM inserted));
            ELSE
                update$source_system_dtm := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$system_dtm = TRUE;
            WHEN 'UPDATE' THEN
                update$system_dtm = ((SELECT
                    array_agg(system_dtm)
                    FROM deleted) != (SELECT
                    array_agg(system_dtm)
                    FROM inserted));
            ELSE
                update$system_dtm := FALSE;
        END CASE;

        IF (TG_OP = 'INSERT') THEN
            SELECT
                count(1)
                FROM inserted
                INTO var_rowcount$aws$;
        ELSE
            SELECT
                count(1)
                FROM deleted
                INTO var_rowcount$aws$;
        END IF; /* ---20131213 */
        var_numrows := var_rowcount$aws$;

        IF var_numrows > 1 THEN
            BEGIN
                SELECT
                    200050
                    INTO var_errno;
                EXIT error;
            END;
        END IF;
        SELECT
            hkid, patient_type, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, patient_name, sex, dob, patient_key, source_system_dtm, system_dtm, SUBSTRING(filler, 1, 1), other_doc_no, SUBSTRING(filler, 3, 1), update_by, update_hospital, source_system
            INTO var_inshkid, var_inspatient_type, var_inscccode1, var_inscccode2, var_inscccode3, var_inscccode4, var_inscccode5, var_inscccode6, var_inspatient_name, var_inssex, var_insdob, var_inspatient_key, var_inssource_system_dtm, var_inssystem_dtm, var_ins_doc_code, var_ins_doc_no, var_ins_hkic_sym, var_ins_upd_by, var_ins_upd_hosp, var_ins_upd_sys
            FROM inserted;
        SELECT
            hkid, patient_type, patient_key, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, patient_name, sex, dob, source_system_dtm, system_dtm, SUBSTRING(filler, 1, 1), other_doc_no, SUBSTRING(filler, 3, 1)
            INTO var_delhkid, var_delpatient_type, var_delpatient_key, var_delcccode1, var_delcccode2, var_delcccode3, var_delcccode4, var_delcccode5, var_delcccode6, var_delpatient_name, var_delsex, var_deldob, var_delsource_system_dtm, var_delsystem_dtm, var_del_doc_code, var_del_doc_no, var_del_hkic_sym
            FROM deleted;

        IF EXISTS (SELECT
            *
            FROM inserted AS i, deleted AS d
            WHERE i.system_dtm = d.system_dtm AND i.patient_key = d.patient_key) THEN
            BEGIN
                SELECT
                    200133
                    INTO var_errno;
                EXIT error;
            END;
        END IF;

        IF (var_inscccode1 = ' ') THEN
            SELECT
                NULL
                INTO var_inscccode1;
        END IF;

        IF (var_inscccode2 = ' ') THEN
            SELECT
                NULL
                INTO var_inscccode2;
        END IF;

        IF (var_inscccode3 = ' ') THEN
            SELECT
                NULL
                INTO var_inscccode3;
        END IF;

        IF (var_inscccode4 = ' ') THEN
            SELECT
                NULL
                INTO var_inscccode4;
        END IF;

        IF (var_inscccode5 = ' ') THEN
            SELECT
                NULL
                INTO var_inscccode5;
        END IF;

        IF (var_inscccode6 = ' ') THEN
            SELECT
                NULL
                INTO var_inscccode6;
        END IF;

        IF RTRIM(LTRIM(var_ins_doc_no)) is NULL OR RTRIM(LTRIM(var_ins_doc_no)) = '' THEN
            SELECT
                NULL
                INTO var_ins_doc_no;
        END IF;

        IF RTRIM(LTRIM(var_del_doc_no)) is NULL OR RTRIM(LTRIM(var_del_doc_no)) = '' THEN
            SELECT
                NULL
                INTO var_del_doc_no;
        END IF;

        IF RTRIM(LTRIM(var_ins_doc_code)) is NULL OR RTRIM(LTRIM(var_ins_doc_code)) = '' THEN
            SELECT
                NULL
                INTO var_ins_doc_code;
        END IF;

        IF RTRIM(LTRIM(var_del_doc_code)) is NULL OR RTRIM(LTRIM(var_del_doc_code)) = '' THEN
            SELECT
                NULL
                INTO var_del_doc_code;
        END IF;

        IF RTRIM(LTRIM(var_ins_hkic_sym)) is NULL OR RTRIM(LTRIM(var_ins_hkic_sym)) = '' THEN
            SELECT
                NULL
                INTO var_ins_hkic_sym;
        END IF;

        IF RTRIM(LTRIM(var_del_hkic_sym)) is NULL OR RTRIM(LTRIM(var_del_hkic_sym)) = '' THEN
            SELECT
                NULL
                INTO var_del_hkic_sym;
        END IF;

        IF (var_delcccode1 = ' ') THEN
            SELECT
                NULL
                INTO var_delcccode1;
        END IF;

        IF (var_delcccode2 = ' ') THEN
            SELECT
                NULL
                INTO var_delcccode2;
        END IF;

        IF (var_delcccode3 = ' ') THEN
            SELECT
                NULL
                INTO var_delcccode3;
        END IF;

        IF (var_delcccode4 = ' ') THEN
            SELECT
                NULL
                INTO var_delcccode4;
        END IF;

        IF (var_delcccode5 = ' ') THEN
            SELECT
                NULL
                INTO var_delcccode5;
        END IF;

        IF (var_delcccode6 = ' ') THEN
            SELECT
                NULL
                INTO var_delcccode6;
        END IF;
        /* patient R/91 patient_detail ON PARENT UPDATE CASCADE */
        IF update$patient_key THEN
            BEGIN
                UPDATE patient_detail
                SET patient_key = var_inspatient_key
                    WHERE patient_detail.patient_key = var_delpatient_key;
                UPDATE pmi_case
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE pmi_case.patient_key = deleted.patient_key;
                UPDATE nok
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE nok.patient_key = deleted.patient_key;
                UPDATE patient_hospital_data
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE patient_hospital_data.patient_key = deleted.patient_key;
                UPDATE patient_detail_1
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE patient_detail_1.patient_key = deleted.patient_key;
                /* 20050923 - update from_patient_key and to_patient_key of move_episode_indicator table when updating patient key */
                UPDATE move_episode_indicator
                SET from_patient_key = var_inspatient_key
                FROM deleted
                    WHERE move_episode_indicator.from_patient_key = deleted.patient_key;
                UPDATE move_episode_indicator
                SET to_patient_key = var_inspatient_key
                FROM deleted
                    WHERE move_episode_indicator.to_patient_key = deleted.patient_key;
                /* 20131101 - update from_patient_key and to_patient_key of move_episode_indicator_log table when updating patient key */
                UPDATE move_episode_indicator_log
                SET from_patient_key = var_inspatient_key
                FROM deleted
                    WHERE move_episode_indicator_log.from_patient_key = deleted.patient_key;
                UPDATE move_episode_indicator_log
                SET to_patient_key = var_inspatient_key
                FROM deleted
                    WHERE move_episode_indicator_log.to_patient_key = deleted.patient_key;
                /* 20060213 SL - Upd pp_opt_out */
                UPDATE pp_opt_out
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE pp_opt_out.patient_key = deleted.patient_key;
                /* 20061013 SL - Upd hkpmi_patient_address_list & hkpmi_patient_address_log */
                UPDATE hkpmi_patient_address_list
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE hkpmi_patient_address_list.patient_key = deleted.patient_key;
                UPDATE hkpmi_patient_address_log
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE hkpmi_patient_address_log.patient_key = deleted.patient_key;
                /* Yorky: Update hkpmi_patient_language and hkpmi_patient_language_log */
                UPDATE hkpmi_patient_language
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE hkpmi_patient_language.patient_key = deleted.patient_key;
                UPDATE hkpmi_patient_language_log
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE hkpmi_patient_language_log.patient_key = deleted.patient_key;
                /* Yorky: Update hkpmi_patient_travel_record and hkpmi_patient_travel_log */
                UPDATE hkpmi_patient_travel_record
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE hkpmi_patient_travel_record.patient_key = deleted.patient_key;
                UPDATE hkpmi_patient_travel_log
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE hkpmi_patient_travel_log.patient_key = deleted.patient_key;
                /* Jessica: Update hkpmi_patient_cvi_record and hkpmi_patient_cvi_dose_info */
                UPDATE hkpmi_patient_cvi_record
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE hkpmi_patient_cvi_record.patient_key = deleted.patient_key;
                UPDATE hkpmi_patient_cvi_dose_info
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE hkpmi_patient_cvi_dose_info.patient_key = deleted.patient_key;
                /* Harmonic: Update hkpmi_patient_cvi_mex */
                UPDATE hkpmi_patient_cvi_mex
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE hkpmi_patient_cvi_mex.patient_key = deleted.patient_key;
                /* Harmonic (20230803): Update patient_geoaddress_detail */
                -- UPDATE patient_geoaddress_detail
                -- SET patient_key = var_inspatient_key
                -- FROM deleted
                --     WHERE patient_geoaddress_detail.patient_key = deleted.patient_key;
                /* Harmonic (20230803): Update nok_geoaddress_detail */
                -- UPDATE nok_geoaddress_detail
                -- SET patient_key = var_inspatient_key
                -- FROM deleted
                --     WHERE nok_geoaddress_detail.patient_key = deleted.patient_key;
                /* ---20130719 --- */
                UPDATE patient_doc_info
                SET patient_key = var_inspatient_key
                FROM deleted
                    WHERE patient_doc_info.patient_key = deleted.patient_key;
                /* --20130930 -- */
                /* --update hkpmi_patient_info_log		--- Unique Key is : (patient_key,info_type,upd_dtm) */
                
                /* --	set hkpmi_patient_info_log.patient_key = @inspatient_key */
                
                /* --	from hkpmi_patient_info_log, deleted */
                
                /* --		where hkpmi_patient_info_log.patient_key = deleted.patient_key */
                
                /* ---20140531 --- */
                UPDATE ehr_patient_list
                SET pas_pky = var_inspatient_key, sys_dtm = timestamp_convert(localtimestamp)
                FROM deleted
                    WHERE ehr_patient_list.pas_pky = deleted.patient_key;
            END;
        END IF;
        /* ------------------------------------------------------- */
        /* 20130508 update patient_doc_info doc_code/doc_no */
        /* ------------------------------------------------------- */
        IF NOT EXISTS (SELECT
            *
            FROM patient_doc_info
            WHERE patient_key = var_inspatient_key) THEN
            BEGIN
                INSERT INTO patient_doc_info (patient_key, doc_code, doc_no, upd_by, upd_hosp, upd_sys, upd_dtm)
                VALUES (var_inspatient_key, var_ins_doc_code, var_ins_doc_no, var_ins_upd_by, var_ins_upd_hosp, var_ins_upd_sys, var_inssystem_dtm);
                /* select patient_key,@ins_doc_code,@ins_doc_no,update_by, update_hospital, source_system,system_dtm */
                
                /* --		from inserted */
            END;
        ELSE
            BEGIN
                /* -------record exist for update ---------- */
                /* 20131213 --- */
                SELECT
                    doc_code
                    INTO var_org_patient_doc_info_doc
                    FROM patient_doc_info
                    WHERE patient_doc_info.patient_key = var_inspatient_key;

                IF RTRIM(LTRIM(var_org_patient_doc_info_doc)) is NULL OR RTRIM(LTRIM(var_org_patient_doc_info_doc)) = '' THEN
                    SELECT
                        NULL
                        INTO var_org_patient_doc_info_doc;
                END IF;
                /* ---if (@del_doc_code != @ins_doc_code) or  (@del_doc_no != @ins_doc_no) */
                IF (var_del_doc_code != var_ins_doc_code) OR (var_del_doc_no != var_ins_doc_no) OR (var_ins_doc_code != var_org_patient_doc_info_doc) THEN /* ---20131213 */
                    BEGIN
                        UPDATE patient_doc_info
                        SET doc_code = var_ins_doc_code, doc_no = var_ins_doc_no, upd_by = update_by, upd_hosp = update_hospital, upd_sys = source_system, upd_dtm = system_dtm
                        FROM inserted
                            WHERE patient_doc_info.patient_key = inserted.patient_key;
                        /* ----------------------------------------------------------------- */
                        /* ---20130930 hkpmi_patient_info_log.info_type is : <D> --- */
                        INSERT INTO hkpmi_patient_info_log (patient_key, info_type, doc_code, doc_no, old_doc_code, old_doc_no, upd_by, upd_hosp, upd_sys, upd_dtm)
                        VALUES (var_inspatient_key, 'D', var_ins_doc_code, var_ins_doc_no, var_org_patient_doc_info_doc, var_del_doc_no, var_ins_upd_by, var_ins_upd_hosp, var_ins_upd_sys, var_inssystem_dtm);
                        /* --	values (@inspatient_key,'D',@ins_doc_code,@ins_doc_no,@del_doc_code,@del_doc_no, @ins_upd_by, @ins_upd_hosp,@ins_upd_sys,@inssystem_dtm) */
                    END;
                END IF;
            END;
        END IF;
        /* ----------------------------------------------------------------- */
        /* ---20130930 hkpmi_patient_info_log.info_type is : <S> --- */
        IF (var_del_hkic_sym != var_ins_hkic_sym) THEN
            BEGIN
                INSERT INTO hkpmi_patient_info_log (patient_key, info_type, hkic_symbol, old_hkic_symbol, upd_by, upd_hosp, upd_sys, upd_dtm)
                VALUES (var_inspatient_key, 'S', var_ins_hkic_sym, var_del_hkic_sym, var_ins_upd_by, var_ins_upd_hosp, var_ins_upd_sys, var_inssystem_dtm);
            END;
        END IF;
        /* ----------------------------------------------------------------- */
        /* patient_type R/92 patient ON CHILD UPDATE RESTRICT */
        IF var_delpatient_type != var_inspatient_type THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, patient_type
                    WHERE inserted.patient_type = patient_type.patient_type;
                SELECT
                    COUNT(*)
                    INTO var_nullcnt
                    FROM inserted
                    WHERE inserted.patient_type IS NULL;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        SELECT
                            200041
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* religion R/80 patient ON CHILD UPDATE RESTRICT */
        IF update$religion THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, religion
                    WHERE inserted.religion = religion.religion_code;
                SELECT
                    COUNT(*)
                    INTO var_nullcnt
                    FROM inserted
                    WHERE inserted.religion IS NULL;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        SELECT
                            200042
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;

        IF update$hkid THEN
            BEGIN
                CALL cpi_pq_validate_hkid(var_return_code, var_inshkid, var_valid_flag);

                IF var_return_code < 0 THEN
                    BEGIN
                        SELECT
                            200072
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;

                IF var_return_code = 1 THEN
                    BEGIN
                        SELECT
                            200048
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;

                IF var_return_code = 2 THEN
                    BEGIN
                        SELECT
                            200049
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
                /* insert hkid to hkpmi_used_unhkid if it is an unknow ID and not exists in table */
                IF var_delhkid != var_inshkid AND var_delhkid LIKE 'U%' THEN
                    BEGIN
                        BEGIN
                            IF NOT EXISTS (SELECT
                                *
                                FROM hkpmi_used_unhkid
                                WHERE hkid = var_delhkid) THEN
                                INSERT INTO hkpmi_used_unhkid (hkid, create_dtm, block_type, request_hosp, request_by, filler)
                                VALUES (var_delhkid, timestamp_convert(localtimestamp), 'U', NULL, 'ADT', NULL);
                            END IF;
                            EXCEPTION
                                WHEN others THEN
                                    BEGIN
                                        SELECT
                                            200072
                                            INTO var_errno;
                                        EXIT error;
                                    END;
                        END;
                    END;
                END IF;
            END;
        END IF;

        IF NOT EXISTS (SELECT
            *
            FROM inserted
            WHERE source_system = 'DNL') THEN
            BEGIN
                IF update$cccode1 AND (var_inscccode1 is not NULL) THEN
                    BEGIN
                        IF NOT EXISTS (SELECT
                            *
                            FROM ccc_big5
                            WHERE ccc_big5.ccc_head = SUBSTRING(var_inscccode1, 1, 4) AND ccc_big5.ccc_tail = SUBSTRING(var_inscccode1, 5, 1)) THEN
                            BEGIN
                                SELECT
                                    200057
                                    INTO var_errno;
                                EXIT error;
                            END;
                        END IF;
                    END;
                END IF;

                IF update$cccode2 AND (var_inscccode2 is not NULL) THEN
                    BEGIN
                        IF NOT EXISTS (SELECT
                            *
                            FROM ccc_big5
                            WHERE ccc_big5.ccc_head = SUBSTRING(var_inscccode2, 1, 4) AND ccc_big5.ccc_tail = SUBSTRING(var_inscccode2, 5, 1)) THEN
                            BEGIN
                                SELECT
                                    200058
                                    INTO var_errno;
                                EXIT error;
                            END;
                        END IF;
                    END;
                END IF;

                IF update$cccode3 AND (var_inscccode3 is not NULL) THEN
                    BEGIN
                        IF NOT EXISTS (SELECT
                            *
                            FROM ccc_big5
                            WHERE ccc_big5.ccc_head = SUBSTRING(var_inscccode3, 1, 4) AND ccc_big5.ccc_tail = SUBSTRING(var_inscccode3, 5, 1)) THEN
                            BEGIN
                                SELECT
                                    200059
                                    INTO var_errno;
                                EXIT error;
                            END;
                        END IF;
                    END;
                END IF;

                IF update$cccode4 AND (var_inscccode4 is not NULL) THEN
                    BEGIN
                        IF NOT EXISTS (SELECT
                            *
                            FROM ccc_big5
                            WHERE ccc_big5.ccc_head = SUBSTRING(var_inscccode4, 1, 4) AND ccc_big5.ccc_tail = SUBSTRING(var_inscccode4, 5, 1)) THEN
                            BEGIN
                                SELECT
                                    200060
                                    INTO var_errno;
                                EXIT error;
                            END;
                        END IF;
                    END;
                END IF;

                IF update$cccode5 AND (var_inscccode5 is not NULL) THEN
                    BEGIN
                        IF NOT EXISTS (SELECT
                            *
                            FROM ccc_big5
                            WHERE ccc_big5.ccc_head = SUBSTRING(var_inscccode5, 1, 4) AND ccc_big5.ccc_tail = SUBSTRING(var_inscccode5, 5, 1)) THEN
                            BEGIN
                                SELECT
                                    200061
                                    INTO var_errno;
                                EXIT error;
                            END;
                        END IF;
                    END;
                END IF;

                IF update$cccode6 AND (var_inscccode6 is not NULL) THEN
                    BEGIN
                        IF NOT EXISTS (SELECT
                            *
                            FROM ccc_big5
                            WHERE ccc_big5.ccc_head = SUBSTRING(var_inscccode6, 1, 4) AND ccc_big5.ccc_tail = SUBSTRING(var_inscccode6, 5, 1)) THEN
                            BEGIN
                                SELECT
                                    200062
                                    INTO var_errno;
                                EXIT error;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;

        IF update$dob THEN
            BEGIN
                IF (var_insdob > localtimestamp) THEN
                    BEGIN
                        SELECT
                            200077
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;

        IF update$exact_dob_flag THEN
            BEGIN
                IF ((SELECT
                    exact_dob_flag
                    FROM inserted) = 'N') AND ((date_part('month', var_insdob::TIMESTAMP) != 1) OR (date_part('day', var_insdob::TIMESTAMP) != 1)) THEN
                    BEGIN
                        SELECT
                            200083
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* race R/79 patient ON CHILD UPDATE RESTRICT */
        IF update$race THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, race
                    WHERE inserted.race = race.race_code;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        SELECT
                            200043
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* district R/77 patient ON CHILD UPDATE RESTRICT */
        IF (update$district OR update$building OR update$floor OR update$block OR update$room) AND ((SELECT
            source_system
            FROM inserted) != 'DNL') THEN
            BEGIN
                IF EXISTS (SELECT
                    *
                    FROM inserted
                    WHERE inserted.district IS NULL AND (inserted.building IS NOT NULL OR floor IS NOT NULL OR inserted.block IS NOT NULL OR inserted.room IS NOT NULL OR inserted.building != ' ' OR floor != ' ' OR inserted.block != ' ' OR inserted.room != ' ')) THEN
                    BEGIN
                        SELECT
                            200063
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, district
                    WHERE inserted.district = district.district_code;
                SELECT
                    COUNT(*)
                    INTO var_nullcnt
                    FROM inserted
                    WHERE inserted.district IS NULL;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        SELECT
                            200044
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;

        IF update$update_hospital THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, hospital
                    WHERE inserted.update_hospital = hospital.hospital_code;
                /* add to recongize update hospital from other source table */
                /* by Mabel Lau 22061999 */
                IF var_validcnt < 1 THEN
                    SELECT
                        COUNT(*)
                        INTO var_validcnt
                        FROM inserted, other_source
                        WHERE inserted.update_hospital = other_source.source_code;
                END IF;
                /* end of modification */
                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        SELECT
                            200079
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;

        IF update$source_system_dtm THEN
            BEGIN
                IF (var_inssource_system_dtm < var_delsource_system_dtm) THEN
                    BEGIN
                        SELECT
                            200110
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;

        IF update$system_dtm THEN
            BEGIN
                IF (var_inssystem_dtm <= var_delsystem_dtm) THEN
                    BEGIN
                        SELECT
                            200111
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /*
        if @inshkid != @delhkid
        begin
           update patient_key_changed
              set original_hkid     = @inshkid
              where patient_key     = @delpatient_key and
                    original_hkid   = @delhkid
        
           if @@error != 0
              return
        
        end
        */
        IF var_delhkid != var_inshkid OR var_delpatient_name != var_inspatient_name OR var_delsex != var_inssex OR var_deldob != var_insdob THEN
            BEGIN
                /*
                if not exists
                         (select *
                            from    patient_key_changed
                            where   patient_key     = @inspatient_key and
                                    original_hkid   = @inshkid
                         )
                      begin
                
                      	insert patient_key_changed
                            (patient_key, original_hkid, source_system_dtm,
                				 hkid, patient_name,
                             sex, cccode1, cccode2, cccode3,
                             cccode4, cccode5, cccode6,
                             dob, update_hospital,
                             update_by)
                            select
                                @inspatient_key, @inshkid, source_system_dtm,
                					 @delhkid, @delpatient_name,
                                @delsex, @delcccode1, @delcccode2, @delcccode3,
                                @delcccode4, @delcccode5, @delcccode6,
                                @deldob, update_hospital,
                                update_by
                              from deleted
                
                        if @@error != 0
                           return
                      end
                
                      insert patient_key_changed
                          (patient_key, original_hkid, source_system_dtm,
                			  hkid, patient_name,
                           sex, cccode1, cccode2, cccode3,
                           cccode4, cccode5, cccode6,
                           dob, update_hospital,
                           update_by)
                          select
                              @inspatient_key, @inshkid, source_system_dtm,
                				  @inshkid, @inspatient_name,
                              @inssex, @inscccode1, @inscccode2, @inscccode3,
                              @inscccode4, @inscccode5, @inscccode6,
                              @insdob, update_hospital,
                              update_by
                            from inserted
                */
                BEGIN
                    INSERT INTO patient_key_changed (old_hkid, system_dtm, old_patient_name, old_sex, old_dob, new_hkid, new_patient_name, new_sex, new_dob, new_patient_key, update_by, hospital_code)
                    SELECT
                        var_delhkid, var_inssystem_dtm, var_delpatient_name, var_delsex, var_deldob, var_inshkid, var_inspatient_name, var_inssex, var_insdob, var_inspatient_key, update_by, update_hospital
                        FROM inserted;
                    EXCEPTION
                        WHEN others THEN
                            RETURN NULL;
                END;
            END;
        END IF;
        INSERT INTO patient_history (patient_key, religion, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_diagnosis, death_external_cause, patient_type, pcs_count, access_code, update_hospital, source_system, update_by, source_system_dtm, system_dtm, filler)
        SELECT
            patient_key, religion, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_diagnosis, death_external_cause, patient_type, pcs_count, access_code, update_hospital, source_system, update_by, source_system_dtm, timestamp_convert(system_dtm), filler
            FROM deleted;
        RETURN NULL;
    END;
    RAISE EXCEPTION USING ERRCODE := var_errno;
    RETURN NULL;
END;
$function$
;


ALTER FUNCTION "fn_tU_patient" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
