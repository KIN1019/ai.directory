-- DROP PROCEDURE hpi.cpi_get_int_by_bin(inout int4, in varchar, inout int4);

CREATE OR REPLACE PROCEDURE hpi.cpi_get_int_by_bin(INOUT pas_return_code integer, IN par_on_off_bit character varying, INOUT par_hex_int integer)
 LANGUAGE plpgsql
AS $procedure$
/*
-	This sp is used to obtain an integer by indicating which bit
	is on or off - @on_off_bit.
-	The first char. in the @on_off_bit represent bit 0, the
	second char. represent bit 1, and so on so for. Value "Y"
	means on, else means off.
-	For simplicity and clarity, bit 31 is not used since it is
	a sign bit for integer type. i.e. if bit 31 is on, it
	represents a negative integer.
*/
DECLARE
    var_i INTEGER;
BEGIN
    SELECT
        0, 0
        INTO par_hex_int, var_i;

    WHILE var_i <= 31 LOOP
        SELECT
            var_i + 1
            INTO var_i;

        IF SUBSTRING(par_on_off_bit, var_i, 1) = 'Y' THEN
            SELECT
                par_hex_int + SIGN(POWER(2, var_i - 1)) * FLOOR(ABS(POWER(2, var_i - 1)))::INT
                INTO par_hex_int;
        END IF;
    END LOOP;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_get_int_by_bin" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
