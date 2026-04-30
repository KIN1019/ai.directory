-- DROP PROCEDURE hkpmi.hkpmi_sync_hago_user(inout int4, in bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_sync_hago_user(INOUT pas_return_code integer, IN par_debug_mode varchar DEFAULT 'N'::varchar)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_src_user_id varchar(22);
    /* not null,		-- Unique clustered index */
    var_src_ref_no varchar(19);
    /* not null,		-- Unique index */
    var_src_custom_username VARCHAR(60);
    /* not null, */
    var_src_status VARCHAR(30);
    /* not null, */
    var_src_doc_no VARCHAR(255);
    /* not null, */
    var_src_doc_type VARCHAR(30);
    /* not null, */
    var_src_first_name VARCHAR(100);
    /* not null, */
    var_src_last_name VARCHAR(100);
    /* not null, */
    var_src_email_address VARCHAR(255);
    /* null, */
    var_src_mobile_phone_no VARCHAR(30);
    /* ------------------------------------------------------ */
    /* not null, */
    var_src_preferred_language varchar(5);
    /* not null, */
    var_src_verify_user VARCHAR(30);
    /* null, */
    var_src_verify_hospital_code VARCHAR(30);
    /* null */
    var_src_verify_system VARCHAR(30);
    /* null */
    var_src_verify_datetime TIMESTAMP WITHOUT TIME ZONE;
    /* null */
    var_src_create_datetime TIMESTAMP WITHOUT TIME ZONE; /* --not null */
    var_src_last_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    /* not null */
    var_src_version bigint;
    var_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_result_str VARCHAR(255);
    var_record_count INTEGER;
    var_dest_version VARCHAR(20);
    raw_hago_csr CURSOR FOR
    SELECT
        user_id, ref_no, custom_username, status, doc_no, doc_type, first_name, last_name, email_address, mobile_phone_no, preferred_language, verify_user, verify_hospital_code, verify_system, verify_datetime, create_datetime, last_update_datetime, version
        FROM hago_user_raw
        /* Source Table */
        ORDER BY user_id NULLS FIRST
    /* Unique clustered Indx */
    ;
    sql$rowcount BIGINT;
BEGIN
    /* ------------------------------------------------------------------------------------------------------------------------------------ */
    /* Source Tables: */
    /* 1.hago_user_raw - source by [cdcpas02#sync_hago_tbl]-job: BCP from HAGO_CORP_SP1_AN.hago_user_view] */
    /* Target tables */
    /* 2.hago_user     - HA_HKPMI_SP1_AN.hkpmi.hago_user */
    
    /* ------------------------------------------------------------------------------------------------------------------------------------ */
    /* last update : 20200415 -- */
    
    /* ------------------------------------------------------------------------------------------------------------------------------------ */
    /* not null */
    
    /* ------------------------------------------------------------------- */
    
    /* ------------------------------------------------------------------- */
    
    /* ------------------------------------------------------------------- */
    SELECT
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        INTO var_src_user_id, var_src_ref_no, var_src_custom_username, var_src_status, var_src_doc_no, var_src_doc_type, var_src_first_name, var_src_last_name, var_src_email_address, var_src_mobile_phone_no;
    SELECT
        NULL, NULL, NULL, NULL, NULL
        INTO var_src_preferred_language, var_src_verify_user, var_src_verify_hospital_code, var_src_verify_system, var_src_verify_datetime;
    SELECT
        NULL, NULL, NULL
        INTO var_src_create_datetime, var_src_last_update_datetime, var_src_version;
    SELECT
        NULL, 0, NULL
        INTO var_result_str, var_record_count, var_dest_version;
    /* ------------------------------------------------------------------- */
    OPEN raw_hago_csr;
    FETCH raw_hago_csr INTO var_src_user_id, var_src_ref_no, var_src_custom_username, var_src_status, var_src_doc_no, var_src_doc_type, var_src_first_name, var_src_last_name, var_src_email_address, var_src_mobile_phone_no, var_src_preferred_language, var_src_verify_user, var_src_verify_hospital_code, var_src_verify_system, var_src_verify_datetime, var_src_create_datetime, var_src_last_update_datetime, var_src_version;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            var_record_count + 1
            INTO var_record_count;
        SELECT
            localtimestamp
            INTO var_sys_dtm;
        /* ------------------------------------------------------------------- */
        /* 1. New Records : Unique Key [user_id] -- */
        
        /* ------------------------------------------------------------------- */
        IF NOT EXISTS (SELECT
            *
            FROM hago_user
            WHERE user_id = var_src_user_id::INTEGER) THEN
            BEGIN
                INSERT INTO hago_user (user_id, ref_no, custom_username, status, doc_no, doc_type, first_name, last_name, email_address, mobile_phone_no, preferred_language, verify_user, verify_hospital_code, verify_system, verify_datetime, create_datetime, last_update_datetime, version, sys_dtm)
                VALUES (var_src_user_id, var_src_ref_no, var_src_custom_username, var_src_status, var_src_doc_no, var_src_doc_type, var_src_first_name, var_src_last_name, var_src_email_address, var_src_mobile_phone_no, var_src_preferred_language, var_src_verify_user, var_src_verify_hospital_code, var_src_verify_system, var_src_verify_datetime, var_src_create_datetime, var_src_last_update_datetime, var_src_version, var_sys_dtm);
                SELECT
                    CONCAT('[', CAST (var_record_count AS CHAR(3)), ']', var_src_user_id, var_src_ref_no, var_src_custom_username, ']Created ->[', var_src_doc_type, '->', var_src_doc_no, ']last_update_datetime[', to_char(var_src_last_update_datetime,'YYYYMMDD HH24:mi'), ']')
                    INTO var_result_str;
            END;
        ELSE
            /* ------------------------------------------------------------------- */
            /* 2. Check/Update with existing Records -- */
            
            /* ------------------------------------------------------------------- */
            BEGIN
                UPDATE hago_user
                SET ref_no = var_src_ref_no, custom_username = var_src_custom_username, status = var_src_status, doc_no = var_src_doc_no, doc_type = var_src_doc_type, first_name = var_src_first_name, last_name = var_src_last_name, email_address = var_src_email_address, mobile_phone_no = var_src_mobile_phone_no,
                /* ----------------------------------------------------- */
                preferred_language = var_src_preferred_language, verify_user = var_src_verify_user, verify_hospital_code = var_src_verify_hospital_code, verify_system = var_src_verify_system, verify_datetime = var_src_verify_datetime, create_datetime = var_src_create_datetime, last_update_datetime = var_src_last_update_datetime, version = var_src_version,
                /* ----------------------------------------------------- */
                sys_dtm = var_sys_dtm
                    WHERE user_id = COALESCE(var_src_user_id, 'NULL') AND
                    /* Uniqe Cluster Index */
                    
                    /* ----------------------------------------------------------- */
                    (COALESCE(ref_no, 'NULL') != COALESCE(var_src_ref_no, 'NULL') OR COALESCE(custom_username, 'NULL') != COALESCE(var_src_custom_username, 'NULL') OR COALESCE(status, 'NULL') != COALESCE(var_src_status, 'NULL') OR COALESCE(doc_no, 'NULL') != COALESCE(var_src_doc_no, 'NULL') OR COALESCE(doc_type, 'NULL') != COALESCE(var_src_doc_type, 'NULL') OR COALESCE(first_name, 'NULL') != COALESCE(var_src_first_name, 'NULL') OR COALESCE(last_name, 'NULL') != COALESCE(var_src_last_name, 'NULL') OR COALESCE(email_address, 'NULL') != COALESCE(var_src_email_address, 'NULL') OR COALESCE(mobile_phone_no, 'NULL') != COALESCE(var_src_mobile_phone_no, 'NULL') OR
                    /* --------------------------------------------------------------------------------- */
                    COALESCE(preferred_language, 'NULL') != COALESCE(var_src_preferred_language, 'NULL') OR COALESCE(verify_user, 'NULL') != COALESCE(var_src_verify_user, 'NULL') OR COALESCE(verify_hospital_code, 'NULL') != COALESCE(var_src_verify_hospital_code, 'NULL') OR COALESCE(verify_system, 'NULL') != COALESCE(var_src_verify_system, 'NULL') OR COALESCE(verify_datetime, '19000101') != COALESCE(var_src_verify_datetime, '19000101') OR COALESCE(create_datetime, '19000101') != COALESCE(var_src_create_datetime, '19000101') OR COALESCE(last_update_datetime, '19000101') != COALESCE(var_src_last_update_datetime, '19000101') OR COALESCE(version, 0) != COALESCE(var_src_version, 0))
                    /* ------------------------------------------------------- */
                ;
                /* ------------------------------- */
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount > 0 THEN
                    SELECT
                        CONCAT('[', CAST (var_record_count AS CHAR(3)), ']', var_src_user_id, var_src_ref_no, var_src_custom_username, ']Updated ->[', var_src_doc_type, '->', var_src_doc_no, ']last_update_datetime[', to_char(var_src_last_update_datetime,'YYYYMMDD HH24:mi'), ']')
                        INTO var_result_str;
                ELSE
                    SELECT
                        CONCAT('[', CAST (var_record_count AS CHAR(3)), ']', var_src_user_id, var_src_ref_no, var_src_custom_username, ']NoChanged ->[', var_src_doc_type, '->', var_src_doc_no, ']last_update_datetime[', to_char(var_src_last_update_datetime,'YYYYMMDD HH24:mi'), ']')
                        INTO var_result_str;
                END IF;
            END;
        END IF;
        /* ------------------------------------------------------------------- */
        IF par_debug_mode = 'Y' THEN
            RAISE NOTICE '%', var_result_str;
        END IF;
        /* ------------------------------------------------------------------- */
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_src_user_id, var_src_ref_no, var_src_custom_username, var_src_status, var_src_doc_no, var_src_doc_type, var_src_first_name, var_src_last_name, var_src_email_address, var_src_mobile_phone_no;
        SELECT
            NULL, NULL, NULL, NULL, NULL
            INTO var_src_preferred_language, var_src_verify_user, var_src_verify_hospital_code, var_src_verify_system, var_src_verify_datetime;
        SELECT
            NULL, NULL, NULL
            INTO var_src_create_datetime, var_src_last_update_datetime, var_src_version;
        SELECT
            NULL, 0, NULL
            INTO var_result_str, var_record_count, var_dest_version;
        /* ------------------------------------------------------------------- */
        FETCH raw_hago_csr INTO var_src_user_id, var_src_ref_no, var_src_custom_username, var_src_status, var_src_doc_no, var_src_doc_type, var_src_first_name, var_src_last_name, var_src_email_address, var_src_mobile_phone_no, var_src_preferred_language, var_src_verify_user, var_src_verify_hospital_code, var_src_verify_system, var_src_verify_datetime, var_src_create_datetime, var_src_last_update_datetime, var_src_version;
    END LOOP;
    CLOSE raw_hago_csr;
    /* ------------------------------------------------------------------- */
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_sync_hago_user" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
