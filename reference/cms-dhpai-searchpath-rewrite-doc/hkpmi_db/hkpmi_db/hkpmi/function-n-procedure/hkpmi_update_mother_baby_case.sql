-- DROP PROCEDURE hkpmi.hkpmi_update_mother_baby_case(inout int4, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in int4, in int4, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in timestamp, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_update_mother_baby_case(INOUT pas_return_code integer, IN par_hospital_code varchar, IN par_mother_hospital varchar, IN par_mother_case varchar,
 IN par_baby_hospital varchar, IN par_baby_case varchar, IN par_birth_order integer, IN par_pregnancy_number integer, IN par_birth_place varchar, IN par_birth_location varchar, 
 IN par_update_by varchar, IN par_transaction_type varchar, IN par_source_system varchar, IN par_source_system_datetime timestamp without time zone, IN par_old_mother_hospital varchar, 
 IN par_old_mother_case varchar, IN par_old_baby_hospital varchar, IN par_old_baby_case varchar, IN par_mother_hkid varchar DEFAULT NULL::varchar, IN par_mother_patient_key varchar DEFAULT NULL::varchar, 
 IN par_new_born_hkid varchar DEFAULT NULL::varchar, IN par_new_born_patient_key varchar DEFAULT NULL::varchar, IN par_old_patient_key varchar DEFAULT NULL::varchar, IN par_update_if_different varchar DEFAULT 'N'::varchar)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_mo_hosp_2 VARCHAR(3);
    var_mo_case_2 VARCHAR(12);
    var_nb_hosp_2 VARCHAR(3);
    var_nb_case_2 VARCHAR(12);
    var_mo_hosp_hn VARCHAR(3);
    var_mo_case_hn VARCHAR(12);
    var_nb_hosp_hn VARCHAR(3);
    var_nb_case_hn VARCHAR(12);
    var_mo_prk VARCHAR(8);
    var_nb_prk VARCHAR(8);
    var_mo_dsch_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_nb_dsch_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_mo_dsch_code VARCHAR(1);
    var_nb_dsch_code VARCHAR(1);
    var_mo_dsch_dtm_2 TIMESTAMP WITHOUT TIME ZONE;
    var_nb_dsch_dtm_2 TIMESTAMP WITHOUT TIME ZONE;
    var_error_code INTEGER;
    var_begin_tran VARCHAR(1);
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_tran_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_mo_hkid VARCHAR(12);
    var_nb_hkid VARCHAR(12);
    var_filler VARCHAR(255);
    var_upload_status VARCHAR(1);
    var_old_mo_prk VARCHAR(8);
    var_old_nb_prk VARCHAR(8);
    var_nb_dob TIMESTAMP WITHOUT TIME ZONE;
    var_old_mo_hosp VARCHAR(3);
    var_old_mo_case VARCHAR(12);
    var_old_mo_hosp_2 VARCHAR(3);
    var_old_mo_case_2 VARCHAR(12);
    var_old_mo_hosp_hn VARCHAR(3);
    var_old_mo_case_hn VARCHAR(12);
    var_old_nb_hosp VARCHAR(3);
    var_old_nb_case VARCHAR(12);
    var_old_nb_hosp_2 VARCHAR(3);
    var_old_nb_case_2 VARCHAR(12);
    var_old_nb_hosp_hn VARCHAR(3);
    var_old_nb_case_hn VARCHAR(12);
	error_sqlstate BIGINT;
	my_conn varchar;
    sql$rowcount BIGINT;
   	error_message text;
begin
	SET search_path TO hkpmi, public;
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN
            <<normal_end>>
            BEGIN
                SELECT
                    0, timestamp_convert(localtimestamp)
                    INTO var_error_code, var_update_datetime;

                /* invalid transaction type */
                /* --	if @transaction_type not in ('260', '261', '262') or */
                /* --		@source_system <> 'ADT' */
				select 'Y' into var_begin_tran;
                IF par_transaction_type NOT IN ('260', '261', '262') THEN
                    BEGIN
                        SELECT
                            200014
                            INTO var_error_code;
                        EXIT return_error;
                    END;
                END IF;

                IF par_baby_case IS NULL THEN
                    BEGIN
                        CALL hkpmi_update_new_born(pas_return_code, par_hospital_code, par_transaction_type, par_source_system_datetime, par_update_by, par_source_system, par_mother_hkid, par_mother_patient_key, par_mother_case, par_birth_order, par_pregnancy_number, par_new_born_patient_key, par_new_born_hkid, par_old_patient_key, var_error_code);


                        IF var_error_code <> 0 THEN
                            BEGIN
                                EXIT return_error;
                            END;
                        END IF;
                        EXIT normal_end;
                    END;
                END IF;

                IF par_transaction_type = '260' AND EXISTS (SELECT
                    *
                    FROM mother_baby_case
                    WHERE mother_hospital_code = par_mother_hospital AND mother_case_no = par_mother_case AND baby_hospital_code = par_baby_hospital AND baby_case_no = par_baby_case AND active_status = 'Y') THEN
                    BEGIN
                        SELECT
                            200166
                            INTO var_error_code;
                        EXIT return_error;
                    END;
                END IF;

                IF par_transaction_type IN ('262', '261') AND NOT EXISTS (SELECT
                    *
                    FROM mother_baby_case
                    WHERE mother_hospital_code = par_old_mother_hospital AND mother_case_no = par_old_mother_case AND baby_hospital_code = par_old_baby_hospital AND baby_case_no = par_old_baby_case AND active_status = 'Y') THEN
                    /*
                    where mother_hospital_code = @mother_hospital
                    and mother_case_no = @mother_case
                    and baby_hospital_code = @baby_hospital
                    and baby_case_no = @baby_case)
                    */
                    BEGIN
                        SELECT
                            200166
                            INTO var_error_code;
                        EXIT return_error;
                    END;
                END IF;
                SELECT
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                    INTO var_mo_case_2, var_mo_hosp_2, var_mo_case_hn, var_mo_hosp_hn, var_nb_hosp_2, var_nb_case_2, var_nb_hosp_hn, var_nb_case_hn, var_old_mo_prk, var_old_nb_prk;

                BEGIN
                    SELECT
                        patient_key, discharge_dtm, discharge_code
                        INTO var_mo_prk, var_mo_dsch_dtm, var_mo_dsch_code
                        FROM pmi_case
                        WHERE hospital_code = par_mother_hospital AND case_no = par_mother_case;
                    raise notice 'par_mother_hospital=%,par_mother_case=%',par_mother_hospital,par_mother_case;
                    var_error_code := 0;
                    EXCEPTION
                        WHEN OTHERS then
                            GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                END;

                IF var_error_code <> 0 THEN
                    BEGIN
                        EXIT return_system_error;
                    END;
                END IF;

                BEGIN
                    SELECT
                        hkid
                        INTO var_mo_hkid
                        FROM patient
                        WHERE patient_key = var_mo_prk;
                    var_error_code := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                END;

                IF var_error_code <> 0 THEN
                    BEGIN
                        EXIT return_system_error;
                    END;
                END IF;

                BEGIN
                    SELECT
                        patient_key, discharge_dtm, discharge_code
                        INTO var_nb_prk, var_nb_dsch_dtm, var_nb_dsch_code
                        FROM pmi_case
                        WHERE hospital_code = par_baby_hospital AND case_no = par_baby_case;
                    raise notice 'par_baby_hospital=%,par_baby_case=%',par_baby_hospital,par_baby_case;
                    var_error_code := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                END;

                IF var_error_code <> 0 THEN
                    BEGIN
                        EXIT return_system_error;
                    END;
                END IF;

                BEGIN
                    SELECT
                        hkid, dob
                        INTO var_nb_hkid, var_nb_dob
                        FROM patient
                        WHERE patient_key = var_nb_prk;
                    var_error_code := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                END;

                IF var_error_code <> 0 THEN
                    BEGIN
                        EXIT return_system_error;
                    END;
                END IF;

                IF par_transaction_type IN ('261', '262') THEN
                    BEGIN
                        BEGIN
                            SELECT
                                patient_key
                                INTO var_old_nb_prk
                                FROM pmi_case
                                WHERE hospital_code = par_old_baby_hospital AND case_no = par_old_baby_case;
                            var_error_code := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                        END;

                        IF var_error_code <> 0 THEN
                            BEGIN
                                EXIT return_system_error;
                            END;
                        END IF;

                        BEGIN
                            SELECT
                                patient_key
                                INTO var_old_mo_prk
                                FROM pmi_case
                                WHERE hospital_code = par_old_mother_hospital AND case_no = par_old_mother_case;
                            var_error_code := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                        END;

                        IF var_error_code <> 0 THEN
                            BEGIN
                                EXIT return_system_error;
                            END;
                        END IF;
                    END;
                END IF;
                /* select other cases for mother */
                IF par_mother_case SIMILAR TO ' HN%' THEN
                    SELECT
                        par_mother_hospital, par_mother_case
                        INTO var_mo_hosp_hn, var_mo_case_hn;
                ELSE
                    BEGIN
                        SELECT
                            hospital_code, case_no, discharge_dtm
                            INTO var_mo_hosp_2, var_mo_case_2, var_mo_dsch_dtm_2
                            FROM (SELECT
                                hospital_code, case_no, discharge_dtm, patient_key, adm_dtm
                                FROM pmi_case) AS ungrouped_query
                            INNER JOIN (SELECT
                                patient_key, MIN(adm_dtm) AS min_1
                                FROM pmi_case
                                WHERE patient_key = var_mo_prk AND adm_dtm >= var_nb_dob AND adm_dtm < 3 * INTERVAL '1 day' + var_nb_dob::TIMESTAMP AND case_type IN ('A', 'I') AND (hospital_code <> par_mother_hospital OR case_no <> par_mother_case)
                                GROUP BY patient_key) AS grouped_query
                                ON (ungrouped_query.patient_key = grouped_query.patient_key OR (ungrouped_query.patient_key IS NULL AND grouped_query.patient_key IS NULL))
                            WHERE adm_dtm = min_1;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF sql$rowcount = 0 THEN
                            SELECT
                                NULL, NULL, NULL
                                INTO var_mo_hosp_2, var_mo_case_2, var_mo_dsch_dtm_2;
                        END IF;

                        IF var_mo_case_2 SIMILAR TO ' HN%' THEN
                            SELECT
                                var_mo_hosp_2, var_mo_case_2
                                INTO var_mo_hosp_hn, var_mo_case_hn;
                        ELSE
                            BEGIN
                                SELECT
                                    hospital_code, case_no
                                    INTO var_mo_hosp_hn, var_mo_case_hn
                                    FROM (SELECT
                                        hospital_code, case_no, patient_key, adm_dtm, source_indicator
                                        FROM pmi_case) AS ungrouped_query
                                    INNER JOIN (SELECT
                                        patient_key, MIN(adm_dtm) AS min_1
                                        FROM pmi_case
                                        WHERE patient_key = var_mo_prk AND adm_dtm >= var_nb_dob AND adm_dtm < 3 * INTERVAL '1 day' + var_nb_dob::TIMESTAMP AND case_type IN ('I')
                                        GROUP BY patient_key) AS grouped_query
                                        ON (ungrouped_query.patient_key = grouped_query.patient_key OR (ungrouped_query.patient_key IS NULL AND grouped_query.patient_key IS NULL))
                                    WHERE adm_dtm = min_1 AND source_indicator = '3';
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                IF sql$rowcount = 0 THEN
                                    SELECT
                                        NULL, NULL
                                        INTO var_mo_hosp_hn, var_mo_case_hn;
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;
                /* select other cases for mother */
                IF par_baby_case SIMILAR TO ' HN%' THEN
                    SELECT
                        par_baby_hospital, par_baby_case
                        INTO var_nb_hosp_hn, var_nb_case_hn;
                ELSE
                    BEGIN
                        SELECT
                            hospital_code, case_no, discharge_dtm
                            INTO var_nb_hosp_2, var_nb_case_2, var_nb_dsch_dtm_2
                            FROM (SELECT
                                hospital_code, case_no, discharge_dtm, patient_key, adm_dtm
                                FROM pmi_case) AS ungrouped_query
                            INNER JOIN (SELECT
                                patient_key, MIN(adm_dtm) AS min_1
                                FROM pmi_case
                                WHERE patient_key = var_nb_prk AND adm_dtm >= var_nb_dob AND adm_dtm < 3 * INTERVAL '1 day' + var_nb_dob::TIMESTAMP AND case_type IN ('A', 'I') AND (hospital_code <> par_baby_hospital OR case_no <> par_baby_case)
                                GROUP BY patient_key) AS grouped_query
                                ON (ungrouped_query.patient_key = grouped_query.patient_key OR (ungrouped_query.patient_key IS NULL AND grouped_query.patient_key IS NULL))
                            WHERE adm_dtm = min_1;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF sql$rowcount = 0 THEN
                            SELECT
                                NULL, NULL, NULL
                                INTO var_nb_hosp_2, var_nb_case_2, var_nb_dsch_dtm_2;
                        END IF;

                        IF var_nb_case_2 SIMILAR TO ' HN%' THEN
                            SELECT
                                var_nb_hosp_2, var_nb_case_2
                                INTO var_nb_hosp_hn, var_nb_case_hn;
                        ELSE
                            BEGIN
                                SELECT
                                    hospital_code, case_no
                                    INTO var_nb_hosp_hn, var_nb_case_hn
                                    FROM (SELECT
                                        hospital_code, case_no, patient_key, adm_dtm, source_indicator
                                        FROM pmi_case) AS ungrouped_query
                                    INNER JOIN (SELECT
                                        patient_key, MIN(adm_dtm) AS min_1
                                        FROM pmi_case
                                        WHERE patient_key = var_nb_prk AND adm_dtm >= var_nb_dob AND adm_dtm < 3 * INTERVAL '1 day' + var_nb_dob::TIMESTAMP AND case_type IN ('I')
                                        GROUP BY patient_key) AS grouped_query
                                        ON (ungrouped_query.patient_key = grouped_query.patient_key OR (ungrouped_query.patient_key IS NULL AND grouped_query.patient_key IS NULL))
                                    WHERE adm_dtm = min_1 AND source_indicator = '3';
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                IF sql$rowcount = 0 THEN
                                    SELECT
                                        NULL, NULL
                                        INTO var_nb_hosp_hn, var_nb_case_hn;
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;

                IF par_transaction_type = '260' THEN
                    BEGIN
                        BEGIN
                            IF EXISTS (SELECT
                                *
                                FROM mother_baby_case
                                WHERE mother_hospital_code = par_mother_hospital AND mother_case_no = par_mother_case AND baby_hospital_code = par_baby_hospital AND baby_case_no = par_baby_case AND active_status <> 'Y') THEN
                                UPDATE mother_baby_case
                                SET mother_hospital_2 = var_mo_hosp_2, mother_case_2 = var_mo_case_2, mother_hospital_hn = var_mo_hosp_hn, mother_case_hn = var_mo_case_hn, baby_hospital_2 = var_nb_hosp_2, baby_case_2 = var_nb_case_2, baby_hospital_hn = var_nb_hosp_hn, baby_case_hn = var_nb_case_hn, birth_order = par_birth_order, pregnancy_number = par_pregnancy_number, birth_place = par_birth_place, birth_location = par_birth_location, update_by = par_update_by, update_datetime = var_update_datetime, active_status = 'Y'
                                    WHERE mother_hospital_code = par_mother_hospital AND mother_case_no = par_mother_case AND baby_hospital_code = par_baby_hospital AND baby_case_no = par_baby_case;
                            ELSE
                                INSERT INTO mother_baby_case (mother_hospital_code, mother_case_no, baby_hospital_code, baby_case_no, mother_hospital_2, mother_case_2, mother_hospital_hn, mother_case_hn, baby_hospital_2, baby_case_2, baby_hospital_hn, baby_case_hn, birth_order, pregnancy_number, birth_place, birth_location, create_by, create_datetime, update_by, update_datetime, active_status)
                                VALUES (par_mother_hospital, par_mother_case, par_baby_hospital, par_baby_case, var_mo_hosp_2, var_mo_case_2, var_mo_hosp_hn, var_mo_case_hn, var_nb_hosp_2, var_nb_case_2, var_nb_hosp_hn, var_nb_case_hn, par_birth_order, par_pregnancy_number, par_birth_place, par_birth_location, par_update_by, var_update_datetime, par_update_by, var_update_datetime, 'Y');
                            END IF;
                            var_error_code := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                        END;

                        IF var_error_code <> 0 THEN
                            EXIT return_system_error;
                        END IF;

                        IF NOT EXISTS (SELECT
                            *
                            FROM new_born
                            WHERE mother_patient_key = var_mo_prk AND new_born_patient_key = var_nb_prk AND hospital_code = par_mother_hospital) THEN
                            BEGIN
                                begin
	                                raise notice 'var_mo_prk=%,var_nb_prk=%',var_mo_prk,var_nb_prk;
                                    INSERT INTO new_born (mother_patient_key, new_born_patient_key, hospital_code, mother_case_no, birth_order, pregnancy_number, create_by, create_datetime, update_by, update_datetime)
                                    VALUES (var_mo_prk, var_nb_prk, par_mother_hospital, par_mother_case, par_birth_order, par_pregnancy_number, par_update_by, var_update_datetime, par_update_by, var_update_datetime);
                                    var_error_code := 0;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                                END;

                                IF var_error_code <> 0 THEN
                                    EXIT return_system_error;
                                END IF;
                            END;
                        END IF;
                        /* --		goto normal_end */
                    END;
                END IF;

                IF par_transaction_type = '261' THEN
                    BEGIN
                        IF par_update_if_different = 'Y' THEN
                            BEGIN
                                SELECT
                                    mother_hospital_2, mother_case_2, mother_hospital_hn, mother_case_hn, baby_hospital_2, baby_case_2, baby_hospital_hn, baby_case_hn
                                    INTO var_old_mo_hosp_2, var_old_mo_case_2, var_old_mo_hosp_hn, var_old_mo_case_hn, var_old_nb_hosp_2, var_old_nb_case_2, var_old_nb_hosp_hn, var_old_nb_case_hn
                                    FROM mother_baby_case
                                    WHERE mother_hospital_code = par_old_mother_hospital AND mother_case_no = par_old_mother_case AND baby_hospital_code = par_old_baby_hospital AND baby_case_no = par_old_baby_case;

                                IF var_old_mo_hosp_2 = var_mo_hosp_2 AND var_old_mo_case_2 = var_mo_case_2 AND var_old_mo_hosp_hn = var_mo_hosp_hn AND var_old_mo_case_hn = var_mo_case_hn AND var_old_nb_hosp_2 = var_nb_hosp_2 AND var_old_nb_case_2 = var_nb_case_2 AND var_old_nb_hosp_hn = var_nb_hosp_hn AND var_old_nb_case_hn = var_nb_case_hn THEN
                                    EXIT normal_end;
                                END IF;
                            END;
                        END IF;

                        IF EXISTS (SELECT
                            *
                            FROM mother_baby_case
                            WHERE mother_hospital_code = par_mother_hospital AND mother_case_no = par_mother_case AND baby_hospital_code = par_baby_hospital AND baby_case_no = par_baby_case AND active_status <> 'Y') THEN
                            BEGIN
                                BEGIN
                                    UPDATE mother_baby_case
                                    SET mother_hospital_2 = var_mo_hosp_2, mother_case_2 = var_mo_case_2, mother_hospital_hn = var_mo_hosp_hn, mother_case_hn = var_mo_case_hn, baby_hospital_2 = var_nb_hosp_2, baby_case_2 = var_nb_case_2, baby_hospital_hn = var_nb_hosp_hn, baby_case_hn = var_nb_case_hn, birth_order = par_birth_order, pregnancy_number = par_pregnancy_number, birth_place = par_birth_place, birth_location = par_birth_location, update_by = par_update_by, update_datetime = var_update_datetime, active_status = 'Y'
                                        WHERE baby_hospital_code = par_baby_hospital AND baby_case_no = par_baby_case AND mother_hospital_code = par_mother_hospital AND mother_case_no = par_mother_case;
                                    var_error_code := 0;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                                END;

                                IF var_error_code <> 0 THEN
                                    EXIT return_system_error;
                                END IF;

                                BEGIN
                                    UPDATE mother_baby_case
                                    SET update_by = par_update_by, update_datetime = var_update_datetime, active_status = 'N'
                                        WHERE baby_hospital_code = par_old_baby_hospital AND baby_case_no = par_old_baby_case AND mother_hospital_code = par_old_mother_hospital AND mother_case_no = par_old_mother_case;
                                    var_error_code := 0;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                                END;

                                IF var_error_code <> 0 THEN
                                    EXIT return_system_error;
                                END IF;
                            END;
                        ELSE
                            BEGIN
                                /*
                                where baby_hospital_code = @baby_hospital
                                and baby_case_no = @baby_case
                                and mother_hospital_code = @mother_hospital
                                and mother_case_no = @mother_case
                                */
                                BEGIN
                                    UPDATE mother_baby_case
                                    SET mother_hospital_code = par_mother_hospital, mother_case_no = par_mother_case, mother_hospital_2 = var_mo_hosp_2, mother_case_2 = var_mo_case_2, mother_hospital_hn = var_mo_hosp_hn, mother_case_hn = var_mo_case_hn, baby_hospital_code = par_baby_hospital, baby_case_no = par_baby_case, baby_hospital_2 = var_nb_hosp_2, baby_case_2 = var_nb_case_2, baby_hospital_hn = var_nb_hosp_hn, baby_case_hn = var_nb_case_hn, birth_order = par_birth_order, pregnancy_number = par_pregnancy_number, birth_place = par_birth_place, birth_location = par_birth_location, update_by = par_update_by, update_datetime = var_update_datetime
                                        WHERE baby_hospital_code = par_old_baby_hospital AND baby_case_no = par_old_baby_case AND mother_hospital_code = par_old_mother_hospital AND mother_case_no = par_old_mother_case;
                                    var_error_code := 0;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                                END;

                                IF var_error_code <> 0 THEN
                                    EXIT return_system_error;
                                END IF;
                            END;
                        END IF;

                        IF EXISTS (SELECT
                            *
                            FROM new_born
                            WHERE mother_patient_key = var_old_mo_prk AND new_born_patient_key = var_old_nb_prk AND hospital_code = par_old_mother_hospital) THEN
                            /*
                            where mother_patient_key = @mo_prk
                            and new_born_patient_key = @nb_prk
                            and hospital_code = @mother_hospital
                            and mother_case_no = @mother_case)
                            */
                            BEGIN
                                /* --				and mother_case_no = @old_mother_case */
                                /*
                                where hospital_code = @mother_hospital
                                and mother_patient_key = @mo_prk
                                and mother_case_no = @mother_case
                                and new_born_patient_key = @nb_prk
                                */
                                BEGIN
                                    UPDATE new_born
                                    SET birth_order = par_birth_order, pregnancy_number = par_pregnancy_number, mother_case_no = par_mother_case, hospital_code = par_mother_hospital, new_born_patient_key = var_nb_prk, mother_patient_key = var_mo_prk
                                        WHERE hospital_code = par_old_mother_hospital AND mother_patient_key = var_old_mo_prk AND new_born_patient_key = var_old_nb_prk;
                                    var_error_code := 0;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                                END;

                                IF var_error_code <> 0 THEN
                                    EXIT return_system_error;
                                END IF;
                            END;
                        ELSE
                            BEGIN
                                BEGIN
                                    INSERT INTO new_born (mother_patient_key, new_born_patient_key, hospital_code, mother_case_no, birth_order, pregnancy_number, create_by, create_datetime, update_by, update_datetime)
                                    VALUES (var_mo_prk, var_nb_prk, par_mother_hospital, par_mother_case, par_birth_order, par_pregnancy_number, par_update_by, var_update_datetime, par_update_by, var_update_datetime);
                                    var_error_code := 0;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                                END;

                                IF var_error_code <> 0 THEN
                                    EXIT return_system_error;
                                END IF;
                            END;
                        END IF;
                        /* --		goto normal_end */
                    END;
                END IF;

                IF par_transaction_type = '262' THEN
                    BEGIN
                        /*
                        delete from mother_baby_case
                        where mother_hospital_code = @old_mother_hospital
                        and mother_case_no = @old_mother_case
                        and baby_hospital_code = @old_baby_hospital
                        and baby_case_no = @old_baby_case
                        */
                        /*
                        where mother_hospital_code = @mother_hospital
                        and mother_case_no = @mother_case
                        and baby_hospital_code = @baby_hospital
                        and baby_case_no = @baby_case
                        */
                        BEGIN
                            UPDATE mother_baby_case
                            SET active_status = 'N'
                                WHERE mother_hospital_code = par_old_mother_hospital AND mother_case_no = par_old_mother_case AND baby_hospital_code = par_old_baby_hospital AND baby_case_no = par_old_baby_case;
                            var_error_code := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                        END;

                        IF var_error_code <> 0 THEN
                            EXIT return_system_error;
                        END IF;

                        IF EXISTS (SELECT
                            *
                            FROM new_born
                            WHERE mother_patient_key = var_old_mo_prk AND new_born_patient_key = var_old_nb_prk AND hospital_code = par_old_mother_hospital) THEN
                            /* --			and mother_case_no = @old_mother_case) */
                            /*
                            where mother_patient_key = @mo_prk
                            and new_born_patient_key = @nb_prk
                            and hospital_code = @mother_hospital
                            and mother_case_no = @mother_case)
                            */
                            BEGIN
                                /* --				and mother_case_no = @old_mother_case */
                                /*
                                where mother_patient_key = @mo_prk
                                and new_born_patient_key = @nb_prk
                                and hospital_code = @mother_hospital
                                and mother_case_no = @mother_case
                                */
                                BEGIN
                                    DELETE FROM new_born
                                        WHERE mother_patient_key = var_old_mo_prk AND new_born_patient_key = var_old_nb_prk AND hospital_code = par_old_mother_hospital;
                                    var_error_code := 0;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            GET STACKED DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT; 
                                END;

                                IF var_error_code <> 0 THEN
                                    EXIT return_system_error;
                                END IF;
                            END;
                        END IF;
                        /* --		goto normal_end */
                    END;
                END IF;
                /* insert transaction_log for admission */
                SELECT
                    var_update_datetime, CONCAT(REPEAT(' ', 11), SUBSTRING(CONCAT(par_mother_hospital, REPEAT(' ', 3)), 1, 3), SUBSTRING(CONCAT(par_baby_hospital, REPEAT(' ', 3)), 1, 3), SUBSTRING(CONCAT(par_baby_case, REPEAT(' ', 12)), 1, 12))
                    INTO var_tran_system_dtm, var_filler;

                IF par_source_system = 'DNL' THEN
                    SELECT
                        'P'
                        INTO var_upload_status;
                ELSE
                    SELECT
                        'Y'
                        INTO var_upload_status;
                END IF;

                WHILE 1 = 1 loop
	                begin
					
					INSERT INTO download.transaction_log (system_dtm, hospital_code, type, hkid, patient_key, case_no, case_access_code, pmi_access_code, old_patient_key, old_hkid, source_indicator, source_code, update_by, update_hospital, source_system, source_system_dtm, upload_status, filler)
                        VALUES (var_tran_system_dtm, par_hospital_code, par_transaction_type, var_mo_hkid, var_mo_prk, par_mother_case, par_pregnancy_number, par_birth_order, var_nb_prk, var_nb_hkid, par_birth_place, par_birth_location, par_update_by, par_hospital_code, par_source_system, par_source_system_datetime, var_upload_status, var_filler);
                    /*
                    [9996 - Severity CRITICAL - Transformer error occurred in userVariable. Please submit report to developers.]
                    select @error_code = @@error
                    */
                    var_error_code := 0;
					EXCEPTION  
					WHEN OTHERS THEN  
						
						GET STACKED  DIAGNOSTICS var_error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT;  
						
						 
						IF var_error_code = 23505 THEN  
							select var_tran_system_dtm + INTERVAL '3 milliseconds' into var_tran_system_dtm;  
							CONTINUE;
							
						ELSE  

							EXIT return_system_error;
						END IF;
                   
                   end;
                   EXIT;
                END LOOP; /* end insert transaction_log from admission */
            END;

            
            pas_return_code := 0;
            RETURN;
        END;
		raise notice 'error_message=%',error_message;
        	raise exception '';
		EXCEPTION  
			WHEN  OTHERS THEN  
--        RAISE EXCEPTION USING ERRCODE := var_error_code;
        pas_return_code := var_error_code;
        RETURN;
    END;
		raise notice 'error_message=%',error_message;
    	raise exception '';
		EXCEPTION  
			WHEN  OTHERS THEN  
    pas_return_code := var_error_code;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_update_mother_baby_case" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
