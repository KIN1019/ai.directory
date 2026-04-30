CREATE OR REPLACE FUNCTION pas_erpt_pri_bed_occ(IN par_hosp_code CHAR)
RETURNS SETOF refcursor
LANGUAGE plpgsql
AS 
$function$
DECLARE
	p_refcur refcursor;
BEGIN
    IF NOT EXISTS (SELECT
        *
        FROM Hospital
        WHERE Hospital_code = par_hosp_code) THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                CONCAT('Invalid Hospital code ', par_hosp_code);
        END;
    ELSE
        BEGIN
            OPEN p_refcur FOR
            SELECT
                w.Ward_code, a.Treatment_location, '         ' AS hkid, s.IMIS_code AS eis_specialty, w.Specialty_code, to_char(c.admission_dtm, 'DD/MM/YYYY') AS admission_dtm, m.ward_code AS adm_ward_code, w.Case_no, c.patient_type, c.last_ward_class AS ward_class, b.Bed_type
                FROM cpi_movement AS m, Specialty AS s, cpi_patient AS p, Ward AS a, Bed AS b
                RIGHT OUTER JOIN cpi_case AS c
                    ON (b.Bed_no = c.last_bed_no AND c.hospital_code = par_hosp_code)
                RIGHT OUTER JOIN Ward_list AS w
                    ON (b.Ward_code = w.Ward_code)
                WHERE w.Case_no = c.case_no AND w.Ward_code <> 'AE01' AND c.case_no = m.case_no AND c.hospital_code = m.hospital_code AND c.patient_type IN (SELECT
                    patient_type
                    FROM patient_type
                    WHERE (patient_group IN ('HA', 'GS') OR patient_type = 'PIP') AND pay_code_type IN ('CONFI', 'IP')) AND m.movement_count = 1 AND s.Hospital_code = c.hospital_code AND s.Specialty_code = w.Specialty_code AND s.Effective_date = (SELECT
                    MAX(Effective_date)
                    FROM Specialty
                    WHERE Hospital_code = c.hospital_code AND Specialty_code = w.Specialty_code AND Effective_date <= localtimestamp) AND c.patient_key = p.patient_key AND a.Ward_code = w.Ward_code AND a.Effective_date = (SELECT
                    MAX(Effective_date)
                    FROM Ward
                    WHERE Hospital_code = c.hospital_code AND Ward_code = w.Ward_code AND Effective_date <= localtimestamp)
                ORDER BY w.Ward_code NULLS FIRST;
        END;
    END IF;
END;
$function$;

;ALTER FUNCTION "pas_erpt_pri_bed_occ" OWNER TO "HPI_SCHEMA_OWNER_ROLE";