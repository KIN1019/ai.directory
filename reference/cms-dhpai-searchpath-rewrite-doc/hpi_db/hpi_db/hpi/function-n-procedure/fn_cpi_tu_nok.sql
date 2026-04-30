-- DROP FUNCTION hpi.fn_cpi_tu_nok();

CREATE OR REPLACE FUNCTION fn_cpi_tu_nok()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_return_code INTEGER;
    var_valid_flag VARCHAR(1);
    var_hkid VARCHAR(12);
    var_dist VARCHAR(5);
    var_patient_key VARCHAR(8);
  
    update$district BOOLEAN = FALSE;
BEGIN
    CASE TG_OP
        WHEN 'INSERT' THEN
            update$district = TRUE;
        WHEN 'UPDATE' THEN
            update$district = ((SELECT
                array_agg(district)
                FROM deleted) != (SELECT
                array_agg(district)
                FROM inserted));
        ELSE
            update$district := FALSE;
    END CASE;
    SELECT
        hkid, district, patient_key
        INTO var_hkid, var_dist, var_patient_key
        FROM inserted;

    IF (var_hkid IS NOT NULL) THEN
        BEGIN
            CALL cpi_pq_validate_hkid(var_return_code, var_hkid, var_valid_flag );

            IF (var_valid_flag = 'N') THEN
                BEGIN
                    IF var_return_code = 1 THEN
                        BEGIN
                            RAISE EXCEPTION 'Invalid HKID, fail to update NOK record!' USING ERRCODE = '25000';
                            RETURN NULL;
                        END;
                    ELSE
                        IF var_return_code = 2 THEN
                            BEGIN
                                RAISE EXCEPTION 'Invalid HKID check digit, fail to update NOK record!' USING ERRCODE = '25000';
                                RETURN NULL;
                            END;
                        END IF;
                    END IF;
                END;
            END IF;
        END;
    END IF;

    IF update$district THEN
        BEGIN
            IF var_dist IS NOT NULL THEN
                BEGIN
                    /* ---Modified by WL on 18 AUG 99 - */
                    /* --exec @return_code = cpi_pq_validate_district @dist, @valid_flag */
                    CALL cpi_pq_validate_district(var_return_code, var_dist, var_valid_flag );
					
                    IF var_return_code <> 0 OR var_valid_flag <> 'Y' THEN
                        BEGIN
                            RAISE EXCEPTION '% % % ', 'UPDATE', 'cpi_nok', 'district' USING ERRCODE = '200012';
                            RETURN NULL;
                        END;
                    END IF;
                END;
            END IF;
        END;
    END IF;
    /*
    if update(patient_key)
    begin
    	if not exists(select * from cpi_patient
    		where patient_key = @patient_key)
    	begin
    		raiserror 200012, "UPDATE", "cpi_nok", "cpi_patient"
    		return
    	end
    end
    */
    /* --To check duplicate key exception */
   
    RETURN NULL;
END;
$function$
;

;ALTER FUNCTION "fn_cpi_tu_nok" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
