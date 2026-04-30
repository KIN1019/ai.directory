-- DROP PROCEDURE cpi_pq_validate_destination(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE cpi_pq_validate_destination(INOUT pas_return_code integer, IN par_destination_code character varying, INOUT par_valid_flag character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
BEGIN
    SELECT
        COUNT(*)
        INTO var_cnt
        FROM destination
        WHERE destination_code = par_destination_code;

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


;ALTER PROCEDURE "cpi_pq_validate_destination" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
