-- DROP PROCEDURE hpi.hasp_cal_age(inout int4, in timestamp, in timestamp, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_cal_age(INOUT pas_return_code integer, IN par_start_date timestamp without time zone, IN par_end_date timestamp without time zone, INOUT par_age character varying)
 LANGUAGE plpgsql
AS $procedure$
/* 2010-01-22 20017749 fx use d, m, y for age indicator */
DECLARE
    var_date_1y INTEGER;
    var_date_1m INTEGER;
    var_date_1d INTEGER;
    var_date_2y INTEGER;
    var_date_2m INTEGER;
    var_date_2d INTEGER;
    var_y_diff INTEGER;
    var_m_diff INTEGER;
    var_d_diff INTEGER;
    var_leap_1y VARCHAR(1);
    var_leap_2y VARCHAR(1);
    var_temp_str VARCHAR(10);
    var_spacing VARCHAR(05);
    var_date_diff INTEGER;
    var_month_diff INTEGER;
    var_year_diff INTEGER;
BEGIN
    <<finish>>
    BEGIN
        IF par_start_date IS NULL OR par_end_date IS NULL OR par_start_date > par_end_date THEN
            BEGIN
                SELECT
                    '-1'
                    INTO par_age;
                EXIT finish;
            END;
        END IF;
        SELECT
            date_part('year', par_start_date::TIMESTAMP)
            INTO var_date_1y;
        SELECT
            date_part('year', par_end_date::TIMESTAMP)
            INTO var_date_2y;
        SELECT
            var_date_2y - var_date_1y
            INTO var_y_diff;
        SELECT
            date_part('month', par_start_date::TIMESTAMP)
            INTO var_date_1m;
        SELECT
            date_part('month', par_end_date::TIMESTAMP)
            INTO var_date_2m;
        SELECT
            var_date_2m - var_date_1m
            INTO var_m_diff;
        SELECT
            date_part('day', par_start_date::TIMESTAMP)
            INTO var_date_1d;
        SELECT
            date_part('day', par_end_date::TIMESTAMP)
            INTO var_date_2d;
        SELECT
            var_date_2d - var_date_1d
            INTO var_d_diff;

        IF (var_date_1y % 4) = 0 AND (var_date_1y % 100) <> 0 OR (var_date_1y % 400) = 0 THEN
            SELECT
                '1'
                INTO var_leap_1y;
        ELSE
            SELECT
                '0'
                INTO var_leap_1y;
        END IF;

        IF (var_date_2y % 4) = 0 AND (var_date_2y % 100) <> 0 OR (var_date_2y % 400) = 0 THEN
            SELECT
                '1'
                INTO var_leap_2y;
        ELSE
            SELECT
                '0'
                INTO var_leap_2y;
        END IF;
        /* --------20091015 : SL */
        /* --- */
        /* Display number of years for age >= 3 yeras */
        /* Display number of months for age within 3 years */
        /* Display number of days for age within 3 months */
        SELECT
            DATE_PART('days', par_end_date::TIMESTAMP- par_start_date::TIMESTAMP)
            INTO var_date_diff;
        SELECT
            12 * (DATE_PART('year', par_end_date::TIMESTAMP) - DATE_PART('year', par_start_date::TIMESTAMP)) + DATE_PART('month', par_end_date::TIMESTAMP) - DATE_PART('month', par_start_date::TIMESTAMP)
            INTO var_month_diff;
        SELECT
            DATE_PART('year', par_end_date::TIMESTAMP) - DATE_PART('year', par_start_date::TIMESTAMP)
            INTO var_year_diff;

        IF var_month_diff * INTERVAL '1 month' + par_start_date::TIMESTAMP > par_end_date THEN
            SELECT
                var_month_diff - 1
                INTO var_month_diff;
        END IF;
        /* ---1)..calc Day -- */
        IF var_month_diff < 3 THEN
            BEGIN
                /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                /* select @age =right(space(3) + convert(varchar(3),@date_diff)+' da',5) */
                SELECT
                    RIGHT(CONCAT(REPEAT(' ', 3),
                    CASE CAST (var_date_diff AS VARCHAR(3))
                        WHEN '' THEN ''
                        ELSE CAST (var_date_diff AS VARCHAR(3))
                    END, ' d'), 5)
                    INTO par_age;
                /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
            END;
        END IF;
        /* --2). Calc month -- */
        IF var_month_diff >= 3 AND var_month_diff < 36 THEN
            BEGIN
                /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                /* select @age =right(space(3) + convert(varchar(3),@month_diff) +' mo',5) */
                SELECT
                    RIGHT(CONCAT(REPEAT(' ', 3),
                    CASE CAST (var_month_diff AS VARCHAR(3))
                        WHEN '' THEN ''
                        ELSE CAST (var_month_diff AS VARCHAR(3))
                    END, ' m'), 5)
                    INTO par_age;
                /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
            END;
        /* ---3). Calc Year */
        ELSE
            IF var_month_diff >= 36 THEN
                BEGIN
                    IF var_year_diff * INTERVAL '1 year' + par_start_date::TIMESTAMP > par_end_date THEN
                        SELECT
                            var_year_diff - 1
                            INTO var_year_diff;
                    END IF;
                    /* 2010-01-22 20017749 fx use d, m, y for age indicator - Start */
                    /* if @year_diff >= 100 */
                    /* select @age =right(space(3) + convert(varchar(3),@year_diff) + 'yr',5) */
                    /* else */
                    /* select @age =right(space(3) + convert(varchar(3),@year_diff) + ' yr',5) */
                    SELECT
                        RIGHT(CONCAT(REPEAT(' ', 3),
                        CASE CAST (var_year_diff AS VARCHAR(3))
                            WHEN '' THEN ''
                            ELSE CAST (var_year_diff AS VARCHAR(3))
                        END, ' y'), 5)
                        INTO par_age;
                    /* 2010-01-22 20017749 fx use d, m, y for age indicator - End */
                END;
            END IF;
        END IF;
    END;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_cal_age" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
