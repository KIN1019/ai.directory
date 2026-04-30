-- DROP PROCEDURE hkpmi.hkpmi_set_move_episode_indicator(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_set_move_episode_indicator(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_create_dtm timestamp without time zone, IN par_from_patient_key character varying, IN par_to_patient_key character varying, IN par_create_user character varying, IN par_create_system character varying, IN par_move_status character varying, IN par_update_dtm timestamp without time zone, IN par_update_user character varying, IN par_update_system character varying, IN par_info_source_code character varying, IN par_reason_code character varying, IN par_other_reason character varying, INOUT par_return_message character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rowcount INTEGER;
    var_error INTEGER;
    var_return_code INTEGER;
    var_begin_tran VARCHAR(1);
    sql$rowcount BIGINT;
begin
	raise notice 'into hkpmi_set_move_episode_indicator';
    <<return_error>>
    BEGIN
set search_path to hkpmi;
	    select 'Y' into var_begin_tran;
        IF EXISTS (SELECT
            1
            FROM move_episode_indicator
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND create_dtm = par_create_dtm) THEN
            BEGIN
                SELECT
                    - 2
                    INTO var_return_code;
                SELECT
                    'Duplicate entry for move_episode_indicator is found'
                    INTO par_return_message;
            END;
        ELSE
            BEGIN
                BEGIN
                    INSERT INTO move_episode_indicator (hospital_code, case_no, create_dtm, from_patient_key, to_patient_key, create_user, create_system, move_status, update_dtm, update_user, update_system, info_source_code, reason_code, other_reason)
                    VALUES (par_hospital_code, par_case_no, par_create_dtm, par_from_patient_key, par_to_patient_key, par_create_user, par_create_system, par_move_status, par_update_dtm, par_update_user, par_update_system, par_info_source_code, par_reason_code, par_other_reason);
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_rowcount <> 1 OR var_error != 0 THEN
                    BEGIN
                        SELECT
                            - 3
                            INTO var_return_code;
                        SELECT
                            'Failure in inserting move_episode_indicator entry'
                            INTO par_return_message;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;

        
    END;

    IF var_return_code <> 0 OR var_error != 0 THEN
        BEGIN
            IF var_begin_tran = 'Y' THEN
                --ROLLBACK;
                raise exception '';
            END IF;
            pas_return_code := var_return_code;
            RETURN;
        END;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_set_move_episode_indicator" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";