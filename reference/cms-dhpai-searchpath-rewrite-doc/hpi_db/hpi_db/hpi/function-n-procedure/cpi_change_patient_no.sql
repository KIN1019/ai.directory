-- DROP PROCEDURE hpi.cpi_change_patient_no(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_change_patient_no(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_old_patient_key character varying, IN par_new_patient_key character varying, IN par_user_id character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_old_patient_no INTEGER;
    var_new_patient_no INTEGER;
    var_update_dt TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    SELECT
        CAST (par_old_patient_key AS INTEGER)
        INTO var_old_patient_no;
    SELECT
        CAST (par_new_patient_key AS INTEGER)
        INTO var_new_patient_no;
    SELECT
        timestamp_convert(localtimestamp)
        INTO var_update_dt;

--    BEGIN TRANSACTION;
    INSERT INTO cpi_change_patient_no_log (hkid, old_patient_no, new_patient_no, update_datetime)
    SELECT
        par_hkid, var_old_patient_no, var_new_patient_no, var_update_dt;

    BEGIN
        UPDATE patient_data
        SET patient_no = var_new_patient_no
            WHERE patient_no = var_old_patient_no;
        EXCEPTION
            WHEN others THEN
                BEGIN
                    RAISE EXCEPTION 'Fail to update patient_data in change patient no' USING ERRCODE := '25000';
                    ROLLBACK;
                    pas_return_code := 1;
                    RETURN;
                END;
    END;

    BEGIN
        UPDATE cases
        SET patient_no = var_new_patient_no
            WHERE patient_no = var_old_patient_no;
        EXCEPTION
            WHEN others THEN
                BEGIN
                    RAISE EXCEPTION 'Fail to update cases in change patient no' USING ERRCODE := '25000';
                    ROLLBACK;
                    pas_return_code := 1;
                    RETURN;
                END;
    END;

    BEGIN
        UPDATE appointment
        SET patient_no = var_new_patient_no
            WHERE patient_no = var_old_patient_no;
        EXCEPTION
            WHEN others THEN
                BEGIN
                    RAISE EXCEPTION 'Fail to update appointment in change patient no' USING ERRCODE := '25000';
                    ROLLBACK;
                    pas_return_code := 1;
                    RETURN;
                END;
    END;

    BEGIN
        UPDATE happointment
        SET patient_no = var_new_patient_no
            WHERE patient_no = var_old_patient_no;
        EXCEPTION
            WHEN others THEN
                BEGIN
                    RAISE EXCEPTION 'Fail to update happointment in change patient no' USING ERRCODE := '25000';
                    ROLLBACK;
                    pas_return_code := 1;
                    RETURN;
                END;
    END;

    BEGIN
        UPDATE appointment_aheis_detail
        SET patient_no = var_new_patient_no
            WHERE patient_no = var_old_patient_no;
        EXCEPTION
            WHEN others THEN
                BEGIN
                    RAISE EXCEPTION 'Fail to update appointment_aheis_detail in change patient no' USING ERRCODE := '25000';
                    ROLLBACK;
                    pas_return_code := 1;
                    RETURN;
                END;
    END;

    BEGIN
        UPDATE appointment_eis_detail
        SET patient_no = var_new_patient_no
            WHERE patient_no = var_old_patient_no;
        EXCEPTION
            WHEN others THEN
                BEGIN
                    RAISE EXCEPTION 'Fail to update appointment_eis_detail in change patient no' USING ERRCODE := '25000';
                    ROLLBACK;
                    pas_return_code := 1;
                    RETURN;
                END;
    END;
    /* 2005-11-29 Shelley SMR20014903 Add pp_by_eis_specialty begin */
    BEGIN
        UPDATE pp_by_eis_specialty
        SET patient_key = par_new_patient_key
            WHERE patient_key = par_old_patient_key;
        EXCEPTION
            WHEN others THEN
                BEGIN
                    RAISE EXCEPTION 'Fail to update pp_by_eis_specialty in change patient no' USING ERRCODE := '25000';
                    ROLLBACK;
                    pas_return_code := 1;
                    RETURN;
                END;
    END;

    IF NOT EXISTS (SELECT
        0
        FROM gopd_patient_detail
        WHERE patient_no = var_new_patient_no) THEN
        BEGIN
            BEGIN
                UPDATE gopd_patient_detail
                SET patient_no = var_new_patient_no
                    WHERE patient_no = var_old_patient_no;
                EXCEPTION
                    WHEN others THEN
                        BEGIN
                            RAISE EXCEPTION 'Fail to update gopd_patient_detail in change patient no' USING ERRCODE := '25000';
                            ROLLBACK;
                            pas_return_code := 1;
                            RETURN;
                        END;
            END;
        END;
    ELSE
        IF EXISTS (SELECT
            0
            FROM gopd_patient_detail
            WHERE patient_no = var_old_patient_no) THEN
            BEGIN
                DELETE FROM gopd_patient_detail
                    WHERE patient_no = var_old_patient_no;
            END;
        END IF;
    END IF;
    /* 2005-08-03 Shelley  SMR20014565 End */
    BEGIN
        UPDATE case_patient_condition
        SET patient_no = var_new_patient_no
            WHERE patient_no = var_old_patient_no;
        EXCEPTION
            WHEN others THEN
                BEGIN
                    RAISE EXCEPTION 'Fail to update case_patient_condition in change patient no' USING ERRCODE := '25000';
                    ROLLBACK;
                    pas_return_code := 1;
                    RETURN;
                END;
    END;

    BEGIN
        UPDATE appointment_intervention
        SET patient_no = var_new_patient_no
            WHERE patient_no = var_old_patient_no;
        EXCEPTION
            WHEN others THEN
                BEGIN
                    RAISE EXCEPTION 'Fail to update appointment_intervention in change patient no' USING ERRCODE := '25000';
                    ROLLBACK;
                    pas_return_code := 1;
                    RETURN;
                END;
    END;
    /* 2005-02-24 Danny Lo SMR20014013 Start */
    BEGIN
        UPDATE ps_waiver
        SET patient_no = var_new_patient_no
            WHERE patient_no = var_old_patient_no;
        EXCEPTION
            WHEN others THEN
                BEGIN
                    RAISE EXCEPTION 'Fail to update ps_waiver in change patient no' USING ERRCODE := '25000';
                    ROLLBACK;
                    pas_return_code := 1;
                    RETURN;
                END;
    END;
    --COMMIT;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_change_patient_no" OWNER TO "HPI_SCHEMA_OWNER_ROLE";