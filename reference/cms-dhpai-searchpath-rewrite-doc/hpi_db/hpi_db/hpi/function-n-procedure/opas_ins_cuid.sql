-- DROP PROCEDURE opas_ins_cuid(inout int4, in varchar, in varchar, inout varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE opas_ins_cuid(INOUT pas_return_code integer, IN par_server_name character varying, IN par_login_id character varying, INOUT par_cuid character varying, IN par_hkid character varying, IN par_name character varying, IN par_create_system character varying, IN par_create_hospital character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rpc_call VARCHAR(60);
    var_raiserror_text VARCHAR(50);
    var_return_code INTEGER;
    var_result INTEGER;
    sql_text text;
begin
	set search_path to hpi,public;
    /* RPC to CUID & return code defined by CUID team */
    /* SELECT @rpc_call = RTRIM(@server_name) + '...proc_cuid_insert_cuid_detail' */
    /* EXEC @return_code = @rpc_call @login_id, @cuid, @hkid, @name, @create_system, @create_hospital, @raiserror_text OUTPUT */
    
    /*
    [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
    SET cis_rpc_handling ON
    */
    
    /*
    [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
    SET transactional_rpc ON
    */ 
    /* ----begran tran ... */
    SELECT
        CONCAT(RTRIM(par_server_name), '...proc_cuid_insert_cuid_detail')
        INTO var_rpc_call;
    /*
    [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
    EXEC @return_code = @rpc_call @login_id,
                                     @cuid OUTPUT,
                                     @hkid, @name, @create_system, @create_hospital,
                                     @raiserror_text OUTPUT,
                                     @result OUTPUT
    */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
    SET cis_rpc_handling OFF
    */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
    SET transactional_rpc OFF
    */
    <<return_null>>
    BEGIN
    END;
END;
$procedure$
;

;ALTER PROCEDURE "opas_ins_cuid" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
