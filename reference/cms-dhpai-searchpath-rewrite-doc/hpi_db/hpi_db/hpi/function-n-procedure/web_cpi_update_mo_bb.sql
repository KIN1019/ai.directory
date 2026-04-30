-- DROP PROCEDURE web_cpi_update_mo_bb(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in int4, in varchar, in varchar, in varchar, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE web_cpi_update_mo_bb(INOUT pas_return_code integer, IN par_action character varying, IN par_mo_hosp character varying, IN par_mo_case character varying, IN par_nb_hosp character varying, IN par_nb_case character varying, IN par_mo_case_org character varying, IN par_nb_case_org character varying, IN par_birth_order integer, IN par_preg_number integer, IN par_birth_loc character varying, IN par_birth_place character varying, IN par_user_id character varying, IN par_system_dtm timestamp without time zone, IN par_baby_hkid character varying DEFAULT NULL::bpchar)
 LANGUAGE plpgsql
AS $procedure$
/* for update mo/nb case no .. */
/* --- for 'A' & checked with @nb_case's HKID  to ensure same patient.. */
DECLARE
    var_input_parm CHAR(100);
    var_retcode INTEGER;
    var_error_msg VARCHAR(255);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_mo_prk CHAR(8);
    var_nb_prk CHAR(8);
    var_nb_prk_org CHAR(8);
    var_nb_hkid CHAR(12);
    var_mo_hkid CHAR(12);
    var_baby_prk CHAR(8);
    var_nb_exist CHAR(1);
    var_upd_new_case CHAR(1);
    var_update_birth_order CHAR(1);
    var_birth_order_org INTEGER;
    var_create_by CHAR(12);
    var_create_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_raiserror_msg CHAR(255);
    var_cnt INTEGER;
    var_exit_flag CHAR(01);
    var_success_flag CHAR(01);
    var_txn_type CHAR(03);
    var_cpi_filler CHAR(30);
    /* --nb_hosp -cpi_filler(14,3) */
    /* --nb_case - cpi_filler(17,12) */ /* --mo_hosp - cpi_filler(11,3) */
    var_case_access_code INTEGER;
    /* pregnancy_number */
    var_pmi_access_code INTEGER;
    /* birth_order */
    var_source_ind CHAR(1);
    /* birth_place, */
    var_source_code CHAR(3);
    /* birth_location */
    var_hospital_code CHAR(3);
    var_transaction_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_remark CHAR(24);
    sql$rowcount BIGINT;
BEGIN
    <<error>>
    BEGIN /* --mb_case_org	-remakr(1,12) */
        /* --no_case_org	-remark(13,24) */
        /* ----init -- */
        var_retcode := 0;
        var_error := 0;
        var_error_msg := NULL;

        IF LTRIM(RTRIM(par_mo_hosp)) = '' THEN
            par_mo_hosp := NULL;
        END IF;

        IF LTRIM(RTRIM(par_mo_case)) = '' THEN
            par_mo_case := NULL;
        END IF;

        IF LTRIM(RTRIM(par_nb_hosp)) = '' THEN
            par_nb_hosp := NULL;
        END IF;

        IF LTRIM(RTRIM(par_nb_case)) = '' THEN
            par_nb_case := NULL;
        END IF;

        IF LTRIM(RTRIM(par_birth_place)) = '' THEN
            par_birth_place := NULL;
        END IF;

        IF LTRIM(RTRIM(par_birth_loc)) = '' THEN
            par_birth_loc := NULL;
        END IF;

        IF LTRIM(RTRIM(par_action)) = '' THEN
            par_action := NULL;
        END IF;

        IF LTRIM(RTRIM(par_mo_case_org)) = '' THEN
            par_mo_case_org := NULL;
        END IF;

        IF LTRIM(RTRIM(par_nb_case_org)) = '' THEN
            par_nb_case_org := NULL;
        END IF;

        IF LTRIM(RTRIM(par_baby_hkid)) = '' THEN
            par_baby_hkid := NULL;
        END IF;
        /*
        [3017 - Severity CRITICAL - PostgreSQL doesn't support the SET NOCOUNT. If need try another way to send message back to the client application.]
        set nocount on
        */
        /* -------------------------------------------------------- */
        IF par_mo_case_org = NULL THEN
            par_mo_case_org := par_mo_case;
        END IF;

        IF par_nb_case_org = NULL THEN
            par_nb_case_org := par_nb_case;
        END IF;
        /* Reject transaction -- */

        IF par_mo_hosp = NULL OR par_mo_case = NULL OR par_nb_hosp = NULL OR par_nb_case = NULL THEN
            BEGIN
                /* --set @retcode = -1 */
                var_retcode := 300001;
                /* ---select @raiserror_msg ="Case no Can not  be null !" */
                EXIT error;
            END;
        END IF;

        IF par_action <> 'A' AND par_action <> 'U' AND par_action <> 'D' THEN /* ---or @action <> 'P' */
            BEGIN
                /* --set @retcode = -2 */
                var_retcode := 300002;
                /* --select @raiserror_msg ="Invalid Action Type !" */
                EXIT error;
            END;
        END IF;
        /* --- Upd to new mo/nb case or NOT ---- */
        var_upd_new_case := 'N';

        IF par_action = 'U' AND (par_mo_case <> par_mo_case_org OR par_nb_case <> par_nb_case_org) THEN
            var_upd_new_case := 'Y';
        END IF;
        SELECT
            patient_key
            INTO var_mo_prk
            FROM cpi_case
            WHERE hospital_code = par_mo_hosp AND case_no = par_mo_case;
        raise notice '|%|%|',par_nb_hosp,par_nb_case;
        SELECT
            patient_key
            INTO var_nb_prk
            FROM cpi_case
            WHERE hospital_code = par_nb_hosp AND case_no = par_nb_case;

        IF (var_mo_prk = NULL OR var_nb_prk = NULL OR LTRIM(RTRIM(var_mo_prk)) = '' OR LTRIM(RTRIM(var_nb_prk)) = '') THEN
            BEGIN
                /* --set @retcode = -3 */
                var_retcode := 300003;
                /* ---select @raiserror_msg ="No Patient Found!" */
                EXIT error;
            END;
        END IF;
        SELECT
            hkid
            INTO var_mo_hkid
            FROM cpi_patient
            WHERE patient_key = var_mo_prk;
        SELECT
            hkid
            INTO var_nb_hkid
            FROM cpi_patient
            WHERE patient_key = var_nb_prk;

        IF par_baby_hkid = NULL OR par_baby_hkid = 'UN' THEN
            par_baby_hkid := var_nb_hkid;
        END IF;
        SELECT
            patient_key
            INTO var_baby_prk
            FROM cpi_patient
            WHERE hkid = par_baby_hkid;

        IF (var_mo_hkid = NULL OR var_nb_hkid = NULL OR LTRIM(RTRIM(var_mo_hkid)) = '' OR LTRIM(RTRIM(var_nb_hkid)) = '' OR var_baby_prk = NULL OR LTRIM(RTRIM(var_baby_prk)) = '') THEN
            BEGIN
                /* --set @retcode = -4 */
                var_retcode := 300004;
                /* ---select @raiserror_msg ="No Patient HKID Found!" */
                EXIT error;
            END;
        END IF;
        /* make sure @nb_case belong to @baby_hkid -- */
        /* --- if @baby_hkid = 'UN' <= new generated HKID.. */

        IF var_baby_prk <> var_nb_prk THEN
            BEGIN
                /* --set @retcode = -5 */
                var_retcode := 300005;
                /* --select @raiserror_msg ="The Baby Case MUST belong to same patient" */
                EXIT error;
            END;
        END IF;
        /* make sure @nb_case/@nb_case_org belong to same patient -- */

        IF var_upd_new_case = 'Y' AND par_nb_case <> par_nb_case_org THEN
            BEGIN
                SELECT
                    patient_key
                    INTO var_nb_prk_org
                    FROM cpi_case
                    WHERE hospital_code = par_nb_hosp AND case_no = par_nb_case_org;

                IF var_nb_prk_org <> var_nb_prk THEN
                    BEGIN
                        /* --set @retcode = -5 */
                        var_retcode := 300005;
                        /* --select @raiserror_msg ="The Baby Case MUST belong to same patient" */
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* ----If birth location is OTH, birth place must be Born before arrival */
        IF par_birth_loc = 'OTH' AND par_birth_place <> 'B' THEN
            BEGIN
                /* --set @retcode = -6 */
                var_retcode := 300006;
                /* ---select @raiserror_msg ="If birth location is OTH, birth place must be Born before arrival" */
                EXIT error;
            END;
        END IF;
        /* ----If birth place is Labour room, birth location must be own hospital. */
        IF par_birth_place = 'L' AND par_birth_loc <> par_mo_hosp THEN
            BEGIN
                /* --set @retcode = -7 */
                var_retcode := 300007;
                /* ---select @raiserror_msg ="If birth place is Labour room, birth location must be own hospital !" */
                EXIT error;
            END;
        END IF;
        /* --- check update birth order or NOT--- */
        SELECT
            'N'
            INTO var_update_birth_order;

        IF par_action = 'U' THEN
            BEGIN
                SELECT
                    birth_order
                    INTO var_birth_order_org
                    FROM mother_baby_case
                    WHERE mother_hospital_code = par_mo_hosp AND mother_case_no = par_mo_case_org AND baby_hospital_code = par_nb_hosp AND baby_case_no = par_nb_case_org;

                IF var_birth_order_org <> par_birth_order THEN
                    var_update_birth_order := 'Y';
                END IF;
            END;
        END IF;

        IF par_action = 'A' OR (par_action = 'U' AND var_update_birth_order = 'Y') OR
        /* --- update birth order */
        (par_action = 'U' AND par_mo_case <> par_mo_case_org) THEN
            /* --- update mo_case */
            BEGIN
                IF EXISTS (SELECT
                    *
                    FROM mother_baby_case
                    WHERE mother_hospital_code = par_mo_hosp AND mother_case_no = par_mo_case AND /* ---@mo_case = insert/updating mo_case */
                    /* ---     and baby_hospital_code = @nb_hosp */
                    /* ---     and baby_case_no = @nb_case */
                    birth_order = par_birth_order) THEN
                    BEGIN
                        /* --set @retcode = -8 */
                        var_retcode := 300008;
                        /* ---select @raiserror_msg ="Duplicate Birth Order is not allowed!" */
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;

        IF EXISTS (SELECT
            *
            FROM mother_baby_case
            WHERE mother_hospital_code = par_mo_hosp AND mother_case_no = par_mo_case AND baby_hospital_code = par_nb_hosp AND baby_case_no = par_nb_case) THEN
            var_nb_exist := 'Y';
        ELSE
            var_nb_exist := 'N';
        END IF;
        /* Format cpi_transaciton Records  => cpi_upload to hkpmi_update_mo_bb ---- */
        var_hospital_code := par_mo_hosp;
        var_success_flag := 'Y';
        var_cpi_filler := CONCAT(REPEAT(' ', 10), SUBSTRING((CONCAT(par_mo_hosp, REPEAT(' ', 3))), 1, 3), SUBSTRING((CONCAT(par_nb_hosp, REPEAT(' ', 3))), 1, 3), SUBSTRING((CONCAT(par_nb_case, REPEAT(' ', 12))), 1, 12));
        var_remark := CONCAT(SUBSTRING((CONCAT(par_mo_case_org, REPEAT(' ', 12))), 1, 12), SUBSTRING((CONCAT(par_nb_case_org, REPEAT(' ', 12))), 1, 12));
        var_source_ind := par_birth_place;
        var_source_code := par_birth_loc;
        var_pmi_access_code := par_birth_order;
        var_case_access_code := par_preg_number;
        /* ------ Transactions handble by gsql_adt_01.commit/rollback */

        IF par_action = 'A' THEN
            BEGIN
                var_txn_type := '260';

                IF var_nb_exist = 'Y' THEN
                    BEGIN
                        var_retcode := 200030;
                        /* 'New born information already exists' */
                        EXIT error;
                    END;
                END IF;

                BEGIN
                    INSERT INTO mother_baby_case (mother_hospital_code, mother_case_no, baby_hospital_code, baby_case_no, birth_order, pregnancy_number, birth_place, birth_location, create_by, create_datetime, update_by, update_datetime)
                    VALUES (par_mo_hosp, par_mo_case, par_nb_hosp, par_nb_case, par_birth_order, par_preg_number, par_birth_place, par_birth_loc, par_user_id, par_system_dtm, par_user_id, par_system_dtm);
                    raise notice 'web_cpi_update_mo_bb(302)[INSERT]mother_baby_case'; 
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        /* --set @retcode = -11		---- insert error */
                        var_retcode := 300011;
                        /* ---select @raiserror_msg ="Insert mother_baby_case error!" */
                        EXIT error;
                    END;
                END IF;
                /* ----20050808 -- */
                IF NOT EXISTS (SELECT
                    *
                    FROM cpi_new_born
                    WHERE mother_patient_key = var_mo_prk AND new_born_patient_key = var_nb_prk AND hospital_code = par_mo_hosp) THEN
                    BEGIN
                        raise notice '|%|%|%|%|%|%|%|%|%|%|', par_mo_hosp, var_mo_prk, var_nb_prk, par_birth_order, par_preg_number, par_user_id, par_system_dtm, par_user_id, par_system_dtm, par_mo_case;
                        INSERT INTO cpi_new_born (hospital_code, mother_patient_key, new_born_patient_key, birth_order, pregnancy_number, update_by, update_datetime, create_by, create_datetime, mother_case_no)
                        VALUES (par_mo_hosp, var_mo_prk, var_nb_prk, par_birth_order, par_preg_number, par_user_id, par_system_dtm, par_user_id, par_system_dtm, par_mo_case);
                         raise notice 'web_cpi_update_mo_bb(327)[INSERT]cpi_new_born'; 
                    END;
                END IF;
                /* ----20050808 -- */
            END;
        END IF;
        /* end of @action = 'A' */

        IF par_action = 'D' THEN
            BEGIN
                var_txn_type := '262';

                IF var_nb_exist = 'N' THEN
                    BEGIN
                        var_retcode := 200031; /* --	'New born information does not exist' */
                        EXIT error;
                    END;
                END IF;
				BEGIN
                DELETE FROM mother_baby_case
                    WHERE mother_hospital_code = par_mo_hosp AND mother_case_no = par_mo_case AND baby_hospital_code = par_nb_hosp AND baby_case_no = par_nb_case;
                raise notice 'web_cpi_update_mo_bb(402)[DELETE]mother_baby_case,par_nb_case=%',par_nb_case;
                var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;
                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        /* --set @retcode = -12		---- Del  error */
                        var_retcode := 300012;
                        /* --select @raiserror_msg ="Delete mother_baby_case error!" */
                        EXIT error;
                    END;
                END IF;
                /* ----20050808 -- */
                IF EXISTS (SELECT
                    *
                    FROM cpi_new_born
                    WHERE new_born_patient_key = var_nb_prk) THEN
                    BEGIN
                        DELETE FROM cpi_new_born
                            WHERE new_born_patient_key = var_nb_prk;
                    END;
                END IF;
            END;
        END IF;
        /* end of @action = 'D' */

        IF par_action = 'U' THEN
            BEGIN
                var_txn_type := '261';

                IF var_upd_new_case = 'N' AND var_nb_exist = 'N' THEN
                    BEGIN
                        var_retcode := 200031; /* --	'New born information does not exist' */
                        EXIT error;
                    END;
                END IF;
                /* ---  if updating new mo/bb cases already exist, = >false to update --- */

                IF var_upd_new_case = 'Y' AND var_nb_exist = 'Y' THEN
                    BEGIN
                        var_retcode := 200030;
                        /* 'New born information already exists' */
                        EXIT error;
                    END;
                END IF;
				BEGIN
                UPDATE mother_baby_case
                SET
                /* --mother_hospital_code = @mo_hosp, */
                mother_case_no = par_mo_case, baby_case_no = par_nb_case, birth_order = par_birth_order, pregnancy_number = par_preg_number, birth_location = par_birth_loc, birth_place = par_birth_place, update_by = par_user_id, update_datetime = par_system_dtm
                    WHERE mother_hospital_code = par_mo_hosp AND mother_case_no = par_mo_case_org AND baby_hospital_code = par_nb_hosp AND baby_case_no = par_nb_case_org;
                 raise notice 'web_cpi_update_mo_bb(402)[UPDATE]mother_baby_case,par_nb_case_org=%',par_nb_case_org;
                var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        /* --set @retcode = -14		---- update error */
                        var_retcode := 300014;
                        /* ---select @raiserror_msg ="Update mother_baby_case error!" */
                        EXIT error;
                    END;
                END IF;
                /* ----20050808 -- */
                IF EXISTS (SELECT
                    *
                    FROM cpi_new_born
                    WHERE new_born_patient_key = var_nb_prk) THEN
                    BEGIN
                        UPDATE cpi_new_born
                        SET hospital_code = par_mo_hosp, mother_case_no = par_mo_case, new_born_patient_key = var_nb_prk, mother_patient_key = var_mo_prk, birth_order = par_birth_order, pregnancy_number = par_preg_number, update_by = par_user_id, update_datetime = par_system_dtm
                            WHERE new_born_patient_key = var_nb_prk;
                       raise notice 'web_cpi_update_mo_bb(427)[UPDATE]cpi_new_born,var_nb_prk=%',var_nb_prk; 
                    END;
                END IF;
            END;
        END IF;
        /* end of @action = 'U' */
        var_transaction_datetime := timestamp_convert(localtimestamp);
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_transaction
            WHERE hospital_code = var_hospital_code AND transaction_datetime = var_transaction_datetime;
        /* ---- Prevent transaction time of different source system is the same.  Add seconds to the transaction time. */

        IF (var_cnt != 0) THEN
            BEGIN
                var_exit_flag := 'N';

                WHILE (var_exit_flag = 'N') LOOP
                    var_transaction_datetime := 3 * INTERVAL '1 millisecond' + var_transaction_datetime::TIMESTAMP;
                    SELECT
                        COUNT(*)
                        INTO var_cnt
                        FROM cpi_transaction
                        WHERE hospital_code = var_hospital_code AND transaction_datetime = var_transaction_datetime;

                    IF (var_cnt = 0) THEN
                        var_exit_flag := 'Y';
                    END IF;
                END LOOP;
            END;
        END IF;

        BEGIN
            INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key, case_no, case_access_code, pmi_access_code, old_patient_key, old_hkid, update_hospital, update_by, update_datetime, source_system, source_system_dtm, success_indicator, upload_status, cpi_filler, source_indicator, source_code, remark)
            VALUES (var_hospital_code, var_transaction_datetime, var_txn_type, var_mo_hkid, var_mo_prk, par_mo_case, var_case_access_code, var_pmi_access_code, var_nb_prk, var_nb_hkid, var_hospital_code, par_user_id, par_system_dtm, 'ADT', par_system_dtm, var_success_flag, 'Y', var_cpi_filler, var_source_ind, var_source_code, var_remark);
            raise notice 'web_cpi_update_mo_bb(427)[INSERT]cpi_transaction,var_nb_prk=%',var_nb_prk; 
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to insert into cpi_transaction for cpi_mo_bb txn!" */
                var_retcode := 200032;
                var_success_flag := 'N';
                EXIT error;
            END;
        END IF;
        pas_return_code := 0;
        RETURN;

        <<insert_transaction>>
        BEGIN
        END;
    END;
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "web_cpi_update_mo_bb" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
