-- create function
CREATE OR REPLACE FUNCTION function_cpi_active_case() RETURNS TRIGGER AS $$
    DECLARE
        retry_count INT := 0;
        max_retries INT := 3;
        delay_interval INT := 500;
        exec_sql    TEXT;
BEGIN
    WHILE retry_count < max_retries
        LOOP
            BEGIN
                
                IF TG_OP = 'INSERT' THEN
                   
                    PERFORM 1
                    FROM hpi.cpi_case
                    WHERE hospital_code = NEW.hospital_code
                      AND case_no = NEW.case_no;

                  
                    IF FOUND THEN
                       
                        PERFORM 1
                        FROM hpi.adt_case_adtdb
                        WHERE case_no = NEW.case_no and hospital_code = NEW.hospital_code;

                        IF FOUND THEN
                            -- do nothing
                        ELSE
                      
                            exec_sql := format('INSERT INTO hpi.adt_case_adtdb (case_no,Admission_datetime,source_indicator,source_code,district_code,pay_code,discharge_code,discharge_datetime,destination_code,case_type,Active_indicator,movement_count,security_count,access_code,system_datetime,user_id,timestamp,t_prk,mrt_indicator,hospital_code) SELECT case_no,admission_dtm,source_indicator,source_code,district_code,patient_type,discharge_code,discharge_dtm,destination_code,case_type,%L,movement_count,1,access_code,update_dtm,update_by,NOW() AS timestamp,patient_key,mrt_indicator,hospital_code FROM cpi_case WHERE hospital_code = %L AND case_no = %L',
                                        NEW.active_indicator, NEW.hospital_code, NEW.case_no);
                            EXECUTE exec_sql;
                        END IF;
                    END IF;
                
                ELSIF TG_OP = 'DELETE' THEN
                   
                    PERFORM 1
                    FROM hpi.cpi_case
                    WHERE hospital_code = NEW.hospital_code and case_no = OLD.case_no;
                    IF FOUND THEN
                   
                    ELSE
                        
                        exec_sql := format('DELETE FROM hpi.adt_case_adtdb WHERE case_no = %L and hospital_code=%L', OLD.case_no, OLD.hospital_code);
                        EXECUTE exec_sql;
                    END IF;
                   
                ELSIF TG_OP = 'UPDATE' THEN
                    IF EXISTS (
                       
                        SELECT 1
                        FROM hpi.adt_case_adtdb
                        WHERE case_no = OLD.case_no and hospital_code = OLD.hospital_code AND active_indicator != NEW.active_indicator) THEN
                        IF (OLD.case_no IS DISTINCT FROM NEW.case_no
                            or OLD.active_indicator is DISTINCT FROM NEW.case_no) then
                            
                            exec_sql := format('UPDATE hpi.adt_case_adtdb SET case_no = %L, active_indicator = %L,hospital_code=%L WHERE case_no = %L and hospital_code=%L',
                                            NEW.case_no, NEW.active_indicator, NEW.hospital_code, OLD.case_no, OLD.hospital_code);
                            EXECUTE exec_sql;
                        END IF;
                    END IF;
                END IF;
                -- break the loop
                EXIT;
            EXCEPTION
                WHEN OTHERS THEN
                    RAISE notice 'Failed to % adt_case_adtdb after % retries with sql: %', TG_OP, retry_count, exec_sql;
                    RAISE notice '%', SQLERRM;

                    retry_count := retry_count + 1;
                    PERFORM pg_sleep(delay_interval / 1000);
                    if retry_count = max_retries then
                        RAISE;
                    end if;
            end;
        end loop;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;
ALTER FUNCTION "function_cpi_active_case" OWNER TO "HPI_SCHEMA_OWNER_ROLE";