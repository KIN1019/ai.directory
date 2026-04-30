-- DROP PROCEDURE hpi.opas_update_specialty(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int2, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.opas_update_specialty(INOUT pas_return_code integer, IN par_trg_type character varying, IN par_specialty_code character varying, IN par_hospital_code character varying, IN par_description character varying, IN par_imis_specialty character varying, IN par_phone character varying, IN par_exclusive_group smallint, IN par_status character varying, IN par_type character varying)
 LANGUAGE plpgsql
AS $procedure$
/* ***** Object:  Stored Procedure dbo.opas_update_specialty    Script Date: 07/05/98 3:37:39 PM ***** */
BEGIN
    set search_path TO hpi,public;
    IF par_trg_type = 'D' THEN
        DELETE FROM op_specialty
            WHERE specialty_code = par_specialty_code AND hospital_code = par_hospital_code;
    ELSE
        IF par_trg_type = 'I' THEN
            INSERT INTO op_specialty
            VALUES (par_specialty_code, par_hospital_code, par_description, par_imis_specialty, par_phone, par_exclusive_group, par_status, par_type);
        ELSE
            IF par_trg_type = 'U' THEN
                UPDATE op_specialty
                SET spec_desc = par_description, imis_specialty = par_imis_specialty, phone = par_phone, exclusive_group = par_exclusive_group, status = par_status, type = par_type
                    WHERE specialty_code = par_specialty_code AND hospital_code = par_hospital_code;
            END IF;
        END IF;
    END IF;
    SELECT 0 INTO pas_return_code;
END;
$procedure$
;

;ALTER PROCEDURE "opas_update_specialty" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
