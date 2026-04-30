-- DROP PROCEDURE hkpmi.hkpmi_erpt_ehr_portal(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in timestamp, inout refcursor, inout refcursor, inout refcursor, inout refcursor, inout refcursor, inout refcursor, inout refcursor, inout refcursor);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_erpt_ehr_portal(INOUT pas_return_code int, par_rpt_type character varying, par_ehr_pin character varying DEFAULT NULL::character varying, par_ehr_pin_type character varying DEFAULT NULL::character varying, par_rpt_id character varying DEFAULT NULL::character varying, par_rpt_start_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, par_rpt_end_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT p_refcur refcursor DEFAULT NULL, INOUT p_refcur_2 refcursor DEFAULT NULL, INOUT p_refcur_3 refcursor DEFAULT NULL, INOUT p_refcur_4 refcursor DEFAULT NULL, INOUT p_refcur_5 refcursor DEFAULT NULL, INOUT p_refcur_6 refcursor DEFAULT NULL, INOUT p_refcur_7 refcursor DEFAULT NULL, INOUT p_refcur_8 refcursor DEFAULT NULL)
 LANGUAGE plpgsql
AS $procedure$
declare p_refcur refcursor;
/* STAT: statitics ;ENQ - Enquiry; GEN - Report Generation */
/* ENQ : ehr_number/hkid/doc.no */
/* ENQ : 1 - ehr_number ; 2 - hkid ; 3 - doc.no */
/* RPT : 1 - 6 */
/* RPT : */
/* RPT : */
DECLARE
    "var_isEhrPatient" INTEGER;
    var_pas_pky VARCHAR(8);
    var_sql VARCHAR(2000);
    var_report_date DATE;
