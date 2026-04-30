CREATE OR REPLACE FUNCTION hkpmi_get_hkpmi_change_hkid(par_from_hkid varchar)
 RETURNS TABLE(res_hkid VARCHAR, res_patient_name VARCHAR, res_sex VARCHAR, res_dob TIMESTAMP WITHOUT TIME ZONE, res_hospital_code VARCHAR, res_update_by VARCHAR, res_system_dtm TIMESTAMP WITHOUT TIME ZONE, res_d INTEGER)
 LANGUAGE plpgsql
AS $function$

DECLARE
    var_old_hkid VARCHAR(12);
    var_old_patient_name VARCHAR(48);
    var_old_sex VARCHAR(1);
    var_old_dob TIMESTAMP WITHOUT TIME ZONE;
    var_new_hkid VARCHAR(12);
    var_new_sex VARCHAR(1);
    var_new_dob TIMESTAMP WITHOUT TIME ZONE;
    var_new_patient_name VARCHAR(48);
    var_hospital_code VARCHAR(3);
    var_update_by VARCHAR(8);
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_id INTEGER;
    var_search_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_search_hkid VARCHAR(12);
    sql$rowcount BIGINT;
    change_csr CURSOR FOR
    SELECT
        system_dtm, update_by, hospital_code, old_hkid, old_patient_name, old_sex, old_dob, new_hkid, new_patient_name, new_sex, new_dob
        FROM patient_key_changed
        WHERE old_hkid <> new_hkid AND old_hkid = par_from_hkid
        ORDER BY system_dtm NULLS FIRST;
BEGIN
    SET search_path TO hkpmi, public; 
    /* -- declare local variable -- */
    SELECT
        1
        INTO var_id;
    /* -- create temp table to store result -- */
    DROP TABLE IF EXISTS t$temp_change_hkid;
    CREATE TEMPORARY TABLE t$temp_change_hkid
    (id INTEGER NULL,
        old_hkid VARCHAR(12) NULL,
        hkid VARCHAR(12) NULL,
        patient_name VARCHAR(48) NULL,
        sex VARCHAR(1) NULL,
        dob TIMESTAMP WITHOUT TIME ZONE NULL,
        hospital_code VARCHAR(3) NULL,
        update_by VARCHAR(8) NULL,
        system_dtm TIMESTAMP WITHOUT TIME ZONE NULL);
    /* --if has change history, put first row as org. image -- */
    SELECT
        old_patient_name, old_sex, old_dob
        INTO var_old_patient_name, var_old_sex, var_old_dob
        FROM (SELECT
            old_patient_name, old_sex, old_dob, old_hkid, system_dtm
            FROM patient_key_changed) AS ungrouped_query
        INNER JOIN (SELECT
            old_hkid, MIN(system_dtm) AS min_1
            FROM patient_key_changed
            WHERE old_hkid <> new_hkid AND old_hkid = par_from_hkid
            GROUP BY old_hkid) AS grouped_query
            ON (ungrouped_query.old_hkid = grouped_query.old_hkid OR (ungrouped_query.old_hkid IS NULL AND grouped_query.old_hkid IS NULL))
        WHERE system_dtm = min_1;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount = 1 THEN
        BEGIN
            INSERT INTO t$temp_change_hkid
            VALUES (var_id, NULL, par_from_hkid, var_old_patient_name, var_old_sex, var_old_dob, NULL, NULL, NULL);
        END;
    END IF;
    /* -use cursor to select all changed hkid tx related to input HKID- */
    OPEN change_csr;
    FETCH change_csr INTO var_system_dtm, var_update_by, var_hospital_code, var_old_hkid, var_old_patient_name, var_old_sex, var_old_dob, var_new_hkid, var_new_patient_name, var_new_sex, var_new_dob;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        <<next>>
        BEGIN
            IF var_id > 1 THEN
                BEGIN
                    IF EXISTS (SELECT
                        *
                        FROM t$temp_change_hkid
                        WHERE old_hkid = var_old_hkid AND hkid = var_new_hkid AND system_dtm = var_system_dtm) THEN
                        BEGIN
                            SELECT
                                var_id - 1
                                INTO var_id;
                            EXIT next;
                        END;
                    ELSE
                        BEGIN
                            INSERT INTO t$temp_change_hkid
                            VALUES (var_id, NULL, var_old_hkid, var_old_patient_name, var_old_sex, var_old_dob, var_hospital_code, var_update_by, var_system_dtm);
                        END;
                    END IF;
                END;
            END IF;
            INSERT INTO t$temp_change_hkid
            VALUES (var_id, var_old_hkid, var_new_hkid, var_new_patient_name, var_new_sex, var_new_dob, var_hospital_code, var_update_by, var_system_dtm);
            SELECT
                var_new_hkid, var_system_dtm
                INTO var_search_hkid, var_search_dtm;

            WHILE var_search_hkid IS NOT NULL LOOP
                /* begin while */
                SELECT
                    hospital_code, update_by, system_dtm, new_hkid, new_sex, new_dob, new_patient_name
                    INTO var_hospital_code, var_update_by, var_system_dtm, var_new_hkid, var_new_sex, var_new_dob, var_new_patient_name
                    FROM (SELECT
                        hospital_code, update_by, system_dtm, new_hkid, new_sex, new_dob, new_patient_name, old_hkid
                        FROM patient_key_changed) AS ungrouped_query
                    INNER JOIN (SELECT
                        old_hkid, MIN(system_dtm) AS min_1
                        FROM patient_key_changed
                        WHERE old_hkid <> new_hkid AND old_hkid = var_search_hkid AND system_dtm >= var_search_dtm
                        GROUP BY old_hkid) AS grouped_query
                        ON (ungrouped_query.old_hkid = grouped_query.old_hkid OR (ungrouped_query.old_hkid IS NULL AND grouped_query.old_hkid IS NULL))
                    WHERE system_dtm = min_1;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount = 1 THEN
                    BEGIN
                        INSERT INTO t$temp_change_hkid
                        VALUES (var_id, var_search_hkid, var_new_hkid, var_new_patient_name, var_new_sex, var_new_dob, var_hospital_code, var_update_by, var_system_dtm);
                        SELECT
                            var_new_hkid, var_system_dtm
                            INTO var_search_hkid, var_search_dtm;
                    END;
                ELSE
                    BEGIN
                        SELECT
                            NULL
                            INTO var_search_hkid;
                        /* --	insert #temp_change_hkid */
                        /* --	values(@id, null,null,null,null,null,null,null,null) */
                    END;
                END IF;
            END LOOP; /* end while */
        END;
        SELECT
            var_id + 1
            INTO var_id;
        FETCH change_csr INTO var_system_dtm, var_update_by, var_hospital_code, var_old_hkid, var_old_patient_name, var_old_sex, var_old_dob, var_new_hkid, var_new_patient_name, var_new_sex, var_new_dob;
    END LOOP; /* end outer while */
    CLOSE change_csr;

    /* -- display result -- */
    RETURN QUERY SELECT
        hkid as res_hkid, patient_name as res_patient_name, sex as res_sex, dob as res_dob, hospital_code as res_hospital_code, update_by as res_update_by, system_dtm as res_system_dtm, id as res_id
        FROM t$temp_change_hkid;
    /*
    
    DROP TABLE IF EXISTS t$temp_change_hkid;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;


ALTER FUNCTION "hkpmi_get_hkpmi_change_hkid" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
