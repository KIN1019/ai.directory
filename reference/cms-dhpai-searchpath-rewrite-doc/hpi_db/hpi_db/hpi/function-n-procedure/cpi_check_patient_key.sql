-- DROP PROCEDURE hpi.cpi_check_patient_key(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in int4);

CREATE OR REPLACE PROCEDURE hpi.cpi_check_patient_key(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_transaction_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_source_system character varying, IN par_hkid character varying, IN par_cpi_patient_key character varying, IN par_host_t_prk character varying, IN par_host_access_code_int integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_rowcount INTEGER;
    var_error INTEGER;
    /* --@host_t_prk 		char(08), */
    var_host_patient_no INTEGER;
    var_return_code INTEGER;
    var_error_msg VARCHAR(255);
    var_hkid2 VARCHAR(12);
    var_cpi_access_code_int INTEGER;
    var_update_by VARCHAR(12);
    var_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_patient_key VARCHAR(08);
    var_hex INTEGER;
    var_old_access_code INTEGER;
    var_opas_access_code INTEGER;
    var_access_code INTEGER;
    sql$rowcount BIGINT;

BEGIN
    IF NOT EXISTS (SELECT
        *
        FROM cpi_patient
        WHERE hkid = par_hkid AND patient_key = par_cpi_patient_key) THEN
        BEGIN
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    SELECT
        timestamp_convert(localtimestamp)
        INTO var_system_datetime;
    /* ------------------------------------------------------ */
    /* ----A). Check for patient key between HKPMI/Local ---- */
    /* ------------------------------------------------------ */
    IF par_cpi_patient_key != par_host_t_prk THEN
        BEGIN
            SELECT
                hkid
                INTO var_hkid2
                FROM cpi_patient
                WHERE patient_key = par_host_t_prk;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            BEGIN
                var_rowcount := sql$rowcount;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;

            IF var_rowcount > 0 THEN
                BEGIN
                    SELECT
                        CONCAT('Update Unmatch T-PRK error - ', par_hkid, '''s	TPRK', par_host_t_prk, ') in HKPMI ', 'unmatched with CPI''s TPRK ', par_cpi_patient_key, ')')
                        INTO var_error_msg;
                    RAISE NOTICE '%', var_error_msg;
                    pas_return_code := - 1;
                    RETURN;
                END;
            END IF;
            SELECT
                CAST (par_host_t_prk AS INTEGER)
                INTO var_host_patient_no;
            UPDATE cpi_patient
            SET patient_key = par_host_t_prk, patient_no = var_host_patient_no, update_dtm = var_system_datetime
                WHERE patient_key = par_cpi_patient_key AND hkid = par_hkid;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            BEGIN
                var_rowcount := sql$rowcount;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;

            IF var_rowcount != 1 OR var_error != 0 THEN
                BEGIN
                    RAISE NOTICE 'update cpi_patient error';
                    pas_return_code := - 2;
                    RETURN;
                END;
            END IF;
            INSERT INTO cpi_change_patient_key (hospital_code, transaction_type, transaction_datetime, hkid, cpi_patient_key, hkpmi_patient_key, source_system, system_datetime, action_code)
            VALUES (par_hospital_code, par_transaction_type, par_transaction_datetime, par_hkid, par_cpi_patient_key, par_host_t_prk, par_source_system, var_system_datetime, NULL);
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            BEGIN
                var_rowcount := sql$rowcount;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;

            IF var_error != 0 OR var_rowcount != 1 THEN
                BEGIN
                    RAISE NOTICE 'cannot insert cpi_change_patient_key error';
                    pas_return_code := - 3;
                    RETURN;
                END;
            END IF;
        END;
    END IF;
    /* check access code */
    SELECT
        update_by, update_dtm, patient_key, access_code
        INTO var_update_by, var_update_dtm, var_patient_key, var_cpi_access_code_int
        FROM cpi_patient
        WHERE hkid = par_hkid;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount != 1 THEN
        BEGIN
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    SELECT
        timestamp_convert(localtimestamp)
        INTO var_system_datetime;
    /* * PMI is confidential in host * */
    /*
    20051014
       if @host_access_code_int & 1 = 0 and
    		@cpi_access_code_int & 1 = 1
       begin
          /* get integer which bit 0,15,16,17 is off */
          exec cpi_get_int_by_bin "NYYYYYYYYYNNNYYNNNYYYYYYYYYYYYY",
               @hex output
    
    		select @cpi_access_code_int = @cpi_access_code_int & @hex
    
          exec @return_code = cpi_patient_upd_access
                   @hospital_code,
                   @hkid,
                   @patient_key,
                   @cpi_access_code_int,
                   @system_datetime,
                   @hospital_code,
                   @update_by,
                   @update_dtm,
                   "HKPMI"
    */
    /* ------------------------------------------------------ */
    /* B). 20140902 : Check for access code between HKPMI/Local ---- */
    
    /* ------------------------------------------------------ */
    IF var_cpi_access_code_int != par_host_access_code_int THEN
        BEGIN
            SELECT
                par_host_access_code_int
                INTO var_old_access_code;
            /* set bits (19 - 26) for OPAS from downloaded access code */
            CALL cpi_get_int_by_bin(pas_return_code, 'NNNNNNNNNNNNNNNNNNNYYYYYYYYNNNN', var_hex);
            SELECT
                var_old_access_code & var_hex
                INTO var_opas_access_code;

            IF (par_host_access_code_int & 1 = 0 AND var_cpi_access_code_int & 1 = 1) OR /* ---1)PMI is confidential in host */ (var_opas_access_code <> var_hex) THEN /* --2)any one of 19-26 bit OFF  for OPAS  .... */
                BEGIN
                    /* ------ for IPAS confidential code:2147247102 -------- */
                    IF par_host_access_code_int & 1 = 0 THEN
                        /* get integer which bit 0,15,16,17 is off */
                        CALL cpi_get_int_by_bin(pas_return_code, 'NYYYYYYYYYNNNYYNNNYYYYYYYYYYYYY', var_access_code);
                    ELSE
                        /* get integer which all bit is on */
                        CALL cpi_get_int_by_bin(pas_return_code, 'YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY', var_access_code);
                    END IF;
                    /* turn off OPAS bits (19 to 26) from patient access code */
                    CALL cpi_get_int_by_bin(pas_return_code, 'YYYYYYYYYYYYYYYYYYYNNNNNNNNYYYY', var_hex);
                    SELECT
                        var_access_code & var_hex
                        INTO var_access_code;
                    /* set downloaded OPAS bits (19 to 26) to patient access code */
                    SELECT
                        var_access_code | var_opas_access_code
                        INTO var_cpi_access_code_int;
                    CALL cpi_patient_upd_access(var_return_code, par_hospital_code, par_hkid, var_patient_key, var_cpi_access_code_int, var_system_datetime, par_hospital_code, var_update_by, var_update_dtm, 'HKPMI');

                END;
            END IF
            /* ----- if @host_access_code <> @cpi_access_code and @cpi_access_code int & 1 =1 */
            ;
        END;
    END IF;
    /* ---- @cpi_access_code_int != @host_access_code_int */
    
    /*
    Do not handle @return_code != 0
    		since do not want to rollback the change patient key
    
          if (@return_code != 0)
          begin
          end
    */
    pas_return_code := 0;
    RETURN;
END; /* end of procedure */
$procedure$
;


;ALTER PROCEDURE "cpi_check_patient_key" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
