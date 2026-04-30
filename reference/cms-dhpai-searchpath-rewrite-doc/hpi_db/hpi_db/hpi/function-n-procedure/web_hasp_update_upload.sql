-- DROP PROCEDURE hpi.web_hasp_update_upload(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_update_upload(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_upload_action character varying, IN par_hkid character varying, IN par_case_no character varying, IN par_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_retcode INTEGER;
    var_rowcount INTEGER;
    var_error_msg VARCHAR(255);
    var_selected_error_msg VARCHAR(255);
    sql$rowcount BIGINT;
BEGIN
    <<error>>
    BEGIN
        IF par_upload_action NOT IN ('D', 'U') THEN
            BEGIN
                var_retcode := 29999;
                var_error_msg := 'Invalid update type';
                EXIT error;
            END;
        END IF;
        /* Get the uploaded record */
        IF NOT EXISTS (SELECT
            *
            FROM Upload
            WHERE Case_no = par_case_no AND HKID = par_hkid AND Hospital_code = par_hosp_code) THEN
            BEGIN
                var_retcode := 29999;
                var_error_msg := 'Uploaded registration record cannot be found';
                EXIT error;
            END;
        END IF;
        /* End - Get the uploaded record */
        /* Open transaction */
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
        		begin transaction
        */
        IF par_upload_action = 'D' THEN
            BEGIN
                DELETE FROM Upload
                    WHERE Case_no = par_case_no AND HKID = par_hkid AND Hospital_code = par_hosp_code;
            END;
        ELSE
            IF par_upload_action = 'U' THEN
                BEGIN
                    UPDATE Upload
                    SET Message = par_message
                        WHERE Case_no = par_case_no AND HKID = par_hkid AND Hospital_code = par_hosp_code;
                END;
            END IF;
        END IF;
        COMMIT;
        pas_return_code := 0;
        RETURN;
    END;
    /*
    [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
    if @@trancount > 0
    		rollback transaction
    */
    /* Find the error message by error code */
    IF var_retcode != 29999 THEN
        BEGIN
            SELECT
                messages
                INTO var_selected_error_msg
                FROM error_msgs
                WHERE error_code = var_retcode;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 1 THEN
                var_error_msg := var_selected_error_msg;
            ELSE
                BEGIN
                    IF var_error_msg IS NULL OR LENGTH(var_error_msg) = 0 THEN
                        var_error_msg := CONCAT('Call cpi function failed with return code ',
                        CASE CAST (var_retcode AS VARCHAR(8))
                            WHEN '' THEN ' '
                            ELSE CAST (var_retcode AS VARCHAR(8))
                        END);
                    END IF;
                END;
            END IF;
        END;
    END IF;
    /* End - Find the error message by error code */
    var_retcode := 29999;
    RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := var_retcode;
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "web_hasp_update_upload" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
