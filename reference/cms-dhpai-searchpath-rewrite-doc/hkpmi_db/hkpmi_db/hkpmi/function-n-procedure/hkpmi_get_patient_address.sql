-- DROP PROCEDURE hkpmi.hkpmi_get_patient_address(inout int4, in bpchar, in bpchar, inout varchar, inout bpchar, inout bpchar, inout bpchar, inout bpchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_get_patient_address(INOUT pas_return_code integer, IN par_hkid VARCHAR, IN par_address_type VARCHAR DEFAULT 'C'::VARCHAR,
 INOUT par_building character varying DEFAULT NULL::character varying, INOUT par_room VARCHAR DEFAULT NULL::VARCHAR, INOUT par_floor VARCHAR DEFAULT NULL::VARCHAR, 
 INOUT par_block VARCHAR DEFAULT NULL::VARCHAR, INOUT par_district_code VARCHAR DEFAULT NULL::VARCHAR, INOUT par_return_code integer DEFAULT NULL::integer, INOUT par_return_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* --- use HKID for update, prk may diff. between CPI/PMI */
/* --- default='C' = correspondence addr */
DECLARE
    var_prk VARCHAR(8);
    var_rtn_code INTEGER;
    var_err_msg VARCHAR(255);
    var_error_code INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        IF LTRIM(RTRIM(par_building)) = '' THEN
            SELECT
                NULL
                INTO par_building;
        END IF;

        IF LTRIM(RTRIM(par_room)) = '' THEN
            SELECT
                NULL
                INTO par_room;
        END IF;

        IF LTRIM(RTRIM(par_floor)) = '' THEN
            SELECT
                NULL
                INTO par_floor;
        END IF;

        IF LTRIM(RTRIM(par_block)) = '' THEN
            SELECT
                NULL
                INTO par_block;
        END IF;

        IF LTRIM(RTRIM(par_district_code)) = '' THEN
            SELECT
                NULL
                INTO par_district_code;
        END IF;
        SELECT
            patient_key
            INTO var_prk
            FROM patient
            WHERE hkid = par_hkid;
        /* ---Patient Not Found -- */
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount <> 1 THEN /* ----@@rowcount = 0 */
            BEGIN
                SELECT
                    - 1
                    INTO var_rtn_code;
                SELECT
                    'Patient Not Found !'
                    INTO var_err_msg;
                EXIT return_error;
            END;
        END IF;
        SELECT
            building, room, floor, block, district_code
            INTO par_building, par_room, par_floor, par_block, par_district_code
            FROM hkpmi_patient_address_list
            WHERE patient_key = var_prk AND address_type = par_address_type;
        /* ------------ entry not found for the patient -------- */
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount <> 1 THEN
            BEGIN
                SELECT
                    1
                    INTO var_rtn_code;
                SELECT
                    'Target address entry is not find'
                    INTO var_err_msg;
                EXIT return_error;
            END;
        END IF;
        SELECT
            NULL
            INTO par_return_message;

        <<return_normal>>
        BEGIN
            SELECT
                0
                INTO par_return_code;
            pas_return_code := 0;
            RETURN;
        END;
    END;
    SELECT
        var_err_msg
        INTO par_return_message;
    SELECT
        var_rtn_code
        INTO par_return_code;
    pas_return_code := var_rtn_code;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_get_patient_address" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

