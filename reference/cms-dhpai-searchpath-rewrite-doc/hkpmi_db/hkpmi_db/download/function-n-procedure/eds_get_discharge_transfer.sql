-- DROP FUNCTION download.eds_get_discharge_transfer(bpchar, timestamp, int4);

CREATE OR REPLACE FUNCTION download.eds_get_discharge_transfer(par_pat_hosp_code character varying, par_system_dtm_in timestamp without time zone, par_number_of_rec integer)
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
    Removed in 1.1.0
    if @system_dtm_in = NULL
    begin
    	select 'Version ' + @version_no
    	return 0
    end
    */
    /* 1.2.0 select @retrieve_dtime = dateadd(ss, -1, @system_dtm_in) */
    
    /*
    Removed in 1.1.0
    if exists(select hospital_code from transaction_log
    	where
    		system_dtm > @retrieve_dtime and
    		((type in ('140' ,'220')) or ((left(ltrim(type), 2) = '13')) or (left(ltrim(type), 2) = '21')))
    
    
    begin
    */
    
    /*
    Removed in 1.1.0
    end
    */
    BEGIN
        IF par_system_dtm_in = NULL OR par_number_of_rec = NULL OR par_pat_hosp_code = NULL THEN
            BEGIN
                OPEN p_refcur FOR
                SELECT
                    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ';
                RETURN NEXT p_refcur;
            END;
        END IF;
        /*
        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
        set rowcount 1
        */
        SELECT
            '1.4.0'
            INTO var_version_no;
        SELECT
            par_system_dtm_in
            INTO var_retrieve_dtime;
        /*
        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @number_of_rec clause of SET statement is not supported. Perform a manual conversion.]
        set rowcount @number_of_rec
        */
        OPEN p_refcur FOR
        /* 1.3.0 */
        /* --		convert(char(8), system_dtm, 112) + ' ' + convert(char(8), system_dtm, 108) system_dtm, */
        SELECT
            to_char(system_dtm::TIMESTAMP WITHOUT TIME ZONE, 'Mon DD YYYY HH:MI:SS.MSpm') AS system_dtm, hospital_code, type, to_char(adm_dtm::TIMESTAMP WITHOUT TIME ZONE, 'Mon DD YYYY HH:MI:SS.MSpm') AS adm_dtm, hkid, patient_key, patient_name, sex, to_char(dob::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') AS dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, marital_status, race, death_indicator, to_char(death_date::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') AS death_date, death_external_cause, death_diagnosis, case_no, source_indicator, source_code, patient_type, discharge_code, destination_code, case_type, ward_code, specialty_code, bed_no, ward_class, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, source_system, CONCAT(to_char(source_system_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ' ', to_char(source_system_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')) AS source_system_dtm, CONCAT(to_char(transfer_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ' ', to_char(transfer_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')) AS transfer_dtm, CONCAT(to_char(discharge_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ' ', to_char(discharge_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')) AS discharge_dtm
            FROM transaction_log
            WHERE
            /* Added in 1.1.0 */
            hospital_code = par_pat_hosp_code AND system_dtm > var_retrieve_dtime AND
            /* Update in 1.1.0	((type in ('140' ,'220')) or ((left(ltrim(type), 2) = '13')) or (left(ltrim(type), 2) = '21')) */
            /* Update in 1.4.0  ((type ='220') or (left(ltrim(type), 2) = '21')) */
            ((type IN ('140', '220')) OR (LEFT(LTRIM(type), 2) = '21'))
            ORDER BY system_dtm
           	LIMIT par_number_of_rec;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        IF sql$rowcount = 0 THEN
            OPEN p_refcur FOR
                SELECT
                    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ';
                RETURN NEXT p_refcur;
        ELSE
            RETURN NEXT p_refcur;
        END IF;

        EXCEPTION
            WHEN OTHERS THEN
                OPEN p_refcur FOR
                SELECT
                    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ';
                RETURN NEXT p_refcur;
    END;
    /* updated in return 0 */
END;
$function$
;

ALTER FUNCTION "eds_get_discharge_transfer" OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";