-- DROP PROCEDURE hpi.opas_merge_hkid(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE opas_merge_hkid(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_from_hkid character varying, IN par_to_hkid character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying)
 LANGUAGE plpgsql
AS $procedure$
/* ***** Object:  Stored Procedure dbo.opas_merge_hkid    Script Date: 11/10/96 15:35:00 ***** */
DECLARE
    var_return_code INTEGER;
    var_same_server INTEGER;
BEGIN
    

	CALL cpi_patient_merge(var_return_code, par_from_hkid, par_to_hkid, par_update_by, par_source_system, par_transaction_datetime, par_hospital_code, par_txn_type, null::varchar);

    IF var_return_code <> 0 THEN
        RAISE EXCEPTION 'cpi_patient_merge return_code is not 0';
    END IF;
  
    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "opas_merge_hkid" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
