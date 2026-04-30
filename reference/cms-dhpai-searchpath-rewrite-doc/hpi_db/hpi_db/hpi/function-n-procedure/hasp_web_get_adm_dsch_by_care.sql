-- DROP PROCEDURE hpi.hasp_web_get_adm_dsch_by_care(inout int4, in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_web_get_adm_dsch_by_care(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_from_date timestamp without time zone, IN par_to_date timestamp without time zone, IN par_care_category character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    report_server VARCHAR(48);
    prog_name     VARCHAR(80) := 'hasp_web_adds_by_care_report';
    db_name       VARCHAR(48);
BEGIN

	par_care_category := safe_substring(par_care_category,1,4);

    SELECT text_value
    INTO report_server
    FROM hospital_control
    WHERE type = 'REPORT_SERVER_NAME'
      AND hospital_code = par_hospital_code;

    IF report_server IS NOT NULL THEN
        db_name := LOWER(TRIM(par_hospital_code)) || 'hpi_db';

        PERFORM DBLINK_EXEC(
                'dbname=' || db_name || ' host=' || report_server,
                'SELECT ' || prog_name || '(' ||
                QUOTE_LITERAL(par_hospital_code) || ', ' ||
                QUOTE_LITERAL(par_from_date) || ', ' ||
                QUOTE_LITERAL(par_to_date) || ', ' ||
                QUOTE_LITERAL(par_care_category) || ')'
                );
    ELSE
        CALL hasp_web_adds_by_care_report(par_hospital_code, par_from_date, par_to_date, par_care_category, p_refcur);
    END IF;
    pas_return_code := 0;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_web_get_adm_dsch_by_care" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
