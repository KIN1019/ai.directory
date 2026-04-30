-- DROP FUNCTION hasp_get_free_addr_list(varchar, timestamp, timestamp, varchar);

CREATE OR REPLACE FUNCTION hasp_get_free_addr_list(par_hosp_code character varying, par_from_date timestamp without time zone, par_to_date timestamp without time zone, par_case_type character varying)
 RETURNS TABLE(case_no character varying, user_id character varying, hkid character varying, adm_dtm timestamp without time zone, bldg character varying, room character varying, floor character varying, block character varying, dist character varying, nbldg character varying, nroom character varying, nfloor character varying, nblock character varying, ndist character varying, nbldg2 character varying, nroom2 character varying, nfloor2 character varying, nblock2 character varying, ndist2 character varying)
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_str_value_1 VARCHAR(255);
    var_str_value_2 VARCHAR(255);
    var_str_value_3 VARCHAR(255);
    var_str_value_4 VARCHAR(255);
    var_str_value_5 VARCHAR(255);
    var_dtm_value_1 TIMESTAMP;
    var_tx_type     VARCHAR(3);
    var_case        VARCHAR(12);
    var_user_id     VARCHAR(8);
    var_hkid        VARCHAR(12);
    var_bldg        VARCHAR(47);
    var_room        VARCHAR(5);
    var_block       VARCHAR(2);
    var_floor       VARCHAR(2);
    var_dist        VARCHAR(5);
    var_nbldg       VARCHAR(47);
    var_nroom       VARCHAR(5);
    var_nblock      VARCHAR(2);
    var_nfloor      VARCHAR(2);
    var_ndist       VARCHAR(5);
    var_nbldg2      VARCHAR(47);
    var_nroom2      VARCHAR(5);
    var_nblock2     VARCHAR(2);
    var_nfloor2     VARCHAR(2);
    var_ndist2      VARCHAR(5);
    var_adm_dtm     TIMESTAMP;
