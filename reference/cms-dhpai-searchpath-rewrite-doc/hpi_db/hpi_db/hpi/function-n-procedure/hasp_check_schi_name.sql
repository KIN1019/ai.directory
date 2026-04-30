-- DROP PROCEDURE hpi.hasp_check_schi_name(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_check_schi_name(INOUT pas_return_code integer, IN par_ccc1 character varying, IN par_ccc2 character varying, IN par_ccc3 character varying, IN par_ccc4 character varying, IN par_ccc5 character varying, IN par_ccc6 character varying, INOUT par_is_schi_name character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    CALL cpi_check_schi_name(pas_return_code=>pas_return_code,par_ccc1 => par_ccc1,
                                          par_ccc2 => par_ccc2,
                                          par_ccc3 => par_ccc3,
                                          par_ccc4 => par_ccc4,
                                          par_ccc5 => par_ccc5,
                                          par_ccc6 => par_ccc6,
                                          par_is_schi_name => par_is_schi_name);
END;
$procedure$
;


;ALTER PROCEDURE "hasp_check_schi_name" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
