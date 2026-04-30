-- DROP FUNCTION hpi.function_cpi_ward_list_cpidb();

CREATE OR REPLACE FUNCTION hpi.function_cpi_ward_list_cpidb()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$ 
begin
    IF TG_OP = 'INSERT' then
    if ( NOT EXISTS (SELECT 1 FROM ward_list WHERE case_no = NEW.case_no and hospital_code = NEW.hospital_code))  THEN
            INSERT INTO ward_list (hospital_code,case_no,ward_code,bed_no,specialty_code)
            VALUES(NEW.hospital_code,NEW.case_no,NEW.ward_code,NEW.bed_no,NEW.specialty_code);
        ELSE
		
        END IF;
    ELSIF TG_OP = 'UPDATE' then
    	IF EXISTS (SELECT 1 FROM ward_list WHERE case_no = NEW.case_no and hospital_code = NEW.hospital_code) then
        	if ( OLD.ward_code IS DISTINCT FROM NEW.ward_code  or OLD.bed_no IS DISTINCT FROM NEW.bed_no  or OLD.specialty_code IS DISTINCT FROM NEW.specialty_code)  THEN 
        		UPDATE ward_list SET ward_code = NEW.ward_code, bed_no = NEW.bed_no, specialty_code = NEW.specialty_code
       			WHERE case_no = NEW.case_no and hospital_code = NEW.hospital_code ;
        	ELSE
            END IF;
    	ELSE
            INSERT INTO ward_list (hospital_code,case_no,ward_code,bed_no,specialty_code)
            VALUES(NEW.hospital_code,NEW.case_no,NEW.ward_code,NEW.bed_no,NEW.specialty_code);
    	END IF;
    ELSIF TG_OP = 'DELETE' then
    	IF EXISTS (SELECT 1 FROM ward_list WHERE case_no = OLD.case_no and hospital_code = OLD.hospital_code) then
    		DELETE FROM ward_list WHERE case_no = OLD.case_no and hospital_code = OLD.hospital_code ;
    	ELSE
        END IF;
    END IF;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "function_cpi_ward_list_cpidb" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
