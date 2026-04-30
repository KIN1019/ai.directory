-- DROP PROCEDURE hkpmi.hkpmi_patient_death_tx(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_patient_death_tx(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_txn_type character varying, IN par_hkid character varying, IN par_write_tx_for_local_hosp character varying, IN par_exact_death_date character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* transaction information */
/* patient information */
/* --	@death						char(01) */
DECLARE
    var_return_status SMALLINT;
    var_return_error_code INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_tmp_hospital_code VARCHAR(03);
    var_tran_hospital_code VARCHAR(03);
    var_process_local_hospital VARCHAR(01);
    var_begin_tran VARCHAR(01);
    var_tran_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_upload_status VARCHAR(01);
    /* patient information */
    var_patient_key VARCHAR(08);
    var_patient_name VARCHAR(48);
    var_sex VARCHAR(01);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_death_indicator VARCHAR(04);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_discharge_code VARCHAR(1);
    var_update_by VARCHAR(08);
    var_source_system VARCHAR(05);
    var_death_external_cause VARCHAR(04);
    var_death_diagnosis VARCHAR(04);
    sql$rowcount BIGINT;
	my_conn varchar;
    error_sqlstate BIGINT;
    error_msg text;
    sqlstatus INTEGER;
    hosp_cursor CURSOR FOR
    SELECT
        h.hospital_code
        FROM hospital AS h, patient_detail_1 AS p
        WHERE p.patient_key = var_patient_key AND (p.hosp_byte_1 & h.byte_value_1 > 0 OR p.hosp_byte_2 & h.byte_value_2 > 0 OR p.hosp_byte_3 & h.byte_value_3 > 0) AND h.hospital_code != par_hospital_code
    UNION
    SELECT DISTINCT
        hospital_code
        FROM pmi_case
        WHERE patient_key = var_patient_key AND hospital_code != par_hospital_code;
BEGIN
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN
            /* Declaration */
            
            /* Validate key fields */
			select 'Y' into var_begin_tran;
            IF NOT par_txn_type IN ('033') THEN
                BEGIN
                    /* Invalid transaction type. */
                    SELECT
                        200014
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* get patient information by HKID */
            SELECT
                patient_key, patient_name, sex, dob, death_indicator, death_date, update_by, source_system, death_external_cause, death_diagnosis, source_system_dtm
                INTO var_patient_key, var_patient_name, var_sex, var_dob, var_death_indicator, var_death_date, var_update_by, var_source_system, var_death_external_cause, var_death_diagnosis, var_source_system_dtm
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
            /*
            if @death_indicator = null and @death = 'Y'
            	begin
                  select @return_error_code = 200119
                  goto return_error
               end
            
            	if @death_indicator != null and @death = 'N'
            	begin
                  select @return_error_code = 200120
                  goto return_error
               end
            */
            IF var_death_indicator is NULL THEN
                BEGIN
                    SELECT
                        NULL, NULL, NULL, NULL
                        INTO var_discharge_code, var_death_date, var_death_external_cause, var_death_diagnosis;
                END;
            ELSE
                BEGIN
                    SELECT
                        '1'
                        INTO var_discharge_code;
                END;
            END IF;
            /* --	/*	insert transaction_log for access code updated */ */
            /* --	declare hosp_cursor cursor for */
            /* --		select distinct hospital_code */
            /* --			from pmi_case */
            /* --			where patient_key = @patient_key and */
            /* --					hospital_code != @hospital_code */
            /* --			for read only */
            /* 19981106 GL */
            OPEN hosp_cursor;
            FETCH hosp_cursor INTO var_tmp_hospital_code;
            select  CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
            end into sqlstatus;
            IF par_write_tx_for_local_hosp = 'N' THEN
                SELECT
                    'Y'
                    INTO var_process_local_hospital;
            ELSE
                SELECT
                    'N'
                    INTO var_process_local_hospital;
            END IF;
            SELECT
                timestamp_convert(localtimestamp)
                INTO var_tran_system_dtm;

            WHILE sqlstatus = 0 OR var_process_local_hospital = 'N' loop
	
                IF var_process_local_hospital = 'N' THEN
                    BEGIN
                        SELECT
                            par_hospital_code
                            INTO var_tran_hospital_code;

                        IF var_source_system = 'DNL' THEN
                            SELECT
                                'P'
                                INTO var_upload_status;
                        ELSE
                            SELECT
                                'Y'
                                INTO var_upload_status;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        SELECT
                            var_tmp_hospital_code, 'P'
                            INTO var_tran_hospital_code, var_upload_status;
                    END;
                END IF;

                WHILE 1 = 1 loop
	                begin
                    IF par_exact_death_date IS NOT NULL THEN
						
						INSERT INTO download.transaction_log (system_dtm, hospital_code, type, hkid, patient_key, patient_name, sex, dob, discharge_code, death_indicator, death_date, death_external_cause, death_diagnosis, update_by, source_system, source_system_dtm, update_hospital, upload_status, filler)
                            VALUES (timestamp_convert(var_tran_system_dtm), var_tran_hospital_code, par_txn_type, par_hkid, var_patient_key, var_patient_name, var_sex, timestamp_convert(var_dob), var_discharge_code, var_death_indicator, timestamp_convert(var_death_date), var_death_external_cause, var_death_diagnosis, var_update_by, var_source_system, timestamp_convert(var_source_system_dtm), par_hospital_code, var_upload_status, CONCAT(REPEAT(' ', 09), par_exact_death_date));
						
                    ELSE
						INSERT INTO download.transaction_log (system_dtm, hospital_code, type, hkid, patient_key, patient_name, sex, dob, discharge_code, death_indicator, death_date, death_external_cause, death_diagnosis, update_by, source_system, source_system_dtm, update_hospital, upload_status)
                            VALUES (timestamp_convert(var_tran_system_dtm), var_tran_hospital_code, par_txn_type, par_hkid, var_patient_key, var_patient_name, var_sex, timestamp_convert(var_dob), var_discharge_code, var_death_indicator, timestamp_convert(var_death_date), var_death_external_cause, var_death_diagnosis, var_update_by, var_source_system, timestamp_convert(var_source_system_dtm), par_hospital_code, var_upload_status);
                    END IF;
					EXCEPTION  
						WHEN unique_violation OR OTHERS THEN  
							BEGIN
								GET STACKED DIAGNOSTICS error_sqlstate = RETURNED_SQLSTATE;  
								IF error_sqlstate = '23505' THEN  
									select var_tran_system_dtm + INTERVAL '3 milliseconds' into var_tran_system_dtm;  
									CONTINUE;
							
								ELSE  
									select error_sqlstate into  var_return_error_code ;
									EXIT return_system_error;
								END IF;
							end;
                   
                   end;
                   EXIT;
                END LOOP;
				
                   
                IF var_process_local_hospital = 'N' THEN
                    BEGIN
						select 'Y' into var_process_local_hospital;

                    END;
                ELSE
                    BEGIN
                        FETCH hosp_cursor INTO var_tmp_hospital_code;
                       select  CASE
			                WHEN FOUND THEN 0
			                WHEN NOT FOUND THEN 2
			                ELSE 1
			            end into sqlstatus;
                    END;
                END IF;
            END LOOP; /* end insert transaction_log from demo updated */

            pas_return_code := 0;
            RETURN;

        END;

        raise exception '';
		EXCEPTION  
			WHEN  OTHERS THEN 
			GET STACKED DIAGNOSTICS error_msg = MESSAGE_TEXT;  
        RAISE EXCEPTION USING ERRCODE := var_return_error_code;
        pas_return_code := var_return_error_code;
        RETURN;
    END;

    raise exception '';
		EXCEPTION  
			WHEN  OTHERS THEN 
			GET STACKED DIAGNOSTICS error_msg = MESSAGE_TEXT;  
    pas_return_code := var_return_error_code;
    RETURN;
END; /* end the procedure */
$procedure$
;

ALTER PROCEDURE "hkpmi_patient_death_tx" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
