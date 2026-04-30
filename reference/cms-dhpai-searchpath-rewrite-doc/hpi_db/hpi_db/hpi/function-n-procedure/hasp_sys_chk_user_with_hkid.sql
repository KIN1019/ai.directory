CREATE OR REPLACE PROCEDURE hasp_sys_chk_user_with_hkid(INOUT pas_return_code int, IN par_user_id CHAR, INOUT par_with_hkid_input CHAR DEFAULT 'Y', INOUT par_name VARCHAR DEFAULT '', INOUT par_title VARCHAR DEFAULT '', INOUT par_expiry_date TIMESTAMP WITHOUT TIME ZONE DEFAULT '19000101', IN par_select_output CHAR DEFAULT 'N', INOUT p_refcur refcursor DEFAULT NULL)
AS 
$BODY$
BEGIN
    IF EXISTS (SELECT
        0
        FROM User_profile
        WHERE User_ID = par_user_id) THEN
        BEGIN
            SELECT
                CASE
                    WHEN HKID IS NULL AND User_ID NOT LIKE '@%' THEN 'N'
                    ELSE 'Y'
                END, Name, User_title, Expiration_date
                INTO par_with_hkid_input, par_name, par_title, par_expiry_date
                FROM User_profile
                WHERE User_ID = par_user_id;

            IF par_select_output = 'Y' THEN
                OPEN p_refcur FOR
                SELECT
                    par_with_hkid_input, par_name, par_title, par_expiry_date;
            END IF;
        END;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;