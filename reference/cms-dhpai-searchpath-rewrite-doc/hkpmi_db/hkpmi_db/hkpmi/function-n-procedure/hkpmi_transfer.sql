-- DROP PROCEDURE hkpmi.hkpmi_transfer(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, inout varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_transfer(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_txn_type character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, INOUT par_patient_key character varying, IN par_hkid character varying, IN par_case_no character varying, IN par_transfer_dtm timestamp without time zone, IN par_last_ward_code character varying, IN par_last_specialty_code character varying, IN par_last_ward_class character varying, IN par_last_bed_no character varying, IN par_old_ward_code character varying, IN par_old_specialty_code character varying, IN par_old_ward_class character varying, IN par_old_bed_no character varying, IN par_doctor_code character varying)
 LANGUAGE plpgsql
AS $procedure$
/* transaction information */
/* patient information */
/* case information */
DECLARE
    var_tmp_phonetic VARCHAR(48);
    var_return_error_code INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_begin_tran VARCHAR(01);
    var_tran_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_chi_name VARCHAR(12);
    var_upload_status VARCHAR(01);
    var_case_old_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_tmp_movement_count INTEGER;
    /* patient information */
    var_old_patient_key VARCHAR(08);
    var_old_patient_name VARCHAR(48);
    var_old_sex VARCHAR(01);
    var_old_dob TIMESTAMP WITHOUT TIME ZONE;
    var_old_exact_dob_flag VARCHAR(01);
    var_old_cccode1 VARCHAR(05);
    var_old_cccode2 VARCHAR(05);
    var_old_cccode3 VARCHAR(05);
    var_old_cccode4 VARCHAR(05);
    var_old_cccode5 VARCHAR(05);
    var_old_cccode6 VARCHAR(05);
    var_old_marital_status VARCHAR(01);
    var_old_race VARCHAR(02);
    var_old_other_doc_no VARCHAR(12);
    var_old_religion VARCHAR(03);
    /* case information */
    var_case_patient_type VARCHAR(03);
    var_case_patient_key VARCHAR(08);
    var_case_case_type VARCHAR(01);
    var_case_hkid VARCHAR(12);
    var_case_last_ward_code VARCHAR(04);
    var_case_last_specialty_code VARCHAR(04);
    var_case_last_ward_class VARCHAR(01);
    var_case_last_bed_no VARCHAR(05);
    var_case_discharge_code VARCHAR(03);
    var_case_movement_count INTEGER;
    var_is_schi_name VARCHAR(01);
    sql$rowcount BIGINT;
    var_return_code int;
begin
	SET search_path TO hkpmi, public;
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN
            /* Declaration */
            /* 2006-12-11 Added by HK Fong SMR20015887 - Start */
            /* 2006-12-11 Added by HK Fong SMR20015887 - End */
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
	        select  'Y' into var_begin_tran;
            /* initalize the variable */
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_old_patient_key, var_old_patient_name, var_old_sex, var_old_dob, var_old_exact_dob_flag, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_old_marital_status, var_old_race, var_old_other_doc_no, var_old_religion;
            /* Validate key fields */
            IF NOT ((par_source_system = 'ADT' AND par_txn_type IN ('140', '160', '170', '700')) OR (par_source_system = 'DNL' AND par_txn_type IN ('140', '160', '170', '700'))) THEN
                BEGIN
                    /* Invalid transaction type. */
                    SELECT
                        200014
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* check source system dtm */
            IF par_source_system != 'DNL' THEN
                BEGIN
                    IF par_transfer_dtm > par_source_system_dtm THEN
                        BEGIN
                            SELECT
                                200146
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /*
            This section is comment since
            	transfer can only update treatment location, but hkpmi do not
            	contain this field.
            	And this type of transaction will also needed to
            	upload.
            
            	if @last_ward_code = @old_ward_code and
            		@last_ward_class = @old_ward_class and
            		@last_specialty_code = @old_specialty_code and
            		@last_bed_no = @old_bed_no
            	begin
                  /* no change in ward_code,specialty, class and bed no*/
                  select @return_error_code = 200143
                  goto return_error
               end
            */
            /* Check the existence of the case */
            SELECT
                patient_key, patient_type, case_type, last_ward_code, last_specialty_code, last_ward_class, last_bed_no, discharge_code, movement_count, row_update_datetime
                INTO var_case_patient_key, var_case_patient_type, var_case_case_type, var_case_last_ward_code, var_case_last_specialty_code, var_case_last_ward_class, var_case_last_bed_no, var_case_discharge_code, var_case_movement_count, var_case_old_timestamp
                FROM pmi_case
                WHERE case_no = par_case_no AND hospital_code = par_hospital_code;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    /*
                    print "Case does not exist in pmi_case,
                    transfer is rejected!"
                    */
                    SELECT
                        200123
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            ELSE
                BEGIN
                    IF var_case_discharge_code IS NOT NULL THEN
                        BEGIN
                            /* Case already discharged, transfer is not allowed */
                            SELECT
                                200132
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;

                    IF var_case_case_type <> 'I' THEN
                        BEGIN
                            /* Case type invalid, transfer is not allowed */
                            SELECT
                                200140
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                    /* check movement count */
                    IF var_case_movement_count = 0 THEN
                        BEGIN
                            /* movement count error */
                            SELECT
                                200145
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                    /* add 1 to movement only if it is not null */
                    IF var_case_movement_count IS NULL THEN
                        SELECT
                            var_case_movement_count
                            INTO var_tmp_movement_count;
                    ELSE
                        SELECT
                            var_case_movement_count + 1
                            INTO var_tmp_movement_count;
                    END IF;
                END;
            END IF;
            /* check case and hkid match */
            SELECT
                hkid
                INTO var_case_hkid
                FROM patient
                WHERE patient_key = var_case_patient_key;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    /* case's patient not found */
                    SELECT
                        200126
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            IF var_case_hkid <> par_hkid THEN
                BEGIN
                    /* case hkid do not match with case */
                    SELECT
                        200125
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* set input patient_key */
            SELECT
                var_case_patient_key
                INTO par_patient_key;
            /* check case information matched */
            /*
            transfer from download may not contain
            old ward, specialty, bed
            for case convert from mainframe, the ward class
            is always null
            */
            IF var_case_last_specialty_code IS NOT NULL AND (var_case_last_ward_code <> par_old_ward_code OR var_case_last_specialty_code <> par_old_specialty_code OR (var_case_last_ward_class <> par_old_ward_class AND var_case_last_ward_class IS NOT NULL) OR (COALESCE(var_case_last_bed_no, 'null') <> COALESCE(par_old_bed_no, 'null') /* ---20070731 */)
            /*
            @case_last_bed_no <> @old_bed_no and
            @case_last_bed_no is not null
            */) AND par_source_system <> 'DNL' THEN
                BEGIN
                    /*
                    case information not match,
                    transfer rejected
                    */
                    SELECT
                        200141
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* get patient  information by HKID */
            SELECT
                patient_name, sex, dob, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, other_doc_no, marital_status, religion, race, exact_dob_flag
                INTO var_old_patient_name, var_old_sex, var_old_dob, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_old_other_doc_no, var_old_marital_status, var_old_religion, var_old_race, var_old_exact_dob_flag
                FROM patient
                WHERE hkid = par_hkid;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    /* patient not exists */
                    /* admission update is rejected!" */
                    SELECT
                        200012
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* Get chinese name from ccc_big5 table */
            CALL cpi_get_phonetic_chin_name(var_return_code, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_tmp_phonetic, var_chi_name);
            /* 2006-12-11 Addeded by HK Fong SMR20015887 - Start */
            IF COALESCE(var_chi_name, '') <> '' THEN
                BEGIN
                    CALL hkpmi_check_schi_name(pas_return_code => pas_return_code, par_ccc1 => var_old_cccode1, par_ccc2 => var_old_cccode2, par_ccc3 => var_old_cccode3, par_ccc4 => var_old_cccode4, par_ccc5 => var_old_cccode5, par_ccc6 => var_old_cccode6, par_is_schi_name => var_is_schi_name);

                    IF var_is_schi_name = 'Y' THEN
                        SELECT
                            NULL
                            INTO var_chi_name;
                    END IF;
                END;
            END IF;
            /* 2006-12-11 Addeded by HK Fong SMR20015887 - End */
            /* update  pmi_case */
            BEGIN
                UPDATE pmi_case
                SET last_ward_code = par_last_ward_code, last_ward_class = par_last_ward_class, last_specialty_code = par_last_specialty_code, last_bed_no = par_last_bed_no, movement_count = var_tmp_movement_count, update_by = par_update_by, source_system = par_source_system, source_system_dtm = par_source_system_dtm
                    WHERE case_no = par_case_no AND hospital_code = par_hospital_code AND row_update_datetime = var_case_old_timestamp;
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
                    /* Case not found or Case has been updated between */
                    /* retrieved and update." */
                    SELECT
                        200127
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* insert transaction_log for transfer */
            SELECT
                'P'
                INTO var_upload_status;
            SELECT
                localtimestamp
                INTO var_tran_system_dtm;

            WHILE 1 = 1 LOOP
                BEGIN
                    INSERT INTO download.transaction_log (system_dtm, hospital_code, type, transfer_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, religion,
                    /* case information */
                    case_no, patient_type, case_type, ward_code, specialty_code, ward_class, bed_no, old_ward_code, old_specialty_code, old_ward_class, old_bed_no, doctor_code, update_by, update_hospital, source_system, source_system_dtm, upload_status)
                    VALUES (var_tran_system_dtm, par_hospital_code, par_txn_type, par_transfer_dtm, par_hkid, par_patient_key, var_old_patient_name, var_old_sex, var_old_dob, var_old_exact_dob_flag, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_chi_name, var_old_marital_status, var_old_race, var_old_other_doc_no, var_old_religion,
                    /* case information */
                    par_case_no, var_case_patient_type, var_case_case_type, par_last_ward_code, par_last_specialty_code, par_last_ward_class, par_last_bed_no, par_old_ward_code, par_old_specialty_code, par_old_ward_class, par_old_bed_no, par_doctor_code, par_update_by, par_hospital_code, par_source_system, par_source_system_dtm, var_upload_status);
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
            END LOOP; /* end insert transaction_log from transfer */

            
            pas_return_code := 0;
            RETURN;

            
        END;

        IF var_begin_tran = 'Y' THEN
            BEGIN
                --ROLLBACK;
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


ALTER PROCEDURE "hkpmi_transfer" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
