-- DROP PROCEDURE cpi_update_new_born(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in int4, in varchar, in timestamp, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE cpi_update_new_born(INOUT pas_return_code integer, IN par_action character varying, IN par_hospital_code character varying, IN par_mother_hkid character varying, IN par_new_born_hkid character varying, IN par_mother_case_no character varying, IN par_birth_order integer, IN par_preg_number integer, IN par_user_id character varying, IN par_system_dtm timestamp without time zone, IN par_old_patient_key character varying DEFAULT NULL::bpchar, IN par_new_patient_key character varying DEFAULT NULL::bpchar)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_mo_prk VARCHAR(8);
    var_nb_prk VARCHAR(8);
    var_nb_exist VARCHAR(1);
    var_retcode INTEGER;
    var_error_msg VARCHAR(255);
    var_error INTEGER;
    var_cnt INTEGER;
    var_exit_flag VARCHAR(01);
    var_success_flag VARCHAR(01);
    var_txn_type VARCHAR(03);
    var_case_access_code INTEGER;
    var_pmi_access_code INTEGER;
    var_rowcount INTEGER;
    var_transaction_datetime TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    <<error>>
    BEGIN
        /* 20030612 : insert cpi_transaction */
        /* ---End of 20030612 --- */
        SELECT
            0, 0, NULL
            INTO var_retcode, var_error, var_error_msg;
        SELECT
            patient_key
            INTO var_mo_prk
            FROM cpi_patient
            WHERE hkid = par_mother_hkid;

        IF par_action = 'P' THEN
            SELECT
                par_old_patient_key
                INTO var_nb_prk;
        ELSE
            SELECT
                patient_key
                INTO var_nb_prk
                FROM cpi_patient
                WHERE hkid = par_new_born_hkid;
        END IF;

        IF EXISTS (SELECT
            *
            FROM cpi_new_born
            /* --	where mother_patient_key = @mo_prk */
            WHERE new_born_patient_key = var_nb_prk) THEN
            SELECT
                'Y'
                INTO var_nb_exist;
        ELSE
            SELECT
                'N'
                INTO var_nb_exist;
        END IF;

        IF var_nb_exist = 'Y' THEN
            BEGIN
                IF par_action = 'D' THEN
                    BEGIN
                        SELECT
                            '262', NULL, NULL, 'Y'
                            INTO var_txn_type, var_case_access_code, var_pmi_access_code, var_success_flag;
                        DELETE FROM cpi_new_born
                        /* --			where mother_patient_key = @mo_prk */
                            WHERE new_born_patient_key = var_nb_prk;
                        raise notice 'cpi_update_new_born(71)[DELETE]cpi_new_born,var_nb_prk=%',var_nb_prk;
                    END;
                ELSE
                    IF par_action = 'U' THEN
                        BEGIN
                            SELECT
                                '261', par_preg_number, par_birth_order, 'Y'
                                INTO var_txn_type, var_case_access_code, var_pmi_access_code, var_success_flag;
                            UPDATE cpi_new_born
                            SET hospital_code = par_hospital_code, mother_case_no = par_mother_case_no, new_born_patient_key = var_nb_prk, mother_patient_key = var_mo_prk, birth_order = par_birth_order, pregnancy_number = par_preg_number, update_by = par_user_id, update_datetime = par_system_dtm
                                WHERE new_born_patient_key = var_nb_prk;
                            raise notice 'cpi_update_new_born(82)[UPDATE]cpi_new_born,var_nb_prk=%',var_nb_prk;
                            /* --				and mother_patient_key = @mo_prk */
                        END;
                    ELSE
                        IF par_action = 'P' THEN
                            BEGIN
                                IF EXISTS (SELECT
                                    *
                                    FROM cpi_new_born
                                    WHERE new_born_patient_key = par_new_patient_key) THEN
                                    BEGIN
                                        SELECT
                                            200030
                                            INTO var_retcode;
                                        EXIT error;
                                    END;
                                END IF;
                                SELECT
                                    '261', par_preg_number, par_birth_order, 'Y'
                                    INTO var_txn_type, var_case_access_code, var_pmi_access_code, var_success_flag;
                                UPDATE cpi_new_born
                                SET new_born_patient_key = par_new_patient_key
                                    WHERE new_born_patient_key = var_nb_prk;
                                raise notice 'cpi_update_new_born(105)[UPDATE]cpi_new_born,var_nb_prk=%',var_nb_prk;
                                SELECT
                                    par_new_patient_key
                                    INTO var_nb_prk;
                            END;
                        ELSE
                            BEGIN
                                /* --				select @error_msg = 'New born information already exists' */
                                /* --				select @retcode = -1 */
                                /* --				raiserror 200026 @error_msg */
                                SELECT
                                    200030
                                    INTO var_retcode;
                                EXIT error;
                            END;
                        END IF;
                    END IF;
                END IF;
            END;
        ELSE
            BEGIN
                IF par_action = 'A' THEN
                    BEGIN
                        SELECT
                            '260', par_preg_number, par_birth_order, 'Y'
                            INTO var_txn_type, var_case_access_code, var_pmi_access_code, var_success_flag;
                        INSERT INTO cpi_new_born (hospital_code, mother_patient_key, new_born_patient_key, birth_order, pregnancy_number, update_by, update_datetime, create_by, create_datetime, mother_case_no)
                        VALUES (par_hospital_code, var_mo_prk, var_nb_prk, par_birth_order, par_preg_number, par_user_id, par_system_dtm, par_user_id, par_system_dtm, par_mother_case_no);
                        raise notice 'cpi_update_new_born(133)[INSERT]cpi_new_born,var_nb_prk=%',var_nb_prk;
                    END;
                ELSE
                    BEGIN
                        /* --			select @error_msg = 'New born information does not exist' */
                        /* --			select @retcode = -1 */
                        /* --			raiserror 200026 @error_msg */
                        SELECT
                            200031
                            INTO var_retcode;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* 20030611 SL :   insert cpi_transaction */
        /* insert_transaction: */
        
        /*
        Prevent transaction time of different source
        system is the same.  Add seconds to the transaction time.
        */
        /* --	select @transaction_datetime=getdate() */
        /* select @transaction_datetime = @system_dtm */
        /* select  @cnt = count(*) */
        /* from    cpi_transaction */
        /* where   hospital_code = @hospital_code */
        /* and     transaction_datetime = @transaction_datetime */
        /* if (@cnt != 0) */
        /* begin */
        /* select  @exit_flag = "N" */
        /* while (@exit_flag = "N") */
        /* begin */
        /* select  @transaction_datetime = */
        /* dateadd(ms,3,@transaction_datetime) */
        /* select @cnt = count(*) */
        /* from cpi_transaction */
        /* where   hospital_code = @hospital_code */
        /* and transaction_datetime = @transaction_datetime */
        /* if (@cnt = 0) */
        /* select  @exit_flag = "Y" */
        /* end */
        /* end */
        /* insert cpi_transaction */
        /* (hospital_code, transaction_datetime, transaction_type, */
        /* hkid, patient_key,case_no,case_access_code,pmi_access_code, */
        /* old_patient_key,old_hkid, update_hospital,update_by, update_datetime, */
        /* source_system,source_system_dtm,success_indicator, upload_status, */
        /* cpi_filler) */
        /* values */
        /* (@hospital_code, @transaction_datetime, @txn_type, */
        /* @mother_hkid,@mo_prk,@mother_case_no,@case_access_code,@pmi_access_code, */
        /* @nb_prk,@new_born_hkid,@hospital_code,@user_id, @system_dtm, */
        /* 'ADT',@system_dtm,@success_flag,'Y', */
        /* @old_patient_key) */
        /* select  @error = @@error, @rowcount = @@rowcount */
        /* if (@error != 0) or (@rowcount = 0) */
        /* begin */
        
        /* print "Fail to insert into cpi_transaction for cpi_new_born txn!" */
        /* select  @retcode = 200032 */
        /* select  @success_flag = "N" */
        /* goto error */
        /* end */
        
        /* END of - 20030611 SL :   insert cpi_transaction */
    END;
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_update_new_born" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
