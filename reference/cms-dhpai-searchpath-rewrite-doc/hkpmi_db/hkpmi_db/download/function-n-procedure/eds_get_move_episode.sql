-- DROP FUNCTION download.eds_get_move_episode(timestamp, int4);

CREATE OR REPLACE FUNCTION download.eds_get_move_episode(par_system_dtm_in timestamp without time zone, par_number_of_rec integer)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
    var_version_no VARCHAR(16);
    var_retrieve_dtime TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
    /*
    **
    set rowcount 1
    if exists(select hospital_code from transaction_log
    	where
    		system_dtm > @retrieve_dtime and
    		(type in ('040' ,'020', '030','031')))
    begin
    **
    */
    /*
    **
    end
    **
    */
    BEGIN
        SELECT
            '1.3.2g7'
            INTO var_version_no;
        SELECT
            - 1 * INTERVAL '1 second' + par_system_dtm_in::TIMESTAMP
            INTO var_retrieve_dtime;

        IF par_system_dtm_in IS NULL THEN
            BEGIN
                OPEN p_refcur FOR
                SELECT
                    CONCAT('Version ', var_version_no);
                RETURN NEXT p_refcur;
            END;
        END IF;

        OPEN p_refcur FOR
        SELECT
            to_char(system_dtm::TIMESTAMP WITHOUT TIME ZONE, 'Mon DD YYYY HH:MI:SS.MSpm'), type, hospital_code, hkid, patient_key, case_no, old_hkid, old_patient_key
            FROM transaction_log
            WHERE system_dtm > var_retrieve_dtime AND (type IN ('040', '020', '030', '031')) AND NOT (old_hkid = hkid AND old_patient_key = patient_key)
            ORDER BY system_dtm
            LIMIT par_number_of_rec;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            OPEN p_refcur FOR
            SELECT
                ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ';
            RETURN NEXT p_refcur;
        ELSE
            RETURN NEXT p_refcur;
        END IF;
       
        EXCEPTION
            WHEN OTHERS THEN
                OPEN p_refcur FOR
                SELECT
                    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ';
                RETURN NEXT p_refcur;
    END;
END;
$function$
;

ALTER FUNCTION "eds_get_move_episode" OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";