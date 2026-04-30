-- DROP PROCEDURE hasp_get_next_hn(inout int4, in varchar, inout varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hasp_get_next_hn(INOUT pas_return_code integer, IN par_hosp_code character varying, INOUT par_hn_no character varying, IN par_hn_no_2 character varying, IN par_adm_datetime timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/*
- get next available HN no if hn_no is null
    - validate input HN no if hn_no is not null
    - Also, adjust year portion of HN no is year if neccessary
	 30 Oct 97 - add century to next hn no. to cater year 2000
					 by Stephen Chan
	 - raise error if hn_no is not null by Mabel Lau ( at 29091998)
	 - put hosp code as input parm by 3 Aug 99
	-	set range for number assignement by LSCHU at 28/12/2001
*/
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_next_hn INTEGER;
    var_time timestamp without time zone;
    var_century19 INTEGER;
    var_century20 INTEGER;
    var_next_hn_char VARCHAR(08);
    var_next_hn_char_century VARCHAR(10);
    var_min_online_no INTEGER;
    var_max_online_no INTEGER;
    var_number_char VARCHAR(6);
    sql$rowcount BIGINT;
BEGIN
    <<abnormal_end>>
    BEGIN
        /* begin transaction */
        IF par_hn_no is NULL THEN
            BEGIN
                /* --- Modified by WL on 3 Aug 99 for HPI -- */
                <<retry>>
                LOOP
                    /* add min and max online number */
                    SELECT
                        Next_available_HN_no, Min_online_number, Max_online_number, row_update_datetime
                        INTO var_next_hn, var_min_online_no, var_max_online_no, var_time
                        FROM hospital_config
                        WHERE Hospital_code = par_hosp_code;

                    IF var_min_online_no IS NULL THEN
                        SELECT
                            1
                            INTO var_min_online_no;
                    END IF;

                    IF var_max_online_no IS NULL THEN
                        SELECT
                            500000
                            INTO var_max_online_no;
                    END IF;
                    /* add min and max online number */
                    SELECT
                        RIGHT(CONCAT('00000000', RTRIM((CAST (var_next_hn AS CHAR(08))))), 8)
                        INTO var_next_hn_char;
                    /* reject if max number is reached */
                    IF CAST (RIGHT(var_next_hn_char, 6) AS INTEGER) >= var_max_online_no THEN
                        BEGIN
                            RAISE EXCEPTION '% ', 'Maxium available number is used' USING ERRCODE := '20026';
                            EXIT abnormal_end;
                        END;
                    END IF;
                    SELECT
                        ABS(date_part('year', par_adm_datetime::TIMESTAMP) - CAST ((CONCAT('19', SUBSTRING(var_next_hn_char, 1, 2))) AS INTEGER))
                        INTO var_century19;
                    EXIT retry;
                    SELECT
                        ABS(date_part('year', par_adm_datetime::TIMESTAMP) - CAST ((CONCAT('20', SUBSTRING(var_next_hn_char, 1, 2))) AS INTEGER))
                        INTO var_century20;

                    IF var_century19 < var_century20 THEN
                        SELECT
                            CONCAT('19', var_next_hn_char)
                            INTO var_next_hn_char_century;
                    ELSE
                        SELECT
                            CONCAT('20', var_next_hn_char)
                            INTO var_next_hn_char_century;
                    END IF;
                    /*
                    if convert(char(02), @adm_datetime, 12) >
                    substring(convert(char(08), @next_hn), 1, 2)
                    */
                    IF to_char(par_adm_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') > SUBSTRING(var_next_hn_char_century, 1, 4) THEN
                        BEGIN
                            /*
                            if convert(int, convert(char(02), @adm_datetime, 12)) -
                            convert(int, substring(convert(char(08), @next_hn), 1, 2)) > 1
                            */
                            IF CAST (to_char(par_adm_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') AS INTEGER) - CAST (SUBSTRING(var_next_hn_char_century, 1, 4) AS INTEGER) > 1 THEN
                                BEGIN
                                    RAISE EXCEPTION '% ', 'Getting next HN no' USING ERRCODE := '20026';
                                    EXIT abnormal_end;
                                END;
                            END IF;
                            /* use min_online_no instead of 000001 */
                            SELECT
                                RIGHT(CONCAT('000000', RTRIM(CAST (var_min_online_no AS CHAR(6)))), 6)
                                INTO var_number_char;
                            /* --- Modified by WL on 3 Aug 99 for HPI --- */
                            UPDATE hospital_config
                            SET Next_available_HN_no = CAST (CONCAT(to_char(par_adm_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YY'), var_number_char) AS INTEGER)
                                /* --					+ "000001") */
                                WHERE row_update_datetime = var_time AND Hospital_code = par_hosp_code;
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
                /* --- Modified by WL on 3 Aug 99 for HPI--- */
                UPDATE hospital_config
                SET Next_available_HN_no = Next_available_HN_no + 1
                    WHERE Hospital_code = par_hosp_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
				raise notice 'hasp_get_next_hn(143)[UPDATE]hospital_config';
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
                /* -- Modified by WL on 3 Aug 99 for HPI --- */

                BEGIN
                    SELECT
                        Next_available_HN_no - 1
                        INTO var_next_hn
                        FROM hospital_config
                        WHERE Hospital_code = par_hosp_code;
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
                    RIGHT(CONCAT('00000000', RTRIM(CAST (var_next_hn AS CHAR(30)))), 8)
                    INTO par_hn_no;
            END;
        ELSE
            BEGIN
                RAISE EXCEPTION '% ', 'pass in HN no. is not null' USING ERRCODE := '20026';
                EXIT abnormal_end;
            END;
        END IF;
        /* modifed by Mabel to raise error if input hn no is not null */
        /*
        begin
              if exists(select * from Hospital where
                        Next_available_HN_no <= convert(int, @hn_no)) or
                 exists(select * from Case_view where
                        Case_no = @hn_no_2)
              begin
                 select @hn_no = ''
              end
        end
        */
        pas_return_code := 0;
        RETURN;

        <<normal_end>>
        BEGIN
        END;
    END;
    pas_return_code := 99;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_next_hn" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
