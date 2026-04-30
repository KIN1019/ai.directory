-- DROP PROCEDURE hkpmi.cpi_get_phonetic_chin_name(inout int4, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.cpi_get_phonetic_chin_name(INOUT pas_return_code integer, IN par_ccc1 varchar, IN par_ccc2 varchar, IN par_ccc3 varchar, IN par_ccc4 varchar, IN par_ccc5 varchar, IN par_ccc6 varchar, INOUT par_phonetic_name character varying, INOUT par_chinese_name character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_ret_code INTEGER;
    var_unicode_char_1 VARCHAR(4);
    var_unicode_char_2 VARCHAR(4);
    var_unicode_char_3 VARCHAR(4);
    var_unicode_char_4 VARCHAR(4);
    var_unicode_char_5 VARCHAR(4);
    var_unicode_char_6 VARCHAR(4);
    var_phonetic_1 VARCHAR(12);
    var_phonetic_2 VARCHAR(12);
    var_phonetic_3 VARCHAR(12);
    var_phonetic_4 VARCHAR(12);
    var_phonetic_5 VARCHAR(12);
    var_phonetic_6 VARCHAR(12);
begin
	
    SELECT
        MAX(CASE WHEN idx = 1 THEN unicode_char END), MAX(CASE WHEN idx = 1 THEN phonetic_text END),
        MAX(CASE WHEN idx = 2 THEN unicode_char END), MAX(CASE WHEN idx = 2 THEN phonetic_text END),
        MAX(CASE WHEN idx = 3 THEN unicode_char END), MAX(CASE WHEN idx = 3 THEN phonetic_text END),
        MAX(CASE WHEN idx = 4 THEN unicode_char END), MAX(CASE WHEN idx = 4 THEN phonetic_text END),
        MAX(CASE WHEN idx = 5 THEN unicode_char END), MAX(CASE WHEN idx = 5 THEN phonetic_text END),
        MAX(CASE WHEN idx = 6 THEN unicode_char END), MAX(CASE WHEN idx = 6 THEN phonetic_text END)
    INTO var_unicode_char_1, var_phonetic_1,
         var_unicode_char_2, var_phonetic_2,
         var_unicode_char_3, var_phonetic_3,
         var_unicode_char_4, var_phonetic_4,
         var_unicode_char_5, var_phonetic_5,
         var_unicode_char_6, var_phonetic_6
    FROM (
        SELECT 1 AS idx, unicode_char, phonetic_text FROM ccc_unicode WHERE ccc_head = substring(par_ccc1, 1, 4) AND ccc_tail = substring(par_ccc1, 5, 1)
        UNION ALL
        SELECT 2, unicode_char, phonetic_text FROM ccc_unicode WHERE ccc_head = substring(par_ccc2, 1, 4) AND ccc_tail = substring(par_ccc2, 5, 1)
        UNION ALL
        SELECT 3, unicode_char, phonetic_text FROM ccc_unicode WHERE ccc_head = substring(par_ccc3, 1, 4) AND ccc_tail = substring(par_ccc3, 5, 1)
        UNION ALL
        SELECT 4, unicode_char, phonetic_text FROM ccc_unicode WHERE ccc_head = substring(par_ccc4, 1, 4) AND ccc_tail = substring(par_ccc4, 5, 1)
        UNION ALL
        SELECT 5, unicode_char, phonetic_text FROM ccc_unicode WHERE ccc_head = substring(par_ccc5, 1, 4) AND ccc_tail = substring(par_ccc5, 5, 1)
        UNION ALL
        SELECT 6, unicode_char, phonetic_text FROM ccc_unicode WHERE ccc_head = substring(par_ccc6, 1, 4) AND ccc_tail = substring(par_ccc6, 5, 1)
    ) t;

     par_phonetic_name := CONCAT_WS(', ',  
                          RTRIM(var_phonetic_1),  
                          CONCAT_WS(' ',
                              RTRIM(var_phonetic_2),
                              RTRIM(var_phonetic_3),
                              RTRIM(var_phonetic_4),
                              RTRIM(var_phonetic_5),
                              RTRIM(var_phonetic_6)
                          ));

    par_chinese_name := CONCAT(
                          COALESCE(var_unicode_char_1, '  '), 
                          COALESCE(var_unicode_char_2, '  '), 
                          COALESCE(var_unicode_char_3, '  '), 
                          COALESCE(var_unicode_char_4, '  '), 
                          COALESCE(var_unicode_char_5, '  '), 
                          COALESCE(var_unicode_char_6, '  '));

    IF par_chinese_name = REPEAT(' ', 12) THEN 
        par_chinese_name := NULL; 
    END IF;

    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "cpi_get_phonetic_chin_name" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

