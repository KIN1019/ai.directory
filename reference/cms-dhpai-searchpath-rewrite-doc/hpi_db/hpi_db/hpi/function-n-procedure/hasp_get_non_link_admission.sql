-- DROP PROCEDURE hasp_get_non_link_admission(inout int4, in bpchar, in timestamp, in timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_get_non_link_admission(INOUT pas_return_code integer, IN par_hospital_code character, IN par_report_from_date timestamp without time zone, IN par_report_to_date timestamp without time zone, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_return INTEGER;
    var_return_code int;
    var_case VARCHAR(120);
    var_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_src_ind VARCHAR(20);
    var_src_code VARCHAR(50);
    var_ward VARCHAR(40);
    var_spec VARCHAR(40);
    var_hkid VARCHAR(120);
    var_local_hosp VARCHAR(30);
    
    csr CURSOR FOR
        SELECT 
            Case_no, From_ward_code, From_specialty_code 
        FROM Transaction_log 
        WHERE Transaction_type = '100' 
          AND Transaction_datetime >= par_report_from_date 
          AND Transaction_datetime < par_report_to_date 
          AND Cancel_flag IS NULL 
          AND Hospital_code = par_hospital_code;
BEGIN
    <<error_return>>
    BEGIN
        DROP TABLE IF EXISTS t$temp_admission;
        CREATE TEMPORARY TABLE t$temp_admission (
            hkid VARCHAR(120),
            case_no VARCHAR(120),
            admission_datetime TIMESTAMP WITHOUT TIME ZONE,
            source_indicator VARCHAR(20),
            source_code VARCHAR(30),
            ward_code VARCHAR(40),
            specialty_code VARCHAR(40)
        );

        IF par_report_from_date IS NULL THEN
            IF par_report_to_date IS NULL THEN
                par_report_from_date := TO_CHAR((CURRENT_DATE - INTERVAL '1 day'), 'YYYYMMDD');
            ELSE
                SELECT par_report_from_date INTO par_report_to_date;
            END IF;
        END IF;

        IF par_report_to_date IS NULL THEN
            SELECT 1 * INTERVAL '1 day' + par_report_from_date::TIMESTAMP INTO par_report_to_date;
        ELSE
            SELECT 1 * INTERVAL '1 day' + par_report_to_date::TIMESTAMP INTO par_report_to_date;
        END IF;

        OPEN csr;
        FETCH csr INTO var_case, var_ward, var_spec;

        WHILE (CASE
                  WHEN FOUND THEN 0
                  WHEN NOT FOUND THEN 2
                  ELSE 1
               END) = 0 LOOP
            SELECT 
                Admission_datetime, Source_indicator, Source_code, HKID
            INTO var_adm_dtm, var_src_ind, var_src_code, var_hkid
            FROM Case_view
            WHERE Case_no = var_case AND Hospital_code = par_hospital_code;

            IF var_src_ind IN ('3', '5') THEN
                BEGIN
                    -- replace_dblink_by_fdw
                    CALL hkpmi.hkpmi_get_linked_case(var_return,var_hkid,null::varchar,null::varchar,par_hospital_code,var_case,null::varchar);
                   	SET search_path TO hpi,public;

                    raise notice 'var_return:%', var_return;

                    IF var_return = -1 OR pas_return_code = -1 THEN
                        BEGIN
                            SELECT -1 INTO pas_return_code;
                            /*EXIT error_return;*/
                            RETURN;
                        END;
                    END IF;
                    IF var_return = 0 THEN
                        INSERT INTO t$temp_admission (hkid, case_no, admission_datetime, source_indicator, source_code, ward_code, specialty_code)
                        VALUES (var_hkid, var_case, var_adm_dtm, var_src_ind, var_src_code, var_ward, var_spec);
                    END IF;
                END;
            END IF;
            FETCH csr INTO var_case, var_ward, var_spec;
        END LOOP;

        OPEN p_refcur FOR
            SELECT 
                hkid, case_no, admission_datetime, source_indicator, source_code, ward_code, specialty_code
            FROM t$temp_admission
            ORDER BY hkid, case_no;
            
        CLOSE csr;
        SELECT 0 INTO pas_return_code;
        RETURN;
    END;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_non_link_admission" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
