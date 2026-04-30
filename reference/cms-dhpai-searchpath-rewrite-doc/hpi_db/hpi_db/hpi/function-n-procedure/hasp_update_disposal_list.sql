-- DROP PROCEDURE hpi.hasp_update_disposal_list(inout int4, in timestamp, in bpchar, in bpchar, in bpchar, in timestamp, in bpchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_update_disposal_list(INOUT pas_return_code integer, IN par_disposal_date timestamp without time zone, IN par_hospital_code character, IN par_case_no character, IN par_user_id character, IN par_update_dtm timestamp without time zone, IN par_source_system character)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    <<error>>
    BEGIN
        IF NOT EXISTS (SELECT
            *
            FROM disposal_list_table
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no) THEN
            BEGIN
                RAISE EXCEPTION 'Case not found in disposal list' USING ERRCODE := '20001';
                EXIT error;
            END;
        END IF;

        IF EXISTS (SELECT
            *
            FROM disposed_record_table
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no) THEN
            BEGIN
                RAISE EXCEPTION 'Case was disposed' USING ERRCODE := '20002';
                EXIT error;
            END;
        END IF;
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
        begin tran
        */
        BEGIN
            DELETE FROM disposal_list_table
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
            EXCEPTION
                WHEN others THEN
                    BEGIN
                        --ROLLBACK;
                        RAISE EXCEPTION 'Fail to update disposal record list' USING ERRCODE := '20003';
                        EXIT error;
                    END;
        END;

        BEGIN
            INSERT INTO disposed_record_table (hospital_code, case_no, disposal_date, user_id, update_datetime, source_system)
            VALUES (par_hospital_code, par_case_no, par_disposal_date, par_user_id, par_update_dtm, par_source_system);
            COMMIT;
            EXCEPTION
                WHEN others THEN
                    BEGIN
                        --ROLLBACK;
                        RAISE EXCEPTION 'Fail to update disposed record list' USING ERRCODE := '20004';
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
