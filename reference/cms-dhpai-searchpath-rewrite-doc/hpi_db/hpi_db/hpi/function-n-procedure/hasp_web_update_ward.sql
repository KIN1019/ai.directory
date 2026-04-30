-- DROP PROCEDURE hasp_web_update_ward(inout int4, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hasp_web_update_ward(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_input_ward_code character varying, IN par_input_effective_date timestamp without time zone, IN par_input_org_effective_date timestamp without time zone, IN par_input_active_status character varying, IN par_input_desc character varying, IN par_input_treat_loc character varying, IN par_input_loc character varying, IN par_input_care_category character varying, IN par_input_new character varying, IN par_input_wristband_no integer DEFAULT NULL::integer, IN par_input_loc_code character varying DEFAULT NULL::character varying, IN par_isolation_type character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
    /* add hosp code input parm for HPI by ML on 10.08.1999 */
/* --//20161207/Ray/Added new column for HI isolation ward enhancement */
DECLARE
    var_return_code           INTEGER;
    var_prev_treatment_loc    VARCHAR(4);
    var_prev_desc             VARCHAR(30);
    var_prev_loc              VARCHAR(20);
    var_prev_care_category    VARCHAR(1);
    var_dsp_dt                VARCHAR(10);
    var_prev_active_status    VARCHAR(1);
    var_prev_effective_date   TIMESTAMP WITHOUT TIME ZONE;
    var_last_eff_dt           TIMESTAMP WITHOUT TIME ZONE;
    var_prev_status           VARCHAR(1);
    var_next_active_status    VARCHAR(1);
    var_next_effective_date   TIMESTAMP WITHOUT TIME ZONE;
    var_error                 INTEGER;
    var_eis_spec              VARCHAR(3);
    var_loc_status            VARCHAR(1);
    var_count_exist_mixed     INTEGER;
    var_bed_allocation_enable VARCHAR(1);
    sql$rowcount              BIGINT;
BEGIN
    /* *************************************** */
    /* declare local variable */
    /* *************************************** */
    /* --declare @hosp_code           VARCHAR(03), */
    /* remarked since hosp code is input parm */
    /*
    PasCr-2016/00095 Add checking and reject change
    if there is existing ward specialty mapped to MIX
    but treatment location is not in PRI/SAW/CUS

    FP: 	Ray HA
    Date: 	24/08/2016
    */
    /* ************************************** */
    /* check input parameter */
    /* ************************************** */
    IF par_input_ward_code IS NULL THEN
        BEGIN
            RAISE EXCEPTION 'Ward code can not be null' USING ERRCODE := '20002';
        END;
    END IF;

    IF par_input_desc IS NULL THEN
        BEGIN
            RAISE EXCEPTION 'Description can not be null' USING ERRCODE := '20002';
        END;
    END IF;

    IF par_input_active_status IS NULL THEN
        BEGIN
            RAISE EXCEPTION 'Active_status can not be null' USING ERRCODE := '20002';
        END;
    END IF;

    IF par_input_effective_date IS NULL THEN
        BEGIN
            RAISE EXCEPTION 'Effective Date can not be null' USING ERRCODE := '20002';
        END;
    END IF;

    /* ** 20050207 * */
    SELECT RTRIM(LTRIM(par_input_care_category))
    INTO par_input_care_category;

    IF par_input_care_category IS NULL THEN
        BEGIN
            RAISE EXCEPTION 'Care Category cannot be empty' USING ERRCODE := '20002';
        END;
    END IF;

    IF (par_input_wristband_no IS NOT NULL) AND ((par_input_wristband_no < 0) OR (par_input_wristband_no > 10)) THEN
        BEGIN
            RAISE EXCEPTION 'Number of Wristband should between 0 - 10 ' USING ERRCODE := '20002';
        END;
    END IF;

    IF par_input_treat_loc IS NOT NULL THEN
        BEGIN
            SELECT IMIS_code
            INTO var_eis_spec
            FROM (SELECT IMIS_code,
                         Specialty_code,
                         Effective_date
                  FROM Specialty) AS ungrouped_query
                     INNER JOIN (SELECT Specialty_code,
                                        MAX(Effective_date) AS max_1
                                 FROM Specialty
                                 WHERE Specialty_code = par_input_treat_loc
                                 GROUP BY Specialty_code) AS grouped_query
                                ON (ungrouped_query.Specialty_code = grouped_query.Specialty_code
                                    OR (ungrouped_query.Specialty_code IS NULL AND
                                        grouped_query.Specialty_code IS NULL))
            WHERE Effective_date = max_1;

            IF ((var_eis_spec = 'ICU' AND coalesce(par_input_care_category, 'null') <> 'U')
                OR (var_eis_spec = 'HDU' AND coalesce(par_input_care_category, 'null') <> 'H')
                OR (var_eis_spec IN ('PIC', 'NIC') AND coalesce(par_input_care_category, 'null') <> 'X')
                OR (var_eis_spec = 'CCU' AND par_input_care_category NOT IN ('X', 'Y'))
                OR (var_eis_spec = 'SCB' AND coalesce(par_input_care_category, 'null') <> 'A')) THEN
                BEGIN
                    RAISE EXCEPTION 'Care Category does not match with Treatment Location' USING ERRCODE := '20002';
                END;
            END IF;
        END;
    END IF;
    /* ** Rule 2 ** */
    /*
    select @hosp_code = Hospital_code
    from Hospital
    */
    SELECT Text_value
    INTO var_bed_allocation_enable
    FROM Hospital_control
    WHERE Type = 'bed_allocation';

    IF par_input_active_status = 'D' AND var_bed_allocation_enable = 'Y' THEN
        BEGIN
            IF EXISTS (SELECT *
                       FROM bed_history
                       WHERE hospital_code = par_hosp_code
                         AND ward_code = par_input_ward_code
                         AND effective_datetime <= par_input_effective_date
                       GROUP BY hospital_code, ward_code
                       HAVING effective_datetime = MAX(effective_datetime)
                          AND active_status = 'A') THEN
                BEGIN
                    RAISE EXCEPTION 'Ward cannot be inactive where active bed exist' USING ERRCODE := '20002';
                END;
            END IF;
        END;
    END IF;

    /* *End - 20050207* */
    /* check for active for location */
    IF par_input_loc_code IS NOT NULL AND coalesce(par_input_active_status, 'null') <> 'D' THEN
        BEGIN
            SELECT active_status
            INTO var_loc_status
            FROM (SELECT active_status,
                         effective_date,
                         MAX(effective_date) OVER (PARTITION BY hospital_code, location_code) AS max_effective_date
                  FROM hospital_location
                  WHERE hospital_code = par_hosp_code
                    AND location_code = par_input_loc_code
                    AND effective_date <= par_input_effective_date) AS subquery
            WHERE effective_date = max_effective_date;

            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            IF sql$rowcount = 0 THEN
                SELECT 'D'
                INTO var_loc_status;
            END IF;

            IF coalesce(var_loc_status, 'null') <> 'A' THEN
                BEGIN
                    RAISE EXCEPTION 'Ward Location is inactive on the specified date' USING ERRCODE := '20002';
                END;
            END IF;
        END;
    END IF;
    /* ********************************* */
    /* new created */
    /* ********************************* */
    IF par_input_org_effective_date IS NULL THEN
        BEGIN
            /* * Modified by Winnie on 11 Feb * */
            /* * care category begin effective * */
            /* * new ward code must not exists in table * */
            /* * new history must not exists in table * */
            /* add hosp code for HPI by ML on 10.08.1999 */
            /* * new added row's effective date must be the latest* */
            /* add hosp code for HPI by ML on 10.08.1999 */
            /* * new added row's effective date must later than today * */
            /* if reactivate or add new ward then effective date can be today */
            BEGIN
                IF par_input_care_category IS NULL THEN
                    BEGIN
                        RAISE EXCEPTION 'Care Category can not be null' USING ERRCODE := '20002';
                    END;
                END IF;

                IF par_input_new = 'Y' THEN
                    BEGIN
                        /* add hosp code for HPI by ML on 10.08.1999 */
                        IF EXISTS (SELECT *
                                   FROM Ward
                                   WHERE Ward_code = par_input_ward_code
                                     AND Hospital_code = par_hosp_code) THEN
                            BEGIN
                                RAISE NOTICE 'Ward code already exist...';
                                RAISE EXCEPTION 'Ward code already exist' USING ERRCODE := '20002';
                            END;
                        END IF;
                    END;
                END IF;

                IF EXISTS (SELECT *
                           FROM Ward
                           WHERE Ward_code = par_input_ward_code
                             AND Effective_date = par_input_effective_date
                             AND Hospital_code = par_hosp_code) THEN
                    BEGIN
                        RAISE EXCEPTION 'Ward history already exist' USING ERRCODE := '20002';
                    END;
                END IF;

                SELECT MAX(Effective_date)
                INTO var_last_eff_dt
                FROM Ward
                WHERE Ward_code = par_input_ward_code
                  AND Hospital_code = par_hosp_code;

                IF par_input_effective_date <= var_last_eff_dt AND var_last_eff_dt IS NOT NULL THEN
                    BEGIN
                        SELECT TO_CHAR(var_last_eff_dt::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY')
                        INTO var_dsp_dt;
                        RAISE EXCEPTION '%', format('Effective_date must later than %s', var_dsp_dt) USING ERRCODE := '20002';
                    END;
                END IF;

                SELECT Active_status
                INTO var_prev_status
                FROM (SELECT Active_status,
                             ROW_NUMBER() OVER (PARTITION BY Ward_code ORDER BY Effective_date DESC) AS rn
                      FROM Ward
                      WHERE Ward_code = par_input_ward_code
                        AND Effective_date < par_input_effective_date
                        AND Hospital_code = par_hosp_code) sub
                WHERE rn = 1;

                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                IF sql$rowcount = 0 THEN
                    SELECT NULL
                    INTO var_prev_status;
                END IF;
            END;
            /* if datediff(dd,getdate(),@input_effective_date) <= 0 */

            IF (par_input_active_status = 'A' AND
                ((coalesce(var_prev_status, 'null') <> 'A' AND DATE_PART('day', par_input_effective_date::timestamp::date::timestamp
                    - CURRENT_DATE::timestamp::date::timestamp) < 0) OR
                 (var_prev_status = 'A' AND DATE_PART('day', par_input_effective_date::timestamp::date::timestamp
                     - CURRENT_DATE::timestamp::date::timestamp) <= 0))) OR
               (coalesce(par_input_active_status, 'null') <> 'A' AND
                DATE_PART('day', par_input_effective_date::timestamp::date::timestamp
                    - CURRENT_DATE::timestamp::date::timestamp) <= 0) THEN
                BEGIN
                    SELECT TO_CHAR(localtimestamp::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY')
                    INTO var_dsp_dt;
                    RAISE EXCEPTION '%', format('Effective_date must later than %s', var_dsp_dt) USING ERRCODE := '20002';
                END;
            END IF;

            IF par_input_active_status = 'D' THEN
                BEGIN
                    /* * no two continuous rows with Inactive status  * */
                    /* add hosp code for HPI by ML on 10.08.1999 */
                    IF EXISTS (SELECT *
                               FROM Ward
                               WHERE Ward_code = par_input_ward_code
                                 AND Effective_date = var_last_eff_dt
                                 AND Active_status = 'D'
                                 AND Hospital_code = par_hosp_code) THEN
                        BEGIN
                            RAISE EXCEPTION 'Invalid insert of inactive row' USING ERRCODE := '20002';
                        END;
                    END IF;
                    /* *** first hist of ward should not be 'D' **** */
                    /* add hosp code for HPI by ML on 10.08.1999 */
                    IF NOT EXISTS (SELECT *
                                   FROM Ward
                                   WHERE Ward_code = par_input_ward_code
                                     AND Hospital_code = par_hosp_code) THEN
                        BEGIN
                            RAISE EXCEPTION 'Active Status should not be ''D'' for first row of Ward histo' USING ERRCODE := '20002';
                        END;
                    END IF;
                    /* *** inserted treat_loc,loc, desc and care category ** */
                    /* *** should equal to previous ** */
                    /* add hosp code for HPI by ML on 10.08.1999 */
                    SELECT Treatment_location,
                           Description,
                           Location,
                           Care_category
                    INTO var_prev_treatment_loc, var_prev_desc, var_prev_loc, var_prev_care_category
                    FROM Ward
                    WHERE Ward_code = par_input_ward_code
                      AND Effective_date = var_last_eff_dt
                      AND Hospital_code = par_hosp_code;

                    IF coalesce(var_prev_desc, 'null') <> coalesce(par_input_desc, 'null') THEN
                        BEGIN
                            IF par_input_desc IS NULL THEN
                                SELECT 'NULL'
                                INTO par_input_desc;
                            END IF;
                            RAISE EXCEPTION '%', format('Description should not be %s', par_input_desc) USING ERRCODE := '20002';
                        END;
                    END IF;

                    IF coalesce(var_prev_loc, 'null') <> coalesce(par_input_loc, 'null') THEN
                        BEGIN
                            IF par_input_loc IS NULL THEN
                                SELECT 'NULL'
                                INTO par_input_loc;
                            END IF;
                            RAISE EXCEPTION '%', format('Location should not be %s', par_input_loc) USING ERRCODE := '20002';
                        END;
                    END IF;

                    IF coalesce(var_prev_treatment_loc, 'null') <> coalesce(par_input_treat_loc, 'null') THEN
                        BEGIN
                            IF par_input_treat_loc IS NULL THEN
                                SELECT 'NULL'
                                INTO par_input_treat_loc;
                            END IF;
                            RAISE EXCEPTION '%', format('Treatment Location should not be %s', par_input_treat_loc) USING ERRCODE := '20002';
                        END;
                    END IF;

                    IF (coalesce(var_prev_care_category, 'null') <> coalesce(par_input_care_category, 'null')) AND
                       (var_prev_care_category IS NOT NULL) THEN
                        BEGIN
                            RAISE EXCEPTION 'Care Category should be the same as previous active row' USING ERRCODE := '20002';
                        END;
                    END IF;
                END;
            END IF;
            /*
            PasCr-2016/00095 Add checking and reject change
            if there is existing ward specialty mapped to MIX
            but treatment location is not in PRI/SAW/CUS

            FP: 	Ray HA
            Date: 	24/08/2016?
            */
            CALL hasp_web_chk_spec_mix_eis_code(var_return_code, 'U', par_hosp_code, par_input_ward_code, NULL,
                                                par_input_treat_loc,
                                                par_input_effective_date, var_count_exist_mixed, NULL);

            IF var_count_exist_mixed > 0 THEN
                BEGIN
                    RAISE EXCEPTION 'Invalid Treatment Location' USING ERRCODE := '20003';
                END;
            END IF;
            /* *** insert new created row *** */
            /*
            select @hosp_code = Hospital_code
            from Hospital
            */
            /* remarked for HPI by ML on 10.08.1999 */
            /* ************************************************* */
            /* ** for new table structure 		  					 ** */
            /* ** Modified on 070497 by Winnie					*** */
            /* ** due to new column added - Default_specialty ** */
            /* ************************************************* */
            /* ------------------------------------------- */
            /* modified to insert ward instead of Ward */
            /* for HPI by ML on 10.08.1999 */
            /* ------------------------------------------- */
            /*
            insert Ward(Hospital_code, Ward_code, Description, Treatment_location, Location, Active_status, Effective_date, User_define, Care_category)
            values(@hosp_code, @input_ward_code, @input_desc, @input_treat_loc,
                      @input_loc, @input_active_status,
                      @input_effective_date, 'Y',@input_care_category)
            */
            BEGIN
                INSERT INTO ward (hospital_code, ward_code, description, treatment_location, location,
                                  active_status, effective_date, user_define, care_category, wristband_no,
                    /* --//20161207/Ray/Added new column for HI isolation ward enhancement */
                                  isolation_type)
                VALUES (par_hosp_code, par_input_ward_code, par_input_desc, par_input_treat_loc, par_input_loc,
                        par_input_active_status, par_input_effective_date, 'Y', par_input_care_category,
                        par_input_wristband_no,
                           /* --//20161207/Ray/Added new column for HI isolation ward enhancement */
                        par_isolation_type);
                var_error = 0;
                --             EXCEPTION
--                 WHEN OTHERS THEN
--                     raise ;
            END;

            /* insert ward_location record for new ward entry */
            BEGIN
                INSERT INTO ward_location (hospital_code, ward_code, location_code, active_status, effective_date)
                VALUES (par_hosp_code, par_input_ward_code, par_input_loc_code, par_input_active_status,
                        par_input_effective_date);
                var_error = 0;
                --             EXCEPTION
--                 WHEN OTHERS THEN
--                     raise ;
            END;

        END;
    ELSE
        BEGIN
            /* * check existences of updated row * */
            /* add hosp code for HPI by ML on 10.08.1999 */
            IF NOT EXISTS (SELECT *
                           FROM Ward
                           WHERE Ward_code = par_input_ward_code
                             AND Effective_date = par_input_org_effective_date
                             AND Hospital_code = par_hosp_code) THEN
                BEGIN
                    RAISE EXCEPTION 'Ward History not found' USING ERRCODE := '20002';
                END;
            END IF;
            /* add hosp code for HPI by ML on 10.08.1999 */
            SELECT MAX(Effective_date)
            INTO var_last_eff_dt
            FROM Ward
            WHERE Ward_code = par_input_ward_code
              AND Hospital_code = par_hosp_code;
            /*
            reject update if effective date on or before today
            modified by L S Chu on 30/5/2003
            */
            IF DATE_PART('days', par_input_org_effective_date::timestamp::date::timestamp
                - localtimestamp ::timestamp :: date :: timestamp) <= 0 THEN
                BEGIN
                    RAISE EXCEPTION 'Update to past information is not allowed' USING ERRCODE := '20002';
                END;
            END IF;
            /*
            PasCr-2016/00095 Add checking and reject change
            if there is existing ward specialty mapped to MIX
            but treatment location is not in PRI/SAW/CUS

            FP: 	Ray HA
            Date: 	24/08/2016
            */
            CALL hasp_web_chk_spec_mix_eis_code(var_return_code, 'U', par_hosp_code, par_input_ward_code, NULL,
                                                par_input_treat_loc,
                                                par_input_effective_date, var_count_exist_mixed, NULL);

            IF var_count_exist_mixed > 0 THEN
                BEGIN
                    RAISE EXCEPTION 'Invalid Treatment Location' USING ERRCODE := '20003';
                END;
            END IF;

            /* * not last row or last row with effective_dt < today * */
            IF (par_input_org_effective_date < var_last_eff_dt)
                OR
               (DATE_PART('days', par_input_org_effective_date::date::timestamp
                   - localtimestamp::date::timestamp) <= 0) THEN
                BEGIN
                    /* add hosp code for HPI by ML on 10.08.1999 */
                    SELECT Active_status,
                           Effective_date
                    INTO var_next_active_status, var_next_effective_date
                    FROM (SELECT Active_status,
                                 Effective_date,
                                 Ward_code
                          FROM Ward) AS ungrouped_query
                             INNER JOIN (SELECT Ward_code,
                                                MIN(Effective_date) AS min_1
                                         FROM Ward
                                         WHERE Ward_code = par_input_ward_code
                                           AND Effective_date > par_input_org_effective_date
                                           AND Hospital_code = par_hosp_code
                                         GROUP BY Ward_code) AS grouped_query
                                        ON (ungrouped_query.Ward_code = grouped_query.Ward_code
                                            OR
                                            (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL))
                    WHERE Effective_date = min_1;

                    IF var_next_active_status = 'D' THEN
                        BEGIN
                            /* ------------------------------------------------- */

                            /* change to update ward for HPI by ML on 10.08.1999 */
                            /* ------------------------------------------------- */

                            /*
                            update Ward
                            set Description = @input_desc
                            where Ward_code = @input_ward_code and
                            Effective_date = @next_effective_date
                            */
                            BEGIN
                                UPDATE ward
                                SET description = par_input_desc
                                WHERE ward_code = par_input_ward_code
                                  AND effective_date = var_next_effective_date
                                  AND hospital_code = par_hosp_code;
                                var_error = 0;
                                --                             EXCEPTION
--                                 WHEN OTHERS THEN
--                                     raise ;
                            END;
                        END;
                    END IF;
                    /* ------------------------------------------------- */

                    /* change to update ward for HPI by ML on 10.08.1999 */
                    /* ------------------------------------------------- */

                    /*
                    update Ward
                    set Description = @input_desc
                    where Ward_code = @input_ward_code and
                    Effective_date = @input_org_effective_date
                    */
                    BEGIN
                        UPDATE ward
                        SET description = par_input_desc
                        WHERE ward_code = par_input_ward_code
                          AND effective_date = par_input_org_effective_date
                          AND hospital_code = par_hosp_code;
                        var_error = 0;
                        --                     EXCEPTION
--                         WHEN OTHERS THEN
--                             raise ;
                    END;
                    /* add upadte for ward_location */
                    BEGIN
                        UPDATE ward_location
                        SET location_code = par_input_loc_code
                        WHERE hospital_code = par_hosp_code
                          AND ward_code = par_input_ward_code
                          AND effective_date = par_input_org_effective_date;
                        var_error = 0;
                        --                     EXCEPTION
--                         WHEN OTHERS THEN
--                             raise ;
                    END;
                END;
            END IF;
            /* * last row with future effective date * */
            IF (par_input_org_effective_date = var_last_eff_dt)
                AND
               (DATE_PART('days', par_input_org_effective_date::timestamp::date::timestamp
                   - localtimestamp::timestamp::date::timestamp) > 0) THEN
                BEGIN
                    /* add hosp code for HPI by ML on 10.08.1999 */
                    SELECT Effective_date
                    INTO var_prev_effective_date
                    FROM (SELECT Effective_date,
                                 Ward_code
                          FROM Ward) AS ungrouped_query
                             INNER JOIN (SELECT Ward_code,
                                                MAX(Effective_date) AS max_1
                                         FROM Ward
                                         WHERE Ward_code = par_input_ward_code
                                           AND Effective_date < var_last_eff_dt
                                           AND Hospital_code = par_hosp_code
                                         GROUP BY Ward_code) AS grouped_query
                                        ON (ungrouped_query.Ward_code = grouped_query.Ward_code
                                            OR
                                            (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL))
                    WHERE Effective_date = max_1;
                    /* * input eff_dt should later than the eff_dt of previous * */
                    IF par_input_effective_date <= var_prev_effective_date THEN
                        BEGIN
                            SELECT TO_CHAR(var_prev_effective_date::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY')
                            INTO var_dsp_dt;
                            RAISE EXCEPTION '%', format('Effective_date should later than %s', var_dsp_dt) USING ERRCODE := '20002';
                        END;
                    END IF;
                    /* * input eff_dt should later than today * */	
                    IF par_input_effective_date <> par_input_org_effective_date THEN
                        BEGIN
                            /* if reactivate or add new ward then effective date can be today */
                            BEGIN
                                SELECT Active_status
                                INTO var_prev_status
                                FROM (SELECT Active_status,
                                             Ward_code,
                                             Effective_date
                                      FROM Ward) AS ungrouped_query
                                         INNER JOIN (SELECT Ward_code,
                                                            MAX(Effective_date) AS max_1
                                                     FROM Ward
                                                     WHERE Ward_code = par_input_ward_code
                                                       AND Effective_date < par_input_effective_date
                                                       AND Hospital_code = par_hosp_code
                                                     GROUP BY Ward_code) AS grouped_query
                                                    ON (ungrouped_query.Ward_code = grouped_query.Ward_code
                                                        OR
                                                        (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL))
                                WHERE Effective_date = max_1;
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                IF sql$rowcount = 0 THEN
                                    SELECT NULL
                                    INTO var_prev_status;
                                END IF;
                            END;
                            /* if datediff(dd, getdate(),@input_effective_date) <= 0 */

                            IF (par_input_active_status = 'A' AND
                                ((coalesce(var_prev_status, 'null') <> 'A' AND
                                  DATE_PART('day', par_input_effective_date::timestamp::date::timestamp
                                      - CURRENT_DATE::timestamp::date::timestamp) < 0) OR
                                 (var_prev_status = 'A' AND
                                  DATE_PART('day', par_input_effective_date::timestamp::date::timestamp
                                      - CURRENT_DATE::timestamp::date::timestamp) <= 0))) OR
                               (coalesce(par_input_active_status, 'null') <> 'A' AND
                                DATE_PART('day', par_input_effective_date::timestamp::date::timestamp
                                    - CURRENT_DATE::timestamp::date::timestamp) <= 0) THEN
                                BEGIN
                                    SELECT TO_CHAR(localtimestamp::TIMESTAMP WITHOUT TIME ZONE, 'DD/MM/YYYY')
                                    INTO var_dsp_dt;
                                    RAISE EXCEPTION '%', format('Effective_date must later than %s', var_dsp_dt) USING ERRCODE := '20002';
                                END;
                            END IF;
                        END;
                    END IF;

                    IF par_input_active_status = 'A' THEN
                        BEGIN
                            /* ------------------------------------------------- */

                            /* change to update ward for HPI by ML on 10.08.1999 */
                            /* ------------------------------------------------- */

                            /*
                            update Ward
                                        set Description = @input_desc,
                                             Treatment_location = @input_treat_loc,
                                            Location = @input_loc,
                                            Active_status = @input_active_status,
                                            Effective_date = @input_effective_date,
                                              Care_category = @input_care_category
                                        where Ward_code = @input_ward_code and
                                              Effective_date = @input_org_effective_date
                            */
                            BEGIN
                                UPDATE ward
                                SET description        = par_input_desc,
                                    treatment_location = par_input_treat_loc,
                                    location           = par_input_loc,
                                    active_status      = par_input_active_status,
                                    effective_date     = par_input_effective_date,
                                    care_category      = par_input_care_category,
                                    wristband_no       = par_input_wristband_no,
                                    /* --//20161207/Ray/Added new column for HI isolation ward enhancement */
                                    isolation_type     = par_isolation_type
                                WHERE ward_code = par_input_ward_code
                                  AND effective_date = par_input_org_effective_date
                                  AND hospital_code = par_hosp_code;
                                var_error = 0;
                                --                             EXCEPTION
--                                 WHEN OTHERS THEN
--                                     raise ;
                            END;

                            /* add upadte for ward_location */
                            BEGIN
                                UPDATE ward_location
                                SET location_code  = par_input_loc_code,
                                    active_status  = par_input_active_status,
                                    effective_date = par_input_effective_date
                                WHERE hospital_code = par_hosp_code
                                  AND ward_code = par_input_ward_code
                                  AND effective_date = par_input_org_effective_date;
                                var_error = 0;
                                --                             EXCEPTION
--                                 WHEN OTHERS THEN
--                                     raise ;
                            END;

                        END;
                    END IF;

                    IF par_input_active_status = 'D' THEN
                        BEGIN
                            /* add hosp code for HPI by ML on 10.08.1999 */
                            SELECT Active_status,
                                   Effective_date
                            INTO var_prev_active_status, var_prev_effective_date
                            FROM (SELECT Active_status,
                                         Effective_date,
                                         Ward_code
                                  FROM Ward) AS ungrouped_query
                                     INNER JOIN (SELECT Ward_code,
                                                        MAX(Effective_date) AS max_1
                                                 FROM Ward
                                                 WHERE Ward_code = par_input_ward_code
                                                   AND Effective_date < par_input_org_effective_date
                                                   AND Hospital_code = par_hosp_code
                                                 GROUP BY Ward_code) AS grouped_query
                                                ON (ungrouped_query.Ward_code = grouped_query.Ward_code OR
                                                    (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL))
                            WHERE Effective_date = max_1;
                            /* * 1st row of history's Active status should not be D * */
                            IF var_prev_active_status IS NULL THEN
                                BEGIN
                                    RAISE EXCEPTION 'Active Status should not equal to ''D'' for first row of ward histo' USING ERRCODE := '20002';
                                END;
                            END IF;
                            /* * no two continuous history has Inactive status * */
                            IF var_prev_active_status = 'D' THEN
                                BEGIN
                                    RAISE EXCEPTION 'Invalid update Active Status to ''D' USING ERRCODE := '20002';
                                END;
                            ELSE
                                BEGIN
                                    /* add hosp code for HPI by ML on 10.08.1999 */
                                    SELECT Description,
                                           Treatment_location,
                                           Location,
                                           Care_category
                                    INTO var_prev_desc, var_prev_treatment_loc, var_prev_loc, var_prev_care_category
                                    FROM Ward
                                    WHERE Ward_code = par_input_ward_code
                                      AND Effective_date = var_prev_effective_date
                                      AND Hospital_code = par_hosp_code;

                                    IF coalesce(var_prev_desc, 'null') <> coalesce(par_input_desc, 'null') OR
                                       coalesce(var_prev_treatment_loc, 'null') <>
                                       coalesce(par_input_treat_loc, 'null') OR
                                       coalesce(var_prev_loc, 'null') <> coalesce(par_input_loc, 'null') THEN
                                        BEGIN
                                            RAISE EXCEPTION 'Description, Location and Treatment Location should equal to previous active row' USING ERRCODE := '20002';
                                        END;
                                    END IF;

                                    IF ((var_prev_care_category <> par_input_care_category) AND
                                        (var_prev_care_category IS NOT NULL)) THEN
                                        BEGIN
                                            RAISE EXCEPTION 'Care category should equal to previous active row' USING ERRCODE := '20002';
                                        END;
                                    END IF;
                                    /* ------------------------------------------------- */

                                    /* change to update ward for HPI by ML on 10.08.1999 */
                                    /* ------------------------------------------------- */

                                    /*
                                    update Ward
                                    set Description = @input_desc,
                                        Treatment_location = @input_treat_loc,
                                        Location = @input_loc,
                                        Active_status = @input_active_status,
                                        Effective_date = @input_effective_date,
                                        Care_category = @input_care_category
                                    where Ward_code = @input_ward_code and
                                          Effective_date = @input_org_effective_date
                                    */
                                    BEGIN
                                        UPDATE ward
                                        SET description        = par_input_desc,
                                            treatment_location = par_input_treat_loc,
                                            location           = par_input_loc,
                                            active_status      = par_input_active_status,
                                            effective_date     = par_input_effective_date,
                                            care_category      = par_input_care_category,
                                            wristband_no       = par_input_wristband_no,
                                            /* --//20161207/Ray/Added new column for HI isolation ward enhancement */
                                            isolation_type     = par_isolation_type
                                        WHERE ward_code = par_input_ward_code
                                          AND effective_date = par_input_org_effective_date
                                          AND hospital_code = par_hosp_code;
                                        var_error = 0;
                                        --                                     EXCEPTION
--                                         WHEN OTHERS THEN
--                                             raise ;
                                    END;

                                    /* add upadte for ward_location */
                                    BEGIN
                                        UPDATE ward_location
                                        SET location_code  = par_input_loc_code,
                                            active_status  = par_input_active_status,
                                            effective_date = par_input_effective_date
                                        WHERE hospital_code = par_hosp_code
                                          AND ward_code = par_input_ward_code
                                          AND effective_date = par_input_org_effective_date;
                                        var_error = 0;
                                        --                                     EXCEPTION
--                                         WHEN OTHERS THEN
--                                             raise ;
                                    END;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
        END;
    END IF;
    pas_return_code = 0;
    RETURN;
    -- EXCEPTION
--     WHEN OTHERS THEN
--         raise notice 'handle exception ending...';
--         pas_return_code = -1;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_web_update_ward" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
