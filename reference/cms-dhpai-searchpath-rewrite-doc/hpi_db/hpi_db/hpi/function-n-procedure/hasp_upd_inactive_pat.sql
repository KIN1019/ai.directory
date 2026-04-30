-- DROP PROCEDURE hpi.hasp_upd_inactive_pat(inout int4, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_upd_inactive_pat(INOUT pas_return_code integer, IN par_hosp_code character varying)
 LANGUAGE plpgsql
AS $procedure$
/* -- add hosp code as input parm by WL on 27 July 1999 --- */
DECLARE
    active_cursor CURSOR FOR
    SELECT
        case_no
        FROM cpi_active_case
        WHERE active_indicator = 'Y';
    var_case_no VARCHAR(24);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_disc_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_disc_code VARCHAR(02);
    sql$rowcount BIGINT;
BEGIN
    /* -- Remark by WL on 27 July 1999, becuase it is input parm-- */
    
    /*
    declare @hosp_code char(03)
    
    	select @hosp_code = Text_value from Hospital_control
    	where Type = "hospital_code"
    
      if @@rowcount != 1
      begin
         print "Error: Hospital_code not found"
     	end
    */
    
    /* remarked since cursor will be closed implicitly */
    
    /* when one of the joined table have to updated */
    
    /* by ML on 10.09.1999 */
    
    /* declare active_cursor cursor for */
    
    /* select Case_no from Case */
    
    /* where Active_indicator = 'Y' */
    
    /* and dateadd(dd,2,Discharge_datetime) < getdate() */
    
    /* and Discharge_code != null */
    
    /* and Case_type != 'O' */
    
    /* for read only */
    OPEN active_cursor;
    FETCH active_cursor INTO var_case_no;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        /* modified by ML on 09.09.1999 */
        SELECT
            discharge_dtm, discharge_code
            INTO var_disc_dtm, var_disc_code
            FROM cpi_case
            WHERE case_no = var_case_no AND hospital_code = par_hosp_code;
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
                RAISE NOTICE 'Select Error %', var_case_no;
                pas_return_code := -1;
                RETURN;
            END;
        END IF;

        IF var_rowcount != 1 THEN
            BEGIN
                RAISE NOTICE 'Case not found %', var_case_no;
            END;
        ELSE
            BEGIN
                IF (2 * INTERVAL '1 day' + var_disc_dtm::TIMESTAMP < timestamp_convert(localtimestamp)) AND (var_disc_code != NULL) THEN
                    BEGIN
                        /*
                        [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
                        begin transaction
                        */
                        /* remarked by Mabel for HPI */
                        /* Update Case */
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

                        IF var_error != 0 THEN
                            BEGIN
                                --ROLLBACK;
                                raise exception '';
                                pas_return_code := -1;
                                RETURN;
                            END;
                        END IF;

                        IF var_rowcount != 1 THEN
                            BEGIN
                                /* --print 'failed to update case ' */
                                /* modified by ML on 09.09.1999 */
                                --ROLLBACK;
                                raise exception '';
                                RAISE NOTICE 'failed to update cpi_active_case ';
                                RAISE NOTICE '%', var_case_no;
                                EXIT;
                            END;
                        ELSE
                            BEGIN
                                RAISE NOTICE 'Case active status % updated', var_case_no;
                            END;
                        END IF;
                        /* -- remove cpi.. by WL on 27 July 1999 for HPI --- */
                        
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

                        IF var_error != 0 THEN
                            BEGIN
                                --ROLLBACK;
                                raise exception '';
                                pas_return_code := -1;
                                RETURN;
                            END;
                        END IF;
                        --COMMIT;
                    END;
                END IF;
            END;
        END IF;
        FETCH active_cursor INTO var_case_no;
    END LOOP;
    CLOSE active_cursor;
END;
$procedure$
;
