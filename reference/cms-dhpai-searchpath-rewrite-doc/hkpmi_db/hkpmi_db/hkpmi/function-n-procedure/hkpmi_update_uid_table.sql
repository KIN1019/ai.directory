-- DROP PROCEDURE hkpmi.hkpmi_update_uid_table(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, inout varchar, inout int4, inout varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_update_uid_table(INOUT pas_return_code integer, IN par_action character varying, IN par_hosp_code character varying, IN par_uid_hkid character varying, IN par_link_hkid character varying, IN par_link_status character varying DEFAULT NULL::character varying, IN par_create_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_create_hospital character varying DEFAULT NULL::character varying, IN par_create_user character varying DEFAULT NULL::character varying, IN par_create_system character varying DEFAULT NULL::character varying, IN par_update_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_update_hospital character varying DEFAULT NULL::character varying, IN par_update_user character varying DEFAULT NULL::character varying, IN par_update_system character varying DEFAULT NULL::character varying, INOUT par_return_hkid character varying DEFAULT NULL::character varying, INOUT par_return_code integer DEFAULT NULL::integer, INOUT par_return_msg character varying DEFAULT NULL::character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* --- Not adm_dtm, but tran_dtm */ 
/* --fo EU only */
/* for EU/EL ,10=uid found,11=link_id found */
DECLARE
    var_retcode INTEGER;
    var_error_msg VARCHAR(255);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_raiserror_msg varchar(255);
    var_u_hkid varchar(12);
    var_l_hkid varchar(12);
    var_u_pkey varchar(8);
    var_l_pkey varchar(8);
    var_hosp varchar(3);
    var_ret_hkid varchar(12);
    var_uid_exist varchar(1);
    var_link_exist varchar(1);
    var_u_link_status varchar(2);
    var_org_link_status varchar(2);
    sql$rowcount BIGINT;
    found_code INTEGER;
    uid_csr CURSOR FOR
    SELECT
        uid_hkid, link_status
        FROM hkpmi_uid_table
        WHERE link_hkid = par_link_hkid;
begin
	SET search_path TO hkpmi, public;
    <<error>>
    BEGIN
        /* ----init -- */
        SELECT
            0, 0, NULL
            INTO pas_return_code, var_error, var_error_msg;
        SELECT
            NULL, NULL, NULL, NULL, NULL
            INTO var_u_pkey, var_l_pkey, var_hosp, var_uid_exist, var_link_exist;

        IF LTRIM(RTRIM(par_hosp_code)) = '' OR LTRIM(RTRIM(par_hosp_code)) is NULL THEN
            SELECT
                NULL
                INTO par_hosp_code;
        END IF;

        IF LTRIM(RTRIM(par_uid_hkid)) = '' OR LTRIM(RTRIM(par_uid_hkid)) is NULL THEN
            SELECT
                NULL
                INTO par_uid_hkid;
        END IF;

        IF LTRIM(RTRIM(par_link_hkid)) = '' OR LTRIM(RTRIM(par_link_hkid)) is NULL THEN
            SELECT
                NULL
                INTO par_link_hkid;
        END IF;

        IF LTRIM(RTRIM(par_link_status)) = '' OR LTRIM(RTRIM(par_link_status)) is NULL THEN
            SELECT
                NULL
                INTO par_link_status;
        END IF;

        -- IF LTRIM(RTRIM(par_create_dtm)) = '' OR LTRIM(RTRIM(par_create_dtm)) = NULL THEN
		IF par_create_dtm is NULL THEN
            SELECT
                NULL
                INTO par_create_dtm;
        END IF;

        IF LTRIM(RTRIM(par_create_hospital)) = '' OR LTRIM(RTRIM(par_create_hospital)) is NULL THEN
            SELECT
                NULL
                INTO par_create_hospital;
        END IF;

        IF LTRIM(RTRIM(par_create_user)) = '' OR LTRIM(RTRIM(par_create_user)) is NULL THEN
            SELECT
                NULL
                INTO par_create_user;
        END IF;

        IF LTRIM(RTRIM(par_create_system)) = '' OR LTRIM(RTRIM(par_create_system)) is NULL THEN
            SELECT
                NULL
                INTO par_create_system;
        END IF;

        --IF LTRIM(RTRIM(par_update_dtm)) = '' OR LTRIM(RTRIM(par_update_dtm)) = NULL THEN
		IF par_update_dtm is NULL THEN
            SELECT
                NULL
                INTO par_update_dtm;
        END IF;

        IF LTRIM(RTRIM(par_update_hospital)) = '' OR LTRIM(RTRIM(par_update_hospital)) is NULL THEN
            SELECT
                NULL
                INTO par_update_hospital;
        END IF;

        IF LTRIM(RTRIM(par_update_user)) = '' OR LTRIM(RTRIM(par_update_user)) is NULL THEN
            SELECT
                NULL
                INTO par_update_user;
        END IF;

        IF LTRIM(RTRIM(par_update_system)) = '' OR LTRIM(RTRIM(par_update_system)) is NULL THEN
            SELECT
                NULL
                INTO par_update_system;
        END IF;
        /*
        [3017 - Severity CRITICAL - PostgreSQL doesn't support the SET NOCOUNT. If need try another way to send message back to the client application.]
        set nocount on
        */
        /* -------------------------------------------------------- */
        /* Reject transaction -- */
        IF par_action NOT IN ('AL', 'U', 'CU', 'CL', 'EU', 'EL') THEN
            BEGIN
                SELECT
                    - 1
                    INTO pas_return_code;
                SELECT
                    'Invalid Action Type !'
                    INTO par_return_msg;
                EXIT error;
            END;
        END IF;

        IF par_hosp_code is NULL OR (par_uid_hkid is NULL AND par_link_hkid is NULL) THEN
            BEGIN
                SELECT
                    - 2
                    INTO pas_return_code;
                SELECT
                    'Hosp / Uid / Link HKID NULL !'
                    INTO par_return_msg;
                EXIT error;
            END;
        END IF;
        /* ------ NOTE: @u_pkey will NULL if @uid merged to @Link_hkid : ie link_status ='CS' ----- */
        SELECT
            patient_key
            INTO var_u_pkey
            FROM patient
            WHERE hkid = par_uid_hkid;
        SELECT
            patient_key
            INTO var_l_pkey
            FROM patient
            WHERE hkid = par_link_hkid;

        IF EXISTS (SELECT
            1
            FROM hkpmi_uid_table
            WHERE uid_hkid = par_uid_hkid) THEN
            SELECT
                'Y'
                INTO var_uid_exist;
        ELSE
            SELECT
                'N'
                INTO var_uid_exist;
        END IF;

        IF EXISTS (SELECT
            1
            FROM hkpmi_uid_table
            WHERE link_hkid = par_link_hkid) THEN
            SELECT
                'Y'
                INTO var_link_exist;
        ELSE
            SELECT
                'N'
                INTO var_link_exist;
        END IF;
        /* --- check ation allow or NOT--- */

        IF par_action = 'AL' AND var_uid_exist = 'N' AND (par_link_status <> 'L' OR var_u_pkey IS NULL OR var_l_pkey IS NULL) THEN
            BEGIN
                SELECT
                    - 3
                    INTO pas_return_code;
                SELECT
                    'UID linkage exists or Patient NOT found !'
                    INTO par_return_msg;
                EXIT error;
            END;
        END IF;
        /* ---- */
        IF (par_action IN ('CU') AND (var_uid_exist = 'N' /* or @u_pkey is null) */)) OR (par_action IN ('CL') AND (var_link_exist = 'N' /* or @l_pkey is null) */)) THEN
            BEGIN
                SELECT
                    - 4
                    INTO pas_return_code;
                SELECT
                    'UID linkage NOT exists or Patient NOT found !'
                    INTO par_return_msg;
                EXIT error;
            END;
        END IF;

        IF par_action = 'U' AND (var_uid_exist = 'N' OR (par_link_status NOT IN ('CS', 'PS', 'CD', 'L'))) THEN
            BEGIN
                SELECT
                    - 5
                    INTO pas_return_code;
                SELECT
                    'UID linkage NOT exists or Linkstatus Error!'
                    INTO par_return_msg;
                EXIT error;
            END;
        END IF;
        /* ------ Transactions handble by gsql_adt_01.commit/rollback */

        IF par_action = 'AL' THEN
            BEGIN
                IF var_uid_exist = 'N' THEN
                    BEGIN
                        BEGIN
                            INSERT INTO hkpmi_uid_table (uid_hkid, link_hkid, link_status, create_dtm, create_hospital, create_user, create_system, update_dtm, update_hospital, update_user, update_system)
                            VALUES (par_uid_hkid, par_link_hkid, par_link_status, timestamp_convert(par_create_dtm), par_create_hospital, par_create_user, par_create_system, timestamp_convert(par_update_dtm), par_update_hospital, par_update_user, par_update_system);
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF (var_error != 0) OR (var_rowcount = 0) THEN
                            BEGIN
                                SELECT
                                    - 11
                                    INTO pas_return_code;
                                /* ---- insert error */
                                SELECT
                                    'Insert hkpmi_uid_table error  !'
                                    INTO par_return_msg;
                                EXIT error;
                            END;
                        END IF;
                    END;
                END IF;
                RETURN;
            END;
        END IF;

        IF par_action IN ('EU', 'EL') THEN
            BEGIN
                IF par_action = 'EU' THEN
                    BEGIN
                        SELECT
                            link_hkid
                            INTO var_ret_hkid
                            FROM hkpmi_uid_table
                            WHERE uid_hkid = par_uid_hkid AND link_status NOT IN ('CS', 'CD'); /* ---- */

                        IF var_ret_hkid IS NOT NULL THEN
                            BEGIN
                                SELECT
                                    var_ret_hkid
                                    INTO par_return_hkid;
                                SELECT
                                    'UID found!'
                                    INTO par_return_msg;
                                SELECT
                                    10
                                    INTO par_return_code;
                                RETURN;
                            END;
                        ELSE
                            BEGIN
                                SELECT
                                    NULL
                                    INTO par_return_hkid;
                                SELECT
                                    'UID NOT found!'
                                    INTO par_return_msg;
                                SELECT
                                    - 10
                                    INTO par_return_code;
                                RETURN;
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        SELECT
                            link_hkid
                            INTO var_ret_hkid
                            FROM hkpmi_uid_table
                            WHERE link_hkid = par_link_hkid AND
                            /* ---- multi-records */
                            link_status NOT IN ('CS', 'CD');

                        IF var_ret_hkid IS NOT NULL THEN
                            BEGIN
                                SELECT
                                    var_ret_hkid
                                    INTO par_return_hkid;
                                SELECT
                                    'LINK HKID found!'
                                    INTO par_return_msg;
                                SELECT
                                    11
                                    INTO par_return_code;
                                RETURN;
                            END;
                        ELSE
                            BEGIN
                                SELECT
                                    NULL
                                    INTO par_return_hkid;
                                SELECT
                                    'LINK HKID NOT found!'
                                    INTO par_return_msg;
                                SELECT
                                    - 11
                                    INTO par_return_code;
                                RETURN;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;

        IF par_action IN ('CU', 'CL') THEN
            BEGIN
                /* ---Construct temp table for the output --- */
	            DROP TABLE IF EXISTS t$uid_list;
                CREATE TEMPORARY TABLE t$uid_list
                (hkid CHAR(12),
                    patient_name CHAR(48) NULL,
                    sex CHAR(1) NULL,
                    dob TIMESTAMP WITHOUT TIME ZONE NULL,
                    other_doc_no CHAR(12) NULL,
                    link_status CHAR(20) NULL,
                    create_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
                    create_hospital CHAR(3) NULL,
                    create_user CHAR(12) NULL,
                    /* --create_system char(5) null, */
                    update_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
                    update_hospital CHAR(3) NULL,
                    update_user CHAR(12) NULL
                /* ---update_system char(5) null */);
                /* --create unique index #uid_list_idx */
                /* --	on #uid_list (hkid) */
                IF par_action = 'CU' THEN
                    /* ---------------CU: return the link_hkid  info.----------- */
                    BEGIN
                        SELECT
                            link_hkid
                            INTO var_l_hkid
                            FROM hkpmi_uid_table
                            WHERE uid_hkid = par_uid_hkid;
                        INSERT INTO t$uid_list
                        SELECT
                            var_l_hkid, p.patient_name, p.sex, p.dob, p.other_doc_no, u.link_status, timestamp_convert(u.create_dtm), u.create_hospital, u.create_user, timestamp_convert(u.update_dtm), u.update_hospital, u.update_user
                            FROM patient AS p
                            JOIN hkpmi_uid_table AS u
                                ON p.hkid = var_l_hkid AND u.uid_hkid = par_uid_hkid;
                    END;
                ELSE
                    /* ----------CL: rturn all uid_hkids info.------------- */
                    BEGIN
                        SELECT
                            NULL, NULL
                            INTO var_u_hkid, var_u_link_status;
                        OPEN uid_csr;
                        FETCH uid_csr INTO var_u_hkid, var_u_link_status;
                        select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
						
                        WHILE found_code = 0 LOOP
                            /* --- Loop for UIDs */
                            
                            /* ---A).  for Merged Un-HKID ...CS..UID NOT exists in patient table */
                            IF var_u_link_status = 'CS' OR (NOT EXISTS (SELECT
                                1
                                FROM patient
                                WHERE hkid = var_u_hkid)) THEN
                                BEGIN
                                    INSERT INTO t$uid_list
                                    SELECT
                                        u.uid_hkid, p.patient_name, p.sex, p.dob, /* p.other_doc_no, */ par_link_hkid, u.link_status, timestamp_convert(u.create_dtm), u.create_hospital, u.create_user, timestamp_convert(u.update_dtm), u.update_hospital, u.update_user
                                        FROM patient AS p
                                        JOIN hkpmi_uid_table AS u
                                            ON p.hkid = par_link_hkid AND /* --UID already deleted after Merge ==> show Link HKID pdemo --- */ u.uid_hkid = var_u_hkid;
                                END;
                            ELSE
                                /* ----B). UID exists in patient table . */
                                BEGIN
                                    INSERT INTO t$uid_list
                                    SELECT
                                        p.hkid, p.patient_name, p.sex, p.dob, p.other_doc_no, u.link_status, timestamp_convert(u.create_dtm), u.create_hospital, u.create_user, timestamp_convert(u.update_dtm), u.update_hospital, u.update_user
                                        FROM patient AS p
                                        JOIN hkpmi_uid_table AS u
                                            ON p.hkid = u.uid_hkid AND p.hkid = var_u_hkid;
                                END;
                            END IF;
                            SELECT
                                NULL, NULL
                                INTO var_u_hkid, var_u_link_status;
                            FETCH uid_csr INTO var_u_hkid, var_u_link_status;
                            select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
                        END LOOP;
                        CLOSE uid_csr;
                    END;
                END IF; /* Adaptive Server has expanded all '*' elements in the following statement */
                /* ---For display full desc in PBL.DW.itemlist without 'CS' item.---- */
                /* --update #uid_list set link_status ='Patient Merged' where link_status='CS' */
                OPEN p_refcur FOR
                SELECT
                    t$uid_list.hkid, t$uid_list.patient_name, t$uid_list.sex, t$uid_list.dob, t$uid_list.other_doc_no, t$uid_list.link_status, timestamp_convert(t$uid_list.create_dtm), t$uid_list.create_hospital, t$uid_list.create_user, timestamp_convert(t$uid_list.update_dtm), t$uid_list.update_hospital, t$uid_list.update_user
                    FROM t$uid_list
                    ORDER BY create_dtm NULLS FIRST;
                RETURN;
            END;
        END IF;

        IF par_action = 'U' THEN
            BEGIN
                SELECT
                    link_status
                    INTO var_org_link_status
                    FROM hkpmi_uid_table
                    WHERE uid_hkid = par_uid_hkid;
                /* 201506 Yorky - Prevent the status: DE (patient deleted) to be updated to another status */
                IF var_org_link_status <> par_link_status  then --AND var_org_link_status NOT IN ('DE')
                    BEGIN
                        BEGIN
                            UPDATE hkpmi_uid_table
                            SET link_status = par_link_status, update_dtm = par_update_dtm, update_hospital = par_update_hospital, update_user = par_update_user, update_system = par_update_system
                                WHERE uid_hkid = par_uid_hkid;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF (var_error != 0) OR (var_rowcount = 0) THEN
                            BEGIN
                                SELECT
                                    - 14
                                    INTO pas_return_code;
                                /* ---- update error */
                                SELECT
                                    'update hkpmi_uid_table Failed !'
                                    INTO par_return_msg;
                                EXIT error;
                            END;
                        END IF;
                    END;
                END IF;
                RETURN;
            END;
        END IF;
        /* end of @action = 'U' */
    END;
    /* --select @return_code = @retcode */
    IF par_action = 'U' THEN
        BEGIN
            SELECT
                210003
                INTO pas_return_code
            /* for cpi_upload.check_status WHICH will skip tran if @retcode <0, */
            ;
        END;
    END IF;
    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$uid_list;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_update_uid_table" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
