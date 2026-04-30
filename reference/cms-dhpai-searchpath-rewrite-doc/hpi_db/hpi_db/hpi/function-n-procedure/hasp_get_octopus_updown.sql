-- DROP PROCEDURE hpi.hasp_get_octopus_updown(inout int4, in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_octopus_updown(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_from_date timestamp without time zone, IN par_to_date timestamp without time zone, IN par_sort_order character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    SELECT 1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
    INTO par_to_date;

    DROP TABLE IF EXISTS t$octopus_updown_display;
    CREATE TEMPORARY TABLE t$octopus_updown_display
    (
        workstation_id     VARCHAR(48),
        transaction_type   VARCHAR(4),
        system_datetime    TIMESTAMP WITHOUT TIME ZONE,
        update_by          VARCHAR(48),
        transaction_status VARCHAR(4)
    );

    IF par_sort_order = 'W' THEN
        INSERT INTO t$octopus_updown_display(workstation_id, transaction_type,
                                             system_datetime, update_by, transaction_status)
        SELECT workstation_id,
               transaction_type,
               system_datetime,
               update_by,
               transaction_status
        FROM octopus_updown
        WHERE hospital_code = par_hospital_code
          AND system_datetime >= par_from_date
          AND system_datetime < par_to_date
        ORDER BY workstation_id NULLS FIRST, system_datetime NULLS FIRST, transaction_type NULLS FIRST;
    ELSE
        INSERT INTO t$octopus_updown_display(workstation_id, transaction_type,
                                             system_datetime, update_by, transaction_status)
        SELECT workstation_id,
               transaction_type,
               system_datetime,
               update_by,
               transaction_status
        FROM octopus_updown
        WHERE hospital_code = par_hospital_code
          AND system_datetime >= par_from_date
          AND system_datetime < par_to_date
        ORDER BY transaction_type NULLS FIRST, workstation_id NULLS FIRST, system_datetime NULLS FIRST;
    END IF;

    IF par_sort_order = 'W' THEN
        OPEN p_refcur FOR SELECT *
                          FROM t$octopus_updown_display
                          ORDER BY workstation_id NULLS FIRST, system_datetime NULLS FIRST,
                                   transaction_type NULLS FIRST;
    ELSE
        OPEN p_refcur FOR SELECT *
                          FROM t$octopus_updown_display
                          ORDER BY transaction_type NULLS FIRST, workstation_id NULLS FIRST,
                                   system_datetime NULLS FIRST;
    END IF;

    pas_return_code := 0;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_octopus_updown" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
