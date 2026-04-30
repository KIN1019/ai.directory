CREATE OR REPLACE FUNCTION pass_hkpmi_get_mother_baby(IN par_baby_hospital_code VARCHAR, IN par_baby_hkid VARCHAR DEFAULT null, IN par_baby_case_no VARCHAR DEFAULT null)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_c_patient_key VARCHAR(8);
    var_error_msg VARCHAR(255);
    var_rowcount INTEGER;
    var_error INTEGER;
    var_pin VARCHAR(12);
    var_pin_len INTEGER;

    p_refcur refcursor;
BEGIN
    IF par_baby_case_no IS NOT NULL THEN
        BEGIN
            SELECT
                LTRIM(RTRIM(par_baby_case_no))
                INTO var_pin;
            SELECT
                OCTET_LENGTH(var_pin)
                INTO var_pin_len;

            IF var_pin_len = 11 THEN
                SELECT
                    CONCAT(' ', var_pin)
                    INTO par_baby_case_no;
            ELSE
                SELECT
                    var_pin
                    INTO par_baby_case_no;
            END IF;
        END;
    END IF;

    IF par_baby_hkid IS NOT NULL THEN
        BEGIN
            SELECT
                LTRIM(RTRIM(par_baby_hkid))
                INTO var_pin;
            SELECT
                OCTET_LENGTH(var_pin)
                INTO var_pin_len;

            IF var_pin_len = 8 THEN
                SELECT
                    CONCAT(' ', var_pin)
                    INTO par_baby_hkid;
            ELSE
                SELECT
                    var_pin
                    INTO par_baby_hkid;
            END IF;
        END;
    END IF;

    IF par_baby_case_no IS NOT NULL THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                p1.hkid AS motherhkid, p2.hkid AS babyhkid, p1.patient_name AS mothername, p2.patient_name AS babyname, m.birth_order, m.mother_hospital_code, m.mother_case_no, m.baby_hospital_code, m.baby_case_no, m.create_by, CONCAT(to_char(m.create_datetime,'DD-MM-YYYY'), ' ', to_char(m.create_datetime,'HH24:MI:SS')) AS create_datetime, m.update_by, CONCAT(to_char(m.update_datetime,'DD-MM-YYYY'), ' ', to_char(m.update_datetime,'HH24:MI:SS')) AS update_datetime
                FROM mother_baby_case AS m, patient AS p1, patient AS p2, pmi_case AS c1, pmi_case AS c2
                WHERE c1.patient_key = p1.patient_key AND c2.patient_key = p2.patient_key AND m.mother_case_no = c1.case_no AND m.mother_hospital_code = c1.hospital_code AND m.baby_case_no = c2.case_no AND m.baby_hospital_code = c2.hospital_code AND (m.baby_case_no = par_baby_case_no AND m.baby_hospital_code = par_baby_hospital_code);
            return next p_refcur;
            RETURN;
        END;
    ELSE
        BEGIN
            OPEN p_refcur FOR
            SELECT
                p1.hkid AS motherhkid, p2.hkid AS babyhkid, p1.patient_name AS mothername, p2.patient_name AS babyname, m.birth_order, m.mother_hospital_code, m.mother_case_no, m.baby_hospital_code, m.baby_case_no, m.create_by, CONCAT(to_char(m.create_datetime,'DD-MM-YYYY'), ' ', to_char(m.create_datetime,'HH24:MI:SS')) AS create_datetime, m.update_by, CONCAT(to_char(m.update_datetime,'DD-MM-YYYY'), ' ', to_char(m.update_datetime,'HH24:MI:SS')) AS update_datetime
                FROM mother_baby_case AS m, patient AS p1, patient AS p2, pmi_case AS c1, pmi_case AS c2
                WHERE c1.patient_key = p1.patient_key AND c2.patient_key = p2.patient_key AND m.mother_case_no = c1.case_no AND m.mother_hospital_code = c1.hospital_code AND m.baby_case_no = c2.case_no AND m.baby_hospital_code = c2.hospital_code AND p2.hkid = par_baby_hkid;
            return next p_refcur;
            RETURN;        
        END;
    END IF;
END;
$function$
;

ALTER FUNCTION "pass_hkpmi_get_mother_baby" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
