CREATE OR REPLACE FUNCTION hkpmi_get_cvi_vaccine_record(par_patient_key character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_status VARCHAR(20);
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
	p_refcur refcursor;
BEGIN
    DROP TABLE IF EXISTS t$temp_vaccine_record;
    CREATE TEMPORARY TABLE t$temp_vaccine_record
    (vaccine_brand VARCHAR(50) NULL,
        dose_order VARCHAR(30) NULL,
        dose_date VARCHAR(12) NULL,
        dose_message VARCHAR(255) NULL,
        vac_center VARCHAR(50) NULL);
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
            --		, dose_order || ' ' || vaccine_brand || ' on ' || TO_CHAR(dose_date,  'DD-Mon-YYYY')|| '\n'
            		, '\t' || TO_CHAR(dose_date, 'dd-Mon-yyyy') || ': ' || dose_order || ' ' || vaccine_brand || '\n',
            		vac_center
            		FROM hkpmi_patient_cvi_dose_info
            		WHERE patient_key = par_patient_key
            		AND update_datetime >= var_update_datetime
            		ORDER BY dose_date DESC, vaccine_brand, dose_order desc;
        END;
    END IF;
    OPEN p_refcur FOR
    SELECT
        vaccine_brand, dose_order, dose_date, dose_message, vac_center
        FROM t$temp_vaccine_record;
    RETURN NEXT p_refcur;
END;
$function$;

;ALTER FUNCTION "hkpmi_get_cvi_vaccine_record" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
