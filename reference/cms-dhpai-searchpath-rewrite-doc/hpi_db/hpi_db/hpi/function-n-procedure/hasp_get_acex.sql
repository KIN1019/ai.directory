CREATE OR REPLACE PROCEDURE hasp_get_acex(INOUT pas_return_code int, IN par_input_from_date TIMESTAMP WITHOUT TIME ZONE, IN par_hosp VARCHAR)
AS 
$BODY$
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_errarg VARCHAR(80);
    var_month VARCHAR(12);
    var_case VARCHAR(24);
    var_los SMALLINT;
    var_bdo SMALLINT;
    var_prev_date TIMESTAMP WITHOUT TIME ZONE;
    var_date TIMESTAMP WITHOUT TIME ZONE;
    var_prev_imis VARCHAR(6);
    var_spec VARCHAR(8);
    var_imis VARCHAR(6);
    var_count SMALLINT;
    var_max_count SMALLINT;
    var_move_count SMALLINT;
    var_type VARCHAR(2);
    var_dsch_code VARCHAR(2);
    var_loc VARCHAR(8);
    var_start_date TIMESTAMP WITHOUT TIME ZONE;
    var_input_to_date TIMESTAMP WITHOUT TIME ZONE;
    var_src_ind VARCHAR(2);
    var_adm_src VARCHAR(6);
    var_tmp_dsch_code VARCHAR(2);
    var_hkid VARCHAR(24);
    var_adm_date TIMESTAMP WITHOUT TIME ZONE;
    var_prev_dsch_date TIMESTAMP WITHOUT TIME ZONE;
    var_dsch_date TIMESTAMP WITHOUT TIME ZONE;
    var_dsch_type VARCHAR(2);
    var_to_home VARCHAR(4);
    var_last_move INTEGER;
    case_csr CURSOR FOR
    SELECT
        HKID, Case_no, Source_indicator, Source_code, Discharge_code, Admission_datetime, Discharge_datetime, Movement_count
        FROM Case_view
        WHERE ((Discharge_code IS NULL) OR (Discharge_code IS NOT NULL AND Discharge_datetime >= par_input_from_date)) AND
        /* and Case_type = 'I' */
        Case_no SIMILAR TO ' HN%' AND Admission_datetime < var_input_to_date AND Hospital_code = par_hosp;
    move_csr CURSOR FOR
    SELECT
        Specialty_code, Treatment_location, Movement_datetime, Movement_type, Movement_count
        FROM Movement
        WHERE Case_no = var_case AND Movement_datetime < var_input_to_date AND Hospital_code = par_hosp
        ORDER BY Movement_count NULLS FIRST;
