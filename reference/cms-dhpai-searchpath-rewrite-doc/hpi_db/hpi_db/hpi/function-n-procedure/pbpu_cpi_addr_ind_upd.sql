-- DROP PROCEDURE hpi.pbpu_cpi_addr_ind_upd(in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.pbpu_cpi_addr_ind_upd(IN par_hkid character, IN par_set_type character, IN par_hospital_code character, IN par_source_system character, IN par_user_id character, INOUT par_return_code integer, INOUT par_return_message character varying)
 LANGUAGE plpgsql
AS $procedure$
/*
****************************************************
* Procedure : pbpu_cpi_addr_ind_upd
* Description : Call IPAS stored procedure cpi_set_problem_address_ind
* Input :
*   Variable               Type        Description
*   --------               ----        -----------
*
* Raiserror :
*   Code  Message
*   ----  -------
*   0	  Success
*   1	  Error
*
*   Date 	Who             Action
*   -----	----            ------
*   20061011	Winnie Chan	Initial Version
*****************************************************
*/
DECLARE
    var_return_code int;
BEGIN
    /*
    [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
    begin transaction
    */
    CALL cpi_set_problem_address_ind(var_return_code, par_hkid, par_set_type, par_hospital_code, par_source_system, par_user_id, par_return_code, par_return_message);

    IF par_return_code = 0 THEN
        --COMMIT;
    ELSE
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support ROLLBACK TRAN command. Perform a manual conversion.]
        rollback transaction
        */
        BEGIN
            raise exception '';
        END;
    END IF;
END;
$procedure$
;

;ALTER PROCEDURE "pbpu_cpi_addr_ind_upd" OWNER TO "HPI_SCHEMA_OWNER_ROLE";