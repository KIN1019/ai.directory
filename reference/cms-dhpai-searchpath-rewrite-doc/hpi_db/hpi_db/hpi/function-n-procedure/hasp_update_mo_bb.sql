CREATE OR REPLACE PROCEDURE hasp_update_mo_bb(INOUT pas_return_code INTEGER, IN par_action VARCHAR, IN par_mo_hosp VARCHAR, IN par_mo_case VARCHAR, IN par_nb_hosp VARCHAR, IN par_nb_case VARCHAR, IN par_mo_case_org VARCHAR, IN par_nb_case_org VARCHAR, IN par_birth_order INTEGER, IN par_preg_number INTEGER, IN par_birth_loc VARCHAR, IN par_birth_place VARCHAR, IN par_user_id VARCHAR, IN par_system_dtm TIMESTAMP WITHOUT TIME ZONE, IN par_baby_hkid VARCHAR DEFAULT null)
AS 
$procedure$
/* for update mo/nb case no .. */
/* --- for 'A' & checked with @nb_case's HKID  to ensure same patient.. */
DECLARE
    var_retcode INTEGER;
    var_error_msg VARCHAR(255);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_raiserror_msg VARCHAR(510);
    var_mo_hkid VARCHAR(24);
    
    sql$rowcount BIGINT;
BEGIN
    <<error>>
    BEGIN
        SELECT
            0, 0, NULL, NULL
            INTO var_retcode, var_error, var_error_msg, var_raiserror_msg;

        IF par_action = 'A' THEN
            BEGIN
                /* --- Ensure ONLY one records for eache Baby HKID --- */
                IF EXISTS (SELECT
                    *
                    FROM mother_baby_case_view
                    WHERE baby_hkid = par_baby_hkid) THEN
                    BEGIN
                        SELECT
                            -21
                            INTO var_retcode;
                        /* --select @error_msg = 'The Mother Baby Relationship already exists for Patient %1!',@baby_hkid */
                        SELECT
                            'The Mother Baby Relationship already exists for the Patient !'
                            INTO var_error_msg;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                        EXIT error;
                    END;
                END IF;
                /* ---20050901 -- */
                /*
                --- IF 260 with different @mo_case for same @mo_hkid
                --- IF 261 with different @mo_case Already handle in cpi_update_mo_bb
                	select @mo_hkid = hkid
                	from cpi_patient
                	where patient_key =
                		(select patient_key
                			from cpi_case
                			where hospital_code = @mo_hosp and case_no = @mo_case
                			)
                
                	if exists(select * from mother_baby_case_view
                		where mother_hkid =@mo_hkid
                			and  birth_order = @birth_order
                		)
                	begin
                		select @retcode = -22
                		select @error_msg = 'Duplicate Birth Order is not allowed!'
                		raiserror 200026 @error_msg
                		goto error
                	end
                */
                
                /* ----20050901--- */
            END;
        END IF;
        CALL cpi_update_mo_bb(var_retcode, par_action, par_mo_hosp, par_mo_case,
        /* --- HPI */
        
        /* ---exec @retcode = cpi..cpi_update_mo_bb @action, @mo_hosp,@mo_case, */
        par_nb_hosp, par_nb_case, par_mo_case_org, par_nb_case_org, par_birth_order, par_preg_number, par_birth_loc, par_birth_place, par_user_id, par_system_dtm, par_baby_hkid);
        

        IF var_retcode <> 0 THEN
            BEGIN
                SELECT
                    messages
                    INTO var_error_msg
                    FROM error_msgs
                    /* --- HPI */
                    
                    /* ---select @error_msg = messages from cpi..error_msgs */
                    WHERE error_code = var_retcode;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_rowcount <> 1 THEN
                    BEGIN
                        IF var_retcode = -1 THEN
                            SELECT
                                'Case no Can not  be null !'
                                INTO var_raiserror_msg;
                        ELSE
                            IF var_retcode = -2 THEN
                                SELECT
                                    'Invalid Action Type !'
                                    INTO var_raiserror_msg;
                            ELSE
                                IF var_retcode = -3 THEN
                                    SELECT
                                        'No Patient Found!'
                                        INTO var_raiserror_msg;
                                ELSE
                                    IF var_retcode = -4 THEN
                                        SELECT
                                            'No Patient HKID Found!'
                                            INTO var_raiserror_msg;
                                    ELSE
                                        IF var_retcode = -5 THEN
                                            SELECT
                                                'The Baby Case MUST belong to same patient'
                                                INTO var_raiserror_msg;
                                        ELSE
                                            IF var_retcode = -6 THEN
                                                SELECT
                                                    'If birth location is OTH, birth place must be Born before arrival'
                                                    INTO var_raiserror_msg;
                                            ELSE
                                                IF var_retcode = -7 THEN
                                                    SELECT
                                                        'If birth place is Labour room, birth location must be own hospital !'
                                                        INTO var_raiserror_msg;
                                                ELSE
                                                    IF var_retcode = -8 THEN
                                                        SELECT
                                                            'Duplicate Birth Order is not allowed!'
                                                            INTO var_raiserror_msg;
                                                    ELSE
                                                        IF var_retcode = -11 THEN
                                                            SELECT
                                                                'Insert mother_baby_case error!'
                                                                INTO var_raiserror_msg;
                                                        ELSE
                                                            IF var_retcode = -12 THEN
                                                                SELECT
                                                                    'Delete mother_baby_case error!'
                                                                    INTO var_raiserror_msg;
                                                            ELSE
                                                                IF var_retcode = -13 THEN
                                                                    SELECT
                                                                        'Delete cpi_new_born error!'
                                                                        INTO var_raiserror_msg;
                                                                ELSE
                                                                    IF var_retcode = -14 THEN
                                                                        SELECT
                                                                            'Update mother_baby_case error!'
                                                                            INTO var_raiserror_msg;
                                                                    ELSE
                                                                        SELECT
                                                                            CONCAT('Call cpi function failed with return code ',
                                                                            CASE CAST (var_retcode AS VARCHAR(8))
                                                                                WHEN '' THEN ''
                                                                                ELSE CAST (var_retcode AS VARCHAR(8))
                                                                            END)
                                                                            INTO var_raiserror_msg;
                                                                    END IF;
                                                                END IF;
                                                            END IF;
                                                        END IF;
                                                    END IF;
                                                END IF;
                                            END IF;
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                        SELECT
                            var_raiserror_msg
                            INTO var_error_msg;
                    END;
                END IF;
                RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                EXIT error;
            END;
        END IF;
    END;
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
LANGUAGE plpgsql;