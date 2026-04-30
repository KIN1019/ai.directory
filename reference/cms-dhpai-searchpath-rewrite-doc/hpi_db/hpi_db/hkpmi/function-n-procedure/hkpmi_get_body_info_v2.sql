-- DROP PROCEDURE hkpmi_get_body_info_v2(inout int4, in varchar, in varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout timestamp, inout varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi_get_body_info_v2(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, INOUT par_hkid character varying, INOUT par_lof_hkid character varying, INOUT par_patient_name character varying, INOUT par_sex character varying, INOUT par_cccode1 character varying, INOUT par_cccode2 character varying, INOUT par_cccode3 character varying, INOUT par_cccode4 character varying, INOUT par_cccode5 character varying, INOUT par_cccode6 character varying, INOUT par_dob timestamp without time zone, INOUT par_exact_dob_flag character varying, INOUT par_death_date timestamp without time zone, INOUT par_body_category character varying, INOUT par_retcode integer, INOUT par_error_msg character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rowcount INTEGER;
    var_error INTEGER;
    var_valid_flag VARCHAR(1);
    var_patient_key VARCHAR(8);
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
	    SET LOCAL search_path TO hkpmi,public;
        SELECT
            0, NULL, 'Y'
            INTO par_retcode, par_error_msg, var_valid_flag;

        IF par_case_no IS NOT NULL THEN
            BEGIN
                /*
                exec @retcode = cpi_pq_validate_caseno @hospital_code, @case_no, @valid_flag output
                if @valid_flag <> "Y"
                begin
                	select @retcode = -1
                	select @error_msg = "Invalid case number"
                	goto return_error
                end
                */
                SELECT
                    hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, dob, exact_dob_flag, death_date, SUBSTRING(p.filler, 2, 1)
                    INTO par_hkid, par_patient_name, par_sex, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, par_dob, par_exact_dob_flag, par_death_date, par_body_category
                    FROM patient AS p, pmi_case AS c
                    WHERE p.patient_key = c.patient_key AND c.hospital_code = par_hospital_code AND c.case_no = par_case_no;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF var_error != 0 THEN
                    BEGIN
                        SELECT
                            var_error
                            INTO par_retcode;
                        SELECT
                            'Error in selecting body information'
                            INTO par_error_msg;
                        EXIT return_error;
                    END;
                END IF;

                IF var_rowcount != 1 THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO par_retcode;
                        SELECT
                            'Patient not found for this case number'
                            INTO par_error_msg;
                        EXIT return_error;
                    END;
                END IF;
            END;
        ELSE
            IF par_hkid IS NOT NULL THEN
                BEGIN
                    /*
                    exec @retcode = cpi_pq_validate_hkid @hkid, @valid_flag output
                    if @valid_flag <> "Y"
                    begin
                    	select @retcode = -1
                    	select @error_msg = "Invalid case number"
                    	goto return_error
                    end
                    */
                    SELECT
                        hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, dob, exact_dob_flag, death_date, SUBSTRING(filler, 2, 1), patient_key
                        INTO par_hkid, par_patient_name, par_sex, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, par_dob, par_exact_dob_flag, par_death_date, par_body_category, var_patient_key /* ---20090604 */
                        FROM patient
                        WHERE hkid = par_hkid;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    BEGIN
                        var_rowcount := sql$rowcount;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    END;

                    IF var_error != 0 THEN
                        BEGIN
                            SELECT
                                var_error
                                INTO par_retcode;
                            SELECT
                                'Error in selecting body information'
                                INTO par_error_msg;
                            EXIT return_error;
                        END;
                    END IF;

                    IF var_rowcount != 1 THEN
                        BEGIN
                            SELECT
                                - 1
                                INTO par_retcode;
                            SELECT
                                'Patient not found'
                                INTO par_error_msg;
                            EXIT return_error;
                        END;
                    END IF;
                    /* ---20090604 SL bugfix : if @case_no is null --> pass-in by hkid */
                    IF par_case_no IS NULL THEN
                        BEGIN
                            SELECT
                                case_no
                                INTO par_case_no
                                FROM pmi_case
                                WHERE patient_key = var_patient_key AND discharge_code = '1';
                        END;
                    END IF;
                    /* ------20090317 ---- Unique index on las_office_form_log (hkid, issue_datetime, action_type ) */
                    
                    /*
                    select @lof_hkid =null
                    select @lof_hkid = hkid from last_office_form_log
                    where last_case_no = @case_no
                    	and last_hospital_code = @hospital_code
                    group by last_case_no
                    having issue_datetime =  max(issue_datetime)
                    */
                    
                    /* -----------20101018 SL bug fix ------------------------------- */
                    SELECT
                        NULL
                        INTO par_lof_hkid;
                    /*
                    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
                    set rowcount 1
                    */
                    /* --- select the oldest hkid of non-cancelled LOF txn as lof_hkid for same HN case (for merged HKIDs ) */
                    SELECT
                        hkid
                        INTO par_lof_hkid
                        FROM last_office_form_log
                        WHERE last_case_no = par_case_no AND last_hospital_code = par_hospital_code AND action_type = 'A' /* ----20120925 */
                        GROUP BY hkid
                        HAVING issue_datetime = MAX(issue_datetime)
                        /* ---and action_type='A' */
                        ORDER BY issue_datetime ASC NULLS FIRST;
                    /*
                    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
                    set rowcount 0
                    */
                    /* ----------------------------------------- */
                END;
            END IF;
        END IF;
    END;

    IF par_retcode <> 0 THEN
        pas_return_code := - 1;
        RETURN;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
  	RESET search_path;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_get_body_info_v2" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
