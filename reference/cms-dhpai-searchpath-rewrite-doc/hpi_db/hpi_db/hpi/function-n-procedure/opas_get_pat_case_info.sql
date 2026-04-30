CREATE OR REPLACE PROCEDURE opas_get_pat_case_info(INOUT pas_return_code int,IN par_hospital VARCHAR, IN par_patient_key VARCHAR, IN par_opcode VARCHAR, IN par_show_output VARCHAR DEFAULT 'N', INOUT par_case_no VARCHAR DEFAULT NULL, INOUT par_specialty VARCHAR DEFAULT NULL, INOUT par_sub_specialty VARCHAR DEFAULT NULL)
AS 
$BODY$
/* 2001-08-08 : HK Fong : to obtain the patient case no., speicalty, sub_specialty */
/* by inputing the patient_no and OPCODE */
DECLARE
    sql$rowcount BIGINT;
begin
	SET search_path TO hpi, public; 
    SELECT
        case_no, last_specialty, COALESCE(last_sub_specialty, '')
        INTO par_case_no, par_specialty, par_sub_specialty
        FROM cpi_case
        WHERE patient_key = par_patient_key AND case_no LIKE CONCAT(par_opcode, '%') AND hospital_code = par_hospital AND status_code = 'AC' AND discharge_dtm IS NULL;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount = 0 THEN
        SELECT
            '', '', ''
            INTO par_case_no, par_specialty, par_sub_specialty;
    END IF;

--    IF par_show_output = 'Y' THEN
--        OPEN p_refcur FOR
--        SELECT
--            par_case_no, par_specialty, par_sub_specialty;
--    END IF;
    pas_return_code := 0;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;


;ALTER PROCEDURE "opas_get_pat_case_info" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
