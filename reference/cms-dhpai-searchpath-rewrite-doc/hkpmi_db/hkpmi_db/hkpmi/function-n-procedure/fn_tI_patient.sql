-- DROP FUNCTION hkpmi."fn_tI_patient"();

CREATE OR REPLACE FUNCTION hkpmi."fn_tI_patient"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* ************************************************************************* */
/* 200409115 - update to insert hkpmi_used_unhkid for any unhkid involved */
/* in update and delete by Leo Lee */
/* 20050923 - update from_patient_key and to_patient_key of */
/* move_episode_indicator table when updating patient key */
/* 20130508 : patient_doc_info */
/* ************************************************************************* */
/* INSERT trigger on patient */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    var_errno INTEGER;
    var_errmsg VARCHAR(255);
    var_valid_flag VARCHAR(1);
    var_return_code INTEGER;
    var_delcccode1 VARCHAR(5);
    var_delcccode2 VARCHAR(5);
    var_delcccode3 VARCHAR(5);
    var_delcccode4 VARCHAR(5);
    var_delcccode5 VARCHAR(5);
    var_delcccode6 VARCHAR(5);
    var_inshkid VARCHAR(12);
    var_insdob TIMESTAMP WITHOUT TIME ZONE;
    var_inscccode1 VARCHAR(5);
    var_inscccode2 VARCHAR(5);
    var_inscccode3 VARCHAR(6);
    var_inscccode4 VARCHAR(5);
    var_inscccode5 VARCHAR(5);
    var_inscccode6 VARCHAR(5);
    var_ins_pky VARCHAR(8);
    var_ins_doc_code VARCHAR(1);
    var_rowcount$aws$ INTEGER;
    update$patient_type BOOLEAN = false;
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
    update$room BOOLEAN = false;
    update$block BOOLEAN = false;
    update$update_hospital BOOLEAN = false;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$patient_type = TRUE;
            WHEN 'UPDATE' THEN
                update$patient_type = ((SELECT
                    array_agg(patient_type)
                    FROM deleted) != (SELECT
                    array_agg(patient_type)
                    FROM inserted));
            ELSE
                update$patient_type := FALSE;
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
        END IF;
        var_numrows := var_rowcount$aws$;

        IF var_numrows > 1 THEN
            BEGIN
                SELECT
                    200047
                    INTO var_errno;
                EXIT error;
            END;
        END IF;
        SELECT
            hkid, dob, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, patient_key, SUBSTRING(filler, 1, 1)
            INTO var_inshkid, var_insdob, var_inscccode1, var_inscccode2, var_inscccode3, var_inscccode4, var_inscccode5, var_inscccode6, var_ins_pky, var_ins_doc_code
            FROM inserted;

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

        IF RTRIM(LTRIM(var_ins_doc_code)) is NULL OR RTRIM(LTRIM(var_ins_doc_code)) = '' THEN
            SELECT
                NULL
                INTO var_ins_doc_code;
        END IF;

        IF update$patient_type THEN
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
                            200036
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* religion R/80 patient ON CHILD INSERT RESTRICT */
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
                            200037
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;

        IF update$hkid THEN
            begin
	            raise notice 'var_inshkid:%,var_valid_flag:%',var_inshkid, var_valid_flag;
                CALL cpi_pq_validate_hkid(var_return_code, var_inshkid, var_valid_flag);
				raise notice 'var_return_code:%', var_return_code;
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
                            200045
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;

                IF var_return_code = 2 THEN
                    BEGIN
                        SELECT
                            200046
                            INTO var_errno;
                        EXIT error;
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
                                    200051
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
                                    200052
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
                                    200053
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
                                    200054
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
                                    200055
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
                                    200056
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
                            200074
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;

        IF update$exact_dob_flag or update$dob THEN
            BEGIN
                IF ((SELECT
                    exact_dob_flag
                    FROM inserted) = 'N') AND ((date_part('month', var_insdob::TIMESTAMP) != 1) OR (date_part('day', var_insdob::TIMESTAMP) != 1)) THEN
                    BEGIN
                        SELECT
                            200084
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* race R/79 patient ON CHILD INSERT RESTRICT */
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
                            200038
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* district R/77 patient ON CHILD INSERT RESTRICT */
        IF (update$district OR update$building OR update$floor OR update$room OR update$block) AND ((SELECT
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
                            200039
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* hospital R/85 pmi_case ON CHILD UPDATE RESTRICT */
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

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        SELECT
                            200108
                            INTO var_errno;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* 20130508 - insert patietn_doc_info */
        IF NOT EXISTS (SELECT
            *
            FROM patient_doc_info
            WHERE patient_key = var_ins_pky) THEN
            BEGIN
                INSERT INTO patient_doc_info (patient_key, doc_code, doc_no, upd_by, upd_hosp, upd_sys, upd_dtm)
                SELECT
                    patient_key, var_ins_doc_code, other_doc_no, update_by, update_hospital, source_system, system_dtm
                    FROM inserted;
            END;
        END IF;
        RETURN NULL;
    END;
    RAISE EXCEPTION USING ERRCODE := var_errno;
    RETURN NULL;
END;
$function$
;

ALTER FUNCTION "fn_tI_patient" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
