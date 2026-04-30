-- DROP PROCEDURE hkpmi.hkpmi_check_mother_baby_case(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_check_mother_baby_case(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_patient_key character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_return_error_code INTEGER;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_return_code INTEGER;
    var_begin_tran VARCHAR(2);
    var_mo_hosp VARCHAR(6);
    var_mo_case VARCHAR(24);
    var_mo_hosp_2 VARCHAR(6);
    var_mo_case_2 VARCHAR(24);
    var_mo_hosp_hn VARCHAR(6);
    var_mo_case_hn VARCHAR(24);
    var_nb_hosp VARCHAR(4);
    var_nb_case VARCHAR(24);
    var_nb_hosp_2 VARCHAR(6);
    var_nb_case_2 VARCHAR(24);
    var_nb_hosp_hn VARCHAR(6);
    var_nb_case_hn VARCHAR(24);
    var_birth_place VARCHAR(2);
    var_birth_loc VARCHAR(6);
    var_preg_no INTEGER;
    var_birth_order INTEGER;
    var_err_msg text;
    mo_csr CURSOR FOR
    SELECT
        mother_hospital_code, mother_case_no, mother_hospital_2, mother_case_2, mother_hospital_hn, mother_case_hn, baby_hospital_code, baby_case_no, baby_hospital_2, baby_case_2, baby_hospital_hn, baby_case_hn, birth_place, birth_location, pregnancy_number, birth_order
        FROM pmi_case AS c, mother_baby_case AS m
        WHERE c.patient_key = par_patient_key AND c.case_type IN ('A', 'I') AND (c.hospital_code = m.mother_hospital_code AND c.case_no = m.mother_case_no) AND active_status = 'Y'
    UNION
    SELECT
        mother_hospital_code, mother_case_no, mother_hospital_2, mother_case_2, mother_hospital_hn, mother_case_hn, baby_hospital_code, baby_case_no, baby_hospital_2, baby_case_2, baby_hospital_hn, baby_case_hn, birth_place, birth_location, pregnancy_number, birth_order
        FROM pmi_case AS c, mother_baby_case AS m
        WHERE c.patient_key = par_patient_key AND c.case_type IN ('A', 'I') AND (c.hospital_code = m.mother_hospital_2 AND c.case_no = m.mother_case_2) AND active_status = 'Y'
    UNION
    SELECT
        mother_hospital_code, mother_case_no, mother_hospital_2, mother_case_2, mother_hospital_hn, mother_case_hn, baby_hospital_code, baby_case_no, baby_hospital_2, baby_case_2, baby_hospital_hn, baby_case_hn, birth_place, birth_location, pregnancy_number, birth_order
        FROM pmi_case AS c, mother_baby_case AS m
        WHERE c.patient_key = par_patient_key AND c.case_type IN ('A', 'I') AND (c.hospital_code = m.mother_hospital_hn AND c.case_no = m.mother_case_hn) AND active_status = 'Y'
    UNION
    SELECT
        mother_hospital_code, mother_case_no, mother_hospital_2, mother_case_2, mother_hospital_hn, mother_case_hn, baby_hospital_code, baby_case_no, baby_hospital_2, baby_case_2, baby_hospital_hn, baby_case_hn, birth_place, birth_location, pregnancy_number, birth_order
        FROM pmi_case AS c, mother_baby_case AS m
        WHERE c.patient_key = par_patient_key AND c.case_type IN ('A', 'I') AND (c.hospital_code = m.baby_hospital_code AND c.case_no = m.baby_case_no) AND active_status = 'Y'
    UNION
    SELECT
        mother_hospital_code, mother_case_no, mother_hospital_2, mother_case_2, mother_hospital_hn, mother_case_hn, baby_hospital_code, baby_case_no, baby_hospital_2, baby_case_2, baby_hospital_hn, baby_case_hn, birth_place, birth_location, pregnancy_number, birth_order
        FROM pmi_case AS c, mother_baby_case AS m
        WHERE c.patient_key = par_patient_key AND c.case_type IN ('A', 'I') AND (c.hospital_code = m.baby_hospital_2 AND c.case_no = m.baby_case_2) AND active_status = 'Y'
    UNION
    SELECT
        mother_hospital_code, mother_case_no, mother_hospital_2, mother_case_2, mother_hospital_hn, mother_case_hn, baby_hospital_code, baby_case_no, baby_hospital_2, baby_case_2, baby_hospital_hn, baby_case_hn, birth_place, birth_location, pregnancy_number, birth_order
        FROM pmi_case AS c, mother_baby_case AS m
        WHERE c.patient_key = par_patient_key AND c.case_type IN ('A', 'I') AND (c.hospital_code = m.baby_hospital_hn AND c.case_no = m.baby_case_hn) AND active_status = 'Y';
BEGIN
    <<return_error>>
    BEGIN
        /* Declaration */
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
           begin
           	begin tran
        		select @begin_tran = "Y"
           end
        	else
        		select @begin_tran = "N"
        */
        /* --			and c.hospital_code = @hospital_code */
		select 'Y' into var_begin_tran;
        OPEN mo_csr;
     
        FETCH mo_csr INTO var_mo_hosp, var_mo_case, var_mo_hosp_2, var_mo_case_2, var_mo_hosp_hn, var_mo_case_hn, var_nb_hosp, var_nb_case, var_nb_hosp_2, var_nb_case_2, var_nb_hosp_hn, var_nb_case_hn, var_birth_place, var_birth_loc, var_preg_no, var_birth_order;
        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 loop
	     
            CALL hkpmi_update_mother_baby_case(var_return_code, var_mo_hosp, var_mo_hosp, var_mo_case, var_nb_hosp, var_nb_case, var_birth_order, var_preg_no, var_birth_place, var_birth_loc, par_update_by, '261', par_source_system, par_source_system_dtm, var_mo_hosp, var_mo_case, var_nb_hosp, var_nb_case, NULL, NULL, NULL, NULL, NULL, 'Y');

            IF var_return_code != 0 THEN
                BEGIN
                    IF var_return_code > 200000 THEN
                        SELECT
                            var_return_code
                            INTO var_return_error_code;
                    ELSE
                        SELECT
                            200167
                            INTO var_return_error_code;
                    END IF;
                    EXIT return_error;
                END;
            END IF;
            FETCH mo_csr INTO var_mo_hosp, var_mo_case, var_mo_hosp_2, var_mo_case_2, var_mo_hosp_hn, var_mo_case_hn, var_nb_hosp, var_nb_case, var_nb_hosp_2, var_nb_case_2, var_nb_hosp_hn, var_nb_case_hn, var_birth_place, var_birth_loc, var_preg_no, var_birth_order;
        END LOOP;
        CLOSE mo_csr;

        pas_return_code := 0;
        RETURN;
    END;

     raise exception '';
		EXCEPTION  
			WHEN  OTHERS then
			begin
			get STACKED DIAGNOSTICS var_err_msg = MESSAGE_TEXT;
			raise notice 'err:%', var_err_msg;
		end;
    RAISE EXCEPTION USING ERRCODE := var_return_error_code;
    pas_return_code := var_return_error_code;
    RETURN;

    
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_check_mother_baby_case" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

