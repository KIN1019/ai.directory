-- DROP PROCEDURE hpi.hasp_update_octopus_updown(inout int4, in varchar, in varchar, inout timestamp, in varchar, in varchar, in varchar, in int4, in varchar, in varchar, inout int4);

CREATE OR REPLACE PROCEDURE hpi.hasp_update_octopus_updown(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_workstation_id character varying, INOUT par_system_datetime timestamp without time zone, IN par_transaction_type character varying, IN par_update_by character varying, IN par_transaction_status character varying, IN par_file_size integer, IN par_file_name character varying, IN par_update_type character varying, INOUT par_return_code integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    CALL cpi_update_octopus_updown(pas_return_code, par_hospital_code, par_workstation_id, par_system_datetime,
                                   par_transaction_type,
                                   par_update_by, par_transaction_status, par_file_size, par_file_name, par_update_type,
                                   par_return_code);
    pas_return_code := par_return_code;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_update_octopus_updown" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
