-- DROP FUNCTION hpi.fn_ops_ti_op_clt();

CREATE OR REPLACE FUNCTION hpi.fn_ops_ti_op_clt()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_numrows INTEGER;
    var_rowcount$aws$ INTEGER;
    var_hospital_in CHAR(3);
    var_hospital CHAR(3);
BEGIN
    IF (TG_OP = 'INSERT') THEN
        SELECT
            count(1)
            FROM inserted
            INTO var_rowcount$aws$;
    ELSE
        SELECT
            count(1)
            FROM deleted
            INTO var_rowcount$aws$;
    END IF;
    var_numrows := var_rowcount$aws$;

    IF var_numrows > 1 THEN
        BEGIN
            RAISE EXCEPTION 'Multi-row insert of op_clt records restricted' USING ERRCODE = '25000';
            ROLLBACK;
            RETURN NULL;
        END;
    END IF;
    SELECT
        hospital_code
        INTO var_hospital
        FROM hospital;
    SELECT
        hospital
        INTO var_hospital_in
        FROM inserted;

    IF var_hospital != var_hospital_in THEN
        BEGIN
            RAISE EXCEPTION 'Cannot insert other hospital record on op_clt table' USING ERRCODE = '25000';
            ROLLBACK;
            RETURN NULL;
        END;
    END IF;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_ops_ti_op_clt" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
