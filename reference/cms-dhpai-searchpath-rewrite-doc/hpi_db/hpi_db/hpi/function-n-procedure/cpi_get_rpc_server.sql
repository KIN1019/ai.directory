-- DROP PROCEDURE cpi_get_rpc_server(inout int4, in varchar, inout varchar, in varchar);

CREATE OR REPLACE PROCEDURE cpi_get_rpc_server(INOUT pas_return_code integer, IN par_server_type character varying, INOUT par_rpc_server character varying, IN par_mode character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* ---'HKPMI_SERVER'/'HKPMI_READ_ONLY_SVR'/ */
DECLARE
    sql$rowcount BIGINT;
BEGIN
	BEGIN
	    SET search_path TO hpi, public;

		SELECT count(*) 
		INTO sql$rowcount 
		FROM hkpmi.hospital;

		IF sql$rowcount > 0 THEN
			par_rpc_server := 'true';
			pas_return_code := 0;
		ELSE
			SELECT NULL 
			INTO par_rpc_server;
			pas_return_code := - 1;
		END IF;

	EXCEPTION 
		WHEN OTHERS THEN
			RAISE EXCEPTION 'HKPMI server is not available !';
	END;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_get_rpc_server" OWNER TO "HPI_SCHEMA_OWNER_ROLE";