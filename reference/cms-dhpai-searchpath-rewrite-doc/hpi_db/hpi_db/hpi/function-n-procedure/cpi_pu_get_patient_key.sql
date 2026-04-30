-- DROP PROCEDURE hpi.cpi_pu_get_patient_key(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_pu_get_patient_key(INOUT pas_return_code integer, IN par_hospital_code character varying, INOUT par_new_patient_key character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_max_patient_key INTEGER;
    var_next_patient_key INTEGER;
    var_latest_effective_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_current_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_return_error_code INTEGER;
    var_success_flag VARCHAR(01);
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        /*
        if @@trancount = 0
           begin
              select   @return_error_code = 20000
              select   @success_flag = "N"
              goto return_error
           end
        */
        /*
        save transaction cpi_pu_get_patient_key
        */
	-- SAVEPOINT cpi_pu_get_patient_key;
	   
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_current_datetime;
       
        SELECT
            MAX(effective_dtm)
            INTO var_latest_effective_dtm
            FROM cpi_patient_key
            WHERE hospital_code = par_hospital_code AND effective_dtm <= var_current_datetime;
      
        SELECT
            patient_key_to, patient_key + 1
            INTO var_max_patient_key, var_next_patient_key
            FROM cpi_patient_key
            WHERE hospital_code = par_hospital_code AND effective_dtm = var_latest_effective_dtm;

        IF (var_next_patient_key > var_max_patient_key) THEN
            BEGIN
                /* --		print "Patient key is reaching maximum values, fail to get next available key!" */
                SELECT
                    100
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* --	save transaction get_patient_key */
        BEGIN
            UPDATE cpi_patient_key
            SET patient_key = patient_key + 1
                WHERE hospital_code = par_hospital_code AND effective_dtm = var_latest_effective_dtm;
            raise notice 'cpi_pu_get_patient_key-cpi_discharge(63)[UPDATE]cpi_patient_key,par_hospital_code=%,effective_dtm=%',par_hospital_code,var_latest_effective_dtm;
            var_error := 0;
            /*EXCEPTION
                WHEN OTHERS then
                    raise notice 'err_msg=>%',sqlerrm;
                    var_error := 1;*/
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;
      

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* --		print "Error in incrementing the patient key" */
                SELECT
                    101
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        ELSE
            BEGIN
                SELECT
                    CAST (patient_key AS VARCHAR(8))
                    INTO par_new_patient_key
                    FROM cpi_patient_key
                    WHERE hospital_code = par_hospital_code AND effective_dtm = var_latest_effective_dtm;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF (sql$rowcount = 0) THEN
                    BEGIN
                        /* --			print "Fail to get new patient key!" */
                        SELECT
                            102
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

    IF (var_success_flag = 'N') THEN
        BEGIN
            /*
            rollback cpi_pu_get_patient_key
            */
	    -- ROLLBACK TO SAVEPOINT cpi_pu_get_patient_key;
		/*ROLLBACK;*/
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

;ALTER PROCEDURE "cpi_pu_get_patient_key" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
