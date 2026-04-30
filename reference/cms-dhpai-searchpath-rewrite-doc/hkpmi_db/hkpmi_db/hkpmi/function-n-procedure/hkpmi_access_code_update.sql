-- DROP PROCEDURE hkpmi.hkpmi_access_code_update(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, inout varchar, in varchar, in varchar, in varchar, in timestamp, in int4, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_access_code_update(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_txn_type character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, INOUT par_patient_key character varying, IN par_hkid character varying, IN par_patient_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_access_code integer, IN par_update_flag character varying DEFAULT 'Y'::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* transaction information */
/* patient information */
/* control flag */
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
    var_old_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_upload_status VARCHAR(01);
    var_old_timestamp timestamp(6);
    /* patient information */
    var_old_patient_key VARCHAR(08);
    var_old_patient_name VARCHAR(48);
    var_old_sex VARCHAR(01);
    var_old_dob TIMESTAMP WITHOUT TIME ZONE;
    var_old_access_code INTEGER;
    sql$rowcount BIGINT;
   	error_message text;
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
           
            SELECT  'Y'
                     INTO var_begin_tran;
            SELECT
                NULL, NULL, NULL, NULL
                INTO var_old_patient_key, var_old_patient_name, var_old_sex, var_old_dob;
            /* Validate key fields */
            IF NOT ((par_source_system = 'ADT' AND par_txn_type IN ('034')) OR (par_source_system = 'DNL' AND par_txn_type IN ('034')) OR (par_source_system = 'OPAS' AND par_txn_type IN ('034')) OR (par_source_system = 'OPAS2' AND par_txn_type IN ('034')) OR (par_source_system = 'PBRC' AND par_txn_type IN ('034'))) THEN
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
                patient_key, patient_name, sex, dob, access_code, source_system_dtm, row_update_datetime
                INTO var_old_patient_key, var_old_patient_name, var_old_sex, var_old_dob, var_old_access_code, var_old_source_system_dtm, var_old_timestamp
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
                var_old_patient_key
                INTO par_patient_key;

            IF var_old_patient_name <> par_patient_name OR var_old_sex <> par_sex OR var_old_dob <> par_dob THEN
                BEGIN
                    /* Patient major keys do not match */
                    SELECT
                        200101
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            SELECT
                localtimestamp
                INTO var_system_dtm;
            /* patient match and update access code */
            IF par_update_flag = 'Y' THEN
                BEGIN
                    /* update patient when update_flay is Y */
                    IF var_old_source_system_dtm > par_source_system_dtm THEN
                        BEGIN
                            /* Patient's last_source_system_dtm is later than */
                            /* upload's source_system_dtm. */
                            SELECT
                                200013
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;

                    BEGIN
                        UPDATE patient
                        SET access_code = par_access_code, update_hospital = par_hospital_code, source_system = par_source_system, update_by = par_update_by, source_system_dtm = par_source_system_dtm, system_dtm = var_system_dtm
                            WHERE hkid = par_hkid AND row_update_datetime = var_old_timestamp;
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
                END;
            ELSE
                BEGIN
                    SELECT
                        var_old_patient_name, var_old_sex, var_old_dob, var_old_access_code
                        INTO par_patient_name, par_sex, par_dob, par_access_code;
                END;
            END IF;
            /*
            19981106 GL, select hospital from patient_patient_1 and pmi_case for
            transaction '034'
            */
            /* --	/*	insert transaction_log for access code updated */ */
            /* --	declare hosp_cursor cursor for */
            /* --		select distinct hospital_code */
            /* --			from pmi_case */
            /* --			where patient_key = @patient_key and */
            /* --					hospital_code != @hospital_code */
            /* --			for read only */
            OPEN hosp_cursor;
            FETCH hosp_cursor INTO var_tmp_hospital_code;
            select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
            SELECT
                'N', var_system_dtm
                INTO var_process_local_hospital, var_tran_system_dtm;

            WHILE (found_code = 0 OR var_process_local_hospital = 'N') LOOP
                IF var_process_local_hospital = 'N' THEN
                    begin
	                    
                        SELECT
                            par_hospital_code
                            INTO var_tran_hospital_code;
                        raise notice '175var_tran_hospital_code=%',var_tran_hospital_code;
                        /*
                        if no update, it is trigger by admission
                        and no need to upload
                        */
                        IF par_update_flag = 'Y' THEN
                            SELECT
                                'Y'
                                INTO var_upload_status;
                        ELSE
                            SELECT
                                'N'
                                INTO var_upload_status;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        /* if no update, only write download to own hospital */
                        IF par_update_flag = 'N' THEN
                            EXIT;
                        END IF;
                       	
                        SELECT
                            var_tmp_hospital_code, 'N'
                            INTO var_tran_hospital_code, var_upload_status;
						raise notice '199var_tran_hospital_code=%',var_tran_hospital_code;                           
                    END;
                END IF;

                WHILE 1 = 1 LOOP
                    begin
	                    raise notice '210var_tran_hospital_code=%',var_tran_hospital_code;   
                        INSERT INTO download.transaction_log (system_dtm, hospital_code, type, hkid, patient_key, patient_name, sex, dob, pmi_access_code, update_by, source_system, source_system_dtm, update_hospital, upload_status)
                        VALUES (var_tran_system_dtm, var_tran_hospital_code, par_txn_type, par_hkid, par_patient_key, par_patient_name, par_sex, par_dob, par_access_code, par_update_by, par_source_system, par_source_system_dtm, par_hospital_code, var_upload_status);
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS then
                            	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                            	raise notice 'error_message=%',error_message;
                                GET STACKED diagnostics var_error = RETURNED_SQLSTATE; 
                    END;
					raise notice '220var_tran_hospital_code=%',var_tran_hospital_code;   
                    IF var_error = 23505 THEN
                        BEGIN
                            SELECT
                                3 * INTERVAL '1 millisecond' + var_tran_system_dtm::TIMESTAMP
                                INTO var_tran_system_dtm;
                            CONTINUE;
                        END;
                    END IF;
					raise notice '229var_tran_hospital_code=%',var_tran_hospital_code; 
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

            IF var_begin_tran = 'Y' THEN
                BEGIN
                    /*
                    [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                    commit
                    */
                END;
            END IF;
            pas_return_code := 0;
            RETURN;

            <<normal_end>>
            BEGIN
            END;
        END;

        IF var_begin_tran = 'Y' THEN
            BEGIN
                --ROLLBACK;
                RAISE EXCEPTION '';
            END;
        END IF;
--        RAISE EXCEPTION USING ERRCODE := var_return_error_code;
        pas_return_code := var_return_error_code;
        RETURN;
    END;

    IF var_begin_tran = 'Y' THEN
        BEGIN
            --ROLLBACK;
            RAISE EXCEPTION '';
        END;
    END IF;
    pas_return_code := var_return_error_code;
    RETURN;
END; /* end the procedure */
$procedure$
;


ALTER PROCEDURE "hkpmi_access_code_update" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";