BEGIN
    /* --------------------------------------------------------------------------------- */
    /* Called by : http://pas-web/pasEhr/ (HA_HKPMI_SP4_AN.pas_stat.erpt_ehr_portal) */
    /* rpt_type 1).Statistics Tab Page - [exec hkpmi_erpt_ehr_portal "STAT"] */
    /* rpt_type 2).Enquiry    Tab Page - [exec hkpmi_erpt_ehr_portal "ENQ",pin,pin_type] */
    /* rpt_type 3).Report     Tab Page - [exec hkpmi_erpt_ehr_portal "GEN",null,null,rpt_id,rpt_start_dtm,report_end_dtm] */
    /* rpt_id = 1 [Total eHR Patients in HA] */
    /* rpt_id = 2 [Duplicated HA PMI records of eHR patient(upon&after eHR Registration) */
    /* rpt_id = 3 [Unmatched HA-eHR Major Keys Cases] */
    /* rpt_id = 4 [Update HKID/DocPair of eHR patient in HA(by update hKID/Merge HKIDS) */
    /* rpt_id = 5 [Update HKID/DOcPair of eHR patient in eHR] */
    /* rpt_id = 6 [ Total eHR Newborn (Cumulative)] */
    
    /* --------------------------------------------------------------------------------- */
    IF par_rpt_type = 'STAT' THEN
        BEGIN
            -- DROP TABLE IF EXISTS t$tmp_code_table;
            -- CREATE TEMPORARY TABLE t$tmp_code_table
            -- AS
            -- SELECT
            --     'Y' AS ehr_ppi_ind, ehr_doc_type, a.code_field_full_desc AS ehr_doc_type_desc, code_field AS ehr_flag, ec.code_field_full_desc AS ehr_flag_desc
            --     FROM (SELECT
            --         CASE
            --             WHEN ct.code_field IS NULL THEN dt.ehr_doc_type
            --             ELSE ct.code_field
            --         END AS ehr_doc_type, COALESCE(code_field_full_desc, 'Code not found on Code Table') AS code_field_full_desc
            --         FROM (SELECT
            --             code_field AS ehr_doc_type
            --             FROM ehr_code_table
            --             WHERE code_type = 'EHR_DOC_TYPE' AND code_name = 'ehr_doc_type'
            --         UNION
            --         SELECT DISTINCT
            --             ehr_doc_type
            --             FROM ehr_patient_list) AS dt
            --         LEFT OUTER JOIN ehr_code_table AS ct
            --             ON dt.ehr_doc_type = ct.code_field AND ct.code_type = 'EHR_DOC_TYPE' AND ct.code_name = 'ehr_doc_type') AS a, ehr_code_table AS ec
            --     WHERE ec.code_type = 'EHR_FLAG' AND ec.code_name = 'ehr_flag';
            -- INSERT INTO t$tmp_code_table
            -- SELECT
            --     'N', ehr_doc_type, ehr_doc_type_desc, ehr_flag, ehr_flag_desc
            --     FROM t$tmp_code_table;
            -- OPEN p_refcur FOR
            -- SELECT
            --     ct.code_field, ct."ehr_doc_type_desc", ct.ehr_flag, ct.ehr_flag_desc, ct."ehr_ppi_ind", COALESCE(cnt, 0) AS cnt
            --     FROM t$tmp_code_table AS ct
            --     LEFT OUTER JOIN (SELECT
            --         CASE ehr_ppi_ind
            --             WHEN 'Y' THEN 'Y'
            --             ELSE 'N'
            --         END AS ehr_ppi_ind, ehr_doc_type, ehr_flag, COUNT(1) AS cnt
            --         FROM ehr_patient_list
            --         GROUP BY ehr_ppi_ind, ehr_doc_type, ehr_flag) AS l
            --         ON ct.code_field = l.ehr_doc_type AND ct.ehr_flag = l.ehr_flag AND ct."ehr_ppi_ind" = l.ehr_ppi_ind;
			-- 		return next p_refcur;
                DROP TABLE IF EXISTS t$tmp_code_table;
                CREATE TEMP TABLE t$tmp_code_table (
                    ehr_ppi_ind VARCHAR(2),
                    ehr_doc_type VARCHAR(50),
                    ehr_doc_type_desc VARCHAR(200),
                    ehr_flag VARCHAR(10),
                    ehr_flag_desc VARCHAR(200)
                );

                -- Insert initial data
                INSERT INTO t$tmp_code_table
                SELECT 'Y' AS ehr_ppi_ind
                    ,ehr_doc_type
                    ,a.code_field_full_desc AS ehr_doc_type_desc
                    ,code_field AS ehr_flag
                    ,ec.code_field_full_desc AS ehr_flag_desc
                FROM (
                    SELECT CASE 
                            WHEN ct.code_field IS NULL
                                THEN dt.ehr_doc_type
                            ELSE ct.code_field
                            END AS ehr_doc_type
                        ,COALESCE(code_field_full_desc, 'Code not found on Code Table') AS code_field_full_desc
                    FROM (
                        SELECT code_field AS ehr_doc_type
                        FROM ehr_code_table
                        WHERE code_type = 'EHR_DOC_TYPE'
                            AND code_name = 'ehr_doc_type'
                        
                        UNION
                        
                        SELECT DISTINCT ehr_doc_type
                        FROM ehr_patient_list
                        ) dt
                    LEFT OUTER JOIN ehr_code_table ct ON dt.ehr_doc_type = ct.code_field
                        AND ct.code_type = 'EHR_DOC_TYPE'
                        AND ct.code_name = 'ehr_doc_type'
                    ) a
                    ,ehr_code_table ec
                WHERE ec.code_type = 'EHR_FLAG'
                    AND ec.code_name = 'ehr_flag';

                -- Insert duplicate data with 'N' flag
                INSERT INTO t$tmp_code_table
                SELECT 'N'
                    ,ehr_doc_type
                    ,ehr_doc_type_desc
                    ,ehr_flag
                    ,ehr_flag_desc
                FROM t$tmp_code_table;

                -- Return statistics data
                OPEN p_refcur FOR
                    SELECT ct.ehr_doc_type
                        ,ct.ehr_doc_type_desc
                        ,ct.ehr_flag
                        ,ct.ehr_flag_desc
                        ,ct.ehr_ppi_ind
                        ,COALESCE(cnt, 0) AS cnt
                    FROM t$tmp_code_table ct
                    LEFT OUTER JOIN (
                        SELECT CASE ehr_ppi_ind
                                WHEN 'Y'
                                    THEN 'Y'
                                ELSE 'N'
                                END AS ehr_ppi_ind
                            ,ehr_doc_type
                            ,ehr_flag
                            ,count(1) AS cnt
                        FROM ehr_patient_list
                        GROUP BY ehr_ppi_ind
                            ,ehr_doc_type
                            ,ehr_flag
                        ) l ON ct.ehr_doc_type = l.ehr_doc_type
                        AND ct.ehr_flag = l.ehr_flag
                        AND ct.ehr_ppi_ind = l.ehr_ppi_ind;
        END;
    END IF;
    /* --------------------------------------------------------------------------------- */
    /* rpt_type 2 :   Enquiry */
    
    /* --------------------------------------------------------------------------------- */
    IF par_rpt_type = 'ENQ' THEN
        BEGIN
            IF (par_ehr_pin IS NULL) OR (par_ehr_pin_type < '1') OR (par_ehr_pin_type > '3') THEN
                BEGIN
                    pas_return_code := 0;
                    RETURN;
                END;
            END IF;
            SELECT
                0
                INTO "var_isEhrPatient";

            IF par_ehr_pin_type = '1' THEN
                BEGIN
                    SELECT
                        1, pas_pky
                        INTO "var_isEhrPatient", var_pas_pky
                        FROM ehr_patient_list
                        WHERE ehr_number = par_ehr_pin;
                END;
            END IF;

            IF par_ehr_pin_type = '2' THEN
                BEGIN
                    SELECT
                        1, pas_pky
                        INTO "var_isEhrPatient", var_pas_pky
                        FROM ehr_patient_list
                        WHERE (ehr_hkic = par_ehr_pin OR ehr_hkic = CONCAT(' ', par_ehr_pin));
                END;
            END IF;

            IF par_ehr_pin_type = '3' THEN
                BEGIN
                    SELECT
                        1, pas_pky
                        INTO "var_isEhrPatient", var_pas_pky
                        FROM ehr_patient_list
                        WHERE ehr_doc_no = par_ehr_pin;
                END;
            END IF;
        
            raise notice 'var_isEhrPatient=%,par_ehr_pin=%,par_ehr_pin_type=%',"var_isEhrPatient",par_ehr_pin,par_ehr_pin_type;
            IF ("var_isEhrPatient" = 1) THEN
                BEGIN
                    OPEN p_refcur_2 FOR
                        SELECT
                            'Y' AS ehr_patient;
                    
                    SELECT 'SELECT ehr_number,ehr_start_date,ehr_end_date,ehr_hkic,ehr_surname,ehr_givenname' INTO var_sql;
                    SELECT CONCAT(var_sql, ',ehr_full_name,ehr_sex,ehr_dob,ehr_exact_dob,ehr_doc_type,ehr_doc_no') INTO var_sql;
                    SELECT CONCAT(var_sql, ',ehr_death_date,ehr_exact_death,pas_hkic,pas_surname,pas_givenname') INTO var_sql;
                    SELECT CONCAT(var_sql, ',pas_full_name,pas_sex,pas_dob,pas_exact_dob,pas_doc_type') INTO var_sql;
                    SELECT CONCAT(var_sql, ',pas_doc_no,ehr_flag,ehr_non_ha_ind, ehr_smart_id FROM ehr_patient_list ') INTO var_sql;
                    SELECT CONCAT(var_sql, 'WHERE') INTO var_sql;                   

                    IF par_ehr_pin_type = '1' THEN
                        BEGIN
                            SELECT CONCAT(var_sql, ' ehr_number = $1') INTO var_sql;
                            -- SELECT
                            --     CONCAT(var_sql, ' ehr_number = @ehr_pin')
                            --     INTO var_sql;
                        END;
                    END IF;

                    IF par_ehr_pin_type = '2' THEN
                        BEGIN
                            SELECT CONCAT(var_sql, ' (ehr_hkic = $1 OR ehr_hkic = '' '' || $1)') INTO var_sql;
                            -- SELECT
                            --     CONCAT(var_sql, ' (ehr_hkic = @ehr_pin or ehr_hkic = '' '' + @ehr_pin)')
                            --     INTO var_sql;
                        END;
                    END IF;

                    IF par_ehr_pin_type = '3' THEN
                        BEGIN
                            SELECT CONCAT(var_sql, ' ehr_doc_no = $1') INTO var_sql;
                            -- SELECT
                            --     CONCAT(var_sql, ' ehr_doc_no = @ehr_pin')
                            --     INTO var_sql;
                        END;
                    END IF;
                    SELECT
                        CONCAT(var_sql, ' AND ehr_ppi_ind = ''Y''')
                        INTO var_sql;
                    /*
                    [3031 - Severity CRITICAL - Automatic conversion of this command is not supported. Perform a manual conversion.]
                    exec (@sql)
                    */
                    raise notice '[1]par_ehr_pin_type=%,par_ehr_pin=%,var_sql=%',par_ehr_pin_type,par_ehr_pin,var_sql;
                    OPEN p_refcur_3 FOR
                        EXECUTE var_sql USING par_ehr_pin;
                    

                    SELECT 'SELECT REPLACE(TO_CHAR(t.evt_txn_dtm, ''YYYY-MM-DD HH24:MI:SS''), ''/'', ''-'') AS evt_txn_dtm,t.evt_txn_type,t.evt_code,t.evt_ack' INTO var_sql;
                    -- SELECT
                    --     'SELECT STR_REPLACE(CONVERT(VARCHAR(19), t.evt_txn_dtm, 121), ''/'', ''-'') AS evt_txn_dtm,t.evt_txn_type,t.evt_code,t.evt_ack'
                    --     INTO var_sql;
                    SELECT CONCAT(var_sql, ',t.ehr_flag,t.ehr_number,t.ehr_start_date,t.ehr_end_date,t.ehr_hkic,t.ehr_surname,t.ehr_givenname,t.ehr_full_name') INTO var_sql;
                    SELECT CONCAT(var_sql, ',t.ehr_sex,t.ehr_dob,t.ehr_exact_dob,t.ehr_doc_type,t.ehr_doc_no,t.ehr_death_date,t.ehr_exact_death,t.old_ehr_flag') INTO var_sql;
                    SELECT CONCAT(var_sql, ',t.old_ehr_hkic,t.old_ehr_surname,t.old_ehr_givenname,t.old_ehr_full_name,t.old_ehr_sex,t.old_ehr_dob,t.old_ehr_exact_dob') INTO var_sql;
                    SELECT CONCAT(var_sql, ',t.old_ehr_doc_type,t.old_ehr_doc_no,t.pas_hkic,t.pas_case,t.pas_surname,t.pas_givenname,t.pas_full_name,t.pas_sex,t.pas_dob') INTO var_sql;
                    SELECT CONCAT(var_sql, ',t.pas_exact_dob,t.pas_doc_type,t.pas_doc_no,t.old_pas_hkic,t.old_pas_surname,t.old_pas_givenname,t.old_pas_full_name') INTO var_sql;
                    SELECT CONCAT(var_sql, ',t.old_pas_sex,t.old_pas_dob,t.old_pas_exact_dob,t.old_pas_doc_type,t.old_pas_doc_no') INTO var_sql;
                    SELECT CONCAT(var_sql, ',REPLACE(TO_CHAR(t.sys_dtm, ''YYYY-MM-DD HH24:MI:SS''), ''/'', ''-'') AS sys_dtm,t.ehr_non_ha_ind,t.old_ehr_non_ha_ind, t.ehr_smart_id ') INTO var_sql;
                    -- SELECT
                    --     CONCAT(var_sql, ',STR_REPLACE(CONVERT(VARCHAR(19), t.sys_dtm, 121), ''/'', ''-'') AS sys_dtm,t.ehr_non_ha_ind,t.old_ehr_non_ha_ind, t.ehr_smart_id ')
                    --     INTO var_sql;
                    SELECT CONCAT(var_sql, 'FROM ehr_patient_list p,ehr_event_txn t WHERE p.ehr_number = t.ehr_number AND') INTO var_sql;

                    IF par_ehr_pin_type = '1' THEN
                        BEGIN
                            SELECT CONCAT(var_sql, ' p.ehr_number = $1') INTO var_sql;
                            -- SELECT
                            --     CONCAT(var_sql, ' p.ehr_number = @ehr_pin')
                            --     INTO var_sql;
                        END;
                    END IF;

                    IF par_ehr_pin_type = '2' THEN
                        BEGIN
                            SELECT CONCAT(var_sql, ' (p.ehr_hkic = $1 OR p.ehr_hkic = '' '' || $1)') INTO var_sql;
                            -- SELECT
                            --     CONCAT(var_sql, ' (p.ehr_hkic = @ehr_pin or p.ehr_hkic = '' '' + @ehr_pin)')
                            --     INTO var_sql;
                        END;
                    END IF;

                    IF par_ehr_pin_type = '3' THEN
                        BEGIN
                            SELECT CONCAT(var_sql, ' p.ehr_doc_no = $1') INTO var_sql;
                            -- SELECT
                            --     CONCAT(var_sql, ' p.ehr_doc_no = @ehr_pin')
                            --     INTO var_sql;
                        END;
                    END IF;
                    SELECT CONCAT(var_sql, ' AND p.ehr_ppi_ind = ''Y''') INTO var_sql;
                    SELECT
                        CONCAT(var_sql, ' AND p.ehr_ppi_ind = ''Y''')
                        INTO var_sql;
                    /*
                    [3031 - Severity CRITICAL - Automatic conversion of this command is not supported. Perform a manual conversion.]
                    exec (@sql)
                    */
                    raise notice '[2]par_ehr_pin_type=%,par_ehr_pin=%,var_sql=%',par_ehr_pin_type,par_ehr_pin,var_sql;
                    OPEN p_refcur_4 FOR
                        EXECUTE var_sql USING par_ehr_pin;
                    
                END;
            ELSE
                BEGIN
                    OPEN p_refcur_2 FOR
                    SELECT
                        'N' AS ehr_patient;
			        
                END;
            END IF;

            SELECT 'SELECT hkid,patient_name,sex,chi_name,dob,exact_dob_flag,other_doc_no,document_type,short_description,update_by,source_system,update_hospital,source_system_dtm FROM patient p left join document_type d ' INTO var_sql;
            SELECT CONCAT(var_sql, 'on SUBSTRING(p.filler,1,1) = d.document_code WHERE ') INTO var_sql; 

            IF par_ehr_pin_type = '2' THEN
                BEGIN
                    SELECT CONCAT(var_sql, '(p.hkid = $1 or p.hkid = '' '' || $1) ') INTO var_sql;
                    -- SELECT
                    --     CONCAT(var_sql, '(p.hkid = @ehr_pin or p.hkid = '' '' + @ehr_pin) ')
                    --     INTO var_sql;
                END;
            END IF;

            IF par_ehr_pin_type = '3' THEN
                BEGIN
                    SELECT CONCAT(var_sql, 'p.other_doc_no = $1 ') INTO var_sql;
                    -- SELECT
                    --     CONCAT(var_sql, 'p.other_doc_no = @ehr_pin ')
                    --     INTO var_sql;
                END;
            END IF;

            IF par_ehr_pin_type = '1' THEN
                BEGIN
                    IF "var_isEhrPatient" = 1 THEN
                        BEGIN
                            SELECT CONCAT(var_sql, 'p.patient_key = $2 ') INTO var_sql;
                            -- SELECT
                            --     CONCAT(var_sql, 'p.patient_key = @pas_pky ')
                            --     INTO var_sql;
                        END;
                    ELSE
                        BEGIN
                            SELECT CONCAT(var_sql, ' 1 = 0 ') INTO var_sql;
                            -- SELECT
                            --     CONCAT(var_sql, ' 1 = 0 ')
                            --     INTO var_sql;
                        END;
                    END IF;
                END;
            END IF;

            /*
            [3031 - Severity CRITICAL - Automatic conversion of this command is not supported. Perform a manual conversion.]
            exec (@sql)
            */
            raise notice '[3]par_ehr_pin_type=%,par_ehr_pin=%,var_pas_pky=%,var_sql=%',par_ehr_pin_type,par_ehr_pin,var_pas_pky,var_sql;
            OPEN p_refcur_5 FOR
                EXECUTE var_sql USING par_ehr_pin, var_pas_pky;
            
            -- SELECT
            --     'SELECT p.hkid,pc.hospital_code,pc.case_no,p.patient_type,pc.create_dtm,pc.create_by FROM (SELECT patient_key,'
            --     INTO var_sql;
            -- SELECT
            --     CONCAT(var_sql, 'min(create_dtm) create_dtm FROM (SELECT patient_key, create_dtm FROM pmi_case WHERE patient_key IN (SELECT patient_key')
            --     INTO var_sql;
            -- SELECT
            --     CONCAT(var_sql, ' FROM patient p WHERE ')
            --     INTO var_sql;
            SELECT 'SELECT p.hkid,old_hkid,k.system_dtm,old_patient_name,old_sex,old_dob,new_hkid,new_patient_name,new_sex,new_dob,k.update_by,hospital_code FROM patient_key_changed k,' INTO var_sql;
            SELECT CONCAT(var_sql, 'patient p WHERE (p.hkid = new_hkid OR p.hkid = old_hkid) AND ') INTO var_sql;

            IF par_ehr_pin_type = '2' THEN
                BEGIN
                    SELECT CONCAT(var_sql, '(p.hkid = $1 or p.hkid = '' '' || $1)') INTO var_sql;
                    -- SELECT
                    --     -- CONCAT(var_sql, '(p.hkid = @ehr_pin or p.hkid = '' '' + @ehr_pin))')
                    --     CONCAT(var_sql, '(p.hkid = @ehr_pin or p.hkid = '' '' + @ehr_pin)')
                    --     INTO var_sql;
                END;
            END IF;

            IF par_ehr_pin_type = '3' THEN
                BEGIN
                    SELECT CONCAT(var_sql, 'p.other_doc_no = $1') INTO var_sql;
                    -- SELECT
                    --     CONCAT(var_sql, 'other_doc_no = @ehr_pin)')
                    --     INTO var_sql;
                END;
            END IF;

            IF par_ehr_pin_type = '1' THEN
                BEGIN
                    IF "var_isEhrPatient" = 1 THEN
                        BEGIN
                            SELECT CONCAT(var_sql, 'p.patient_key = $2') INTO var_sql;
                            -- SELECT
                            --     CONCAT(var_sql, 'patient_key = @pas_pky)')
                            --     INTO var_sql;
                        END;
                    ELSE
                        BEGIN
                            SELECT CONCAT(var_sql, ' 1 = 0') INTO var_sql;
                            -- SELECT
                            --     CONCAT(var_sql, ' 1 = 0)')
                            --     INTO var_sql;
                        END;
                    END IF;
                END;
            END IF;
            -- SELECT
            --     CONCAT(var_sql, ')a GROUP BY patient_key) pm, pmi_case pc,patient p WHERE pc.patient_key=pm.patient_key AND pc.create_dtm = pm.create_dtm')
            --     INTO var_sql;
            -- SELECT
            --     CONCAT(var_sql, ' AND pc.patient_key=p.patient_key')
            --     INTO var_sql;
            /*
            [3031 - Severity CRITICAL - Automatic conversion of this command is not supported. Perform a manual conversion.]
            exec (@sql)
            */
            SELECT CONCAT(var_sql, ' ORDER BY system_dtm') INTO var_sql;
            raise notice '[4]par_ehr_pin_type=%,par_ehr_pin=%,var_pas_pky=%,var_sql=%',par_ehr_pin_type,par_ehr_pin,var_pas_pky,var_sql;
            OPEN p_refcur_6 FOR
                EXECUTE var_sql USING par_ehr_pin, var_pas_pky;
            
            -- SELECT
            --     'SELECT p.hkid,old_hkid,k.system_dtm,old_patient_name,old_sex,old_dob,new_hkid,new_patient_name,new_sex,new_dob,k.update_by,hospital_code FROM patient_key_changed k,'
            --     INTO var_sql;
            -- SELECT
            --     CONCAT(var_sql, 'patient p WHERE (p.hkid = new_hkid OR p.hkid = old_hkid) AND ')
            --     INTO var_sql;

            -- IF par_ehr_pin_type = '2' THEN
            --     BEGIN
            --         SELECT
            --             CONCAT(var_sql, '(p.hkid = @ehr_pin or p.hkid = '' '' + @ehr_pin)')
            --             INTO var_sql;
            --     END;
            -- END IF;
            IF par_ehr_pin_type = '2' THEN
                BEGIN
                    IF EXISTS (SELECT
                        1
                        FROM patient
                        WHERE hkid = par_ehr_pin OR hkid = CONCAT(' ', par_ehr_pin)) THEN
                        BEGIN
                            SELECT
                                patient_key
                                INTO var_pas_pky
                                FROM patient
                                WHERE hkid = par_ehr_pin OR hkid = CONCAT(' ', par_ehr_pin);
                        END;
                    ELSE
                        BEGIN
                            SELECT
                                NULL
                                INTO var_pas_pky;
                        END;
                    END IF;
                END;
            END IF;

            -- IF par_ehr_pin_type = '3' THEN
            --     BEGIN
            --         SELECT
            --             CONCAT(var_sql, 'p.other_doc_no = @ehr_pin')
            --             INTO var_sql;
            --     END;
            -- END IF;
            IF par_ehr_pin_type = '3' THEN
                BEGIN
                    IF EXISTS (SELECT
                        1
                        FROM patient
                        WHERE other_doc_no = par_ehr_pin) THEN
                        BEGIN
                            SELECT
                                patient_key
                                INTO var_pas_pky
                                FROM patient
                                WHERE other_doc_no = par_ehr_pin;
                        END;
                    ELSE
                        BEGIN
                            SELECT
                                NULL
                                INTO var_pas_pky;
                        END;
                    END IF;
                END;
            END IF;

            -- IF par_ehr_pin_type = '1' THEN
            --     BEGIN
            --         IF "var_isEhrPatient" = 1 THEN
            --             BEGIN
            --                 SELECT
            --                     CONCAT(var_sql, 'p.patient_key = @pas_pky')
            --                     INTO var_sql;
            --             END;
            --         ELSE
            --             BEGIN
            --                 SELECT
            --                     CONCAT(var_sql, ' 1 = 0')
            --                     INTO var_sql;
            --             END;
            --         END IF;
            --     END;
            -- END IF;
            -- SELECT
            --     CONCAT(var_sql, ' ORDER BY system_dtm')
            --     INTO var_sql;
            /*
            [3031 - Severity CRITICAL - Automatic conversion of this command is not supported. Perform a manual conversion.]
            exec (@sql)
            */
            -- execute var_sql;
            -- SELECT
            --     'SELECT p.hkid,m.hkid AS mhkid,mother_hospital_code,baby_hospital_code,mother_case_no,pc.case_no FROM patient p,pmi_case pc,mother_baby_case c,pmi_case mc,patient m WHERE '
            --     INTO var_sql;

            -- IF par_ehr_pin_type = '2' THEN
            --     BEGIN
            --         SELECT
            --             CONCAT(var_sql, '(p.hkid = @ehr_pin or p.hkid = '' '' + @ehr_pin)')
            --             INTO var_sql;
            --     END;
            -- END IF;

            -- IF par_ehr_pin_type = '3' THEN
            --     BEGIN
            --         SELECT
            --             CONCAT(var_sql, 'p.other_doc_no = @ehr_pin')
            --             INTO var_sql;
            --     END;
            -- END IF;

            -- IF par_ehr_pin_type = '1' THEN
            --     BEGIN
            --         IF "var_isEhrPatient" = 1 THEN
            --             BEGIN
            --                 SELECT
            --                     CONCAT(var_sql, 'p.patient_key = @pas_pky')
            --                     INTO var_sql;
            --             END;
            --         ELSE
            --             BEGIN
            --                 SELECT
            --                     CONCAT(var_sql, ' 1 = 0')
            --                     INTO var_sql;
            --             END;
            --         END IF;
            --     END;
            -- END IF;
            -- SELECT
            --     CONCAT(var_sql, ' AND p.patient_key = pc.patient_key AND pc.case_no =baby_case_no AND mother_case_no = mc.case_no AND m.patient_key = mc.patient_key')
            --     INTO var_sql;
            /*
            [3031 - Severity CRITICAL - Automatic conversion of this command is not supported. Perform a manual conversion.]
            exec (@sql)
            */
            -- execute var_sql;
            IF par_ehr_pin_type = '1' THEN
                BEGIN
                    IF "var_isEhrPatient" <> 1 THEN
                        BEGIN
                            SELECT
                                NULL
                                INTO var_pas_pky;
                        END;
                    END IF;
                END;
            END IF;

            IF var_pas_pky IS NOT NULL THEN
                BEGIN
                    IF EXISTS (SELECT
                        1
                        FROM patient AS m, pmi_case AS mc, mother_baby_case AS c
                        WHERE m.patient_key = mc.patient_key AND m.patient_key = var_pas_pky AND c.mother_case_no = mc.case_no) THEN
                        BEGIN
                            DROP TABLE IF EXISTS t$tmp1;
                            DROP TABLE IF EXISTS t$tmp2;
                            CREATE TEMPORARY TABLE t$tmp1
                            AS
                            SELECT
                                bc.patient_key, m.hkid AS mhkid, mother_hospital_code, baby_hospital_code, mother_case_no, baby_case_no
                                FROM patient AS m, pmi_case AS mc, mother_baby_case AS mbc, pmi_case AS bc
                                WHERE m.patient_key = mc.patient_key AND m.patient_key = var_pas_pky AND mbc.mother_case_no = mc.case_no AND bc.case_no = baby_case_no AND bc.hospital_code = baby_hospital_code;
                            CREATE TEMPORARY TABLE t$tmp2
                            AS
                            SELECT DISTINCT
                                bc.patient_key
                                FROM patient AS m, pmi_case AS mc, mother_baby_case AS mbc, pmi_case AS bc
                                WHERE m.patient_key = mc.patient_key AND m.patient_key = var_pas_pky AND mbc.mother_case_no = mc.case_no AND bc.case_no = baby_case_no AND bc.hospital_code = baby_hospital_code;
                            OPEN p_refcur_7 FOR
                            SELECT
                                a.hkid, mhkid, mother_hospital_code, baby_hospital_code, mother_case_no, baby_case_no AS case_no
                                FROM (SELECT
                                    p.hkid, p.patient_key
                                    FROM t$tmp2, patient AS p
                                    WHERE t$tmp2.patient_key = p.patient_key) AS a, t$tmp1
                                WHERE a.patient_key = t$tmp1.patient_key;
                            
                        END;
                    ELSE
                        BEGIN
                            OPEN p_refcur_7 FOR
                            SELECT
                                '' AS hkid, '' AS mhkid, mother_hospital_code, baby_hospital_code, mother_case_no, baby_case_no AS case_no
                                FROM mother_baby_case
                                WHERE 1 = 0;
                            
                        END;
                    END IF;
                END;
            ELSE
                BEGIN
                    OPEN p_refcur_7 FOR
                    SELECT
                        '' AS hkid, '' AS mhkid, mother_hospital_code, baby_hospital_code, mother_case_no, baby_case_no AS case_no
                        FROM mother_baby_case
                        WHERE 1 = 0;
                    
                END;
            END IF;
        END;
    END IF;
    /* --------------------------------------------------------------------------------- */
    /* rpt_type 3 :   Gen Report */
    
    /* --------------------------------------------------------------------------------- */
    IF par_rpt_type = 'GEN' THEN
        BEGIN
            SELECT
                localtimestamp
                INTO var_report_date;

            IF (par_rpt_id = '1') THEN
                BEGIN
                    BEGIN
                        OPEN p_refcur_8 FOR
                        SELECT
                            REPLACE(to_char(var_report_date::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-') AS report_date, 1 AS report_id, code_field AS rpt_f1, code_field_full_desc AS rpt_f2,
                            CASE CAST (COALESCE(ehr_cnt, 0) AS VARCHAR)
                                WHEN '' THEN ''
                                ELSE CAST (COALESCE(ehr_cnt, 0) AS VARCHAR)
                            END AS rpt_f3,
                            CASE CAST (COALESCE(ppi_cnt, 0) AS VARCHAR)
                                WHEN '' THEN ''
                                ELSE CAST (COALESCE(ppi_cnt, 0) AS VARCHAR)
                            END AS rpt_f4,
                            CASE CAST (CASE
                                WHEN code_field = 'VAL' THEN 1
                                WHEN code_field = 'NID' THEN 2
                                WHEN code_field = 'MKD' THEN 3
                                WHEN code_field = 'MES' THEN 4
                                WHEN code_field = 'MKU' THEN 5
                                WHEN code_field = 'MKC' THEN 6
                                WHEN code_field = 'MKE' THEN 7
                                WHEN code_field = 'MKP' THEN 8
                                WHEN code_field = 'MKM' THEN 9
                                WHEN code_field = 'WHD' THEN 10
                                WHEN code_field = 'DDR' THEN 11
                                WHEN code_field = 'MID' THEN 12
                                WHEN code_field = 'MIC' THEN 13
                                WHEN code_field = 'MIE' THEN 14
                                WHEN code_field = 'MIM' THEN 15
                                WHEN code_field = 'MIP' THEN 16
                                WHEN code_field = 'MIU' THEN 17
                            END AS VARCHAR)
                                WHEN '' THEN ''
                                ELSE CAST (CASE
                                    WHEN code_field = 'VAL' THEN 1
                                    WHEN code_field = 'NID' THEN 2
                                    WHEN code_field = 'MKD' THEN 3
                                    WHEN code_field = 'MES' THEN 4
                                    WHEN code_field = 'MKU' THEN 5
                                    WHEN code_field = 'MKC' THEN 6
                                    WHEN code_field = 'MKE' THEN 7
                                    WHEN code_field = 'MKP' THEN 8
                                    WHEN code_field = 'MKM' THEN 9
                                    WHEN code_field = 'WHD' THEN 10
                                    WHEN code_field = 'DDR' THEN 11
                                    WHEN code_field = 'MID' THEN 12
                                    WHEN code_field = 'MIC' THEN 13
                                    WHEN code_field = 'MIE' THEN 14
                                    WHEN code_field = 'MIM' THEN 15
                                    WHEN code_field = 'MIP' THEN 16
                                    WHEN code_field = 'MIU' THEN 17
                                END AS VARCHAR)
                            END AS rpt_f5, NULL AS rpt_f6, NULL AS rpt_f7, NULL AS rpt_f8, NULL AS rpt_f9, NULL AS rpt_f10, NULL AS rpt_f11, NULL AS rpt_f12, NULL AS rpt_f13, NULL AS rpt_f14, NULL AS rpt_f15, NULL AS rpt_f16, NULL AS rpt_f17, NULL AS rpt_f18, NULL AS rpt_f19, NULL AS rpt_f20, NULL AS rpt_f21, NULL AS rpt_f22, NULL AS rpt_f23, NULL AS rpt_f24, NULL AS rpt_f25, NULL AS rpt_f26, NULL AS rpt_f27, NULL AS rpt_f28, NULL AS rpt_f29, NULL AS rpt_f30, NULL AS rpt_f31, NULL AS rpt_f32
                            FROM ehr_code_table AS t
                            LEFT OUTER JOIN (SELECT
                                ehr_flag, SUM(CASE ehr_ppi_ind
                                    WHEN 'Y' THEN 1
                                    ELSE 0
                                END) AS ehr_cnt, SUM(CASE ehr_ppi_ind
                                    WHEN 'Y' THEN 0
                                    ELSE 1
                                END) AS ppi_cnt
                                FROM ehr_patient_list
                                GROUP BY ehr_flag) AS plist
                                ON t.code_field = plist.ehr_flag
                            WHERE t.code_type = 'EHR_FLAG' AND t.code_name = 'ehr_flag';
						
                        EXCEPTION
                            WHEN others THEN
                                BEGIN
                                    pas_return_code := 1;
                                    RETURN;
                                END;
                    END;
                END;
            END IF;

            IF (par_rpt_id = '2') THEN
                BEGIN
                    /* Adaptive Server has expanded all '*' elements in the following statement */
                    -- CREATE TEMPORARY TABLE t$tmp_2
                    -- AS
                    -- SELECT
                    --     t.evt_txn_dtm, t.evt_txn_type, t.evt_code, t.evt_log_type, t.evt_msg_no, t.evt_ack, t.ehr_flag, t.ehr_number, t.ehr_start_date, t.ehr_end_date, t.ehr_hkic, t.ehr_surname, t.ehr_givenname, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.ehr_doc_type, t.ehr_doc_no, t.ehr_death_date, t.ehr_death_time, t.ehr_exact_death, t.ehr_death_ind, t.old_ehr_number, t.old_ehr_flag, t.old_ehr_hkic, t.old_ehr_surname, t.old_ehr_givenname, t.old_ehr_full_name, t.old_ehr_sex, t.old_ehr_dob, t.old_ehr_exact_dob, t.old_ehr_doc_type, t.old_ehr_doc_no, t.pas_hosp, t.pas_hkic, t.pas_pky, t.pas_case, t.pas_surname, t.pas_givenname, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob, t.pas_doc_type, t.pas_doc_no, t.pas_death_date, t.pas_death_time, t.pas_exact_death, t.pas_death_ind, t.old_pas_hkic, t.old_pas_pky, t.old_pas_surname, t.old_pas_givenname, t.old_pas_full_name, t.old_pas_sex, t.old_pas_dob, t.old_pas_exact_dob, t.old_pas_doc_type, t.old_pas_doc_no, t.upd_by, t.upd_sys, t.upd_hosp, t.upd_host, t.sys_dtm, t.ehr_ppi_ind, t.ehr_non_ha_ind, t.ehr_status, t.old_ehr_ppi_ind, t.old_ehr_non_ha_ind, t.old_ehr_status
                    --     FROM ehr_patient_list AS p, ehr_event_txn AS t
                    --     WHERE p.ehr_flag = 'NID' AND p.ehr_ppi_ind = 'Y' AND p.ehr_doc_type NOT IN ('ID', 'BC') AND p.ehr_number = t.ehr_number AND t.ehr_flag = 'NID' AND evt_txn_type IN ('ENT', 'MKC') AND t.sys_dtm BETWEEN
                    --     CASE par_rpt_start_dtm
                    --         WHEN NULL THEN '19700101'
                    --         ELSE par_rpt_start_dtm
                    --     END AND
                    --     CASE par_rpt_end_dtm
                    --         WHEN NULL THEN localtimestamp
                    --         ELSE par_rpt_end_dtm
                    --     END;
                    -- CREATE TEMPORARY TABLE t$tmp_2_1
                    -- AS
                    -- SELECT
                    --     max_evt_txn, uponafter, t.ehr_start_date, t.ehr_number, t.ehr_doc_type, t.ehr_doc_no, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.ehr_full_name
                    --     FROM (SELECT
                    --         ungrouped_query.ehr_number, min_1 AS min_evt_txn, max_1 AS max_evt_txn, ungrouped_query.uponafter
                    --         FROM (SELECT
                    --             ehr_number,
                    --             CASE MIN(evt_txn_dtm)
                    --                 WHEN MAX(evt_txn_dtm) THEN 1
                    --                 ELSE 0
                    --             END AS uponafter
                    --             FROM t$tmp_2) AS ungrouped_query
                    --         INNER JOIN (SELECT
                    --             ehr_number, MIN(evt_txn_dtm) AS min_1, MAX(evt_txn_dtm) AS max_1
                    --             FROM t$tmp_2
                    --             GROUP BY ehr_number) AS grouped_query
                    --             ON (ungrouped_query.ehr_number = grouped_query.ehr_number OR (ungrouped_query.ehr_number IS NULL AND grouped_query.ehr_number IS NULL))) AS p, ehr_event_txn AS t
                    --     WHERE p.ehr_number = t.ehr_number AND p.max_evt_txn = t.evt_txn_dtm AND t.ehr_flag = 'NID' AND evt_txn_type IN ('ENT', 'MKC');
                    -- OPEN p_refcur FOR
                    -- SELECT
                    --     REPLACE(to_char(var_report_date::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-') AS report_date, 2 AS report_id, 'NID' AS rpt_f1, ehr_number AS rpt_f2,
                    --     CASE uponafter
                    --         WHEN 1 THEN 'UPON'
                    --         ELSE 'AFTER'
                    --     END AS rpt_f3,
					-- 	COALESCE(REPLACE(TO_CHAR(ehr_start_date, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f4,
                    --     COALESCE(CONCAT(REPLACE(to_char(max_evt_txn::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char( max_evt_txn::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A') AS rpt_f5, ehr_doc_type AS rpt_f6, ehr_doc_no AS rpt_f7, ehr_full_name AS rpt_f8, ehr_sex AS rpt_f9,
                       
					-- 	COALESCE(REPLACE(TO_CHAR(ehr_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f10,
                    --     ehr_exact_dob AS rpt_f11, hkid AS rpt_f12, d.document_type AS rpt_f13, other_doc_no AS rpt_f14, patient_name AS rpt_f15, sex AS rpt_f16, COALESCE(REPLACE(to_char(dob::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f17, exact_dob_flag AS rpt_f18, NULL AS rpt_f19, NULL AS rpt_f20, NULL AS rpt_f21, NULL AS rpt_f22, NULL AS rpt_f23, NULL AS rpt_f24, NULL AS rpt_f25, NULL AS rpt_f26, NULL AS rpt_f27, NULL AS rpt_f28, NULL AS rpt_f29, NULL AS rpt_f30, NULL AS rpt_f31, NULL AS rpt_f32
                    --     FROM t$tmp_2_1, patient AS p, document_type AS d
                    --     WHERE t$tmp_2_1.ehr_number IN (SELECT
                    --         ehr_number
                    --         FROM t$tmp_2 AS a, patient AS p, document_type AS d
                    --         WHERE UPPER(ehr_doc_no) = p.other_doc_no AND SUBSTRING(p.filler, 1, 1) = d.document_code AND a.ehr_doc_type =
                    --         CASE d.document_type
                    --             WHEN 'AE' THEN 'AR'
                    --             WHEN 'AN' THEN 'AR'
                    --             WHEN 'BE' THEN 'BC'
                    --             WHEN 'BN' THEN 'BC'
                    --             ELSE d.document_type
                    --         END
                    --         GROUP BY ehr_number
                    --         HAVING COUNT(ehr_number) > 1) AND UPPER(ehr_doc_no) = p.other_doc_no AND SUBSTRING(p.filler, 1, 1) = d.document_code AND t$tmp_2_1.ehr_doc_type =
                    --     CASE d.document_type
                    --         WHEN 'AE' THEN 'AR'
                    --         WHEN 'AN' THEN 'AR'
                    --         WHEN 'BE' THEN 'BC'
                    --         WHEN 'BN' THEN 'BC'
                    --         ELSE d.document_type
					
                    --     END;
					-- return next p_refcur;
                    -- DROP TABLE IF EXISTS t$tmp_2;
                    -- DROP TABLE IF EXISTS t$tmp_2_1;
                    OPEN p_refcur_8 FOR
                        SELECT REPLACE(TO_CHAR(CAST(var_report_date AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-') AS report_date
                            ,2 AS report_id
                            ,'NID' AS rpt_f1
                            ,z.ehr_number AS rpt_f2
                            ,CASE z.uponafter
                                WHEN 1 THEN 'UPON'
                                ELSE 'AFTER'
                            END AS rpt_f3
                            ,COALESCE(REPLACE(TO_CHAR(CAST(z.ehr_start_date AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f4
                            ,COALESCE(REPLACE(TO_CHAR(CAST(z.max_evt_txn AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-') || ' ' || TO_CHAR(z.max_evt_txn, 'HH24:MI:SS'), 'N/A') AS rpt_f5
                            ,z.ehr_doc_type AS rpt_f6
                            ,z.ehr_doc_no AS rpt_f7
                            ,z.ehr_full_name AS rpt_f8
                            ,z.ehr_sex AS rpt_f9
                            ,COALESCE(REPLACE(TO_CHAR(CAST(z.ehr_dob AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f10
                            ,z.ehr_exact_dob AS rpt_f11
                            ,p.hkid AS rpt_f12
                            ,d.document_type AS rpt_f13
                            ,p.other_doc_no AS rpt_f14
                            ,p.patient_name AS rpt_f15
                            ,p.sex AS rpt_f16
                            ,COALESCE(REPLACE(TO_CHAR(CAST(p.dob AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f17
                            ,p.exact_dob_flag AS rpt_f18
                            ,NULL AS rpt_f19
                            ,NULL AS rpt_f20
                            ,NULL AS rpt_f21
                            ,NULL AS rpt_f22
                            ,NULL AS rpt_f23
                            ,NULL AS rpt_f24
                            ,NULL AS rpt_f25
                            ,NULL AS rpt_f26
                            ,NULL AS rpt_f27
                            ,NULL AS rpt_f28
                            ,NULL AS rpt_f29
                            ,NULL AS rpt_f30
                            ,NULL AS rpt_f31
                            ,NULL AS rpt_f32
                        FROM (
                            SELECT max_evt_txn
                                ,uponafter
                                ,t.ehr_start_date
                                ,t.ehr_number
                                ,t.ehr_doc_type
                                ,t.ehr_doc_no
                                ,t.ehr_sex
                                ,t.ehr_dob
                                ,t.ehr_exact_dob
                                ,t.ehr_full_name
                            FROM (
                                SELECT ehr_number
                                    ,MIN(evt_txn_dtm) AS min_evt_txn
                                    ,MAX(evt_txn_dtm) AS max_evt_txn
                                    ,CASE MIN(evt_txn_dtm)
                                        WHEN MAX(evt_txn_dtm) THEN 1
                                        ELSE 0
                                    END AS uponafter
                                FROM (
                                    SELECT t.evt_txn_dtm
                                        ,t.evt_txn_type
                                        ,t.evt_code
                                        ,t.evt_log_type
                                        ,t.ehr_number
                                        ,t.ehr_hkic
                                        ,t.ehr_doc_type
                                        ,t.ehr_doc_no
                                    FROM ehr_patient_list p, ehr_event_txn t
                                    WHERE p.ehr_flag = 'NID'
                                        AND p.ehr_ppi_ind = 'Y'
                                        AND p.ehr_doc_type NOT IN ('ID', 'BC')
                                        AND p.ehr_number = t.ehr_number
                                        AND t.ehr_flag = 'NID'
                                        AND t.evt_txn_type IN ('ENT', 'MKC')
                                        AND t.sys_dtm BETWEEN COALESCE(par_rpt_start_dtm, '1970-01-01'::TIMESTAMP)
                                            AND COALESCE(par_rpt_end_dtm, CURRENT_TIMESTAMP)
                                ) tmp
                                GROUP BY ehr_number
                            ) p, ehr_event_txn t
                            WHERE p.ehr_number = t.ehr_number
                                AND p.max_evt_txn = t.evt_txn_dtm
                                AND t.ehr_flag = 'NID'
                                AND t.evt_txn_type IN ('ENT', 'MKC')
                        ) z, patient p, document_type d
                        WHERE z.ehr_number IN (
                            SELECT ehr_number
                            FROM (
                                SELECT t.evt_txn_dtm
                                    ,t.evt_txn_type
                                    ,t.evt_code
                                    ,t.evt_log_type
                                    ,t.ehr_number
                                    ,t.ehr_hkic
                                    ,t.ehr_doc_type
                                    ,t.ehr_doc_no
                                FROM ehr_patient_list p, ehr_event_txn t
                                WHERE p.ehr_flag = 'NID'
                                    AND p.ehr_ppi_ind = 'Y'
                                    AND p.ehr_doc_type NOT IN ('ID', 'BC')
                                    AND p.ehr_number = t.ehr_number
                                    AND t.ehr_flag = 'NID'
                                    AND t.evt_txn_type IN ('ENT', 'MKC')
                                    AND t.sys_dtm BETWEEN COALESCE(par_rpt_start_dtm, '1970-01-01'::TIMESTAMP)
                                        AND COALESCE(par_rpt_end_dtm, CURRENT_TIMESTAMP)
                            ) a, patient p, document_type d
                            WHERE UPPER(a.ehr_doc_no) = p.other_doc_no
                                AND SUBSTRING(p.filler, 1, 1) = d.document_code
                                AND a.ehr_doc_type = CASE d.document_type
                                    WHEN 'AE' THEN 'AR'
                                    WHEN 'AN' THEN 'AR'
                                    WHEN 'BE' THEN 'BC'
                                    WHEN 'BN' THEN 'BC'
                                    ELSE d.document_type
                                END
                            GROUP BY ehr_number
                            HAVING COUNT(ehr_number) > 1
                        )
                        AND UPPER(z.ehr_doc_no) = p.other_doc_no
                        AND SUBSTRING(p.filler, 1, 1) = d.document_code
                        AND z.ehr_doc_type = CASE d.document_type
                            WHEN 'AE' THEN 'AR'
                            WHEN 'AN' THEN 'AR'
                            WHEN 'BE' THEN 'BC'
                            WHEN 'BN' THEN 'BC'
                            ELSE d.document_type
                        END;
                        
                END;
            END IF;

            IF (par_rpt_id = '3') THEN
                BEGIN
                    -- CREATE TEMPORARY TABLE t$tmp_3
                    -- AS
                    -- SELECT
                    --     t.evt_txn_dtm, t.ehr_flag, t.ehr_number, t.ehr_start_date, 'N/A' AS update_dtm, 'N/A' AS update_by, t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob
                    --     FROM ehr_event_txn AS t, ehr_patient_list AS p
                    --     WHERE t.ehr_flag = 'MKD' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
                    -- UNION
                    -- SELECT
                    --     t.evt_txn_dtm, t.ehr_flag, t.ehr_number, t.ehr_start_date, COALESCE(CONCAT(REPLACE(to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A'), 'eHR', t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob
                    --     FROM ehr_event_txn AS t, ehr_patient_list AS p
                    --     WHERE t.ehr_flag = 'MKU' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
                    -- UNION
                    -- SELECT
                    --     t.evt_txn_dtm, t.ehr_flag, t.ehr_number, t.ehr_start_date, COALESCE(CONCAT(REPLACE(to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A'), 'HA', t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob
                    --     FROM ehr_event_txn AS t, ehr_patient_list AS p
                    --     WHERE t.ehr_flag = 'MKC' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
                    -- UNION
                    -- SELECT
                    --     t.evt_txn_dtm, t.ehr_flag, t.ehr_number, t.ehr_start_date, COALESCE(CONCAT(REPLACE(to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A'), 'eHR', t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob
                    --     FROM ehr_event_txn AS t, ehr_patient_list AS p
                    --     WHERE t.ehr_flag = 'MKE' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
                    -- UNION
                    -- SELECT
                    --     t.evt_txn_dtm, t.ehr_flag, t.ehr_number, t.ehr_start_date, COALESCE(CONCAT(REPLACE(to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A'), 'HA', t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob
                    --     FROM ehr_event_txn AS t, ehr_patient_list AS p
                    --     WHERE t.ehr_flag = 'MKP' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
                    -- UNION
                    -- SELECT
                    --     t.evt_txn_dtm, t.ehr_flag, t.ehr_number, t.ehr_start_date, COALESCE(CONCAT(REPLACE(to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A'),
                    --     CASE evt_log_type
                    --         WHEN 'T' THEN 'HA'
                    --         ELSE 'eHR'
                    --     END, t.ehr_hkic, t.ehr_doc_type, t.ehr_doc_no, t.ehr_full_name, t.ehr_sex, t.ehr_dob, t.ehr_exact_dob, t.pas_hkic, t.pas_doc_type, t.pas_doc_no, t.pas_full_name, t.pas_sex, t.pas_dob, t.pas_exact_dob
                    --     FROM ehr_event_txn AS t, ehr_patient_list AS p
                    --     WHERE t.ehr_flag = 'MKM' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y';
                    -- CREATE TEMPORARY TABLE t$tmp_3_1
                    -- AS
                    -- SELECT
                    --     ehr_number, MAX(evt_txn_dtm) AS evt_txn_dtm
                    --     FROM t$tmp_3
                    --     WHERE evt_txn_dtm BETWEEN
                    --     CASE par_rpt_start_dtm
                    --         WHEN NULL THEN '19700101'
                    --         ELSE par_rpt_start_dtm
                    --     END AND
                    --     CASE par_rpt_end_dtm
                    --         WHEN NULL THEN localtimestamp
                    --         ELSE par_rpt_end_dtm
                    --     END
                    --     GROUP BY ehr_number;
                    -- OPEN p_refcur FOR
                    -- SELECT
                    --     REPLACE(to_char(var_report_date::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-') AS report_date, 3 AS report_id, t.ehr_flag AS rpt_f1, t.ehr_number AS rpt_f2,
                     
					-- 	COALESCE(REPLACE(TO_CHAR(t.ehr_start_date, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f3,
                    --     t."update_dtm" AS rpt_f4, t."update_by" AS rpt_f5, t.ehr_hkic AS rpt_f6, t.ehr_doc_type AS rpt_f7, t.ehr_doc_no AS rpt_f8, t.ehr_full_name AS rpt_f9, t.ehr_sex AS rpt_f10,
                     
					-- 	COALESCE(REPLACE(TO_CHAR(t.ehr_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f11,
                    --     t.ehr_exact_dob AS rpt_f12, t.pas_hkic AS rpt_f13, t.pas_doc_type AS rpt_f14, t.pas_doc_no AS rpt_f15, t.pas_full_name AS rpt_f16, t.pas_sex AS rpt_f17,
                        
					-- 	 COALESCE(REPLACE(TO_CHAR(t.pas_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f18,
                    --     t.pas_exact_dob AS rpt_f19, NULL AS rpt_f20, NULL AS rpt_f21, NULL AS rpt_f22, NULL AS rpt_f23, NULL AS rpt_f24, NULL AS rpt_f25, NULL AS rpt_f26, NULL AS rpt_f27, NULL AS rpt_f28, NULL AS rpt_f29, NULL AS rpt_f30, NULL AS rpt_f31, NULL AS rpt_f32
                    --     FROM t$tmp_3 AS t, t$tmp_3_1 AS p
                    --     WHERE t.ehr_number = p.ehr_number AND t.evt_txn_dtm = p."evt_txn_dtm";
                    -- 
                    -- DROP TABLE IF EXISTS t$tmp_3;
                    -- DROP TABLE IF EXISTS t$tmp_3_1;
                    OPEN p_refcur_8 FOR
                        SELECT REPLACE(TO_CHAR(CAST(var_report_date AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-') AS report_date
                            ,3 AS report_id
                            ,t.ehr_flag AS rpt_f1
                            ,t.ehr_number AS rpt_f2
                            ,COALESCE(REPLACE(TO_CHAR(CAST(t.ehr_start_date AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f3
                            ,t.update_dtm AS rpt_f4
                            ,t.update_by AS rpt_f5
                            ,t.ehr_hkic AS rpt_f6
                            ,t.ehr_doc_type AS rpt_f7
                            ,t.ehr_doc_no AS rpt_f8
                            ,t.ehr_full_name AS rpt_f9
                            ,t.ehr_sex AS rpt_f10
                            ,COALESCE(REPLACE(TO_CHAR(CAST(t.ehr_dob AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f11
                            ,t.ehr_exact_dob AS rpt_f12
                            ,t.pas_hkic AS rpt_f13
                            ,t.pas_doc_type AS rpt_f14
                            ,t.pas_doc_no AS rpt_f15
                            ,t.pas_full_name AS rpt_f16
                            ,t.pas_sex AS rpt_f17
                            ,COALESCE(REPLACE(TO_CHAR(CAST(t.pas_dob AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f18
                            ,t.pas_exact_dob AS rpt_f19
                            ,NULL AS rpt_f20
                            ,NULL AS rpt_f21
                            ,NULL AS rpt_f22
                            ,NULL AS rpt_f23
                            ,NULL AS rpt_f24
                            ,NULL AS rpt_f25
                            ,NULL AS rpt_f26
                            ,NULL AS rpt_f27
                            ,NULL AS rpt_f28
                            ,NULL AS rpt_f29
                            ,NULL AS rpt_f30
                            ,NULL AS rpt_f31
                            ,NULL AS rpt_f32
                        FROM (
                            -- MKD records
                            SELECT t.evt_txn_dtm
                                ,t.ehr_flag
                                ,t.ehr_number
                                ,t.ehr_start_date
                                ,'N/A' AS update_dtm
                                ,'N/A' AS update_by
                                ,t.ehr_hkic
                                ,t.ehr_doc_type
                                ,t.ehr_doc_no
                                ,t.ehr_full_name
                                ,t.ehr_sex
                                ,t.ehr_dob
                                ,t.ehr_exact_dob
                                ,t.pas_hkic
                                ,t.pas_doc_type
                                ,t.pas_doc_no
                                ,t.pas_full_name
                                ,t.pas_sex
                                ,t.pas_dob
                                ,t.pas_exact_dob
                            FROM ehr_event_txn t, ehr_patient_list p
                            WHERE t.ehr_flag = 'MKD'
                                AND t.ehr_number = p.ehr_number
                                AND p.ehr_ppi_ind = 'Y'
                            
                            UNION
                            
                            -- MKU records
                            SELECT t.evt_txn_dtm
                                ,t.ehr_flag
                                ,t.ehr_number
                                ,t.ehr_start_date
                                ,COALESCE(REPLACE(TO_CHAR(t.evt_txn_dtm, 'DD Mon YYYY'), ' ', '-') || ' ' || TO_CHAR(t.evt_txn_dtm, 'HH24:MI:SS'), 'N/A')
                                ,'eHR'
                                ,t.ehr_hkic
                                ,t.ehr_doc_type
                                ,t.ehr_doc_no
                                ,t.ehr_full_name
                                ,t.ehr_sex
                                ,t.ehr_dob
                                ,t.ehr_exact_dob
                                ,t.pas_hkic
                                ,t.pas_doc_type
                                ,t.pas_doc_no
                                ,t.pas_full_name
                                ,t.pas_sex
                                ,t.pas_dob
                                ,t.pas_exact_dob
                            FROM ehr_event_txn t, ehr_patient_list p
                            WHERE t.ehr_flag = 'MKU'
                                AND t.ehr_number = p.ehr_number
                                AND p.ehr_ppi_ind = 'Y'
                            
                            UNION
                            
                            -- MKC records
                            SELECT t.evt_txn_dtm
                                ,t.ehr_flag
                                ,t.ehr_number
                                ,t.ehr_start_date
                                ,COALESCE(REPLACE(TO_CHAR(t.evt_txn_dtm, 'DD Mon YYYY'), ' ', '-') || ' ' || TO_CHAR(t.evt_txn_dtm, 'HH24:MI:SS'), 'N/A')
                                ,'HA'
                                ,t.ehr_hkic
                                ,t.ehr_doc_type
                                ,t.ehr_doc_no
                                ,t.ehr_full_name
                                ,t.ehr_sex
                                ,t.ehr_dob
                                ,t.ehr_exact_dob
                                ,t.pas_hkic
                                ,t.pas_doc_type
                                ,t.pas_doc_no
                                ,t.pas_full_name
                                ,t.pas_sex
                                ,t.pas_dob
                                ,t.pas_exact_dob
                            FROM ehr_event_txn t, ehr_patient_list p
                            WHERE t.ehr_flag = 'MKC'
                                AND t.ehr_number = p.ehr_number
                                AND p.ehr_ppi_ind = 'Y'
                            
                            UNION
                            
                            -- MKE records
                            SELECT t.evt_txn_dtm
                                ,t.ehr_flag
                                ,t.ehr_number
                                ,t.ehr_start_date
                                ,COALESCE(REPLACE(TO_CHAR(t.evt_txn_dtm, 'DD Mon YYYY'), ' ', '-') || ' ' || TO_CHAR(t.evt_txn_dtm, 'HH24:MI:SS'), 'N/A')
                                ,'eHR'
                                ,t.ehr_hkic
                                ,t.ehr_doc_type
                                ,t.ehr_doc_no
                                ,t.ehr_full_name
                                ,t.ehr_sex
                                ,t.ehr_dob
                                ,t.ehr_exact_dob
                                ,t.pas_hkic
                                ,t.pas_doc_type
                                ,t.pas_doc_no
                                ,t.pas_full_name
                                ,t.pas_sex
                                ,t.pas_dob
                                ,t.pas_exact_dob
                            FROM ehr_event_txn t, ehr_patient_list p
                            WHERE t.ehr_flag = 'MKE'
                                AND t.ehr_number = p.ehr_number
                                AND p.ehr_ppi_ind = 'Y'
                            
                            UNION
                            
                            -- MKP records
                            SELECT t.evt_txn_dtm
                                ,t.ehr_flag
                                ,t.ehr_number
                                ,t.ehr_start_date
                                ,COALESCE(REPLACE(TO_CHAR(t.evt_txn_dtm, 'DD Mon YYYY'), ' ', '-') || ' ' || TO_CHAR(t.evt_txn_dtm, 'HH24:MI:SS'), 'N/A')
                                ,'HA'
                                ,t.ehr_hkic
                                ,t.ehr_doc_type
                                ,t.ehr_doc_no
                                ,t.ehr_full_name
                                ,t.ehr_sex
                                ,t.ehr_dob
                                ,t.ehr_exact_dob
                                ,t.pas_hkic
                                ,t.pas_doc_type
                                ,t.pas_doc_no
                                ,t.pas_full_name
                                ,t.pas_sex
                                ,t.pas_dob
                                ,t.pas_exact_dob
                            FROM ehr_event_txn t, ehr_patient_list p
                            WHERE t.ehr_flag = 'MKP'
                                AND t.ehr_number = p.ehr_number
                                AND p.ehr_ppi_ind = 'Y'
                            
                            UNION
                            
                            -- MKM records
                            SELECT t.evt_txn_dtm
                                ,t.ehr_flag
                                ,t.ehr_number
                                ,t.ehr_start_date
                                ,COALESCE(REPLACE(TO_CHAR(t.evt_txn_dtm, 'DD Mon YYYY'), ' ', '-') || ' ' || TO_CHAR(t.evt_txn_dtm, 'HH24:MI:SS'), 'N/A')
                                ,CASE t.evt_log_type
                                    WHEN 'T' THEN 'HA'
                                    ELSE 'eHR'
                                END
                                ,t.ehr_hkic
                                ,t.ehr_doc_type
                                ,t.ehr_doc_no
                                ,t.ehr_full_name
                                ,t.ehr_sex
                                ,t.ehr_dob
                                ,t.ehr_exact_dob
                                ,t.pas_hkic
                                ,t.pas_doc_type
                                ,t.pas_doc_no
                                ,t.pas_full_name
                                ,t.pas_sex
                                ,t.pas_dob
                                ,t.pas_exact_dob
                            FROM ehr_event_txn t, ehr_patient_list p
                            WHERE t.ehr_flag = 'MKM'
                                AND t.ehr_number = p.ehr_number
                                AND p.ehr_ppi_ind = 'Y'
                        ) t, (
                            SELECT ehr_number, MAX(evt_txn_dtm) AS evt_txn_dtm
                            FROM (
                                -- Duplicate the same UNION logic for the subquery
                                SELECT t.evt_txn_dtm, t.ehr_number
                                FROM ehr_event_txn t, ehr_patient_list p
                                WHERE t.ehr_flag = 'MKD' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
                                UNION
                                SELECT t.evt_txn_dtm, t.ehr_number
                                FROM ehr_event_txn t, ehr_patient_list p
                                WHERE t.ehr_flag = 'MKU' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
                                UNION
                                SELECT t.evt_txn_dtm, t.ehr_number
                                FROM ehr_event_txn t, ehr_patient_list p
                                WHERE t.ehr_flag = 'MKC' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
                                UNION
                                SELECT t.evt_txn_dtm, t.ehr_number
                                FROM ehr_event_txn t, ehr_patient_list p
                                WHERE t.ehr_flag = 'MKE' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
                                UNION
                                SELECT t.evt_txn_dtm, t.ehr_number
                                FROM ehr_event_txn t, ehr_patient_list p
                                WHERE t.ehr_flag = 'MKP' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
                                UNION
                                SELECT t.evt_txn_dtm, t.ehr_number
                                FROM ehr_event_txn t, ehr_patient_list p
                                WHERE t.ehr_flag = 'MKM' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y'
                            ) a
                            WHERE evt_txn_dtm BETWEEN COALESCE(par_rpt_start_dtm, '1970-01-01'::TIMESTAMP)
                                AND COALESCE(par_rpt_end_dtm, CURRENT_TIMESTAMP)
                            GROUP BY ehr_number
                        ) p
                        WHERE t.ehr_number = p.ehr_number
                            AND t.evt_txn_dtm = p.evt_txn_dtm;
                        
                END;
            END IF;

            IF (par_rpt_id = '4') THEN
                BEGIN
                    -- OPEN p_refcur FOR
                    -- SELECT
                    --     REPLACE(to_char(var_report_date::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-') AS report_date, 4 AS report_id, t.old_ehr_flag AS rpt_f1, t.ehr_flag AS rpt_f2, t.ehr_number AS rpt_f3,
                      
					-- 	COALESCE(REPLACE(TO_CHAR(t.ehr_start_date, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f4,
                    --     COALESCE(CONCAT(REPLACE(to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(t.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A') AS rpt_f5, t.ehr_hkic AS rpt_f6, t.ehr_doc_type AS rpt_f7, t.ehr_doc_no AS rpt_f8, t.ehr_full_name AS rpt_f9, t.ehr_sex AS rpt_f10,
                       
                    --     COALESCE(REPLACE(TO_CHAR(t.ehr_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f11,
                    --     t.ehr_exact_dob AS rpt_f12,
                    --     CASE evt_txn_type
                    --         WHEN '020' THEN 'Merge HKIDs'
                    --         WHEN '031' THEN 'Update HKID'
                    --         ELSE ''
                    --     END AS rpt_f13,
                    --     CASE SUBSTRING(t.old_pas_hkic, 1, 1)
                    --         WHEN 'U' THEN 'N/A'
                    --         WHEN NULL THEN 'N/A'
                    --         ELSE t.old_pas_hkic
                    --     END AS rpt_f14,
                    --     CASE SUBSTRING(t.old_pas_hkic, 1, 1)
                    --         WHEN 'U' THEN t.old_pas_hkic
                    --         WHEN NULL THEN 'N/A'
                    --         ELSE 'N/A'
                    --     END AS rpt_f15, t.old_pas_doc_type AS rpt_f16, t.old_pas_doc_no AS rpt_f17, t.old_pas_full_name AS rpt_f18, t.old_pas_sex AS rpt_f19,
                     
                    --    COALESCE(REPLACE(TO_CHAR(t.old_pas_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f20,
                    --     t.old_pas_exact_dob AS rpt_f21,
                    --     CASE SUBSTRING(t.pas_hkic, 1, 1)
                    --         WHEN 'U' THEN 'N/A'
                    --         WHEN NULL THEN 'N/A'
                    --         ELSE t.pas_hkic
                    --     END AS rpt_f22,
                    --     CASE SUBSTRING(t.pas_hkic, 1, 1)
                    --         WHEN 'U' THEN t.pas_hkic
                    --         WHEN NULL THEN 'N/A'
                    --         ELSE 'N/A'
                    --     END AS rpt_f23, t.pas_doc_type AS rpt_f24, t.pas_doc_no AS rpt_f25, t.pas_full_name AS rpt_f26, t.pas_sex AS rpt_f27,
					-- 	 COALESCE(REPLACE(TO_CHAR(t.pas_dob, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f28,
                    --     t.pas_exact_dob AS rpt_f29,
                    --     CASE l.ehr_number
                    --         WHEN NULL THEN 'N'
                    --         ELSE 'Y'
                    --     END AS rpt_f30, l.ehr_number AS rpt_f31, l.ehr_flag AS rpt_f32
                    --     FROM ehr_event_txn AS t
                    --     LEFT OUTER JOIN ehr_patient_list AS l
                    --         ON
                    --         CASE
                    --             WHEN SUBSTRING(t.pas_hkic, 1, 1) = 'U' THEN t.pas_doc_no
                    --             ELSE t.pas_hkic
                    --         END =
                    --         CASE l.ehr_doc_type
                    --             WHEN 'ID' THEN l.ehr_hkic
                    --             WHEN 'BC' THEN l.ehr_hkic
                    --             ELSE l.ehr_doc_no
                    --         END
                    --     WHERE t.ehr_flag = 'MID' AND evt_txn_dtm BETWEEN
                    --     CASE par_rpt_start_dtm
                    --         WHEN NULL THEN '19700101'
                    --         ELSE par_rpt_start_dtm
                    --     END AND
                    --     CASE par_rpt_end_dtm
                    --         WHEN NULL THEN localtimestamp
                    --         ELSE par_rpt_end_dtm
                    --     END;
					-- return next p_refcur;
                    OPEN p_refcur_8 FOR
                        SELECT REPLACE(TO_CHAR(CAST(var_report_date AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-') AS report_date
                            ,4 AS report_id
                            ,t.old_ehr_flag AS rpt_f1
                            ,t.ehr_flag AS rpt_f2
                            ,t.ehr_number AS rpt_f3
                            ,COALESCE(REPLACE(TO_CHAR(CAST(t.ehr_start_date AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f4
                            ,COALESCE(REPLACE(TO_CHAR(t.evt_txn_dtm, 'DD Mon YYYY'), ' ', '-') || ' ' || TO_CHAR(t.evt_txn_dtm, 'HH24:MI:SS'), 'N/A') AS rpt_f5
                            ,t.ehr_hkic AS rpt_f6
                            ,t.ehr_doc_type AS rpt_f7
                            ,t.ehr_doc_no AS rpt_f8
                            ,t.ehr_full_name AS rpt_f9
                            ,t.ehr_sex AS rpt_f10
                            ,COALESCE(REPLACE(TO_CHAR(CAST(t.ehr_dob AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f11
                            ,t.ehr_exact_dob AS rpt_f12
                            ,CASE t.evt_txn_type
                                WHEN '020' THEN 'Merge HKIDs'
                                WHEN '031' THEN 'Update HKID'
                                ELSE ''
                            END AS rpt_f13
                            ,CASE SUBSTRING(t.old_pas_hkic, 1, 1)
                                WHEN 'U' THEN 'N/A'
                                WHEN NULL THEN 'N/A'
                                ELSE t.old_pas_hkic
                            END AS rpt_f14
                            ,CASE SUBSTRING(t.old_pas_hkic, 1, 1)
                                WHEN 'U' THEN t.old_pas_hkic
                                WHEN NULL THEN 'N/A'
                                ELSE 'N/A'
                            END AS rpt_f15
                            ,t.old_pas_doc_type AS rpt_f16
                            ,t.old_pas_doc_no AS rpt_f17
                            ,t.old_pas_full_name AS rpt_f18
                            ,t.old_pas_sex AS rpt_f19
                            ,COALESCE(REPLACE(TO_CHAR(CAST(t.old_pas_dob AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f20
                            ,t.old_pas_exact_dob AS rpt_f21
                            ,CASE SUBSTRING(t.pas_hkic, 1, 1)
                                WHEN 'U' THEN 'N/A'
                                WHEN NULL THEN 'N/A'
                                ELSE t.pas_hkic
                            END AS rpt_f22
                            ,CASE SUBSTRING(t.pas_hkic, 1, 1)
                                WHEN 'U' THEN t.pas_hkic
                                WHEN NULL THEN 'N/A'
                                ELSE 'N/A'
                            END AS rpt_f23
                            ,t.pas_doc_type AS rpt_f24
                            ,t.pas_doc_no AS rpt_f25
                            ,t.pas_full_name AS rpt_f26
                            ,t.pas_sex AS rpt_f27
                            ,COALESCE(REPLACE(TO_CHAR(CAST(t.pas_dob AS TIMESTAMP), 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f28
                            ,t.pas_exact_dob AS rpt_f29
                            ,CASE 
                                WHEN l.ehr_number IS NULL THEN 'N'
                                ELSE 'Y'
                            END AS rpt_f30
                            ,l.ehr_number AS rpt_f31
                            ,l.ehr_flag AS rpt_f32
                        FROM ehr_event_txn t
                        LEFT OUTER JOIN ehr_patient_list l ON CASE 
                            WHEN SUBSTRING(t.pas_hkic, 1, 1) = 'U' THEN t.pas_doc_no
                            ELSE t.pas_hkic
                        END = CASE l.ehr_doc_type
                            WHEN 'ID' THEN l.ehr_hkic
                            WHEN 'BC' THEN l.ehr_hkic
                            ELSE l.ehr_doc_no
                        END
                        WHERE t.ehr_flag = 'MID'
                            AND t.evt_txn_dtm BETWEEN COALESCE(par_rpt_start_dtm, '1970-01-01'::TIMESTAMP)
                                AND COALESCE(par_rpt_end_dtm, CURRENT_TIMESTAMP);
                        
                END;
            END IF;

            IF (par_rpt_id = '5') THEN
                BEGIN
                    OPEN p_refcur_8 FOR
                    SELECT
                        REPLACE(to_char(var_report_date::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-') AS report_date, 5 AS report_id, t.old_ehr_flag AS rpt_f1, t.ehr_flag AS rpt_f2, p.ehr_number AS rpt_f3,
                       
							COALESCE(REPLACE(TO_CHAR(p.ehr_start_date::TIMESTAMP WITHOUT TIME ZONE, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f4,
                        COALESCE(CONCAT(REPLACE(to_char(evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A') AS rpt_f5, old_ehr_hkic AS rpt_f6, old_ehr_doc_type AS rpt_f7, old_ehr_doc_no AS rpt_f8, old_ehr_full_name AS rpt_f9, old_ehr_sex AS rpt_f10,
                 
                         COALESCE(REPLACE(TO_CHAR(old_ehr_dob::TIMESTAMP WITHOUT TIME ZONE, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f11,
                        old_ehr_exact_dob AS rpt_f12, t.ehr_hkic AS rpt_f13, t.ehr_doc_type AS rpt_f14, t.ehr_doc_no AS rpt_f15, t.ehr_full_name AS rpt_f16, t.ehr_sex AS rpt_f17,
                         COALESCE(REPLACE(TO_CHAR(t.ehr_dob::TIMESTAMP WITHOUT TIME ZONE, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f18,
                        t.ehr_exact_dob AS rpt_f19, NULL AS rpt_f20, NULL AS rpt_f21, NULL AS rpt_f22, NULL AS rpt_f23, NULL AS rpt_f24, NULL AS rpt_f25, NULL AS rpt_f26, NULL AS rpt_f27, NULL AS rpt_f28, NULL AS rpt_f29, NULL AS rpt_f30, NULL AS rpt_f31, NULL AS rpt_f32
                        FROM ehr_event_txn AS t, ehr_patient_list AS p
                        WHERE evt_txn_type = 'MKC' AND evt_code = 'ADT_A47' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y' AND t.sys_dtm BETWEEN
                        CASE par_rpt_start_dtm
                            WHEN NULL THEN '19700101'
                            ELSE par_rpt_start_dtm
                        END AND
                        CASE par_rpt_end_dtm
                            WHEN NULL THEN localtimestamp
                            ELSE par_rpt_end_dtm
                        END;
				    
                END;
            END IF;

            IF (par_rpt_id = '6') THEN
                BEGIN           
                    OPEN p_refcur_8 FOR
                    SELECT
                        REPLACE(to_char(var_report_date::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-') AS report_date, 6 AS report_id,
                        
                        COALESCE(REPLACE(TO_CHAR(t.ehr_start_date::TIMESTAMP WITHOUT TIME ZONE, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f1,
                        t.ehr_number AS rpt_f2, t.ehr_doc_type AS rpt_f3, t.ehr_doc_no AS rpt_f4, t.ehr_full_name AS rpt_f5, t.ehr_sex AS rpt_f6,
                       
						COALESCE(REPLACE(TO_CHAR(t.ehr_dob::TIMESTAMP WITHOUT TIME ZONE, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f7,
                        t.ehr_exact_dob AS rpt_f8, COALESCE(CONCAT(REPLACE(to_char(r.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'), ' ', to_char(r.evt_txn_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS')), 'N/A') AS rpt_f9, r.ehr_hkic AS rpt_f10, r.ehr_doc_type AS rpt_f11, r.ehr_full_name AS rpt_f12, r.ehr_sex AS rpt_f13,
                       
						COALESCE(REPLACE(TO_CHAR(r.ehr_dob::TIMESTAMP WITHOUT TIME ZONE, 'DD Mon YYYY'), ' ', '-'), 'N/A') AS rpt_f14,
                        r.ehr_exact_dob AS rpt_f15, p.ehr_flag AS rpt_f16, a.hkid AS rpt_f17, d.document_type AS rpt_f18, a.other_doc_no AS rpt_f19, a.patient_name AS rpt_f20, a.sex AS rpt_f21, a.dob AS rpt_f22, a.exact_dob_flag AS rpt_f23, NULL AS rpt_f24, NULL AS rpt_f25, NULL AS rpt_f26, NULL AS rpt_f27, NULL AS rpt_f28, NULL AS rpt_f29, NULL AS rpt_f30, NULL AS rpt_f31, NULL AS rpt_f32
                        FROM ehr_event_txn AS t, ehr_patient_list AS p
                        LEFT OUTER JOIN ehr_event_txn AS r
                            ON p.ehr_number = r.ehr_number AND r.evt_txn_type = 'MKC' AND r.evt_code = 'ADT_A47' AND r.evt_txn_dtm = (SELECT
                                MAX(evt_txn_dtm)
                                FROM ehr_event_txn AS x
                                WHERE p.ehr_number = x.ehr_number AND x.evt_txn_type = 'MKC' AND x.evt_code = 'ADT_A47')
                        LEFT OUTER JOIN patient AS a
                            ON p.pas_pky = a.patient_key
                        LEFT OUTER JOIN document_type AS d
                            ON SUBSTRING(a.filler, 1, 1) = d.document_code
                        WHERE t.evt_txn_dtm = (SELECT
                            MIN(evt_txn_dtm)
                            FROM ehr_event_txn AS t2
                            WHERE t.ehr_number = t2.ehr_number) AND t.evt_code = 'ADT_A28' AND t.evt_txn_type = 'ENT' AND t.ehr_doc_type = 'ED' AND t.ehr_number = p.ehr_number AND p.ehr_ppi_ind = 'Y';
							
                END;
            END IF;
        END;
    END IF;
    /*
    
    DROP TABLE IF EXISTS t$tmp_code_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$tmp_2;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$tmp_2_1;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$tmp_3;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*c
    
    DROP TABLE IF EXISTS t$tmp_3_1;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /* --------------------------------------------------------------------------------- */
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_erpt_ehr_portal" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";