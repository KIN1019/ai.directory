-- DROP PROCEDURE hkpmi.cpi_address_phonetic_word(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.cpi_address_phonetic_word(INOUT pas_return_code integer, IN par_string character varying, INOUT par_output character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_word VARCHAR(100);
    var_i    INTEGER;
BEGIN
    SELECT NULL
    INTO var_word;
    SELECT 1
    INTO var_i;
    SELECT NULL
    INTO par_output;

    IF par_string IS NOT NULL THEN
        BEGIN
            SELECT UPPER(par_string)
            INTO par_string;
            SELECT LTRIM(RTRIM(par_string))
            INTO par_string;
            RAISE NOTICE 'par_string=%', par_string;
            WHILE 0 = 0
                LOOP
                    SELECT STRPOS(par_string, REPEAT(' ', 1))
                    INTO var_i;

                    IF var_i > 0 THEN
                        BEGIN
                            SELECT SUBSTRING(par_string, 1, var_i - 1)
                            INTO var_word;
                            SELECT LTRIM(SUBSTRING(par_string, var_i + 1, CHAR_LENGTH(par_string)))
                            INTO par_string;
                        END;
                    ELSE
                        BEGIN
                            SELECT par_string
                            INTO var_word;
                            SELECT NULL
                            INTO par_string;
                        END;
                    END IF;
                    /* reselect @i for other operation use */
                    SELECT 0
                    INTO var_i;
                    /* Get the standard word from the table and add it to the output string */
                    IF (SELECT 1 FROM address_phonetic_word WHERE non_standard = var_word) THEN
	                    SELECT standard
	                    INTO var_word
	                    FROM address_phonetic_word
	                    WHERE non_standard = var_word;
	                END IF;
                    SELECT CONCAT(par_output, LTRIM(RTRIM(var_word)), REPEAT(' ', 1))
                    INTO par_output;
                    /* when the string is empty, that means the whole string has been converted */

                    IF par_string IS NULL THEN
                        EXIT;
                    END IF;
                END LOOP;
        END;
    END IF;
    SELECT LTRIM(RTRIM(par_output))
    INTO par_output;
END;
$procedure$
;


ALTER PROCEDURE "cpi_address_phonetic_word" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
