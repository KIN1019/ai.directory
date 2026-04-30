-- DROP PROCEDURE hpi.opas_patient_upd_access(inout int4, in varchar, in varchar, in varchar, in int4, in timestamp, in varchar, in varchar, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE opas_patient_upd_access(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_patient_key character varying, IN par_access_code integer, IN par_transaction_datetime timestamp without time zone, IN par_update_hospital character varying, IN par_update_by character varying, IN par_last_update_datetime timestamp without time zone, IN par_source_system character varying)
 LANGUAGE plpgsql
AS $procedure$
/* 2011-05-25 - jw - Fix opas database name to adapt Testing environment */
/* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration */
DECLARE
    var_return_code INTEGER;
  
   
BEGIN

  	CALL cpi_patient_upd_access(var_return_code, par_hospital_code, par_hkid, par_patient_key, par_access_code, par_transaction_datetime, par_update_hospital, par_update_by, par_last_update_datetime, par_source_system);

    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "opas_patient_upd_access" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
