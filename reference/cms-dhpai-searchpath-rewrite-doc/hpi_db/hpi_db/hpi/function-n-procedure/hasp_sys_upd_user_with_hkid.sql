CREATE OR REPLACE PROCEDURE hasp_sys_upd_user_with_hkid(INOUT pas_return_code int, IN par_user_id CHAR, IN par_hkid1 INTEGER, IN par_hkid2 INTEGER, IN par_hkid3 INTEGER, IN par_hkid4 INTEGER, IN par_hkid5 INTEGER, IN par_hkid6 INTEGER, IN par_hkid7 INTEGER, IN par_hkid8 INTEGER, IN par_hkid9 INTEGER, IN par_hkid10 INTEGER, IN par_hkid11 INTEGER, IN par_hkid12 INTEGER, IN par_name VARCHAR, IN par_title VARCHAR)
AS 
$BODY$
DECLARE
    var_hkidcode VARCHAR(24);
BEGIN
    CALL hasp_sys_decode(par_hkid1, par_hkid2, par_hkid3, par_hkid4, par_hkid5, par_hkid6, par_hkid7, par_hkid8, var_hkidcode, par_hkid9, par_hkid10, par_hkid11, par_hkid12);

    IF var_hkidcode IS NOT NULL OR LTRIM(RTRIM(var_hkidcode)) <> '' THEN
        BEGIN
            BEGIN
                UPDATE User_profile
                SET HKID = var_hkidcode, Name = par_name, User_title = par_title
                    /* --update_by = @user_id, */
                    /* --update_datetime = getdate() */
                    WHERE User_ID = par_user_id;
                EXCEPTION
                    WHEN others THEN
                        RAISE EXCEPTION 'Canncel update record' USING ERRCODE := '9999';
            END;
        END;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;