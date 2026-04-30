-- DROP PROCEDURE hpi.hasp_insert_audit_log(inout int4, in varchar, in timestamp, in varchar, in varchar, in int4, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hasp_insert_audit_log(INOUT pas_return_code integer, IN par_hosp character varying, IN par_system_datetime timestamp without time zone, IN par_ws_id character varying, IN par_login_id character varying, IN par_func_id integer, IN par_action_type character varying, IN par_action_string character varying, IN par_hkid character varying, IN par_case_no character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_sqlstate text;
    v_err text;
BEGIN
    begin
        /* --- Modified by WL on 23 July 1999 for HPi --- */
        INSERT INTO audit_log_no_pat_id (hospital_code, system_datetime, ws_id, login_id, func_id, action_type, action_string, hkid, case_no)
        VALUES (par_hosp, par_system_datetime, par_ws_id, par_login_id, par_func_id, par_action_type, par_action_string, par_hkid, par_case_no);
    END;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_insert_audit_log" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
