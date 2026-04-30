-- DROP PROCEDURE hpi.hasp_ae_statistics(inout int4, in varchar, in timestamp, in timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_ae_statistics(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_from_date timestamp without time zone, IN par_to_date timestamp without time zone, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/*
- A&E Statistics

    Parameters to be used :-
	     Description               Data Type
	--------------------	       -------------
	1. Hospital Code               VARCHAR(3)
	2. From date                   datetime
	3. To date                     datetime

Modification:
20120312 Max, prevent daily report generate for leap year 29 Feb
20120312 Max, for accurate result of 28 feb in leap year
*/
DECLARE
    result_str_value_1           VARCHAR(128);
    result_str_value_2           VARCHAR(128);
    result_str_value_3           VARCHAR(128);
    var_prev_from_date           TIMESTAMP WITHOUT TIME ZONE;
    var_prev_to_date             TIMESTAMP WITHOUT TIME ZONE;
    var_new_attend_tot           INTEGER;
    var_new_attend_tot_prev      INTEGER;
    var_reattend_tot             INTEGER;
    var_reattend_tot_prev        INTEGER;
    var_ambulance_tot            INTEGER;
    var_ambulance_tot_prev       INTEGER;
    var_dead_bef_arrvd           INTEGER;
    var_dead_bef_arrvd_prev      INTEGER;
    var_follow_up_tot            INTEGER;
    var_follow_up_tot_prev       INTEGER;
    var_gross_tot                INTEGER;
    var_gross_tot_prev           INTEGER;
    var_ae_adm_tot               INTEGER;
    var_ae_adm_tot_prev          INTEGER;
    var_ae_adm_oth_tot           INTEGER;
    var_ae_adm_oth_tot_prev      INTEGER;
    var_attend_hospitalised      DOUBLE PRECISION;
    var_attend_hospitalised_prev DOUBLE PRECISION;
    var_case_no                  VARCHAR(12);
    var_ae_case_type             VARCHAR(1);
    var_tx_type                  VARCHAR(4);
    var_tx_dt                    TIMESTAMP WITHOUT TIME ZONE;
    var_amb_no                   VARCHAR(4);
    var_dba_flag                 VARCHAR(1);
    var_dest_code                VARCHAR(4);
   /* var_chk_from_date            TIMESTAMP WITHOUT TIME ZONE;
    var_error_msg                VARCHAR(255);*/
    cur1 CURSOR FOR
        SELECT Case_no,
               Transaction_datetime,
               Transaction_type
        FROM Transaction_log
        WHERE Transaction_datetime >= var_prev_from_date
          AND Transaction_datetime < var_prev_to_date
          AND ((Transaction_type = '300') OR (Transaction_type LIKE '33%'))
          AND Cancel_flag IS NULL
          AND Hospital_code = par_hosp_code::VARCHAR;
    sql$rowcount                 BIGINT;
    cur2 CURSOR FOR
        SELECT Case_no,
               Transaction_datetime,
               Transaction_type
        FROM Transaction_log
        WHERE Transaction_datetime >= par_from_date
          AND Transaction_datetime < par_to_date
          AND ((Transaction_type = '300') OR (Transaction_type LIKE '33%'))
          AND Cancel_flag IS NULL
          AND Hospital_code = par_hosp_code::VARCHAR;
begin
	
  
    SELECT 1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
    INTO par_to_date;
    SELECT - 1 * INTERVAL '1 year' + par_from_date::TIMESTAMP
    INTO var_prev_from_date;

    SELECT - 1 * INTERVAL '1 year' + par_to_date::TIMESTAMP
    INTO var_prev_to_date;

   
    /* 20120312 Max, for accurate result of 28 feb in leap year */
    SELECT 0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0
    INTO var_new_attend_tot, var_new_attend_tot_prev, var_reattend_tot, var_reattend_tot_prev, var_ambulance_tot, var_ambulance_tot_prev, var_dead_bef_arrvd, var_dead_bef_arrvd_prev, var_follow_up_tot, var_follow_up_tot_prev, var_gross_tot, var_gross_tot_prev, var_ae_adm_tot, var_ae_adm_tot_prev, var_ae_adm_oth_tot, var_ae_adm_oth_tot_prev;
    /* process current previous month data */
    /* Add hospital code for HPI by ML on 26.07.1999 */
    OPEN cur1;

    WHILE (1 = 1)
        LOOP
            FETCH cur1 INTO var_case_no, var_tx_dt, var_tx_type;

            IF ((CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
                END) = 0) THEN
                BEGIN
                    /* previous total */
                    IF safe_substring(var_tx_type, 1, 2) = '30' THEN
                        BEGIN
                            /* --- Add hospital code for HPI by ML on 26.07.1999 --- */
                            SELECT var_gross_tot_prev + 1
                            INTO var_gross_tot_prev;

                            SELECT AE_case_type,
                                   Ambulance_no,
                                   DBA_flag
                            -- INTO var_ae_case_type, var_amb_no, var_dba_flag
                            INTO result_str_value_1, result_str_value_2, result_str_value_3
                            FROM AE_case_detail
                            WHERE (Case_no = var_case_no)
                              AND (Hospital_code = par_hosp_code);
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                            IF (sql$rowcount = 1) THEN
                                var_ae_case_type := result_str_value_1;
                                var_amb_no := result_str_value_2;
                                var_dba_flag := result_str_value_3;
                                BEGIN
                                    IF var_ae_case_type = 'N' THEN
                                        SELECT var_new_attend_tot_prev + 1
                                        INTO var_new_attend_tot_prev;
                                    ELSE
                                        BEGIN
                                            IF var_ae_case_type = 'F' THEN
                                                SELECT var_follow_up_tot_prev + 1
                                                INTO var_follow_up_tot_prev;
                                            ELSE
                                                SELECT var_reattend_tot_prev + 1
                                                INTO var_reattend_tot_prev;
                                            END IF;
                                        END;
                                    END IF;

                                    IF var_amb_no IS NOT NULL AND COALESCE(var_amb_no, 'null') <> '' THEN
                                        SELECT var_ambulance_tot_prev + 1
                                        INTO var_ambulance_tot_prev;
                                    END IF;

                                    IF var_dba_flag = 'Y' THEN
                                        SELECT var_dead_bef_arrvd_prev + 1
                                        INTO var_dead_bef_arrvd_prev;
                                    END IF;
                                END;
                            END IF;
                        END;
                    ELSE
                        BEGIN
                            /* 33% */
                            /*
                            Script before CPI change
                            *****
                                             select @dest_code = Destination_code from Case
                                             where (Case.Case_no = @case_no) and
                                                    (Case.Discharge_code in ('0','4','9'))
                            *****
                             Changes due to CPI, by man at 25 april 96
                            */
                            /* --- Add hosp code for HPI by ML on 26.07.1999 --- */
                            SELECT Destination_code
                            -- INTO var_dest_code
                            INTO result_str_value_1
                            FROM Case_view
                            WHERE (Case_no = var_case_no)
                              AND (Discharge_code IN ('0', '4', '9') AND
                                   Hospital_code = par_hosp_code);
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                            IF (sql$rowcount = 1) THEN
                                var_dest_code := result_str_value_1;
                                BEGIN
                                    IF var_dest_code = par_hosp_code THEN
                                        SELECT var_ae_adm_tot_prev + 1
                                        INTO var_ae_adm_tot_prev;
                                    ELSE
                                        SELECT var_ae_adm_oth_tot_prev + 1
                                        INTO var_ae_adm_oth_tot_prev;
                                    END IF;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            ELSE
                EXIT;
            END IF;
        END LOOP;
    /* end while loop */
    /* process current month */
    CLOSE cur1;
    /* --- Add hospital code for HPI by ML on 26.07.1999 */
    OPEN cur2;

    WHILE (1 = 1)
        LOOP
            FETCH cur2 INTO var_case_no, var_tx_dt, var_tx_type;

            IF ((CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
                END) = 0) THEN
                BEGIN
                    IF var_tx_dt >= par_from_date THEN /* current total */
                        BEGIN
                            IF safe_substring(var_tx_type, 1, 2) = '30' THEN
                                BEGIN
                                    SELECT var_gross_tot + 1
                                    INTO var_gross_tot;

                                    SELECT AE_case_type,
                                           Ambulance_no,
                                           DBA_flag
                                    -- INTO var_ae_case_type, var_amb_no, var_dba_flag
                                    INTO result_str_value_1, result_str_value_2, result_str_value_3
                                    FROM AE_case_detail
                                    WHERE (Case_no = var_case_no)
                                      AND (Hospital_code = par_hosp_code);
                                    /* --- Add hosp code for HPI by ML on 26.07.1999 --- */
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                    IF (sql$rowcount = 1) THEN
                                        var_ae_case_type := result_str_value_1;
                                        var_amb_no := result_str_value_2;
                                        var_dba_flag := result_str_value_3;
                                        BEGIN
                                            IF var_ae_case_type = 'N' THEN
                                                SELECT var_new_attend_tot + 1
                                                INTO var_new_attend_tot;
                                            ELSE
                                                BEGIN
                                                    IF var_ae_case_type = 'F' THEN
                                                        SELECT var_follow_up_tot + 1
                                                        INTO var_follow_up_tot;
                                                    ELSE
                                                        SELECT var_reattend_tot + 1
                                                        INTO var_reattend_tot;
                                                    END IF;
                                                END;
                                            END IF;

                                            IF var_amb_no IS NOT NULL AND COALESCE(var_amb_no, 'null') <> '' THEN
                                                SELECT var_ambulance_tot + 1
                                                INTO var_ambulance_tot;
                                            END IF;

                                            IF var_dba_flag = 'Y' THEN
                                                SELECT var_dead_bef_arrvd + 1
                                                INTO var_dead_bef_arrvd;
                                            END IF;
                                        END;
                                    END IF;
                                END;
                            ELSE
                                BEGIN
                                    /*
                                    Script before CPI change
                                    *****
                                                     select @dest_code = Destination_code from Case
                                                     where (Case.Case_no = @case_no) and
                                                            (Case.Discharge_code in ('0','4','9'))
                                    *****
                                     Changes due to CPI, by man at 25 april 96
                                    */
                                    /* --- Add hosp code for HPI by ML on 26.07.1999 --- */
                                    SELECT Destination_code
                                    -- INTO var_dest_code
                                    INTO result_str_value_1
                                    FROM Case_view
                                    WHERE (Case_no = var_case_no)
                                      AND (Discharge_code IN ('0', '4', '9'))
                                      AND (Hospital_code = par_hosp_code);
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                    IF (sql$rowcount = 1) THEN
                                        var_dest_code := result_str_value_1;
                                        BEGIN
                                            IF var_dest_code = par_hosp_code THEN
                                                SELECT var_ae_adm_tot + 1
                                                INTO var_ae_adm_tot;
                                            ELSE
                                                SELECT var_ae_adm_oth_tot + 1
                                                INTO var_ae_adm_oth_tot;
                                            END IF;
                                        END;
                                    END IF;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            ELSE
                EXIT;
            END IF;
        END LOOP; /* end while loop */
    CLOSE cur2;

    IF var_new_attend_tot_prev > 0 THEN
        SELECT 1.0 * (var_ae_adm_tot_prev + var_ae_adm_oth_tot_prev) / var_new_attend_tot_prev
        INTO var_attend_hospitalised_prev;
    END IF;

    IF var_new_attend_tot > 0 THEN
        SELECT 1.0 * (var_ae_adm_tot + var_ae_adm_oth_tot) / var_new_attend_tot
        INTO var_attend_hospitalised;
    END IF;
    OPEN p_refcur FOR
        SELECT DATE_PART('days', par_to_date::TIMESTAMP::DATE::TIMESTAMP - par_from_date::TIMESTAMP::DATE::TIMESTAMP),
               DATE_PART('days',
                         var_prev_to_date::TIMESTAMP::DATE::TIMESTAMP - var_prev_from_date::TIMESTAMP::DATE::TIMESTAMP),
               COALESCE(var_new_attend_tot, 0),
               COALESCE(var_new_attend_tot_prev, 0),
               COALESCE(var_reattend_tot, 0),
               COALESCE(var_reattend_tot_prev, 0),
               COALESCE(var_ambulance_tot, 0),
               COALESCE(var_ambulance_tot_prev, 0),
               COALESCE(var_dead_bef_arrvd, 0),
               COALESCE(var_dead_bef_arrvd_prev, 0),
               COALESCE(var_follow_up_tot, 0),
               COALESCE(var_follow_up_tot_prev, 0),
               COALESCE(var_gross_tot, 0),
               COALESCE(var_gross_tot_prev, 0),
               COALESCE(var_ae_adm_tot, 0),
               COALESCE(var_ae_adm_tot_prev, 0),
               COALESCE(var_ae_adm_oth_tot, 0),
               COALESCE(var_ae_adm_oth_tot_prev, 0),
               COALESCE(var_attend_hospitalised, 0),
               COALESCE(var_attend_hospitalised_prev, 0);
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_ae_statistics" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
