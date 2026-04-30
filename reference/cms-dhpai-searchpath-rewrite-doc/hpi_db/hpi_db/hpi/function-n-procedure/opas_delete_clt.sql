CREATE OR REPLACE PROCEDURE opas_delete_clt(INOUT pas_return_code INTEGER, IN par_hospital VARCHAR, IN par_specialty VARCHAR, IN par_sub_specialty VARCHAR)
AS 
$BODY$
BEGIN
    IF (par_hospital = 'TMP') THEN
        SELECT
            'TMH'
            INTO par_hospital;
    END IF;
    /* 2007-04-18 Kelvin Leung SMR20016147 - Start */
    IF EXISTS (SELECT
        1
        FROM op_clt
        WHERE specialty = par_specialty AND sub_specialty = par_sub_specialty AND hospital = par_hospital AND expiry_date IS NULL) THEN
        DELETE FROM op_clt
            WHERE specialty = par_specialty AND sub_specialty = par_sub_specialty AND hospital = par_hospital AND expiry_date IS NULL;
    END IF;
END;
/* --	else */
/* --		begin */
/* --			raiserror 25000 'Delete failed, no record found on op_clt table' */
/* --			rollback transaction */
/* --			return */
/* --		end */
/* 2007-04-18 Kelvin Leung SMR20016147 - End */
$BODY$
LANGUAGE plpgsql;


;ALTER PROCEDURE "opas_delete_clt" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
