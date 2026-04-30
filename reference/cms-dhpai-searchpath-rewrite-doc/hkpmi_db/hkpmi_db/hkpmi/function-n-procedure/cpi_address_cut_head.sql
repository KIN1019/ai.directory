-- DROP PROCEDURE hkpmi.cpi_address_cut_head(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.cpi_address_cut_head(INOUT pas_return_code integer, IN par_in_name character varying, INOUT par_out_name character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_record_type VARCHAR(50);
    var_string_pos INTEGER;
    var_space_pos INTEGER;
    var_temp_record_type VARCHAR(50);
BEGIN
    SELECT REGEXP_REPLACE(UPPER(par_in_name), '[;,.]', ' ', 'g')
    INTO par_in_name;
 
    SELECT
        NULL
        INTO par_out_name;

    WHILE par_in_name IS NOT NULL LOOP
        SELECT
            NULL
            INTO var_record_type;
        SELECT
            0
            INTO var_string_pos;
        SELECT
            STRPOS(LTRIM(RTRIM(par_in_name)), ' ')
            INTO var_string_pos;
        /* Cut the last word for record type checking */

        IF var_string_pos > 1 THEN
            BEGIN
                SELECT
                    SAFE_SUBSTRING(LTRIM(RTRIM(par_in_name)), 1, var_string_pos - 1)
                    INTO var_record_type;
                SELECT
                    SAFE_SUBSTRING(LTRIM(RTRIM(par_in_name)), var_string_pos + 1, CHAR_LENGTH(LTRIM(RTRIM(par_in_name))))
                    INTO par_in_name;
            END;
        ELSE
            BEGIN
                SELECT
                    par_in_name
                    INTO var_record_type;
                SELECT
                    NULL
                    INTO par_in_name;
            END;
        END IF;
        /* check if record_type contains only one character skip it */
        IF CHAR_LENGTH(var_record_type) = 1 THEN
            CONTINUE;
        END IF;

        IF SAFE_SUBSTRING(var_record_type, 1, 1) IN (',', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0') THEN
            CONTINUE;
        ELSE
            IF EXISTS (SELECT
                *
                FROM address_type
                WHERE full_name = var_record_type OR abbreviation = var_record_type) THEN
                BEGIN
                    IF par_out_name IS NULL THEN
                        CONTINUE;
                    ELSE
                        EXIT;
                    END IF;
                END;
            ELSE
                IF SAFE_SUBSTRING(var_record_type, 2, 1) IN (',', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0') THEN
                    CONTINUE;
                END IF;
            END IF;
        END IF;
        SELECT
            CONCAT(par_out_name, var_record_type, REPEAT(' ', 1))
            INTO par_out_name;
    END LOOP;
    SELECT
        RTRIM(par_out_name)
        INTO par_out_name;
END;
$procedure$
;


ALTER PROCEDURE "cpi_address_cut_head" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

