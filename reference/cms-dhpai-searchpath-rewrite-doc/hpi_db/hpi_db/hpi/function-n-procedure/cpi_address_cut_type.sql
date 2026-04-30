-- DROP PROCEDURE hpi.cpi_address_cut_type(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_address_cut_type(INOUT pas_return_code integer, IN par_in_name character varying, INOUT par_out_name character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_record_type VARCHAR(20);
BEGIN
    SELECT UPPER(par_in_name)
    INTO par_in_name;

    IF (STRPOS(par_in_name, REPEAT(' ', 1)) > 0) THEN
        BEGIN
            /* Cut the last word for record type checking */
            SELECT REVERSE(SUBSTRING(REVERSE(LTRIM(RTRIM(par_in_name))), 1,
                                     STRPOS(REVERSE(LTRIM(RTRIM(par_in_name))), ' ') - 1))
            INTO var_record_type;
            /* If the last word is found in the record type table, cut it off */

            IF EXISTS (SELECT *
                       FROM address_type
                       WHERE full_name = var_record_type
                          OR abbreviation = var_record_type) THEN
                SELECT REVERSE(SUBSTRING(REVERSE(LTRIM(RTRIM(par_in_name))),
                                         STRPOS(REVERSE(LTRIM(RTRIM(par_in_name))), ' ') + 1, 50))
                INTO par_in_name;
            END IF;
        END;
    END IF;
    SELECT LTRIM(RTRIM(par_in_name))
    INTO par_out_name;
END;
$procedure$
;


;ALTER PROCEDURE "cpi_address_cut_type" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
