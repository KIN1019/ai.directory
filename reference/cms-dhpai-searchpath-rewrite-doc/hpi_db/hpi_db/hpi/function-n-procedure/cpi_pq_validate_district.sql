-- DROP PROCEDURE hpi.cpi_pq_validate_district(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_pq_validate_district(INOUT pas_return_code integer, IN par_district_code character varying, INOUT par_valid_flag character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
BEGIN
    SELECT
        COUNT(*)
        INTO var_cnt
        FROM district
        WHERE district_code = par_district_code;

    IF (var_cnt = 1) THEN
        SELECT
            'Y'
            INTO par_valid_flag;
    ELSE
        SELECT
            'N'
            INTO par_valid_flag;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "cpi_pq_validate_district" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
