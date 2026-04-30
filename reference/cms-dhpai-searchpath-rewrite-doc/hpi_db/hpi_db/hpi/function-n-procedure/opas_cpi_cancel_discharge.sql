-- DROP FUNCTION hpi.opas_cpi_cancel_discharge(varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, timestamp, varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.opas_cpi_cancel_discharge(par_hospital_code character varying, par_case_no character varying, par_hkid character varying, par_ward_code character varying, par_ward_class character varying, par_bed_no character varying, par_specialty_code character varying, par_sub_specialty character varying, par_doctor_code character varying, par_case_type character varying, par_txn_type character varying, par_transaction_datetime timestamp without time zone, par_update_by character varying, par_source_system character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/* 2011-05-25 - jw - Fix opas database name to adapt Testing environment */
/* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration */
/* 2007-10-17 Shelley SMR20016548 Change From RPC to DC */
DECLARE
    var_return_code INTEGER;
    var_return_message VARCHAR(255);
   	p_refcur refcursor;
begin
	
   
    SELECT
        LTRIM(RTRIM(par_ward_code))
        INTO par_ward_code;
    SELECT
        LTRIM(RTRIM(par_ward_class))
        INTO par_ward_class;
    SELECT
        LTRIM(RTRIM(par_bed_no))
        INTO par_bed_no;
    SELECT
        LTRIM(RTRIM(par_sub_specialty))
        INTO par_sub_specialty;
    SELECT
        LTRIM(RTRIM(par_doctor_code))
        INTO par_doctor_code;

    
   	CALL cpi_cancel_discharge(var_return_code, par_hospital_code, par_case_no, par_hkid, par_ward_code, par_ward_class, par_bed_no, par_specialty_code, par_sub_specialty, par_doctor_code, par_case_type, par_txn_type, par_transaction_datetime, par_update_by, par_source_system);
   

    IF var_return_code = 0 THEN
        BEGIN
            SELECT
                ''
                INTO var_return_message;
        END;
    ELSE
        BEGIN
            SELECT
                CONCAT(messages, ' - CPI Error!')
                INTO var_return_message
                FROM error_msgs
                WHERE error_code = var_return_code;
        END;
    END IF;
    OPEN p_refcur FOR
    SELECT
        var_return_code, var_return_message;
END;
$function$
;


;ALTER FUNCTION "opas_cpi_cancel_discharge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";