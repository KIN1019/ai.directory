-- DROP FUNCTION hpi.fn_cpi_tu_patient();

CREATE OR REPLACE FUNCTION hpi.fn_cpi_tu_patient()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/*
------------------------------------------------------------
 *  Modification History -
 * Feb 98 - reject if update_dtm of before image is less than
 *			   after image by Stephen CHAN
 * Mar 98 - raiseerror 25000 if calling cpi_update_patient_key
 *			   failed instead of using the return code
 * 19981030 - delete cpi_unmatch_hkid if the patient is
 *					updated by Leo Lee
 * 19981207 - do not log changes to cpi_patient_key_changed if
 *              chi_name not match (to ignore double byte not match
 *              with CCC created by OPAS during conversion)
 *					 by Mabel Lau
 *
 * 2007-02-13 - Add the checking in backend SP to prevent
 * 		user from inputting partial chinese name content
 *		Changed by HK Fong SMR20016006
* 20130805 add Rollback
* ------------------------------------------------------------
*/
/* --use cpi */
/* --go */
/* drop  trigger cpi_tu_patient */
DECLARE
    var_del_patient_key VARCHAR(8);
    var_name_phonetic VARCHAR(48);
    var_del_patient_name VARCHAR(48);
    var_del_cccode1 VARCHAR(5);
    var_del_cccode2 VARCHAR(5);
    var_del_cccode3 VARCHAR(5);
    var_del_cccode4 VARCHAR(5);
    var_del_cccode5 VARCHAR(5);
    var_del_cccode6 VARCHAR(5);
    var_del_sex VARCHAR(1);
    var_del_dob TIMESTAMP WITHOUT TIME ZONE;
    var_del_hkid VARCHAR(12);
    var_del_chi_name VARCHAR(12);
    var_del_marital_status VARCHAR(1);
    var_del_other_doc_no VARCHAR(12);
    var_del_building VARCHAR(47);
    var_del_room VARCHAR(5);
    var_del_floor VARCHAR(2);
    var_del_block VARCHAR(2);
    var_del_district VARCHAR(5);
    var_del_religion VARCHAR(3);
    var_del_phone1 VARCHAR(10);
    var_del_phone2 VARCHAR(10);
    var_del_address_indicator VARCHAR(4);
    var_del_mobile_phone VARCHAR(10);
    var_del_sms_language VARCHAR(4);
    var_del_access_code INTEGER;
    var_del_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_ins_patient_key VARCHAR(8);
    var_ins_patient_name VARCHAR(48);
    var_ins_cccode1 VARCHAR(5);
    var_ins_cccode2 VARCHAR(5);
    var_ins_cccode3 VARCHAR(5);
    var_ins_cccode4 VARCHAR(5);
    var_ins_cccode5 VARCHAR(5);
    var_ins_cccode6 VARCHAR(5);
    var_ins_sex VARCHAR(1);
    var_ins_dob TIMESTAMP WITHOUT TIME ZONE;
    var_ins_hkid VARCHAR(12);
    var_ins_chi_name VARCHAR(12);
    var_ins_marital_status VARCHAR(1);
    var_ins_other_doc_no VARCHAR(12);
    var_ins_building VARCHAR(47);
    var_ins_room VARCHAR(5);
    var_ins_floor VARCHAR(2);
    var_ins_block VARCHAR(2);
    var_ins_district VARCHAR(5);
    var_ins_religion VARCHAR(3);
    var_ins_phone1 VARCHAR(10);
    var_ins_phone2 VARCHAR(10);
    var_ins_address_indicator VARCHAR(4);
    var_ins_mobile_phone VARCHAR(10);
    var_ins_sms_language VARCHAR(4);
    var_chi_name VARCHAR(12);
    var_ins_update_hospital VARCHAR(3);
    var_ins_exact_dob_flag VARCHAR(1);
    var_ins_race_code VARCHAR(2);
    var_ins_reference VARCHAR(20);
    var_ins_religion_code VARCHAR(3);
    var_ins_death_indicator VARCHAR(1);
    var_ins_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_ins_death_code VARCHAR(4);
    var_ins_card_holder INTEGER;
    var_ins_patient_no INTEGER;
    var_ins_access_code INTEGER;
    var_ins_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_update_flag VARCHAR(1);
    var_cnt INTEGER;
    var_return_code INTEGER;
    var_valid_flag VARCHAR(1);
    var_user_name VARCHAR(12);
    var_temp_access_code VARCHAR(01);
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    var_tmp_phonetic VARCHAR(48);
    var_tmp_del_chi_name VARCHAR(12);
    var_numrows INTEGER;
    var_rowcount$aws$ INTEGER;

