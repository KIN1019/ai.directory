-- DROP PROCEDURE hpi.hasp_update_ws_information(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_update_ws_information(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_ws_id character varying, IN par_term_id character varying, IN par_user_id character varying, IN par_reg_year character varying, IN par_unhkid_prefix character varying, IN par_unhkid_next character varying, IN par_ae_next character varying, IN par_hn_next character varying, IN par_mini_next character varying, INOUT par_rtn integer, INOUT par_rtn_msg character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_eff_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_hosp VARCHAR(6);
    var_ws VARCHAR(48);
    var_hosp_unhkid_prefix VARCHAR(4);
    var_db_unhkid_prefix VARCHAR(4);
    var_db_hosp VARCHAR(3);
    var_db_reg_year VARCHAR(4);
    var_db_unhkid_min VARCHAR(12);
    var_db_unhkid_max VARCHAR(12);
    var_db_unhkid_next VARCHAR(12);
    var_db_hn_min VARCHAR(12);
    var_db_hn_max VARCHAR(12);
    var_db_hn_next VARCHAR(12);
    var_db_ae_min VARCHAR(12);
    var_db_ae_max VARCHAR(12);
    var_db_ae_next VARCHAR(12);
    var_db_mini_label_min VARCHAR(20);
    var_db_mini_label_max VARCHAR(20);
    var_db_mini_next VARCHAR(20);
    var_li_max_ae_case INTEGER;
    var_li_max_hn_case INTEGER;
    var_li_max_hkid INTEGER;
    var_li_max_used_unhkid INTEGER;
    var_max_ae_case VARCHAR(24);
    var_max_hn_case VARCHAR(24);
    var_max_hkid VARCHAR(24);
    var_max_used_unhkid VARCHAR(24);
    var_ls_ws_case_min VARCHAR(24);
    var_ls_ws_case_max VARCHAR(24);
    var_ls_ws_hkid_min VARCHAR(24);
    var_ls_ws_hkid_max VARCHAR(24);
    var_cur_year VARCHAR(4);
    var_row INTEGER;
    var_action_str VARCHAR(10);
    var_old_db_reg_year VARCHAR(4);
    sql$rowcount BIGINT;
    var_today TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    <<prog_end>>
    BEGIN
        SELECT timestamp_convert(localtimestamp)
        INTO var_today;

        SELECT
            '00000'
            INTO var_action_str; /* ---'11111' - reg_year/unhkid/ae/hn/mini */
        SELECT
            UPPER(par_hosp_code)
            INTO par_hosp_code;
        SELECT
            UPPER(par_ws_id)
            INTO par_ws_id;
        SELECT
            LTRIM(RTRIM(par_ws_id))
            INTO par_ws_id;
        SELECT
            hospital_code, un_hkid_prefix
            INTO var_hosp, var_hosp_unhkid_prefix
            FROM hospital_config;

        IF var_hosp <> par_hosp_code OR par_hosp_code IS NULL OR var_hosp IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO par_rtn;
                SELECT
                    'Hospital Code did not match !'
                    INTO par_rtn_msg;
                EXIT prog_end;
            END;
        END IF;

        /* --- select current ws_info to check need to update or NOT ---- */
        SELECT
            ungrouped_query.hospital_code, ungrouped_query.ws_id, effective_datetime, registration_year, unhkid_prefix, unhkid_min, unhkid_max, unhkid_next, hn_min, hn_max, hn_next, ae_min, ae_max, ae_next, mini_label_min, mini_label_max, mini_label_next
            INTO var_hosp, var_ws, var_eff_dtm, var_db_reg_year, var_db_unhkid_prefix, var_db_unhkid_min, var_db_unhkid_max, var_db_unhkid_next, var_db_hn_min, var_db_hn_max, var_db_hn_next, var_db_ae_min, var_db_ae_max, var_db_ae_next, var_db_mini_label_min, var_db_mini_label_max, var_db_mini_next
            FROM (SELECT
                hospital_code, ws_id, effective_datetime, registration_year, unhkid_prefix, unhkid_min, unhkid_max, unhkid_next, hn_min, hn_max, hn_next, ae_min, ae_max, ae_next, mini_label_min, mini_label_max, mini_label_next, active_status
                FROM ws_information) AS ungrouped_query
            INNER JOIN (SELECT
                hospital_code, ws_id, MAX(effective_datetime) AS max_1
                FROM ws_information
                WHERE hospital_code = par_hosp_code AND ws_id = par_ws_id AND effective_datetime <= var_today
                GROUP BY hospital_code, ws_id) AS grouped_query
                ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
            WHERE effective_datetime = max_1 AND active_status = 'A';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_row := sql$rowcount;

        IF var_row <> 1 THEN
            BEGIN
                SELECT
                    - 2
                    INTO par_rtn;
                SELECT
                    'No ws_information records to update !'
                    INTO par_rtn_msg;
                EXIT prog_end;
            END;
        END IF;

        IF var_db_unhkid_prefix IS NULL OR var_hosp_unhkid_prefix IS NULL OR var_hosp_unhkid_prefix <> var_db_unhkid_prefix THEN
            BEGIN
                SELECT
                    - 3
                    INTO par_rtn;
                SELECT
                    'Pseudo ID prefix  did not match !'
                    INTO par_rtn_msg;
                EXIT prog_end;
            END;
        END IF;
        /* ----------------------------------------------------------------------------- */
        /* ---- check to update ws_infomation.reg_year &&  reset hn/ae next  to hn/ae min ---- */
        
        /* ----------------------------------------------------------------------------- */
        SELECT
            var_db_reg_year
            INTO var_old_db_reg_year;
        SELECT
            to_char(timestamp_convert(localtimestamp), 'YY')
            INTO var_cur_year;

        IF par_reg_year = var_cur_year AND (par_reg_year <> var_db_reg_year OR var_db_reg_year IS NULL) THEN
            BEGIN
                UPDATE ws_information
                SET registration_year = var_cur_year, hn_next = var_db_hn_min, ae_next = var_db_ae_min
                    WHERE hospital_code = par_hosp_code AND ws_id = par_ws_id AND effective_datetime = var_eff_dtm;
                /* re-set @db_values */
                SELECT
                    var_cur_year
                    INTO var_db_reg_year;
                SELECT
                    var_db_hn_min
                    INTO var_db_hn_next;
                SELECT
                    var_db_ae_min
                    INTO var_db_ae_next;
                SELECT
                    '10000'
                    INTO var_action_str;
            END;
        END IF;
        /* ----print 'input: %1! %2! %3! %4!',@hkid,@hn_case_no,@ae_case_no,@mini_label */
        /* ------------------------------------------------------ */
        /* --- update  unhkid_next ----- */
        
        /* ------------------------------------------------------ */
        IF par_unhkid_prefix = var_db_unhkid_prefix AND LTRIM(RTRIM(par_unhkid_next)) <> '' THEN
            BEGIN
                IF CAST (par_unhkid_next AS INTEGER) > CAST (var_db_unhkid_next AS INTEGER) AND CAST (par_unhkid_next AS INTEGER) <= CAST (var_db_unhkid_max AS INTEGER) THEN
                    BEGIN
                        /* --------- select max(hkid) for this Workstation's down-time range ---- */
                        SELECT
                            CONCAT(var_db_unhkid_prefix, var_db_unhkid_min)
                            INTO var_ls_ws_hkid_min;
                        SELECT
                            CONCAT(var_db_unhkid_prefix, var_db_unhkid_max)
                            INTO var_ls_ws_hkid_max;
                        /*
                        select @max_hkid = max(hkid)
                        from cpi..cpi_patient
                        ---from cpi_patient  ---HPI
                        where hkid >=@ls_ws_hkid_min and hkid <@ls_ws_hkid_max
                        */
                        SELECT
                            MAX(HKID)
                            INTO var_max_hkid
                            FROM PMI_wo_MRN
                            WHERE HKID >= var_ls_ws_hkid_min AND HKID < var_ls_ws_hkid_max;
                        /* --- note: max(hkid) = NULL  ==> @@rowcount=1 */

                        IF var_max_hkid IS NULL OR LTRIM(RTRIM(var_max_hkid)) = '' THEN
                            SELECT
                                0
                                INTO var_li_max_hkid;
                        ELSE
                            SELECT
                                CAST (SUBSTRING(var_max_hkid, 3, 6) AS INTEGER)
                                INTO var_li_max_hkid;
                        END IF;
                        /* ---print 'update hkid next - %1! %2! %3!',@li_hkid_num,@li_db_unhkid_next,@li_max_hkid */
                        /* ----------cpi_used_unhkid----------- */
                        SELECT
                            CONCAT(var_db_unhkid_prefix, RIGHT(CONCAT('000000', par_unhkid_next), 6))
                            INTO var_ls_ws_hkid_min;
                        /*
                        select @max_used_unhkid = max(hkid)
                        from cpi..cpi_used_unhkid
                        ---from cpi_used_unhkid  ---HPI
                        where hkid >=@ls_ws_hkid_min and hkid <@ls_ws_hkid_max
                        */
                        SELECT
                            MAX(hkid)
                            INTO var_max_used_unhkid
                            FROM used_unhkid
                            WHERE hkid >= var_ls_ws_hkid_min AND hkid < var_ls_ws_hkid_max;
                        /* --- note: max(hkid) = NULL  ==> @@rowcount=1 */

                        IF var_max_used_unhkid IS NULL OR LTRIM(RTRIM(var_max_used_unhkid)) = '' THEN
                            SELECT
                                0
                                INTO var_li_max_used_unhkid;
                        ELSE
                            SELECT
                                CAST (SUBSTRING(var_max_used_unhkid, 3, 6) AS INTEGER)
                                INTO var_li_max_used_unhkid;
                        END IF;
                        /* --------------------- */
                        IF CAST (par_unhkid_next AS INTEGER) > var_li_max_hkid AND CAST (par_unhkid_next AS INTEGER) > var_li_max_used_unhkid THEN
                            BEGIN
                                SELECT
                                    RIGHT(CONCAT('000000', par_unhkid_next), 6)
                                    INTO par_unhkid_next;
                                UPDATE ws_information
                                SET unhkid_next = par_unhkid_next
                                    WHERE hospital_code = par_hosp_code AND ws_id = par_ws_id AND effective_datetime = var_eff_dtm;
                                SELECT
                                    CONCAT(SUBSTRING(var_action_str, 1, 1), '1000')
                                    INTO var_action_str;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* --- 'UNHKID' --- */
        
        /* ------------------------------------------------------ */
        /* update AE next ---- if @ls_case_year = @ls_cur_year && ... */
        
        /* ------------------------------------------------------ */
        IF RTRIM(LTRIM(par_ae_next)) <> '' THEN
            BEGIN
                IF CAST (par_ae_next AS INTEGER) > CAST (var_db_ae_next AS INTEGER) AND CAST (par_ae_next AS INTEGER) >= CAST (var_db_ae_min AS INTEGER) AND CAST (par_ae_next AS INTEGER) <= CAST (var_db_ae_max AS INTEGER) THEN
                    BEGIN
                        SELECT
                            CONCAT(' AE', var_cur_year, var_db_ae_min)
                            INTO var_ls_ws_case_min;
                        SELECT
                            CONCAT(' AE', var_cur_year, var_db_ae_max)
                            INTO var_ls_ws_case_max;
                        /*
                        select @max_ae_case = max(case_no)
                        from cpi..cpi_case
                        ---from cpi_case	---HPI ver
                        where hospital_code = @hosp_code and case_no > @ls_ws_case_min and case_no < @ls_ws_case_max
                        */
                        SELECT
                            MAX(Case_no)
                            INTO var_max_ae_case
                            FROM ADT_Case
                            WHERE Case_no > var_ls_ws_case_min AND Case_no < var_ls_ws_case_max;

                        IF var_max_ae_case IS NULL OR LTRIM(RTRIM(var_max_ae_case)) = '' THEN
                            SELECT
                                0
                                INTO var_li_max_ae_case;
                        ELSE
                            SELECT
                                CAST (SUBSTRING(var_max_ae_case, 6, 6) AS INTEGER)
                                INTO var_li_max_ae_case;
                        END IF;
                        /* ---print '%1! %2! %3!',@db_ae_next,@ae_next,@li_max_ae_case */
                        IF CAST (par_ae_next AS INTEGER) > var_li_max_ae_case THEN
                            BEGIN
                                SELECT
                                    RIGHT(CONCAT('000000', par_ae_next), 6)
                                    INTO par_ae_next;
                                UPDATE ws_information
                                SET ae_next = par_ae_next
                                    WHERE hospital_code = par_hosp_code AND ws_id = par_ws_id AND effective_datetime = var_eff_dtm;
                                SELECT
                                    CONCAT(SUBSTRING(var_action_str, 1, 2), '100')
                                    INTO var_action_str;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF; /* --'AE Next ' ----- */
        /* ------------------------------------------------------ */
        /* --- update HN next -- if @ls_case_year = @ls_cur_year && ... */
        
        /* ------------------------------------------------------ */
        IF RTRIM(LTRIM(par_hn_next)) <> '' THEN
            BEGIN
                IF CAST (par_hn_next AS INTEGER) > CAST (var_db_hn_next AS INTEGER) AND CAST (par_hn_next AS INTEGER) >= CAST (var_db_hn_min AS INTEGER) AND CAST (par_hn_next AS INTEGER) <= CAST (var_db_hn_max AS INTEGER) THEN
                    BEGIN
                        SELECT
                            CONCAT(' HN', var_cur_year, var_db_hn_min)
                            INTO var_ls_ws_case_min;
                        SELECT
                            CONCAT(' HN', var_cur_year, var_db_hn_max)
                            INTO var_ls_ws_case_max;
                        /*
                        select @max_hn_case = max(case_no)
                        from cpi..cpi_case
                        ---from cpi_case	---HPI ver
                        where hospital_code = @hosp_code and case_no > @ls_ws_case_min and case_no < @ls_ws_case_max
                        */
                        SELECT
                            MAX(Case_no)
                            INTO var_max_hn_case
                            FROM ADT_Case
                            WHERE Case_no > var_ls_ws_case_min AND Case_no < var_ls_ws_case_max;

                        IF var_max_hn_case IS NULL OR LTRIM(RTRIM(var_max_hn_case)) = '' THEN
                            SELECT
                                0
                                INTO var_li_max_hn_case;
                        ELSE
                            SELECT
                                CAST (SUBSTRING(var_max_hn_case, 6, 6) AS INTEGER)
                                INTO var_li_max_hn_case;
                        END IF;
                        /* ---print '%1! %2! %3!',@db_hn_next,@hn_next,@li_max_hn_case */
                        IF CAST (par_hn_next AS INTEGER) > var_li_max_hn_case THEN
                            BEGIN
                                SELECT
                                    RIGHT(CONCAT('000000', par_hn_next), 6)
                                    INTO par_hn_next;
                                UPDATE ws_information
                                SET hn_next = par_hn_next
                                    WHERE hospital_code = par_hosp_code AND ws_id = par_ws_id AND effective_datetime = var_eff_dtm;
                                SELECT
                                    CONCAT(SUBSTRING(var_action_str, 1, 3), '10')
                                    INTO var_action_str;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF; /* --'HN Next ' ----- */
        /* ------------------------------------------------------ */
        /* --- update mini_label next directly by pass-in values ---- */
        
        /* ------------------------------------------------------ */
        IF LTRIM(RTRIM(par_mini_next)) <> '' THEN
            BEGIN
                IF CAST (par_mini_next AS NUMERIC(18, 0)) > CAST (var_db_mini_next AS NUMERIC(18, 0)) AND CAST (par_mini_next AS NUMERIC(18, 0)) > CAST (var_db_mini_label_min AS NUMERIC(18, 0)) AND CAST (par_mini_next AS NUMERIC(18, 0)) <= CAST (var_db_mini_label_max AS NUMERIC(18, 0)) THEN
                    BEGIN
                        /* ---print '%1! %2!',@ld_mini_label,@ld_db_mini_next */
                        SELECT
                            RIGHT(CONCAT('0000000000', par_mini_next), 10)
                            INTO par_mini_next;
                        UPDATE ws_information
                        SET mini_label_next = par_mini_next
                            WHERE hospital_code = par_hosp_code AND ws_id = par_ws_id AND effective_datetime = var_eff_dtm;
                        SELECT
                            CONCAT(SUBSTRING(var_action_str, 1, 4), '1')
                            INTO var_action_str;
                    END;
                END IF;
            END;
        END IF; /* ---'mini label' ------ */
        SELECT
            0
            INTO par_rtn;
        SELECT
            ''
            INTO par_rtn_msg;
    END;
    INSERT INTO ws_history (hospital_code, ws_id, system_datetime, error_code, term_id, user_id, action_code, registration_year, unhkid_prefix, unhkid_next, ae_next, hn_next, mini_label_next, old_registration_year, old_unhkid_prefix, old_unhkid_min, old_unhkid_max, old_ae_min, old_ae_max, old_hn_min, old_hn_max, old_mini_label_min, old_mini_label_max, old_unhkid_next, old_ae_next, old_hn_next, old_mini_label_next)
    VALUES (par_hosp_code, par_ws_id, var_today, par_rtn, par_term_id, par_user_id, var_action_str, par_reg_year, par_unhkid_prefix, par_unhkid_next, par_ae_next, par_hn_next, par_mini_next, var_old_db_reg_year, var_db_unhkid_prefix, var_db_unhkid_min, var_db_unhkid_max, var_db_ae_min, var_db_ae_max, var_db_hn_min, var_db_hn_max, var_db_mini_label_min, var_db_mini_label_max, var_db_unhkid_next, var_db_ae_next, var_db_hn_next, var_db_mini_next);
    pas_return_code := par_rtn;
    RETURN;
END;
$procedure$
;
