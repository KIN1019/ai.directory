-- DROP PROCEDURE hkpmi.hkpmi_set_off_patient_hosp(inout int4, in bpchar, in bpchar, in bpchar, in bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_set_off_patient_hosp(INOUT pas_return_code integer, IN par_hkid varchar, IN par_hospital_code varchar, IN par_update_by varchar, 
IN par_source_system varchar)
 LANGUAGE plpgsql
AS $procedure$
/* 19981105 - add timestamp checking by Stephen */
DECLARE
    var_byte_value_1 INTEGER;
    var_byte_value_2 INTEGER;
    var_byte_value_3 INTEGER;
    var_return_error_code INTEGER;
    var_hosp_byte_1 INTEGER;
    var_hosp_byte_2 INTEGER;
    var_hosp_byte_3 INTEGER;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_patient_key VARCHAR(8);
    var_begin_tran VARCHAR(1);
    var_patient_exist INTEGER;
    var_update VARCHAR(1);
    var_timestamp timestamp ;
    sql$rowcount BIGINT;
BEGIN
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN
            <<normal_return>>
            BEGIN
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
                /* check permition for update */
				select 'Y' into var_begin_tran;
                IF NOT EXISTS (SELECT
                    *
                    FROM system_permit
                    WHERE source_system = par_source_system AND func_name = 'hkpmi_set_off_patient_hosp') THEN
                    BEGIN
                        SELECT
                            200157
                            INTO var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;
                /* check patient */
                SELECT
                    patient_key
                    INTO var_patient_key
                    FROM patient
                    WHERE hkid = par_hkid;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount != 1 THEN
                    BEGIN
                        SELECT
                            200012
                            INTO var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;
                /* get hospital byte and its value */
                SELECT
                    byte_value_1, byte_value_2, byte_value_3
                    INTO var_byte_value_1, var_byte_value_2, var_byte_value_3
                    FROM hospital
                    WHERE hospital_code = par_hospital_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount != 1 THEN
                    BEGIN
                        SELECT
                            200156
                            INTO var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;
                /* get hospital byte value from patient detail */
                SELECT
                    hosp_byte_1, hosp_byte_2, hosp_byte_3, row_update_datetime
                    INTO var_hosp_byte_1, var_hosp_byte_2, var_hosp_byte_3, var_timestamp
                    FROM patient_detail_1
                    WHERE patient_key = var_patient_key;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount != 1 THEN
                    BEGIN
                        /* print 'no record, %1! is off', @hospital_code */
                        EXIT normal_return;
                    END;
                END IF;

                IF var_hosp_byte_1 & var_byte_value_1 > 0 OR var_hosp_byte_2 & var_byte_value_2 > 0 OR var_hosp_byte_3 & var_byte_value_3 > 0 THEN
                    BEGIN
                        SELECT
                            var_hosp_byte_1 - var_byte_value_1, var_hosp_byte_2 - var_byte_value_2, var_hosp_byte_3 - var_byte_value_3, 'Y'
                            INTO var_hosp_byte_1, var_hosp_byte_2, var_hosp_byte_3, var_update;
                    END;
                ELSE
                    SELECT
                        'N'
                        INTO var_update;
                END IF;

                IF var_update = 'Y' THEN
                    BEGIN
                        BEGIN
                            UPDATE patient_detail_1
                            SET hosp_byte_1 = var_hosp_byte_1, hosp_byte_2 = var_hosp_byte_2, hosp_byte_3 = var_hosp_byte_3, update_by = par_update_by, update_hospital = par_hospital_code, source_system = par_source_system, system_dtm = timestamp_convert(localtimestamp)
                                WHERE patient_key = var_patient_key AND row_update_datetime = var_timestamp;
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
                                /* Patient details has been updated between retrieved & update. */
                                SELECT
                                    200155
                                    INTO var_return_error_code;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
                /* else */
                /* print 'record exists, %1! is off', @hospital_code */
            END;

            pas_return_code := 0;
            RETURN;
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
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_set_off_patient_hosp" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
