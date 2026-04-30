-- DROP PROCEDURE hpi.hasp_cancel_td(inout int4, in varchar, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.hasp_cancel_td(INOUT pas_return_code integer, IN par_hosp_code character varying, IN "par_T_CASE_NO" character varying, IN "par_T_NS_CODE" character varying, IN "par_T_USER_ID" character varying, IN "par_T_CASE_timestamp" timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/* -------------------------------------------------------------- */
/* This store procedure is developed base on the LRR/DT version */
/* Date                : 01st Dec,  1995 */
/* Project             : IPAS/ADT v2.0 */
/* Server              : Sybase 10.0.2 */
/* O.S.                : AIX 3.2.5 */
/* Function            : To perform cancellation of trial discharge */
/* AIX file name       : sp_ctd.sql */
/* Call                : hasp_common_ctd (sp_coctd.sql) */
/* -------------------------------------------------------------- */
DECLARE
    "var_Trans_type" VARCHAR(6);
    var_return_code INTEGER;
BEGIN

    SELECT
        '230'
        INTO "var_Trans_type";
    /*
    call common module : hasp_common_ctd with trans_type '230'
    (cancellation of trial discharge)
    */
    CALL hasp_common_ctd(var_return_code, par_hosp_code, "par_T_CASE_NO", "par_T_NS_CODE", "par_T_USER_ID", "par_T_CASE_timestamp", "var_Trans_type");

    IF var_return_code != 0 THEN
        BEGIN
            RAISE EXCEPTION 'Cancellation of Trial Discharge record update error!' USING ERRCODE := var_return_code;
            pas_return_code := var_return_code;
            RETURN;
        END;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_cancel_td" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
