-- DROP PROCEDURE hpi.cpi_insert_octopus_record(inout int4, in varchar, in timestamp, in varchar, in varchar, in bytea, in varchar, in varchar, in timestamp, inout int4);

CREATE OR REPLACE PROCEDURE hpi.cpi_insert_octopus_record(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_system_datetime timestamp without time zone, IN par_workstation_id character varying, IN par_update_by character varying, IN par_transaction_data bytea, IN par_upload_ind character varying, IN par_file_name character varying, IN par_upload_datetime timestamp without time zone, INOUT par_return_code integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_success_flag VARCHAR(1);
/*
[9996 - Severity CRITICAL - Transformer error occurred in beginEndBlock. Please submit report to developers.]
begin

	declare @success_flag char(1)
	select @success_flag = 'Y'

	if @@trancount = 0
	begin
		select @success_flag = 'N'
		select @return_code = -1
		goto return_error
	end

	save tran cpi_insert_octopus_record

	insert cpi_octopus_record (	hospital_code, system_datetime, workstation_id, update_by,
								transaction_data, upload_ind, file_name, upload_datetime)
	values (@hospital_code, @system_datetime, @workstation_id, @update_by,
			@transaction_data, @upload_ind, @file_name, @upload_datetime)
	if @@rowcount = 0 or @@error <> 0
	begin
		select @return_code = -2
		select @success_flag = 'N'
		goto return_error
	end

return_error:
	if @success_flag = 'N'
		rollback cpi_insert_octopus_record

	return @return_code

end
*/
BEGIN
	<<return_error>>
	BEGIN
		INSERT INTO cpi_octopus_record (hospital_code, system_datetime, workstation_id, update_by, transaction_data, upload_ind, file_name, upload_datetime)
		VALUES (par_hospital_code, par_system_datetime, par_workstation_id, par_update_by, par_transaction_data, par_upload_ind, par_file_name, par_upload_datetime);
		EXCEPTION
			WHEN others THEN
				BEGIN
					SELECT
						'N'
						INTO var_success_flag;
					SELECT
						- 1
						INTO par_return_code;
					raise exception '';
				END;
	END;
	pas_return_code := 0;
	RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "cpi_insert_octopus_record" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
