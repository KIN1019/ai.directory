-- DROP PROCEDURE hkpmi.hkpmi_set_patient_address(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_set_patient_address(INOUT pas_return_code integer, IN par_hkid character varying, IN par_address_type character varying DEFAULT 'C'::character varying, IN par_building character varying DEFAULT NULL::character varying, IN par_room character varying DEFAULT NULL::character varying, IN par_floor character varying DEFAULT NULL::character varying, IN par_block character varying DEFAULT NULL::character varying, IN par_district_code character varying DEFAULT NULL::character varying, IN par_hospital_code character varying DEFAULT NULL::character varying, IN par_source_system character varying DEFAULT NULL::character varying, IN par_user_id character varying DEFAULT NULL::character varying, INOUT par_return_code integer DEFAULT NULL::integer, INOUT par_return_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* --- use HKID for update, prk may diff. between CPI/PMI */
/* --- default='C' = correspondence addr */
DECLARE
var_begin_tran varchar(01);
    var_prk varchar(8);
    var_rtn_code INTEGER;
    var_err_msg varchar(255);
    var_error_code INTEGER;
    var_old_building VARCHAR(255);
    var_old_floor varchar(5);
    var_old_room varchar(5);
    var_old_block varchar(5);
    var_old_district_code varchar(5);
    var_opr_type varchar(5);
    sql$rowcount BIGINT;
BEGIN
<<return_error>>
BEGIN
<<return_normal>>
begin
	        set search_path TO hkpmi,public;
select 'Y' into var_begin_tran;
/* ----checking rule --- */
IF NOT (par_hospital_code = 'VH' OR EXISTS (SELECT
                1
                FROM cluster_hospital
                WHERE hospital_code = par_hospital_code::VARCHAR)) THEN
BEGIN
SELECT
    - 1
INTO var_rtn_code;
/* select @err_msg = 'Incorrect hospital code' */
SELECT
    'Hospital not found!'
INTO var_err_msg;
RAISE EXCEPTION '% ', var_err_msg USING ERRCODE := '200156';
                    EXIT return_error;
END;
END IF;

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
    NULL, NULL, NULL, NULL, NULL
INTO var_old_building, var_old_floor, var_old_room, var_old_block, var_old_district_code;
/* ----checking rule --- */
IF par_building <> NULL THEN
BEGIN
                    IF NOT EXISTS (SELECT
                        *
                        FROM district
                        WHERE district_code = par_district_code) THEN
BEGIN
SELECT
    - 1
INTO var_rtn_code;
/* select @err_msg = 'Incorrect district code' */
SELECT
    'District not found!'
INTO var_err_msg;
RAISE EXCEPTION '% ', var_err_msg USING ERRCODE := '500029';
                            EXIT return_error;
END;
END IF;
END;
END IF;

            IF par_source_system NOT IN ('ADT', 'OPAS', 'OPAS2', 'PBRC') THEN
BEGIN
SELECT
    - 1
INTO var_rtn_code;
/* select @err_msg = 'Incorrect Source System !' */
SELECT
    'Invalid Source System!'
INTO var_err_msg;
RAISE EXCEPTION '% ', par_source_system USING ERRCODE := '500019';
                    EXIT return_error;
END;
END IF;
SELECT
    patient_key
INTO var_prk
FROM patient
WHERE hkid = par_hkid;
/* --- Patient Not Found -- */
GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

IF sql$rowcount <> 1 THEN
BEGIN
SELECT
    - 1
INTO var_rtn_code;
SELECT
    'Patient Not Found!'
INTO var_err_msg;
RAISE EXCEPTION '% ', var_err_msg USING ERRCODE := '200012';
                    EXIT return_error;
END;
END IF;
SELECT
    building, room, FLOOR, block, district_code
INTO var_old_building, var_old_room, var_old_floor, var_old_block, var_old_district_code
FROM hkpmi_patient_address_list
WHERE patient_key = var_prk::VARCHAR AND address_type = par_address_type::VARCHAR;
GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

IF sql$rowcount = 0 THEN
BEGIN
                    /* ----------- 'INS' : Insert New Record ------------------------- */
                    /* --- Reject if @building = null and NO old Records for patient  --- */
                    IF par_building IS NULL THEN
BEGIN
SELECT
    - 1
INTO var_rtn_code;
SELECT
    'Cannot update building to NULL'
INTO var_err_msg;
RAISE EXCEPTION '% ', var_err_msg USING ERRCODE := '500030';
                            EXIT return_error;
END;
END IF;

BEGIN
INSERT INTO hkpmi_patient_address_list (patient_key, address_type, building, room, floor, block, district_code, source_system, update_hospital, update_by, update_datetime)
VALUES (var_prk, par_address_type, par_building, par_room, par_floor, par_block, par_district_code, par_source_system, par_hospital_code, par_user_id, localtimestamp);
var_error_code := 0;
EXCEPTION
                            WHEN OTHERS THEN
                                var_error_code := 1;
END;

                    IF var_error_code <> 0 THEN
BEGIN
SELECT
    - 11
INTO var_rtn_code;
SELECT
    'Insert hkpmi_patient_address_list Failed!'
INTO var_err_msg;
RAISE EXCEPTION '% ', var_err_msg USING ERRCODE := '500031';
                            EXIT return_error;
END;
ELSE
BEGIN
BEGIN
INSERT INTO hkpmi_patient_address_log (system_dtm, patient_key, update_type, address_type, building, room, floor, block, district_code, old_building, old_room, old_floor, old_block, old_district_code, source_system, update_hospital, update_by, update_datetime)
VALUES (localtimestamp, var_prk, 'INS', par_address_type, par_building, par_room, par_floor, par_block, par_district_code, NULL, NULL, NULL, NULL, NULL, par_source_system, par_hospital_code, par_user_id, localtimestamp);
var_error_code := 0;
EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error_code := 1;
END;

                            IF var_error_code <> 0 THEN
BEGIN
SELECT
    - 12
INTO var_rtn_code;
SELECT
    'Insert hkpmi_patient_address_log Failed!'
INTO var_err_msg;
RAISE EXCEPTION '% ', var_err_msg USING ERRCODE := '500032';
                                    EXIT return_error;
END;
END IF;
                            EXIT return_normal;
END;
END IF;
END;
ELSE
                /* ----update existing record ----- */
BEGIN
                    /* ----- 'DEL' if  Old record existed & new building = NULL --- */
BEGIN
                        IF par_building is NULL THEN
BEGIN
SELECT
    'DEL'
INTO var_opr_type;
DELETE FROM hkpmi_patient_address_list
WHERE patient_key = var_prk::VARCHAR AND address_type = par_address_type::VARCHAR;
END;
ELSE
BEGIN
                                /*
                                if @building <> @old_building
                                				or @room <> @old_room
                                				or @floor <> @old_floor
                                				or @block <> @old_block
                                				or @district_code <> @old_district_code
                                                       	begin
                                	                        ---- 'UPD' if New record <> Old Record -----
                                */
SELECT
    'UPD'
INTO var_opr_type;
UPDATE hkpmi_patient_address_list
SET building = par_building, room = par_room, FLOOR = par_floor, block = par_block, district_code = par_district_code, source_system = par_source_system, update_hospital = par_hospital_code, update_by = par_user_id, update_datetime = localtimestamp
WHERE patient_key = var_prk::VARCHAR AND address_type = par_address_type::VARCHAR;
/*
end
else ----- return as normal if no update ----
begin
    goto return_normal
end
*/
END;
END IF;
                        var_error_code := 0;
EXCEPTION
                            WHEN OTHERS THEN
                                var_error_code := 1;
END;

                    IF var_error_code <> 0 THEN
BEGIN
SELECT
    - 13
INTO var_rtn_code;
SELECT
    'Update hkpmi_patient_address_list Failed!'
INTO var_err_msg;
RAISE EXCEPTION '% ', var_err_msg USING ERRCODE := '500033';
                            EXIT return_error;
END;
ELSE
BEGIN
BEGIN
INSERT INTO hkpmi_patient_address_log (system_dtm, patient_key, update_type, address_type, building, room, floor, block, district_code, old_building, old_room, old_floor, old_block, old_district_code, source_system, update_hospital, update_by, update_datetime)
VALUES (localtimestamp, var_prk, var_opr_type, par_address_type, par_building, par_room, par_floor, par_block, par_district_code, var_old_building, var_old_room, var_old_floor, var_old_block, var_old_district_code, par_source_system, par_hospital_code, par_user_id, localtimestamp);
var_error_code := 0;
EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error_code := 1;
END;

                            IF var_error_code <> 0 THEN
BEGIN
SELECT
    - 14
INTO var_rtn_code;
SELECT
    'Insert hkpmi_patient_address_log Failed!'
INTO var_err_msg;
RAISE EXCEPTION '% ', var_err_msg USING ERRCODE := '500032';
                                    EXIT return_error;
END;
END IF;
                            EXIT return_normal;
END;
END IF;
END;
END IF;
END;
SELECT
    NULL
INTO par_return_message;
SELECT
    0
INTO par_return_code;

pas_return_code := 0;
        RETURN;
END;
SELECT
    var_err_msg
INTO par_return_message;
SELECT
    var_rtn_code
INTO par_return_code;

IF var_begin_tran = 'Y' THEN
        ROLLBACK;
END IF;
    pas_return_code := var_rtn_code;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_set_patient_address" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";