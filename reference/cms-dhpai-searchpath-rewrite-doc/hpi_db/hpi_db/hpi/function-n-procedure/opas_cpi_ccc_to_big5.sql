-- DROP PROCEDURE hpi.opas_cpi_ccc_to_big5(inout int4, in bpchar, inout bpchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.opas_cpi_ccc_to_big5(INOUT pas_return_code integer, IN par_ccc character, INOUT par_big5 character, INOUT par_return_code integer, INOUT par_return_msg character varying)
 LANGUAGE plpgsql
AS $procedure$
/* 2008-05-05 Shelley SMR20017336 Get the Big5 from CCCode */
DECLARE
    sql$rowcount BIGINT;
BEGIN
    SELECT
        0
        INTO par_return_code;

    IF par_ccc IS NULL THEN
        SELECT
            ''
            INTO par_ccc;
    ELSE
        SELECT
            RTRIM(par_ccc)
            INTO par_ccc;
    END IF;

    IF COALESCE(par_ccc, '') = '' THEN
        SELECT
            '  '
            INTO par_big5;
    ELSE
        IF (par_ccc NOT SIMILAR TO '[A-Z0-9][0-9][0-9][0-9][0-9S]') THEN
            BEGIN
                SELECT
                    99999, CONCAT('Invalid CCCode: ', par_ccc)
                    INTO par_return_code, par_return_msg;
            END;
        ELSE
            BEGIN
                SELECT
                    big5
                    INTO par_big5
                    FROM ccc_big5
                    WHERE CONCAT(ccc_head, ccc_tail) = par_ccc;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF (sql$rowcount = 0) OR (par_big5 IS NULL) OR (par_big5 = '') THEN
                    SELECT
                        '  '
                        INTO par_big5;
                END IF;
            END;
        END IF;
    END IF;
END;
$procedure$
;
