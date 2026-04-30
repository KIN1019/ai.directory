-- DROP PROCEDURE hpi.cpi_nok_update(inout int4, in varchar, in varchar, inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_nok_update(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_patient_key character varying, INOUT par_priority integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_phone1 character varying, IN par_nok_phone2 character varying, IN par_nok_address_indicator character varying, IN par_nok_mobile_phone character varying, IN par_nok_sms_language character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
    var_return_status SMALLINT;
    var_n_prior INTEGER;
    var_min_priority INTEGER;
    var_major_nok CHAR(1);
    var_rep_clusters INTEGER;
    var_success_flag CHAR(1);
    var_exit_flag CHAR(1);
    var_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_return_error_code INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        /* Declaration */
        /*
        if @@trancount = 0
           begin
              select   @return_error_code = 20000
              select   @success_flag = "N"
              goto return_error
           end
        */
        /*
        save transaction cpi_nok_update
        */
--	SAVEPOINT cpi_nok_update
        /* Assign the transaction_datetime of source system to source_system_dtm */
        SELECT
            par_transaction_datetime
            INTO var_source_system_dtm;
        /* Use a common datetime to update all tables */
        SELECT
            timestamp_convert(localtimestamp)
            INTO par_transaction_datetime;
        /* Set flags */
        SELECT
            'Y'
            INTO var_success_flag;
        /* Validate key fields */
        /* Get initiate bit values */
        /*
        select	@rep_hospital = bit_value
        	from	rep_cluster_bits
        	where	hospital_code = @hospital_code
        
        	if (@@rowcount = 0)
        	begin
        /*		print "Fail to get bit values from rep_cluster_bits, nok update is rejected!" */
        		select	@return_error_code = 11001
        		select	@success_flag = "N"
        		goto return_error
        	end
        */
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_patient
            WHERE patient_key = par_patient_key;

        IF var_cnt = 0 THEN
            BEGIN
                /* print "Patient does not exist in CPI, NOK update is rejected!" */
                SELECT
                    11001
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* update nok record */
        /*
        Rules:	If priority is not given, it is assumed the NOK is a new one.
        Insertion operation will be done.
        If priority is given and name is not null, it assumes an
        update operation.
        If priority is given and name is NULL, it assumes a delete
        operation.
        */
        IF (par_priority IS NULL) THEN
            BEGIN
                SELECT
                    1
                    INTO var_n_prior;
                SELECT
                    COUNT(*)
                    INTO var_cnt
                    FROM cpi_nok
                    WHERE patient_key = par_patient_key;

                IF (var_cnt != 0) THEN
                    BEGIN
                        SELECT
                            MAX(priority) + 1
                            INTO var_n_prior
                            FROM cpi_nok
                            WHERE patient_key = par_patient_key;
                    END;
                END IF;
                /*
                if (@n_prior = 1)
                	select	@major_nok = "Y"
                else
                	select	@major_nok = "N"
                */
                SELECT
                    'N'
                    INTO var_major_nok;
                SELECT
                    var_n_prior
                    INTO par_priority;

                IF (par_nok_name IS NOT NULL) THEN
                    BEGIN
                        begin
	                        raise notice '[cpi_nok_update]insert cpi_nok param(%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%)',par_patient_key, var_n_prior, var_major_nok, par_nok_hkid, par_nok_relation_code, par_nok_name, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language, par_hospital_code, par_update_by, par_transaction_datetime;
                            INSERT INTO cpi_nok (patient_key, priority, major_nok, hkid, relationship, nok_name, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language, update_hospital, update_by, update_dtm)
                            VALUES (par_patient_key, var_n_prior, var_major_nok, par_nok_hkid, par_nok_relation_code, par_nok_name, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language, par_hospital_code, par_update_by, par_transaction_datetime);
                            raise notice '[128]cpi_nok_update[INSERT INTO cpi_nok]par_patient_key=%',par_patient_key; 
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF (var_error != 0) OR (var_rowcount = 0) THEN
                            BEGIN
                                /* print "Fail to insert into cpi_nok, NOK update is rejected!" */
                                SELECT
                                    11002
                                    INTO var_return_error_code;
                                SELECT
                                    'N'
                                    INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                SELECT
                    major_nok
                    INTO var_major_nok
                    FROM cpi_nok
                    WHERE patient_key = par_patient_key AND priority = par_priority;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount = 0 THEN
                    BEGIN
                        /* print "Given priority does not exist, fail to update cpi_nok. NOK update is rejected!" */
                        SELECT
                            11003
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;

                IF var_major_nok = 'Y' THEN
                    BEGIN
                        SELECT
                            200008
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;

                IF (par_nok_name IS NOT NULL) THEN
                    BEGIN
                        BEGIN
                            UPDATE cpi_nok
                            SET relationship = par_nok_relation_code, nok_name = par_nok_name, hkid = par_nok_hkid, building = par_nok_building, room = par_nok_room, floor = par_nok_floor, block = par_nok_block, district = par_nok_district_code, phone1 = par_nok_phone1, phone2 = par_nok_phone2, address_indicator = par_nok_address_indicator, mobile_phone = par_nok_mobile_phone, sms_language = par_nok_sms_language, update_hospital = par_hospital_code, update_by = par_update_by, update_dtm = par_transaction_datetime
                                WHERE patient_key = par_patient_key AND priority = par_priority;
                             raise notice '[192]cpi_nok_update[ UPDATE cpi_nok]par_patient_key=%',par_patient_key; 
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF (var_error != 0) OR (var_rowcount = 0) THEN
                            BEGIN
                                /* print "Fail to update cpi_nok, NOK update is rejected!" */
                                SELECT
                                    11004
                                    INTO var_return_error_code;
                                SELECT
                                    'N'
                                    INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        /*
                        if (@major_nok = "Y")
                        			begin
                        				select	@min_priority = priority
                        				from	cpi_nok
                        				where	patient_key = @patient_key
                        
                        				if (@@rowcount != 0)
                        				begin
                        					update	cpi_nok
                        					set	major_nok = "Y"
                        					where	patient_key = @patient_key
                        					and	priority = @min_priority
                        
                        					select	@error = @@error,
                        						@rowcount = @@rowcount
                        					if (@error != 0) or (@rowcount = 0)
                        					begin
                        /*						print "Fail to set major_nok of cpi_nok, NOK update is rejected!" */
                        						select	@success_flag = "N"
                        						select	@return_error_code = 11007
                        						goto return_error
                        					end
                        				end
                        			end
                        */
                        BEGIN
                            DELETE FROM cpi_nok
                                WHERE patient_key = par_patient_key AND priority = par_priority;
                            raise notice '[245]cpi_nok_update[DELETE FROM cpi_nok]par_patient_key=%',par_patient_key;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF (var_error != 0) OR (var_rowcount = 0) THEN
                            BEGIN
                                /* print "Fail to delete cpi_nok, NOK update is rejected!" */
                                SELECT
                                    11005
                                    INTO var_return_error_code;
                                SELECT
                                    'N'
                                    INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* insert transaction record */
        /*
        Prevent transaction time of different source
        system is the same.  Add seconds to the transaction time.
        */
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_transaction
            WHERE hospital_code = par_hospital_code AND transaction_datetime = par_transaction_datetime;

        IF (var_cnt != 0) THEN
            BEGIN
                SELECT
                    'N'
                    INTO var_exit_flag;

                WHILE (var_exit_flag = 'N') LOOP
                    SELECT
                        1 * INTERVAL '1 second' + par_transaction_datetime::TIMESTAMP
                        INTO par_transaction_datetime;
                    SELECT
                        COUNT(*)
                        INTO var_cnt
                        FROM cpi_transaction
                        WHERE hospital_code = par_hospital_code AND transaction_datetime = par_transaction_datetime;

                    IF (var_cnt = 0) THEN
                        SELECT
                            'Y'
                            INTO var_exit_flag;
                    END IF;
                END LOOP;
            END;
        END IF;

        BEGIN
            INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, chi_name, marital_status, race_code, other_document_no, reference, medical_record_number, remark, building, room, floor, block, district_code, religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder, priority, major_nok, nok_name, nok_hkid, nok_relation_code, nok_building, nok_room, nok_floor, nok_block, nok_district_code, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, case_no, admission_datetime, source_indicator, source_code, patient_type, discharge_code, discharge_datetime, destination_code, doctor_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba_flag, follow_up_datetime, ward_code, specialty_code, sub_specialty_code, bed_no, ward_class, transfer_datetime, old_patient_key, old_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, old_doctor_code, pp_code, update_hospital, update_by, update_datetime, source_system, success_indicator, upload_status, source_system_dtm)
            VALUES (par_hospital_code, par_transaction_datetime, par_txn_type, NULL, par_patient_key, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_priority, var_major_nok, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_hospital_code, par_update_by, timestamp_convert(localtimestamp), par_source_system, var_success_flag, 'Y', var_source_system_dtm);
			raise notice '[309]cpi_nok_update[INSERT INTO cpi_transaction]par_patient_key=%',par_patient_key;           
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to insert cpi_transaction for NOK update!" */
                SELECT
                    11006
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;

        <<insert_transaction>>
        BEGIN
        END;
    END;

    IF (var_success_flag = 'N') THEN
        BEGIN
            /*
            rollback cpi_nok_update
            */
--	    ROLLBACK TO SAVEPOINT cpi_nok_update;
--ROLLBACK;
            raise exception '';
            pas_return_code := var_return_error_code;
            RETURN;
        END;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_nok_update" OWNER TO "HPI_SCHEMA_OWNER_ROLE";