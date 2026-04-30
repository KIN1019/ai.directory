-- DROP FUNCTION hkpmi.dw_bp_get_ehr_patient(timestamp, timestamp, int4);

CREATE OR REPLACE FUNCTION hkpmi.dw_bp_get_ehr_patient(par_startdtm timestamp without time zone, par_enddtm timestamp without time zone DEFAULT NULL::timestamp without time zone, par_maxrow integer DEFAULT 0)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
BEGIN
    /* Validate input parameters */
    IF par_startdtm IS NULL OR par_maxrow IS NULL THEN
        BEGIN
            RAISE NOTICE '@startdtm and @maxrow must not be null';
           
            RETURN;
        END;
    END IF;

    IF par_enddtm IS NOT NULL AND par_enddtm < par_startdtm THEN
        BEGIN
            RAISE NOTICE 'The value of @startdtm must not be greater than the value of @enddtm';
            
            RETURN;
        END;
    END IF;

    IF par_maxrow < 0 THEN
        BEGIN
            RAISE NOTICE 'The value of @maxrow must be greater than or equal to 0';
           
            RETURN;
        END;
    END IF;
    /* Set maximum number of rows to be returned */
    
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @maxrow clause of SET statement is not supported. Perform a manual conversion.]
    set rowcount @maxrow
    */
    /* Return eHR patient list */
    OPEN p_refcur FOR
    SELECT
        ehr_number, ehr_start_date, ehr_end_date, ehr_flag, pas_hkic, pas_pky, sys_dtm
        FROM ehr_patient_list
        WHERE sys_dtm >= par_startdtm AND (par_enddtm IS NULL OR sys_dtm < par_enddtm)
        ORDER BY sys_dtm NULLS FIRST
        LIMIT par_maxrow;
	
    /* Reset server settings (i.e. switch off row count limit) */
    
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
    set rowcount 0
    */
    /* Return success value */
	return next p_refcur;
    RETURN;
END;
$function$
;


ALTER FUNCTION "dw_bp_get_ehr_patient" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

