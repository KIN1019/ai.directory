CREATE OR REPLACE PROCEDURE hasp_insert_octopus_record(INOUT pas_return_code INTEGER, IN par_hospital_code VARCHAR, IN par_system_datetime TIMESTAMP WITHOUT TIME ZONE, IN par_workstation_id VARCHAR, IN par_update_by VARCHAR, IN par_transaction_data BYTEA, IN par_upload_ind VARCHAR, IN par_file_name VARCHAR, IN par_file_size INTEGER, IN par_upload_datetime TIMESTAMP WITHOUT TIME ZONE, INOUT par_retcode INTEGER, INOUT par_retMsg VARCHAR)
AS 
$procedure$
BEGIN
    <<end_exit>>
    BEGIN
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
        	begin
        		begin transaction
            end
        */
        CALL cpi_insert_octopus_record(par_retcode, par_hospital_code, par_system_datetime, par_workstation_id, par_update_by, par_transaction_data, par_upload_ind, par_file_name, par_upload_datetime, par_retcode);

        IF par_retcode = 0 THEN
            BEGIN
                /* exec hasp_update_octopus_updown */
                CALL cpi_update_octopus_updown(par_retcode, par_hospital_code, par_workstation_id, par_system_datetime, 'U', /* --@transaction_type, */ par_update_by, 'Y', /* --@transaction_status, */ par_file_size, par_file_name, 'U', /* --@update_type, */ par_retcode);

                IF par_retcode <> 0 THEN
                    BEGIN
                        SELECT
                            'Return code from backend is not zero'
                            INTO par_retMsg;
                        EXIT end_exit;
                    END;
                END IF;
            END;
        ELSE
            EXIT end_exit;
        END IF;
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount > 0
        	begin
        		commit transaction
            end
        */
        pas_return_code := par_retcode;
        RETURN;
    END;
    /*
    [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
    if @@trancount > 0
    	begin
    		rollback transaction
    	end
    */
    pas_return_code := par_retcode;
    RETURN;
END;
$procedure$
LANGUAGE plpgsql;