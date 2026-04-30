-- DROP FUNCTION hpi.fn_cpi_ti_patient();

CREATE OR REPLACE FUNCTION hpi.fn_cpi_ti_patient()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_return_code INTEGER;
    var_valid_flag VARCHAR(1);
    var_hkid VARCHAR(12);
    var_dist VARCHAR(5);
    var_name VARCHAR(48);
    var_sex VARCHAR(1);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_ccc_1 VARCHAR(5);
    var_ccc_2 VARCHAR(5);
    var_ccc_3 VARCHAR(5);
    var_ccc_4 VARCHAR(5);
    var_ccc_5 VARCHAR(5);
    var_ccc_6 VARCHAR(5);
    var_prk VARCHAR(8);
    var_update_by VARCHAR(8);
    var_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_hosp_code VARCHAR(3);
    var_chi_name VARCHAR(12);
    var_old_name VARCHAR(48);
    var_old_sex VARCHAR(1);
    var_old_dob TIMESTAMP WITHOUT TIME ZONE;
    var_old_ccc_1 VARCHAR(5);
    var_old_ccc_2 VARCHAR(5);
    var_old_ccc_3 VARCHAR(5);
    var_old_ccc_4 VARCHAR(5);
    var_old_ccc_5 VARCHAR(5);
    var_old_ccc_6 VARCHAR(5);
    var_old_exact_dob VARCHAR(1);
    var_old_update_by VARCHAR(8);
    var_old_src_system VARCHAR(5);
    var_old_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_old_hosp VARCHAR(3);
    var_old_prk VARCHAR(8);
    var_old_chi_name VARCHAR(12);
    var_old_phonetic VARCHAR(48);
    var_document_flag VARCHAR(1);
    var_numrows INTEGER;
    var_rowcount$aws$ INTEGER;
    sql$rowcount BIGINT;
    update$district BOOLEAN = FALSE;
