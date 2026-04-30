-- DROP PROCEDURE hkpmi.hkpmi_del_pmi(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, inout varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_del_pmi(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_txn_type character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, INOUT par_patient_key character varying, IN par_hkid character varying, IN par_patient_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_ccc1 character varying, IN par_ccc2 character varying, IN par_ccc3 character varying, IN par_ccc4 character varying, IN par_ccc5 character varying, IN par_ccc6 character varying)
 LANGUAGE plpgsql
AS $procedure$
/* transaction information */
/* patient information */
DECLARE
    /* --	@return_status				smallint, */
    var_return_error_code INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_tmp_hospital_code VARCHAR(03);
    var_tran_hospital_code VARCHAR(03);
    var_process_local_hospital VARCHAR(01);
    var_begin_tran VARCHAR(01);
    var_tran_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_hkpmi_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_upload_status VARCHAR(01);
    var_hkpmi_timestamp timestamp(6);
    /* patient information */
    var_hkpmi_patient_key VARCHAR(08);
    var_hkpmi_patient_name VARCHAR(48);
    var_hkpmi_sex VARCHAR(01);
    var_hkpmi_dob TIMESTAMP WITHOUT TIME ZONE;
    var_hkpmi_ccc1 VARCHAR(5);
    var_hkpmi_ccc2 VARCHAR(5);
    var_hkpmi_ccc3 VARCHAR(5);
    var_hkpmi_ccc4 VARCHAR(5);
    var_hkpmi_ccc5 VARCHAR(5);
    var_hkpmi_ccc6 VARCHAR(5);
    sql$rowcount BIGINT;
    found_code INTEGER;
    hosp_cursor CURSOR FOR
    SELECT
        h.hospital_code
        FROM hospital AS h, patient_detail_1 AS p
        WHERE p.patient_key = par_patient_key AND (p.hosp_byte_1 & h.byte_value_1 > 0 OR p.hosp_byte_2 & h.byte_value_2 > 0 OR p.hosp_byte_3 & h.byte_value_3 > 0) AND h.hospital_code != par_hospital_code
    UNION
    SELECT DISTINCT
        hospital_code
        FROM pmi_case
        WHERE patient_key = par_patient_key AND hospital_code != par_hospital_code;
begin
	SET search_path TO hkpmi, public;
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN
            /* Declaration */
             SELECT  'Y'
                INTO var_begin_tran;
            /* initalize the variable */
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_hkpmi_patient_key, var_hkpmi_patient_name, var_hkpmi_sex, var_hkpmi_dob, var_hkpmi_ccc1, var_hkpmi_ccc2, var_hkpmi_ccc3, var_hkpmi_ccc4, var_hkpmi_ccc5, var_hkpmi_ccc6, var_hkpmi_source_system_dtm;
            /* Validate key fields */
            IF NOT (par_source_system = 'ADT' AND par_txn_type IN ('250')) THEN
                BEGIN
                    /* Invalid transaction type. */
                    SELECT
                        200014
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* get patient  information by HKID */
            SELECT
                patient_key, patient_name, sex, dob, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, source_system_dtm, row_update_datetime
                INTO var_hkpmi_patient_key, var_hkpmi_patient_name, var_hkpmi_sex, var_hkpmi_dob, var_hkpmi_ccc1, var_hkpmi_ccc2, var_hkpmi_ccc3, var_hkpmi_ccc4, var_hkpmi_ccc5, var_hkpmi_ccc6, var_hkpmi_source_system_dtm, var_hkpmi_timestamp
                FROM patient
                WHERE hkid = par_hkid;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    /* Patient does not already exists */
                    SELECT
                        200012
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* pass patient to local system */
            SELECT
                var_hkpmi_patient_key
                INTO par_patient_key;

            IF var_hkpmi_ccc1 = REPEAT(' ', 1) THEN
                SELECT
                    NULL
                    INTO var_hkpmi_ccc1;
            END IF;

            IF var_hkpmi_ccc2 = REPEAT(' ', 1) THEN
                SELECT
                    NULL
                    INTO var_hkpmi_ccc2;
            END IF;

            IF var_hkpmi_ccc3 = REPEAT(' ', 1) THEN
                SELECT
                    NULL
                    INTO var_hkpmi_ccc3;
            END IF;

            IF var_hkpmi_ccc4 = REPEAT(' ', 1) THEN
                SELECT
                    NULL
                    INTO var_hkpmi_ccc4;
            END IF;

            IF var_hkpmi_ccc5 = REPEAT(' ', 1) THEN
                SELECT
                    NULL
                    INTO var_hkpmi_ccc5;
            END IF;

            IF var_hkpmi_ccc6 = REPEAT(' ', 1) THEN
                SELECT
                    NULL
                    INTO var_hkpmi_ccc6;
            END IF;

            IF par_ccc1 = REPEAT(' ', 1) THEN
                SELECT
                    NULL
                    INTO par_ccc1;
            END IF;

            IF par_ccc2 = REPEAT(' ', 1) THEN
                SELECT
                    NULL
                    INTO par_ccc2;
            END IF;

            IF par_ccc3 = REPEAT(' ', 1) THEN
                SELECT
                    NULL
                    INTO par_ccc3;
            END IF;

            IF par_ccc4 = REPEAT(' ', 1) THEN
                SELECT
                    NULL
                    INTO par_ccc4;
            END IF;

            IF par_ccc5 = REPEAT(' ', 1) THEN
                SELECT
                    NULL
                    INTO par_ccc5;
            END IF;

            IF par_ccc6 = REPEAT(' ', 1) THEN
                SELECT
                    NULL
                    INTO par_ccc6;
            END IF;
            /* check major keys */
           	raise notice 'var_hkpmi_patient_name=%,par_patient_name=%,var_hkpmi_sex=%,par_sex=%,var_hkpmi_dob=%,par_dob=%,var_hkpmi_ccc1=%,par_ccc1=%,var_hkpmi_ccc2=%,par_ccc2=%',var_hkpmi_patient_name,par_patient_name,var_hkpmi_sex,par_sex,var_hkpmi_dob,par_dob,var_hkpmi_ccc1,par_ccc1,var_hkpmi_ccc2,par_ccc2;
            IF var_hkpmi_patient_name <> par_patient_name OR var_hkpmi_sex <> par_sex OR var_hkpmi_dob <> par_dob OR var_hkpmi_ccc1 <> par_ccc1 OR var_hkpmi_ccc2 <> par_ccc2 OR var_hkpmi_ccc3 <> par_ccc3 OR var_hkpmi_ccc4 <> par_ccc4 OR var_hkpmi_ccc5 <> par_ccc5 OR var_hkpmi_ccc6 <> par_ccc6 THEN
                BEGIN
                    /* Patient major keys do not match */
                    SELECT
                        200101
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* check case existence */
            IF EXISTS (SELECT
                *
                FROM pmi_case
                WHERE patient_key = var_hkpmi_patient_key) THEN
                BEGIN
                    /* Cannot delete patient because pmi_case exist! */
                    SELECT
                        200035
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            IF var_hkpmi_source_system_dtm > par_source_system_dtm THEN
                BEGIN
                    /* Patient's last_source_system_dtm is later than */
                    /* upload's source_system_dtm. */
                    SELECT
                        200013
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            SELECT
                timestamp_convert(localtimestamp)
                INTO var_system_dtm;
            /* --- begin delete -- */
            
            /*
            delete patient hospital data, no matter the mrn is belong
            to which hospital
            */
            BEGIN
                DELETE FROM patient_hospital_data
                    WHERE patient_key = var_hkpmi_patient_key;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    EXIT return_system_error;
                END;
            END IF;
            /* delete nok */
            BEGIN
                DELETE FROM nok
                    WHERE patient_key = var_hkpmi_patient_key;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    EXIT return_system_error;
                END;
            END IF;
            /* --	/* delete patient_detail_1 */ */
            /* --	delete patient_detail_1 */
            /* --	where patient_key= @hkpmi_patient_key */
            /* --	select	@error = @@error, @rowcount = @@rowcount */
            /* --	if @error != 0 */
            /* --	begin */
            /* --		select   @return_error_code = @error */
            /* --		goto return_system_error */
            /* --	end */
            /* --	if @rowcount <> 1 */
            /* --	begin */
            /* --		/* cannot delete patient because more than one row in*/ */
            /* --		patient_detail_1* / */
            /* --		select   @return_error_code = 300005 */
            /* --		goto return_error */
            /* --	end */
            /* delete unmatch hkid */
            BEGIN
                DELETE FROM unmatch_hkid
                    WHERE hkid = par_hkid;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    EXIT return_system_error;
                END;
            END IF;

            IF var_rowcount > 1 THEN
                BEGIN
                    SELECT
                        300006
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* --	/* delete patient */ */
            /* --	delete patient */
            /* --	where patient_key = @hkpmi_patient_key and */
            /* --			timestamp = @hkpmi_timestamp */
            /* -- */
            /* --	select	@error = @@error, @rowcount = @@rowcount */
            /* --	if @error != 0 */
            /* --	begin */
            /* --		select   @return_error_code = @error */
            /* --		goto return_system_error */
            /* --	end */
            /* --	if @rowcount != 1 */
            /* --	begin */
            /* --		/* Patient not found or Patient has been updated between */ */
            /* --		/* retrieved and update." */ */
            /* --		select   @return_error_code = 200016 */
            /* --		goto return_error */
            /* --	end */
            /*
            19981106 GL, select hospital from patient_patient_1 and pmi_case for
            transaction '250'
            */
            OPEN hosp_cursor;
            FETCH hosp_cursor INTO var_tmp_hospital_code;
            select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
            SELECT
                'N', var_system_dtm
                INTO var_process_local_hospital, var_tran_system_dtm;

            WHILE (found_code = 0 OR var_process_local_hospital = 'N') LOOP
                IF var_process_local_hospital = 'N' THEN
                    BEGIN
                        SELECT
                            par_hospital_code
                            INTO var_tran_hospital_code;
                        SELECT
                            'Y'
                            INTO var_upload_status;
                    END;
                ELSE
                    BEGIN
                        SELECT
                            var_tmp_hospital_code, 'P'
                            INTO var_tran_hospital_code, var_upload_status;
                    END;
                END IF;

                WHILE 1 = 1 LOOP
                    BEGIN
                        INSERT INTO download.transaction_log (system_dtm, hospital_code, type, hkid, patient_key, patient_name, sex, dob, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, update_by, source_system, source_system_dtm, update_hospital, upload_status)
                        VALUES (var_tran_system_dtm, var_tran_hospital_code, par_txn_type, par_hkid, par_patient_key, par_patient_name, par_sex, par_dob, par_ccc1, par_ccc2, par_ccc3, par_ccc4, par_ccc5, par_ccc6, par_update_by, par_source_system, par_source_system_dtm, par_hospital_code, var_upload_status);
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                GET STACKED diagnostics var_error = RETURNED_SQLSTATE; 
                    END;

                    IF var_error = 23505 THEN
                        BEGIN
                            SELECT
                                3 * INTERVAL '1 millisecond' + var_tran_system_dtm::TIMESTAMP
                                INTO var_tran_system_dtm;
                            CONTINUE;
                        END;
                    END IF;

                    IF var_error != 0 THEN
                        BEGIN
                            /* Fail to insert into transaction_log. */
                            SELECT
                                var_error
                                INTO var_return_error_code;
                            EXIT return_system_error;
                        END;
                    END IF;
                    EXIT;
                END LOOP;

                IF var_process_local_hospital = 'N' THEN
                    BEGIN
                        SELECT
                            'Y'
                            INTO var_process_local_hospital;
                    END;
                ELSE
                    BEGIN
                        FETCH hosp_cursor INTO var_tmp_hospital_code;
                        select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
                    END;
                END IF;
            END LOOP; /* end insert transaction_log from demo updated */
            /* delete patient_detail_1 */
            begin
	            raise notice 'var_hkpmi_patient_key=%',var_hkpmi_patient_key;
                DELETE FROM patient_detail_1
                    WHERE patient_key = var_hkpmi_patient_key;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    EXIT return_system_error;
                END;
            END IF;

            IF var_rowcount <> 1 THEN
                BEGIN
                    /*
                    cannot delete patient because more than one row in
                    patient_detail_1
                    */
                    SELECT
                        300005
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* delete patient */
            BEGIN
                DELETE FROM patient
                    WHERE patient_key = var_hkpmi_patient_key AND row_update_datetime = var_hkpmi_timestamp;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    EXIT return_system_error;
                END;
            END IF;

            IF var_rowcount != 1 THEN
                BEGIN
                    /* Patient not found or Patient has been updated between */
                    /* retrieved and update." */
                    SELECT
                        200016
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* insert del tx into log table */
            IF EXISTS (SELECT
                *
                FROM del_pmi_log
                WHERE patient_key = par_patient_key) THEN
                BEGIN
                    /* Fail to insert row into del_pmi_log table */
                    SELECT
                        300007
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            BEGIN
                INSERT INTO del_pmi_log (patient_key, hkid, patient_name, sex, dob, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, update_hospital, source_system, update_by, source_system_dtm, system_dtm)
                VALUES (par_patient_key, par_hkid, par_patient_name, par_sex, par_dob, par_ccc1, par_ccc2, par_ccc3, par_ccc4, par_ccc5, par_ccc6, par_hospital_code, par_source_system, par_update_by, par_source_system_dtm, var_system_dtm);
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    EXIT return_system_error;
                END;
            END IF;

            IF var_rowcount <> 1 THEN
                BEGIN
                    /* Fail to insert row into del_pmi_table */
                    SELECT
                        300007
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* ---20120908 --- */
            BEGIN
                INSERT INTO hkpmi_pin_change_log (hosp_code, txn_dtm, txn_type, hkid, patient_key, old_hkid, old_patient_key, update_by, source_sys, source_sys_dtm, update_hosp)
                VALUES (par_hospital_code, var_tran_system_dtm, par_txn_type, par_hkid, par_patient_key, NULL, NULL, par_update_by, par_source_system, par_source_system_dtm, par_hospital_code);
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            /* --- the uniqe key = hosp_code + txn_dtm + hkid  --> 23505 SHOULD NOT occurred */

            
            var_rowcount := sql$rowcount;

            IF var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    EXIT return_system_error;
                END;
            END IF;

            IF var_rowcount <> 1 THEN
                BEGIN
                    /* Fail to insert row into cpi_pin_change_log */
                    SELECT
                        300007
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* ---- END 20120908 --- */

           
            pas_return_code := 0;
            RETURN;

        END;

        IF var_begin_tran = 'Y' THEN
            BEGIN
               -- ROLLBACK;
               raise exception '';
            END;
        END IF;
--        RAISE EXCEPTION USING ERRCODE := var_return_error_code;
        pas_return_code := var_return_error_code;
        RETURN;
    END;

    IF var_begin_tran = 'Y' THEN
        BEGIN
            --ROLLBACK;
            raise exception '';
        END;
    END IF;
    pas_return_code := var_return_error_code;
    RETURN;
END; /* end the procedure */
$procedure$
;


ALTER PROCEDURE "hkpmi_del_pmi" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";