-- DROP PROCEDURE hpi.opas_move_episodes(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.opas_move_episodes(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_patient_key character varying, IN par_new_hkid character varying, IN par_new_patient_key character varying, IN par_case_type character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_move_episode_status character varying DEFAULT NULL::character varying, IN par_info_source_code character varying DEFAULT NULL::character varying, IN par_reason_code character varying DEFAULT NULL::character varying, IN par_other_reason character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration */
/* 20130927 Ricky enhancement on @move_episode_status Same(S) or Different (O) - type 040 */
/* 20140404 Yorky add move episode info_source_code, reason_code and other_reason input parameters */
/* ***** Object:  Stored Procedure opas_move_episodes    Script Date: 11/10/96 15:35:00 ***** */
DECLARE
    var_return_code INTEGER;
  
    
begin
	
 

    CALL cpi_move_episodes( var_return_code,par_hospital_code, par_case_no, par_hkid, par_patient_key, par_new_hkid, par_new_patient_key, par_case_type, par_txn_type, par_transaction_datetime, par_update_by, par_source_system, par_move_episode_status,
    /* 20140404 Yorky add move episode info_source_code, reason_code and other_reason input parameters - Start */
        par_info_source_code, par_reason_code, par_other_reason);
 
    /* 20140404 Yorky add move episode info_source_code, reason_code and other_reason input parameters - End */
    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "opas_move_episodes" OWNER TO "HPI_SCHEMA_OWNER_ROLE";