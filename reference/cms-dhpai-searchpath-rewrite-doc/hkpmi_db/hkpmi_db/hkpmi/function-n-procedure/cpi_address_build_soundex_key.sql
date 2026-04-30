-- DROP PROCEDURE hkpmi.cpi_address_build_soundex_key(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.cpi_address_build_soundex_key(INOUT pas_return_code integer, IN par_name character varying, INOUT par_soundex_key character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_counter INTEGER;
    var_last_char VARCHAR(1);
    var_word1 VARCHAR(255);
    var_word2 VARCHAR(255);
    var_temp_word VARCHAR(255);
    var_temp_soundex_key VARCHAR(16);
    var_post INTEGER;
    var_soundex_chk INTEGER;
    var_temp_char VARCHAR(1);
BEGIN
    SELECT
        NULL
        INTO var_word1;
    SELECT
        NULL
        INTO var_word2;
    SELECT
        ''
        INTO par_soundex_key;
    SELECT
        0
        INTO var_post;
    SELECT
        RTRIM(UPPER(par_name))
        INTO par_name;
    SELECT
        STRPOS(par_name, ' ')
        INTO var_post;

    IF NOT (var_post = 0) THEN
        BEGIN
            SELECT
                SAFE_SUBSTRING(par_name, 1, var_post - 1)
                INTO var_word1;
            SELECT
                SAFE_SUBSTRING(par_name, var_post + 1, 255)
                INTO par_name;
            /* Copy the second word if exist */
            SELECT
                STRPOS(par_name, ' ')
                INTO var_post;

            IF NOT (var_post = 0) THEN
                BEGIN
                    SELECT
                        SAFE_SUBSTRING(par_name, 1, var_post - 1)
                        INTO var_word2;
                    SELECT
                        SAFE_SUBSTRING(par_name, var_post + 1, 255)
                        INTO par_name;
                END;
            ELSE
                SELECT
                    par_name
                    INTO var_word2;
            END IF;
        END;
    ELSE
        BEGIN
            SELECT
                par_name
                INTO var_word1;
            SELECT
                NULL
                INTO var_word2;
        END;
    END IF;
    /* --print @word1 */
    /* --print @word2 */
    SELECT
        var_word1
        INTO var_temp_word;
    SELECT
        1
        INTO var_counter;

    WHILE COALESCE(CHAR_LENGTH(par_soundex_key), 0) <= 7 LOOP
        IF var_temp_word IS NULL THEN
            BEGIN
                SELECT
                    CONCAT(RTRIM(par_soundex_key), '0000')
                    INTO par_soundex_key;
                CONTINUE;
            END;
        END IF;

        IF var_counter = 1 THEN
            BEGIN
                IF (SAFE_SUBSTRING(var_temp_word, var_counter, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')) THEN
                    BEGIN
                        SELECT
                            CONCAT(RTRIM(par_soundex_key), '0000')
                            INTO par_soundex_key;
                        SELECT
                            var_word2
                            INTO var_temp_word;
                        SELECT
                            1
                            INTO var_counter;
                        CONTINUE;
                    END;
                ELSE
                    BEGIN
                        SELECT
                            CONCAT(RTRIM(par_soundex_key), SAFE_SUBSTRING(var_temp_word, var_counter, 1))
                            INTO par_soundex_key;
                        SELECT
                            SAFE_SUBSTRING(var_temp_word, var_counter, 1)
                            INTO var_last_char;
                        SELECT
                            var_counter + 1
                            INTO var_counter;
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                WHILE (var_counter <= 255) LOOP
                    IF (CHAR_LENGTH(par_soundex_key) = 4 AND (var_word1 = var_temp_word)) OR (CHAR_LENGTH(par_soundex_key) = 8 AND (var_word2 = var_temp_word)) THEN
                        EXIT;
                    END IF;

                    IF (var_last_char <> SAFE_SUBSTRING(var_temp_word, var_counter, 1)) OR (var_last_char IS NOT NULL AND SAFE_SUBSTRING(var_temp_word, var_counter, 1) IS NULL) THEN
                        BEGIN
                            SELECT
                                NULL
                                INTO var_temp_char;
                            SELECT
                                phonetic_code
                                INTO var_temp_char
                                FROM address_phonetic_code
                                WHERE phonetic_char = SAFE_SUBSTRING(var_temp_word, var_counter, 1);

                            IF var_temp_char IS NOT NULL THEN
                                BEGIN
                                    SELECT
                                        CONCAT(RTRIM(par_soundex_key), var_temp_char)
                                        INTO par_soundex_key;
                                    /* --print @temp_char */
                                    /* --print @soundex_key */
                                    SELECT
                                        SAFE_SUBSTRING(var_temp_word, var_counter, 1)
                                        INTO var_last_char;
                                END;
                            END IF;
                        END;
                    END IF;
                    SELECT
                        var_counter + 1
                        INTO var_counter;
                END LOOP;

                IF CHAR_LENGTH(par_soundex_key) <= 4 THEN
                    BEGIN
                        SELECT
                            CONCAT(par_soundex_key, '0000')
                            INTO var_temp_soundex_key;
                        SELECT
                            SAFE_SUBSTRING(var_temp_soundex_key, 1, 4)
                            INTO par_soundex_key;
                        SELECT
                            var_word2
                            INTO var_temp_word;
                        SELECT
                            1
                            INTO var_counter;
                        CONTINUE;
                    END;
                END IF;

                IF CHAR_LENGTH(par_soundex_key) > 4 AND CHAR_LENGTH(par_soundex_key) <= 8 THEN
                    BEGIN
                        SELECT
                            CONCAT(par_soundex_key, '0000')
                            INTO var_temp_soundex_key;
                        SELECT
                            SAFE_SUBSTRING(var_temp_soundex_key, 1, 8)
                            INTO par_soundex_key;
                        EXIT;
                    END;
                END IF;
            END;
        END IF;
    END LOOP;
END;
$procedure$
;

ALTER PROCEDURE "cpi_address_build_soundex_key" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
