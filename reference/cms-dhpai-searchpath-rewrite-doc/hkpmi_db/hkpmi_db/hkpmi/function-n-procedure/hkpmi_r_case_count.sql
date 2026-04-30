CREATE OR REPLACE PROCEDURE hkpmi_r_case_count(INOUT pas_return_code integer, IN par_hkid character, INOUT par_case_out integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    /* --select hospital_code, case_no, */
    /* --		 	 convert(char(8), adm_dtm, 112), */
    /* --		  	 substring(convert(char(5),adm_dtm,108),1,2) + */
    /* --			   right(convert(char(5),adm_dtm,108),2), */
    /* --		 	 convert(char(8), discharge_dtm, 112), */
    /* --			 substring(convert(char(5),discharge_dtm,108),1,2) + */
    /* --				right(convert(char(5),discharge_dtm,108),2), */
    /* --		 	 destination_code, last_specialty_code, last_ward_code */
	SET search_path TO hkpmi, public; 
    SELECT
        COUNT(*)
        INTO par_case_out
        FROM pmi_case, patient
        WHERE patient.hkid = par_hkid AND pmi_case.patient_key = patient.patient_key;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_r_case_count" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

