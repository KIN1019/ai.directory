-- DROP PROCEDURE hkpmi.hkpmi_get_body_info_by_caseno(inout int4, in bpchar, in bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout timestamp, inout bpchar, inout timestamp, inout bpchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_get_body_info_by_caseno(INOUT pas_return_code integer, IN par_hospital_code VARCHAR, IN par_case_no VARCHAR, INOUT par_hkid VARCHAR, 
INOUT par_patient_name VARCHAR, INOUT par_sex VARCHAR, INOUT par_cccode1 VARCHAR, INOUT par_cccode2 VARCHAR, INOUT par_cccode3 VARCHAR, INOUT par_cccode4 VARCHAR, 
INOUT par_cccode5 VARCHAR, INOUT par_cccode6 VARCHAR, INOUT par_dob timestamp without time zone, INOUT par_exact_dob_flag VARCHAR, INOUT par_death_date timestamp without time zone, 
INOUT par_body_category VARCHAR, INOUT par_retcode integer, INOUT par_error_msg character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rowcount INTEGER;
    var_error INTEGER;
    var_valid_flag VARCHAR(1);
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
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
                    hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, dob, exact_dob_flag, death_date, 
                    CASE WHEN LENGTH(p.filler) >= 2 THEN SUBSTRING(p.filler, 2, 1)
                    ELSE NULL END
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
                        hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, dob, exact_dob_flag, death_date,  
                        CASE WHEN LENGTH(filler) >= 2 THEN SUBSTRING(filler, 2, 1)
                        ELSE NULL END
                        INTO par_hkid, par_patient_name, par_sex, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, par_dob, par_exact_dob_flag, par_death_date, par_body_category
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
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_get_body_info_by_caseno" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

