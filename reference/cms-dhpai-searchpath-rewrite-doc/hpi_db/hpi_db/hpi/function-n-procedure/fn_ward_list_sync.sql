-- DROP FUNCTION hpi.fn_ward_list_sync();

CREATE OR REPLACE FUNCTION hpi.fn_ward_list_sync()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$ 
begin
    IF TG_OP = 'INSERT' then
    if ( NOT EXISTS (SELECT 1 FROM cpi_ward_list_cpidb WHERE case_no = NEW.case_no and hospital_code = NEW.hospital_code))  THEN
            INSERT INTO cpi_ward_list_cpidb (hospital_code,case_no,ward_code,bed_no,specialty_code)
            VALUES(NEW.hospital_code,NEW.case_no,NEW.ward_code,NEW.bed_no,NEW.specialty_code);
        ELSE
		
        END IF;
    ELSIF TG_OP = 'UPDATE' then
    	IF EXISTS (SELECT 1 FROM cpi_ward_list_cpidb WHERE case_no = NEW.case_no and hospital_code = NEW.hospital_code) then
        	if ( OLD.ward_code IS DISTINCT FROM NEW.ward_code  or OLD.bed_no IS DISTINCT FROM NEW.bed_no or OLD.specialty_code IS DISTINCT FROM NEW.specialty_code)  THEN 
        		UPDATE cpi_ward_list_cpidb SET ward_code = NEW.ward_code, bed_no = NEW.bed_no, specialty_code = NEW.specialty_code
       			WHERE case_no = NEW.case_no and hospital_code = NEW.hospital_code ;
        	ELSE
            END IF;
    	ELSE
            INSERT INTO cpi_ward_list_cpidb (hospital_code,case_no,ward_code,bed_no,specialty_code)
            VALUES(NEW.hospital_code,NEW.case_no,NEW.ward_code,NEW.bed_no,NEW.specialty_code);
    	END IF;
    ELSIF TG_OP = 'DELETE' then
    	IF EXISTS (SELECT 1 FROM cpi_ward_list_cpidb WHERE case_no = OLD.case_no and hospital_code = OLD.hospital_code) then
    		DELETE FROM cpi_ward_list_cpidb WHERE case_no = OLD.case_no and hospital_code = OLD.hospital_code ;
    	ELSE
        END IF;
    END IF;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_ward_list_sync" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
