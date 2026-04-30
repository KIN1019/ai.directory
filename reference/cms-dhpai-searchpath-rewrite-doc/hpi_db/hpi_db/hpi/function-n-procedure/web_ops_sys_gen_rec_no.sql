-- DROP PROCEDURE hpi.web_ops_sys_gen_rec_no(varchar);

CREATE OR REPLACE PROCEDURE hpi.web_ops_sys_gen_rec_no(IN par_table_name character varying)
 LANGUAGE plpgsql
AS $procedure$
declare
	p_refcur refcursor;
    var_seq_no INTEGER;
BEGIN
    BEGIN
        BEGIN
            CALL opsyb_sys_gen_rec_no(par_table_name, var_seq_no);

            EXCEPTION
                WHEN others THEN
                    BEGIN
                        --ROLLBACK;
                        raise exception '';
                        SELECT
                            0
                            INTO var_seq_no;
                    END;
        END;
    END;
    OPEN p_refcur FOR
    SELECT
        var_seq_no;
END;
$procedure$
;

;ALTER PROCEDURE "web_ops_sys_gen_rec_no" OWNER TO "HPI_SCHEMA_OWNER_ROLE";