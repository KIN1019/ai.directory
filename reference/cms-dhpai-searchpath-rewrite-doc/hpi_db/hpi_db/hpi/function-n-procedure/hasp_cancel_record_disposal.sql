-- DROP PROCEDURE hpi.hasp_cancel_record_disposal(inout int4, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_cancel_record_disposal(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_hkid VARCHAR(24);
    var_name VARCHAR(96);
    var_mrn VARCHAR(16);
    var_discharge_dtm TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    <<error>>
    BEGIN
        IF NOT EXISTS (SELECT
            *
            FROM disposed_record_table
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no) THEN
            BEGIN
                RAISE EXCEPTION 'Case not found in disposed record list' USING ERRCODE := '20001';
                EXIT error;
            END;
        END IF;
        SELECT
            NULL, NULL, NULL, NULL
            INTO var_hkid, var_name, var_mrn, var_discharge_dtm;
        SELECT
            c."HKID", c."Discharge_datetime", p."Name", p."Medical_record_number"
            INTO var_hkid, var_discharge_dtm, var_name, var_mrn
            FROM h1ahpi_db_dbo."Case_view" AS c
            LEFT OUTER JOIN h1ahpi_db_dbo."PMI" AS p
                ON (c."HKID" = p."HKID")
            WHERE c."Case_no" = par_case_no;
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
        begin tran
        */
        BEGIN
            INSERT INTO disposal_list_table (hospital_code, hkid, name, mrn, case_no, discharge_datetime, disposal_date)
            SELECT
                par_hospital_code, var_hkid, var_name, var_mrn, par_case_no, var_discharge_dtm, disposal_date
                FROM disposed_record_table
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
            EXCEPTION
                WHEN others THEN
                    BEGIN
                        --ROLLBACK;
                        RAISE EXCEPTION 'Fail to insert disposal record list' USING ERRCODE := '20002';
                        EXIT error;
                    END;
        END;

        BEGIN
            DELETE FROM disposed_record_table
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
            --COMMIT;
            EXCEPTION
                WHEN others THEN
                    BEGIN
                        --ROLLBACK;
                        RAISE EXCEPTION 'Fail to update disposed record list' USING ERRCODE := '20003';
                        EXIT error;
                    END;
        END;
        pas_return_code := 0;
        RETURN;
    END;
    pas_return_code := - 1;
    RETURN;
END;
$procedure$
;
