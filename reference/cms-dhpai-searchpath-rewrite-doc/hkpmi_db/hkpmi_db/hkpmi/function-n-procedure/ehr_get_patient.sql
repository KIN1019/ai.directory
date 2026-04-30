-- DROP FUNCTION hkpmi.ehr_get_patient(varchar, bpchar);

CREATE OR REPLACE FUNCTION hkpmi.ehr_get_patient(par_ehr_number character varying, par_itype character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    "var_isEhrPatient" INTEGER;
    var_pas_pky VARCHAR(8);
    var_sql VARCHAR(2000);
BEGIN
    IF (par_ehr_number IS NULL) OR (par_itype < '1') OR (par_itype > '3') THEN
        BEGIN
            RETURN;
        END;
    END IF;
    SELECT
        0
        INTO "var_isEhrPatient";

    IF par_itype = '1' THEN
        BEGIN
            SELECT
                1, pas_pky
                INTO "var_isEhrPatient", var_pas_pky
                FROM ehr_patient_list
                WHERE ehr_number = par_ehr_number;
        END;
    END IF;

    IF par_itype = '2' THEN
        BEGIN
            SELECT
                1, pas_pky
                INTO "var_isEhrPatient", var_pas_pky
                FROM ehr_patient_list
                WHERE (ehr_hkic = par_ehr_number OR ehr_hkic = CONCAT(' ', par_ehr_number));
        END;
    END IF;

    IF par_itype = '3' THEN
        BEGIN
            SELECT
                1, pas_pky
                INTO "var_isEhrPatient", var_pas_pky
                FROM ehr_patient_list
                WHERE ehr_doc_no = par_ehr_number;
        END;
    END IF;

    IF ("var_isEhrPatient" = 1) THEN
        BEGIN
            p_refcur := 'cursor_' || CLOCK_TIMESTAMP();
            OPEN p_refcur FOR
            SELECT
                'Y' AS ehr_patient;
			return next p_refcur;

            SELECT
                'SELECT ehr_number,ehr_start_date,ehr_end_date,ehr_hkic,ehr_surname,ehr_givenname'
                INTO var_sql;
            SELECT
                CONCAT(var_sql, ',ehr_full_name,ehr_sex,ehr_dob,ehr_exact_dob,ehr_doc_type,ehr_doc_no')
                INTO var_sql;
            SELECT
                CONCAT(var_sql, ',ehr_death_date,ehr_exact_death,pas_hkic,pas_surname,pas_givenname')
                INTO var_sql;
            SELECT
                CONCAT(var_sql, ',pas_full_name,pas_sex,pas_dob,pas_exact_dob,pas_doc_type')
                INTO var_sql;
            SELECT
                CONCAT(var_sql, ',pas_doc_no,ehr_flag,ehr_non_ha_ind FROM ehr_patient_list ')
                INTO var_sql;
            SELECT
                CONCAT(var_sql, 'WHERE')
                INTO var_sql;

            IF par_itype = '1' THEN
                BEGIN
                    SELECT
                        CONCAT(var_sql, FORMAT(' ehr_number = %L', par_ehr_number))
                        INTO var_sql;
                END;
            END IF;

            IF par_itype = '2' THEN
                BEGIN
                    SELECT
                        CONCAT(var_sql, FORMAT(' (ehr_hkic = %L or ehr_hkic = CONCAT('' '', %L))', par_ehr_number, par_ehr_number))
                        INTO var_sql;
                END;
            END IF;

            IF par_itype = '3' THEN
                BEGIN
                    SELECT
                        CONCAT(var_sql, FORMAT(' ehr_doc_no = %L', par_ehr_number))
                        INTO var_sql;
                END;
            END IF;
            SELECT
                CONCAT(var_sql, ' AND ehr_ppi_ind = ''Y''')
                INTO var_sql;
            /*
            [3031 - Severity CRITICAL - Automatic conversion of this command is not supported. Perform a manual conversion.]
            exec (@sql)
            */
            p_refcur := 'cursor_' || CLOCK_TIMESTAMP();
            OPEN p_refcur FOR EXECUTE var_sql;
            RETURN NEXT p_refcur;

            SELECT
                'SELECT TO_CHAR(t.evt_txn_dtm, ''YYYY-MM-DD HH24:MI:SS'') AS evt_txn_dtm,t.evt_txn_type,t.evt_code,t.evt_ack'
                INTO var_sql;
            SELECT
                CONCAT(var_sql, ',t.ehr_flag,t.ehr_number,t.ehr_start_date,t.ehr_end_date,t.ehr_hkic,t.ehr_surname,t.ehr_givenname,t.ehr_full_name')
                INTO var_sql;
            SELECT
                CONCAT(var_sql, ',t.ehr_sex,t.ehr_dob,t.ehr_exact_dob,t.ehr_doc_type,t.ehr_doc_no,t.ehr_death_date,t.ehr_exact_death,t.old_ehr_flag')
                INTO var_sql;
            SELECT
                CONCAT(var_sql, ',t.old_ehr_hkic,t.old_ehr_surname,t.old_ehr_givenname,t.old_ehr_full_name,t.old_ehr_sex,t.old_ehr_dob,t.old_ehr_exact_dob')
                INTO var_sql;
            SELECT
                CONCAT(var_sql, ',t.old_ehr_doc_type,t.old_ehr_doc_no,t.pas_hkic,t.pas_case,t.pas_surname,t.pas_givenname,t.pas_full_name,t.pas_sex,t.pas_dob')
                INTO var_sql;
            SELECT
                CONCAT(var_sql, ',t.pas_exact_dob,t.pas_doc_type,t.pas_doc_no,t.old_pas_hkic,t.old_pas_surname,t.old_pas_givenname,t.old_pas_full_name')
                INTO var_sql;
            SELECT
                CONCAT(var_sql, ',t.old_pas_sex,t.old_pas_dob,t.old_pas_exact_dob,t.old_pas_doc_type,t.old_pas_doc_no')
                INTO var_sql;
            SELECT
                CONCAT(var_sql, ',TO_CHAR(t.sys_dtm, ''YYYY-MM-DD HH24:MI:SS'') AS sys_dtm,t.ehr_non_ha_ind,t.old_ehr_non_ha_ind ')
                INTO var_sql;
            SELECT
                CONCAT(var_sql, 'FROM ehr_patient_list p,ehr_event_txn t WHERE p.ehr_number = t.ehr_number AND')
                INTO var_sql;

            IF par_itype = '1' THEN
                BEGIN
                    SELECT
                        CONCAT(var_sql, FORMAT(' p.ehr_number = %L', par_ehr_number))
                        INTO var_sql;
                END;
            END IF;

            IF par_itype = '2' THEN
                BEGIN
                    SELECT
                        CONCAT(var_sql, FORMAT(' (p.ehr_hkic = %L or p.ehr_hkic = CONCAT('' '', %L))', par_ehr_number, par_ehr_number))
                        INTO var_sql;
                END;
            END IF;

            IF par_itype = '3' THEN
                BEGIN
                    SELECT
                        CONCAT(var_sql, FORMAT(' p.ehr_doc_no = %L', par_ehr_number))
                        INTO var_sql;
                END;
            END IF;
            SELECT
                CONCAT(var_sql, ' AND p.ehr_ppi_ind = ''Y''')
                INTO var_sql;
            
            /*
            [3031 - Severity CRITICAL - Automatic conversion of this command is not supported. Perform a manual conversion.]
            exec (@sql)
            */
            p_refcur := 'cursor_' || CLOCK_TIMESTAMP();
            OPEN p_refcur FOR EXECUTE var_sql;
            RETURN NEXT p_refcur;
        END;
    ELSE
        BEGIN
            p_refcur := 'cursor_' || CLOCK_TIMESTAMP();
            OPEN p_refcur FOR
            SELECT
                'N' AS ehr_patient;
	        return next p_refcur;
        END;
    END IF;

    SELECT
        'SELECT hkid,patient_name,sex,chi_name,dob,exact_dob_flag,other_doc_no,document_type,short_description FROM patient p left join document_type d '
        INTO var_sql;
    SELECT
        CONCAT(var_sql, 'on SUBSTRING(p.filler,1,1) = d.document_code WHERE ')
        INTO var_sql;

    IF par_itype = '2' THEN
        BEGIN
            SELECT
                CONCAT(var_sql, FORMAT('(p.hkid = %L or p.hkid = CONCAT('' '', %L)) ', par_ehr_number, par_ehr_number))
                INTO var_sql;
        END;
    END IF;

    IF par_itype = '3' THEN
        BEGIN
            SELECT
                CONCAT(var_sql, FORMAT('p.other_doc_no = %L ', par_ehr_number))
                INTO var_sql;
        END;
    END IF;

    IF par_itype = '1' THEN
        BEGIN
            IF "var_isEhrPatient" = 1 THEN
                BEGIN
                    SELECT
                        CONCAT(var_sql, FORMAT('p.patient_key = %L ', var_pas_pky))
                        INTO var_sql;
                END;
            ELSE
                BEGIN
                    SELECT
                        CONCAT(var_sql, ' 1 = 0 ')
                        INTO var_sql;
                END;
            END IF;
        END;
    END IF;

    /*
        [3031 - Severity CRITICAL - Automatic conversion of this command is not supported. Perform a manual conversion.]
        exec (@sql)
        */
    p_refcur := 'cursor_' || CLOCK_TIMESTAMP();
    OPEN p_refcur FOR EXECUTE var_sql;
    RETURN NEXT p_refcur;
    
    SELECT
        'SELECT p.hkid,pc.hospital_code,pc.case_no,p.patient_type,pc.create_dtm,pc.create_by FROM (SELECT patient_key,'
        INTO var_sql;
    SELECT
        CONCAT(var_sql, 'min(create_dtm) create_dtm FROM (SELECT patient_key, create_dtm FROM pmi_case WHERE patient_key IN (SELECT patient_key')
        INTO var_sql;
    SELECT
        CONCAT(var_sql, ' FROM patient p WHERE ')
        INTO var_sql;

    IF par_itype = '2' THEN
        BEGIN
            SELECT
                CONCAT(var_sql, FORMAT('(p.hkid = %L or p.hkid = CONCAT('' '', %L)))', par_ehr_number, par_ehr_number))
                INTO var_sql;
        END;
    END IF;

    IF par_itype = '3' THEN
        BEGIN
            SELECT
                CONCAT(var_sql, FORMAT('other_doc_no = %L)', par_ehr_number))
                INTO var_sql;
        END;
    END IF;

    IF par_itype = '1' THEN
        BEGIN
            IF "var_isEhrPatient" = 1 THEN
                BEGIN
                    SELECT
                        CONCAT(var_sql, FORMAT('patient_key = %L)', var_pas_pky))
                        INTO var_sql;
                END;
            ELSE
                BEGIN
                    SELECT
                        CONCAT(var_sql, ' 1 = 0)')
                        INTO var_sql;
                END;
            END IF;
        END;
    END IF;
    SELECT
        CONCAT(var_sql, ')a GROUP BY patient_key) pm, pmi_case pc,patient p WHERE pc.patient_key=pm.patient_key AND pc.create_dtm = pm.create_dtm')
        INTO var_sql;
    SELECT
        CONCAT(var_sql, ' AND pc.patient_key=p.patient_key')
        INTO var_sql;
   
    /*
    [3031 - Severity CRITICAL - Automatic conversion of this command is not supported. Perform a manual conversion.]
    exec (@sql)
    */
    p_refcur := 'cursor_' || CLOCK_TIMESTAMP();
    OPEN p_refcur FOR EXECUTE var_sql;
    RETURN NEXT p_refcur;

    SELECT
        'SELECT p.hkid,old_hkid,k.system_dtm,old_patient_name,old_sex,old_dob,new_hkid,new_patient_name,new_sex,new_dob,k.update_by,hospital_code FROM patient_key_changed k,'
        INTO var_sql;
    SELECT
        CONCAT(var_sql, 'patient p WHERE (p.hkid = new_hkid OR p.hkid = old_hkid) AND ')
        INTO var_sql;

    IF par_itype = '2' THEN
        BEGIN
            SELECT
                CONCAT(var_sql, FORMAT('(p.hkid = %L or p.hkid = CONCAT('' '', %L))', par_ehr_number, par_ehr_number))
                INTO var_sql;
        END;
    END IF;

    IF par_itype = '3' THEN
        BEGIN
            SELECT
                CONCAT(var_sql, FORMAT('p.other_doc_no = %L', par_ehr_number))
                INTO var_sql;
        END;
    END IF;

    IF par_itype = '1' THEN
        BEGIN
            IF "var_isEhrPatient" = 1 THEN
                BEGIN
                    SELECT
                        CONCAT(var_sql, FORMAT('p.patient_key = %L', var_pas_pky))
                        INTO var_sql;
                END;
            ELSE
                BEGIN
                    SELECT
                        CONCAT(var_sql, ' 1 = 0')
                        INTO var_sql;
                END;
            END IF;
        END;
    END IF;
    SELECT
        CONCAT(var_sql, ' ORDER BY system_dtm')
        INTO var_sql;
    /*
    [3031 - Severity CRITICAL - Automatic conversion of this command is not supported. Perform a manual conversion.]
    exec (@sql)
    */
    p_refcur := 'cursor_' || CLOCK_TIMESTAMP();
    OPEN p_refcur FOR EXECUTE var_sql;
    RETURN NEXT p_refcur;

    SELECT
        'SELECT p.hkid,m.hkid AS mhkid,mother_hospital_code,baby_hospital_code,mother_case_no,pc.case_no FROM patient p,pmi_case pc,mother_baby_case c,pmi_case mc,patient m WHERE '
        INTO var_sql;

    IF par_itype = '2' THEN
        BEGIN
            SELECT
                CONCAT(var_sql, FORMAT('(p.hkid = %L or p.hkid = CONCAT('' '', %L))', par_ehr_number, par_ehr_number))
                INTO var_sql;
        END;
    END IF;

    IF par_itype = '3' THEN
        BEGIN
            SELECT
                CONCAT(var_sql, FORMAT('p.other_doc_no = %L', par_ehr_number))
                INTO var_sql;
        END;
    END IF;

    IF par_itype = '1' THEN
        BEGIN
            IF "var_isEhrPatient" = 1 THEN
                BEGIN
                    SELECT
                        CONCAT(var_sql, FORMAT('p.patient_key = %L', var_pas_pky))
                        INTO var_sql;
                END;
            ELSE
                BEGIN
                    SELECT
                        CONCAT(var_sql, ' 1 = 0')
                        INTO var_sql;
                END;
            END IF;
        END;
    END IF;
    SELECT
        CONCAT(var_sql, ' AND p.patient_key = pc.patient_key AND pc.case_no =baby_case_no AND mother_case_no = mc.case_no AND m.patient_key = mc.patient_key')
        INTO var_sql;
   
    /*
    [3031 - Severity CRITICAL - Automatic conversion of this command is not supported. Perform a manual conversion.]
    exec (@sql)
    */
    p_refcur := 'cursor_' || CLOCK_TIMESTAMP();
    OPEN p_refcur FOR EXECUTE var_sql;
    RETURN NEXT p_refcur;
END;
$function$
;


ALTER FUNCTION "ehr_get_patient" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

