-- DROP PROCEDURE hkpmi.cpi_address_build_short_key(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.cpi_address_build_short_key(INOUT pas_return_code integer, IN par_search_name character varying, INOUT par_short_key character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_post INTEGER;
    var_word1 VARCHAR(50);
    var_word2 VARCHAR(50);
    var_word3 VARCHAR(50);
    var_key VARCHAR(1);
BEGIN
    SELECT
        ''
        INTO var_word1;
    SELECT
        ''
        INTO var_word2;
    SELECT
        ''
        INTO var_word3;
    SELECT
        ''
        INTO var_key;
    SELECT
        LTRIM(RTRIM(UPPER(par_search_name)))
        INTO par_search_name;
    /* Copy the first word if exist */
    SELECT
        STRPOS(par_search_name, ' ')
        INTO var_post;

    IF NOT (var_post = 0) THEN
        BEGIN
            SELECT
                SAFE_SUBSTRING(par_search_name, 1, var_post - 1)
                INTO var_word1;
            SELECT
                SAFE_SUBSTRING(par_search_name, var_post + 1, 255)
                INTO par_search_name;
            /* Copy the second word if exist */
            SELECT
                STRPOS(par_search_name, ' ')
                INTO var_post;

            IF NOT (var_post = 0) THEN
                BEGIN
                    SELECT
                        SAFE_SUBSTRING(par_search_name, 1, var_post - 1)
                        INTO var_word2;
                    SELECT
                        SAFE_SUBSTRING(par_search_name, var_post + 1, 255)
                        INTO par_search_name;
                    /* Copy the third word if exist */
                    SELECT
                        STRPOS(par_search_name, ' ')
                        INTO var_post;

                    IF NOT (var_post = 0) THEN
                        BEGIN
                            SELECT
                                SAFE_SUBSTRING(par_search_name, 1, var_post - 1)
                                INTO var_word3;
                            SELECT
                                SAFE_SUBSTRING(par_search_name, var_post + 1, 255)
                                INTO par_search_name;
                        END;
                    ELSE
                        SELECT
                            par_search_name
                            INTO var_word3;
                    END IF;
                END;
            ELSE
                BEGIN
                    SELECT
                        par_search_name
                        INTO var_word2;
                    SELECT
                        REPEAT(' ', 50)
                        INTO var_word3;
                END;
            END IF;
        END;
    ELSE
        BEGIN
            SELECT
                par_search_name
                INTO var_word1;
            SELECT
                REPEAT(' ', 50)
                INTO var_word2;
            SELECT
                REPEAT(' ', 50)
                INTO var_word3;
        END;
    END IF;
    /* Start to make the short key */
    SELECT
        CONCAT(SAFE_SUBSTRING(var_word1, 1, 2), SAFE_SUBSTRING(var_word2, 1, 1), SAFE_SUBSTRING(var_word3, 1, 1), SAFE_SUBSTRING(var_word1, 3, 1), SAFE_SUBSTRING(var_word2, 2, 1), SAFE_SUBSTRING(var_word3, 2, 1))
        INTO par_short_key;
END;
$procedure$
;

ALTER PROCEDURE "cpi_address_build_short_key" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