BEGIN
    CASE TG_OP
        WHEN 'INSERT' THEN
            update$district = TRUE;
        WHEN 'UPDATE' THEN
            update$district = ((SELECT
                array_agg(district)
                FROM deleted) != (SELECT
                array_agg(district)
                FROM inserted));
        ELSE
            update$district := FALSE;
    END CASE;

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
    /* 2007-02-13 by HK Fong SMR20016006 - Start */
    /* --	declare @first_blank_ccc int, @last_non_blank_ccc int */
    /* 2007-02-13 by HK Fong SMR20016006 - End */
    var_numrows := var_rowcount$aws$;

    IF var_numrows > 1 THEN
        BEGIN
            RAISE EXCEPTION 'Multiple rows insert of patient is not allowed!' USING ERRCODE = '25000';
            ROLLBACK; /* ---20130805 */
            RETURN NULL;
        END;
    END IF;
    /* --	select	@hkid = hkid from inserted */
    SELECT
        hkid, sex, dob, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, patient_key, update_by, update_hospital, update_dtm, chi_name, patient_name, district
        INTO var_hkid, var_sex, var_dob, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_prk, var_update_by, var_hosp_code, var_update_dtm, var_chi_name, var_name, var_dist
        FROM inserted;
    CALL cpi_pq_validate_hkid(var_return_code, var_hkid, var_valid_flag );

    IF (var_valid_flag = 'N') THEN
        BEGIN
            IF var_return_code = 1 THEN
                BEGIN
                    RAISE EXCEPTION 'Invalid HKID, fail to insert patient record!' USING ERRCODE = '25000';
                    RETURN NULL;
                END;
            ELSE
                IF var_return_code = 2 THEN
                    BEGIN
                        RAISE EXCEPTION 'Invalid HKID check digit, fail to insert patient record!' USING ERRCODE = '25000';
                        RETURN NULL;
                    END;
                END IF;
            END IF;
        END;
    END IF;

    IF update$district THEN
        BEGIN
            IF var_dist IS NOT NULL THEN
                BEGIN
                    CALL cpi_pq_validate_district(var_return_code, var_dist, var_valid_flag );

                    IF var_return_code <> 0 OR var_valid_flag <> 'Y' THEN
                        BEGIN
                            RAISE EXCEPTION '% % % ', 'INSERT', 'cpi_patiebt', 'district' USING ERRCODE = '200012';
                            RETURN NULL;
                        END;
                    END IF;
                END;
            END IF;
        END;
    END IF;
    /* 2007-02-13 by HK Fong SMR20016006 - Start */
    /*
    select @first_blank_ccc = 0, @last_non_blank_ccc = 0
    if IsNull(@ccc_1, '') = ''
    begin
    	if @first_blank_ccc = 0
    		select @first_blank_ccc = 1
    end
    else
    	select @last_non_blank_ccc = 1
    
    if IsNull(@ccc_2, '') = ''
    begin
    	if @first_blank_ccc = 0
    		select @first_blank_ccc = 2
    end
    else
    	select @last_non_blank_ccc = 2
    
    if IsNull(@ccc_3, '') = ''
    begin
    	if @first_blank_ccc = 0
    		select @first_blank_ccc = 3
    end
    else
    	select @last_non_blank_ccc = 3
    
    if IsNull(@ccc_4, '') = ''
    begin
    	if @first_blank_ccc = 0
    		select @first_blank_ccc = 4
    end
    else
    	select @last_non_blank_ccc = 4
    
    if IsNull(@ccc_5, '') = ''
    begin
    
    	if @first_blank_ccc = 0
    		select @first_blank_ccc = 5
    end
    else
    	select @last_non_blank_ccc = 5
    
    if IsNull(@ccc_6, '') = ''
    begin
    	if @first_blank_ccc = 0
    		select @first_blank_ccc = 6
    end
    else
    	select @last_non_blank_ccc = 6
    
    if @first_blank_ccc > 0 and @last_non_blank_ccc > 0 and @first_blank_ccc < @last_non_blank_ccc
    begin
    	raiserror 25000 "Partial Chinese name input is not allowed, fail to insert patient record!"
    	return
    end
    */
    /* 2007-02-13 by HK Fong SMR20016006 -  End */
    /* ----------------20140709 --------------- */
    /* --Previous Deployment Date : cpi_ti_patient dbo   trigger     Dec 27 2001  7:39PM */
    /* 2005/2006 DataIntegrity enhanced to create <local new patient>, this pdemo MUST be retrieved from HKPMI (if HKPMI not available,TXN rejected !) */
    /* Following cpi_patient_key_changed during creating <local new patient> is not necessary -- */
    /* removed to ensure the UN-AE/Adm without any error event HKPMI down -- */
    /* ----------------20140709 --------------- */
    /* -----20140710 --- re-enable check HKPMI to fix : if the <local new patient> created by <030> and then <update the patient demo> at the same time, cpi_patient_key_changed occurred ... */
    CALL cpi_get_hkpmi_major_key(var_return_code, var_hkid, var_old_prk, var_old_name, var_old_sex, var_old_dob, var_old_exact_dob, var_old_ccc_1, var_old_ccc_2, var_old_ccc_3, var_old_ccc_4, var_old_ccc_5, var_old_ccc_6, var_old_update_by, var_old_src_system, var_old_update_dtm, var_old_hosp, var_document_flag);

    IF var_return_code = 0 THEN
        IF var_name <> var_old_name OR var_sex <> var_old_sex OR var_dob <> var_old_dob OR var_ccc_1 <> var_old_ccc_1 OR var_ccc_2 <> var_old_ccc_2 OR var_ccc_3 <> var_old_ccc_3 OR var_ccc_4 <> var_old_ccc_4 OR var_ccc_5 <> var_old_ccc_5 OR var_ccc_6 <> var_old_ccc_6 THEN
            BEGIN
                IF NOT EXISTS (SELECT
                    *
                    FROM cpi_patient_key_changed
                    WHERE patient_key = var_prk AND original_hkid = var_hkid) THEN
                    BEGIN
                        IF var_old_hosp <> var_hosp_code THEN
                            BEGIN
                                IF var_old_src_system = 'OPAS2' THEN
                                    SELECT
                                        'OPAS'
                                        INTO var_old_src_system;
                                END IF;
                                SELECT
                                    CONCAT(RTRIM(var_old_hosp), RTRIM(var_old_src_system))
                                    INTO var_old_update_by;
                            END;
                        END IF;
                        CALL cpi_get_phonetic_chin_name(var_return_code, var_old_ccc_1, var_old_ccc_2, var_old_ccc_3, var_old_ccc_4, var_old_ccc_5, var_old_ccc_6, var_old_phonetic, var_old_chi_name);
                        INSERT INTO cpi_patient_key_changed (patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, original_hkid, update_hospital, update_by, update_dtm)
                        VALUES (var_prk, var_hkid, var_old_name, var_old_sex, var_old_ccc_1, var_old_ccc_2, var_old_ccc_3, var_old_ccc_4, var_old_ccc_5, var_old_ccc_6, var_old_chi_name, var_old_dob, var_hkid, var_old_hosp, var_old_update_by, var_old_update_dtm);
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF sql$rowcount <> 1 THEN
                            BEGIN
                                RAISE EXCEPTION 'Insert Major Key Change Log failed' USING ERRCODE = '25000';
                                RETURN NULL;
                            END;
                        END IF;
                    END;
                END IF;
                INSERT INTO cpi_patient_key_changed (patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, original_hkid, update_hospital, update_by, update_dtm)
                VALUES (var_prk, var_hkid, var_name, var_sex, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_dob, var_hkid, var_hosp_code, var_update_by, var_update_dtm);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount <> 1 THEN
                    BEGIN
                        RAISE EXCEPTION 'Insert Major Key Change Log failed' USING ERRCODE = '25000';
                        RETURN NULL;
                    END;
                END IF;
            END;
        END IF;
    END IF;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_cpi_ti_patient" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
