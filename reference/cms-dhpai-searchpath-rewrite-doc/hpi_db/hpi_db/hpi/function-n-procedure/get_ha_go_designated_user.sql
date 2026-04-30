-- DROP PROCEDURE hpi.get_ha_go_designated_user(inout int4, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.get_ha_go_designated_user(INOUT pas_return_code integer, IN par_user_id character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_ha_go_designated_user VARCHAR(1);
BEGIN
    IF EXISTS (SELECT
        1
        FROM ha_go_designated_user
        WHERE aws_sapase_ext.user_id = par_user_id::INTEGER) THEN
        BEGIN
            SELECT
                'Y'
                INTO var_ha_go_designated_user;
        END;
    ELSE
        BEGIN
            SELECT
                'N'
                INTO var_ha_go_designated_user;
        END;
    END IF;
    OPEN p_refcur FOR
    SELECT
        var_ha_go_designated_user;
END;
$procedure$;

;ALTER PROCEDURE "get_ha_go_designated_user" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
