CREATE OR REPLACE function pass_hkpmi_get_pin_change_hkid(IN par_target_hkid VARCHAR, IN par_search_backward VARCHAR DEFAULT 'N')
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/* --	25/02/2021	Harmonic Li 	To find out the history of HKID changes */
DECLARE
    var_count_loop INTEGER;
    var_max_count_loop INTEGER;
    var_search_old_hkid VARCHAR(12);
    var_search_new_hkid VARCHAR(12);
    var_search_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_search_patient_name VARCHAR(48);
    var_temp_search_hkid VARCHAR(12);
    var_temp_search_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_time_order INTEGER;
    var_groupId INTEGER;
    var_sub_time_order INTEGER;
    var_hospital_code VARCHAR(3);
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_new_hkid VARCHAR(12);
    var_patient_key VARCHAR(8);
    var_old_hkid VARCHAR(12);
    var_old_patient_name VARCHAR(48);
    change_hkid refcursor;
    sql$rowcount BIGINT;

    p_refcur refcursor;
BEGIN
	drop table if EXISTS t$result_table;
    CREATE TEMPORARY TABLE t$result_table
    (time_order INTEGER NULL,
        groupId INTEGER NULL,
        sub_time_order INTEGER NULL,
        hospital_code VARCHAR(3),
        system_dtm TIMESTAMP WITHOUT TIME ZONE,
        new_hkid VARCHAR(12),
        patient_key VARCHAR(8),
        old_hkid VARCHAR(12));

    IF par_search_backward = 'Y' THEN
        BEGIN
            BEGIN
                open change_hkid for 
                SELECT
                    hospital_code, system_dtm, new_hkid, new_patient_key, old_hkid, old_patient_name
                    FROM patient_key_changed
                    WHERE old_hkid <> new_hkid AND (new_hkid = par_target_hkid)
                    ORDER BY system_dtm DESC NULLS FIRST;
            END;
        END;
    ELSE
        BEGIN
            BEGIN
                open change_hkid for
                SELECT
                    hospital_code, system_dtm, new_hkid, new_patient_key, old_hkid, old_patient_name
                    FROM patient_key_changed
                    WHERE old_hkid <> new_hkid AND (old_hkid = par_target_hkid)
                    ORDER BY system_dtm NULLS FIRST;            
            END;
        END;
    END IF;
    var_groupId := 1;
    -- OPEN change_hkid;
    FETCH change_hkid INTO var_hospital_code, var_system_dtm, var_new_hkid, var_patient_key, var_old_hkid, var_old_patient_name;

    WHILE (CASE FOUND::INT
        WHEN 0 THEN - 1
        ELSE 0
    END) = 0 LOOP
        BEGIN
            var_search_old_hkid := var_old_hkid;
            var_search_new_hkid := var_new_hkid;
            var_search_dtm := var_system_dtm;

            IF EXISTS (SELECT
                1
                FROM t$result_table
                WHERE system_dtm = var_search_dtm AND old_hkid = var_search_old_hkid) THEN
                BEGIN
                    FETCH change_hkid INTO var_hospital_code, var_system_dtm, var_new_hkid, var_patient_key, var_old_hkid, var_old_patient_name;
                END;
            END IF;
            var_sub_time_order := 0;
            INSERT INTO t$result_table (groupid, sub_time_order, hospital_code, system_dtm, new_hkid, patient_key, old_hkid)
            SELECT
                var_groupId, var_sub_time_order, var_hospital_code, var_system_dtm, var_new_hkid, var_patient_key, var_old_hkid;
            /* --Backward */
            IF par_search_backward = 'Y' THEN
                BEGIN
                    var_sub_time_order := 0;
                    var_count_loop := 0;
                    var_max_count_loop := 100;
                    var_temp_search_hkid := var_search_old_hkid;
                    var_temp_search_dtm := var_search_dtm;
                    var_search_patient_name := var_old_patient_name;

                    WHILE (var_count_loop < var_max_count_loop) LOOP
                        SELECT
                            hospital_code, system_dtm, new_hkid, new_patient_key, old_hkid, old_patient_name
                            INTO var_hospital_code, var_system_dtm, var_new_hkid, var_patient_key, var_old_hkid, var_old_patient_name
                            FROM (SELECT
                                hospital_code, system_dtm, new_hkid, new_patient_key, old_hkid, old_patient_name
                                FROM patient_key_changed) AS ungrouped_query, (SELECT
                                MAX(system_dtm) AS max_1
                                FROM patient_key_changed
                                WHERE new_hkid = var_temp_search_hkid AND system_dtm <= var_temp_search_dtm AND new_patient_name = var_search_patient_name) AS grouped_query
                            WHERE system_dtm = max_1;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF sql$rowcount = 0 THEN
                            BEGIN
                                EXIT;
                            END;
                        END IF;

                        IF var_new_hkid = var_old_hkid THEN
                            BEGIN
                                var_search_patient_name := var_old_patient_name;
                            END;
                        ELSE
                            BEGIN
                                var_temp_search_hkid := var_old_hkid;
                                var_temp_search_dtm := var_system_dtm;
                                var_sub_time_order := var_sub_time_order - 1;
                                INSERT INTO t$result_table (groupid, sub_time_order, hospital_code, system_dtm, new_hkid, patient_key, old_hkid)
                                SELECT
                                    var_groupId, var_sub_time_order, var_hospital_code, var_system_dtm, var_new_hkid, var_patient_key, var_old_hkid;
                            END;
                        END IF;
                        var_count_loop := var_count_loop + 1;
                    END LOOP;
                END;
            ELSE
                /* --Forward */
                BEGIN
                    var_sub_time_order := 0;
                    var_count_loop := 0;
                    var_max_count_loop := 100;
                    var_temp_search_hkid := var_search_new_hkid;
                    var_temp_search_dtm := var_search_dtm;

                    WHILE (var_count_loop < var_max_count_loop) LOOP
                        SELECT
                            hospital_code, system_dtm, new_hkid, new_patient_key, old_hkid
                            INTO var_hospital_code, var_system_dtm, var_new_hkid, var_patient_key, var_old_hkid
                            FROM (SELECT
                                hospital_code, system_dtm, new_hkid, new_patient_key, old_hkid
                                FROM patient_key_changed) AS ungrouped_query, (SELECT
                                MIN(system_dtm) AS min_1
                                FROM patient_key_changed
                                WHERE old_hkid = var_temp_search_hkid AND system_dtm >= var_temp_search_dtm AND old_hkid <> new_hkid) AS grouped_query
                            WHERE system_dtm = min_1;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF sql$rowcount = 0 THEN
                            BEGIN
                                EXIT;
                            END;
                        END IF;
                        var_temp_search_hkid := var_new_hkid;
                        var_temp_search_dtm := var_system_dtm;
                        var_sub_time_order := var_sub_time_order + 1;
                        INSERT INTO t$result_table (groupid, sub_time_order, hospital_code, system_dtm, new_hkid, patient_key, old_hkid)
                        SELECT
                            var_groupId, var_sub_time_order, var_hospital_code, var_system_dtm, var_new_hkid, var_patient_key, var_old_hkid;
                        var_count_loop := var_count_loop + 1;
                    END LOOP;
                    /*
                    
                    DROP TABLE IF EXISTS t$result_table;
                    */
                    /*
                    
                    Temporary table must be removed before end of the function.
                    */
                END;
            END IF;
            var_groupId := var_groupId + 1;
        END;
        
    END LOOP;
    CLOSE change_hkid;
    /* Update sub_order */
    SELECT
        MAX(groupid)
        INTO var_groupId
        FROM t$result_table;

    WHILE (var_groupId > 0) LOOP
        UPDATE t$result_table
        SET sub_time_order = sub_time_order * - 1
            WHERE groupid = var_groupId;
        SELECT
            MIN(sub_time_order) * - 1 + 1
            INTO var_sub_time_order
            FROM t$result_table
            WHERE groupid = var_groupId;
        UPDATE t$result_table
        SET sub_time_order = sub_time_order + var_sub_time_order
            WHERE groupid = var_groupId;
        var_groupId := var_groupId - 1;
    END LOOP;
    /* Update order */
    SELECT
        COUNT(*)
        INTO var_time_order
        FROM t$result_table;

    WHILE (var_time_order > 0) LOOP
        UPDATE t$result_table
        SET time_order = var_time_order
            WHERE system_dtm = (SELECT
                MIN(system_dtm)
                FROM t$result_table
                WHERE time_order IS NULL);
        var_time_order := var_time_order - 1;
    END LOOP;
    OPEN p_refcur FOR
    SELECT
        time_order, groupid, sub_time_order, hospital_code, system_dtm, new_hkid, patient_key, old_hkid
        FROM t$result_table
        ORDER BY time_order DESC NULLS FIRST;
    return next p_refcur;
    RETURN;
END;
$function$
;

ALTER FUNCTION "pass_hkpmi_get_pin_change_hkid" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
