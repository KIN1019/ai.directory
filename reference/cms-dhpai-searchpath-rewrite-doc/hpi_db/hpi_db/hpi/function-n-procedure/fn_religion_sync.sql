-- DROP FUNCTION hpi.fn_religion_sync();

CREATE OR REPLACE FUNCTION hpi.fn_religion_sync()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$ 
begin
    IF TG_OP = 'INSERT' then
    if ( NOT EXISTS (SELECT 1 FROM religion_cpidb WHERE religion_code = NEW.religion_code))  THEN
            INSERT INTO religion_cpidb (religion_code,religion_description)
            VALUES(NEW.religion_code,NEW.religion_description);
        ELSE
		
        END IF;
    ELSIF TG_OP = 'UPDATE' then
    	IF EXISTS (SELECT 1 FROM religion_cpidb WHERE religion_code = NEW.religion_code) then
        	if ( OLD.religion_description IS DISTINCT FROM NEW.religion_description)  THEN 
        		UPDATE religion_cpidb SET religion_description = NEW.religion_description
       			WHERE religion_code = NEW.religion_code;
        	ELSE
            END IF;
    	ELSE
            INSERT INTO religion_cpidb (religion_code,religion_description)
            VALUES(NEW.religion_code,NEW.religion_description);
    	END IF;
    ELSIF TG_OP = 'DELETE' then
    	IF EXISTS (SELECT 1 FROM religion_cpidb WHERE religion_code = OLD.religion_code) then
    		DELETE FROM religion_cpidb WHERE religion_code = OLD.religion_code;
    	ELSE
        END IF;
    END IF;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_religion_sync" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
