CREATE OR REPLACE PROCEDURE opas_delete_clt_by_eis_prof(INOUT pas_return_code INTEGER, IN par_hospital VARCHAR, IN par_specialty VARCHAR, IN par_sub_specialty VARCHAR, IN par_effective_date TIMESTAMP WITHOUT TIME ZONE, IN par_expiry_date TIMESTAMP WITHOUT TIME ZONE)
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
        WHERE specialty = par_specialty AND sub_specialty = par_sub_specialty AND hospital = par_hospital AND effective_date = par_effective_date) THEN
        DELETE FROM op_clt
            WHERE specialty = par_specialty AND sub_specialty = par_sub_specialty AND hospital = par_hospital AND effective_date = par_effective_date;
    END IF;
END;
/* else */

/* --		begin */

/* --			raiserror 25000 'Delete failed, no record found on op_clt table' */

/* --			rollback transaction */

/* --			return */

/* --		end */

/* 2007-04-18 Kelvin Leung SMR20016147 - End */
$BODY$
LANGUAGE plpgsql;


;ALTER PROCEDURE "opas_delete_clt_by_eis_prof" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
