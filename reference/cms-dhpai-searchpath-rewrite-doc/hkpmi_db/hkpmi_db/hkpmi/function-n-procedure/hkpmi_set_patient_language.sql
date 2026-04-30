-- DROP PROCEDURE hkpmi.hkpmi_set_patient_language(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_set_patient_language(INOUT pas_return_code integer, IN par_hkid character varying, IN par_language_code character varying, IN par_mode character varying, IN par_source_system character varying, IN par_update_hospital character varying, IN par_update_datetime timestamp without time zone, IN par_update_by character varying)
 LANGUAGE plpgsql
AS $procedure$
/* @mode */
/* N:	New */
/* U:	Update */
/* D:	Delete */
DECLARE
var_patient_key CHAR(8);
    var_error_msg VARCHAR(255);
    var_error_code INTEGER;
    var_rowcount INTEGER;
    var_log_datetime TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
<<return_error>>
BEGIN
SELECT
    patient_key
INTO var_patient_key
FROM patient
WHERE hkid = par_hkid;

IF var_patient_key IS NULL THEN
BEGIN
SELECT
    'Patient record not found!'
INTO var_error_msg;
RAISE exception '';
END;
END IF;

        IF NOT (par_update_hospital = 'VH' OR EXISTS (SELECT
            1
            FROM cluster_hospital
            WHERE hospital_code = par_update_hospital)) THEN
BEGIN
SELECT
    'Hospital code not found!'
INTO var_error_msg;
RAISE exception '';
END;
END IF;

        IF par_source_system NOT IN ('ADT', 'OPAS') THEN
BEGIN
SELECT
    'Source system code invalid!'
INTO var_error_msg;
RAISE exception '';
END;
END IF;

        IF NOT EXISTS (SELECT
            1
            FROM interpretation_language
            WHERE language_code = par_language_code) AND par_mode IN ('N', 'U') THEN
BEGIN
SELECT
    'Patient language code not found!'
INTO var_error_msg;
RAISE exception '';
END;
END IF;
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
        	begin
        		begin tran
        	end
        */
        IF par_mode IN ('N', 'U') THEN
BEGIN
                IF EXISTS (SELECT
                    1
                    FROM hkpmi_patient_language
                    WHERE patient_key = var_patient_key) THEN
BEGIN
SELECT
    update_datetime
INTO var_log_datetime
FROM hkpmi_patient_language
WHERE patient_key = var_patient_key;
/* --To avoid insert duplicate key error */
IF EXISTS (SELECT
                            1
                            FROM hkpmi_patient_language AS p, hkpmi_patient_language_log AS l
                            WHERE l.patient_key = var_patient_key AND l.patient_key = p.patient_key AND l.update_datetime = p.update_datetime) THEN
BEGIN
SELECT
    + 5 * INTERVAL '1 millisecond' + var_log_datetime::TIMESTAMP
INTO var_log_datetime;
END;
END IF;

BEGIN
INSERT INTO hkpmi_patient_language_log
SELECT
    patient_key, language_code, status, source_system, update_hospital, var_log_datetime, update_by
FROM hkpmi_patient_language
WHERE patient_key = var_patient_key;
var_error_code := 0;
                           raise notice 'hkpmi_set_patient_language-[INSERT]hkpmi_patient_language_log patient_key=%',var_patient_key;
EXCEPTION
                                WHEN OTHERS THEN
                                    var_error_code := 1;
END;
GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
var_rowcount := sql$rowcount;

                        IF var_error_code <> 0 OR var_rowcount <> 1 THEN
BEGIN
SELECT
    'Fail to update hkpmi_patient_language_log!'
INTO var_error_msg;
RAISE exception '';
END;
END IF;

BEGIN
UPDATE hkpmi_patient_language
SET language_code = par_language_code, status = 'A', source_system = par_source_system, update_hospital = par_update_hospital, update_datetime = par_update_datetime, update_by = par_update_by
WHERE patient_key = var_patient_key;
var_error_code := 0;
                             raise notice 'hkpmi_set_patient_language-[UPDATE]hkpmi_patient_language patient_key=%',var_patient_key;

EXCEPTION
                                WHEN OTHERS THEN
                                    var_error_code := 1;
END;
GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
var_rowcount := sql$rowcount;

                        IF var_error_code <> 0 OR var_rowcount <> 1 THEN
BEGIN
SELECT
    'Fail to update hkpmi_patient_language!'
INTO var_error_msg;
RAISE exception '';
END;
END IF;
END;
ELSE
BEGIN
BEGIN
INSERT INTO hkpmi_patient_language (patient_key, language_code, status, source_system, update_hospital, update_datetime, update_by)
VALUES (var_patient_key, par_language_code, 'A', par_source_system, par_update_hospital, par_update_datetime, par_update_by);
var_error_code := 0;
                            raise notice 'hkpmi_set_patient_language-[INSERT]hkpmi_patient_language patient_key=%',var_patient_key;

EXCEPTION
                                WHEN OTHERS THEN
                                    var_error_code := 1;
END;
GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
var_rowcount := sql$rowcount;

                        IF var_error_code <> 0 OR var_rowcount <> 1 THEN
BEGIN
SELECT
    'Fail to insert hkpmi_patient_language!'
INTO var_error_msg;
RAISE exception '';
END;
END IF;
END;
END IF;
END;
END IF;

        IF par_mode IN ('D') THEN
BEGIN
SELECT
    update_datetime
INTO var_log_datetime
FROM hkpmi_patient_language
WHERE patient_key = var_patient_key;
/* --To avoid insert duplicate key error */
IF EXISTS (SELECT
                    1
                    FROM hkpmi_patient_language AS p, hkpmi_patient_language_log AS l
                    WHERE l.patient_key = var_patient_key AND l.patient_key = p.patient_key AND l.update_datetime = p.update_datetime) THEN
BEGIN
SELECT
    + 5 * INTERVAL '1 millisecond' + var_log_datetime::TIMESTAMP
INTO var_log_datetime;
END;
END IF;

BEGIN
INSERT INTO hkpmi_patient_language_log
SELECT
    patient_key, language_code, status, source_system, update_hospital, var_log_datetime, update_by
FROM hkpmi_patient_language
WHERE patient_key = var_patient_key;
raise notice 'hkpmi_set_patient_language-[INSERT]hkpmi_patient_language_log patient_key=%',var_patient_key;

                    var_error_code := 0;
EXCEPTION
                        WHEN OTHERS THEN
                            var_error_code := 1;
END;
GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
var_rowcount := sql$rowcount;

                IF var_error_code <> 0 OR var_rowcount <> 1 THEN
BEGIN
SELECT
    'Fail to update hkpmi_patient_language_log!'
INTO var_error_msg;
RAISE exception '';
END;
END IF;

BEGIN
UPDATE hkpmi_patient_language
SET status = 'I', source_system = par_source_system, update_hospital = par_update_hospital, update_datetime = par_update_datetime, update_by = par_update_by
WHERE patient_key = var_patient_key;
raise notice 'hkpmi_set_patient_language-[UPDATE]hkpmi_patient_language patient_key=%',var_patient_key;

                    var_error_code := 0;
EXCEPTION
                        WHEN OTHERS THEN
                            var_error_code := 1;
END;
GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
var_rowcount := sql$rowcount;

                IF var_error_code <> 0 OR var_rowcount <> 1 THEN
BEGIN
SELECT
    'Fail to update hkpmi_patient_language!'
INTO var_error_msg;
RAISE exception '';
END;
END IF;
END;
END IF;
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount > 0
        	begin
        		commit
        	end
        */
        pas_return_code := 0;
        RETURN;
EXCEPTION
			WHEN OTHERS then
begin
				EXIT return_error;
end;
END;
SELECT
    500034
INTO var_error_code;
RAISE EXCEPTION '% ', var_error_msg USING ERRCODE = var_error_code;
    pas_return_code := - 1;
    RETURN;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_set_patient_language" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
