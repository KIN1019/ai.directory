-- DROP FUNCTION hkpmi.hkpmi_get_acute_pp_transaction(timestamp, timestamp);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_acute_pp_transaction(par_from_dtm timestamp without time zone, par_to_dtm timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
BEGIN
    IF par_from_dtm IS NULL OR par_to_dtm IS NULL THEN
        BEGIN
            RAISE NOTICE 'Invalid time range';

            RETURN;
        END;
    END IF;

    IF par_from_dtm > par_to_dtm OR par_from_dtm < - 3 * INTERVAL '1 month' + localtimestamp::TIMESTAMP OR par_to_dtm < - 3 * INTERVAL '1 month' + localtimestamp::TIMESTAMP OR par_from_dtm > localtimestamp OR par_to_dtm > localtimestamp THEN
        BEGIN
            RAISE NOTICE 'Invalid time range';

            RETURN;
        END;
    END IF;

    IF par_to_dtm > 1 * INTERVAL '1 month' + par_from_dtm::TIMESTAMP THEN
        BEGIN
            RAISE NOTICE 'Date range should be within one month';

            RETURN;
        END;
    END IF;
    SELECT
        1 * INTERVAL '1 day' + par_to_dtm::TIMESTAMP
        INTO par_to_dtm;
    OPEN p_refcur FOR
    SELECT
        t.hospital_code AS hospital_code, t.case_no AS case_no, t.adm_dtm AS admission_datetime, p.pp_code AS pp_code
        FROM download_dbo.transaction_log AS t, pmi_case AS p
        WHERE t.system_dtm >= par_from_dtm AND t.system_dtm < par_to_dtm AND t.type = '100' AND t.case_type = 'I' AND t.hospital_code IN ('AHN', 'KWH', 'PMH', 'QEH', 'TMH', 'UCH', 'YCH', 'CMC', 'RH', 'PYN', 'TKO') AND t.hospital_code = p.hospital_code AND t.case_no = p.case_no AND p.pp_code IS NOT NULL AND p.pp_code <> 'NONE'
        /* --and p.pp_code in (select pp_code from temp_pp_consent) */
        ORDER BY hospital_code NULLS FIRST, adm_dtm NULLS FIRST;
	return next p_refcur;
END;
$function$
;


ALTER FUNCTION "hkpmi_get_acute_pp_transaction" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

