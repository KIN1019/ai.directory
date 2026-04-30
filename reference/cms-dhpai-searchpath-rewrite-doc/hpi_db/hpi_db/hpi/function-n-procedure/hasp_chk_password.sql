CREATE OR REPLACE PROCEDURE hasp_chk_password(INOUT pas_return_code int, IN par_user_id VARCHAR, IN par_password VARCHAR, INOUT par_result INTEGER)
AS 
$BODY$
/*
@result values   Meaning
0          Password correct
1          Password NOT correct
2          User_id NOT found
*/
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_ret_code INTEGER;
    var_encrypt_pswd VARCHAR(32);
    sql$rowcount BIGINT;
BEGIN
    <<abnormal_end>>
    BEGIN
        <<normal_end>>
        BEGIN
            SELECT
                0
                INTO par_result;

            BEGIN
                SELECT
                    Password
                    INTO var_encrypt_pswd
                    FROM User_profile
                    WHERE User_ID = par_user_id;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF var_error != 0 THEN
                BEGIN
                    RAISE EXCEPTION USING ERRCODE := var_error;
                    EXIT abnormal_end;
                END;
            END IF;

            IF var_rowcount != 1 THEN
                BEGIN
                    SELECT
                        2
                        INTO par_result;
                    EXIT normal_end;
                END;
            END IF;
            CALL hasp_cal_password(var_ret_code, par_user_id, var_encrypt_pswd);

            IF var_ret_code != 0 THEN
                BEGIN
                    RAISE EXCEPTION '% ', var_ret_code USING ERRCODE := '200022';
                    EXIT abnormal_end;
                END;
            END IF;

            IF var_encrypt_pswd != par_password THEN
                BEGIN
                    SELECT
                        1
                        INTO par_result;
                    EXIT normal_end;
                END;
            END IF;
        END;
        pas_return_code := 0;
        RETURN;
    END;
    pas_return_code := 99;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;