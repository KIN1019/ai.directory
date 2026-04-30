CREATE OR REPLACE function hasp_ae_unplan_readm(IN par_hosp_code CHAR, IN par_from_date TIMESTAMP WITHOUT TIME ZONE, IN par_to_date TIMESTAMP WITHOUT TIME ZONE)
RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/*
- Unplanned re-admission of A&E

    Parameters to be used :-
	     Description               Data Type
	--------------------	       -------------
   1. Hospital code               VARCHAR(3)
	2. From date                   datetime
	3. To date                     datetime

   Modification History:
   ---------------------
     26.07.1999 - Add hospital code for HPI by Mabel LAU
*/
DECLARE
    var_case_no VARCHAR(12);
    var_hkid VARCHAR(12);
    var_prev_disc_dt TIMESTAMP WITHOUT TIME ZONE;
    var_adm_dt TIMESTAMP WITHOUT TIME ZONE;
    var_begin_dt TIMESTAMP WITHOUT TIME ZONE;
    var_end_dt TIMESTAMP WITHOUT TIME ZONE;
    var_total_attend INTEGER;
    var_24_hr_ae_readm INTEGER;
    var_48_hr_ae_readm INTEGER;
    var_72_hr_ae_readm INTEGER;
    var_ae_case_type VARCHAR(1);
	p_refcur refcursor;
    cur1 CURSOR FOR
    SELECT
        t.Case_no, c.HKID, Admission_datetime
        FROM Transaction_log AS t, Case_view AS c
        WHERE Transaction_datetime >= par_from_date AND Transaction_datetime < par_to_date AND Transaction_type = '300' AND From_ward_code = 'AE01' AND Cancel_flag IS NULL AND t.Case_no = c.Case_no AND t.Hospital_code = par_hosp_code AND c.Hospital_code = par_hosp_code;
    sql$rowcount BIGINT;
BEGIN
    SELECT
        1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
        INTO par_to_date;
    SELECT
        0, 0, 0, 0
        INTO var_24_hr_ae_readm, var_48_hr_ae_readm, var_72_hr_ae_readm, var_total_attend;
    /*
    Updated by chuls @960520 for better performance
    declare CUR1 cursor for
    select Case.Case_no, HKID, Admission_datetime
    from Case
    where (Admission_datetime >= @from_date) and
          (Admission_datetime < @to_date) and
          (Case_type = 'A')
    */
    /* Add hospital code for HPI by ML on 26.07.1999 */
    OPEN cur1;

    WHILE (1 = 1) LOOP
        FETCH cur1 INTO var_case_no, var_hkid, var_adm_dt;

        IF ((CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0) THEN
            BEGIN
                /* ************************************* */
                /* ignore ae follow up case */
                /* ************************************* */
                /* --- Add hospital code for HPI by ML on 26.07.1999 --- */
                SELECT
                    AE_case_type
                    INTO var_ae_case_type
                    FROM AE_case_detail
                    WHERE Case_no = var_case_no AND Hospital_code = par_hosp_code;

                IF coalesce(var_ae_case_type, '') <> 'F' THEN
                    BEGIN
                        SELECT
                            var_adm_dt
                            INTO var_end_dt;
                        SELECT
                            - 3 * INTERVAL '1 day' + var_adm_dt::TIMESTAMP
                            INTO var_begin_dt;
                        /*
                        The Case table of the from clause was
                                       substituted by Case_view
                        	            by Watson Tsui on 1996/6/14
                        	            due to CPI
                        */
                        /*
                        select @prev_disc_dt = max(Admission_datetime)
                        from Case
                        */
                        SELECT
                            MAX(Admission_datetime)
                            INTO var_prev_disc_dt
                            FROM Case_view AS c
                            WHERE (HKID = var_hkid) AND (Case_type = 'A') AND (Admission_datetime IS NOT NULL) AND (Admission_datetime BETWEEN var_begin_dt AND var_end_dt) AND (coalesce(c.Case_no, 'null') <> var_case_no) AND (c.Hospital_code = par_hosp_code);
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF (sql$rowcount = 1) THEN
                            BEGIN
                                IF (1 * INTERVAL '1 day' + var_prev_disc_dt::TIMESTAMP > var_adm_dt) THEN
                                    SELECT
                                        var_24_hr_ae_readm + 1
                                        INTO var_24_hr_ae_readm;
                                ELSE
                                    BEGIN
                                        IF (2 * INTERVAL '1 day' + var_prev_disc_dt::TIMESTAMP > var_adm_dt) THEN
                                            SELECT
                                                var_48_hr_ae_readm + 1
                                                INTO var_48_hr_ae_readm;
                                        ELSE
                                            IF (3 * INTERVAL '1 day' + var_prev_disc_dt::TIMESTAMP > var_adm_dt) THEN
                                                SELECT
                                                    var_72_hr_ae_readm + 1
                                                    INTO var_72_hr_ae_readm;
                                            END IF;
                                        END IF;
                                    END;
                                END IF;
                                SELECT
                                    var_total_attend + 1
                                    INTO var_total_attend;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        ELSE
            EXIT;
        END IF;
    END LOOP;
    CLOSE cur1;
    OPEN p_refcur FOR
    SELECT
        var_24_hr_ae_readm, var_48_hr_ae_readm, var_72_hr_ae_readm, var_total_attend;
    return next p_refcur;
END;
$function$
;

;ALTER FUNCTION "hasp_ae_unplan_readm" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
