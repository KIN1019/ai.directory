-- DROP PROCEDURE hpi.hasp_cancel_transfer(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.hasp_cancel_transfer(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_t_case_no character varying, IN par_t_ns_code character varying, IN par_t_user_id character varying, IN par_t_case_timestamp timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/* -------------------------------------------------------------- */
/* This store procedure is developed base on the LRR/DT version */
/* Developed by        : Watson Tsui */
/* Date                : 22nd June, 1995 */
/* Project             : IPAS/ADT v2.0 */
/* Server              : Sybase 10.0.2 */
/* O.S.                : AIX 3.2.5 */
/* Function            : To perform cancellation of transfer */
/* AIX file name       : sp_ct.sql */
/* Call                : hasp_common_ctd (sp_coctd.sql) */
/* -------------------------------------------------------------- */
DECLARE
    var_trans_type VARCHAR(6);
    var_return_code INTEGER;
BEGIN
    SELECT
        '220'
        INTO var_trans_type;
    /*
    call common module : hasp_common_ctd with trans_type '220'
    (cancellation of transfer)
    */
 
    CALL hasp_common_ctd(var_return_code, par_hosp_code, par_t_case_no, par_t_ns_code, par_t_user_id, par_t_case_timestamp, var_trans_type);

    IF var_return_code != 0 THEN
        BEGIN
            pas_return_code := var_return_code;
            RAISE EXCEPTION 'Cancellation of Transfer record update error!' USING ERRCODE := var_return_code;
            RETURN;
        END;
    END IF;

    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_cancel_transfer" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
