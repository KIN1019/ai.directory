-- DROP FUNCTION adt_tmp.function_adt_case_adtdb();
CREATE OR REPLACE FUNCTION function_adt_case_adtdb() RETURNS trigger LANGUAGE plpgsql
AS $function$
	DECLARE statusCode VARCHAR(2);
    DECLARE
        retry_count INT := 0;
        max_retries INT := 3;
        delay_interval INT := 500;
        exec_sql    TEXT;
begin
    WHILE retry_count < max_retries
        LOOP
            BEGIN
                
                IF TG_OP = 'INSERT' then
              
                SELECT status_code into statusCode  FROM hpi.cpi_case   WHERE case_no = NEW.case_no and hospital_code = NEW.hospital_code;
                if ( NEW.case_type in('I','A') and (statusCode<>'CC' or statusCode is null)
                    and NOT EXISTS (SELECT 1 FROM hpi.cpi_active_case WHERE case_no = NEW.case_no and hospital_code = NEW.hospital_code))  THEN
                        
                        exec_sql := format('INSERT INTO hpi.cpi_active_case (case_no, active_indicator,hospital_code) VALUES(%L, %L, %L);',
                                        NEW.case_no, NEW.active_indicator, NEW.hospital_code);
                        EXECUTE exec_sql;
                    ELSE
                    END IF;
                
                ELSIF TG_OP = 'UPDATE' then
                    SELECT status_code into statusCode  FROM hpi.cpi_case   WHERE case_no = OLD.case_no and hospital_code = NEW.hospital_code;
                    IF EXISTS (SELECT 1 FROM hpi.cpi_active_case WHERE case_no = OLD.case_no and hospital_code = OLD.hospital_code limit 1) then
                        if ( NEW.case_type in('I','A') and statusCode<>'CC'
                            and (OLD.active_indicator IS DISTINCT FROM NEW.active_indicator
                            or OLD.hospital_code IS DISTINCT FROM NEW.hospital_code
                            or OLD.case_no IS DISTINCT FROM NEW.case_no))  THEN
                            
                            exec_sql := format('UPDATE hpi.cpi_active_case SET active_indicator = %L,hospital_code=%L,case_no=%L WHERE case_no = %L and hospital_code=%L',
                                            NEW.active_indicator, NEW.hospital_code, new.case_no, OLD.case_no, OLD.hospital_code);
                            EXECUTE exec_sql;
                        ELSEIF (NEW.case_type not in('I','A') or statusCode ='CC' ) then
                            
                            exec_sql := format('DELETE FROM hpi.cpi_active_case WHERE case_no = %L and hospital_code=%L', OLD.case_no, OLD.hospital_code);
                            EXECUTE exec_sql;
                        END IF;
                    ELSE
                        if ( NEW.case_type in('I','A') and statusCode<>'CC' )  THEN
                            
                            exec_sql := format('INSERT INTO hpi.cpi_active_case (case_no, active_indicator,hospital_code) VALUES(%L, %L, %L)',
                                            NEW.case_no, NEW.active_indicator, NEW.hospital_code);
                            EXECUTE exec_sql;
                        ELSE
                        END IF;
                    END IF;
               
                ELSIF TG_OP = 'DELETE' then
                    
                    exec_sql := format('DELETE FROM hpi.cpi_active_case WHERE case_no = %L and hospital_code=%L', OLD.case_no, OLD.hospital_code);
                    EXECUTE exec_sql;
                END IF;
                -- break the loop
                EXIT;
            EXCEPTION
                WHEN OTHERS THEN
                    RAISE notice 'Failed to % cpi_active_case after % retries with sql: %', TG_OP, retry_count, exec_sql;
                    RAISE notice '%', SQLERRM;

                    retry_count := retry_count + 1;
                    PERFORM pg_sleep(delay_interval / 1000);
                    if retry_count = max_retries then
                        insert into hpi.adt_case_adtdb_trigger_error_log(message, create_time)
                        values (json_build_object(
                            'sql', exec_sql,
                            'error_message', SQLERRM,
                            'SQLSTATE', SQLSTATE
                        ), now());
                    end if;
            end;
        end loop;
    RETURN NULL;
END;
$function$
;
ALTER FUNCTION "function_adt_case_adtdb" OWNER TO "HPI_SCHEMA_OWNER_ROLE";