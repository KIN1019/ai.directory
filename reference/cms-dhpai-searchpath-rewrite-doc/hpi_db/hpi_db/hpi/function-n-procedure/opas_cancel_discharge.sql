-- DROP PROCEDURE hpi.opas_cancel_discharge(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.opas_cancel_discharge(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_ward_code character varying, IN par_ward_class character varying, IN par_bed_no character varying, IN par_specialty_code character varying, IN par_sub_specialty character varying, IN par_doctor_code character varying, IN par_case_type character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying)
 LANGUAGE plpgsql
AS $procedure$
/* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration */
/* ***** Object:  Stored Procedure opas_cancel_discharge    Script Date: 11/10/96 15:32:08 ***** */
DECLARE
    var_return_code INTEGER;
begin
  
    CALL cpi_cancel_discharge( var_return_code, par_hospital_code, par_case_no, par_hkid, par_ward_code, par_ward_class, par_bed_no, par_specialty_code, par_sub_specialty, par_doctor_code, par_case_type, par_txn_type, par_transaction_datetime, par_update_by, par_source_system);
  

    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;



;ALTER PROCEDURE "opas_cancel_discharge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";