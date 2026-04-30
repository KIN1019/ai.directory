CREATE OR REPLACE PROCEDURE hasp_set_move_episode_mail(INOUT pas_return_code INTEGER, IN par_hospital_code VARCHAR, IN par_last_sent_serial_number INTEGER)
AS 
$procedure$
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_serial_number INTEGER;
    sql$rowcount BIGINT;
BEGIN
    IF par_hospital_code IS NULL OR par_last_sent_serial_number IS NULL OR par_last_sent_serial_number < 0 THEN
        pas_return_code := -1;
        RETURN;
    END IF;

    BEGIN
        SELECT
            COALESCE(serial_number, 0)
            INTO var_serial_number
            FROM move_episode_notification
            WHERE hospital_code = par_hospital_code;
        var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
    END;

    IF var_error <> 0 THEN
        pas_return_code := var_error;
        RETURN;
    END IF;

    IF par_last_sent_serial_number > var_serial_number THEN
        pas_return_code := -1;
        RETURN;
    END IF;

    BEGIN
        UPDATE move_episode_notification
        SET last_sent_serial_number = par_last_sent_serial_number
            WHERE hospital_code = par_hospital_code;
        var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
    END;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
    var_rowcount := sql$rowcount;

    IF var_error <> 0 OR var_rowcount = 0 THEN
        pas_return_code := -1;
        RETURN;
    END IF;
    pas_return_code := var_rowcount;
    RETURN;
END;
$procedure$
LANGUAGE plpgsql;