-- DROP PROCEDURE hkpmi_get_datetime(inout int4, inout timestamp);

CREATE OR REPLACE PROCEDURE hkpmi_get_datetime(INOUT pas_return_code integer, INOUT par_ret_datetime timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    SELECT
        timestamp_convert(localtimestamp), 0
        INTO par_ret_datetime, pas_return_code;
	return; 
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_get_datetime" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

