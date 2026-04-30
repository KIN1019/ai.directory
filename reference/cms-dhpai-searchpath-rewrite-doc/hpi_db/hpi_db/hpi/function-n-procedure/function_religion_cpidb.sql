-- DROP FUNCTION hpi.function_religion_cpidb();

CREATE OR REPLACE FUNCTION hpi.function_religion_cpidb()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$ 
begin
    IF TG_OP = 'INSERT' then
    if ( NOT EXISTS (SELECT 1 FROM religion WHERE religion_code = NEW.religion_code))  THEN
            INSERT INTO religion (religion_code,religion_description)
            VALUES(NEW.religion_code,NEW.religion_description);
        ELSE
		
        END IF;
    ELSIF TG_OP = 'UPDATE' then
    	IF EXISTS (SELECT 1 FROM religion WHERE religion_code = NEW.religion_code) then
        	if ( OLD.religion_description IS DISTINCT FROM NEW.religion_description)  THEN 
        		UPDATE religion SET religion_description = NEW.religion_description
       			WHERE religion_code = NEW.religion_code;
        	ELSE
            END IF;
    	ELSE
            INSERT INTO religion (religion_code,religion_description)
            VALUES(NEW.religion_code,NEW.religion_description);
    	END IF;
    ELSIF TG_OP = 'DELETE' then
    	IF EXISTS (SELECT 1 FROM religion WHERE religion_code = OLD.religion_code) then
    		DELETE FROM religion WHERE religion_code = OLD.religion_code ;
    	ELSE
        END IF;
    END IF;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "function_religion_cpidb" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
