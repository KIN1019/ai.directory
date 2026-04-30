-- DROP PROCEDURE hpi.web_can_ae_discharge_by_ext(inout int4, in varchar, in varchar, in varchar, inout int4);

CREATE OR REPLACE PROCEDURE hpi.web_can_ae_discharge_by_ext(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_user_id character varying, INOUT par_return_code integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_enable_ae_refund VARCHAR(1);
    var_rowcount INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<force_exit>>
    BEGIN
        SELECT
            Text_value
            INTO var_enable_ae_refund
            FROM Hospital_control
            WHERE Hospital_code = par_hospital_code AND Type = 'enable_ae_refund';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_rowcount = 0 OR var_enable_ae_refund <> 'Y') THEN
            BEGIN
                SELECT
                    99
                    INTO par_return_code;
                raise exception '';
            END;
        END IF;
        CALL hasp_can_ae_discharge_by_cis(par_return_code, par_hospital_code, par_case_no, par_user_id);
    END;
END;
$procedure$
;


;ALTER PROCEDURE "web_can_ae_discharge_by_ext" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
