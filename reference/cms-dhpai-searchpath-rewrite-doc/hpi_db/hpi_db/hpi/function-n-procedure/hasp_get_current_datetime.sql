-- DROP PROCEDURE hpi.hasp_get_current_datetime(inout int4, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_current_datetime(INOUT pas_return_code integer, INOUT p_refcur refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* @cur_datetime              datetime output */
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
BEGIN
    OPEN p_refcur FOR
    SELECT
        timestamp_convert(localtimestamp);

    <<normal_end>>
    BEGIN
        pas_return_code := 0;
        RETURN;
	END;
    <<abnormal_end>>
    BEGIN
        pas_return_code := var_error;
        RETURN;
    END;
    
END;
$procedure$
;
