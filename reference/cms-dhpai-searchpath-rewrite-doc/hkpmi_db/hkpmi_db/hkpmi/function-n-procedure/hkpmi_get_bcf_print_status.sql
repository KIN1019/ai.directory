-- DROP PROCEDURE hkpmi_get_bcf_print_status(inout int4, in varchar, in varchar, inout varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi_get_bcf_print_status(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, INOUT par_status_code character varying, INOUT par_return_code integer, INOUT par_error_message character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
	SET SEARCH_PATH TO HKPMI;
    SELECT
        0
        INTO par_return_code;
    SELECT
        NULL
        INTO par_error_message;

    BEGIN
        IF EXISTS (SELECT
            hkid
            FROM bcf_log
            WHERE hkid = par_hkid) THEN
            SELECT
                'D'
                INTO par_status_code;
        ELSE
            SELECT
                'F'
                INTO par_status_code;
        END IF;
        par_return_code := 0;
        EXCEPTION
            WHEN OTHERS THEN
            	raise notice 'err_msg=>%',sqlerrm;
                par_return_code := 1;
    END;

    IF par_return_code != 0 THEN
        SELECT
            'System error'
            INTO par_error_message;
    END IF;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_get_bcf_print_status" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

