CREATE OR REPLACE PROCEDURE hasp_get_preprint_un(INOUT pas_return_code int, IN par_amount INTEGER, INOUT par_unhkid VARCHAR)
AS 
$BODY$
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_time TIMESTAMP WITHOUT TIME ZONE;
    var_next_hkid VARCHAR(12);
    var_max_hkid VARCHAR(12);
    sql$rowcount BIGINT;
BEGIN
    <<abnormal_end>>
    BEGIN
        SELECT
            un_next_hkid, un_max_hkid
            INTO var_next_hkid, var_max_hkid
            FROM hospital_config;

        IF (CAST (var_next_hkid AS INTEGER) + par_amount > CAST (var_max_hkid AS INTEGER)) THEN
            BEGIN
                pas_return_code := 99;
                RAISE EXCEPTION USING ERRCODE := '200027';
            END;
        END IF;

        BEGIN
            SELECT
                CONCAT(un_hkid_prefix, un_next_hkid)
                INTO par_unhkid
                FROM hospital_config;
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

        BEGIN
            UPDATE hospital_config
            SET un_next_hkid = RIGHT(CONCAT('00000',
            CASE CAST (CAST (un_next_hkid AS INTEGER) + par_amount AS VARCHAR(12))
                WHEN '' THEN ' '
                ELSE CAST (CAST (un_next_hkid AS INTEGER) + par_amount AS VARCHAR(12))
            END), 6);
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            var_rowcount := sql$rowcount;
            var_error := 0;
            IF var_rowcount <> 1 THEN
                BEGIN
                    RAISE EXCEPTION '';
                END;
            END IF;
        EXCEPTION
                WHEN OTHERS THEN
                    BEGIN
                        pas_return_code := 99;
                        var_error := 1;
                        RAISE EXCEPTION USING ERRCODE := '200016';
                    END;
        END;
        <<normal_end>>
        BEGIN
            pas_return_code := 0;
            RETURN;
        END;
    END;
END;
$BODY$
LANGUAGE plpgsql;