-- DROP PROCEDURE hasp_set_user_password(inout int4, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hasp_set_user_password(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_user_id character varying, IN par_password character varying, IN par_password_expiration_date timestamp without time zone, IN par_last_updated_by character varying, IN par_last_update_status character varying, IN par_upper_password character varying, IN par_event_type character varying, INOUT par_return_code integer, INOUT par_return_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_update_datetime        TIMESTAMP WITHOUT TIME ZONE;
    var_begin_tran             VARCHAR(1);
    var_rowcount               INTEGER;
    var_error_msg              VARCHAR(255);
    var_error_code             INTEGER;
    var_last_update_status_ret VARCHAR(50);
    sql$rowcount               BIGINT;

BEGIN
    IF (SELECT COUNT(1)
        FROM
            User_profile
        WHERE Hospital_code = par_hospital_code AND User_ID = par_user_id) < 1
    THEN
        BEGIN
            par_return_code := -1;
            pas_return_code := -1;
            var_error_msg := 'User Id does not exist!!';
            RAISE EXCEPTION 'User Id does not exist!!';
        END;
    END IF;

    SELECT last_update_status
    INTO var_last_update_status_ret
    FROM
        User_password
    WHERE
          update_datetime = (SELECT MAX(update_datetime)
                             FROM
                                 User_password
                             WHERE hospital_code = par_hospital_code AND user_id = par_user_id)
      AND user_id = par_user_id AND hospital_code = par_hospital_code;

    IF (SELECT COUNT(1)
        FROM
            User_password
        WHERE
            hospital_code = par_hospital_code AND user_id = par_user_id AND password = par_password
                                              AND var_last_update_status_ret <> 'FORCE_UPDATE') > 0
    THEN
        BEGIN
            par_return_code := -1;
            pas_return_code := -1;
            SELECT 'Same password is not re-usable for recent 5 times.'
            INTO var_error_msg;
            RAISE EXCEPTION 'Same password is not re-usable for recent 5 times.';
        END;
    END IF;

    IF (SELECT COUNT(1)
        FROM
            User_password
        WHERE hospital_code = par_hospital_code AND user_id = par_user_id) < 5
    THEN
        BEGIN
            BEGIN
                INSERT INTO User_password (hospital_code,user_id,password,update_datetime,last_updated_by,
                                           last_update_status)
                VALUES (par_hospital_code,par_user_id,par_password,timestamp_convert(LOCALTIMESTAMP),
                        par_last_updated_by,par_last_update_status);
                var_error_code := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error_code := 1;
            END;

            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF var_error_code <> 0 OR var_rowcount <> 1
            THEN
                BEGIN
                    par_return_code := -1;
                    pas_return_code := -1;
                    SELECT 'Fail to insert User_password!'
                    INTO var_error_msg;
                    RAISE EXCEPTION 'Fail to insert User_password!';
                END;
            END IF;
        END;
    ELSE
        BEGIN
            SELECT MIN(update_datetime)
            INTO var_update_datetime
            FROM
                User_password
            WHERE user_id = par_user_id;

            BEGIN
                UPDATE User_password
                SET password           = par_password,
                    update_datetime    = timestamp_convert(LOCALTIMESTAMP),
                    last_updated_by    = par_last_updated_by,
                    last_update_status = par_last_update_status
                WHERE user_id = par_user_id AND update_datetime = var_update_datetime;
                var_error_code := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error_code := 1;
            END;

            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF var_error_code <> 0 OR var_rowcount <> 1
            THEN
                BEGIN
                    par_return_code := -1;
                    pas_return_code := -1;
                    SELECT 'Fail to update User_password!'
                    INTO var_error_msg;
                    RAISE EXCEPTION 'Fail to update User_password!';
                END;
            END IF;
        END;
    END IF;

    IF par_event_type = 'UPDATE'
    THEN
        BEGIN
            IF par_password_expiration_date = NULL
            THEN
                BEGIN
                    UPDATE User_profile
                    SET encrypted_pswd       = par_password,
                        Password             = par_upper_password,
                        Password_retry_count = 0
                    WHERE Hospital_code = par_hospital_code AND User_ID = par_user_id;
                END;
            ELSE
                BEGIN
                    UPDATE User_profile
                    SET Password_expiration_date = par_password_expiration_date,
                        encrypted_pswd           = par_password,
                        Password                 = par_upper_password,
                        Password_retry_count     = 0
                    WHERE Hospital_code = par_hospital_code AND User_ID = par_user_id;
                END;
            END IF;
        END;
    END IF;

    SELECT NULL
    INTO par_return_message;
    SELECT 0
    INTO par_return_code;

    pas_return_code := 0;
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            par_return_code := -1;
            pas_return_code := -1;
            par_return_message = var_error_msg;
        END;
END ;

$procedure$
;

;ALTER PROCEDURE "hasp_set_user_password" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
