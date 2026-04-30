-- DROP PROCEDURE hkpmi.hkpmi_hago_ehr_act_check(inout int4, in bpchar, inout bpchar, inout bpchar, inout int4, inout bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_hago_ehr_act_check(INOUT pas_return_code integer, IN par_hkid VARCHAR, INOUT par_ehr_number VARCHAR, INOUT par_ehr_flag VARCHAR, INOUT par_code integer,
INOUT par_status VARCHAR)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_return_code int;
    var_rowcount INTEGER;
    var_ehr_start_date VARCHAR(8);
    var_ehr_end_date VARCHAR(8);
BEGIN
    <<return_result>>
    BEGIN
        /* execute activation check SP */
        CALL hkpmi_hago_activation_check(var_return_code, par_hkid, par_code, par_status);

        IF par_code <> 0 THEN
            BEGIN
                EXIT return_result;
            END;
        END IF;
        SELECT
            COUNT(*)
            INTO var_rowcount
            FROM ehr_patient_list
            WHERE ehr_hkic = par_hkid;

        IF var_rowcount = 0 THEN
            BEGIN
                SELECT
                    2912
                    INTO par_code;
                SELECT
                    'eHR record not found'
                    INTO par_status;
                EXIT return_result;
            END;
        END IF;
        SELECT
            ehr_number, ehr_flag, ehr_start_date, ehr_end_date
            INTO par_ehr_number, par_ehr_flag, var_ehr_start_date, var_ehr_end_date
            FROM ehr_patient_list
            WHERE ehr_hkic = par_hkid
            /* --and ehr_flag = 'VAL' */
            /* --and (ehr_end_date = null or convert(date,ehr_end_date,112)>= getdate()) */
            ORDER BY ehr_start_date DESC NULLS FIRST
            LIMIT 1;

        IF par_ehr_flag != 'VAL' THEN
            BEGIN
                SELECT
                    2913
                    INTO par_code;
                SELECT
                    'Eligible eHR record not found'
                    INTO par_status;
                EXIT return_result;
            END;
        END IF;

        IF (var_ehr_end_date IS NULL or to_date(var_ehr_end_date,'YYYYMMDD')  >= timestamp_convert(localtimestamp)) and to_date(var_ehr_start_date,'YYYYMMDD')  <= timestamp_convert(localtimestamp) THEN
            BEGIN
                SELECT
                    0
                    INTO par_code;
                SELECT
                    'Eligible eHR record found'
                    INTO par_status;
                EXIT return_result;
            END;
        ELSE
            BEGIN
                SELECT
                    2914
                    INTO par_code;
                SELECT
                    'Eligible eHR record expired'
                    INTO par_status;
                EXIT return_result;
            END;
        END IF;
    END;
    pas_return_code := par_code;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_hago_ehr_act_check" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

