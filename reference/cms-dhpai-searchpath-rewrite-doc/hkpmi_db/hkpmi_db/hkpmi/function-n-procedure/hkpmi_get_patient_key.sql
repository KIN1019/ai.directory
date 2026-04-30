-- DROP PROCEDURE hkpmi.hkpmi_get_patient_key(inout int4, inout bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_get_patient_key(INOUT pas_return_code integer, INOUT par_new_patient_key VARCHAR)
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
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_current_datetime;
        SELECT
            MAX(effective_dtm)
            INTO var_latest_effective_dtm
            FROM patient_key
            WHERE effective_dtm <= var_current_datetime;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            BEGIN
                /* --		print "no record for patient key effective datetime < today" */
                SELECT
                    100
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /*
        select	@max_patient_key = patient_key_to,
        		@next_patient_key = patient_key + 1
        	from	patient_key
        	where	effective_dtm = @latest_effective_dtm
        
        	if (@next_patient_key > @max_patient_key)
        	begin
        --		print "Patient key is reaching maximum values, fail to get next available key!"
              select   @return_error_code = 100
              select   @success_flag = "N"
              goto return_error
        	end
        */
        BEGIN
            UPDATE patient_key
            SET patient_key = patient_key + 1
                WHERE effective_dtm = var_latest_effective_dtm AND patient_key + 1 <= patient_key_to;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* --		print "Error in incrementing the patient key" */
                SELECT
                    100
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        ELSE
            BEGIN
                SELECT
                    RIGHT(CONCAT('00000000',
                    CASE CAST (patient_key AS VARCHAR(8))
                        WHEN '' THEN ' '
                        ELSE CAST (patient_key AS VARCHAR(8))
                    END), 8)
                    INTO par_new_patient_key
                    FROM patient_key
                    WHERE effective_dtm = var_latest_effective_dtm;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF (sql$rowcount = 0) THEN
                    BEGIN
                        /* --			print "Fail to get new patient key!" */
                        SELECT
                            100
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
        pas_return_code := var_return_error_code;
        RETURN;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_get_patient_key" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
