CREATE OR REPLACE FUNCTION hkpmi_get_cvi_vaccine_rec_v2(IN par_patient_key VARCHAR)
RETURNS SETOF refcursor
LANGUAGE plpgsql
AS 
$function$
DECLARE
	p_refcur refcursor;
    var_status VARCHAR(20);
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    DROP TABLE IF EXISTS t$temp_vaccine_record;
    CREATE TEMPORARY TABLE t$temp_vaccine_record
    (vaccine_brand VARCHAR(50),
        dose_order VARCHAR(30),
        dose_date VARCHAR(12),
        dose_message VARCHAR(255));
    SELECT
        status, update_datetime
        INTO var_status, var_update_datetime
        FROM hkpmi_patient_cvi_record
        WHERE patient_key = par_patient_key;

    IF var_status IS NOT NULL AND var_status = 'VACCINATED' AND EXISTS (SELECT
        1
        FROM hkpmi_patient_cvi_dose_info
        WHERE patient_key = par_patient_key AND update_datetime >= var_update_datetime) THEN
        BEGIN
            INSERT INTO t$temp_vaccine_record
            		SELECT vaccine_brand, dose_order, TO_CHAR(dose_date, 'dd-Mon-yyyy')
            --		, dose_order + ' ' + vaccine_brand + ' on ' + STR_REPLACE(CONVERT(varchar, dose_date, 106),' ','-') + '\n'
            		, '\t' || TO_CHAR(dose_date, 'dd-Mon-yyyy') || ': ' || dose_order || ' ' || vaccine_brand || '\n'
            		FROM hkpmi_patient_cvi_dose_info
            		WHERE patient_key = par_patient_key
            		AND update_datetime >= var_update_datetime
            		ORDER BY dose_date DESC, vaccine_brand, dose_order desc;
        END;
    END IF;
    OPEN p_refcur FOR
    SELECT
        vaccine_brand, dose_order, dose_date, dose_message
        FROM t$temp_vaccine_record;
    RETURN NEXT p_refcur;
END;
$function$;


;ALTER FUNCTION "hkpmi_get_cvi_vaccine_rec_v2" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
