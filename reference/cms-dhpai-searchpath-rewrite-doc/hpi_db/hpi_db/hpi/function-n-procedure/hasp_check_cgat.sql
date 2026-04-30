-- DROP PROCEDURE hpi.hasp_check_cgat(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_check_cgat(INOUT pas_return_code integer, IN par_eh_code character varying, INOUT par_cgat_code character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_row INTEGER;
    var_err INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<return_null>>
    BEGIN
        BEGIN
            SELECT
                CONCAT(cgat_hospital, '/CGAT')
                INTO par_cgat_code
                FROM eh_cgat
                WHERE eh_code = par_eh_code;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            var_row := sql$rowcount;
            var_err := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_err := 1;
        END;

        IF var_err = 0 AND var_row = 1 THEN
            /* --- found the cgat code */
            pas_return_code := 0;
            RETURN;
        ELSE
            EXIT return_null;
        END IF;
    END;

    pas_return_code := - 1;
    IF par_eh_code IS NOT NULL THEN
        SELECT
            'HFTA'
            INTO par_cgat_code;
    ELSE
        SELECT
            NULL
            INTO par_cgat_code;
    END IF;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_check_cgat" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
