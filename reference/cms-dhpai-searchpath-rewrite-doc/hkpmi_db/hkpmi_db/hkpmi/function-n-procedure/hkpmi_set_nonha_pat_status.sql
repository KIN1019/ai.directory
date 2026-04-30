-- DROP PROCEDURE hkpmi.hkpmi_set_nonha_pat_status(inout int4, in bpchar, in bpchar, in bpchar, in bpchar, in timestamp, in bpchar, in bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_set_nonha_pat_status(INOUT pas_return_code integer, IN par_patient_key varchar, IN par_status varchar, 
IN par_source_system varchar, IN par_update_hospital varchar, IN par_update_datetime timestamp without time zone, IN par_update_by varchar, IN par_action varchar)
 LANGUAGE plpgsql
AS $procedure$
/* --@status */
/* --Registered */
/* --Merged */
/* --Changed */
/* --HA-Patient */
/* --@action */
/* --U = update */
/* --I = insert */
DECLARE
var_error_msg VARCHAR(255);
    var_error_code INTEGER;
    var_rowcount INTEGER;
    var_log_datetime TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
<<return_error>>
BEGIN
        IF NOT (par_update_hospital = 'VH' OR EXISTS (SELECT
            1
            FROM cluster_hospital
            WHERE hospital_code = par_update_hospital)) THEN
BEGIN
SELECT
    'Hospital code not found!'
INTO var_error_msg;
EXIT return_error;
END;
END IF;

        IF par_source_system NOT IN ('ADT', 'OPAS') THEN
BEGIN
SELECT
    'Source system code invalid!'
INTO var_error_msg;
EXIT return_error;
END;
END IF;
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
        begin transaction
        */
        raise notice 'par_action=%',par_action;
       	raise notice '%,%,%,%,%,%',par_patient_key,par_status,par_source_system,par_update_hospital,par_update_datetime,par_update_by;
        IF par_action = 'U' THEN
BEGIN
BEGIN
UPDATE non_ha_patient_status
SET status = par_status, source_system = par_source_system, update_hospital = par_update_hospital, update_datetime = timestamp_convert(par_update_datetime), update_by = par_update_by
WHERE patient_key = par_patient_key;
raise notice 'hkpmi_set_nonha_pat_status[UPDATE][55]non_ha_patient_status,patient_key=%',par_patient_key;
                    var_error_code := 0;
EXCEPTION
                        WHEN OTHERS THEN
                            var_error_code := 1;
END;
GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
var_rowcount := sql$rowcount;
				raise notice 'var_error_code=%,var_rowcount=%',var_error_code,var_rowcount;
                IF var_error_code <> 0 OR var_rowcount <> 1 THEN
BEGIN
SELECT
    'Fail to update HKPMI non_ha_patient_status!'
INTO var_error_msg;
EXIT return_error;
END;
END IF;
END;
ELSE
            IF par_action = 'I' THEN
BEGIN
BEGIN
INSERT INTO non_ha_patient_status (patient_key, status, source_system, update_hospital, update_datetime, update_by)
VALUES (par_patient_key, par_status, par_source_system, par_update_hospital, timestamp_convert(par_update_datetime), par_update_by);
var_error_code := 0;
                       	raise notice 'hkpmi_set_nonha_pat_status[INSERT][79]non_ha_patient_status,patient_key=%',par_patient_key;
EXCEPTION
                            WHEN OTHERS THEN
                                var_error_code := 1;
END;
GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
var_rowcount := sql$rowcount;

                    IF var_error_code <> 0 OR var_rowcount <> 1 THEN
BEGIN
SELECT
    'Fail to insert HKPMI non_ha_patient_status!'
INTO var_error_msg;
EXIT return_error;
END;
END IF;
END;
END IF;
END IF;
        pas_return_code := 0;
        RETURN;
END;

SELECT
    50035
INTO var_error_code;
RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := var_error_code;
    pas_return_code := - 1;
    RETURN;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_set_nonha_pat_status" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
