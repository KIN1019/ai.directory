-- DROP PROCEDURE hpi.get_hago_close_reason_list(inout int4, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.get_hago_close_reason_list(INOUT pas_return_code integer, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
BEGIN

OPEN p_refcur FOR

SELECT reason_code,
       hago_close_reason_code,
       reason_description,
       input_remark,
       patient_type,
       status,
       order_no
FROM hago_close_reason_list
ORDER BY patient_type NULLS FIRST, status NULLS FIRST, order_no NULLS FIRST;

END;
$procedure$;

;ALTER PROCEDURE "get_hago_close_reason_list" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
