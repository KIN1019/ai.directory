CREATE OR REPLACE PROCEDURE pass_hkpmi_set_patient_address(INOUT pas_return_code int ,IN par_hkid VARCHAR, IN par_address_type VARCHAR DEFAULT 'C', IN par_building VARCHAR DEFAULT NULL, IN par_room VARCHAR DEFAULT NULL, IN par_floor VARCHAR DEFAULT NULL, IN par_block VARCHAR DEFAULT NULL, IN par_district_code VARCHAR DEFAULT NULL, IN par_hospital_code VARCHAR DEFAULT NULL, IN par_source_system VARCHAR DEFAULT NULL, IN par_user_id VARCHAR DEFAULT NULL, INOUT par_return_code INTEGER DEFAULT NULL, INOUT par_return_message VARCHAR DEFAULT '')
 LANGUAGE plpgsql
AS $procedure$
/* --- use HKID for update, prk may diff. between CPI/PMI */
/* --- default='C' = correspondence addr */
DECLARE
    var_addr_code INTEGER;
    var_return_code int;

BEGIN
    BEGIN
        SELECT
            LTRIM(RTRIM(par_building))
            INTO par_building;
        SELECT
            LTRIM(RTRIM(par_room))
            INTO par_room;
        SELECT
            LTRIM(RTRIM(par_floor))
            INTO par_floor;
        SELECT
            LTRIM(RTRIM(par_block))
            INTO par_block;
        SELECT
            LTRIM(RTRIM(par_district_code))
            INTO par_district_code;

        IF par_building IS NOT NULL THEN
            BEGIN
                IF SUBSTRING(par_building, 1, 7) = 'HACODE:' THEN
                    BEGIN
                        SELECT
                            CAST (RIGHT(RTRIM(par_building), CHAR_LENGTH(RTRIM(par_building)) - 7) AS INTEGER)
                            INTO var_addr_code;
                        SELECT
                            NULL
                            INTO par_district_code;
                        SELECT
                            district_code
                            INTO par_district_code
                            FROM address_detail
                            WHERE record_id = var_addr_code;

                        IF par_district_code IS NULL THEN
                            BEGIN
                                SELECT
                                    - 1
                                    INTO par_return_code;
                                SELECT
                                    'invalid postal address record id'
                                    INTO par_return_message;
                                -- EXIT return_error;
                                pas_return_code := par_return_code;
                                RETURN;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        CALL hkpmi_set_patient_address(var_return_code,par_hkid, par_address_type, par_building, par_room, par_floor, par_block, par_district_code, par_hospital_code, par_source_system, par_user_id, par_return_code, par_return_message);
        /* --parse return message */
        IF par_return_code != 0 THEN
            BEGIN
                IF par_return_message = 'District not found' THEN
                    SELECT
                        'Invalid postal_address.district_code'
                        INTO par_return_message;
                END IF;

                IF par_return_message = 'Cannot update building to NULL' THEN
                    SELECT
                        'no postal address can be deleted'
                        INTO par_return_message;
                END IF;
            END;
        END IF;
    END;
   
END;
$procedure$
;

ALTER PROCEDURE "pass_hkpmi_set_patient_address" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";