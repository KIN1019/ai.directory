-- DROP FUNCTION hpi.fn_cpi_tu_patient_hd();

CREATE OR REPLACE FUNCTION hpi.fn_cpi_tu_patient_hd()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_patient_key VARCHAR(8);
    var_hospital_code VARCHAR(3);
    var_ins_mrn VARCHAR(8);
    var_del_mrn VARCHAR(8);
    var_cnt INTEGER;
    var_return_code INTEGER;
    var_valid_flag VARCHAR(1);
    var_dis_msg VARCHAR(50);
    var_numrows INTEGER;
    var_rowcount$aws$ INTEGER;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        SELECT
            count(1)
            FROM inserted
            INTO var_rowcount$aws$;
    ELSE
        SELECT
            count(1)
            FROM deleted
            INTO var_rowcount$aws$;
    END IF;
    var_numrows := var_rowcount$aws$;

    IF (var_numrows > 1) THEN
        BEGIN
            RAISE EXCEPTION 'Multiple rows update of patient_hospital_data table is not allowed!' USING ERRCODE = '25000';
            ROLLBACK; /* ---20130805 */
            RETURN NULL;
        END;
    END IF;
    SELECT
        patient_key, hospital_code, mrn
        INTO var_patient_key, var_hospital_code, var_del_mrn
        FROM deleted;
    SELECT
        mrn
        INTO var_ins_mrn
        FROM inserted;
	
    IF (var_ins_mrn = var_del_mrn)or(var_ins_mrn is null or var_del_mrn is null) THEN
        BEGIN
            RETURN NULL;
        END;
    END IF;
    SELECT
        0
        INTO var_return_code;

    IF (var_ins_mrn IS NOT NULL) THEN
        BEGIN
            CALL cpi_pq_validate_mrn(var_return_code, var_ins_mrn, var_hospital_code, var_valid_flag);

            IF (var_valid_flag = 'N') THEN
                BEGIN
                    IF (var_return_code = 1) THEN
                        BEGIN
                            RAISE EXCEPTION 'Invalid MRN, fail to update patient_hospital_data!' USING ERRCODE = '25000';
                            RETURN NULL;
                        END;
                    ELSE
                        IF (var_return_code = 2) THEN
                            BEGIN
                                RAISE EXCEPTION 'Invalid MRN check digit, fail to update patient_hospital_data!' USING ERRCODE = '25000';
                                RETURN NULL;
                            END;
                        END IF;
                    END IF;
                END;
            END IF;
        END;
    END IF;
    /*
    select	@cnt = count(*)
    from	cpi_patient_hospital_data
    where	patient_key = @patient_key
    and	hospital_code = @hospital_code
    */
    /*
    select	@cnt = count(*)
    from	cpi_patient_hosp_mrn_changed
    where	patient_key = @patient_key
    */
    SELECT
        COUNT(*)
        INTO var_cnt
        FROM cpi_patient_hosp_mrn_changed
        WHERE patient_key = var_patient_key AND hospital_code = var_hospital_code;

    IF (var_cnt = 0) THEN
        BEGIN
            INSERT INTO cpi_patient_hosp_mrn_changed (patient_key, hospital_code, mrn, update_by, update_dtm)
            SELECT
                patient_key, hospital_code, mrn, update_by, update_dtm
                FROM deleted;
        END;
    END IF;
    INSERT INTO cpi_patient_hosp_mrn_changed (patient_key, hospital_code, mrn, update_by, update_dtm)
    SELECT
        patient_key, hospital_code, mrn, update_by, update_dtm
        FROM inserted;
    RETURN NULL;
END;
$function$
;

;ALTER FUNCTION "fn_cpi_tu_patient_hd" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
