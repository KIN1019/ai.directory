-- DROP PROCEDURE hkpmi.hkpmi_hago_minor_preact_check(inout int4, in bpchar, inout int4, inout bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_hago_minor_preact_check(INOUT pas_return_code integer, IN par_minor_hkid varchar, INOUT par_code integer, INOUT par_status varchar)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_baby_dob TIMESTAMP WITHOUT TIME ZONE;
    var_valid_flag VARCHAR(1);
    "var_yrDiff" INTEGER;
    "var_monDiff" INTEGER;
    var_txn_type VARCHAR(6);
    var_return_code int;
    sql$rowcount BIGINT;
BEGIN
    <<return_result>>
    BEGIN
        SELECT
            0, 'OK'
            INTO par_code, par_status;
        /* Minor HKID validation */
        SELECT
            RIGHT(CONCAT(REPEAT(' ', 9), RTRIM(par_minor_hkid)), 9)
            INTO par_minor_hkid;

        IF SUBSTRING(par_minor_hkid, 1, 1) = 'U' THEN
            BEGIN
                SELECT
                    2921, 'Invalid Minor HKID'
                    INTO par_code, par_status;
                EXIT return_result;
            END;
        END IF;
        CALL cpi_pq_validate_hkid(var_return_code, par_minor_hkid, var_valid_flag);

        IF var_valid_flag = 'N' THEN
            BEGIN
                SELECT
                    2921, 'Invalid Minor HKID'
                    INTO par_code, par_status;
                EXIT return_result;
            END;
        END IF;
        /* Check Minor HKD in HKPMI */
        SELECT
            dob
            INTO var_baby_dob
            FROM patient
            WHERE hkid = par_minor_hkid;

        
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            IF (sql$rowcount = 0)THEN
				 BEGIN
                    SELECT
                        txn_type
                        INTO var_txn_type
                        FROM hkpmi_pin_change_log
                        WHERE old_hkid = par_minor_hkid;

                    IF var_txn_type = '020' THEN
                        SELECT
                            2930, 'Minor HKID Merged'
                            INTO par_code, par_status;
                    ELSE
                        IF var_txn_type = '031' THEN
                            SELECT
                                2931, 'Minor HKID Changed'
                                INTO par_code, par_status;
                        ELSE
                            SELECT
                                2923, 'Minor HKID Not Found'
                                INTO par_code, par_status;
                        END IF;
                    END IF;
                    EXIT return_result;
                END;
			END IF;
        /* minor DOB checking */
        SELECT
            date_part('year', timestamp_convert(localtimestamp)::TIMESTAMP) - date_part('year', var_baby_dob::TIMESTAMP)
            INTO "var_yrDiff";
        SELECT
            date_part('month', timestamp_convert(localtimestamp)::TIMESTAMP) - date_part('month', var_baby_dob::TIMESTAMP)
            INTO "var_monDiff";

        IF date_part('day', timestamp_convert(localtimestamp)::DATE) - date_part('day', var_baby_dob::DATE) < 0 THEN
            SELECT
                "var_monDiff" - 1
                INTO "var_monDiff";
        END IF;

        IF "var_monDiff" < 0 THEN
            SELECT
                "var_yrDiff" - 1
                INTO "var_yrDiff";
        END IF;
        /* Mar-2022/Max/Extend minor registration to age 16-18 */
        
        /* --if @baby_dob = null or @yrDiff >= 16 */
        IF var_baby_dob IS NULL OR "var_yrDiff" >= 18 THEN
            BEGIN
                SELECT
                    2925, 'Ineligible Age'
                    INTO par_code, par_status;
                EXIT return_result;
            END;
        END IF;
        /* minor DOB checking */
        /* execute activation check SP */
        CALL hkpmi_hago_activation_check(var_return_code, par_minor_hkid, par_code, par_status);

        IF par_code <> 0 THEN
            BEGIN
                IF par_code = 2904 THEN
                    SELECT
                        2929, 'Minor Episode Moved'
                        INTO par_code, par_status;
                ELSE
                    IF par_code = 2906 THEN
                        SELECT
                            2928, 'Minor - Dead Patient'
                            INTO par_code, par_status;
                    END IF;
                END IF;
                EXIT return_result;
            END;
        END IF;
    END;
    pas_return_code := par_code;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_hago_minor_preact_check" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

