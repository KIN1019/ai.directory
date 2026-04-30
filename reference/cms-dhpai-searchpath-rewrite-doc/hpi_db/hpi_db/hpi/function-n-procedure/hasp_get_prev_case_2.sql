-- DROP PROCEDURE hasp_get_prev_case_2(inout int4, in varchar, in timestamp, in varchar, in varchar, out varchar, out timestamp, out varchar, out timestamp, out varchar, out varchar, out varchar);

CREATE OR REPLACE PROCEDURE hasp_get_prev_case_2(INOUT pas_return_code integer, IN par_hkid character varying, IN par_input_date timestamp without time zone, IN par_case_type character varying, IN par_active_indicator character varying, OUT par_case_no character varying, OUT par_admission_date timestamp without time zone, OUT par_discharge_code character varying, OUT par_discharge_datetime timestamp without time zone, OUT par_pay_code character varying, OUT par_eh_code character varying, OUT par_pp_code character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_t_prk     VARCHAR(16);
    var_hosp_code VARCHAR(6);
BEGIN
    -- Initialize output parameters
    par_case_no := NULL;
    par_admission_date := NULL;
    par_discharge_code := NULL;
    par_discharge_datetime := NULL;
    par_pay_code := NULL;
    par_eh_code := NULL;
    par_pp_code := NULL;

    -- Get patient key
    SELECT patient_key
    INTO var_t_prk
    FROM
        cpi_patient
    WHERE hkid = par_hkid;

    IF NOT FOUND
    THEN
        -- If no patient key is found, exit with an error
        -- RAISE NOTICE 'No patient key found for HKID: %', par_hkid;
        pas_return_code := -1;
        RETURN;
    END IF;
    
    BEGIN
        -- Retrieve case details
        WITH
            ranked_cases AS (SELECT ca.case_no,
                                    ca.admission_dtm,
                                    ca.discharge_code,
                                    ca.discharge_dtm,
                                    ca.patient_type AS pay_code,
                                    ca.hospital_code AS hosp_code,
                                    ROW_NUMBER() OVER (
                                        PARTITION BY ca.patient_key
                                        ORDER BY ca.admission_dtm DESC
                                        ) AS rn
                            FROM
                                cpi_case ca
                                INNER JOIN
                                    cpi_active_case ca_act
                                    ON
                                        ca.hospital_code = ca_act.hospital_code
                                            AND ca.case_no = ca_act.case_no
                            WHERE
                                ca.patient_key = var_t_prk
                            AND COALESCE(ca.case_type,'null') <> COALESCE(par_case_type,'null')
                            AND COALESCE(ca_act.active_indicator,'null') <> COALESCE(par_active_indicator,'null')
                            AND ca.admission_dtm < par_input_date
                            AND ca.case_type <> 'O'
                            AND ca.status_code <> 'CC')
        SELECT case_no,
            admission_dtm,
            discharge_code,
            discharge_dtm,
            pay_code,
            hosp_code
        INTO par_case_no,
            par_admission_date,
            par_discharge_code,
            par_discharge_datetime,
            par_pay_code,
            var_hosp_code
        FROM
            ranked_cases
        WHERE
            rn = 1;
    EXCEPTION 
        WHEN OTHERS THEN
            pas_return_code := -1;
            RETURN;
    END;

    -- Retrieve AE case details
    SELECT eh_code, pp_code
    INTO par_eh_code, par_pp_code
    FROM
        AE_case_detail
    WHERE
          case_no = par_case_no
      AND hospital_code = var_hosp_code;

    -- If no AE case details are found, set EH code to NULL
    IF NOT FOUND
    THEN
        par_eh_code := NULL;
    END IF;

    -- Return successfully
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_prev_case_2" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
