-- DROP PROCEDURE hpi.hasp_update_death_dtm(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_update_death_dtm(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_death_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_body_category character varying DEFAULT NULL::character varying, IN par_user_id character varying DEFAULT NULL::character varying, IN par_user_hospital character varying DEFAULT NULL::character varying, IN par_source_system character varying DEFAULT NULL::character varying, IN par_workstation_id character varying DEFAULT NULL::character varying, INOUT par_return_code integer DEFAULT NULL::integer, INOUT par_error_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            NULL
            INTO par_Error_message;

        IF par_Hospital_code IS NULL THEN
            BEGIN
                SELECT
                    'Hospital code cannot be null'
                    INTO par_Error_message;
                raise exception '';
            END;
        END IF;

        IF par_HKID IS NULL THEN
            BEGIN
                SELECT
                    'HKID cannot be null'
                    INTO par_Error_message;
                raise exception '';
            END;
        END IF;

        IF par_User_ID IS NULL OR par_User_hospital IS NULL OR par_Workstation_ID IS NULL THEN
            BEGIN
                SELECT
                    'User information cannot be null'
                    INTO par_Error_message;
                raise exception '';
            END;
        END IF;
        CALL cpi_update_death_dtm(par_Return_code, par_Hospital_code, par_HKID, par_Death_datetime, par_Body_category, par_User_ID, par_User_hospital, par_Source_system, par_Workstation_ID, par_Error_message);
    END;

    IF par_Return_code <> 0 THEN
        pas_return_code := - 1;
        RETURN;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_update_death_dtm" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
