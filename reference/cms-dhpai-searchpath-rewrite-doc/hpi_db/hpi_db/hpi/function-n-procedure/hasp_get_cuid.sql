-- DROP PROCEDURE hasp_get_cuid(inout int4, in bpchar, in varchar, inout bpchar, inout varchar, inout bpchar, in bpchar);

CREATE OR REPLACE PROCEDURE hasp_get_cuid(INOUT pas_return_code integer, IN par_hkid character, IN par_name character varying, INOUT par_cuid_exist character, INOUT par_cuid_name character varying, INOUT par_cuid character, IN par_select_output character DEFAULT 'N'::bpchar)
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
    var_hosp_code VARCHAR(3);
    var_login_id VARCHAR(12);
BEGIN
    <<return_null>>
    BEGIN
        /*
        --- OPAS SP style
        declare @st_proc_name varchar(255), @rtn int, @raiserror_text VARCHAR(50)
        
        exec pas_sys_rtn_st_proc_name 1, 'proc_cuid_get_cuid', @st_proc_name output
        
        exec @rtn = @st_proc_name @hkid, @name, @cuid_exist output, @cuid_name output, @cuid output, @raiserror_text output
        
        if @select_output = 'Y'
           select @cuid_exist, @cuid_name, @cuid, @rtn, @raiserror_text
        */
        
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
        */ /* ----begran tran ... */
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
        /* ---20090918 SL : generate the new CUID for the HKID -- */
        IF par_cuid IS NULL OR LTRIM(RTRIM(par_cuid)) = '' THEN
            BEGIN
                SELECT
                    Hospital_code
                    INTO var_hosp_code
                    FROM Hospital;
                SELECT
                    aws_sapase_ext.user_name()
                    INTO var_login_id;
                CALL hasp_ins_cuid(pas_return_code,var_login_id, par_cuid, par_hkid, par_name, 'IPAS', var_hosp_code);
                /* ---- Retrive CUID again */
                
                /*
                [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
                set cis_rpc_handling on
                */
                
                /*
                [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
                set transactional_rpc on
                */
                
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
                /* ----begran tran ... */
            END;
        END IF;
        /* ---20090918 SL : generate the new CUID for the HKID -- */
    END;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_cuid" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