BEGIN
    -- Adjust to_date if null
    IF par_to_date IS NULL
    THEN
        par_to_date := par_from_date + INTERVAL '1 day';
    ELSE
        par_to_date := par_to_date + INTERVAL '1 day';
    END IF;

    -- Set transaction type based on case type
    IF par_case_type = 'A'
    THEN
        var_tx_type := '300';
    ELSE
        var_tx_type := '100';
    END IF;

    -- Create temporary table
    DROP TABLE IF EXISTS t$case_list;
    CREATE TEMP TABLE t$case_list (
        case_no VARCHAR(12),
        user_id VARCHAR(8),
        hkid    VARCHAR(12),
        adm_dtm TIMESTAMP,
        bldg    VARCHAR(47),
        room    VARCHAR(5),
        floor   VARCHAR(2),
        block   VARCHAR(2),
        dist    VARCHAR(5),
        nbldg   VARCHAR(47),
        nroom   VARCHAR(5),
        nfloor  VARCHAR(2),
        nblock  VARCHAR(2),
        ndist   VARCHAR(5),
        nbldg2  VARCHAR(47),
        nroom2  VARCHAR(5),
        nfloor2 VARCHAR(2),
        nblock2 VARCHAR(2),
        ndist2  VARCHAR(5)
    );

    -- Cursor for transaction log
    FOR var_case, var_user_id IN
        SELECT tl.Case_no, tl.User_ID
        FROM
            Transaction_log tl
        WHERE
              tl.Transaction_datetime >= par_from_date
          AND tl.Transaction_datetime < par_to_date
          AND tl.Transaction_type = var_tx_type
          AND tl.Cancel_flag IS NULL
          AND tl.Hospital_code = par_hosp_code
        ORDER BY transaction_datetime,system_datetime 
    LOOP
        -- Case view selection
        SELECT cv.Admission_datetime, cv.HKID
        -- INTO var_adm_dtm, var_hkid
        INTO var_dtm_value_1,var_str_value_1
        FROM
            Case_view cv
        WHERE
              cv.Case_no = var_case
          AND cv.Hospital_code = par_hosp_code;

        IF FOUND
        THEN
            var_adm_dtm := var_dtm_value_1;
            var_hkid := var_str_value_1;
        END IF;

        -- PMI selection
        SELECT pm.Building, pm.Room, pm.Floor, pm.Block, pm.District_code
        -- INTO var_bldg, var_room, var_floor, var_block, var_dist
        INTO var_str_value_1, var_str_value_2, var_str_value_3, var_str_value_4, var_str_value_5
        FROM
            PMI_wo_MRN pm
        WHERE pm.HKID = var_hkid;

        IF FOUND
        THEN
            var_bldg := var_str_value_1;
            var_room := var_str_value_2;
            var_floor := var_str_value_3;
            var_block := var_str_value_4;
            var_dist := var_str_value_5;
        END IF;

        -- NOK selection with priority 1
        SELECT nk.Building, nk.Room, nk.Floor, nk.Block, nk.District_code
        INTO var_nbldg, var_nroom, var_nfloor, var_nblock, var_ndist
        FROM
            NOK nk
        WHERE
              nk.HKID = var_hkid
          AND nk.Priority = 1;

        -- Handle errors for NOK priority 1
        IF NOT FOUND
        THEN
            var_nbldg := NULL;
            var_nroom := NULL;
            var_nfloor := NULL;
            var_nblock := NULL;
            var_ndist := NULL;
        ELSE
            -- NOK selection with priority 2
            SELECT nk2.Building, nk2.Room, nk2.Floor, nk2.Block, nk2.District_code
            INTO var_nbldg2, var_nroom2, var_nfloor2, var_nblock2, var_ndist2
            FROM
                NOK nk2
            WHERE
                  nk2.HKID = var_hkid
              AND nk2.Priority = 2;

            -- Handle errors for NOK priority 2
            IF NOT FOUND
            THEN
                var_nbldg2 := NULL;
                var_nroom2 := NULL;
                var_nfloor2 := NULL;
                var_nblock2 := NULL;
                var_ndist2 := NULL;
            END IF;
        END IF;

        -- Insert into temporary table if conditions are met
        IF (var_bldg IS NOT NULL AND var_bldg NOT LIKE 'HACODE:%')
            OR (var_nbldg IS NOT NULL AND var_nbldg NOT LIKE 'HACODE:%')
            OR (var_nbldg2 IS NOT NULL AND var_nbldg2 NOT LIKE 'HACODE:%')
        THEN

            IF var_bldg LIKE 'HACODE:%'
            THEN
                var_bldg := NULL;
                var_room := NULL;
                var_floor := NULL;
                var_block := NULL;
                var_dist := NULL;
            END IF;

            IF var_nbldg LIKE 'HACODE:%'
            THEN
                var_nbldg := NULL;
                var_nroom := NULL;
                var_nfloor := NULL;
                var_nblock := NULL;
                var_ndist := NULL;
            END IF;

            IF var_nbldg2 LIKE 'HACODE:%'
            THEN
                var_nbldg2 := NULL;
                var_nroom2 := NULL;
                var_nfloor2 := NULL;
                var_nblock2 := NULL;
                var_ndist2 := NULL;
            END IF;

            INSERT INTO t$case_list (case_no,user_id,hkid,adm_dtm,bldg,room,floor,block,dist,
                                     nbldg,nroom,nfloor,nblock,ndist,
                                     nbldg2,nroom2,nfloor2,nblock2,ndist2)
            VALUES (var_case,var_user_id,var_hkid,var_adm_dtm,var_bldg,var_room,var_floor,var_block,var_dist,
                    var_nbldg,var_nroom,var_nfloor,var_nblock,var_ndist,
                    var_nbldg2,var_nroom2,var_nfloor2,var_nblock2,var_ndist2);
        END IF;
    END LOOP;

    -- Return the result set
    RETURN QUERY
        SELECT cl.case_no, cl.user_id, cl.hkid, cl.adm_dtm, cl.bldg, cl.room, cl.floor, cl.block, cl.dist,
               cl.nbldg, cl.nroom, cl.nfloor, cl.nblock, cl.ndist,
               cl.nbldg2, cl.nroom2, cl.nfloor2, cl.nblock2, cl.ndist2
        FROM
            t$case_list cl
        ORDER BY cl.adm_dtm NULLS FIRST, cl.hkid NULLS FIRST;
    DROP TABLE t$case_list;
END;
$function$
;

;ALTER FUNCTION "hasp_get_free_addr_list" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
