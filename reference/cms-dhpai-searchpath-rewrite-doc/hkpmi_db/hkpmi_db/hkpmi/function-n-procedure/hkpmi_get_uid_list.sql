-- DROP FUNCTION hkpmi_get_uid_list(bpchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hkpmi_get_uid_list(par_hospital_code varchar, par_from_date timestamp without time zone DEFAULT NULL::timestamp without time zone, par_to_date timestamp without time zone DEFAULT NULL::timestamp without time zone)
 RETURNS TABLE(rec_type varchar, hkid varchar, uid varchar, patient_name varchar, link_status varchar, create_dtm timestamp without time zone, create_hosp varchar, create_user varchar, update_dtm timestamp without time zone, update_hosp varchar, update_user varchar)
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_name VARCHAR(48);
    var_uid  VARCHAR(12);
    var_hkid VARCHAR(12);
BEGIN
	SET SEARCH_PATH TO HKPMI;
    IF par_from_date IS NULL THEN
        par_from_date := CURRENT_DATE - INTERVAL '1 day';
    END IF;
    IF par_to_date IS NULL THEN
        par_to_date := par_to_date + INTERVAL '1 day';
    ELSE
        par_to_date := par_to_date + INTERVAL '1 day';
    END IF;

    DROP TABLE IF EXISTS t$temp_uid_table;
    CREATE TEMPORARY TABLE t$temp_uid_table
    (
        rec_type     VARCHAR(160),
        hkid         VARCHAR(24),
        uid          VARCHAR(24),
        patient_name VARCHAR(96),
        link_status  VARCHAR(4),
        create_dtm   TIMESTAMP,
        create_hosp  VARCHAR(6),
        create_user  VARCHAR(24),
        update_dtm   TIMESTAMP,
        update_hosp  VARCHAR(6),
        update_user  VARCHAR(24)
    );
    CREATE UNIQUE INDEX temp_index ON t$temp_uid_table
        (rec_type, hkid, uid, update_dtm, update_hosp);

    INSERT INTO t$temp_uid_table
    (uid, hkid, link_status, create_dtm, create_hosp, create_user, update_dtm, update_hosp, update_user, rec_type)
    SELECT hut.uid_hkid,
           hut.link_hkid,
           hut.link_status,
           hut.create_dtm,
           hut.create_hospital,
           hut.create_user,
           hut.update_dtm,
           hut.update_hospital,
           hut.update_user,
           'SECTION 1: UID LINK'
    FROM hkpmi_uid_table hut
    WHERE hut.create_dtm >= par_from_date
      AND hut.create_dtm < par_to_date
      AND hut.create_hospital = par_hospital_code;
    
    RAISE NOTICE 'insert into done -001';

    INSERT INTO t$temp_uid_table
    (uid, hkid, link_status, create_dtm, create_hosp, create_user, update_dtm, update_hosp, update_user, rec_type)
    SELECT hut.uid_hkid,
           hut.link_hkid,
           hut.link_status,
           hut.create_dtm,
           hut.create_hospital,
           hut.create_user,
           hut.update_dtm,
           hut.update_hospital,
           hut.update_user,
           'UPDATE'
    FROM hkpmi_uid_table hut
    WHERE hut.update_dtm >= par_from_date
      AND hut.update_dtm < par_to_date
      AND (hut.update_hospital = par_hospital_code OR hut.create_hospital = par_hospital_code)
      AND (hut.create_dtm <> hut.update_dtm OR hut.create_hospital <> hut.update_hospital OR hut.create_user <> hut.update_user)
      AND NOT (hut.create_dtm >= par_from_date AND hut.create_dtm < par_to_date AND hut.create_hospital = par_hospital_code AND
               hut.link_status = 'L');
              
    RAISE NOTICE 'insert into done -002';

    FOR var_name, var_uid, var_hkid IN
        SELECT tut.patient_name, tut.uid, tut.hkid FROM t$temp_uid_table tut
        LOOP
            SELECT INTO var_name p.patient_name FROM patient p WHERE p.hkid = var_hkid;
            IF NOT FOUND THEN
                SELECT INTO var_name p.patient_name FROM patient p WHERE p.hkid = var_uid;
                IF NOT FOUND THEN
                    var_name := NULL;
                END IF;
            END IF;

            UPDATE t$temp_uid_table as tut
            SET patient_name = var_name
            WHERE tut.uid = var_uid
              AND tut.hkid = var_hkid;
        END LOOP;

    UPDATE t$temp_uid_table as tut
    SET rec_type = CASE
        WHEN tut.rec_type = 'UPDATE' AND tut.link_status IN ('CD', 'CS') THEN 'SECTION 3: SAME OR DIFFERENT PATIENT'
        WHEN tut.rec_type = 'UPDATE' AND tut.link_status = 'PS' THEN 'SECTION 2: PENDING MERGE'
        WHEN tut.rec_type = 'UPDATE' AND tut.link_status = 'L' THEN 'SECTION 1: UID LINK'
        WHEN tut.rec_type = 'UPDATE' AND tut.link_status = 'DE' THEN 'SECTION 4: PATIENT DELETED'
        WHEN tut.rec_type = 'UPDATE' AND tut.link_status = 'RD' THEN 'SECTION 5: DEAD PATIENT'
        ELSE tut.rec_type
        END;

    CLUSTER t$temp_uid_table USING temp_index;
    RETURN QUERY
        SELECT tut.rec_type,
               tut.hkid,
               tut.uid,
               tut.patient_name,
               tut.link_status,
               tut.create_dtm,
               tut.create_hosp,
               tut.create_user,
               tut.update_dtm,
               tut.update_hosp,
               tut.update_user
        FROM t$temp_uid_table tut
       	ORDER BY tut.rec_type COLLATE "C",tut.hkid COLLATE "C",tut.uid COLLATE "C";
END;
$function$
;

ALTER FUNCTION "hkpmi_get_uid_list" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
