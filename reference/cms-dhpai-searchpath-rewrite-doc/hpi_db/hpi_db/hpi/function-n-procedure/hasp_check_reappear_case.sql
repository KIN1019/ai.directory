-- DROP PROCEDURE hasp_check_reappear_case(inout int4, in varchar, in varchar, inout varchar, inout timestamp, inout int4);

CREATE OR REPLACE PROCEDURE hasp_check_reappear_case(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_hkid character varying, INOUT par_prev_case_no character varying, INOUT par_prev_adm_dtm timestamp without time zone, INOUT par_return_code integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cur_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_enable_ae_charging VARCHAR(2);
    var_rowcount INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<return_control>>
    BEGIN
        SELECT
            Text_value
            INTO var_enable_ae_charging
            FROM Hospital_control
            WHERE type = 'ae_charging' AND Hospital_code = par_hosp_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF var_rowcount = 0 OR var_enable_ae_charging <> 'Y' THEN
            BEGIN
                SELECT
                    NULL, NULL, - 1
                    INTO par_prev_case_no, par_prev_adm_dtm, par_return_code;
                EXIT return_control;
            END;
        END IF;
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_cur_dtm;
        /*
        select @prev_case_no = Case_no, @prev_adm_dtm = Admission_datetime
        from Case_view
        where HKID = @hkid
        and Hospital_code = @hosp_code
        and Case_type = 'A'
        and Admission_datetime =
        (select max(Admission_datetime)
        from Case_view where HKID = @hkid
        and Hospital_code = @hosp_code
        and Discharge_datetime is null
        and Admission_datetime >= dateadd(hh,-6,@cur_dtm)
        and Admission_datetime <= @cur_dtm
        and Case_type = 'A')
        */
        /* ---20131015 try to fix slow-perf due to the VIEW issues --- */
        SELECT
            case_no, admission_dtm
            INTO par_prev_case_no, par_prev_adm_dtm
            FROM (SELECT
                case_no, admission_dtm, patient_key
                FROM cpi_case) AS ungrouped_query
            INNER JOIN (SELECT
                patient_key, MAX(admission_dtm) AS max_1
                FROM cpi_case
                WHERE patient_key = (SELECT
                    patient_key
                    FROM cpi_patient
                    WHERE hkid = par_hkid) AND discharge_dtm IS NULL AND admission_dtm >= - 6 * INTERVAL '1 hour' + var_cur_dtm::TIMESTAMP AND admission_dtm <= var_cur_dtm AND case_type = 'A' AND status_code <> 'CC'
                GROUP BY patient_key) AS grouped_query
                ON (ungrouped_query.patient_key = grouped_query.patient_key OR (ungrouped_query.patient_key IS NULL AND grouped_query.patient_key IS NULL))
            WHERE admission_dtm = max_1;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            BEGIN
                SELECT
                    NULL, NULL, - 1
                    INTO par_prev_case_no, par_prev_adm_dtm, par_return_code;
                EXIT return_control;
            END;
        ELSE
            BEGIN
                SELECT
                    0
                    INTO par_return_code;
                EXIT return_control;
            END;
        END IF;
    END;
    pas_return_code := par_return_code;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_check_reappear_case" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
