-- DROP PROCEDURE cpi_update_octopus_updown(inout int4, in varchar, in varchar, inout timestamp, in varchar, in varchar, in varchar, in int4, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE cpi_update_octopus_updown(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_workstation_id character varying, INOUT par_system_datetime timestamp without time zone, IN par_transaction_type character varying, IN par_update_by character varying, IN par_transaction_status character varying, IN par_file_size integer, IN par_file_name character varying, IN par_update_type character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_success_flag VARCHAR(1) := 'Y';
BEGIN
    par_system_datetime := NULL;
    pas_return_code := 0;

    <<cpi_update_octopus_updown>>
    BEGIN
        IF par_update_type = 'I' THEN
	        RAISE NOTICE 'will do insert';
            par_system_datetime := timestamp_convert(localtimestamp);
            INSERT INTO cpi_octopus_updown
            (hospital_code, workstation_id, system_datetime, update_by,
             transaction_type, transaction_status, file_size, file_name)
            VALUES (par_hospital_code, par_workstation_id, par_system_datetime, par_update_by,
                    par_transaction_type, par_transaction_status, par_file_size, par_file_name);
        ELSE
        	RAISE NOTICE 'will do update';
            UPDATE cpi_octopus_updown
            SET transaction_status = par_transaction_status,
                file_size          = par_file_size,
                file_name          = par_file_name,
                update_by          = par_update_by
            WHERE hospital_code = par_hospital_code
              AND workstation_id = par_workstation_id
              AND transaction_type = par_transaction_type
              AND system_datetime = par_system_datetime;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            var_success_flag := 'N';
            pas_return_code := -1;
            RAISE EXCEPTION 'call cpi_update_octopus_updown failed,msg => [%]',SQLERRM;
    END;

    IF var_success_flag = 'Y' THEN
        pas_return_code := 0;
    END IF;
	RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_update_octopus_updown" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
