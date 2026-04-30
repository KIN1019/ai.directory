-- DROP PROCEDURE hpi.hasp_cut_audit_log(inout int4, in int4, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_cut_audit_log(INOUT pas_return_code integer, IN par_month integer, IN par_hospital_code character varying)
 LANGUAGE plpgsql
AS $procedure$
/* --- put hospital_code as input parm by WL on 26 July 1999 --- */
/* --- for HPI --- */
DECLARE
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ws_id VARCHAR(16);
    var_count INTEGER;
    del_al_csr CURSOR FOR
    SELECT
        "System_datetime", "WS_ID"
        FROM "Audit_log"
        WHERE par_month * INTERVAL '1 month' + "System_datetime"::TIMESTAMP < localtimestamp AND "Hospital_code" = par_hospital_code;
BEGIN
    IF par_month < 6 THEN
        BEGIN
            RAISE NOTICE 'Data within 6 months cannot be remove!';
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    /*
    [3017 - Severity CRITICAL - PostgreSQL doesn't support the SET NOCOUNT. If need try another way to send message back to the client application.]
    set nocount on
    */
    /* --- Modified by WL on 21 July 1999 for HPI --- */
    SELECT
        0
        INTO var_count;
    OPEN del_al_csr;
    FETCH del_al_csr INTO var_system_datetime, var_ws_id;

    IF ((CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 2) THEN
        BEGIN
            RAISE NOTICE 'No data to be deleted in Audit_log !';
            CLOSE del_al_csr;
            pas_return_code := 0;
            RETURN;
        END;
    END IF;

    WHILE ((CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0) LOOP
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
        begin tran
        */
        BEGIN
            DELETE FROM "Audit_log"
                WHERE CURRENT OF del_al_csr;
            EXCEPTION
                WHEN others THEN
                    BEGIN
                        RAISE NOTICE 'Error in deleting Audit_log - %+%', var_system_datetime, var_ws_id;
                        ---ROLLBACK;
                        raise exception 'Error in deleting Audit_log';
                        pas_return_code := 0;
                        RETURN;
                    END;
        END;
        --COMMIT;
        SELECT
            var_count + 1
            INTO var_count;
        FETCH del_al_csr INTO var_system_datetime, var_ws_id;
    END LOOP;

    IF ((CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 1) THEN
        BEGIN
            RAISE NOTICE 'Error in fetching cursor!';
            CLOSE del_al_csr;
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    RAISE NOTICE 'Total No. of record deleted %', var_count;
    CLOSE del_al_csr;
END;
$procedure$
;
