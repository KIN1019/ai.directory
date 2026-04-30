CREATE OR REPLACE PROCEDURE pass_ipas_user_management(INOUT pas_return_code int, IN par_hospital_code VARCHAR, IN par_user_id VARCHAR, IN par_authority_code INTEGER, IN par_department VARCHAR, IN par_dt_effective_date TIMESTAMP WITHOUT TIME ZONE DEFAULT null, IN par_dt_enable_flag VARCHAR DEFAULT null, IN par_dt_expiration_date TIMESTAMP WITHOUT TIME ZONE DEFAULT null, IN par_dt_security_code INTEGER DEFAULT null, IN par_effective_date TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL, IN par_expiration_date TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL, IN par_group_id VARCHAR DEFAULT NULL, IN par_hkid VARCHAR DEFAULT NULL, IN par_menu VARCHAR DEFAULT null, IN par_name VARCHAR DEFAULT NULL, IN par_password VARCHAR DEFAULT NULL, IN par_password_expiration_date TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL, IN par_password_retry_count INTEGER DEFAULT null, IN par_rank_code VARCHAR DEFAULT NULL, IN par_user_title VARCHAR DEFAULT null, IN par_email VARCHAR DEFAULT NULL, IN par_encrypted_pswd VARCHAR DEFAULT NULL, IN par_updated_by VARCHAR DEFAULT NULL, IN par_last_update_status VARCHAR DEFAULT NULL, IN par_event_type VARCHAR DEFAULT NULL, INOUT par_return_code INTEGER DEFAULT NULL, INOUT par_return_msg VARCHAR DEFAULT NULL, IN par_masked_hkid VARCHAR DEFAULT NULL, IN par_input_message_1 VARCHAR DEFAULT NULL, IN par_input_message_2 VARCHAR DEFAULT NULL, IN par_action_type VARCHAR DEFAULT NULL, IN par_update_project VARCHAR DEFAULT NULL, IN par_cuid_flag VARCHAR DEFAULT null)
AS 
$BODY$
/* --insertIpasUserProfile */
/* --createNewUserPasswordRecord */
/* --insertIpasUserManagementLog */
DECLARE
    /* --@cuid_flag VARCHAR(1), */
    var_new_password_control_flag VARCHAR(2);
    var_begin_tran VARCHAR(2);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_create_account_action VARCHAR(50);
    var_update_expiry_action VARCHAR(50);
    sql$rowcount BIGINT;
    var_return_code int;
    p_refcur refcursor;
    var_success VARCHAR(2);
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            0
            INTO par_return_code;
        SELECT
            'createIPASAccount'
            INTO var_create_account_action;
        SELECT
            'updateIPASAccountExpiryDate'
            INTO var_update_expiry_action;
        /* --select @cuid_flag = Text_value from Hospital_control where [Type] = 'cuid_enable' */
        SELECT
            'N'
            INTO var_begin_tran;
        IF par_user_id IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO par_return_code;
                SELECT
                    'user_id cannot be null'
                    INTO par_return_msg;
                EXIT return_error;
            END;
        END IF;

        IF par_hospital_code IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO par_return_code;
                SELECT
                    'hospital_code cannot be null'
                    INTO par_return_msg;
                EXIT return_error;
            END;
        END IF;

        IF par_updated_by IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO par_return_code;
                SELECT
                    'updated_by cannot be null'
                    INTO par_return_msg;
                EXIT return_error;
            END;
        END IF;

        IF par_action_type IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO par_return_code;
                SELECT
                    'action_type cannot be null'
                    INTO par_return_msg;
                EXIT return_error;
            END;
        END IF;

        IF par_update_project IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO par_return_code;
                SELECT
                    'update_project cannot be null'
                    INTO par_return_msg;
                EXIT return_error;
            END;
        END IF;
        /* -------------- */
        IF par_action_type = var_create_account_action THEN
            BEGIN
                IF par_group_id IS NULL THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO par_return_code;
                        SELECT
                            'group_id cannot be null'
                            INTO par_return_msg;
                        EXIT return_error;
                    END;
                END IF;

                IF par_password IS NULL THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO par_return_code;
                        SELECT
                            'password cannot be null'
                            INTO par_return_msg;
                        EXIT return_error;
                    END;
                END IF;

                IF par_name IS NULL THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO par_return_code;
                        SELECT
                            'name cannot be null'
                            INTO par_return_msg;
                        EXIT return_error;
                    END;
                END IF;

                IF par_authority_code IS NULL THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO par_return_code;
                        SELECT
                            'authority_code cannot be null'
                            INTO par_return_msg;
                        EXIT return_error;
                    END;
                END IF;

                IF par_effective_date IS NULL THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO par_return_code;
                        SELECT
                            'effective_date cannot be null'
                            INTO par_return_msg;
                        EXIT return_error;
                    END;
                END IF;

                IF par_rank_code IS NULL THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO par_return_code;
                        SELECT
                            'rank_code cannot be null'
                            INTO par_return_msg;
                        EXIT return_error;
                    END;
                END IF;
                SELECT
                    Text_value
                    INTO var_new_password_control_flag
                    FROM Hospital_control
                    WHERE Type = 'enable_user_password_control';

                IF var_new_password_control_flag = 'Y' THEN
                    BEGIN
                        IF par_encrypted_pswd IS NULL THEN
                            BEGIN
                                SELECT
                                    - 1
                                    INTO par_return_code;
                                SELECT
                                    'encrypted_pswd cannot be null'
                                    INTO par_return_msg;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;

                IF EXISTS (SELECT
                    1
                    FROM User_profile
                    WHERE Hospital_code = par_hospital_code AND User_ID = par_user_id) THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO par_return_code;
                        SELECT
                            CONCAT('User Id already exist!! ', par_user_id)
                            INTO par_return_msg;
                        EXIT return_error;
                    END;
                END IF;

                IF par_expiration_date < par_effective_date THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO par_return_code;
                        SELECT
                            'expirationDate cannot be earlier than effectiveDate'
                            INTO par_return_msg;
                        EXIT return_error;
                    END;
                END IF;

                IF par_effective_date < timestamp_convert(localtimestamp)::DATE THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO par_return_code;
                        SELECT
                            'effectiveDate cannot be earlier than today'
                            INTO par_return_msg;
                        EXIT return_error;
                    END;
                END IF;

                BEGIN
                    INSERT INTO User_profile (user_id, group_id, password, department, name, authority_code, expiration_date, effective_date, rank_code, menu, dt_security_code, hospital_code, hkid, user_title, dt_enable_flag, dt_effective_date, dt_expiration_date, password_expiration_date, password_retry_count, cuid_flag, email, encrypted_pswd)
                    VALUES (par_user_id, par_group_id, par_password, par_department, par_name, par_authority_code, par_expiration_date, par_effective_date, par_rank_code, par_menu, par_dt_security_code, par_hospital_code, par_hkid, par_user_title, par_dt_enable_flag, par_dt_effective_date, par_dt_expiration_date, par_password_expiration_date, par_password_retry_count, par_cuid_flag, par_email, par_encrypted_pswd);
                    var_error := 0;
                    EXCEPTION
                        WHEN NOT_NULL_VIOLATION THEN
                            var_error := 515;
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_error != 0 OR var_rowcount != 1 THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO par_return_code;
                        IF var_error = 515 THEN
                            par_return_code := var_error;
                        END IF;
                        SELECT
                            'cannot insert into User_profile'
                            INTO par_return_msg;
                        EXIT return_error;
                    END;
                END IF;

                IF var_new_password_control_flag = 'Y' THEN
                    BEGIN
                        CALL hasp_set_user_password(var_return_code, par_hospital_code, par_user_id, par_encrypted_pswd, par_password_expiration_date, par_updated_by, par_last_update_status, par_password, par_event_type, par_return_code, par_return_msg);

                        BEGIN
                            var_error := 0;
                            EXCEPTION
                                 WHEN NOT_NULL_VIOLATION THEN
                                    var_error := 515;
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;

                        IF par_return_code != 0 OR var_error != 0 THEN
                            BEGIN
                                IF var_error = 515 THEN
                                    par_return_code := var_error;
                                END IF;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        /* ---------------- */
        ELSE
            IF par_action_type = var_update_expiry_action THEN
                BEGIN
                    BEGIN
                        SELECT
                            Effective_date
                            INTO par_effective_date
                            FROM User_profile
                            WHERE Hospital_code = par_hospital_code AND User_ID = par_user_id;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    END;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                    var_rowcount := sql$rowcount;

                    IF var_rowcount != 1 THEN
                        BEGIN
                            SELECT
                                - 1
                                INTO par_return_code;
                            SELECT
                                CONCAT('User Id not exist!! ', par_user_id)
                                INTO par_return_msg;
                            EXIT return_error;
                        END;
                    END IF;

                    IF par_expiration_date < par_effective_date THEN
                        BEGIN
                            SELECT
                                - 1
                                INTO par_return_code;
                            SELECT
                                'expirationDate cannot be earlier than effectiveDate'
                                INTO par_return_msg;
                            EXIT return_error;
                        END;
                    END IF;

                    BEGIN
                        UPDATE User_profile
                        SET Expiration_date = par_expiration_date
                            WHERE Hospital_code = par_hospital_code AND User_ID = par_user_id;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    END;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                    var_rowcount := sql$rowcount;

                    IF var_error != 0 OR var_rowcount != 1 THEN
                        BEGIN
                            SELECT
                                - 1
                                INTO par_return_code;
                            SELECT
                                'cannot update User_profile'
                                INTO par_return_msg;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            /* --------------- */
            ELSE
                BEGIN
                    SELECT
                        - 1
                        INTO par_return_code;
                    SELECT
                        CONCAT('no action_type: ', par_action_type, ' is allowed.')
                        INTO par_return_msg;
                    EXIT return_error;
                END;
            END IF;
        END IF;
        SELECT
            'Y'
            INTO var_success;

        BEGIN
            INSERT INTO ipas_user_management_log (hospital, masked_hkid, login_id, action, input_message_1, input_message_2, success, error_message, update_datetime, update_by, update_project)
            VALUES (par_hospital_code, par_masked_hkid, par_user_id, par_action_type, par_input_message_1, par_input_message_2, var_success, par_return_msg, timestamp_convert(localtimestamp), par_updated_by, par_update_project);
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF var_error != 0 OR var_rowcount != 1 THEN
            BEGIN
                SELECT
                    - 1
                    INTO par_return_code;
                SELECT
                    'Cannot write log into ipas_user_management_log.'
                    INTO par_return_msg;
                EXIT return_error;
            END;
        END IF;

        pas_return_code := 0;
        RETURN;
    END;
	
    pas_return_code := - 1;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;