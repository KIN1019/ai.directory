-- DROP PROCEDURE hkpmi.hkpmi_cancel_admission(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, inout varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_cancel_admission(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_txn_type character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, INOUT par_patient_key character varying, IN par_hkid character varying, IN par_case_no character varying, IN par_case_type character varying, IN par_adm_dtm timestamp without time zone, IN par_adm_ward_code character varying, IN par_adm_specialty_code character varying, IN par_adm_ward_class character varying)
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
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_chi_name VARCHAR(12);
    var_upload_status VARCHAR(01);
    var_case_old_timestamp timestamp(6);
    /*
    1998118 GL
    @tmp_adm_dtm_str			char(30),
    @tmp_case_adm_dtm_str	char(30),
    */
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
    var_case_adm_ward_code VARCHAR(04);
    var_case_adm_specialty_code VARCHAR(04);
    var_case_adm_ward_class VARCHAR(01);
    var_case_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_case_discharge_code VARCHAR(01);
    var_case_movement_count INTEGER;
    var_return_code INTEGER;
    /* Add by WL on 19981208 */
    var_case_discharge_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_case_destination_code VARCHAR(05);
    var_mo_hosp VARCHAR(3);
    var_mo_case VARCHAR(12);
    var_nb_hosp VARCHAR(3);
    var_nb_case VARCHAR(12);
    var_birth_order INTEGER;
    var_preg_no INTEGER;
    var_birth_place VARCHAR(1);
    var_birth_loc VARCHAR(3);
    var_is_schi_name VARCHAR(01);
    sql$rowcount BIGINT;
   	error_message text;
begin
	SET search_path TO hkpmi, public;
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN
            /* Declaration */
            /* 2006-12-11 Added by HK Fong SMR20015887 - Start */
            /* 2006-12-11 Added by HK Fong SMR20015887 - End */
            
              SELECT  'Y'
                INTO var_begin_tran;
            /* initalize the variable */
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                /* -- cancel convert old case 080 -- */
                NULL, NULL
                INTO var_old_patient_key, var_old_patient_name, var_old_sex, var_old_dob, var_old_exact_dob_flag, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_old_marital_status, var_old_race, var_old_other_doc_no, var_old_religion, var_case_discharge_dtm, var_case_destination_code;
            /* Validate key fields */
            /* Add 080 for cancel convert old case by WL 19981208 */
            IF NOT ((par_source_system = 'ADT' AND par_txn_type IN ('200', '201', '080')) OR (par_source_system = 'OPAS' AND par_txn_type IN ('200')) OR (par_source_system = 'OPAS2' AND par_txn_type IN ('200')) OR (par_source_system = 'DNL' AND par_txn_type IN ('200', '201'))) THEN
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
                    IF par_adm_dtm > par_source_system_dtm THEN
                        BEGIN
                            SELECT
                                200146
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* Check the existence of the case */
            SELECT
                patient_key, patient_type, case_type, adm_dtm, adm_ward_code, adm_specialty_code, adm_ward_class, movement_count, discharge_code, row_update_datetime,
                /* -- cancel convert old case 080 --- */
                discharge_dtm, destination_code
                INTO var_case_patient_key, var_case_patient_type, var_case_case_type, var_case_adm_dtm, var_case_adm_ward_code, var_case_adm_specialty_code, var_case_adm_ward_class, var_case_movement_count, var_case_discharge_code, var_case_old_timestamp, var_case_discharge_dtm, var_case_destination_code
                FROM pmi_case
                WHERE case_no = par_case_no AND hospital_code = par_hospital_code;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    /*
                    print "Case does not exist in pmi_case,
                    admission update is rejected!"
                    */
                    SELECT
                        200123
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            ELSE
                BEGIN
                    /* discharge code for convert old case must be not null, */
                    /* so skip validate 080 by WL 19981208 */
                    IF var_case_discharge_code IS NOT NULL AND par_txn_type <> '080' THEN
                        BEGIN
                            /* Case already discharged, cancel admission is not allowed */
                            SELECT
                                200132
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                    /* movement count of convert old case = 2, skip validate 080 */
                    /* by WL 19981208 */
                    IF var_case_movement_count IS NOT NULL AND var_case_movement_count <> 1 AND par_txn_type <> '080' THEN
                        BEGIN
                            /*
                            print "Admission cannot be updated
                            after movement occured"
                            */
                            SELECT
                                200142
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;

                    IF var_case_discharge_code = '1' AND par_txn_type = '080' THEN
                        BEGIN
                            /*
                            print "Invalid discharge code for convert old case,
                            cancellation of conversion of old case fail"
                            */
                            SELECT
                                200174
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                    /* download do not have admission datetime */
                    IF par_source_system = 'DNL' AND par_case_type = 'O' THEN
                        BEGIN
                            SELECT
                                var_case_adm_dtm, var_case_adm_specialty_code
                                INTO par_adm_dtm, par_adm_specialty_code;
                        END;
                    END IF;
                    /* temporary for all record from DNL in mainframe */
                    IF par_source_system = 'DNL' THEN
                        BEGIN
                            SELECT
                                var_case_adm_dtm
                                INTO par_adm_dtm;
                        END;
                    END IF;
                    /* old data may not contain ward, spec info */
                    IF var_case_adm_specialty_code IS NULL THEN
                        SELECT
                            par_adm_ward_code, par_adm_ward_class, par_adm_specialty_code
                            INTO var_case_adm_ward_code, var_case_adm_ward_class, var_case_adm_specialty_code;
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
			raise notice 'var_case_hkid=%,par_hkid=%',var_case_hkid,par_hkid;
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
            /*
            special checking for adm dtm for opas
            which do not have second in adt dtm
            */
            /* 19981118 GL, don't check case detail for OP case */
            /*
            select @tmp_adm_dtm_str = convert(char(30), @adm_dtm, 100)
            select @tmp_case_adm_dtm_str = convert(char(30), @case_adm_dtm, 100)
            */
            /* check case information matched */
            raise notice '%,%,%,%',par_adm_ward_code,var_case_adm_specialty_code,par_adm_specialty_code,var_case_adm_ward_class;
            IF (coalesce(var_case_case_type,'') <> coalesce(par_case_type,'') OR coalesce(var_case_adm_ward_code,'') <> coalesce(par_adm_ward_code,'') OR coalesce(var_case_adm_specialty_code,'') <> coalesce(par_adm_specialty_code,'') OR coalesce(var_case_adm_ward_class,'') <> coalesce(par_adm_ward_class,'') OR coalesce(var_case_adm_dtm,'1999-01-01'::timestamp) <> coalesce(par_adm_dtm,'1999-01-01'::timestamp)) AND coalesce(var_case_case_type,'') <> 'O' THEN
                /* (@case_adm_dtm <> @adm_dtm and @case_type <> "O") or */
                /* (@tmp_adm_dtm_str <> @tmp_case_adm_dtm_str) */
                BEGIN
                    /*
                    case information not match,
                    cancel admission rejected
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
            /* delete case */
            BEGIN
                DELETE FROM pmi_case
                    WHERE case_no = par_case_no AND hospital_code = par_hospital_code AND row_update_datetime = var_case_old_timestamp;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS then
                    	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;  
                                raise notice 'error_message%',error_message;
                        
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
            /* ----------20070711 SL-delete  hkpmi_linked_case -------- */
            IF EXISTS (SELECT
                *
                FROM hkpmi_linked_case
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no) THEN
                BEGIN
                    BEGIN
                        DELETE FROM hkpmi_linked_case
                            WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;  
                                raise notice 'error_message%',error_message;
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

                    IF var_rowcount < 1 THEN /* ---Multi-records ---- */
                        BEGIN
                            SELECT
                                200038
                                INTO var_return_error_code; /* ---"failed to updat linked case " */
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* ------reject  cancel admision ==> upload problem ==> contact target hosp user to remove the Linke Case ==> then Reupload this Transaction --- */
            IF EXISTS (SELECT
                *
                FROM hkpmi_linked_case
                WHERE previous_hospital = par_hospital_code AND previous_case = par_case_no) THEN
                BEGIN
                    SELECT
                        200038
                        INTO var_return_error_code; /* ---"failed to updat linked case " */
                    EXIT return_error;
                END;
            END IF;
            /* ----------20070711 SL --------- */
            /*
            By Goya 19981031, set this patient in this hospital on in
            patient_detail_1 if this patient doesn't have any more cases in
            this hospital. (hkpmi_set_on_patient_hosp will check exsitence of
            case before process)
            */
            IF NOT EXISTS (SELECT
                *
                FROM pmi_case
                WHERE patient_key = par_patient_key AND hospital_code = par_hospital_code) THEN
                BEGIN
                    CALL hkpmi_set_on_patient_hosp(var_return_code, par_hkid, par_hospital_code, par_update_by, par_source_system);


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
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;

            IF par_txn_type <> '080' THEN
                SELECT
                    NULL, NULL, NULL
                    INTO var_case_discharge_dtm, var_case_destination_code, var_case_discharge_code;
            END IF;
            /* insert transaction_log for cancel admission */
            SELECT
                'P'
                INTO var_upload_status;
            SELECT
                localtimestamp
                INTO var_system_dtm;
            SELECT
                var_system_dtm
                INTO var_tran_system_dtm;

            WHILE 1 = 1 LOOP
                BEGIN
                    INSERT INTO download.transaction_log (system_dtm, hospital_code, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, religion,
                    /* case information */
                    case_no, patient_type, case_type, ward_code, specialty_code, ward_class, update_by, update_hospital, source_system, source_system_dtm, upload_status,
                    /* cancel convert old case */
                    discharge_code, destination_code, discharge_dtm)
                    VALUES (var_tran_system_dtm, par_hospital_code, par_txn_type, par_adm_dtm, par_hkid, par_patient_key, var_old_patient_name, var_old_sex, var_old_dob, var_old_exact_dob_flag, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_chi_name, var_old_marital_status, var_old_race, var_old_other_doc_no, var_old_religion,
                    /* case information */
                    par_case_no, var_case_patient_type, par_case_type, par_adm_ward_code, par_adm_specialty_code, par_adm_ward_class, par_update_by, par_hospital_code, par_source_system, par_source_system_dtm, var_upload_status, var_case_discharge_code, var_case_destination_code, var_case_discharge_dtm);
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
            END LOOP; /* end insert transaction_log from admission */
            /*
            20050718 - update mother_baby_case if the cancelled case exist
            in the table
            */
            IF par_case_type IN ('I', 'A') THEN
                BEGIN
                    CALL hkpmi_check_mother_baby_case(var_return_code, par_hospital_code, par_patient_key, par_source_system_dtm, par_update_by, par_source_system);

                    IF var_return_code <> 0 THEN
                        BEGIN
                            SELECT
                                var_return_code
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /*
            if exists(select * from mother_baby_case
            	where mother_hospital_code = @hospital_code
            	and mother_case_no = @case_no
            	and active_status = 'Y') or
            	exists(select * from mother_baby_case
            	where baby_hospital_code = @hospital_code
            	and baby_case_no = @case_no
            	and active_status = 'Y')
            begin
            	select @return_error_code = 200167
            	goto return_error
            end
            declare mb_csr cursor for
            	select mother_hospital_code, mother_case_no, baby_hospital_code,
            		baby_case_no, birth_order, pregnancy_number, birth_place,
            		birth_location
            		from mother_baby_case
            		where (mother_hospital_2 = @hospital_code
            		and mother_case_2 = @case_no
            		and active_status = 'Y')
            		or (mother_hospital_hn = @hospital_code
            		and mother_case_hn = @case_no
            		and active_status = 'Y')
            		or (baby_hospital_hn = @hospital_code
            		and baby_case_hn = @case_no
            		and active_status = 'Y')
            		or (baby_hospital_2 = @hospital_code
            		and baby_case_2 = @case_no
            		and active_status = 'Y')
            	for read only
            open mb_csr
            fetch mb_csr into @mo_hosp, @mo_case, @nb_hosp, @nb_case,
            	@birth_order, @preg_no, @birth_place, @birth_loc
            while @@sqlstatus = 0
            begin
            	exec @return_code = hkpmi_update_mother_baby_case
            		@nb_hosp, @mo_hosp, @mo_case, @nb_hosp, @nb_case, @birth_order,
            		@preg_no, @birth_place, @birth_loc, @update_by, '261',
            		@source_system, @source_system_dtm, @mo_hosp, @mo_case,
            		@nb_hosp, @nb_case, null, null, null, null, null
            	if @return_code <> 0
            	begin
            		select @return_error_code = @return_code
            		goto return_error
            	end
            	fetch mb_csr into @mo_hosp, @mo_case, @nb_hosp, @nb_case,
            		@birth_order, @preg_no, @birth_place, @birth_loc
            end
            close mb_csr
            deallocate cursor mb_csr
            */
            
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
           -- ROLLBACK;
           raise exception '';
        END;
    END IF;
    pas_return_code := var_return_error_code;
    RETURN;
END; /* end the procedure */
$procedure$
;



ALTER PROCEDURE "hkpmi_cancel_admission" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";