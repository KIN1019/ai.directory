-- DROP PROCEDURE hpi.opas_update_clt_by_specialty(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.opas_update_clt_by_specialty(INOUT pas_return_code integer, IN par_hospital character varying, IN par_specialty character varying, IN par_specialty_desc character varying, IN par_update_by character varying, IN par_update_datetime timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    set search_path TO hpi,public;
    IF (par_hospital = 'TMP') THEN
        SELECT
            'TMH'
            INTO par_hospital;
    END IF;
    /* 2007-04-18 Kelvin Leung SMR20016147 - Start */
    IF EXISTS (SELECT
        1
        FROM op_clt
        WHERE specialty = par_specialty AND hospital = par_hospital AND expiry_date IS NULL) THEN
        UPDATE op_clt
        SET specialty_desc = par_specialty_desc, update_by = par_update_by, update_datetime = par_update_datetime
            WHERE specialty = par_specialty AND hospital = par_hospital AND expiry_date IS NULL;
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
$procedure$
;



;ALTER PROCEDURE "opas_update_clt_by_specialty" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
