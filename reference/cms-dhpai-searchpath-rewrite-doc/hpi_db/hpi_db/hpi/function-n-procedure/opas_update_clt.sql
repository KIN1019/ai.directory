CREATE OR REPLACE PROCEDURE opas_update_clt(INOUT pas_return_code int, IN par_hospital VARCHAR, IN par_specialty VARCHAR, IN par_sub_specialty VARCHAR, IN par_sub_spec_desc VARCHAR, IN par_status VARCHAR, IN par_update_datetime TIMESTAMP WITHOUT TIME ZONE, IN par_update_by VARCHAR)
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
        UPDATE op_clt
        SET sub_spec_desc = par_sub_spec_desc, status = par_status, update_by = par_update_by, update_datetime = par_update_datetime
            WHERE specialty = par_specialty AND sub_specialty = par_sub_specialty AND hospital = par_hospital AND expiry_date IS NULL;
    ELSE
        BEGIN
            RAISE EXCEPTION 'Update failed, no record found on op_clt table' USING ERRCODE := '25000';
            ROLLBACK;
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
END;
/* 2007-04-18 Kelvin Leung SMR20016147 - End */
$BODY$
LANGUAGE plpgsql;


;ALTER PROCEDURE "opas_update_clt" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