BEGIN
    /*
    Acute/Extended Interface Extraction
    
            parameter name          Description
    			@hosp							Hospital to be processed
            @input_from_date        From date to be processed
    */
    /* declare @hosp char(3), */
    DROP TABLE IF EXISTS t$tx_table;
    CREATE TEMPORARY TABLE t$tx_table
    (tx_hosp VARCHAR(6),
        tx_month VARCHAR(12),
        tx_hkid VARCHAR(24),
        tx_case VARCHAR(24),
        tx_count SMALLINT,
        tx_spec VARCHAR(6),
        tx_los SMALLINT,
        tx_bdo SMALLINT,
        tx_dsch VARCHAR(2) NULL,
        tx_src_ind VARCHAR(2) NULL,
        tx_adm_src VARCHAR(6) NULL,
        tx_adm_date TIMESTAMP WITHOUT TIME ZONE NULL,
        tx_prev_dsch_date TIMESTAMP WITHOUT TIME ZONE NULL,
        tx_dsch_type VARCHAR(2) NULL,
        tx_to_home VARCHAR(2) NULL);
    /* select @hosp = Hospital_code from Hospital */

    IF par_input_from_date IS NULL THEN
        /*
        select @input_from_date =
        convert(char(6),dateadd(mm,-1,getdate()),112) + '01'
        */
        SELECT
            - 1 * INTERVAL '1 month' + CONCAT(to_char(localtimestamp, 'YYYYMM'), '01')::TIMESTAMP
            INTO par_input_from_date;
    ELSE
        SELECT
            CONCAT(to_char(par_input_from_date, 'YYYYMM'), '01')
            INTO par_input_from_date;
    END IF;
    SELECT
        to_char(par_input_from_date, 'YYYYMMDD')
        INTO var_month;
    SELECT
        1 * INTERVAL '1 month' + par_input_from_date::TIMESTAMP
        INTO var_input_to_date;
    /* changed by Karen at 19960612 for cpi */
    /* comment start for select from Case_view instead of Case */
    /*
    declare case_csr cursor for
            select HKID, Case_no, Source_indicator, Source_code, Discharge_code,
                    Admission_datetime, Discharge_datetime, Movement_count
                    from Case
                    where ((Discharge_code is null)
                    or (Discharge_code is not null
                    and Discharge_datetime >= @input_from_date))
                    and Case_type = 'I'
                    and Admission_datetime < @input_to_date
    					and Hospital_code = @hosp
            for read only
    */
    /* end of comment */
    /* modify start for select from Case_view */
    /* end of modify */
    OPEN case_csr;
    FETCH case_csr INTO var_hkid, var_case, var_src_ind, var_adm_src, var_dsch_code, var_adm_date, var_dsch_date, var_last_move;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            0, 0
            INTO var_count, var_max_count;
        OPEN move_csr;
        FETCH move_csr INTO var_spec, var_loc, var_date, var_type, var_move_count;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF var_loc IS NOT NULL THEN
                SELECT
                    IMIS_code
                    INTO var_loc
                    FROM (SELECT
                        IMIS_code, Specialty_code, Effective_date
                        FROM Specialty) AS ungrouped_query
                    INNER JOIN (SELECT
                        Specialty_code, MAX(Effective_date) AS max_1
                        FROM Specialty
                        WHERE Specialty_code = var_loc AND Hospital_code = par_hosp AND Effective_date < var_input_to_date
                        GROUP BY Specialty_code) AS grouped_query
                        ON (ungrouped_query.Specialty_code = grouped_query.Specialty_code OR (ungrouped_query.Specialty_code IS NULL AND grouped_query.Specialty_code IS NULL))
                    WHERE Effective_date = max_1;
            END IF;
            /* --				and Active_status = 'A' */
            SELECT
                var_move_count, 'N'
                INTO var_max_count, var_to_home;

            IF var_loc = 'PRI' THEN
                SELECT
                    'PRI'
                    INTO var_imis;
            ELSE
                IF var_loc = 'ICU' THEN
                    SELECT
                        'ICU'
                        INTO var_imis;
                ELSE
                    IF var_loc = 'CCU' THEN
                        SELECT
                            'CCU'
                            INTO var_imis;
                    ELSE
                        IF var_loc = 'SCB' THEN
                            SELECT
                                'SCB'
                                INTO var_imis;
                        ELSE
                            IF var_loc = 'PIC' THEN
                                SELECT
                                    'PIC'
                                    INTO var_imis;
                            ELSE
                                IF var_loc = 'NIC' THEN
                                    SELECT
                                        'NIC'
                                        INTO var_imis;
                                ELSE
                                    IF var_loc = 'HDU' THEN
                                        SELECT
                                            'HDU'
                                            INTO var_imis;
                                    ELSE
                                        IF var_spec = 'HOME' THEN
                                            SELECT
                                                NULL, 'Y'
                                                INTO var_imis, var_to_home;
                                        ELSE
                                            SELECT
                                                IMIS_code
                                                INTO var_imis
                                                FROM (SELECT
                                                    IMIS_code, Specialty_code, Effective_date
                                                    FROM Specialty) AS ungrouped_query
                                                INNER JOIN (SELECT
                                                    Specialty_code, MAX(Effective_date) AS max_1
                                                    FROM Specialty
                                                    WHERE Specialty_code = var_spec AND Hospital_code = par_hosp AND Effective_date < var_input_to_date
                                                    GROUP BY Specialty_code) AS grouped_query
                                                    ON (ungrouped_query.Specialty_code = grouped_query.Specialty_code OR (ungrouped_query.Specialty_code IS NULL AND grouped_query.Specialty_code IS NULL))
                                                WHERE Effective_date = max_1;
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;
            /* and Active_status = 'A' */

            IF var_type = 'A' THEN
                SELECT
                    var_imis, var_date, - 1 * INTERVAL '1 day' + var_adm_date::TIMESTAMP
                    INTO var_prev_imis, var_prev_date, var_prev_dsch_date;
            END IF;

            IF var_type = 'D' THEN
                BEGIN
                    SELECT
                        var_dsch_code
                        INTO var_tmp_dsch_code;

                    IF DATE_PART('days', var_dsch_date::TIMESTAMP - var_adm_date::TIMESTAMP) = 0 THEN
                        SELECT
                            'D'
                            INTO var_dsch_type;
                    ELSE
                        SELECT
                            'I'
                            INTO var_dsch_type;
                    END IF;
                END;
            ELSE
                SELECT
                    NULL, NULL
                    INTO var_tmp_dsch_code, var_dsch_type;
            END IF;

            IF var_imis <> var_prev_imis OR var_type = 'D' THEN
                BEGIN
                    SELECT
                        DATE_PART('days', var_date::TIMESTAMP - var_prev_date::TIMESTAMP)
                        INTO var_los;
                    /*
                    if @los = 0
                    select @los = 1
                    */
                    IF var_los = 0 AND var_type = 'D' THEN
                        BEGIN
                            IF DATE_PART('days', var_date::TIMESTAMP - var_adm_date::TIMESTAMP) = 0 AND var_src_ind = '3' THEN
                                SELECT
                                    1
                                    INTO var_los;
                            ELSE
                                IF DATE_PART('days', var_date::TIMESTAMP - var_adm_date::TIMESTAMP) <> 0 THEN
                                    SELECT
                                        0
                                        INTO var_los;
                                END IF;
                            END IF;
                        END;
                    END IF;

                    IF var_prev_date < par_input_from_date THEN
                        SELECT
                            par_input_from_date
                            INTO var_start_date;
                    ELSE
                        SELECT
                            var_prev_date
                            INTO var_start_date;
                    END IF;

                    IF var_date >= par_input_from_date THEN
                        BEGIN
                            SELECT
                                DATE_PART('days', var_date::TIMESTAMP - var_start_date::TIMESTAMP)
                                INTO var_bdo;

                            IF var_bdo = 0 THEN
                                BEGIN
                                    IF var_type = 'D' AND var_dsch_type = 'D' AND var_src_ind = '3' THEN
                                        SELECT
                                            1
                                            INTO var_bdo;
                                    END IF;
                                END;
                            END IF;
                        END;
                    ELSE
                        BEGIN
                            SELECT
                                0
                                INTO var_bdo;
                        END;
                    END IF;

                    IF var_prev_imis = NULL AND var_type = 'D' THEN
                        BEGIN
                            SELECT
                                0, 0, 'PSY'
                                INTO var_los, var_bdo, var_prev_imis;
                            SELECT
                                var_count + 1
                                INTO var_count;
                            INSERT INTO t$tx_table
                            VALUES (par_hosp, var_month, var_hkid, var_case, var_count, var_prev_imis, var_los, var_bdo, var_tmp_dsch_code, var_src_ind, var_adm_src, var_adm_date, var_prev_dsch_date, var_dsch_type, var_to_home);
                        END;
                    ELSE
                        BEGIN
                            IF var_prev_imis <> NULL THEN
                                BEGIN
                                    SELECT
                                        var_count + 1
                                        INTO var_count;
                                    INSERT INTO t$tx_table
                                    VALUES (par_hosp, var_month, var_hkid, var_case, var_count, var_prev_imis, var_los, var_bdo, var_tmp_dsch_code, var_src_ind, var_adm_src, var_adm_date, var_prev_dsch_date, var_dsch_type, var_to_home);
                                END;
                            END IF;
                        END;
                    END IF;
                    SELECT
                        var_date, var_imis
                        INTO var_prev_date, var_prev_imis;
                END;
            END IF;
            FETCH move_csr INTO var_spec, var_loc, var_date, var_type, var_move_count;
        END LOOP;
        CLOSE move_csr;
        /*
        if @max_count < (select max(Movement_count) from Movement
        where Case_no = @case)
        */
        IF var_max_count < var_last_move OR var_tmp_dsch_code IS NULL THEN
            BEGIN
                SELECT
                    DATE_PART('days', var_input_to_date::TIMESTAMP - var_prev_date::TIMESTAMP), 'N'
                    INTO var_los, var_to_home;
                /*
                if @los = 0
                select @los = 1
                */
                IF var_prev_date < par_input_from_date THEN
                    SELECT
                        par_input_from_date
                        INTO var_start_date;
                ELSE
                    SELECT
                        var_prev_date
                        INTO var_start_date;
                END IF;
                SELECT
                    DATE_PART('days', var_input_to_date::TIMESTAMP - var_start_date::TIMESTAMP)
                    INTO var_bdo;

                IF var_bdo = 0 THEN
                    SELECT
                        1
                        INTO var_bdo;
                END IF;

                IF var_prev_imis <> NULL THEN
                    BEGIN
                        SELECT
                            var_count + 1
                            INTO var_count;
                        INSERT INTO t$tx_table
                        VALUES (par_hosp, var_month, var_hkid, var_case, var_count, var_prev_imis, var_los, var_bdo, var_tmp_dsch_code, var_src_ind, var_adm_src, var_adm_date, var_prev_dsch_date, var_dsch_type, var_to_home);
                    END;
                END IF;
            END;
        END IF;
        FETCH case_csr INTO var_hkid, var_case, var_src_ind, var_adm_src, var_dsch_code, var_adm_date, var_dsch_date, var_last_move;
    END LOOP;
    CLOSE case_csr;
    /* due to warm stand by, change truncate to delete by WL */
    /* --truncate table acex_table */
    DELETE FROM acex_table;
    INSERT INTO acex_table
    SELECT
        tx_hosp, tx_month, tx_hkid, tx_case, RIGHT(CONCAT('000000', RTRIM(CAST (tx_count AS VARCHAR(12)))), 6), tx_spec, RIGHT(CONCAT('000000', RTRIM(CAST (tx_los AS VARCHAR(12)))), 6), RIGHT(CONCAT('000000', RTRIM(CAST (tx_bdo AS VARCHAR(12)))), 6), COALESCE(tx_dsch, ' '), COALESCE(tx_src_ind, ' '), COALESCE(tx_adm_src, '   '), to_char(tx_adm_date, 'YYYYMMDD'), to_char(tx_prev_dsch_date, 'YYYYMMDD'), COALESCE(tx_dsch_type, ' '), tx_to_home
        FROM t$tx_table;
    -- DROP TABLE t$tx_table;
    pas_return_code := 0;
    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$tx_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$BODY$
LANGUAGE plpgsql;