-- DROP PROCEDURE hpi.hasp_web_chk_spec_mix_eis_code(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, inout int4, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.hasp_web_chk_spec_mix_eis_code(INOUT pas_return_code integer, IN par_mode character varying, IN par_hospital_code character varying, IN par_ward_code character varying, IN par_specialty_code character varying, IN par_input_treat_loc character varying, IN par_effective_date timestamp without time zone, INOUT par_count_exist_mixed integer, IN par_org_effective_date timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_official_bed              INTEGER;
    var_day_bed                   INTEGER;
    var_spec_effective_date_start TIMESTAMP;
    var_spec_effective_date_end   TIMESTAMP;
    var_previous_eis_code         VARCHAR(3);
    var_row_count               INT;
    var_ward_spec_eff_end       TIMESTAMP;
    var_ward_spec_eff_start     TIMESTAMP;
BEGIN
    -- Checking point from ward
    IF par_ward_code IS NOT NULL AND par_specialty_code IS NULL THEN
        -- if it is delete action, check previous record instead
        IF par_mode = 'D' THEN
            SELECT Treatment_location, Effective_date
            INTO par_input_treat_loc, par_effective_date
            FROM Ward
            WHERE Ward_code = par_ward_code
              AND Effective_date < par_effective_date
              AND Hospital_code = par_hospital_code
            ORDER BY Effective_date DESC
            LIMIT 1;

            -- Check if a row was found
            IF NOT FOUND THEN
                par_count_exist_mixed := 0;
                RETURN;
            END IF;
        END IF;

        IF par_input_treat_loc IN ('PRI', 'SAW', 'CUS') THEN
            par_count_exist_mixed := 0;
            RETURN;
        END IF;

        CREATE TEMP TABLE temp_specialty
        (
            Specialty_code VARCHAR(4) NOT NULL,
            IMIS_code      VARCHAR(3),
            EIS_code       VARCHAR(3),
            Active_status  VARCHAR(1),
            Effective_date TIMESTAMP  NOT NULL
        );

        CREATE TEMP TABLE temp AS
        SELECT o.Specialty_code, o.Effective_date, o.Official_bed, o.Day_bed
        FROM (SELECT Specialty_code, MAX(Effective_date) AS Effective_date, Official_bed, Day_bed
              FROM Ward_specialty
              WHERE Ward_code = par_ward_code
                AND Effective_date <= par_effective_date -- Input ward effective date
                AND Hospital_code = par_hospital_code
                AND (Official_bed <> 0 OR Day_bed <> 0)
              GROUP BY Specialty_code, Official_bed, Day_bed

              UNION

              SELECT Specialty_code, Effective_date, Official_bed, Day_bed
              FROM Ward_specialty
              WHERE Ward_code = par_ward_code
                AND Hospital_code = par_hospital_code
                AND Effective_date > par_effective_date -- Input ward effective date
             ) o
        ORDER BY Specialty_code, Effective_date;

        /*
            List of specialties mapped with ward specialty should be listed in #temp table
            there should be 1-2 records for 1 specialties mapping: start and end of mapping
        */
        LOOP
            EXIT WHEN NOT EXISTS (SELECT 1 FROM temp);

            -- Fetch the first record to process
            SELECT Specialty_code, Effective_date, Official_bed, Day_bed
            INTO par_specialty_code, var_spec_effective_date_start, var_official_bed, var_day_bed
            FROM temp
            ORDER BY Specialty_code, Effective_date
            LIMIT 1;

            /* If there is record of ward specialty having same effective date as ward, previous record of ward specialty is no more reference */
            IF EXISTS (SELECT 1
                       FROM temp
                       WHERE Specialty_code = par_specialty_code
                         AND Effective_date = par_effective_date) THEN
                DELETE
                FROM temp
                WHERE Specialty_code = par_specialty_code
                  AND Effective_date < par_effective_date;

                SELECT Specialty_code, Effective_date, Official_bed, Day_bed
                INTO par_specialty_code, var_spec_effective_date_start, var_official_bed, var_day_bed
                FROM temp
                WHERE Specialty_code = par_specialty_code
                  AND Effective_date = par_effective_date;
            END IF;

            -- Check for records with 0 official and day beds
            IF var_official_bed = 0 AND var_day_bed = 0 THEN
                DELETE
                FROM temp
                WHERE Specialty_code = par_specialty_code
                  AND Effective_date = var_spec_effective_date_start;
                var_spec_effective_date_start := null;
            ELSE
                DELETE
                FROM temp
                WHERE Specialty_code = par_specialty_code
                  AND Effective_date = var_spec_effective_date_start;

                -- Fetch the maximum effective date for further checks
                SELECT MAX(Effective_date)
                INTO var_spec_effective_date_end
                FROM temp
                WHERE Specialty_code = par_specialty_code;

                DELETE
                FROM temp
                WHERE Specialty_code = par_specialty_code;

                /* Check current effective history record mapping with EIS code MIX */
                INSERT INTO temp_specialty (Specialty_code, IMIS_code, EIS_code, Active_status, Effective_date)
                SELECT s.Specialty_code, s.IMIS_code, im.EIS_code, s.Active_status, s.Effective_date
                FROM (SELECT Specialty_code, IMIS_code, Active_status, Effective_date
                      FROM Specialty
                      WHERE Specialty_code = par_specialty_code
                        AND Hospital_code = par_hospital_code
                        AND Effective_date <= par_effective_date
                      GROUP BY Specialty_code, IMIS_code, Active_status, Effective_date
                      HAVING Effective_date = MAX(Effective_date)) s
                         JOIN IMIS im ON s.IMIS_code = im.IMIS_code;

                /* Check future history record mapping with EIS code MIX */
                /* handle null if number of bed is zero */
                INSERT INTO temp_specialty (Specialty_code, IMIS_code, EIS_code, Active_status, Effective_date)
                SELECT s.Specialty_code, s.IMIS_code, im.EIS_code, s.Active_status, s.Effective_date
                FROM (SELECT Specialty_code, IMIS_code, Active_status, Effective_date
                      FROM Specialty
                      WHERE Specialty_code = par_specialty_code
                        AND Hospital_code = par_hospital_code
                        AND Effective_date > par_effective_date) s
                         JOIN IMIS im ON s.IMIS_code = im.IMIS_code;

                /* 	If the specialty code have a new history record which is same as ward effective date,
                    then delete records which are outdated after new effective date to enable saving */
                IF EXISTS (SELECT 1
                           FROM Specialty
                           WHERE Specialty_code = par_specialty_code
                             AND Hospital_code = par_hospital_code
                             AND Effective_date = par_effective_date) THEN
                    DELETE
                    FROM temp_specialty
                    WHERE Specialty_code = par_specialty_code
                      AND Effective_date < par_effective_date;
                END IF;
            END IF;
        END LOOP;

        SELECT COUNT(1) INTO par_count_exist_mixed FROM temp_specialty WHERE EIS_code = 'MIX';

        DROP TABLE temp;
        DROP TABLE temp_specialty;

    ELSE
        /* if it is delete action, check previous record instead
            overwrite effective date
        */
        IF par_mode = 'D' THEN
            SELECT IMIS_code, Effective_date
            INTO var_previous_eis_code, par_effective_date
            FROM Specialty
            WHERE Specialty_code = par_specialty_code
              AND Hospital_code = par_hospital_code
              AND Effective_date < par_effective_date
            ORDER BY Effective_date DESC
            LIMIT 1;

            /* if previous record is not MIX, do not need to keep checking */
            GET DIAGNOSTICS var_row_count = ROW_COUNT;
            IF var_previous_eis_code <> 'MIX' OR var_row_count = 0 THEN
                par_count_exist_mixed := 0;
                RETURN;
            END IF;
        END IF;

        /* if the update record is not the latest record, not required to change as only description update */
        IF par_org_effective_date IS NOT NULL THEN
            IF EXISTS (SELECT 1
                       FROM Specialty
                       WHERE Specialty_code = par_specialty_code
                         AND Hospital_code = par_hospital_code
                         AND Effective_date > par_org_effective_date) THEN
                par_count_exist_mixed := 0;
                RETURN;
            END IF;
        END IF;

        CREATE TEMP TABLE temp_by_specialty
        (
            Ward_code      VARCHAR(4) NOT NULL,
            Effective_date TIMESTAMP,
            Official_bed   INTEGER,
            Day_bed        INTEGER
        );

        CREATE TEMP TABLE temp_ward
        (
            Ward_code          VARCHAR(4) NOT NULL,
            Treatment_location VARCHAR(4),
            Active_status      VARCHAR(1),
            Effective_date     TIMESTAMP  NOT NULL
        );

        /* Union current and future ward specialty record start */
        /* still need to get one previous to check 0 0 bed time range */
        /* Adaptive Server has expanded all '*' elements in the following statement */
        INSERT INTO temp_by_specialty
        SELECT o.Ward_code, o.Effective_date, o.Official_bed, o.Day_bed
        FROM (SELECT Ward_code, MAX(Effective_date) AS Effective_date, Official_bed, Day_bed
              FROM Ward_specialty
              WHERE Specialty_code = par_specialty_code
                AND Hospital_code = par_hospital_code
                AND Effective_date <= par_effective_date
                AND (Official_bed <> 0 OR Day_bed <> 0)
              GROUP BY Ward_code, Official_bed, Day_bed
              UNION
              SELECT Ward_code, Effective_date, Official_bed, Day_bed
              FROM Ward_specialty
              WHERE Specialty_code = par_specialty_code
                AND Hospital_code = par_hospital_code
                AND Effective_date > par_effective_date) o;

        LOOP
            EXIT WHEN NOT EXISTS (SELECT 1 FROM temp_by_specialty);

            /* Get the time range of specialty to check specialty history EIS code mapping */
            /* fetch effective start time of ward specialty */
            SELECT Ward_code, Effective_date, Official_bed, Day_bed
            INTO par_ward_code, var_ward_spec_eff_start, var_official_bed, var_day_bed
            FROM temp_by_specialty
            ORDER BY Effective_date
            LIMIT 1;

            /* If there is record of ward specialty having same effective date as ward, previous record of ward specialty is no more reference */
            IF EXISTS (SELECT 1
                       FROM temp_by_specialty
                       WHERE Ward_code = par_ward_code
                         AND Effective_date = par_effective_date) THEN

                DELETE
                FROM temp_by_specialty
                WHERE Ward_code = par_ward_code
                  AND Effective_date < par_effective_date;

                SELECT Ward_code, Effective_date, Official_bed, Day_bed
                INTO par_ward_code, var_ward_spec_eff_start, var_official_bed, var_day_bed
                FROM temp_by_specialty
                WHERE Ward_code = par_ward_code
                  AND Effective_date = par_effective_date;
            END IF;

            /* cater future 0 0 bed record */
            IF var_official_bed = 0 AND var_day_bed = 0 THEN
                /* if future consist of 0 0 records, delete the record as it is turn off*/
                DELETE
                FROM temp_by_specialty
                WHERE Ward_code = par_ward_code
                  AND Effective_date = var_ward_spec_eff_start;
                var_ward_spec_eff_start := NULL;
            ELSE
                DELETE
                FROM temp_by_specialty
                WHERE Ward_code = par_ward_code
                  AND Effective_date = var_ward_spec_eff_start;

                /* fetch effective end time of ward specialty */
                IF EXISTS (SELECT 1 FROM temp_by_specialty WHERE Ward_code = par_ward_code) THEN
                    SELECT MAX(Effective_date)
                    INTO var_ward_spec_eff_end
                    FROM temp_by_specialty
                    WHERE Ward_code = par_ward_code;

                    /* Delete all records of current specialty after getting earliest and latest effective for checking later */
                    DELETE
                    FROM temp_by_specialty
                    WHERE Ward_code = par_ward_code;
                ELSE
                    var_ward_spec_eff_end := NULL;
                END IF;

                INSERT INTO temp_ward (Ward_code, Treatment_location, Active_status, Effective_date)
                SELECT Ward_code, Treatment_location, Active_status, Effective_date
                FROM Ward
                WHERE Ward_code = par_ward_code
                  AND Hospital_code = par_hospital_code
                  AND Effective_date <= par_effective_date
                GROUP BY Ward_code, Treatment_location, Active_status, Effective_date
                HAVING Effective_date = MAX(Effective_date);

                INSERT INTO temp_ward (Ward_code, Treatment_location, Active_status, Effective_date)
                SELECT Ward_code, Treatment_location, Active_status, Effective_date
                FROM Ward
                WHERE Ward_code = par_ward_code
                  AND Hospital_code = par_hospital_code
                  AND Effective_date > par_effective_date;

                /* 	If the specialty code have a new history record which is same as ward effective date,
                    then delete records which are outdated after new effective date to enable saving */
                IF EXISTS (SELECT 1
                           FROM Ward
                           WHERE Ward_code = par_ward_code
                             AND Hospital_code = par_hospital_code
                             AND Effective_date = par_effective_date) THEN
                    DELETE
                    FROM temp_ward
                    WHERE Ward_code = par_ward_code
                      AND Effective_date < par_effective_date;
                END IF;
            END IF;
        END LOOP;

        SELECT COUNT(*)
        INTO par_count_exist_mixed
        FROM temp_ward
        WHERE Treatment_location IS NULL
           OR Treatment_location NOT IN ('PRI', 'SAW', 'CUS');

        DROP TABLE temp_by_specialty;
        DROP TABLE temp_ward;
    END IF;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_web_chk_spec_mix_eis_code" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
