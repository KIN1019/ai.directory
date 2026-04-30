-- DROP PROCEDURE hkpmi.hkpmi_check_sars_alert(inout int4, in bpchar, in timestamp, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout timestamp, inout bpchar, inout bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_check_sars_alert(INOUT pas_return_code integer, IN par_hkid VARCHAR, IN par_adm_dtm timestamp without time zone, INOUT par_hosp_code VARCHAR, INOUT par_case VARCHAR, INOUT par_ward VARCHAR, 
INOUT par_spec VARCHAR, INOUT par_ward_desc VARCHAR, INOUT par_out_dtm timestamp without time zone, INOUT par_status VARCHAR, INOUT par_rec_found VARCHAR)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_retcode INTEGER;
    var_create_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_check_date TIMESTAMP WITHOUT TIME ZONE;
    var_server_name VARCHAR(30);
    var_db_name VARCHAR(30);
    var_user_name VARCHAR(30);
    var_enable_flag VARCHAR(1);
    var_program_name VARCHAR(80);
    sql$rowcount BIGINT;
BEGIN
    <<program_end>>
    BEGIN
        <<return_not_found>>
        BEGIN
            BEGIN
                SELECT
                    'Y', NULL
                    INTO par_rec_found, var_check_date;
                SELECT
                    enable_flag, server_name, current_schema, aws_sapase_ext.user_name
                    INTO var_enable_flag, var_server_name, var_db_name, var_user_name
                    FROM remote_server_control
                    WHERE system_name = 'SARS';
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount <> 1 THEN
                    SELECT
                        'N'
                        INTO var_enable_flag;
                END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        SELECT
                            'N'
                            INTO var_enable_flag;
            END;

            IF var_enable_flag = 'Y' THEN
                BEGIN
                    SELECT
                        RTRIM(CONCAT(RTRIM(var_server_name), '.', RTRIM(var_db_name), '.', RTRIM(var_user_name), '.', 'proc_sars_chk_record'))
                        INTO var_program_name;
                    /*
                    [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
                    exec @retcode = @program_name
                    			@hkid, @case output, @hosp_code output, @status output,
                    			@create_dtm output
                    */
                END;
            ELSE
                SELECT
                    NULL, NULL, NULL, NULL
                    INTO par_case, par_hosp_code, par_status, var_create_dtm;
            END IF;

            IF par_case IS NULL THEN
                BEGIN
                    SELECT
                        case_no, hospital_code, ward_code, specialty_code, out_dtm, ward_description
                        INTO par_case, par_hosp_code, par_ward, par_spec, par_out_dtm, par_ward_desc
                        FROM (SELECT
                            case_no, hospital_code, ward_code, specialty_code, out_dtm, ward_description, hkid, in_dtm
                            FROM hkpmi_sars_patient_list) AS ungrouped_query
                        INNER JOIN (SELECT
                            hkid, MAX(in_dtm) AS max_1
                            FROM hkpmi_sars_patient_list
                            WHERE hkid = par_hkid AND out_dtm IS NULL
                            GROUP BY hkid) AS grouped_query
                            ON (ungrouped_query.hkid = grouped_query.hkid OR (ungrouped_query.hkid IS NULL AND grouped_query.hkid IS NULL))
                        WHERE in_dtm = max_1;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    BEGIN
                        var_rowcount := sql$rowcount;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    END;

                    IF var_rowcount = 1 AND var_error = 0 THEN
                        EXIT program_end;
                    END IF;
                    SELECT
                        case_no, hospital_code, ward_code, specialty_code, out_dtm, ward_description
                        INTO par_case, par_hosp_code, par_ward, par_spec, par_out_dtm, par_ward_desc
                        FROM (SELECT
                            case_no, hospital_code, ward_code, specialty_code, out_dtm, ward_description, hkid
                            FROM hkpmi_sars_patient_list) AS ungrouped_query
                        INNER JOIN (SELECT
                            hkid, MAX(out_dtm) AS max_2
                            FROM hkpmi_sars_patient_list
                            WHERE hkid = par_hkid AND out_dtm IS NOT NULL
                            GROUP BY hkid) AS grouped_query
                            ON (ungrouped_query.hkid = grouped_query.hkid OR (ungrouped_query.hkid IS NULL AND grouped_query.hkid IS NULL))
                        WHERE out_dtm = max_2;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    BEGIN
                        var_rowcount := sql$rowcount;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    END;

                    IF var_rowcount = 0 OR var_error <> 0 THEN
                        EXIT return_not_found;
                    END IF;

                    IF par_out_dtm < - 14 * INTERVAL '1 day' + par_adm_dtm::TIMESTAMP THEN
                        EXIT return_not_found;
                    END IF;
                END;
            ELSE
                BEGIN
                    IF par_status = 'N' THEN
                        SELECT
                            'NOT SARS'
                            INTO par_status;
                    END IF;

                    IF par_status = 'C' THEN
                        SELECT
                            'CLINICAL SARS'
                            INTO par_status;
                    END IF;

                    IF par_status = 'S' THEN
                        SELECT
                            'SUSPECTED SARS'
                            INTO par_status;
                    END IF;
                    SELECT
                        discharge_dtm, last_ward_code, last_specialty_code
                        INTO par_out_dtm, par_ward, par_spec
                        FROM pmi_case
                        WHERE case_no = par_case AND hospital_code = par_hosp_code;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    BEGIN
                        var_rowcount := sql$rowcount;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    END;

                    IF var_rowcount = 0 OR var_error <> 0 THEN
                        EXIT return_not_found;
                    END IF;

                    IF par_out_dtm IS NOT NULL AND par_out_dtm < - 14 * INTERVAL '1 day' + par_adm_dtm::TIMESTAMP THEN
                        EXIT return_not_found;
                    END IF;

                    IF par_out_dtm IS NULL THEN
                        SELECT
                            localtimestamp
                            INTO var_check_date;
                    ELSE
                        SELECT
                            par_out_dtm
                            INTO var_check_date;
                    END IF;
                    SELECT
                        description
                        INTO par_ward_desc
                        FROM hkpmi_ward
                        WHERE hospital_code = par_hosp_code AND ward_code = par_ward AND effective_date = (SELECT
                            MAX(effective_date)
                            FROM hkpmi_ward
                            WHERE effective_date <= var_check_date AND ward_code = par_ward AND hospital_code = par_hosp_code);

                    IF par_status = '1' THEN
                        SELECT
                            'UNDER OBSERVATION'
                            INTO par_status;
                    ELSE
                        IF par_status = '2' THEN
                            SELECT
                                'SUSPECT + Rx'
                                INTO par_status;
                        ELSE
                            IF par_status = '3' THEN
                                SELECT
                                    'CLINICAL SARS'
                                    INTO par_status;
                            ELSE
                                IF par_status = '4' THEN
                                    SELECT
                                        'NOT SARS'
                                        INTO par_status;
                                ELSE
                                    SELECT
                                        'NO CATEGORY'
                                        INTO par_status;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END;
            END IF;
            EXIT program_end;
        END;
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N'
            INTO par_case, par_hosp_code, par_status, par_out_dtm, par_ward, par_spec, par_ward_desc, par_rec_found;
        pas_return_code := - 1;
        RETURN;
    END;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_check_sars_alert" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

