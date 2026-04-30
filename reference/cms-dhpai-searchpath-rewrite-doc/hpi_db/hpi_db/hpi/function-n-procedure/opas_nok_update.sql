-- DROP PROCEDURE hpi.opas_nok_update(inout int4, in varchar, in varchar, inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE opas_nok_update(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_patient_key character varying, INOUT par_priority integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_home_phone character varying, IN par_nok_other_phone_no_1 character varying, IN par_nok_other_phone_ext_1 character varying, IN par_nok_other_phone_no_2 character varying, IN par_nok_other_phone_ext_2 character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying)
 LANGUAGE plpgsql
AS $procedure$
/* 2011-05-25 - jw - Fix opas database name to adapt Testing environment */
/* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration */
/* ***** Object:  Stored Procedure dbo.opas_nok_update    Script Date: 11/10/96 15:35:16 ***** */
DECLARE
    var_return_code INTEGER;
 
    
BEGIN

    CALL cpi_nok_update(var_return_code, par_hospital_code, par_patient_key, par_priority, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_home_phone, par_nok_other_phone_no_1, par_nok_other_phone_ext_1, par_nok_other_phone_no_2, par_nok_other_phone_ext_2, par_txn_type, par_transaction_datetime, par_update_by, par_source_system);
  
    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "opas_nok_update" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
