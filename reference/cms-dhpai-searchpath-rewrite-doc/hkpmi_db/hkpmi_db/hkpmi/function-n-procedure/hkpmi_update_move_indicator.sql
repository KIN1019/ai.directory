CREATE OR REPLACE PROCEDURE hkpmi_update_move_indicator(INOUT pas_return_code int,IN par_hospital_code VARCHAR, IN par_case_no VARCHAR, IN par_create_dtm TIMESTAMP WITHOUT TIME ZONE, IN par_update_dtm TIMESTAMP WITHOUT TIME ZONE, IN par_update_user VARCHAR, IN par_update_system VARCHAR, INOUT par_return_code INTEGER, INOUT par_error_message VARCHAR)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rowcount INTEGER;
    var_error INTEGER;
    var_begin_tran VARCHAR(1);
    var_status VARCHAR(1);
    sql$rowcount BIGINT;
BEGIN
    BEGIN
        SELECT
            0, 0, NULL, NULL
            INTO var_error, par_return_code, par_error_message, var_status;
        /* --,@update_dtm=isnull(@update_dtm,getdate()) */
        IF par_case_no IS NULL OR NOT EXISTS (SELECT
            case_no
            FROM move_episode_indicator
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND create_dtm = par_create_dtm) THEN
            BEGIN
                SELECT
                    1, 'Move episode record not found!'
                    INTO par_return_code, par_error_message;

                IF par_return_code <> 0 OR var_error != 0 THEN
                    BEGIN
                        IF var_begin_tran = 'Y' THEN
                            --ROLLBACK;
                            RAISE EXCEPTION 'Move episode record not found!';
                        END IF;
                        pas_return_code := - 1;
                        RETURN;
                    END;
                ELSE
                    pas_return_code := 0;
                    RETURN;
                END IF;
            END;
        END IF;

        IF par_update_system NOT IN ('CMS') THEN
            BEGIN
                SELECT
                    3, 'Update system is not correct!'
                    INTO par_return_code, par_error_message;
                    
                IF par_return_code <> 0 OR var_error != 0 THEN
                    BEGIN
                        IF var_begin_tran = 'Y' THEN
                            --ROLLBACK;
                            RAISE EXCEPTION 'Update system is not correct!';
                        END IF;
                        pas_return_code := - 1;
                        RETURN;
                    END;
                ELSE
                    pas_return_code := 0;
                    RETURN;
                END IF;
            END;
        END IF;

        IF par_update_dtm IS NOT NULL THEN
            BEGIN
                IF par_update_dtm < par_create_dtm THEN
                    BEGIN
                        SELECT
                            5, 'Update date/time cannot be before create date/time!'
                            INTO par_return_code, par_error_message;

                        IF par_return_code <> 0 OR var_error != 0 THEN
                            BEGIN
                                IF var_begin_tran = 'Y' THEN
                                    --ROLLBACK;
                                    RAISE EXCEPTION 'Update date/time cannot be before create date/time!';
                                END IF;
                                pas_return_code := - 1;
                                RETURN;
                            END;
                        ELSE
                            pas_return_code := 0;
                            RETURN;
                        END IF;
                        
                    END;
                END IF;
            END;
        END IF;
        SELECT
            move_status
            INTO var_status
            FROM move_episode_indicator
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND create_dtm = par_create_dtm;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                SELECT
                    9999, 'System error in selecting move_episode_indicator table!'
                    INTO par_return_code, par_error_message;
                
            END;
        END IF;

        IF var_rowcount = 1 AND var_status in ('C','M') THEN
            BEGIN
                SELECT
                    2, 'Move episode indicator is already completed or patient is merged to another patient!'
                    INTO par_return_code, par_error_message;

                    IF par_return_code <> 0 OR var_error != 0 THEN
                        BEGIN
                            IF var_begin_tran = 'Y' THEN
                                --ROLLBACK;
                                RAISE EXCEPTION 'Move episode indicator is already completed or patient is merged to another patient!';
                            END IF;
                                pas_return_code := - 1;
                                RETURN;
                        END;
                    ELSE
                        pas_return_code := 0;
                        RETURN;
                    END IF;
            END;
        END IF;
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
           	begin
              		begin tran
              		select @begin_tran = "Y"
           	end
           	else
              		select @begin_tran = "N"
        */
        UPDATE move_episode_indicator
        SET move_status = 'C', update_dtm = par_update_dtm, update_user = par_update_user, update_system = par_update_system
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND create_dtm = par_create_dtm;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_rowcount <> 1 OR var_error != 0 THEN
            BEGIN
                SELECT
                    9999, 'System error in updating move_episode_indicator table!'
                    INTO par_return_code, par_error_message;

                IF par_return_code <> 0 OR var_error != 0 THEN
                    BEGIN
                        IF var_begin_tran = 'Y' THEN
                            --ROLLBACK;
                            RAISE EXCEPTION 'Move episode indicator is already completed!';
                        END IF;
                            pas_return_code := - 1;
                            RETURN;
                    END;
                ELSE
                    pas_return_code := 0;
                    RETURN;
                END IF;

            END;
        END IF;

        IF var_begin_tran = 'Y' THEN
            /*
            [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
            commit
            */
            BEGIN
                return;
            END;
        END IF;
    END;

   
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_update_move_indicator" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";