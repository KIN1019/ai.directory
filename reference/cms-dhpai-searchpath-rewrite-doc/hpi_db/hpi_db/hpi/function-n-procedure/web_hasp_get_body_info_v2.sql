-- DROP PROCEDURE web_hasp_get_body_info_v2(inout int4, in varchar, in varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout int4, inout int4, inout int4, inout int4, inout int4, inout timestamp, inout varchar, inout timestamp, inout varchar, inout int4, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE web_hasp_get_body_info_v2(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, INOUT par_hkid character varying, INOUT par_lof_hkid character varying, INOUT par_patient_name character varying, INOUT par_sex character varying, INOUT par_cccode1 character varying, INOUT par_cccode2 character varying, INOUT par_cccode3 character varying, INOUT par_cccode4 character varying, INOUT par_cccode5 character varying, INOUT par_cccode6 character varying, INOUT par_unicode1 integer, INOUT par_unicode2 integer, INOUT par_unicode3 integer, INOUT par_unicode4 integer, INOUT par_unicode5 integer, INOUT par_unicode6 integer, INOUT par_dob timestamp without time zone, INOUT par_exact_dob_flag character varying, INOUT par_death_date timestamp without time zone, INOUT par_body_category character varying, INOUT par_retcode integer, INOUT par_error_msg character varying, INOUT par_bcf_eff_date character varying DEFAULT ''::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rowcount        INTEGER;
    var_error           INTEGER;
    var_valid_flag      VARCHAR(1);
    var_local_hospital  VARCHAR(3);
    var_local_flag      VARCHAR(1);
    var_hkpmi_srvr      VARCHAR(20);
    var_prg_name        VARCHAR(60);
    var_rpc_call        VARCHAR(255);
    var_parent_hospital VARCHAR(3);
    var_effective_date  TIMESTAMP WITHOUT TIME ZONE;
    var_hkpmi_down_flag VARCHAR(1);
    var_local_hosp      VARCHAR(3);
    sql$rowcount        BIGINT;
    var_return_code     int;
BEGIN
    <<return_error>>
    BEGIN
        SELECT 'N',
               'Y',
               0,
               NULL
        INTO var_local_flag, var_valid_flag, par_retcode, par_error_msg;

        IF par_hkid IS NULL AND par_case_no IS NULL THEN
            BEGIN
                SELECT - 1
                INTO par_retcode;
                SELECT 'Either HKID or case number should be provided'
                INTO par_error_msg;
                EXIT return_error;
            END;
        END IF;

        /* Ricky Yuen 20130424 to enhance support multiple version appendix */
        /* version 2.1 will be used when Text_value exists */
        SELECT Text_value
        INTO par_bcf_eff_date
        FROM Hospital_control
        WHERE Type = 'bcf_version_2.1';

        /* YL 20070905 	Get parent_hospital from hospital_mortuary table */
        SELECT MAX(effective_date)
        INTO var_effective_date
        FROM hospital_mortuary
        WHERE mortuary_hospital = par_hospital_code
          AND effective_date <= LOCALTIMESTAMP;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;

        IF var_error != 0 OR var_rowcount != 1 THEN
            BEGIN
                SELECT - 1
                INTO par_retcode;
                SELECT 'Error in selecting hospital_mortuary'
                INTO par_error_msg;
                EXIT return_error;
            END;
        END IF;

        SELECT parent_hospital
        INTO var_parent_hospital
        FROM (SELECT parent_hospital,
                     ROW_NUMBER()
                     OVER (PARTITION BY mortuary_hospital, effective_date ORDER BY update_datetime DESC) AS rn
              FROM hospital_mortuary
              WHERE mortuary_hospital = par_hospital_code
                AND effective_date = var_effective_date) subquery
        WHERE rn = 1;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;

        IF var_error != 0 OR var_rowcount != 1 THEN
            BEGIN
                SELECT - 1
                INTO par_retcode;
                SELECT 'Error in selecting hospital_mortuary'
                INTO par_error_msg;
                EXIT return_error;
            END;
        END IF;

        IF var_parent_hospital IS NOT NULL AND var_parent_hospital <> '' THEN
            SELECT var_parent_hospital
            INTO par_hospital_code;
        END IF;

        SELECT Hospital_code
        INTO var_local_hospital
        FROM Hospital;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;

        IF var_error != 0 OR var_rowcount != 1 THEN
            BEGIN
                SELECT var_error
                INTO par_retcode;
                SELECT 'Error in selecting Hospital table'
                INTO par_error_msg;
                EXIT return_error;
            END;
        END IF;

        IF par_hospital_code = var_local_hospital THEN
            SELECT 'Y'
            INTO var_local_flag;
        END IF;

        IF var_local_flag = 'Y' THEN
            BEGIN
                IF par_hospital_code IS NOT NULL AND par_case_no IS NOT NULL THEN
                    BEGIN
                        SELECT HKID
                        INTO par_hkid
                        FROM Case_view
                        WHERE Hospital_code = par_hospital_code
                          AND Case_no = par_case_no;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        BEGIN
                            var_rowcount := sql$rowcount;
                            var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                        END;

                        IF var_error != 0 THEN
                            BEGIN
                                SELECT var_error
                                INTO par_retcode;
                                SELECT 'Error in getting HKID'
                                INTO par_error_msg;
                                EXIT return_error;
                            END;
                        END IF;

                        IF var_rowcount != 1 THEN
                            BEGIN
                                SELECT - 1
                                INTO par_retcode;
                                SELECT 'Patient not found for the case number'
                                INTO par_error_msg;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
                /* 12-12-2012 Ricky Yuen to retrieve unicode_int for web reports - Start */
                SELECT p.hkid,
                       p.name,
                       p.sex,
                       p.ccc_1,
                       p.ccc_2,
                       p.ccc_3,
                       p.ccc_4,
                       p.ccc_5,
                       p.ccc_6,
                       c1.unicode_int,
                       c2.unicode_int,
                       c3.unicode_int,
                       c4.unicode_int,
                       c5.unicode_int,
                       c6.unicode_int,
                       p.dob,
                       p.exact_dob_flag,
                       p.death_date,
                       p.body_category
                INTO par_hkid, par_patient_name, par_sex, par_cccode1, par_cccode2, par_cccode3,
                    par_cccode4, par_cccode5, par_cccode6,
                    par_unicode1, par_unicode2, par_unicode3, par_unicode4, par_unicode5, par_unicode6,
                    par_dob, par_exact_dob_flag, par_death_date, par_body_category
                FROM pmi_wo_mrn p
                         LEFT JOIN ccc_unicode c1
                                   ON SUBSTRING(p.ccc_1, 1, 4) = c1.ccc_head AND SUBSTRING(p.ccc_1, 5, 1) = c1.ccc_tail
                         LEFT JOIN ccc_unicode c2
                                   ON SUBSTRING(p.ccc_2, 1, 4) = c2.ccc_head AND SUBSTRING(p.ccc_2, 5, 1) = c2.ccc_tail
                         LEFT JOIN ccc_unicode c3
                                   ON SUBSTRING(p.ccc_3, 1, 4) = c3.ccc_head AND SUBSTRING(p.ccc_3, 5, 1) = c3.ccc_tail
                         LEFT JOIN ccc_unicode c4
                                   ON SUBSTRING(p.ccc_4, 1, 4) = c4.ccc_head AND SUBSTRING(p.ccc_4, 5, 1) = c4.ccc_tail
                         LEFT JOIN ccc_unicode c5
                                   ON SUBSTRING(p.ccc_5, 1, 4) = c5.ccc_head AND SUBSTRING(p.ccc_5, 5, 1) = c5.ccc_tail
                         LEFT JOIN ccc_unicode c6
                                   ON SUBSTRING(p.ccc_6, 1, 4) = c6.ccc_head AND SUBSTRING(p.ccc_6, 5, 1) = c6.ccc_tail
                WHERE p.hkid = par_hkid;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;

                IF var_error != 0 THEN
                    BEGIN
                        SELECT var_error
                        INTO par_retcode;
                        SELECT 'Error in selecting body information'
                        INTO par_error_msg;
                        EXIT return_error;
                    END;
                END IF;

                IF var_rowcount != 1 THEN
                    BEGIN
                        SELECT - 1
                        INTO par_retcode;
                        SELECT 'Patient not found'
                        INTO par_error_msg;
                        EXIT return_error;
                    END;
                END IF;
                /* ---20090604 SL bugfix : if @case_no is null --> pass-in by hkid */
                IF par_case_no IS NULL THEN
                    BEGIN
                        SELECT Case_no
                        INTO par_case_no
                        FROM Case_view
                        WHERE HKID = par_hkid
                          AND Discharge_code = '1';
                    END;
                END IF;
                /* ------20090317 ---- Unique index on las_office_form_log (hkid, issue_datetime, action_type ) */

                /*
                select @lof_hkid = hkid from last_office_form_log
                where last_case_no = @case_no
                	and last_hospital_code = @hospital_code
                group by last_case_no
                having issue_datetime =  max(issue_datetime)
                */

                /* -----------20101018 SL bug fix ------------------------------- */
                SELECT NULL
                INTO par_lof_hkid;

                /* --- select the oldest hkid of non-cancelled LOF txn as lof_hkid for same HN case (for merged HKIDs ) */
                SELECT hkid
                INTO par_lof_hkid
                FROM (SELECT hkid,
                             ROW_NUMBER() OVER (PARTITION BY hkid ORDER BY issue_datetime DESC) AS rn
                      FROM hkpmi.last_office_form_log
                      WHERE last_case_no = par_case_no
                        AND last_hospital_code = par_hospital_code
                        AND action_type = 'A') subquery
                WHERE rn = 1;
                /* ----------------------------------------- */

            END; /* ---local_flag = 'Y' */
        ELSE
            BEGIN
                /* ----------20120105 Check HKPMI down Flag-------------------- */
                SELECT 'N'
                INTO var_hkpmi_down_flag;

                SELECT Hospital_code
                INTO var_local_hosp
                FROM Hospital;

                SELECT appl_ctl_text_value
                INTO var_hkpmi_down_flag
                FROM pas_appl_control
                WHERE hospital_code = var_local_hosp
                  AND appl_name = 'IPAS'
                  AND appl_ctl_type = 'HKPMI_SP1_DOWN';

                IF var_hkpmi_down_flag = 'Y' THEN
                    BEGIN
                        SELECT NULL
                        INTO var_hkpmi_srvr;
                        /* ---exec cpi..cpi_get_rpc_server 'HKPMI_READ_ONLY_SVR', @hkpmi_srvr	output */
                        CALL cpi_get_rpc_server('HKPMI_READ_ONLY_SVR', var_hkpmi_srvr, var_return_code);
                    END;
                ELSE
                    /* ------------------------------------------------ */
                    BEGIN
                        SELECT NULL
                        INTO var_hkpmi_srvr;
                        /* ----exec cpi..cpi_get_rpc_server 'HKPMI_SERVER', @hkpmi_srvr output */
                        CALL cpi_get_rpc_server('HKPMI_SERVER', var_hkpmi_srvr, var_return_code)
                        /* ---- HPI Version */
                        ;
                    END;
                END IF;

                IF var_hkpmi_srvr IS NOT NULL THEN
                    BEGIN
                        /*var_prg_name := 'hkpmi.web_hkpmi_get_body_info_v2';

                        SELECT CONCAT(RTRIM(var_hkpmi_srvr), var_prg_name)
                        INTO var_rpc_call;

                        PERFORM public.dblink_connect('rpc_server'::text, var_rpc_call);
                        SELECT * FROM public.dblink_connect('rpc_server'::text,'call '
                                      || var_prg_name || '('
                                      || case when par_hospital_code IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_hospital_code,'''::bpchar') END || ','
                                      || case when par_case_no IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_case_no,'''::bpchar') END || ','
                                      || case when par_hkid IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_hkid,'''::bpchar') END || ','
                                      || case when par_lof_hkid IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_lof_hkid,'''::bpchar') END || ','
                                      || case when par_patient_name IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_patient_name,'''::bpchar') END || ','
                                      || case when par_sex IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_sex,'''::bpchar') END || ','
                                      || case when par_cccode1 IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_cccode1,'''::bpchar') END || ','
                                      || case when par_cccode2 IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_cccode2,'''::bpchar') END || ','
                                      || case when par_cccode3 IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_cccode3,'''::bpchar') END || ','
                                      || case when par_cccode4 IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_cccode4,'''::bpchar') END || ','
                                      || case when par_cccode5 IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_cccode5,'''::bpchar') END || ','
                                      || case when par_cccode6 IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_cccode6,'''::bpchar') END || ','
                                      || case when par_unicode1 IS NULL THEN 'NULL::int' ELSE par_unicode1 END || ','
                                      || case when par_unicode2 IS NULL THEN 'NULL::int' ELSE par_unicode2 END || ','
                                      || case when par_unicode3 IS NULL THEN 'NULL::int' ELSE par_unicode3 END || ','
                                      || case when par_unicode4 IS NULL THEN 'NULL::int' ELSE par_unicode4 END || ','
                                      || case when par_unicode5 IS NULL THEN 'NULL::int' ELSE par_unicode5 END || ','
                                      || case when par_unicode6 IS NULL THEN 'NULL::int' ELSE par_unicode6 END || ','
                                      || case when par_dob is NULL then 'NULL::TIMESTAMP WITHOUT TIME ZONE' ELSE concat('''', par_dob,'''::TIMESTAMP WITHOUT TIME ZONE') END || ','
                                      || case when par_exact_dob_flag IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_exact_dob_flag,'''::bpchar') END || ','
                                      || case when par_death_date IS NULL THEN 'NULL::NULL::TIMESTAMP WITHOUT TIME ZONE' ELSE concat('''', par_death_date,'''::NULL::TIMESTAMP WITHOUT TIME ZONE') END || ','
                                      || case when par_body_category IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_body_category,'''::bpchar') END || ','
                                      || case when par_retcode IS NULL THEN 'NULL::int' ELSE par_retcode END || ','
                                      || case when par_bcf_eff_date IS NULL THEN 'NULL::bpchar' ELSE concat('''', par_body_category,'''::bpchar') END
                                      || ');' ::text)
                        as t1(par_hkid bpchar,par_lof_hkid bpchar,par_patient_name bpchar,par_sex bpchar,
                            par_cccode1 bpchar,par_cccode2 bpchar,par_cccode3 bpchar,par_cccode4 bpchar,
                            par_cccode5 bpchar,par_cccode6 bpchar,par_unicode1 int,par_unicode2 int,
                            par_unicode3 int,par_unicode4 int, par_unicode5 int,par_unicode6 int,
                            par_dob timestamp without time zone,par_exact_dob_flag bpchar,
                            par_death_date timestamp without time zone,par_body_category bpchar,
                            par_retcode int,par_bcf_eff_date bpchar)
                        into par_hkid,par_lof_hkid,par_patient_name,par_sex,
                            par_cccode1,par_cccode2,par_cccode3,par_cccode4,
                            par_cccode5,par_cccode6,par_unicode1,par_unicode2,
                            par_unicode3,par_unicode4,par_unicode5,par_unicode6,
                            par_dob,par_exact_dob_flag,
                            par_death_date,par_body_category,par_retcode,par_bcf_eff_date;
                        PERFORM public.dblink_disconnect('rpc_server'::text);*/
	                    
	                    -- replace_dblink_by_fdw
	                    CALL hkpmi.web_hkpmi_get_body_info_v2(par_hospital_code, par_case_no, par_hkid,par_lof_hkid,par_patient_name,par_sex,
	                    par_cccode1,par_cccode2,par_cccode3,par_cccode4,par_cccode5,par_cccode6,par_unicode1,par_unicode2,par_unicode3,par_unicode4,par_unicode5,par_unicode6,
	                    par_dob,par_exact_dob_flag,par_death_date,par_body_category,par_retcode,par_bcf_eff_date); 
	                   	SET search_path TO hpi,public;
                    END;
                ELSE
                    BEGIN
                        SELECT - 2
                        INTO par_retcode;
                        SELECT 'Fail to call HKPMI'
                        INTO par_error_msg;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
    END;

    IF par_retcode <> 0 THEN
        pas_return_code := - 1;
        RETURN;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
END;
$procedure$
;

;ALTER PROCEDURE "web_hasp_get_body_info_v2" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
