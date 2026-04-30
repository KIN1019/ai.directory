-- DROP PROCEDURE hkpmi.ehr_add_user(inout int4, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.ehr_add_user(INOUT pas_return_code integer, IN "par_userId" character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rcnt INTEGER;
    var_ecnt INTEGER;
    sql$rowcount BIGINT;
BEGIN
    IF EXISTS (SELECT
        1
        FROM ehr_user_table
        WHERE user_id = "par_userId") THEN
        BEGIN
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    INSERT INTO ehr_user_table (user_id)
    VALUES ("par_userId");
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    BEGIN
        var_rcnt := sql$rowcount;
        var_ecnt := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_ecnt := 1;
    END;

    IF (var_ecnt <> 0 OR var_rcnt <> 1) THEN
        BEGIN
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    pas_return_code := 1;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "ehr_add_user" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
