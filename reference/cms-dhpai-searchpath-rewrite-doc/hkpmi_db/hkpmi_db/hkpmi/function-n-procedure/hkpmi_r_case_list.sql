-- DROP FUNCTION hkpmi.hkpmi_r_case_list(bpchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_r_case_list(par_hkid varchar)
 RETURNS TABLE(hospital_code character varying, case_no character varying, adt1 text, adt2 text, 
 adt3 text, adt4 text, destination_code character varying, last_specialty_code character varying, last_ward_code character varying)
 LANGUAGE plpgsql
AS $function$

begin
	SET search_path TO hkpmi, public;

   
	return QUERY SELECT
        pmi_case.hospital_code, pmi_case.case_no,
		 to_char(adm_dtm,'YYYYMMDD') as adt1,to_char(adm_dtm,'HH24mi') as adt2,
		 to_char(discharge_dtm,'YYYYMMDD') as adt3,to_char(discharge_dtm,'HH24mi') as adt4,
		pmi_case.destination_code, pmi_case.last_specialty_code, pmi_case.last_ward_code
        FROM pmi_case, patient
        WHERE patient.hkid = par_hkid AND pmi_case.patient_key = patient.patient_key;
    /* --					discharge_code is not null */
    /*
    union
    		select hospital_code, case_no,
                 convert(char(8), adm_dtm, 112),
                 substring(convert(char(5),adm_dtm,108),1,2) +
                   right(convert(char(5),adm_dtm,108),2),
    				 null, null, null, null, null
             from pmi_case, patient
                where patient.hkid = @hkid and
                   pmi_case.patient_key = patient.patient_key and
    					discharge_code is null
    */


END;
$function$
;

ALTER FUNCTION "hkpmi_r_case_list" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

