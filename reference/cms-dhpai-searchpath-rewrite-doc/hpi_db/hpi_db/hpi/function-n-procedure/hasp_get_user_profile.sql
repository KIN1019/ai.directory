-- DROP PROCEDURE hasp_get_user_profile(inout int4, in bpchar, in bpchar, in bpchar, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_user_profile(INOUT pas_return_code integer, IN par_hosp_code character, IN par_user_id character, IN par_by_what character, IN par_by_value character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* add hosp code for HPI by ML on 29.07.1999 */ /* I - id, N - Name */
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_authority_code INTEGER;
    var_super_user INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<abnormal_end>>
    BEGIN
        /* add hosp code for HPI by ML on 29.07.1999 */
        BEGIN
            SELECT
                Authority_code
                INTO var_authority_code
                FROM User_profile
                WHERE Hospital_code = par_hosp_code AND User_ID = par_user_id;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            var_rowcount := sql$rowcount;
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;

        IF var_rowcount <> 1 OR var_error <> 0 THEN
            BEGIN
                EXIT abnormal_end;
            END;
        END IF;

        IF var_authority_code & 1024 > 0 THEN /* BIT 10 is on, System Adm (HAHO) */
            BEGIN
                /* select @authority_code = 261120  /* BIT 10 to 17 is on */ */
                SELECT
                    523264
                    INTO var_authority_code; /* BIT 10 to 17, 18 is on */
                SELECT
                    1
                    INTO var_super_user;
            END;
        ELSE
            BEGIN
                SELECT
                    0
                    INTO var_super_user;

                IF var_authority_code & 2048 > 0 THEN /* BIT 11 is on, System Adm (General) */
                    BEGIN
                        /* select @authority_code = 260096   /* 11 to 17 is on */ */
                        SELECT
                            522240
                            INTO var_authority_code /* 11 to 17, 18 is on */;
                    END;
                ELSE
                    BEGIN
                        IF var_authority_code & 4096 > 0 THEN /* BIT 12 is on, System Adm (User profile maint) */
                            BEGIN
                                /* select @authority_code = 258048   /* BIT 12 to 17 is on */ */
                                SELECT
                                    520192
                                    INTO var_authority_code /* BIT 12 to 17, 18 is on */;
                            END;
                        ELSE
                            BEGIN
                                SELECT
                                    0
                                    INTO var_authority_code;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        SELECT
            CONCAT('%', par_by_value, '%')
            INTO par_by_value;

        BEGIN
            IF par_by_what = 'I' THEN /* select by user id */
                BEGIN
                    IF var_super_user = 1 THEN
                        BEGIN
                            /* add hosp code for HPI by ML on 29.07.1999 */
                            OPEN p_refcur FOR
                            SELECT
                                User_ID, Name, Effective_date, Expiration_date
                                FROM User_profile
                                WHERE User_ID LIKE par_by_value AND Hospital_code = par_hosp_code AND (Authority_code & var_authority_code > 0 OR Authority_code = 0)
                                ORDER BY User_ID NULLS FIRST;
                        END;
                    ELSE
                        BEGIN
                            /* add hosp code for HPI by ML on 29.07.1999 */
                            OPEN p_refcur FOR
                            SELECT
                                User_ID, Name, Effective_date, Expiration_date
                                FROM User_profile
                                WHERE User_ID LIKE par_by_value AND Hospital_code = par_hosp_code AND ((Authority_code & var_authority_code > 0 AND Authority_code & 1024 = 0) OR Authority_code = 0)
                                ORDER BY User_ID NULLS FIRST;
                        END;
                    END IF;
                END;
            ELSE
                /* select by user name */
                BEGIN
                    IF var_super_user = 1 THEN
                        BEGIN
                            /* add hosp code for HPI by ML on 29.07.1999 */
                            OPEN p_refcur FOR
                            SELECT
                                User_ID, Name, Effective_date, Expiration_date
                                FROM User_profile
                                WHERE Name LIKE par_by_value AND Hospital_code = par_hosp_code AND (Authority_code & var_authority_code > 0 OR Authority_code = 0)
                                ORDER BY User_ID NULLS FIRST;
                        END;
                    ELSE
                        BEGIN
                            /* add hosp code for HPI by ML on 29.07.1999 */
                            OPEN p_refcur FOR
                            SELECT
                                User_ID, Name, Effective_date, Expiration_date
                                FROM User_profile
                                WHERE Name LIKE par_by_value AND Hospital_code = par_hosp_code AND ((Authority_code & var_authority_code > 0 AND Authority_code & 1024 = 0) OR Authority_code = 0)
                                ORDER BY User_ID NULLS FIRST;
                        END;
                    END IF;
                END;
            END IF;
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

        <<normal_end>>
        BEGIN
            pas_return_code := 0;
            RETURN;
        END;
    END;
    pas_return_code := 99;
    RETURN;
END;
/* --go */
/* --grant execute on hasp_get_user_profile to adt_group */
/* --go */
/* -- */
/* --grant execute on hasp_get_user_profile to pas_app_gp */
/* --go */
$procedure$
;

;ALTER PROCEDURE "hasp_get_user_profile" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
