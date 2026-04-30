-- DROP PROCEDURE hpi.proc_lrr_get_hosp_map(inout int4, inout varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.proc_lrr_get_hosp_map(INOUT pas_return_code integer, INOUT par_hosp_code character varying, IN par_mapped_hosp character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_login_prefix VARCHAR(6);
    var_error INTEGER;
    var_rowcount INTEGER;
    sql$rowcount BIGINT;
BEGIN
    SELECT
        UPPER(safe_SUBSTRING(current_user, 1, 3))
        INTO var_login_prefix;

    BEGIN
    /*
        SELECT
            MAPPED_HOSP
            INTO par_hosp_code
            FROM cmslrr_db_dbo.HOSP_MAP
            WHERE HOSP_CODE = var_login_prefix;
    */
    SELECT
        Par_MAPPED_HOSP
        INTO par_hosp_code;
        var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
    END;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
    var_rowcount := sql$rowcount;

    IF var_error != 0 THEN
        pas_return_code := var_error;
        RETURN;
    END IF;

    IF var_rowcount != 1 THEN
        BEGIN
            /* raiserror 99999 "Invalid Hospital code mapping" */
            /* return -1 */
            RAISE EXCEPTION 'Invalid Hospital code mapping' USING ERRCODE := '40006';
            pas_return_code := 40006;
            RETURN;
        END;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "proc_lrr_get_hosp_map" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
