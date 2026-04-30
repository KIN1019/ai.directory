-- DROP PROCEDURE hpi.cpi_update_patient_key(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4);

CREATE OR REPLACE PROCEDURE hpi.cpi_update_patient_key(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_patient_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_old_patient_key character varying, IN par_new_patient_key character varying, IN par_update_by character varying, IN par_source_system character varying, IN par_exact_dob_flag character varying, IN par_ccc_1 character varying, IN par_ccc_2 character varying, IN par_ccc_3 character varying, IN par_ccc_4 character varying, IN par_ccc_5 character varying, IN par_ccc_6 character varying, IN par_chi_name character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_reference character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_phone1 character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone character varying, IN par_sms_language character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_death_code character varying, IN par_card_holder integer)
 LANGUAGE plpgsql
AS $procedure$
/*
This procedure is run in the update trigger of cpi_patient
Mar 1998 - return the correct return code for calling opas remote
				stored proc. If opas db is not ready, do not perform
				the patient key checking by Stephen CHAN
19991210 - update patient key of cpi_postal_address if patient key
				changed by WL
29/10/2004 - Add update for cpi_new_born
*/
DECLARE
    var_cnt INTEGER;
    var_return_status INTEGER;
    var_success_flag VARCHAR(1);
    var_exit_flag VARCHAR(1);
    var_return_error_code INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_valid_flag VARCHAR(1);
    var_loop INTEGER;
    var_hosp_code VARCHAR(3);
    var_rpc_name VARCHAR(50);
    var_return_code INTEGER;
    var_transaction_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_transaction_type CHAR(3);
    var_case_no VARCHAR(12);
    var_mo_prk VARCHAR(8);
    var_mo_hkid VARCHAR(12);
    var_nb_prk VARCHAR(8);
    var_nb_hkid VARCHAR(12);
    var_birth_order INTEGER;
    var_preg_number INTEGER;
    var_opas_db VARCHAR(30);
   	found_code integer;
    hosp_cur CURSOR FOR
    SELECT
        hospital_code
        FROM hospital;

    cur_mo CURSOR FOR
    SELECT
        mother_case_no, new_born_patient_key
        FROM cpi_new_born
        WHERE mother_patient_key = par_old_patient_key AND hospital_code = var_hosp_code;
    cura CURSOR FOR
    SELECT
        case_no
        FROM cpi_case
        WHERE patient_key = par_old_patient_key AND hospital_code = var_hosp_code;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        /* Declaration */
        /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
        /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End */
        /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
        SELECT
            CASE
                WHEN hospital_code IN ('QMH', 'UCH') THEN 'opsystem'
                ELSE 'opas'
            END
            INTO var_opas_db
            FROM hospital;
        /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End */
        /* get the transaction_datetime and transaction_type */
        SELECT
            timestamp_convert(localtimestamp), '032'
            INTO var_transaction_datetime, var_transaction_type;
        /* check the @old_patient_key exist. If so, do it. If not, skip it. */
        /*
        @old_patient_key exist and have to be update.
        	The update sequence is as following
        		  1. cpi_patient (it was updated)
        		  2. cpi_patient_key_changed
        		  3. cpi_patient_other_changed
        		  4. cpi_nok
        		  5. cpi_patient_hospital_data
        		  6. cpi_patient_hosp_mrn_changed
        		  6. cpi_new_born for new born
                6. cpi_new_born for mother case
        		  7. cpi_case
        		  8. cpi_case_key_changed (updated by trigger)
        		  9. cpi_patient_location (updated by trigger)
        		 10. cpi_access_changed
        		 11. cpi_postal_address ( added by WL )
        */
        BEGIN
            UPDATE cpi_patient_key_changed
            SET patient_key = par_new_patient_key
                WHERE patient_key = par_old_patient_key;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                SELECT
                    var_error
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;

        BEGIN
            UPDATE cpi_patient_other_changed
            SET patient_key = par_new_patient_key
                WHERE patient_key = par_old_patient_key;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                SELECT
                    var_error
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;

        BEGIN
            UPDATE cpi_nok
            SET patient_key = par_new_patient_key
                WHERE patient_key = par_old_patient_key;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                SELECT
                    var_error
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* loop for all hospitals in that server */
        OPEN hosp_cur;
        FETCH hosp_cur INTO var_hosp_code;
		select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
        WHILE found_code = 0 LOOP
            BEGIN
                UPDATE cpi_patient_hospital_data
                SET patient_key = par_new_patient_key
                    WHERE patient_key = par_old_patient_key AND hospital_code = var_hosp_code;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;

            IF var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    SELECT
                        'N'
                        INTO var_success_flag;
                    EXIT return_error;
                END;
            END IF;

            BEGIN
                UPDATE cpi_patient_hosp_mrn_changed
                SET patient_key = par_new_patient_key
                    WHERE patient_key = par_old_patient_key AND hospital_code = var_hosp_code;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;

            IF var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    SELECT
                        'N'
                        INTO var_success_flag;
                    EXIT return_error;
                END;
            END IF;

            IF EXISTS (SELECT
                *
                FROM cpi_new_born
                WHERE new_born_patient_key = par_old_patient_key AND hospital_code = var_hosp_code) THEN
                BEGIN
                    SELECT
                        mother_patient_key, birth_order, pregnancy_number, mother_case_no
                        INTO var_mo_prk, var_birth_order, var_preg_number, var_case_no
                        FROM cpi_new_born
                        WHERE new_born_patient_key = par_old_patient_key AND hospital_code = var_hosp_code;
                    SELECT
                        hkid
                        INTO var_mo_hkid
                        FROM cpi_patient
                        WHERE patient_key = var_mo_prk;
                    CALL cpi_update_new_born(var_return_code, 'P', var_hosp_code, var_mo_hkid, par_hkid, var_case_no, var_birth_order, var_preg_number, par_update_by, var_transaction_datetime, par_old_patient_key, par_new_patient_key);


                    IF var_return_code != 0 THEN
                        BEGIN
                            SELECT
                                var_return_code
                                INTO var_return_error_code;
                            SELECT
                                'N'
                                INTO var_success_flag;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            OPEN cur_mo;
            FETCH cur_mo INTO var_case_no, var_nb_prk;
			select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
            WHILE found_code = 0 LOOP
                SELECT
                    birth_order, pregnancy_number
                    INTO var_birth_order, var_preg_number
                    FROM cpi_new_born
                    WHERE mother_patient_key = par_old_patient_key AND hospital_code = var_hosp_code AND mother_case_no = var_case_no AND new_born_patient_key = var_nb_prk;
                SELECT
                    hkid
                    INTO var_nb_hkid
                    FROM cpi_patient
                    WHERE patient_key = var_nb_prk;
                CALL cpi_update_new_born(var_return_code, 'U', var_hosp_code, par_hkid, var_nb_hkid, var_case_no, var_birth_order, var_preg_number, par_update_by, var_transaction_datetime, NULL, NULL);

                IF var_return_code != 0 THEN
                    BEGIN
                        SELECT
                            var_return_code
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
                FETCH cur_mo INTO var_case_no, var_nb_prk;
               	select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
            END LOOP;
            CLOSE cur_mo;
            OPEN cura;
            FETCH cura INTO var_case_no;
			select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
            WHILE found_code = 0 LOOP
                BEGIN
                    UPDATE cpi_case
                    SET patient_key = par_new_patient_key
                        WHERE patient_key = par_old_patient_key AND hospital_code = var_hosp_code AND case_no = var_case_no;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF var_error != 0 THEN
                    BEGIN
                        SELECT
                            var_error
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
                FETCH cura INTO var_case_no;
               	select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
            END LOOP;
            CLOSE cura;
            /*
            the following is remarked by Alex since these two tables
            will be updated by triggers
            
            	update cpi_case_key_changed
            	set patient_key = @new_patient_key
            	where patient_key = @old_patient_key
            	and hospital_code = @hosp_code
            	select @error = @@error
            	if @error != 0
            	begin
            		select @return_error_code = @error
            		select @success_flag = 'N'
            		goto return_error
            	end
            
            	update cpi_patient_location
            	set patient_key = @new_patient_key
            	where patient_key = @old_patient_key
            	and hospital_code = @hosp_code
            	select @error = @@error
            	if @error != 0
            	begin
            		select @return_error_code = @error
            		select @success_flag = 'N'
            		goto return_error
            	end
            */
            /* insert cpi_tranaction */
            SELECT
                COUNT(*)
                INTO var_cnt
                FROM cpi_transaction
                WHERE hospital_code = par_hospital_code AND transaction_datetime = var_transaction_datetime;

            IF (var_cnt != 0) THEN
                BEGIN
                    SELECT
                        'N'
                        INTO var_exit_flag;

                    WHILE (var_exit_flag = 'N') LOOP
                        SELECT
                            3 * INTERVAL '1 millisecond' + var_transaction_datetime::TIMESTAMP
                            INTO var_transaction_datetime;
                        SELECT
                            COUNT(*)
                            INTO var_cnt
                            FROM cpi_transaction
                            WHERE hospital_code = par_hospital_code AND transaction_datetime = var_transaction_datetime;

                        IF (var_cnt = 0) THEN
                            SELECT
                                'Y'
                                INTO var_exit_flag;
                        END IF;
                    END LOOP;
                END;
            END IF;
            INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, chi_name, marital_status, race_code, other_document_no, reference, building, room, floor, block, district_code, religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder, old_patient_key, update_hospital, update_by, update_datetime, source_system, success_indicator, upload_status, source_system_dtm)
            VALUES (var_hosp_code, var_transaction_datetime, var_transaction_type, par_hkid, par_new_patient_key, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_chi_name, par_marital_status, par_race_code, par_other_document_no, par_reference, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_phone1, par_phone2, par_address_indicator, par_mobile_phone, par_sms_language, par_death_indicator, par_death_date, par_death_code, par_card_holder, par_old_patient_key, par_hospital_code, par_update_by, var_transaction_datetime, par_source_system, 'Y', 'P', var_transaction_datetime);
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            BEGIN
                var_cnt := sql$rowcount;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;

            IF var_cnt != 1 OR var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    SELECT
                        'N'
                        INTO var_success_flag;
                    EXIT return_error;
                END;
            END IF;
            /* call ADT's stored procedure to update its T_PRK in Case table */
            /*
            select @return_code = db_id(rtrim(lower(@hosp_code)) + "adt_db")
            if @return_code != null
            begin
            	select @rpc_name = lower(@hosp_code) + "adt_db..hasp_update_t_prk"
            	exec @return_code = @rpc_name @hosp_code,
            						@hkid, @patient_name, @sex, @dob,
            						@old_patient_key, @new_patient_key,
            						@update_by
            	if @return_code != 0
            	begin
            		select @return_error_code = @return_code
            		select @success_flag = 'N'
            		goto return_error
            	end
            end
            */
            FETCH hosp_cur INTO var_hosp_code;
            select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
        END LOOP;

        /* call Out-patient's stored procedure to update its patient_no */
        /*
        check the existence of the db opsystem before calling to aviod
        un-expected error
        */
        /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
        /* select @return_code = db_id('opsystem') */
        /*SELECT
            to_regnamespace(var_opas_db)
            INTO var_return_code;*/
        SELECT
            oid
            INTO var_return_code
            from pg_catalog.pg_database 
            where datname= var_opas_db;
        /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End */
        IF var_return_code is not NULL THEN
            BEGIN
                /*
                [3061 - Severity CRITICAL - Unable to convert system object sysdatabases. Perform a manual conversion.]
                if exists (select name from master..sysdatabases
                2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start
                						where name = 'opsystem' and
                						where name = @opas_db and
                2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End
                								( status & 0x800 > 0 or
                								  status & 0x1000 > 0 or
                								  status & 0x100 > 0 )
                					 )
                		begin
                			select @return_error_code = -1
                			select @success_flag = 'N'
                			print "!!!!! OPAS DB not ready."
                			goto return_error
                		end
                */
                /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
                /* select @rpc_name = 'opsystem..cpi_change_patient_no' */
                SELECT
                    CONCAT(RTRIM(var_opas_db), '.cpi_change_patient_no')
                    INTO var_rpc_name;
                /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End */
                /*
                [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
                exec @return_code = @rpc_name @hospital_code,
                												@hkid, @patient_name, @sex, @dob,
                												@old_patient_key, @new_patient_key,
                												@update_by
                */
				execute 'call '||var_rpc_name||'('||par_hospital_code||','|| par_hkid ||','|| par_patient_name ||','|| par_sex ||','|| par_dob ||','|| par_old_patient_key ||','|| par_update_by ||','|| var_return_code ||');' into var_return_code;
                IF var_return_code != 0 THEN
                    BEGIN
                        SELECT
                            var_return_code
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        RAISE NOTICE '!!!!! Error in Call OPAS stored proc';
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;

        BEGIN
            UPDATE cpi_access_changed
            SET patient_key = par_new_patient_key
                WHERE patient_key = par_old_patient_key;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                SELECT
                    var_error
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* --- remark cpi.. for HPI by WL on 19991210--- */
        
        /* --update cpi..cpi_postal_address */
        BEGIN
            UPDATE cpi_postal_address
            SET patient_key = par_new_patient_key
                WHERE patient_key = par_old_patient_key;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                SELECT
                    var_error
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
    END;

    IF (var_success_flag = 'N') THEN
        pas_return_code := var_return_error_code;
        RETURN;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
END;
$procedure$
;


;ALTER PROCEDURE "cpi_update_patient_key" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
