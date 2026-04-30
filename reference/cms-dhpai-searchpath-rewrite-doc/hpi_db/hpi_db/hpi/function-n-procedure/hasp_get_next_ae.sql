-- DROP PROCEDURE hasp_get_next_ae(inout int4, in varchar, inout varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hasp_get_next_ae(INOUT pas_return_code integer, IN par_hosp_code character varying, INOUT par_ae_no character varying, IN par_ae_no_2 character varying, IN par_adm_datetime timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/*
- get next available AE no if ae_no is null
    - validate input AE if ae_no is not null
    - Also, adjust year portion of AE no is year if neccessary
    30 Oct 97 - add century to next AE no. to cater year 2000
                by Stephen Chan
	 - Raise Error if input ae_no is not null
	   by Mabel Lau ( at 29091998)
	- add hospital code as input parm for HPI by WL
		3 Aug 1999
	-	set range for number assignement by LSCHU at 28/12/2001
*/
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_next_ae INTEGER;
    var_time timestamp without time zone;
    var_century19 INTEGER;
    var_century20 INTEGER;
    var_next_ae_char VARCHAR(08);
    var_next_ae_char_century VARCHAR(10);
    var_min_online_no INTEGER;
    var_max_online_no INTEGER;
    var_number_char VARCHAR(6);
    sql$rowcount BIGINT;
BEGIN
    <<abnormal_end>>
    BEGIN
        /* begin transaction */
        IF par_ae_no is NULL THEN
            BEGIN
                /* --- Modified by WL  3 Aug 1999 for HPI -- */
                <<retry>>
                LOOP
                    /* add min and max online number */
                    SELECT
                        next_available_ae_no, min_online_number, max_online_number, row_update_datetime
                        INTO var_next_ae, var_min_online_no, var_max_online_no, var_time
                        FROM hospital_config
                        WHERE hospital_code = par_hosp_code;

                    IF var_min_online_no IS NULL THEN
                        SELECT
                            1
                            INTO var_min_online_no;
                    END IF;

                    IF var_max_online_no IS NULL THEN
                        /* add min and max online number */
                        SELECT
                            500000
                            INTO var_max_online_no;
                    END IF;
                    SELECT
                        RIGHT(CONCAT('00000000', RTRIM((CAST (var_next_ae AS CHAR(08))))), 8)
                        INTO var_next_ae_char;
                    /* reject if max number is reached */
                    IF CAST (RIGHT(var_next_ae_char, 6) AS INTEGER) >= var_max_online_no THEN
                        BEGIN
                            RAISE EXCEPTION '% ', 'Maxium available number is used' USING ERRCODE := '20261';
                            EXIT abnormal_end;
                        END;
                    END IF;
                    SELECT
                        ABS(date_part('year', par_adm_datetime::TIMESTAMP) - CAST ((CONCAT('19', SUBSTRING(var_next_ae_char, 1, 2))) AS INTEGER))
                        INTO var_century19;
                    SELECT
                        ABS(date_part('year', par_adm_datetime::TIMESTAMP) - CAST ((CONCAT('20', SUBSTRING(var_next_ae_char, 1, 2))) AS INTEGER))
                        INTO var_century20;
                    EXIT retry;

                    IF var_century19 < var_century20 THEN
                        SELECT
                            CONCAT('19', var_next_ae_char)
                            INTO var_next_ae_char_century;
                    ELSE
                        SELECT
                            CONCAT('20', var_next_ae_char)
                            INTO var_next_ae_char_century;
                    END IF;
                    /*
                    if convert(char(02), @adm_datetime, 12) >
                    substring(convert(char(08), @next_ae), 1, 2)
                    */
                    IF to_char(par_adm_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') > SUBSTRING(var_next_ae_char_century, 1, 4) THEN
                        BEGIN
                            /*
                            if convert(int, convert(char(02), @adm_datetime, 12)) -
                            convert(int, substring(convert(char(08), @next_ae), 1, 2)) > 1
                            */
                            IF CAST (to_char(par_adm_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') AS INTEGER) - CAST (SUBSTRING(var_next_ae_char_century, 1, 4) AS INTEGER) > 1 THEN
                                BEGIN
                                    RAISE EXCEPTION '% ', 'Getting next AE no' USING ERRCODE := '20262';
                                    EXIT abnormal_end;
                                END;
                            END IF;
                            /* use min_online_no instead of 000001 */
                            SELECT
                                RIGHT(CONCAT('000000', RTRIM(CAST (var_min_online_no AS CHAR(6)))), 6)
                                INTO var_number_char;
                            /* --- Modified by WL on 3 Aug 99 for HPI --- */
                            UPDATE hospital_config
                            SET next_available_ae_no = CAST (CONCAT(to_char(par_adm_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YY'), var_number_char) AS INTEGER)
                                /* convert(int, convert(char(02), @adm_datetime, 12) + "000001") */
                                WHERE row_update_datetime = var_time AND hospital_code = par_hosp_code;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                            BEGIN
                                var_rowcount := sql$rowcount;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                            END;

                            IF var_rowcount <> 1 THEN
                                BEGIN
                                    RAISE EXCEPTION USING ERRCODE := '20016';
                                    EXIT abnormal_end;
                                END;
                            END IF;

                            IF var_error = 532 THEN /* timestamp changes */
                                CONTINUE retry;
                            END IF;

                            IF var_error <> 0 THEN
                                BEGIN
                                    EXIT abnormal_end;
                                END;
                            END IF;
                        END;
                    END IF;
                END LOOP;
                /* --- Modified by WL on 3 Aug 99 for HPI --- */
                UPDATE hospital_config
                SET next_available_ae_no = next_available_ae_no + 1
                    WHERE hospital_code = par_hosp_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
				raise notice 'hasp_get_next_ae(145)[UPDATE]hospital_config';
                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF var_rowcount <> 1 THEN
                    BEGIN
                        RAISE EXCEPTION USING ERRCODE := '20016';
                        EXIT abnormal_end;
                    END;
                END IF;

                IF var_error <> 0 THEN
                    BEGIN
                        EXIT abnormal_end;
                    END;
                END IF;
                /* --- Modified by WL on 3 Aug 99 for HPI --- */

                BEGIN
                    SELECT
                        next_available_ae_no - 1
                        INTO var_next_ae
                        FROM hospital_config
                        WHERE hospital_code = par_hosp_code;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF var_error <> 0 THEN
                    BEGIN
                        EXIT abnormal_end;
                    END;
                END IF;
                SELECT
                    RIGHT(CONCAT('00000000', RTRIM(CAST (var_next_ae AS CHAR(30)))), 8)
                    INTO par_ae_no;
            END;
        ELSE
            BEGIN
                RAISE EXCEPTION '% ', 'pass in AE no. is not null' USING ERRCODE := '20263';
                EXIT abnormal_end;
            END;
        END IF;
        /* modified by Mabel to raise error for not null ae_no */
        /*
        begin
        	  if exists(select * from Hospital where
                       Next_available_AE_no <= convert(int, @ae_no)) or
             exists(select * from Case_view where
                       Case_no = @ae_no_2)
        	  begin
             select @ae_no = ''
        	  end
          end
        */
        /* commit transaction */
        pas_return_code := 0;
        RETURN;

        <<normal_end>>
        BEGIN
        END;
    END;
    /* rollback transaction */
    pas_return_code := 99;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_next_ae" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
