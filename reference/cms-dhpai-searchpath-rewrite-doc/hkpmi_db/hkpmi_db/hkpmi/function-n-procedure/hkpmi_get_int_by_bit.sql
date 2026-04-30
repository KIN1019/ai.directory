-- DROP PROCEDURE hkpmi.hkpmi_get_int_by_bit(inout int4, in varchar, inout int4);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_get_int_by_bit(INOUT pas_return_code integer, IN par_on_off_bit character varying, INOUT par_hex_int integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_i INTEGER;
    var_a VARCHAR(1);
BEGIN
    SELECT 0,
           0
    INTO par_hex_int, var_i;

    WHILE var_i <= 31
        LOOP
            SELECT var_i + 1
            INTO var_i;
            SELECT SUBSTRING(par_on_off_bit, var_i, 1)
            INTO var_a;

            IF SUBSTRING(par_on_off_bit, var_i, 1) = 'Y' THEN
                SELECT par_hex_int + SIGN(POWER(2, var_i - 1)) * FLOOR(ABS(POWER(2, var_i - 1)))::INT
                INTO par_hex_int;
            END IF;
        END LOOP;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_get_int_by_bit" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

