-- DROP PROCEDURE hpi.hasp_transfer(inout int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_transfer(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_t_datetime timestamp without time zone, IN par_t_case_no character varying, IN par_t_to_ns_code character varying, IN par_t_to_specialty character varying, IN par_t_to_class character varying, IN par_t_to_bed_no character varying, IN par_t_ns_code character varying, IN par_t_doctor character varying, IN par_t_user_id character varying, IN par_t_case_timestamp timestamp without time zone, IN par_iso_status character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* -------------------------------------------------------------- */
/* This store procedure is developed base on the LRR/DT version */
/* Developed by        : Watson Tsui */
/* Date                : 21st June, 1995 */
/* Project             : IPAS/ADT v2.0 */
/* Server              : Sybase 10.0.2 */
/* O.S.                : AIX 3.2.5 */
/* Function            : To perform transfer */
/* AIX file name       : sp_t.sql */
/* Call                : hasp_common_td (sp_co_td.sql) */
/* Trans_type          : 140 - transfer */
/* History		: 20160426 - CR31244 Add ISO_STATUS to capture patient isolation status by Yorky LEUNG */
/* 2017-03-29 PasCr201700198 Noel Chan To reset patient AII status during transfer out to non AII ward */
/* 2017-08-02 PasCr201700315 Jack Wong Reject Transfer if ward_class is blank */
/* 2018-03-22 PasCR201800080 Jack Wong Add checking to avoid invalid ward_class being used in transfer stored procedure function */
/* -------------------------------------------------------------- */
DECLARE
    var_Trans_type VARCHAR(03);
    var_return_code INTEGER;
BEGIN
    /* sp_addmessage 40028,"Ward Class/Status is empty!" */
    
    /* 2017-08-02 PasCr201700315 Jack Wong Reject Transfer if ward_class is blank - Start */
    IF par_T_TO_CLASS IS NULL OR par_T_TO_CLASS = '' THEN
        BEGIN
            RAISE EXCEPTION 'Ward Class/Status is empty!' USING ERRCODE := '40028';
            pas_return_code := 40028;
            RETURN;
        END;
    END IF;
    /* 2017-08-02 PasCr201700315 Jack Wong Reject Transfer if ward_class is blank - End */
    /* 2018-03-22 PasCR201800080 Jack Wong Add checking to avoid invalid ward_class being used in transfer stored procedure function - Start */
    IF NOT EXISTS (SELECT
        *
        FROM ward_class_code
        WHERE Ward_class = par_T_TO_CLASS::VARCHAR) AND NOT EXISTS (SELECT
        *
        FROM hospital_ward_class
        WHERE ward_class = par_T_TO_CLASS) THEN
        BEGIN
            RAISE EXCEPTION 'Ward class not exist, cannot process!' USING ERRCODE := '40029';
            pas_return_code := 40029;
            RETURN;
        END;
    END IF;
    /* 2018-03-22 PasCR201800080 Jack Wong Add checking to avoid invalid ward_class being used in transfer stored procedure function - End */
    /*
    [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
    begin transaction
    */
    SELECT
        '140'
        INTO var_Trans_type;
    /* 2017-03-29 PasCr201700198 Noel Chan To reset patient AII status during transfer out to non AII ward - Start */
    IF par_T_TO_BED_NO IS NULL OR par_T_TO_BED_NO = '' THEN
        SELECT
            NULL
            INTO par_ISO_STATUS;
    END IF;
    /* 2017-03-29 PasCr201700198 Noel Chan To reset patient AII status during transfer out to non AII ward - End */
    /* call common module : hasp_common_td with trans_type '140' (transfer) */
    raise notice 'CALL hasp_common_td(%,%,%,%,%,%,%,%,%,%,%,%,%,%)',var_return_code,par_hosp_code,par_T_DATETIME, par_T_CASE_NO, par_T_TO_NS_CODE, par_T_TO_SPECIALTY, par_T_TO_CLASS, par_T_TO_BED_NO, par_T_NS_CODE, par_T_DOCTOR, par_T_USER_ID, par_T_CASE_timestamp, var_Trans_type, par_ISO_STATUS;
    CALL hasp_common_td(var_return_code, par_hosp_code, par_T_DATETIME, par_T_CASE_NO, par_T_TO_NS_CODE, par_T_TO_SPECIALTY, par_T_TO_CLASS, par_T_TO_BED_NO, par_T_NS_CODE, par_T_DOCTOR, par_T_USER_ID, par_T_CASE_timestamp, var_Trans_type, par_ISO_STATUS);

    IF var_return_code != 0 THEN
        BEGIN
            RAISE EXCEPTION 'Transfer record update error!' USING ERRCODE := var_return_code;
            pas_return_code := var_return_code;
            RETURN;
        END;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_transfer" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
