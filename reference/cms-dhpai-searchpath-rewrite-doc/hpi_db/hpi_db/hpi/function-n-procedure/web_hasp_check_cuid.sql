-- DROP PROCEDURE web_hasp_check_cuid(inout int4, in bpchar, in varchar, inout bpchar, inout varchar, inout bpchar, in bpchar);

CREATE OR REPLACE PROCEDURE web_hasp_check_cuid(INOUT pas_return_code integer, IN par_hkid character, IN par_name character varying, INOUT par_cuid_exist character, INOUT par_cuid_name character varying, INOUT par_cuid character, IN par_select_output character DEFAULT 'N'::bpchar)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_server_name VARCHAR(20);
    var_rpc_call VARCHAR(60);
    var_cuid_enable VARCHAR(1);
    var_raiserror_text VARCHAR(50);
    var_return_code INTEGER;
    var_result INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<return_null>>
    BEGIN
        /* init */
        SELECT
            'N'
            INTO var_cuid_enable;
        SELECT
            Text_value
            INTO var_cuid_enable
            FROM Hospital_control
            WHERE Type = 'cuid_enable';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount != 1 OR /* Not set the flag */ var_cuid_enable != 'Y' THEN /* the flag disable */
            BEGIN
                EXIT return_null /* return NULL */;
            END;
        END IF;
        /* --> get server name <-- */
        SELECT
            Text_value
            INTO var_server_name
            FROM Hospital_control
            WHERE Type = 'CUID_SERVER_ORA';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount != 1 THEN
            BEGIN
                RAISE NOTICE '...Cannot select CUID SERVER  name!!!...';
                EXIT return_null;
            END;
        END IF;
        /* RPC to CUID & return code defined by CUID team */
        /*
        [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
        set cis_rpc_handling on
        */
        /*
        [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
        set transactional_rpc on
        */
        SELECT
            CONCAT(RTRIM(var_server_name), '...proc_cuid_get_cuid')
            INTO var_rpc_call;
        /*
        [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
        exec @return_code = @rpc_call @hkid, @name,
        		@cuid_exist output,
        		@cuid_name output,
        		@cuid output,
        		@raiserror_text output,
        		@result output
        */
        /*
        [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
        set cis_rpc_handling off
        */
        /*
        [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
        set transactional_rpc off
        */
    END;
END;
$procedure$
;

;ALTER PROCEDURE "web_hasp_check_cuid" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
