-- DROP FUNCTION hkpmi.cvi_data_collection();

CREATE OR REPLACE FUNCTION hkpmi.cvi_data_collection()
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
    var_hospital_code CHAR(3);
    var_case_no CHAR(12);
    var_patient_key CHAR(8);
    var_dose_order VARCHAR(30);
    var_vaccine_brand VARCHAR(50);
    var_dose_date TIMESTAMP WITHOUT TIME ZONE;
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    sample_cursor CURSOR FOR
    /* --SELECT patient_key from temp_cvi_dose */
    SELECT
        tcd.hospital_code, tcd.case_no, tcd.patient_key, cd.dose_order, cd.vaccine_brand, cd.dose_date, cd.update_datetime
        FROM temp_cvi_dose AS tcd, hkpmi_patient_cvi_dose_info AS cd, pmi_case AS p
        WHERE tcd.patient_key = cd.patient_key AND tcd.case_no = p.case_no AND tcd.hospital_code = p.hospital_code
        ORDER BY patient_key NULLS FIRST, dose_date NULLS FIRST, vaccine_brand NULLS FIRST, dose_order NULLS FIRST;
BEGIN
    UPDATE temp_cvi_dose AS tcd
    SET patient_key = p.patient_key, adm_dtm = p.adm_dtm, discharge_code = p.discharge_code, discharge_dtm = p.discharge_dtm
    FROM pmi_case AS p
        WHERE tcd.case_no = p.case_no AND tcd.hospital_code = p.hospital_code;
    /* declare a cursor */
    /* open cursor and fetch first row into variables */
    OPEN sample_cursor;
    FETCH NEXT FROM sample_cursor INTO var_hospital_code, var_case_no, var_patient_key, var_dose_order, var_vaccine_brand, var_dose_date, var_update_datetime;
    /* check for a new row */

    WHILE (CASE FOUND::INT
        WHEN 0 THEN - 1
        ELSE 0
    END) = 0 LOOP
        /* do complex operation here */
        IF EXISTS (SELECT
            1
            FROM hkpmi_patient_cvi_record AS cr, patient AS p
            WHERE cr.patient_key = var_patient_key AND cr.status = 'VACCINATED' AND cr.update_datetime <= var_update_datetime AND p.patient_key = var_patient_key AND p.hkid NOT LIKE 'U%') THEN
            BEGIN
                IF (SELECT
                    dose_date_1st
                    FROM temp_cvi_dose
                    WHERE patient_key = var_patient_key AND hospital_code = var_hospital_code AND case_no = var_case_no) IS NULL THEN
                    UPDATE temp_cvi_dose
                    SET dose_1st = var_dose_order, vaccine_brand_1st = var_vaccine_brand, dose_date_1st = var_dose_date
                        WHERE patient_key = var_patient_key AND hospital_code = var_hospital_code AND case_no = var_case_no;
                ELSE
                    IF (SELECT
                        dose_date_2nd
                        FROM temp_cvi_dose
                        WHERE patient_key = var_patient_key AND hospital_code = var_hospital_code AND case_no = var_case_no) IS NULL THEN
                        UPDATE temp_cvi_dose
                        SET dose_2nd = var_dose_order, vaccine_brand_2nd = var_vaccine_brand, dose_date_2nd = var_dose_date
                            WHERE patient_key = var_patient_key AND hospital_code = var_hospital_code AND case_no = var_case_no;
                    ELSE
                        IF (SELECT
                            dose_date_3rd
                            FROM temp_cvi_dose
                            WHERE patient_key = var_patient_key AND hospital_code = var_hospital_code AND case_no = var_case_no) IS NULL THEN
                            UPDATE temp_cvi_dose
                            SET dose_3rd = var_dose_order, vaccine_brand_3rd = var_vaccine_brand, dose_date_3rd = var_dose_date
                                WHERE patient_key = var_patient_key AND hospital_code = var_hospital_code AND case_no = var_case_no;
                        ELSE
                            IF (SELECT
                                dose_date_4th
                                FROM temp_cvi_dose
                                WHERE patient_key = var_patient_key AND hospital_code = var_hospital_code AND case_no = var_case_no) IS NULL THEN
                                UPDATE temp_cvi_dose
                                SET dose_4th = var_dose_order, vaccine_brand_4th = var_vaccine_brand, dose_date_4th = var_dose_date
                                    WHERE patient_key = var_patient_key AND hospital_code = var_hospital_code AND case_no = var_case_no;
                            ELSE
                                IF (SELECT
                                    dose_date_5th
                                    FROM temp_cvi_dose
                                    WHERE patient_key = var_patient_key AND hospital_code = var_hospital_code AND case_no = var_case_no) IS NULL THEN
                                    UPDATE temp_cvi_dose
                                    SET dose_5th = var_dose_order, vaccine_brand_5th = var_vaccine_brand, dose_date_5th = var_dose_date
                                        WHERE patient_key = var_patient_key AND hospital_code = var_hospital_code AND case_no = var_case_no;
                                ELSE
                                    IF (SELECT
                                        dose_date_6th
                                        FROM temp_cvi_dose
                                        WHERE patient_key = var_patient_key AND hospital_code = var_hospital_code AND case_no = var_case_no) IS NULL THEN
                                        UPDATE temp_cvi_dose
                                        SET dose_6th = var_dose_order, vaccine_brand_6th = var_vaccine_brand, dose_date_6th = var_dose_date
                                            WHERE patient_key = var_patient_key AND hospital_code = var_hospital_code AND case_no = var_case_no;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END;
        END IF;
        /* get next available row into variables */
        FETCH NEXT FROM sample_cursor INTO var_hospital_code, var_case_no, var_patient_key, var_dose_order, var_vaccine_brand, var_dose_date, var_update_datetime;
    END LOOP;
    CLOSE sample_cursor;
    OPEN p_refcur FOR
    SELECT
        hospital_code AS "Hospital code", case_no AS "Case No", patient_key AS "Patient Key", adm_dtm AS "Admission Date Time", discharge_code AS "Discharge Code", discharge_dtm AS "Discharge Date Time", dose_1st AS "1st Dose Order", vaccine_brand_1st AS "1st Dose Vaccine Brand", dose_date_1st AS "1st Dose Date", dose_2nd AS "2nd Dose Order", vaccine_brand_2nd AS "2nd Dose Vaccine Brand", dose_date_2nd AS "2nd Dose Date", dose_3rd AS "3rd Dose Order", vaccine_brand_3rd AS "3rd Dose Vaccine Brand", dose_date_3rd AS "3rd Dose Date", dose_4th AS "4th Dose Order", vaccine_brand_4th AS "4th Dose Vaccine Brand", dose_date_4th AS "4th Dose Date", dose_5th AS "5th Dose Order", vaccine_brand_5th AS "5th Dose Vaccine Brand", dose_date_5th AS "5th Dose Date", dose_6th AS "6th Dose Order", vaccine_brand_6th AS "6th Dose Vaccine Brand", dose_date_6th AS "6th Dose Date"
        FROM temp_cvi_dose;
	return next p_refcur;
END;
$function$
;


ALTER FUNCTION "cvi_data_collection" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
