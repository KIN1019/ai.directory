-- DROP PROCEDURE hpi.web_hasp_get_hkid_check_digit(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_get_hkid_check_digit(INOUT pas_return_code integer, IN par_hkid character varying, INOUT "par_formattedHkid" character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_tmp_hkid VARCHAR(9);
    var_tmp_char VARCHAR(1);
    var_counter INTEGER;
    var_ascii_sum INTEGER;
    var_result_no INTEGER;
BEGIN
    var_tmp_hkid := RIGHT(CONCAT('  ', par_hkid), 8);
    var_counter := 6;
    var_ascii_sum := 0;
    /* 1st varchar */
    var_tmp_char := LEFT(var_tmp_hkid, 1);

    IF var_tmp_char = ' ' THEN
        var_ascii_sum := 36 * 9;
    ELSE
        var_ascii_sum := (ASCII(var_tmp_char) - 55) * 9;
    END IF;
    /* 2nd varchar */
    var_ascii_sum := var_ascii_sum + (ASCII(RIGHT(LEFT(var_tmp_hkid, 2), 1)) - 55) * 8;
    /* 3rd - 8th varchars */
    WHILE var_counter >= 1 LOOP
        var_tmp_char := LEFT(RIGHT(var_tmp_hkid, var_counter), 1);
        var_ascii_sum := var_ascii_sum + (ASCII(var_tmp_char) - 48) * (var_counter + 1);
        var_counter := var_counter - 1;
    END LOOP;
    var_result_no := 11 - (var_ascii_sum % 11);

    IF var_result_no = 10 THEN
        "par_formattedHkid" := CONCAT(var_tmp_hkid, 'A');
    ELSE
        IF var_result_no > 10 THEN
            "par_formattedHkid" := CONCAT(var_tmp_hkid, '0');
        ELSE
            "par_formattedHkid" := CONCAT(var_tmp_hkid,
            CASE
                WHEN 48 + var_result_no BETWEEN 1 AND 255 THEN CHR(48 + var_result_no)
                ELSE NULL
            END);
        END IF;
    END IF;
END;
$procedure$
;


;ALTER PROCEDURE "web_hasp_get_hkid_check_digit" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
