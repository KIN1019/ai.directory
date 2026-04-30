-- DROP PROCEDURE hkpmi.ehr_chk_user(inout int4, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.ehr_chk_user(INOUT pas_return_code integer, IN par_userid character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    IF EXISTS (SELECT
        1
        FROM ehr_user_table
        WHERE user_id = par_userid) THEN
        BEGIN
            pas_return_code := 1;
            RETURN;
        END;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "ehr_chk_user" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

