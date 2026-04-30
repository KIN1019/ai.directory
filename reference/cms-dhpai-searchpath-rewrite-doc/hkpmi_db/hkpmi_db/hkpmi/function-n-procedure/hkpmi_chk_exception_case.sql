-- DROP PROCEDURE hkpmi.hkpmi_chk_exception_case(inout int4, in bpchar, in bpchar, inout bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_chk_exception_case(INOUT pas_return_code integer, IN par_hospital_cde VARCHAR, IN par_case_no VARCHAR, INOUT par_exception_flag VARCHAR)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_exception_flag VARCHAR(2);
BEGIN
    SELECT
        'N'
        INTO par_exception_flag;
    /*
    if exists (select 1 from hkpmi_chk_case_exception_list
        where case_hosp_code = @hospital_cde
        and   case_no        = @case_no
    	)
    begin
    	select @exception_flag = 'Y'
    end
    */
    SELECT
        exception_flag
        INTO var_exception_flag
        FROM (SELECT
            exception_flag, case_hosp_code, case_no, exception_eff_dtm
            FROM hkpmi_chk_case_exception_list) AS ungrouped_query
        INNER JOIN (SELECT
            case_hosp_code, case_no, MAX(exception_eff_dtm) AS max_1
            FROM hkpmi_chk_case_exception_list
            WHERE case_hosp_code = par_hospital_cde AND case_no = par_case_no AND exception_type = 'DOB' AND /* ---For DOB<adm_dtm exception type */ exception_eff_dtm < localtimestamp
            GROUP BY case_hosp_code, case_no) AS grouped_query
            ON (ungrouped_query.case_hosp_code = grouped_query.case_hosp_code OR (ungrouped_query.case_hosp_code IS NULL AND grouped_query.case_hosp_code IS NULL))
        /* --- check with the eff dtm */
        WHERE exception_eff_dtm = max_1;

    IF FOUND THEN
        SELECT var_exception_flag
        INTO par_exception_flag;
    END IF;
    
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_chk_exception_case" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

