-- DROP PROCEDURE hpi.opas_discharge(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE opas_discharge(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_discharge_code character varying, IN par_discharge_datetime timestamp without time zone, IN par_destination_code character varying, IN par_ward_code character varying, IN par_ward_class character varying, IN par_bed_no character varying, IN par_specialty_code character varying, IN par_sub_specialty character varying, IN par_doctor_code character varying, IN par_case_type character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_mrt_indicator character varying DEFAULT ''::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration */
/* ***** Object:  Stored Procedure opas_discharge    Script Date: 11/10/96 15:32:59 ***** */
DECLARE
    var_return_code INTEGER;
    var_same_server INTEGER;
    var_opas_db VARCHAR(30);

begin
	 
	set search_path TO hpi,public;

    /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
    /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End */
    /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
    SELECT
        CASE
            WHEN hospital_code IN ('QMH', 'UCH') THEN 'opsystem'
            ELSE CONCAT(RTRIM(LOWER(hospital_code)), 'opas_db')
        END
        INTO var_opas_db
        FROM hospital;
    /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End */
    /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End */
    SELECT  count(*) into var_same_server FROM pg_database where datname = var_opas_db;
    IF var_same_server = 0 then
        begin
            CALL cpi_discharge(var_return_code, par_hospital_code, par_case_no, par_hkid, par_discharge_code, par_discharge_datetime, par_destination_code, par_ward_code, par_ward_class, par_bed_no, par_specialty_code, par_sub_specialty, par_doctor_code, par_case_type, par_txn_type, par_transaction_datetime, par_update_by, par_source_system, par_mrt_indicator);

            IF var_return_code != 0 THEN
                begin
	                raise  notice  'cpi_discharge var_return_code:%', var_return_code; 
                END;
            END IF;
        END;
    else
	    CALL cpi_discharge( var_return_code, par_hospital_code, par_case_no, par_hkid, par_discharge_code, par_discharge_datetime, par_destination_code, par_ward_code, par_ward_class, par_bed_no, par_specialty_code, par_sub_specialty, par_doctor_code, par_case_type, par_txn_type, par_transaction_datetime, par_update_by, par_source_system, par_mrt_indicator);
   END IF;

    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "opas_discharge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
