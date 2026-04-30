-- DROP PROCEDURE hpi.hasp_ae_discharge_by_cis(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.hasp_ae_discharge_by_cis(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_discharge_datetime timestamp without time zone, IN par_user_id character varying, IN par_discharge_code character varying, IN par_destination_code character varying, IN par_death_date timestamp without time zone DEFAULT NULL::timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/*
Return values   Meaning
0					normal
1					invalid hospital code
2					ADT_Case not found
3					invalid destination code with discharge code
					if dest_code != null, discharge_code is (0,4,9)
4					Discharge datetime < last movement datetime
5					Discharge datetime is null
6					Invalid Discharge code
7					ADT_Case already discharged by ADT user
8					Cannot cancel prev AE discharge(by using SP)
9					Invalid Destination code
10					Cannot discharge AE case (SP ERROR)
11					ADT_Case not found after cancel discharge
12				   Discharge datetime > system_datetime
13				   (within 2 mins)Discharge datetime > system_datetime
*/
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_transaction_type VARCHAR(06);
    var_retcode INTEGER;
    var_adm_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_message VARCHAR(200);
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_last_movement_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_last_upd_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_last_discharge_code VARCHAR(02);
    var_last_destination_code VARCHAR(06);
    var_last_user_id VARCHAR(16);
    var_time_diff INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<abnormal_end>>
    BEGIN
        <<skip_update>>
        BEGIN
            /*
            [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
            begin transaction
            */
            /*
            [3057 - Severity CRITICAL - PostgreSQL does not support SAVE TRAN cis command. Perform a manual conversion.]
            save transaction cis
            */
            SELECT
                timestamp_convert(localtimestamp)
                INTO var_system_datetime;
            SELECT
                0
                INTO var_error;

            IF NOT EXISTS (SELECT
                *
                FROM Hospital
                WHERE Hospital_code = par_hospital_code) THEN
                BEGIN
                    SELECT
                        CONCAT('Invalid Hospital code ', par_hospital_code)
                        INTO var_message;
                    SELECT
                        1
                        INTO var_error;
                    raise exception '';
                END;
            END IF;

            IF NOT EXISTS (SELECT
                *
                FROM Discharge_type
                WHERE Discharge_code = par_discharge_code) THEN
                BEGIN
                    SELECT
                        CONCAT('Invalid Discharge code ', par_case_no, ' ', par_discharge_code)
                        INTO var_message;
                    SELECT
                        6
                        INTO var_error;
                    raise exception '';
                END;
            END IF;
            /* change to check discharge code and destination code by Leo */
            IF (par_destination_code is not NULL) AND NOT (par_discharge_code = '0' OR par_discharge_code = '4' OR par_discharge_code = '9') THEN
                BEGIN
                    SELECT
                        CONCAT('Destination code ', par_destination_code, ' is invalid with discharge code', par_destination_code, 'for case ', par_case_no)
                        INTO var_message;
                    SELECT
                        3
                        INTO var_error;
                    raise exception '';
                END;
            END IF;

            IF (par_destination_code is NULL) AND (par_discharge_code = '0' OR par_discharge_code = '4' OR par_discharge_code = '9') THEN
                BEGIN
                    SELECT
                        CONCAT('Destination code ', par_destination_code, ' is invalid with discharge code', par_destination_code, 'for case ', par_case_no)
                        INTO var_message;
                    SELECT
                        3
                        INTO var_error;
                    raise exception '';
                END;
            END IF;
            /* change to check discharge code and destination code by Leo */
            IF (par_destination_code is not NULL) AND NOT EXISTS (SELECT
                *
                FROM Destination
                WHERE Destination_code = par_destination_code) THEN
                BEGIN
                    SELECT
                        CONCAT('Invalid Destination code ', par_case_no, ' ', par_destination_code)
                        INTO var_message;
                    SELECT
                        9
                        INTO var_error;
                    raise exception '';
                END;
            END IF;

            IF par_discharge_datetime is NULL THEN
                BEGIN
                    SELECT
                        CONCAT('Discharge datetime is null ', par_case_no)
                        INTO var_message;
                    SELECT
                        5
                        INTO var_error;
                    raise exception '';
                END;
            END IF;

            IF par_discharge_datetime > var_system_datetime THEN
                BEGIN
                    SELECT
                        (FLOOR(DATE_PART('epoch', par_discharge_datetime::TIMESTAMP) - DATE_PART('epoch', var_system_datetime::TIMESTAMP)) / 60)::NUMERIC(20, 0)
                        INTO var_time_diff;
					raise notice 'var_time_diff:%',var_time_diff;
                    IF var_time_diff > 2 THEN
                        BEGIN
                            SELECT
                                CONCAT('Discharge datetime > system datetime', par_case_no)
                                INTO var_message;
                            SELECT
                                12
                                INTO var_error;
                            raise exception '';
                        END;
                    ELSE
                        BEGIN
                            SELECT
                                CONCAT('Discharge dtm > system dtm(within 2 mins)', par_case_no)
                                INTO var_message;
                            SELECT
                                13
                                INTO var_error;
                            raise exception '';
                        END;
                    END IF;
                END;
            END IF;
            /* ----- Modified by WL on 21 July 1999 for HPI ---- */
            SELECT
                a.Discharge_code, a.User_ID, a.Destination_code, a.System_datetime, b.Movement_datetime, a.row_update_datetime
                INTO var_last_discharge_code, var_last_user_id, var_last_destination_code, var_last_upd_datetime, var_last_movement_datetime, var_timestamp
                FROM ADT_Case AS a, Movement AS b
                WHERE a.Case_no = par_case_no AND a.Hospital_code = par_hospital_code AND b.Case_no = par_case_no AND b.Hospital_code = par_hospital_code AND a.Movement_count = b.Movement_count;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF var_rowcount = 0 THEN
                BEGIN
                    SELECT
                        CONCAT('Case not found ', par_case_no)
                        INTO var_message;
                    SELECT
                        2
                        INTO var_error;
                    raise exception '';
                END;
            END IF;

            IF var_last_discharge_code is not NULL THEN
                BEGIN
                    IF var_last_user_id != par_user_id AND NOT (var_last_user_id = 'ADT' AND var_last_discharge_code = '7') THEN
                        BEGIN
                            SELECT
                                CONCAT('Case already discharged by ADT ', par_case_no, ' ', var_last_user_id)
                                INTO var_message;
                            SELECT
                                7
                                INTO var_error;
                            raise exception '';
                        END;
                    ELSE
                        BEGIN
                            IF var_last_discharge_code = par_discharge_code AND var_last_movement_datetime = par_discharge_datetime AND var_last_destination_code = par_destination_code THEN
                                raise exception '';
                            ELSE
                                BEGIN
                                    /* cancel prev ae discharge */
                                    CALL hasp_cis_can_discharge(var_retcode, par_hospital_code, par_case_no, 'AE01', par_user_id, var_last_upd_datetime, 'AE');

                                    IF var_retcode != 0 THEN
                                        BEGIN
                                            SELECT
                                                CONCAT('Cannot cancel prev AE discharge ', par_case_no, ' return code = ', CAST (var_retcode AS VARCHAR(20)))
                                                INTO var_message;
                                            SELECT
                                                8
                                                INTO var_error;
                                            raise exception '';
                                        END;
                                    END IF;
                                    /* --- Modified by WL on 21 July 1999 for HPI --- */
                                    SELECT
                                        b.Movement_datetime
                                        INTO var_last_movement_datetime
                                        FROM ADT_Case AS a, Movement AS b
                                        WHERE a.Case_no = par_case_no AND a.Hospital_code = par_hospital_code AND b.Case_no = par_case_no AND a.Movement_count = b.Movement_count AND b.Hospital_code = par_hospital_code;
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                                    var_rowcount := sql$rowcount;

                                    IF var_rowcount = 0 THEN
                                        BEGIN
                                            SELECT
                                                CONCAT('Case not found after cancel discharge ', par_case_no)
                                                INTO var_message;
                                            SELECT
                                                11
                                                INTO var_error;
                                            raise exception '';
                                        END;
                                    END IF;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;

            IF par_discharge_datetime < var_last_movement_datetime THEN
                BEGIN
                    SELECT
                        CONCAT('Discharge datetime < last movement datetime ', par_case_no, ' ', to_char(par_discharge_datetime::TIMESTAMP WITHOUT TIME ZONE, 'Mon DD YYYY HH:MI:SS.MSpm'))
                        INTO var_message;
                    SELECT
                        4
                        INTO var_error;
                    raise exception '';
                END;
            END IF;
            SELECT
                timestamp_convert(localtimestamp)
                INTO var_system_datetime;
            CALL hasp_discharge_ae_case(var_retcode, par_hospital_code, par_case_no, par_discharge_datetime, var_system_datetime, par_user_id, par_discharge_code, par_destination_code, par_death_date);

            IF var_retcode != 0 THEN
                BEGIN
                    SELECT
                        CONCAT('Cannot discharge AE case ', par_case_no)
                        INTO var_message;
                    SELECT
                        10
                        INTO var_error;
                    raise exception '';
                END;
            END IF;
        END;
        pas_return_code := var_error;
        RETURN;
    END;
   	exception when others then
   		begin
	   		SELECT
		        CONCAT('hasp_ae_discharge_by_cis ', var_message)
		        INTO var_message;
		    /* --- Modified by WL on 21 July 1999 for HPI --- */
		    /*INSERT INTO Error_log
		    VALUES (par_hospital_code, var_system_datetime, var_message, NULL, NULL, NULL);*/
		    raise notice 'var_error:%',var_error;
		    pas_return_code := var_error;
		    RETURN;
	   	end;
END;
$procedure$
;
