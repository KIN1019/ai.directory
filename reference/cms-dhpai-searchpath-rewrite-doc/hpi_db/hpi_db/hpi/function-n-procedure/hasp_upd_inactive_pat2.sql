-- DROP PROCEDURE hpi.hasp_upd_inactive_pat2(inout int4, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_upd_inactive_pat2(INOUT pas_return_code integer, IN par_hosp_code character varying)
 LANGUAGE plpgsql
AS $procedure$
/* -- Add hosp_code as input parm by WL on 27 July 1999 -- */
DECLARE
    var_active_indicator VARCHAR(02);
    var_discharge_code VARCHAR(02);
    var_discharge_datetime TIMESTAMP WITHOUT TIME ZONE;
    active_cursor CURSOR FOR
    SELECT
        case_no
        FROM cpi_patient_location
        WHERE hospital_code = par_hosp_code;
    var_case_no VARCHAR(24);
    var_error INTEGER;
    var_rowcount INTEGER;
    sql$rowcount BIGINT;
BEGIN
    /* -- Remark hosp_code by WL on 27 July 1999, because -- */
    /* -- it is input parm --- */
    
    /* --@hosp_code char(03) */
    
    /*
    select @hosp_code = Text_value from Hospital_control
          		where Type = hospital_code
    
       	  if @@rowcount != 1
    		  begin
    				print Error: Hospital_code not found
    				return
    		  end
    */
    /* -- Remove cpi.. by WL on 27 July 1999 for HPI --- */
    OPEN active_cursor;
    FETCH active_cursor INTO var_case_no;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
        begin transaction
        */
        /* -- Add hosp_code by WL on 27 July 1999 for HPI -- */
        SELECT
            Active_indicator, Discharge_datetime, Discharge_code
            INTO var_active_indicator, var_discharge_datetime, var_discharge_code
            FROM ADT_Case
            WHERE Case_no = var_case_no AND Hospital_code = par_hosp_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount != 1 THEN
            BEGIN
                RAISE NOTICE 'Error: Case not found %', var_case_no;
                --ROLLBACK;
                raise exception 'Error: Case not found';
                pas_return_code := -1;
                RETURN;
            END;
        END IF;

        IF var_discharge_code != NULL AND 2 * INTERVAL '1 day' + var_discharge_datetime::TIMESTAMP < timestamp_convert(localtimestamp) THEN
            BEGIN
                /* -- Remove cpi.. by WL on 27 July 1999 for HPI -- */
                
                /* --delete cpi..cpi_patient_location */
                DELETE FROM cpi_patient_location
                    WHERE case_no = var_case_no AND hospital_code = par_hosp_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF var_error != 0 OR var_rowcount != 1 THEN
                    BEGIN
                        RAISE NOTICE 'Error: Patient location not found %', var_case_no;
                        --ROLLBACK;
                        raise exception 'Error: Patient location not found ';
                        pas_return_code := -1;
                        RETURN;
                    END;
                END IF;

                IF var_active_indicator = 'Y' THEN
                    BEGIN
                        /* change update to cpi_active_case for HPI */
                        /* by ML on 09 Sept 1999 */
                        /* Update ADT_Case */
                        /* set Active_indicator = 'N' */
                        /* where Case_no = @case_no */
                        UPDATE cpi_active_case
                        SET active_indicator = 'N'
                            WHERE case_no = var_case_no AND hospital_code = par_hosp_code;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        BEGIN
                            var_rowcount := sql$rowcount;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;

                        IF var_error != 0 OR var_rowcount != 1 THEN
                            BEGIN
                                RAISE NOTICE 'Error: Update case active status failed %', var_case_no;
                                --ROLLBACK;
                                raise exception 'Error: Update case active status failed ';
                                pas_return_code := -1;
                                RETURN;
                            END;
                        END IF;
                    END;
                END IF;
                RAISE NOTICE 'Case active status % updated', var_case_no;
            END;
        END IF;
        --COMMIT;
        FETCH active_cursor INTO var_case_no;
    END LOOP;
END;
$procedure$
;