BEGIN
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
    /* 2007-02-13 by HK Fong SMR20016006 - Start */
    /* --	declare @first_blank_ccc int, @last_non_blank_ccc int */
    /* 2007-02-13 by HK Fong SMR20016006 - End */
    var_numrows := var_rowcount$aws$;

    IF var_numrows > 1 THEN
        BEGIN
            /*
            print "multiple rows update of patient are not allowed!"
            return
            */
            RAISE EXCEPTION 'Multiple rows update of patient are not allowed!' USING ERRCODE = '25000';
            ROLLBACK; /* ---20130805 */
            RETURN NULL;
        END;
    END IF;
    /* delete cpi_unmatch_hkid if patient record is updated */
    DELETE FROM cpi_unmatch_hkid
    USING inserted
        WHERE cpi_unmatch_hkid.hkid = inserted.hkid;
    SELECT
        patient_key, hkid, patient_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, dob, sex, chi_name, marital_status, other_doc_no, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, access_code, update_dtm
        INTO var_del_patient_key, var_del_hkid, var_del_patient_name, var_del_cccode1, var_del_cccode2, var_del_cccode3, var_del_cccode4, var_del_cccode5, var_del_cccode6, var_del_dob, var_del_sex, var_del_chi_name, var_del_marital_status, var_del_other_doc_no, var_del_building, var_del_room, var_del_floor, var_del_block, var_del_district, var_del_religion, var_del_phone1, var_del_phone2, var_del_address_indicator, var_del_mobile_phone, var_del_sms_language, var_del_access_code, var_del_update_dtm
        FROM deleted;
    SELECT
        update_hospital, patient_key, hkid, patient_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, dob, sex, chi_name, marital_status, other_doc_no, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, race, reference, exact_dob_flag, religion, death_indicator, death_date, death_code, card_holder, patient_no, access_code, update_dtm
        INTO var_ins_update_hospital, var_ins_patient_key, var_ins_hkid, var_ins_patient_name, var_ins_cccode1, var_ins_cccode2, var_ins_cccode3, var_ins_cccode4, var_ins_cccode5, var_ins_cccode6, var_ins_dob, var_ins_sex, var_ins_chi_name, var_ins_marital_status, var_ins_other_doc_no, var_ins_building, var_ins_room, var_ins_floor, var_ins_block, var_ins_district, var_ins_religion, var_ins_phone1, var_ins_phone2, var_ins_address_indicator, var_ins_mobile_phone, var_ins_sms_language, var_ins_race_code, var_ins_reference, var_ins_exact_dob_flag, var_ins_religion_code, var_ins_death_indicator, var_ins_death_date, var_ins_death_code, var_ins_card_holder, var_ins_patient_no, var_ins_access_code, var_ins_update_dtm
        FROM inserted;
    SELECT
        current_user
        INTO var_user_name;

    IF var_del_update_dtm > var_ins_update_dtm THEN
        BEGIN
            RAISE EXCEPTION 'System error! update_dtm is earlier than before image.' USING ERRCODE = '25000';
            RETURN NULL;
        END;
    END IF;
    /*
    Check if the patient_key was changed
    The valid condition is follow:-
    				patient_key	hkid	sex	dob	name
    Changed		Y				N		N		N		N
    */
    IF var_del_patient_key != var_ins_patient_key THEN
        BEGIN
            IF var_del_hkid != var_ins_hkid OR var_del_patient_name != var_ins_patient_name OR var_del_sex != var_ins_sex OR var_del_dob != var_ins_dob THEN
                BEGIN
                    RAISE EXCEPTION 'Cannot change the patient_key while others are being changed' USING ERRCODE = '25000';
                    RETURN NULL;
                END;
            END IF;

            IF var_ins_patient_no != CAST (var_ins_patient_key AS INTEGER) THEN
                BEGIN
                    RAISE EXCEPTION 'Unmatch patient_no and patient_key' USING ERRCODE = '25000';
                    RETURN NULL;
                END;
            END IF;
            /* --exec @return_code = cpi..cpi_update_patient_key */
            CALL cpi_update_patient_key(pas_return_code => var_return_code, par_hospital_code => var_ins_update_hospital, par_hkid => var_ins_hkid, par_patient_name => var_ins_patient_name, par_sex => var_ins_sex, par_dob => var_ins_dob, par_old_patient_key => var_del_patient_key, par_new_patient_key => var_ins_patient_key, par_update_by => var_user_name, par_source_system => 'CPI', par_exact_dob_flag => var_ins_exact_dob_flag, par_ccc_1 => var_ins_cccode1, par_ccc_2 => var_ins_cccode2, par_ccc_3 => var_ins_cccode3, par_ccc_4 => var_ins_cccode4, par_ccc_5 => var_ins_cccode5, par_ccc_6 => var_ins_cccode6, par_chi_name => var_ins_chi_name, par_marital_status => var_ins_marital_status, par_race_code => var_ins_race_code, par_other_document_no => var_ins_other_doc_no, par_reference => var_ins_reference, par_building => var_ins_building, par_room => var_ins_room, par_floor => var_ins_floor, par_block => var_ins_block, par_district_code => var_ins_district, par_religion_code => var_ins_religion_code, par_phone1 => var_ins_phone1, par_phone2 => var_ins_phone2, par_address_indicator => var_ins_address_indicator, par_mobile_phone => var_ins_mobile_phone, par_sms_language => var_ins_sms_language, par_death_indicator => var_ins_death_indicator, par_death_date => var_ins_death_date, par_death_code => var_ins_death_code, par_card_holder => var_ins_card_holder);
            /* , p_refcur => cpi_update_patient_key$refcur_1, p_refcur_2 => cpi_update_patient_key$refcur_2 */


            IF var_return_code != 0 THEN
                BEGIN
                    RAISE EXCEPTION 'Problem to update patient_key' USING ERRCODE = '25000';
                    RETURN NULL;
                END;
            END IF;
        END;
    END IF;
    CALL cpi_pq_validate_hkid(var_return_code, var_ins_hkid, var_valid_flag);

    IF (var_valid_flag = 'N') THEN
        BEGIN
            IF var_return_code = 1 THEN
                BEGIN
                    RAISE EXCEPTION 'Invalid HKID, fail to update patient record!' USING ERRCODE = '25000';
                    RETURN NULL;
                END;
            ELSE
                IF var_return_code = 2 THEN
                    BEGIN
                        RAISE EXCEPTION 'Invalid HKID check digit, fail to update patient record!' USING ERRCODE = '25000';
                        RETURN NULL;
                    END;
                END IF;
            END IF;
        END;
    END IF;

    IF var_ins_hkid != var_del_hkid THEN
        BEGIN
            BEGIN
                UPDATE cpi_patient_key_changed
                SET original_hkid = var_ins_hkid
                    WHERE patient_key = var_del_patient_key AND original_hkid = var_del_hkid;
                EXCEPTION
                    WHEN OTHERS THEN
                        RETURN NULL;
            END;
        END;
    END IF;

    IF var_del_cccode1 = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_del_cccode1;
    END IF;

    IF var_del_cccode2 = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_del_cccode2;
    END IF;

    IF var_del_cccode3 = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_del_cccode3;
    END IF;

    IF var_del_cccode4 = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_del_cccode4;
    END IF;

    IF var_del_cccode5 = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_del_cccode5;
    END IF;

    IF var_del_cccode6 = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_del_cccode6;
    END IF;

    IF var_del_chi_name = REPEAT(' ', 12) THEN
        SELECT
            NULL
            INTO var_del_chi_name;
    END IF;

    IF var_del_marital_status = REPEAT(' ', 01) THEN
        SELECT
            NULL
            INTO var_del_marital_status;
    END IF;

    IF var_del_other_doc_no = REPEAT(' ', 12) THEN
        SELECT
            NULL
            INTO var_del_other_doc_no;
    END IF;

    IF var_del_building = REPEAT(' ', 47) THEN
        SELECT
            NULL
            INTO var_del_building;
    END IF;

    IF var_del_room = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_del_room;
    END IF;

    IF var_del_floor = REPEAT(' ', 02) THEN
        SELECT
            NULL
            INTO var_del_floor;
    END IF;

    IF var_del_block = REPEAT(' ', 02) THEN
        SELECT
            NULL
            INTO var_del_block;
    END IF;

    IF var_del_district = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_del_district;
    END IF;

    IF var_del_religion = REPEAT(' ', 03) THEN
        SELECT
            NULL
            INTO var_del_religion;
    END IF;

    IF var_del_phone1 = REPEAT(' ', 10) THEN
        SELECT
            NULL
            INTO var_del_phone1;
    END IF;

    IF var_del_phone2 = REPEAT(' ', 10) THEN
        SELECT
            NULL
            INTO var_del_phone2;
    END IF;

    IF var_del_address_indicator = REPEAT(' ', 04) THEN
        SELECT
            NULL
            INTO var_del_address_indicator;
    END IF;

    IF var_del_mobile_phone = REPEAT(' ', 10) THEN
        SELECT
            NULL
            INTO var_del_mobile_phone;
    END IF;

    IF var_del_sms_language = REPEAT(' ', 04) THEN
        SELECT
            NULL
            INTO var_del_sms_language;
    END IF;

    IF var_ins_cccode1 = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_ins_cccode1;
    END IF;

    IF var_ins_cccode2 = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_ins_cccode2;
    END IF;

    IF var_ins_cccode3 = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_ins_cccode3;
    END IF;

    IF var_ins_cccode4 = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_ins_cccode4;
    END IF;

    IF var_ins_cccode5 = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_ins_cccode5;
    END IF;

    IF var_ins_cccode6 = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_ins_cccode6;
    END IF;

    IF var_ins_chi_name = REPEAT(' ', 12) THEN
        SELECT
            NULL
            INTO var_ins_chi_name;
    END IF;

    IF var_ins_marital_status = REPEAT(' ', 01) THEN
        SELECT
            NULL
            INTO var_del_marital_status;
    END IF;

    IF var_ins_other_doc_no = REPEAT(' ', 12) THEN
        SELECT
            NULL
            INTO var_ins_other_doc_no;
    END IF;

    IF var_ins_building = REPEAT(' ', 47) THEN
        SELECT
            NULL
            INTO var_ins_building;
    END IF;

    IF var_ins_room = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_ins_room;
    END IF;

    IF var_ins_floor = REPEAT(' ', 02) THEN
        SELECT
            NULL
            INTO var_ins_floor;
    END IF;

    IF var_ins_block = REPEAT(' ', 02) THEN
        SELECT
            NULL
            INTO var_ins_block;
    END IF;

    IF var_ins_district = REPEAT(' ', 05) THEN
        SELECT
            NULL
            INTO var_ins_district;
    END IF;

    IF var_ins_religion = REPEAT(' ', 03) THEN
        SELECT
            NULL
            INTO var_ins_religion;
    END IF;

    IF var_ins_phone1 = REPEAT(' ', 10) THEN
        SELECT
            NULL
            INTO var_ins_phone1;
    END IF;

    IF var_ins_phone2 = REPEAT(' ', 10) THEN
        SELECT
            NULL
            INTO var_ins_phone2;
    END IF;

    IF var_ins_address_indicator = REPEAT(' ', 04) THEN
        SELECT
            NULL
            INTO var_ins_address_indicator;
    END IF;

    IF var_ins_mobile_phone = REPEAT(' ', 10) THEN
        SELECT
            NULL
            INTO var_ins_mobile_phone;
    END IF;

    IF var_ins_sms_language = REPEAT(' ', 04) THEN
        SELECT
            NULL
            INTO var_ins_sms_language;
    END IF;
    /* 2007-02-13 by HK Fong SMR20016006 - Start */
    /*
    if @del_cccode1 <> @ins_cccode1 or
       @del_cccode2 <> @ins_cccode2 or
       @del_cccode3 <> @ins_cccode3 or
       @del_cccode4 <> @ins_cccode4 or
       @del_cccode5 <> @ins_cccode5 or
    
       @del_cccode6 <> @ins_cccode6
    begin
    	select @first_blank_ccc = 0, @last_non_blank_ccc = 0
    	if IsNull(@ins_cccode1, '') = ''
    	begin
    		if @first_blank_ccc = 0
    			select @first_blank_ccc = 1
    	end
    	else
    		select @last_non_blank_ccc = 1
    
    
    	if IsNull(@ins_cccode2, '') = ''
    	begin
    		if @first_blank_ccc = 0
    			select @first_blank_ccc = 2
    	end
    	else
    		select @last_non_blank_ccc = 2
    
    	if IsNull(@ins_cccode3, '') = ''
    	begin
    		if @first_blank_ccc = 0
    			select @first_blank_ccc = 3
    	end
    	else
    		select @last_non_blank_ccc = 3
    
    	if IsNull(@ins_cccode4, '') = ''
    	begin
    		if @first_blank_ccc = 0
    			select @first_blank_ccc = 4
    	end
    	else
    		select @last_non_blank_ccc = 4
    
    	if IsNull(@ins_cccode5, '') =  ''
    	begin
    		if @first_blank_ccc = 0
    			select @first_blank_ccc = 5
    	end
    	else
    		select @last_non_blank_ccc = 5
    
    	if IsNull(@ins_cccode6, '') = ''
    	begin
    		if @first_blank_ccc = 0
    			select @first_blank_ccc = 6
    	end
    	else
    		select @last_non_blank_ccc = 6
    
    	if @first_blank_ccc > 0 and @last_non_blank_ccc > 0 and
    	   @first_blank_ccc < @last_non_blank_ccc
    	begin
    		raiserror 25000 "Partial Chinese name input is not allowed, fail to update patient record!"
    		return
    	end
    
    end
    */
    /* 2007-02-13 by HK Fong SMR20016006 - End */
    IF var_del_hkid != var_ins_hkid OR var_del_patient_name != var_ins_patient_name OR var_del_cccode1 != var_ins_cccode1 OR var_del_cccode2 != var_ins_cccode2 OR var_del_cccode3 != var_ins_cccode3 OR var_del_cccode4 != var_ins_cccode4 OR var_del_cccode5 != var_ins_cccode5 OR var_del_cccode6 != var_ins_cccode6 OR var_del_sex != var_ins_sex OR var_del_dob != var_ins_dob THEN
        /* remarked to fix double byte not match with CCC created by OPAS */
        /* do not keep log on those changes */
        /*
        @del_dob             != @ins_dob          or
        @del_chi_name        != @ins_chi_name
        */
        BEGIN
            IF NOT EXISTS (SELECT
                *
                FROM cpi_patient_key_changed
                WHERE patient_key = var_ins_patient_key AND original_hkid = var_ins_hkid) THEN
                BEGIN
                    /*
                    insert cpi_patient_key_changed
                    (patient_key, hkid, patient_name,
                     sex, cccode1, cccode2, cccode3,
                     cccode4, cccode5, cccode6,
                     chi_name, dob, original_hkid, update_hospital,
                     update_by, update_dtm)
                    select
                        @ins_patient_key, @del_hkid, @del_patient_name,
                        @del_sex, @del_cccode1, @del_cccode2, @del_cccode3,
                        @del_cccode4, @del_cccode5, @del_cccode6,
                        @del_chi_name, @del_dob, @ins_hkid, update_hospital,
                        update_by, update_dtm
                      from deleted
                    */
                    /* get true chi name before logging 19981207 ML */
                    CALL cpi_get_phonetic_chin_name(var_return_code, var_del_cccode1, var_del_cccode2, var_del_cccode3, var_del_cccode4, var_del_cccode5, var_del_cccode6, var_tmp_phonetic, var_tmp_del_chi_name);

                    BEGIN
                        INSERT INTO cpi_patient_key_changed (patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, original_hkid, update_hospital, update_by, update_dtm)
                        SELECT
                            var_ins_patient_key, var_del_hkid, var_del_patient_name, var_del_sex, var_del_cccode1, var_del_cccode2, var_del_cccode3, var_del_cccode4, var_del_cccode5, var_del_cccode6, var_tmp_del_chi_name, var_del_dob, var_ins_hkid, update_hospital, update_by, update_dtm
                            FROM deleted;
                        EXCEPTION
                            WHEN OTHERS THEN
                                RETURN NULL;
                    END;
                END;
            END IF;

            BEGIN
                INSERT INTO cpi_patient_key_changed (patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, original_hkid, update_hospital, update_by, update_dtm)
                SELECT
                    var_ins_patient_key, var_ins_hkid, var_ins_patient_name, var_ins_sex, var_ins_cccode1, var_ins_cccode2, var_ins_cccode3, var_ins_cccode4, var_ins_cccode5, var_ins_cccode6, var_ins_chi_name, var_ins_dob, var_ins_hkid, update_hospital, update_by, update_dtm
                    FROM inserted;
                EXCEPTION
                    WHEN OTHERS THEN
                        RETURN NULL;
            END;
        END;
    END IF;

    IF var_ins_marital_status != var_del_marital_status OR var_ins_other_doc_no != var_del_other_doc_no OR var_ins_building != var_del_building OR var_ins_room != var_del_room OR var_ins_floor != var_del_floor OR var_ins_block != var_del_block OR var_ins_district != var_del_district OR var_ins_religion != var_del_religion OR var_ins_phone1 != var_del_phone1 OR var_ins_phone2 != var_del_phone2 OR var_ins_address_indicator != var_del_address_indicator OR var_ins_mobile_phone != var_del_mobile_phone OR var_ins_sms_language != var_del_sms_language THEN
        BEGIN
            IF NOT EXISTS (SELECT
                *
                FROM cpi_patient_other_changed
                WHERE patient_key = var_ins_patient_key) THEN
                BEGIN
                    BEGIN
                        INSERT INTO cpi_patient_other_changed (patient_key, marital_status, other_doc_no, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, update_hospital, update_by, update_dtm)
                        SELECT
                            var_ins_patient_key, var_del_marital_status, var_del_other_doc_no, var_del_building, var_del_room, var_del_floor, var_del_block, var_del_district, var_del_religion, var_del_phone1, var_del_phone2, var_del_address_indicator, var_del_mobile_phone, var_del_sms_language, update_hospital, update_by, update_dtm
                            FROM deleted;
                        EXCEPTION
                            WHEN OTHERS THEN
                                RETURN NULL;
                    END;
                END;
            END IF;
            INSERT INTO cpi_patient_other_changed (patient_key, marital_status, other_doc_no, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, update_hospital, update_by, update_dtm)
            SELECT
                var_ins_patient_key, var_ins_marital_status, var_ins_other_doc_no, var_ins_building, var_ins_room, var_ins_floor, var_ins_block, var_ins_district, var_ins_religion, var_ins_phone1, var_ins_phone2, var_ins_address_indicator, var_ins_mobile_phone, var_ins_sms_language, update_hospital, update_by, update_dtm
                FROM inserted;
        END;
    END IF;

    IF EXISTS (SELECT
        *
        FROM cpi_patient_location
        WHERE patient_key = var_del_patient_key) THEN
        BEGIN
            /* call stored procedure to get name_phonetic */
            CALL cpi_get_phonetic_chin_name(var_return_code, var_ins_cccode1, var_ins_cccode2, var_ins_cccode3, var_ins_cccode4, var_ins_cccode5, var_ins_cccode6, var_name_phonetic, var_chi_name);

            BEGIN
                UPDATE cpi_patient_location
                SET patient_key = var_ins_patient_key, patient_name = var_ins_patient_name, name_soundex = soundex(var_ins_patient_name), name_phonetic = var_name_phonetic, sex = var_ins_sex, dob = var_ins_dob, chinese_name = var_ins_chi_name, phone1 = var_ins_phone1, phone2 = var_ins_phone2, mobile_phone = var_ins_mobile_phone,
                /* 20140822/Ray/Enquiry of Patient Location chinese name search begin */
                /* new fields */
                cccode1 = var_ins_cccode1, cccode2 = var_ins_cccode2, cccode3 = var_ins_cccode3, cccode4 = var_ins_cccode4, cccode5 = var_ins_cccode5, cccode6 = var_ins_cccode6
                    /* 20140822/Ray/Enquiry of Patient Location chinese name search begin */
                    WHERE patient_key = var_del_patient_key;
                EXCEPTION
                    WHEN OTHERS THEN
                        RETURN NULL;
            END;
        END;
    END IF;
    /* added for update cpi_access_changed */
    IF var_ins_hkid != var_del_hkid THEN
        BEGIN
            BEGIN
                UPDATE cpi_access_changed
                SET original_hkid = var_ins_hkid
                    WHERE patient_key = var_del_patient_key AND original_hkid = var_del_hkid;
                EXCEPTION
                    WHEN OTHERS THEN
                        RETURN NULL;
            END;
        END;
    END IF;
    /* added for insert cpi_access_changed for access code change */
    IF ((var_ins_access_code & 1) != (var_del_access_code & 1)) THEN
        BEGIN
            IF NOT EXISTS (SELECT
                *
                FROM cpi_access_changed
                WHERE patient_key = var_ins_patient_key AND original_hkid = var_ins_hkid) THEN
                BEGIN
                    IF var_del_access_code & 1 = 1 THEN
                        SELECT
                            'U'
                            INTO var_temp_access_code;
                    ELSE
                        SELECT
                            'C'
                            INTO var_temp_access_code;
                    END IF;

                    BEGIN
                        INSERT INTO cpi_access_changed (patient_key, original_hkid, update_dtm, access_status, update_hospital, update_by)
                        SELECT
                            var_ins_patient_key, var_del_hkid, update_dtm, var_temp_access_code, update_hospital, update_by
                            FROM deleted;
                        EXCEPTION
                            WHEN OTHERS THEN
                                RETURN NULL;
                    END;
                END;
            END IF;

            IF var_ins_access_code & 1 = 1 THEN
                SELECT
                    'U'
                    INTO var_temp_access_code;
            ELSE
                SELECT
                    'C'
                    INTO var_temp_access_code;
            END IF;

            BEGIN
                INSERT INTO cpi_access_changed (patient_key, original_hkid, update_dtm, access_status, update_hospital, update_by)
                SELECT
                    var_ins_patient_key, var_ins_hkid, update_dtm, var_temp_access_code, update_hospital, update_by
                    FROM inserted;
                EXCEPTION
                    WHEN OTHERS THEN
                        RETURN NULL;
            END;
        END;
    END IF;
    /*
    comment by Karen on Jan 23
    /* District UPDATE RESTRICTS */
    /* Updated by Alan Tai on Jan 16 '98 */
    if
    	update(district)
    begin
    	if exists (select * from inserted
    					where
    						inserted.district is NULL and
    						(inserted.building is not NULL or
    						 inserted.floor is not NULL or
    						 inserted.block is not NULL or
    						 inserted.room is not NULL))
    	begin
    		raiserror 25000 "District code cannot be NULL!"
    		return
    	end
    
    	select @nullcnt = 0
    	select @validcnt = count(*)
    			from inserted, district
    				where
    					inserted.district = district.district_code
    	select @nullcnt = count(*)
    			from inserted
    				where
    					inserted.district is null
    	if @validcnt + @nullcnt != @@rowcount
    	begin
    		raiserror 25000 "Invalid District Code!"
    		return
    	end
    end
    */
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_cpi_tu_patient" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
