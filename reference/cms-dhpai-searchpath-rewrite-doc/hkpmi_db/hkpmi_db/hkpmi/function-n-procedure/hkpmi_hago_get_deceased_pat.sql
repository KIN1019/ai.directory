-- DROP PROCEDURE hkpmi.hkpmi_hago_get_deceased_pat(inout int4, in timestamp, in timestamp, inout int4, inout varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_hago_get_deceased_pat(INOUT pas_return_code integer, IN par_start_date timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_end_date timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_return_code integer DEFAULT 0, INOUT par_return_message character varying DEFAULT NULL::character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_start_date TIMESTAMP WITHOUT TIME ZONE;
    var_end_date TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    /* Validation 1: date range should be within 100 days */
    IF DATE_PART('days', par_end_date::TIMESTAMP - par_start_date::TIMESTAMP) > 100 THEN
        BEGIN
            par_return_code := - 1;
            par_return_message := 'The date range exceeded 100 days';
            pas_return_code := par_return_code;
            RETURN;
        END;
    END IF;

    SELECT - 7 * INTERVAL '1 day' + par_start_date::TIMESTAMP
    INTO var_start_date;

    SELECT - 7 * INTERVAL '1 day' + par_end_date::TIMESTAMP
    INTO var_end_date;

    OPEN p_refcur FOR
    SELECT
        bcf.hkid
        FROM bcf_log AS bcf
        INNER JOIN patient AS p
            ON bcf.hkid = p.hkid::VARCHAR
        WHERE bcf.system_datetime >= var_start_date AND bcf.system_datetime < var_end_date AND p.death_indicator = 'ADT' AND p.death_date <= bcf.system_datetime
    UNION
    SELECT
        drl.hkid
        FROM death_reg_log AS drl
        INNER JOIN patient AS p
            ON drl.hkid = p.hkid::VARCHAR
        WHERE drl.system_datetime >= var_start_date AND drl.system_datetime < var_end_date AND p.death_indicator IS NOT NULL AND p.death_date <= drl.system_datetime;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_hago_get_deceased_pat" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

