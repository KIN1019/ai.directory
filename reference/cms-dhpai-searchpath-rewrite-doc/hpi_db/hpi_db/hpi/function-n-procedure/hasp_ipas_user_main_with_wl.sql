-- DROP PROCEDURE hpi.hasp_ipas_user_main_with_wl(inout int4, in varchar, in bpchar, in bpchar, in bpchar, in int4, in bpchar, in timestamp, in bpchar, in timestamp, in int4, in timestamp, in timestamp, in bpchar, in bpchar, in bpchar, in varchar, in bpchar, in timestamp, in int4, in bpchar, in bpchar, in varchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_ipas_user_main_with_wl(INOUT pas_return_code integer, IN par_action_type character varying, IN par_update_password character, IN par_hospital_code character, IN par_user_id character, IN par_authority_code integer, IN par_department character, IN par_dt_effective_date timestamp without time zone, IN par_dt_enable_flag character, IN par_dt_expiration_date timestamp without time zone, IN par_dt_security_code integer, IN par_effective_date timestamp without time zone, IN par_expiration_date timestamp without time zone, IN par_group_id character, IN par_hkid character, IN par_menu character, IN par_name character varying, IN par_password character, IN par_password_expiration_date timestamp without time zone, IN par_password_retry_count integer, IN par_rank_code character, IN par_user_title character, IN par_email character varying, IN par_encrypted_pswd character, IN par_cuid_flag character, IN par_enablepspnamesearchwhitelist character, IN par_cvforaereg character, IN par_cvforipreg character, IN par_cvforpmienq character, IN par_cvforhkpmienq character, IN par_cvforupdpatdemo character, IN par_cvforupdpatdemononmajorkey character, IN par_cvforupdconfi character, IN par_updated_by character, IN par_event_type character, INOUT par_return_code integer, INOUT par_return_msg character varying)
 LANGUAGE plpgsql
AS $procedure$
/* --update flag */
/* --IpasUserProfile */
/* --hasp_set_user_password */
/* --return message */
DECLARE
    var_begin_tran VARCHAR(1);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_create_account_action VARCHAR(50);
    var_create_account_without_upd_user_pwd_table_action VARCHAR(50);
    var_update_account_action VARCHAR(50);
    var_update_account_without_upd_user_pwd_table_action VARCHAR(50);
    sql$rowcount BIGINT;
    var_return_code int;
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
            'createIPASAccountWithoutUpdUserPwdTable'
            INTO var_create_account_without_upd_user_pwd_table_action;
        SELECT
            'updateIPASAccount'
            INTO var_update_account_action;
        SELECT
            'updateIPASAccountWithoutUpdUserPwdTable'
            INTO var_update_account_without_upd_user_pwd_table_action;
        /* Start Transaction */
        SELECT
            'N'
            INTO var_begin_tran;
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
        	begin
        		select @begin_tran = 'Y'
        		begin transaction
        	end
            else
            begin
        		select @begin_tran = 'S'
        		save transaction hasp_ipas_user_main_with_wl
            end
        */
        /* -------------- */
        IF par_action_type = var_create_account_action THEN
            BEGIN
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
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;

                BEGIN
                    INSERT INTO User_profile (user_id, group_id, password, department, name, authority_code, expiration_date, effective_date, rank_code, menu, dt_security_code, hospital_code, hkid, user_title, dt_enable_flag, dt_effective_date, dt_expiration_date, password_expiration_date, password_retry_count, cuid_flag, email, encrypted_pswd)
                    VALUES (par_user_id, par_group_id, par_password, par_department, par_name, par_authority_code, par_expiration_date, par_effective_date, par_rank_code, par_menu, par_dt_security_code, par_hospital_code, par_hkid, par_user_title, par_dt_enable_flag, par_dt_effective_date, par_dt_expiration_date, par_password_expiration_date, par_password_retry_count, par_cuid_flag, par_email, par_encrypted_pswd);
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
                            -1
                            INTO par_return_code;
                        SELECT
                            'Cannot insert into User_profile'
                            INTO par_return_msg;
                        /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
                CALL hasp_set_user_password(pas_return_code,par_hospital_code, par_user_id, par_encrypted_pswd, par_password_expiration_date, par_updated_by, par_event_type, par_password, par_event_type, par_return_code, par_return_msg);

                BEGIN
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF par_return_code != 0 OR var_error != 0 THEN
                    BEGIN
                         /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        /* -------------- */
        /* 202203 when PSP_ENABLE_NAME_SEARCH_WL = Y and enable_user_password_control = N */
        ELSE
            IF par_action_type = var_create_account_without_upd_user_pwd_table_action THEN
                BEGIN
                    IF EXISTS (SELECT
                        1
                        FROM User_profile
                        WHERE Hospital_code = par_hospital_code AND User_ID = par_user_id) THEN
                        BEGIN
                            SELECT
                                -1
                                INTO par_return_code;
                            SELECT
                                CONCAT('User Id already exist!! ', par_user_id)
                                INTO par_return_msg;
                             /*EXIT return_error;*/
                             raise exception '';
                        END;
                    END IF;

                    BEGIN
                        INSERT INTO User_profile (user_id, group_id, password, department, name, authority_code, expiration_date, effective_date, rank_code, menu, dt_security_code, hospital_code, hkid, user_title, dt_enable_flag, dt_effective_date, dt_expiration_date, password_expiration_date, password_retry_count, cuid_flag, email, encrypted_pswd)
                        VALUES (par_user_id, par_group_id, par_password, par_department, par_name, par_authority_code, par_expiration_date, par_effective_date, par_rank_code, par_menu, par_dt_security_code, par_hospital_code, par_hkid, par_user_title, par_dt_enable_flag, par_dt_effective_date, par_dt_expiration_date, par_password_expiration_date, par_password_retry_count, par_cuid_flag, par_email, NULL);
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
                                -1
                                INTO par_return_code;
                            SELECT
                                'Cannot insert into User_profile'
                                INTO par_return_msg;
                             /*EXIT return_error;*/
                             raise exception '';
                        END;
                    END IF;

                    IF par_return_code != 0 OR var_error != 0 THEN
                        BEGIN
                             /*EXIT return_error;*/
                             raise exception '';
                        END;
                    END IF;
                END;
            /* ---------------- */
            ELSE
                IF par_action_type = var_update_account_action THEN
                    BEGIN
                        IF (SELECT
                            COUNT(1)
                            FROM User_profile
                            WHERE Hospital_code = par_hospital_code AND User_ID = par_user_id) < 1 THEN
                            BEGIN
                                SELECT
                                    -1
                                    INTO par_return_code;
                                SELECT
                                    CONCAT('User Id is not exist!! ', par_user_id)
                                    INTO par_return_msg;
                                 /*EXIT return_error;*/
                                  raise exception '';
                            END;
                        END IF;

                        BEGIN
                            IF par_update_password = 'N' THEN
                                BEGIN
                                    UPDATE User_profile
                                    SET Group_ID = par_group_id, Department = par_department, Name = par_name, Authority_code = par_authority_code, Expiration_date = par_expiration_date, Effective_date = par_effective_date, Rank_code = par_rank_code, Menu = par_menu, DT_security_code = par_dt_security_code, HKID = par_hkid, User_title = par_user_title, DT_enable_flag = par_dt_enable_flag, DT_effective_date = par_dt_effective_date, DT_expiration_date = par_dt_expiration_date, Password_expiration_date = par_password_expiration_date, cuid_flag = par_cuid_flag, Email = par_email
                                        WHERE Hospital_code = par_hospital_code AND User_ID = par_user_id;
                                END;
                            END IF;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF var_error != 0 THEN
                            BEGIN
                                SELECT
                                    -1
                                    INTO par_return_code;
                                SELECT
                                    'Cannot update User_profile table'
                                    INTO par_return_msg;
                                 /*EXIT return_error;*/
                                 raise exception '';
                            END;
                        END IF;

                        IF par_update_password = 'Y' THEN
                            BEGIN
                                CALL hasp_set_user_password(pas_return_code,par_hospital_code, par_user_id, par_encrypted_pswd, par_password_expiration_date, par_updated_by, par_event_type, par_password, par_event_type, par_return_code, par_return_msg);

                                BEGIN
                                    var_error := 0;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            var_error := 1;
                                END;

                                IF par_return_code != 0 OR var_error != 0 THEN
                                    BEGIN
                                         /*EXIT return_error;*/
                                         raise exception '';
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                /* ---------------- */
                ELSE
                    IF par_action_type = var_update_account_without_upd_user_pwd_table_action THEN
                        BEGIN
                            IF (SELECT
                                COUNT(1)
                                FROM User_profile
                                WHERE Hospital_code = par_hospital_code AND User_ID = par_user_id) < 1 THEN
                                BEGIN
                                    SELECT
                                        -1
                                        INTO par_return_code;
                                    SELECT
                                        CONCAT('User Id is not exist!! ', par_user_id)
                                        INTO par_return_msg;
                                     /*EXIT return_error;*/
                                      raise exception '';
                                END;
                            END IF;

                            BEGIN
                                IF par_update_password = 'N' THEN
                                    BEGIN
                                        UPDATE User_profile
                                        SET Group_ID = par_group_id, Department = par_department, Name = par_name, Authority_code = par_authority_code, Expiration_date = par_expiration_date, Effective_date = par_effective_date, Rank_code = par_rank_code, Menu = par_menu, DT_security_code = par_dt_security_code, HKID = par_hkid, User_title = par_user_title, DT_enable_flag = par_dt_enable_flag, DT_effective_date = par_dt_effective_date, DT_expiration_date = par_dt_expiration_date, Password_expiration_date = par_password_expiration_date, cuid_flag = par_cuid_flag, Email = par_email
                                            WHERE Hospital_code = par_hospital_code AND User_ID = par_user_id;
                                    END;
                                END IF;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                            END;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;

                            IF var_error != 0 THEN
                                BEGIN
                                    SELECT
                                        -1
                                        INTO par_return_code;
                                    SELECT
                                        'Cannot update User_profile table'
                                        INTO par_return_msg;
                                     /*EXIT return_error;*/
                                     raise exception '';
                                END;
                            END IF;

                            BEGIN
                                IF par_update_password = 'Y' THEN
                                    BEGIN
                                        IF par_password_expiration_date = NULL THEN
                                            BEGIN
                                                UPDATE User_profile
                                                SET encrypted_pswd = par_password, Password = par_password, Password_retry_count = 0
                                                    WHERE Hospital_code = par_hospital_code AND User_ID = par_user_id;
                                            END;
                                        ELSE
                                            BEGIN
                                                UPDATE User_profile
                                                SET Password_expiration_date = par_password_expiration_date, Password = par_password, Password_retry_count = 0
                                                    WHERE Hospital_code = par_hospital_code AND User_ID = par_user_id;
                                            END;
                                        END IF;
                                    END;
                                END IF;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                            END;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;

                            IF var_error != 0 THEN
                                BEGIN
                                    SELECT
                                        -1
                                        INTO par_return_code;
                                    SELECT
                                        'Cannot update User_profile table'
                                        INTO par_return_msg;
                                     /*EXIT return_error;*/
                                     raise exception '';
                                END;
                            END IF;
                        END;
                    /* --------------- */
                    ELSE
                        BEGIN
                            SELECT
                                -1
                                INTO par_return_code;
                            SELECT
                                CONCAT('no action_type: ', par_action_type, ' is allowed.')
                                INTO par_return_msg;
                             /*EXIT return_error;*/
                              raise exception '';
                        END;
                    END IF;
                END IF;
            END IF;
        END IF;

        IF par_enablepspnamesearchwhitelist = 'Y' THEN
            BEGIN
                CALL cpi_set_pas_func_whitelist(pas_return_code,par_hospital_code, par_user_id,'PSP_NAME_SEARCH', par_updated_by, par_cvForAeReg,par_cvForIpReg,par_cvForPmiEnq,par_cvForHkpmiEnq,par_cvForUpdPatDemo,par_cvForUpdPatDemoNonMajorKey,par_cvForUpdConfi, par_return_msg);

                BEGIN
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                /* --Test commit/rollback in nested SP */
                /* --select @error = -999 */
                /* --select @return_code = -888 */
                /* --select @return_msg = 'Test commit/rollback in nested SP' */
                /* --Test commit/rollback in nested SP */
                IF par_return_code != 0 OR var_error != 0 THEN
                    BEGIN
                         /*EXIT return_error;*/
                          raise exception '';
                    END;
                END IF;
            END;
        END IF;

        /*IF var_begin_tran = 'Y' THEN
            BEGIN
                /*
                [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                commit transaction
                */
            END;
        ELSE
            IF var_begin_tran = 'S' THEN
                BEGIN
                    /*
                    [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                    commit hasp_ipas_user_main_with_wl
                    */
                END;
            END IF;
        END IF;*/
       EXCEPTION
	    WHEN OTHERS THEN
	    	begin
		    	pas_return_code := par_return_code;
		    	raise exception '';
	   	    END;
        
        RETURN;
    END;

    /*IF var_begin_tran = 'Y' THEN
        BEGIN
            ROLLBACK;
        END;
    ELSE
        IF var_begin_tran = 'S' THEN
            BEGIN
                /*
                [9996 - Severity CRITICAL - Transformer error occurred in statement. Please submit report to developers.]
                rollback hasp_ipas_user_main_with_wl
                */
                BEGIN
                END;
            END;
        END IF;
    END IF;*/
  	
    pas_return_code := par_return_code;
    RETURN;
END;
$procedure$
;
