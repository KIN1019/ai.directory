-- DROP PROCEDURE hpi.opas_insert_clt_by_eis_prof(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in timestamp, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.opas_insert_clt_by_eis_prof(INOUT pas_return_code integer, IN par_hospital character varying, IN par_specialty character varying, IN par_sub_specialty character varying, IN par_eis_service_type character varying, IN par_eis_specialty character varying, IN par_eis_sub_specialty character varying, IN par_effective_date timestamp without time zone, IN par_expiry_date timestamp without time zone, IN par_update_by character varying, IN par_update_datetime timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_counter INTEGER;
    var_specialty_desc VARCHAR(30);
    var_sub_spec_desc VARCHAR(30);
    var_status VARCHAR(1);
  
begin
	 SET search_path TO hpi, public;
    IF (par_hospital = 'TMP') THEN
        SELECT
            'TMH'
            INTO par_hospital;
    END IF;
    SELECT
        COUNT(*)
        INTO var_counter
        FROM op_clt
        WHERE specialty = par_specialty AND sub_specialty = par_sub_specialty AND hospital = par_hospital;

    IF var_counter > 0 THEN
        BEGIN
            /*
            update op_clt
            set eis_service_type = @eis_service_type,
                eis_specialty = @eis_specialty,
                eis_sub_specialty = @eis_sub_specialty,
                effective_date = @effective_date,
                expiry_date = @expiry_date,
                update_by = @update_by,
                update_datetime = @update_datetime
            where specialty = @specialty
            and sub_specialty = @sub_specialty
            and hospital = @hospital
            */
            SELECT
                specialty_desc, sub_spec_desc, status
                INTO var_specialty_desc, var_sub_spec_desc, var_status
                FROM op_clt
                WHERE specialty = par_specialty AND sub_specialty = par_sub_specialty AND hospital = par_hospital
                ORDER BY expiry_date DESC NULLS FIRST limit 1;
            INSERT INTO op_clt
            VALUES (par_hospital, par_specialty, par_sub_specialty, var_specialty_desc, var_sub_spec_desc, par_eis_service_type, par_eis_specialty, par_eis_sub_specialty, par_effective_date, par_expiry_date, 'O', var_status, par_update_datetime, par_update_by);
        END;
    ELSE
        INSERT INTO op_clt
        VALUES (par_hospital, par_specialty, par_sub_specialty, '', '', par_eis_service_type, par_eis_specialty, par_eis_sub_specialty, par_effective_date, par_expiry_date, 'O', '', par_update_datetime, par_update_by);
    END IF;
END;
$procedure$
;

;ALTER PROCEDURE "opas_insert_clt_by_eis_prof" OWNER TO "HPI_SCHEMA_OWNER_ROLE";