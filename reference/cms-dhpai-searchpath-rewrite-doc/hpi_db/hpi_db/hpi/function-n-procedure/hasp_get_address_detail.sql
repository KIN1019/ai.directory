-- DROP PROCEDURE hpi.hasp_get_address_detail(inout int4, in int4, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hasp_get_address_detail(INOUT pas_return_code integer, IN par_record_id integer, INOUT par_address_eng character varying, INOUT par_address_chi character varying, INOUT par_district_code character varying, INOUT par_eh_eng character varying, INOUT par_eh_chi character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
CALL cpi_get_address_detail(pas_return_code, par_record_id, par_address_eng, par_address_chi, par_district_code, par_eh_eng, par_eh_chi);
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_address_detail" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
