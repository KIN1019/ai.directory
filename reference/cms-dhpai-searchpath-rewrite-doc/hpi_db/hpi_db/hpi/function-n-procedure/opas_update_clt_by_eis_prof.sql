CREATE OR REPLACE PROCEDURE opas_update_clt_by_eis_prof(INOUT pas_return_code int, IN par_hospital VARCHAR, IN par_specialty VARCHAR, IN par_sub_specialty VARCHAR, IN par_eis_service_type VARCHAR, IN par_eis_specialty VARCHAR, IN par_eis_sub_specialty VARCHAR, IN par_effective_date TIMESTAMP WITHOUT TIME ZONE, IN par_old_effective_date TIMESTAMP WITHOUT TIME ZONE, IN par_expiry_date TIMESTAMP WITHOUT TIME ZONE, IN par_update_by VARCHAR, IN par_update_datetime TIMESTAMP WITHOUT TIME ZONE)
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
        WHERE specialty = par_specialty AND sub_specialty = par_sub_specialty AND hospital = par_hospital AND effective_date = par_old_effective_date) THEN
        UPDATE op_clt
        SET eis_service_type = par_eis_service_type, eis_specialty = par_eis_specialty, eis_sub_specialty = par_eis_sub_specialty, effective_date = par_effective_date, expiry_date = par_expiry_date, update_by = par_update_by, update_datetime = par_update_datetime
            WHERE specialty = par_specialty AND sub_specialty = par_sub_specialty AND hospital = par_hospital AND effective_date = par_old_effective_date;
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


;ALTER PROCEDURE "opas_update_clt_by_eis_prof" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
