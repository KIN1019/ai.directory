-- DROP PROCEDURE hpi.hasp_trial_discharge(inout int4, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.hasp_trial_discharge(INOUT pas_return_code integer, IN "par_T_DATETIME" timestamp without time zone, IN "par_T_CASE_NO" character varying, IN "par_T_TO_NS_CODE" character varying, IN "par_T_TO_SPECIALTY" character varying, IN "par_T_TO_CLASS" character varying, IN "par_T_TO_BED_NO" character varying, IN "par_T_NS_CODE" character varying, IN "par_T_USER_ID" character varying, IN "par_T_CASE_timestamp" timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/* -------------------------------------------------------------- */
/* This store procedure is developed base on the LRR/DT version */
/* Date                : 01st Dec, 1995 */
/* Project             : IPAS/ADT v2.0 */
/* Server              : Sybase 10.0.2 */
/* O.S.                : AIX 3.2.5 */
/* Function            : To perform trial discharge */
/* AIX file name       : sp_td.sql */
/* Call                : hasp_common_td (sp_co_td.sql) */
/* -------------------------------------------------------------- */
DECLARE
    "var_Trans_type" VARCHAR(6);
    var_return_code INTEGER;
BEGIN
    /*
    [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
    begin transaction
    */
    SELECT
        '160'
        INTO "var_Trans_type";
    /* call common module : hasp_common_td with trans_type '160' (trial discharge) */
    CALL hasp_common_td(var_return_code, "par_T_DATETIME", "par_T_CASE_NO", 'HOME', 'HOME', '3', '', "par_T_NS_CODE", NULL, /* Null doctor code */ "par_T_USER_ID", to_char("par_T_CASE_timestamp", 'YYYY-MM-DD HH24:MI:SS.MS')::TIMESTAMP, "var_Trans_type");

    IF var_return_code != 0 THEN
        BEGIN
            RAISE EXCEPTION 'Trial Discharge record update error!' USING ERRCODE := var_return_code;
        END;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_trial_discharge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
