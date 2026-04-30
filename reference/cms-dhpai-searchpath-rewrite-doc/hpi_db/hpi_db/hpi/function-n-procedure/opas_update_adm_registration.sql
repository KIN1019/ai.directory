-- DROP PROCEDURE hpi.opas_update_adm_registration(inout int4, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE opas_update_adm_registration(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_admission_datetime timestamp without time zone, IN par_source_indicator character varying, IN par_source_code character varying, IN par_patient_type character varying, IN par_discharge_code character varying, IN par_discharge_datetime timestamp without time zone, IN par_destination_code character varying, IN par_ambulance_no character varying, IN par_police_case character varying, IN par_labour_case character varying, IN par_ae_case_type character varying, IN par_dba_flag character varying, IN par_follow_up_datetime timestamp without time zone, IN par_ward_code character varying, IN par_ward_class character varying, IN par_bed_no character varying, IN par_specialty_code character varying, IN par_sub_specialty character varying, IN par_pp_code character varying, IN par_case_type character varying, IN par_txn_type character varying, IN par_update_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_eh_code character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration */
/* 2004-12-07 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number */

/* ***** Object:  Stored Procedure opas_update_adm_registration    Script Date: 11/10/96 15:36:01 ***** */
/* 2004-12-07 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number - Start */
/* 2004-12-07 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number - End */
DECLARE
    var_return_code INTEGER;
   

begin
	
    
   
                 
    CALL cpi_update_adm_registration( var_return_code,par_hospital_code, par_case_no, par_hkid, par_admission_datetime, par_source_indicator, par_source_code, par_patient_type, par_discharge_code, par_discharge_datetime, par_destination_code, par_ambulance_no, par_police_case, par_labour_case, par_ae_case_type, par_dba_flag, par_follow_up_datetime, par_ward_code, par_ward_class, par_bed_no, par_specialty_code, par_sub_specialty, par_pp_code, par_case_type, par_txn_type, par_update_type, par_transaction_datetime, par_update_by, par_source_system,
    /* 2004-12-07 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number - Start */
        par_document_flag, par_eh_code);
   
    /* 2004-12-07 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number - End */
    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "opas_update_adm_registration" OWNER TO "HPI_SCHEMA_OWNER_ROLE";