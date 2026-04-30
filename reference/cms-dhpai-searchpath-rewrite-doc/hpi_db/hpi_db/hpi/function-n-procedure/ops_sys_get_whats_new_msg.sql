-- DROP FUNCTION ops_sys_get_whats_new_msg(varchar, varchar);

CREATE OR REPLACE FUNCTION ops_sys_get_whats_new_msg(par_hospital character varying, par_message_id character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur REFCURSOR;
BEGIN

    DROP TABLE IF EXISTS t$temp_message;
    CREATE TEMPORARY TABLE t$temp_message (
        hospital           VARCHAR(3),
        message_id         VARCHAR(10),
        message_start_date TIMESTAMP WITHOUT TIME ZONE,
        message_header     VARCHAR(100),
        message_content_1  VARCHAR(255) NULL,
        message_content_2  VARCHAR(255) NULL,
        message_content_3  VARCHAR(255) NULL,
        message_content_4  VARCHAR(255) NULL
    );

    INSERT INTO t$temp_message
    SELECT a.hospital, a.message_id, a.message_start_date, a.message_header, b.message_content, NULL, NULL, NULL
    FROM
        ipas_whats_new_message AS a,
        ipas_whats_new_message_dtl AS b
    WHERE
        a.hospital = par_hospital AND a.message_id = par_message_id AND b.hospital = a.hospital
                                  AND b.message_id = a.message_id AND b.message_line = 1;

    UPDATE t$temp_message
    SET message_content_2 = b.message_content
    FROM
        ipas_whats_new_message_dtl AS b
    WHERE b.hospital = t$temp_message.hospital AND b.message_id = t$temp_message.message_id AND b.message_line = 2;

    UPDATE t$temp_message
    SET message_content_3 = b.message_content
    FROM
        ipas_whats_new_message_dtl AS b
    WHERE b.hospital = t$temp_message.hospital AND b.message_id = t$temp_message.message_id AND b.message_line = 3;

    UPDATE t$temp_message
    SET message_content_4 = b.message_content
    FROM
        ipas_whats_new_message_dtl AS b
    WHERE b.hospital = t$temp_message.hospital AND b.message_id = t$temp_message.message_id AND b.message_line = 4;

    OPEN p_refcur FOR
        SELECT hospital, message_id, message_start_date, message_header, message_content_1, message_content_2,
               message_content_3, message_content_4
        FROM
            t$temp_message;
    RETURN NEXT p_refcur;

END;
$function$
;

;ALTER FUNCTION "ops_sys_get_whats_new_msg" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
