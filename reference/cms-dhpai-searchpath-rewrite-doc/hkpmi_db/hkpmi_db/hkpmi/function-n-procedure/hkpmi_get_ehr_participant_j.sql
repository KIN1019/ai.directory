-- DROP FUNCTION hkpmi.hkpmi_get_ehr_participant_j(varchar, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_ehr_participant_j(par_patient_key character varying, par_hkid character varying, par_source_system character varying, par_source_function character varying DEFAULT NULL::character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
/* 20140317/C/Victor/Get eHR details with patient key and hkid */
/* 20140407/C/Victor/To export different result for PMI Deletion function (PMI_DELETION) */
DECLARE
    var_ehr_number VARCHAR(24);
    var_ehr_start_date VARCHAR(20);
    var_ehr_end_date VARCHAR(20);
    var_pas_patient_key VARCHAR(16);
    var_pas_hkic VARCHAR(24);
    var_ehr_hkic VARCHAR(24);
    var_ehr_non_ha_ind VARCHAR(2);
    var_ehr_flag VARCHAR(6);
    var_patient_hkid VARCHAR(24);
    var_document_type VARCHAR(4);
    var_other_doc_number VARCHAR(24);
    var_rowcount INTEGER;
    var_current_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_live_run_flag VARCHAR(2);
    var_ehr_full_name VARCHAR(200);
    var_pas_full_name VARCHAR(200);
    var_ehr_sex VARCHAR(2);
    var_pas_sex VARCHAR(2);
    var_ehr_dob VARCHAR(20);
    var_pas_dob VARCHAR(20);
    var_ehr_doc_type VARCHAR(12);
    var_ehr_doc_no VARCHAR(60);
    var_pas_doc_type VARCHAR(12);
    var_pas_doc_no VARCHAR(60);
    var_ehr_count INTEGER;
    var_ehr_hkid_count INTEGER;
    sql$rowcount BIGINT;
    var_last_name VARCHAR(96);
    var_first_name VARCHAR(96);
    var_sex VARCHAR(2);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_patient_name VARCHAR(96);
    var_patient_name_len INTEGER;
    var_document_code VARCHAR(2);
    var_comma_index INTEGER;
BEGIN
    <<error>>
    BEGIN
        /* Major keys not matched alert data fields */
        /* --To cater multiple eHR number cases with same patient key */
        SELECT
            run_flag
            INTO var_live_run_flag
            FROM ehr_event_conf
            WHERE config_id = 11 AND system_id = 'EHR_CMS_WS';

        IF var_live_run_flag <> 'Y' THEN
            BEGIN
                EXIT error;
            END;
        END IF;
        /* --------- Ensure the mandatory fields are not empty ---------- */

       IF par_patient_key IS NULL OR par_source_system IS NULL OR par_hkid IS NULL OR (LTRIM(RTRIM(par_patient_key)) = '') OR (LTRIM(RTRIM(par_source_system)) = '') OR (LTRIM(RTRIM(par_hkid)) = '') THEN
            BEGIN
                EXIT error;
            END;
        END IF;
        SELECT
            hkid
            INTO var_patient_hkid
            FROM patient
            WHERE patient_key = par_patient_key;
        /* ---------- Patient not found by patient key ---------- */
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF var_rowcount = 0 THEN
            BEGIN
                EXIT error;
            END;
        END IF;
        /* ---------- Check whether the HKID against the patient key ---------- */

        IF var_patient_hkid <> par_hkid THEN
            BEGIN
                EXIT error;
            END;
        END IF;

        IF par_source_function = 'PMI_DELETION' THEN
            BEGIN
                SELECT
                    pas_pky, pas_hkic, ehr_number, ehr_start_date, ehr_end_date
                    INTO var_pas_patient_key, var_pas_hkic, var_ehr_number, var_ehr_start_date, var_ehr_end_date
                    FROM ehr_patient_list
                    WHERE pas_hkic = par_hkid;
                /* 20140417/C/Victor/Confirmed in PAS support to eHR internal meeting */
                /* not allow to perform PMI deletion when eHR record is existed even the flag is WHD */
            END;
        ELSE
            BEGIN
                SELECT
                    timestamp_convert(localtimestamp)
                    INTO var_current_dtm;

                IF par_source_system IN ('CMS', 'PMS', 'CDR', 'RIS', 'ePR', 'MCAF', 'eSHR', 'LIS', 'MOE') THEN
                    BEGIN
                        /* --To cater multiple eHR number cases with same patient key */
                        SELECT
                            COUNT(1)
                            INTO var_ehr_count
                            FROM ehr_patient_list
                            WHERE pas_hkic = par_hkid AND ehr_flag IN ('VAL', 'MKU', 'MKC', 'MKE', 'MKP', 'MKM', 'MES') AND (ehr_ppi_ind IN ('Y') AND var_live_run_flag = 'Y');
                        SELECT
                            COUNT(1)
                            INTO var_ehr_hkid_count
                            FROM ehr_patient_list
                            WHERE pas_hkic = par_hkid AND ehr_flag IN ('VAL', 'MKU', 'MKC', 'MKE', 'MKP', 'MKM', 'MES') AND (ehr_ppi_ind IN ('Y') AND var_live_run_flag = 'Y') AND pas_doc_type = 'ID';
                        /* --if no of record > 1 and with document type = HKID */
                        IF (var_ehr_count > 1 AND var_ehr_hkid_count > 0) THEN
                            BEGIN
                                SELECT
                                    ehr_non_ha_ind, pas_pky, pas_hkic, ehr_number, ehr_start_date, ehr_end_date
                                    INTO var_ehr_non_ha_ind, var_pas_patient_key, var_pas_hkic, var_ehr_number, var_ehr_start_date, var_ehr_end_date
                                    FROM ehr_patient_list
                                    WHERE pas_hkic = par_hkid AND
                                    /* 20140730/M/Victor/updated by Erica to include 'MKM' and exclude 'MID' */
                                    ehr_flag IN ('VAL', 'MKU', 'MKC', 'MKE', 'MKP', 'MKM', 'MES') AND
                                    /* 20150818/M/Yorky - Retrieve PPI patients with consent on eHR only */
                                    /* 20151116/M/Yorky - Retrieve PPI patients with consent on eHR only after eHR is live run */
                                    (ehr_ppi_ind IN ('Y') AND var_live_run_flag = 'Y') AND pas_doc_type = 'ID'
                                    ORDER BY sys_dtm DESC NULLS FIRST;
                            END;
                        ELSE
                            BEGIN
                                SELECT
                                    ehr_non_ha_ind, pas_pky, pas_hkic, ehr_number, ehr_start_date, ehr_end_date
                                    INTO var_ehr_non_ha_ind, var_pas_patient_key, var_pas_hkic, var_ehr_number, var_ehr_start_date, var_ehr_end_date
                                    FROM ehr_patient_list
                                    WHERE pas_hkic = par_hkid AND
                                    /* 20140730/M/Victor/updated by Erica to include 'MKM' and exclude 'MID' */
                                    ehr_flag IN ('VAL', 'MKU', 'MKC', 'MKE', 'MKP', 'MKM', 'MES') AND
                                    /* 20150818/M/Yorky - Retrieve PPI patients with consent on eHR only */
                                    /* 20151116/M/Yorky - Retrieve PPI patients with consent on eHR only after eHR is live run */
                                    (ehr_ppi_ind IN ('Y') AND var_live_run_flag = 'Y')
                                    ORDER BY sys_dtm DESC NULLS FIRST;
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        SELECT
                            ehr_non_ha_ind, pas_pky, pas_hkic, ehr_number, ehr_start_date, ehr_end_date,
                            /* 20151119/M/Yorky - Include major keys for major key not matched alert */
                            ehr_full_name, ehr_sex, ehr_dob, ehr_doc_type, ehr_doc_no, pas_full_name, pas_sex, pas_dob, pas_doc_type, pas_doc_no, ehr_flag,
                            /* 20151120/M/Victor - Include eHR HKID for major key not matched alert */
                            ehr_hkic
                            INTO var_ehr_non_ha_ind, var_pas_patient_key, var_pas_hkic, var_ehr_number, var_ehr_start_date, var_ehr_end_date, var_ehr_full_name, var_ehr_sex, var_ehr_dob, var_ehr_doc_type, var_ehr_doc_no, var_pas_full_name, var_pas_sex, var_pas_dob, var_pas_doc_type, var_pas_doc_no, var_ehr_flag, var_ehr_hkic
                            FROM ehr_patient_list
                            WHERE pas_hkic = par_hkid AND
                            /* 20140730/M/Victor/updated by Erica to include 'MKM' and exclude 'MID' */
                            /* 20151117/M/Yorky-Include MKD for PAS to indicate major key not match patients during enrollment */
                            ehr_flag IN ('VAL', 'MKD', 'MKU', 'MKC', 'MKE', 'MKP', 'MKM', 'MES') AND
                            /* 20150818/M/Yorky - Retrieve PPI patients with consent on eHR only */
                            /* 20151116/M/Yorky - Retrieve PPI patients with consent on eHR only after eHR is live run */
                            (ehr_ppi_ind IN ('Y') AND var_live_run_flag = 'Y');
                    END;
                END IF;
            END;
        END IF;
        /* ---------- Format start/end date in DD/MM/YYYY Format ---------- */

        IF var_ehr_start_date IS NOT NULL AND var_ehr_start_date <> '' THEN
            BEGIN
                SELECT
                    CONCAT(SAFE_SUBSTRING(var_ehr_start_date, 7, 2), '/', SAFE_SUBSTRING(var_ehr_start_date, 5, 2), '/', SAFE_SUBSTRING(var_ehr_start_date, 1, 4))
                    INTO var_ehr_start_date;
            END;
        END IF;

        IF var_ehr_end_date IS NOT NULL AND var_ehr_end_date <> '' THEN
            BEGIN
                SELECT
                    CONCAT(SAFE_SUBSTRING(var_ehr_end_date, 7, 2), '/', SAFE_SUBSTRING(var_ehr_end_date, 5, 2), '/', SAFE_SUBSTRING(var_ehr_end_date, 1, 4))
                    INTO var_ehr_end_date;
            END;
        END IF;
        /* ---------- Return eHR details for CMS ---------- */

        IF par_source_system IN ('CMS', 'PMS', 'CDR', 'RIS', 'ePR', 'MCAF', 'eSHR', 'LIS', 'MOE') THEN
            BEGIN
                /* ---------- Return patient information for CMS ---------- */
                SELECT
                    RTRIM(patient_name), sex, dob,
                    /* 20141105/C/Victor/Simon preferred to get document code and number from patient table instead of patient_doc_info */
                    SAFE_SUBSTRING(filler, 1, 1), other_doc_no
                    INTO var_patient_name, var_sex, var_dob, var_document_code, var_other_doc_number
                    FROM patient
                    WHERE hkid = var_pas_hkic;
                /* ---------- Split the patient_name into last_name and first_name ---------- */
                SELECT
                    LENGTH(var_patient_name)
                    INTO var_patient_name_len;

                IF var_patient_name_len > 0 THEN
                    BEGIN
                        SELECT
                            '', ''
                            INTO var_last_name, var_first_name;
                        SELECT
                            STRPOS(var_patient_name, ',')
                            INTO var_comma_index;

                        IF var_comma_index <> 0 THEN
                            BEGIN
                                SELECT
                                    RTRIM(LTRIM(SAFE_SUBSTRING(var_patient_name, 1, var_comma_index - 1)))
                                    INTO var_last_name;

                                IF var_comma_index < LENGTH(var_patient_name) THEN
                                    BEGIN
                                        SELECT
                                            RTRIM(LTRIM(SAFE_SUBSTRING(var_patient_name, var_comma_index + 1, LENGTH(var_patient_name) - var_comma_index)))
                                            INTO var_first_name;
                                    END;
                                END IF;
                            END;
                        ELSE
                            BEGIN
                                SELECT
                                    RTRIM(LTRIM(var_patient_name))
                                    INTO var_last_name;
                            END;
                        END IF;
                        /*
                        cater the patient name which has no last name (e.g. DAVID, ), for the case, the name should be returned as first name
                        confirmed in PAS support for eHR internal meeting on 14/04/2014
                        */
                        IF var_first_name IS NULL OR LENGTH(var_first_name) = 0 THEN
                            BEGIN
                                SELECT
                                    var_last_name
                                    INTO var_first_name;
                                SELECT
                                    ''
                                    INTO var_last_name;
                            END;
                        END IF;
                    END;
                END IF;
                /* 20141105/C/Victor/group the document type for CMS */
                IF var_document_code IS NOT NULL AND var_document_code <> '' THEN
                    BEGIN
                        SELECT
                            CASE
                                WHEN document_type IN ('AE', 'AN', 'AR') THEN 'AR'
                                WHEN document_type IN ('BC', 'BE', 'BN') THEN 'BC'
                                ELSE document_type
                            END
                            INTO var_document_type
                            FROM document_type
                            WHERE document_code = var_document_code;
                    END;
                END IF;
                /* ---------- Return eHR details for CMS ---------- */
                OPEN p_refcur FOR
                SELECT
                    var_pas_patient_key AS patient_key, var_pas_hkic AS hkid, var_ehr_number AS ehr_no, var_ehr_start_date AS ehr_start_date, var_ehr_end_date AS ehr_end_date, var_last_name AS surname, var_first_name AS given_name, var_sex AS sex, var_dob AS dob, var_document_type AS document_type, var_other_doc_number AS other_doc_no, var_ehr_non_ha_ind AS non_ha_data;
            	return next p_refcur;
END;
        ELSE
            /* ---------- Return eHR details for PAS ---------- */
            BEGIN
                /* 20151119/M/Yorky - Include major keys for major key not matched alert */
                IF var_ehr_dob IS NOT NULL AND var_ehr_dob <> '' THEN
                    BEGIN
                        SELECT
                            CONCAT(SAFE_SUBSTRING(var_ehr_dob, 7, 2), '/', SAFE_SUBSTRING(var_ehr_dob, 5, 2), '/', SAFE_SUBSTRING(var_ehr_dob, 1, 4))
                            INTO var_ehr_dob;
                    END;
                END IF;

                IF var_pas_dob IS NOT NULL AND var_pas_dob <> '' THEN
                    BEGIN
                        SELECT
                            CONCAT(SAFE_SUBSTRING(var_pas_dob, 7, 2), '/', SAFE_SUBSTRING(var_pas_dob, 5, 2), '/', SAFE_SUBSTRING(var_pas_dob, 1, 4))
                            INTO var_pas_dob;
                    END;
                END IF;
                OPEN p_refcur FOR
                SELECT
                    var_pas_patient_key AS patient_key, var_pas_hkic AS pas_hkid, var_ehr_number AS ehr_no, var_ehr_start_date AS ehr_start_date, var_ehr_end_date AS ehr_end_date,
                    /* Additional data fields for major keys not matched alert */
                    var_ehr_hkic AS ehr_hkid, var_ehr_full_name AS ehr_full_name, var_ehr_sex AS ehr_sex, var_ehr_dob AS ehr_dob, var_ehr_doc_type AS ehr_doc_type, var_ehr_doc_no AS ehr_doc_no, var_pas_full_name AS pas_full_name, var_pas_sex AS pas_sex, var_pas_dob AS pas_dob, var_pas_doc_type AS pas_doc_type, var_pas_doc_no AS pas_doc_no, var_ehr_flag AS ehr_flag;
            	return next p_refcur;
END;
        END IF;

        RETURN;
    END;

    IF par_source_system IN ('CMS', 'PMS', 'CDR', 'RIS', 'ePR', 'MCAF', 'eSHR', 'LIS', 'MOE') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                NULL AS patient_key, NULL AS hkid, NULL AS ehr_no, NULL AS ehr_start_date, NULL AS ehr_end_date, NULL AS surname, NULL AS given_name, NULL AS sex, NULL AS dob, NULL AS document_type, NULL AS other_doc_no, NULL AS non_ha_data;
        	return next p_refcur;
END;
    ELSE
        BEGIN
            OPEN p_refcur FOR
            SELECT
                NULL AS patient_key, NULL AS pas_hkid, NULL AS ehr_no, NULL AS ehr_start_date, NULL AS ehr_end_date,
                /* Additional data fields for major keys not matched alert */
                NULL AS ehr_hkid, NULL AS ehr_full_name, NULL AS ehr_sex, NULL AS ehr_dob, NULL AS ehr_doc_type, NULL AS ehr_doc_no, NULL AS pas_full_name, NULL AS pas_sex, NULL AS pas_dob, NULL AS pas_doc_type, NULL AS pas_doc_no, NULL AS ehr_flag;
        	return next p_refcur;
END;
    END IF;
END;
$function$
;


ALTER FUNCTION "hkpmi_get_ehr_participant_j" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
