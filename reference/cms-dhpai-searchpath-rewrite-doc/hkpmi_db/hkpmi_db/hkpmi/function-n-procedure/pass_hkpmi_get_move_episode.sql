CREATE OR REPLACE FUNCTION pass_hkpmi_get_move_episode(IN par_hospital_code VARCHAR, IN par_case_no VARCHAR, IN par_from_patient_key VARCHAR, IN par_to_patient_key VARCHAR, IN par_create_dtm TIMESTAMP WITHOUT TIME ZONE DEFAULT null)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_pin VARCHAR(12);
    var_pin_len INTEGER;

    p_refcur refcursor;
BEGIN
    SELECT
        LTRIM(RTRIM(par_case_no))
        INTO var_pin;
    SELECT
        OCTET_LENGTH(var_pin)
        INTO var_pin_len;

    IF var_pin_len = 11 THEN
        SELECT
            CONCAT(' ', var_pin)
            INTO par_case_no;
    ELSE
        SELECT
            var_pin
            INTO par_case_no;
    END IF;
    OPEN p_refcur FOR
    SELECT
        m.hospital_code, m.case_no, m.move_status,
        CASE
            WHEN m.move_status = 'O' THEN 'Different patient (yellow flag)'
            WHEN m.move_status = 'C' THEN 'Completed data checking'
            WHEN m.move_status = 'M' THEN 'Merged patient'
            WHEN m.move_status = 'S' THEN 'Same patient'
            ELSE 'N/A'
        END AS description, m.from_patient_key, pf.hkid, m.to_patient_key, pt.hkid,
        /* m.create_dtm */
        (CASE
            WHEN m.create_dtm IS NOT NULL THEN CONCAT(to_char(m.create_dtm,'DD-MM-YYYY'), ' ', to_char(m.create_dtm,'HH24:MI:SS:MS'))
            ELSE NULL
        END) AS create_dtm
        FROM move_episode_indicator AS m
        LEFT OUTER JOIN patient AS pt
            ON (m.to_patient_key = pt.patient_key)
        LEFT OUTER JOIN patient AS pf
            ON (m.from_patient_key = pf.patient_key)
        WHERE m.hospital_code = par_hospital_code AND m.case_no = par_case_no AND m.from_patient_key = par_from_patient_key AND m.to_patient_key = par_to_patient_key AND (m.create_dtm = par_create_dtm OR par_create_dtm IS NULL);
    return next p_refcur;
    RETURN;  
END;
$function$
;

ALTER FUNCTION "pass_hkpmi_get_move_episode" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
