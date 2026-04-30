-- DROP PROCEDURE hkpmi.hkpmi_update_new_born(inout int4, in bpchar, in bpchar, in timestamp, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in int4, in int4, in bpchar, in bpchar, in bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_update_new_born(INOUT pas_return_code integer, IN par_hospital_code varchar, IN par_txn_type varchar,
 IN par_source_system_dtm timestamp without time zone, IN par_update_by varchar, IN par_source_system varchar, IN par_mother_hkid varchar, IN par_mother_patient_key varchar,
  IN par_mother_case_no varchar, IN par_birth_order integer, IN par_pregnancy_number integer, IN par_new_born_patient_key varchar, IN par_new_born_hkid varchar, IN par_old_patient_key varchar DEFAULT NULL::varchar)
 LANGUAGE plpgsql
AS $procedure$
/* transaction information */
/* new born details */
DECLARE
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* transaction details */
    var_create_by varchar(12);
    var_create_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_tran_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_begin_tran varchar(01);
    var_upload_status varchar(01);
    var_return_error_code INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    sql$rowcount BIGINT;
	my_conn varchar;
	error_sqlstate BIGINT;
BEGIN
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN

			select 'Y' into var_begin_tran;
            SELECT
                timestamp_convert(localtimestamp)
                INTO var_system_dtm; /* get system datetime for the whole program */

            IF par_txn_type = '260' THEN
                BEGIN
                    SELECT
                        par_update_by, par_source_system_dtm
                        INTO var_create_by, var_create_datetime;
                    SELECT
                        timestamp_convert(par_source_system_dtm)
                        INTO var_update_datetime;

                    IF NOT EXISTS (SELECT
                        *
                        FROM new_born
                        WHERE mother_patient_key = par_mother_patient_key AND new_born_patient_key = par_new_born_patient_key AND hospital_code = par_hospital_code) THEN
                        BEGIN
                            BEGIN
                                INSERT INTO new_born (mother_patient_key, new_born_patient_key, hospital_code, mother_case_no, birth_order, pregnancy_number, create_by, create_datetime, update_by, update_datetime)
                                VALUES (par_mother_patient_key, par_new_born_patient_key, par_hospital_code, par_mother_case_no, par_birth_order, par_pregnancy_number, var_create_by, var_create_datetime, par_update_by, var_update_datetime);
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
                                    /* Insert new_born fail" */
                                    SELECT
                                        200166
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;

            IF par_txn_type = '261' THEN
                BEGIN
                    SELECT
                        par_update_by, par_source_system_dtm
                        INTO par_update_by, var_update_datetime;
                    SELECT
                        NULL, NULL
                        INTO var_create_by, var_create_datetime;

                    IF par_old_patient_key IS NULL THEN
                        BEGIN
                            IF EXISTS (SELECT
                                *
                                FROM new_born
                                WHERE new_born_patient_key = par_new_born_patient_key AND hospital_code = par_hospital_code) THEN
                                BEGIN
                                    BEGIN
                                        UPDATE new_born
                                        SET mother_patient_key = par_mother_patient_key, mother_case_no = par_mother_case_no, birth_order = par_birth_order, pregnancy_number = par_pregnancy_number, update_by = par_update_by, update_datetime = var_update_datetime
                                            WHERE new_born_patient_key = par_new_born_patient_key AND hospital_code = par_hospital_code;
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
                                            /* Update new_born fail" */
                                            SELECT
                                                200166
                                                INTO var_return_error_code;
                                            EXIT return_error;
                                        END;
                                    END IF;
                                END;
                            END IF;
                        END;
                    ELSE
                        BEGIN
                            IF EXISTS (SELECT
                                *
                                FROM new_born
                                WHERE new_born_patient_key = par_old_patient_key AND hospital_code = par_hospital_code) THEN
                                BEGIN
                                    BEGIN
                                        UPDATE new_born
                                        SET new_born_patient_key = par_new_born_patient_key
                                            WHERE new_born_patient_key = par_old_patient_key;
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
                                            /* Update new_born fail" */
                                            SELECT
                                                200166
                                                INTO var_return_error_code;
                                            EXIT return_error;
                                        END;
                                    END IF;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;

            IF par_txn_type = '262' THEN
                BEGIN
                    IF EXISTS (SELECT
                        *
                        FROM new_born
                        WHERE mother_patient_key = par_mother_patient_key AND new_born_patient_key = par_new_born_patient_key AND hospital_code = par_hospital_code) THEN
                        BEGIN
                            BEGIN
                                DELETE FROM new_born
                                    WHERE mother_patient_key = par_mother_patient_key AND new_born_patient_key = par_new_born_patient_key AND hospital_code = par_hospital_code;
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
                                    /* Delete new_born fail" */
                                    SELECT
                                        200166
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
            SELECT
                var_system_dtm
                INTO var_tran_system_dtm;
            /* insert transaction_log for admission */
            SELECT
                var_system_dtm
                INTO var_tran_system_dtm;

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
				INSERT INTO download.transaction_log (system_dtm, hospital_code, type, hkid, patient_key, case_no, case_access_code, pmi_access_code, old_patient_key, old_hkid, update_by, update_hospital, source_system, source_system_dtm, upload_status)
                    VALUES (var_tran_system_dtm, par_hospital_code, par_txn_type, par_mother_hkid, par_mother_patient_key, par_mother_case_no, par_pregnancy_number, par_birth_order, par_new_born_patient_key, par_new_born_hkid, par_update_by, par_hospital_code, par_source_system, par_source_system_dtm, var_upload_status);

                EXCEPTION  
					WHEN unique_violation OR OTHERS THEN  
						
						GET STACKED DIAGNOSTICS
												error_sqlstate = RETURNED_SQLSTATE;  
				
						 
						IF error_sqlstate = '23505' THEN  
							select  var_tran_system_dtm + INTERVAL '3 milliseconds' into var_tran_system_dtm;  
							CONTINUE;
							
						ELSE  
							select  error_sqlstate into var_return_error_code;
							EXIT return_system_error;
						END IF;

                
               end;
              EXIT;
            END LOOP; /* end insert transaction_log from admission */


            pas_return_code := 0;
			return;

        END;

        raise exception '';
		EXCEPTION  
			WHEN  OTHERS THEN 
        RAISE EXCEPTION USING ERRCODE := var_return_error_code;
        pas_return_code := var_return_error_code;
        RETURN;
    END;

    raise exception '';
		EXCEPTION  
			WHEN  OTHERS THEN 
    pas_return_code := var_return_error_code;
    RETURN;
END; /* end the procedure */
$procedure$
;


ALTER PROCEDURE "hkpmi_update_new_born" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
