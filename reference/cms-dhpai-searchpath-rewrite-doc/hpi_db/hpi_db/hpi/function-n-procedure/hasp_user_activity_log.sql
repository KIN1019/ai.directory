-- DROP PROCEDURE hasp_user_activity_log(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hasp_user_activity_log(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_user_id character varying, IN par_term_id character varying, IN par_func_id character varying, IN par_remark character varying, IN par_system_datetime timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    sql$rowcount BIGINT;
    v_message    VARCHAR(512);
BEGIN

    INSERT INTO user_activity_log (hospital_code, user_id, term_id, func_id, remark, system_datetime)
    VALUES (par_hospital_code, par_user_id, par_term_id, par_func_id, par_remark, par_system_datetime);

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS pas_return_code = RETURNED_SQLSTATE, v_message = MESSAGE_TEXT;
        RAISE NOTICE 'Error: %, SQLSTATE: %', v_message, pas_return_code;
        -- Optionally, set pas_return_code to a non-zero value to indicate error
        pas_return_code := 1;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_user_activity_log" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
