-- DROP PROCEDURE hpi.opas_get_pat_case_pp_info(inout int4, in varchar, in varchar, in varchar, in varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout timestamp);

CREATE OR REPLACE PROCEDURE hpi.opas_get_pat_case_pp_info(INOUT pas_return_code integer, IN par_hospital character varying, IN par_patient_key character varying, IN par_case_no character varying, IN par_specialty character varying, INOUT par_pp_code character varying, INOUT par_patient_name character varying, INOUT par_cccode1 character varying, INOUT par_cccode2 character varying, INOUT par_cccode3 character varying, INOUT par_cccode4 character varying, INOUT par_cccode5 character varying, INOUT par_cccode6 character varying, INOUT par_hkid character varying, INOUT par_sex character varying, INOUT par_dob timestamp without time zone, INOUT par_adm_datetime timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    sql$rowcount BIGINT;
BEGIN
    IF par_case_no LIKE 'SOPD%' THEN
        BEGIN
            SELECT
                pp_code
                INTO par_pp_code
                FROM opas_pp_by_specialty
                WHERE case_no = par_case_no AND specialty = par_specialty AND hospital_code = par_hospital;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                SELECT
                    NULL
                    INTO par_pp_code;
            END IF;
            SELECT
                admission_dtm
                INTO par_adm_datetime
                FROM cpi_case
                WHERE patient_key = par_patient_key AND case_no = par_case_no AND hospital_code = par_hospital AND status_code = 'AC' AND discharge_dtm IS NULL;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                SELECT
                    '19000101'
                    INTO par_adm_datetime;
            END IF;
        END;
    ELSE
        BEGIN
            SELECT
                pp_code, admission_dtm
                INTO par_pp_code, par_adm_datetime
                FROM cpi_case
                WHERE patient_key = par_patient_key AND case_no = par_case_no AND hospital_code = par_hospital AND status_code = 'AC' AND discharge_dtm IS NULL;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                SELECT
                    NULL, '19000101'
                    INTO par_pp_code, par_adm_datetime;
            END IF;
        END;
    END IF;
    SELECT
        patient_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, hkid, sex, dob
        INTO par_patient_name, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, par_hkid, par_sex, par_dob
        FROM cpi_patient
        WHERE patient_key = par_patient_key;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount = 0 THEN
        BEGIN
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '19000101'
                INTO par_patient_name, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, par_hkid, par_sex, par_dob;
        END;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "opas_get_pat_case_pp_info" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
