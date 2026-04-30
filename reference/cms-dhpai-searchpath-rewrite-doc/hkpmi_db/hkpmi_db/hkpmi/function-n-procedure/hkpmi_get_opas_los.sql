-- DROP FUNCTION hkpmi.hkpmi_get_opas_los(bpchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_opas_los(par_hkid varchar, par_from_date timestamp without time zone, par_to_date timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_prk VARCHAR(8);
    var_return_code INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            0
            INTO var_return_code;
        SELECT
            patient_key
            INTO var_prk
            FROM patient
            WHERE hkid = par_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            BEGIN
                SELECT
                    1
                    INTO var_return_code;
                EXIT return_error;
            END;
        END IF;
        DROP TABLE IF EXISTS t$temp_case;
        CREATE TEMPORARY TABLE t$temp_case
        ("case_no" VARCHAR(12),
            "hospital_code" VARCHAR(3),
            "adm_dtm" TIMESTAMP WITHOUT TIME ZONE,
            "dsch_dtm" TIMESTAMP WITHOUT TIME ZONE NULL,
            "last_spec" VARCHAR(4),
            "los" INTEGER NULL);

        IF par_to_date IS NULL THEN
            SELECT
                1 * INTERVAL '1 day' + par_from_date::TIMESTAMP
                INTO par_to_date;
        ELSE
            SELECT
                1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
                INTO par_to_date;
        END IF;
        INSERT INTO t$temp_case (case_no, hospital_code, adm_dtm, dsch_dtm, last_spec)
        SELECT
            case_no, hospital_code, adm_dtm, discharge_dtm, last_specialty_code
            FROM pmi_case
            WHERE patient_key = var_prk AND adm_dtm < par_to_date AND
            /* --			and adm_dtm >= @from_date */
            /* updated for patient ever stayed in the date range */
            (discharge_code IS NULL OR (discharge_code IS NOT NULL AND discharge_dtm >= par_from_date)) AND
            /* updated for patient ever stayed in the date range */
            case_type = 'I';
        /*
        update #temp_case set
        	los = datediff(dd,adm_dtm,dsch_dtm)
        	where dsch_dtm is not null
        
        update #temp_case set
        	los = datediff(dd,adm_dtm,getdate())
        	where dsch_dtm is null
        */
        UPDATE t$temp_case
        SET "los" = DATE_PART('days', "dsch_dtm"::TIMESTAMP - "adm_dtm"::TIMESTAMP)
            WHERE dsch_dtm IS NOT NULL AND adm_dtm >= par_from_date;
        UPDATE t$temp_case
        SET "los" = DATE_PART('days', "dsch_dtm"::TIMESTAMP - par_from_date::TIMESTAMP)
            WHERE dsch_dtm IS NOT NULL AND adm_dtm < par_from_date;
        UPDATE t$temp_case
        SET "los" = DATE_PART('days', timestamp_convert(localtimestamp)::TIMESTAMP - "adm_dtm"::TIMESTAMP)
            WHERE dsch_dtm IS NULL AND adm_dtm >= par_from_date;
        UPDATE t$temp_case
        SET "los" = DATE_PART('days', timestamp_convert(localtimestamp)::TIMESTAMP - par_from_date::TIMESTAMP)
            WHERE dsch_dtm IS NULL AND adm_dtm < par_from_date;
        OPEN p_refcur FOR
        SELECT
            t$temp_case.case_no, t$temp_case.hospital_code, t$temp_case.adm_dtm, t$temp_case.dsch_dtm, t$temp_case.last_spec, t$temp_case.los
            FROM t$temp_case;
		return next p_refcur;
        EXIT return_error;
    END;

    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$temp_case;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;


ALTER FUNCTION "hkpmi_get_opas_los" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
