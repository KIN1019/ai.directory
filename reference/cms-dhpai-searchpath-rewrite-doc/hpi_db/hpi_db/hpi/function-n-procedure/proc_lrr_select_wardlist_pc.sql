-- DROP FUNCTION hpi.proc_lrr_select_wardlist_pc(varchar, varchar, varchar, varchar, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.proc_lrr_select_wardlist_pc(par_h_code character varying, par_ws_code character varying, par_option character varying, par_user_group character varying, par_pward character varying, par_change_ns_code character varying, par_ns_code character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/* select all ward except 'HOME' */
DECLARE
    p_refcur refcursor;
BEGIN
    IF par_OPTION = 'A' THEN
        BEGIN
            /*
            Remarked by Alex on 04-02-1997
            select ward_code
            from ward
            where ((close_date = NULL) or (GETDATE() <= close_date)) and
            	  open_date <= GETDATE() and
            	  ward_code <> 'HOME' and
            	  hospital_code = @H_CODE  /* Add Hospital Code */
            order by ward_code
            */
            -- OPEN p_refcur FOR
            -- SELECT
            --     ward_code
            --     FROM ward
            --     WHERE ward_code <> 'HOME' AND hospital_code = par_H_CODE AND effective_date <= timestamp_convert(localtimestamp)
            --     GROUP BY ward_code
            --     HAVING effective_date = MAX(effective_date) AND active_status = 'A'
            --     ORDER BY ward_code NULLS FIRST;
            -- RETURN NEXT p_refcur;
            OPEN p_refcur FOR
            SELECT
                ward_code
                FROM (
                    SELECT
                        ward_code,
                        ROW_NUMBER() OVER (PARTITION BY ward_code ORDER BY effective_date DESC) as rn
                        FROM ward
                        WHERE ward_code <> 'HOME' AND hospital_code = par_H_CODE AND effective_date <= timestamp_convert(localtimestamp) AND active_status = 'A') sub
                WHERE rn = 1
                ORDER BY ward_code NULLS FIRST;
            RETURN NEXT p_refcur;
        END;
    END IF;
    /* get only authorized ward */
    IF par_OPTION = 'B' THEN
        BEGIN
            IF par_PWARD = 'N' THEN
                BEGIN
                    /*
                    Remarked by Alex on 04-02-1997
                    SELECT w1.ward_code
                    FROM ward w1, cmslrr_db..CHANGE_WARD c1
                    WHERE rtrim(w1.hospital_code) = @H_CODE AND
                    	w1.ward_code = c1.CHANGE_NS_CODE AND
                    	c1.HOSP_CODE = @H_CODE AND  /* Add Hospital Code */
                    	rtrim(c1.WS_CODE) = @WS_CODE AND
                    	((close_date = NULL) or (GETDATE() <= close_date)) AND
                    	  ward_code <> 'HOME'
                    order by w1.ward_code
                    */

                    /*2025-01-24*/
                    /*
                    OPEN p_refcur FOR
                    SELECT
                        w1.ward_code
                        FROM ward AS w1, cmslrr_db_dbo.CHANGE_WARD AS c1
                        WHERE w1.hospital_code = par_H_CODE AND w1.ward_code = c1.CHANGE_NS_CODE AND c1.HOSP_CODE = par_H_CODE AND c1.WS_CODE = par_WS_CODE AND w1.ward_code <> 'HOME' AND w1.effective_date <= timestamp_convert(localtimestamp)
                        GROUP BY w1.ward_code
                        HAVING w1.effective_date = MAX(w1.effective_date) AND w1.active_status = 'A'
                        ORDER BY w1.ward_code NULLS FIRST;
                    RETURN NEXT p_refcur;
                    */

                    /*After the modification, please ensure that the input parameter CHANGE_NS_CODE meets the following conditions; otherwise, it will alter the original logic.
                    select CHANGE_NS_CODE from cmslrr_db_dbo.CHANGE_WARD where HOSP_CODE = par_H_CODE AND WS_CODE = par_WS_CODE */
                    OPEN p_refcur FOR
                    SELECT
                        ward_code
                    FROM(SELECT
                        ward_code,
                        ROW_NUMBER() OVER (PARTITION BY ward_code ORDER BY effective_date DESC) as rn
                        FROM ward
                        WHERE hospital_code = par_H_CODE AND ward_code=par_CHANGE_NS_CODE AND ward_code <> 'HOME' AND effective_date <= timestamp_convert(localtimestamp) AND active_status = 'A')sub
                    WHERE rn=1
                    ORDER BY ward_code NULLS FIRST;
                    RETURN NEXT p_refcur;
                END;
            ELSE
                BEGIN
                    OPEN p_refcur FOR
                    /*2025-01-24*/
                    /*
                    SELECT
                        w1.ward_code
                        FROM ward AS w1, cmslrr_db_dbo.CHANGE_WARD AS c1
                        WHERE w1.hospital_code = par_H_CODE AND w1.ward_code = c1.CHANGE_NS_CODE AND c1.HOSP_CODE = par_H_CODE AND c1.WS_CODE = par_WS_CODE AND w1.ward_code <> 'HOME' AND w1.effective_date <= timestamp_convert(localtimestamp)
                        GROUP BY w1.ward_code
                        HAVING w1.effective_date = MAX(w1.effective_date) AND w1.active_status = 'A'
                    */
                    /*After the modification, please ensure that the input parameter CHANGE_NS_CODE meets the following conditions; otherwise, it will alter the original logic.
                    select CHANGE_NS_CODE from cmslrr_db_dbo.CHANGE_WARD where HOSP_CODE = par_H_CODE AND WS_CODE = par_WS_CODE */
                    -- SELECT
                    --     ward_code
                    --     FROM ward
                    --     WHERE hospital_code = par_H_CODE AND ward_code=par_CHANGE_NS_CODE AND ward_code <> 'HOME' AND effective_date <= timestamp_convert(localtimestamp)
                    --     GROUP BY ward_code
                    --     HAVING effective_date = MAX(effective_date) AND active_status = 'A'
                    SELECT
                        ward_code
                    FROM(SELECT
                        ward_code,
                        ROW_NUMBER() OVER (PARTITION BY ward_code ORDER BY effective_date DESC) as rn
                        FROM ward
                        WHERE hospital_code = par_H_CODE AND ward_code=par_CHANGE_NS_CODE AND ward_code <> 'HOME' AND effective_date <= timestamp_convert(localtimestamp) AND active_status = 'A')sub
                    WHERE rn=1
                    UNION
                    /*
                    SELECT
                        ns_code
                        FROM cmslrr_db_dbo.cms_ward_list
                        WHERE user_group = par_USER_GROUP AND hosp_code = par_H_CODE
                        ORDER BY w1.ward_code NULLS FIRST;
                    RETURN NEXT p_refcur;
                    */
                    SELECT par_ns_code AS ns_code;
                    RETURN NEXT p_refcur;
                END;
            END IF;
        END;
    END IF;
    /* dom161100  - start */
    IF par_OPTION = 'C' THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                ward_code
            FROM(SELECT
                ward_code,
                ROW_NUMBER() OVER (PARTITION BY ward_code ORDER BY effective_date DESC) as rn
                FROM ward
                WHERE hospital_code = par_H_CODE AND effective_date <= timestamp_convert(localtimestamp) AND active_status = 'A')sub
            WHERE rn=1 
            ORDER BY ward_code NULLS FIRST;
            RETURN NEXT p_refcur;
        END;
    END IF;
    /* get only authorized ward */
    IF par_OPTION = 'D' THEN
        BEGIN
            IF par_PWARD = 'N' THEN
                BEGIN
                    OPEN p_refcur FOR
                    /*
                    SELECT
                        w1.ward_code
                        FROM ward AS w1, cmslrr_db_dbo.CHANGE_WARD AS c1
                        WHERE w1.hospital_code = par_H_CODE AND w1.ward_code = c1.CHANGE_NS_CODE AND c1.HOSP_CODE = par_H_CODE AND c1.WS_CODE = par_WS_CODE AND w1.effective_date <= timestamp_convert(localtimestamp)
                        GROUP BY w1.ward_code
                        HAVING w1.effective_date = MAX(w1.effective_date) AND w1.active_status = 'A'
                    */
                    SELECT
                        ward_code
                    FROM(SELECT
                        ward_code,
                        ROW_NUMBER() OVER (PARTITION BY ward_code ORDER BY effective_date DESC) as rn
                        FROM ward
                        WHERE hospital_code = par_H_CODE AND ward_code=par_CHANGE_NS_CODE AND effective_date <= timestamp_convert(localtimestamp) AND active_status = 'A')sub
                    WHERE rn=1
                    UNION
                    SELECT
                        'HOME'
                        FROM ward 
                        ORDER BY ward_code NULLS FIRST;
                    RETURN NEXT p_refcur;
                END;
            ELSE
                BEGIN
                    OPEN p_refcur FOR
                    /*
                    SELECT
                        w1.ward_code
                        FROM ward AS w1, cmslrr_db_dbo.CHANGE_WARD AS c1
                        WHERE w1.hospital_code = par_H_CODE AND w1.ward_code = c1.CHANGE_NS_CODE AND c1.HOSP_CODE = par_H_CODE AND c1.WS_CODE = par_WS_CODE AND w1.effective_date <= timestamp_convert(localtimestamp)
                        GROUP BY w1.ward_code
                        HAVING w1.effective_date = MAX(w1.effective_date) AND w1.active_status = 'A'
                    */
                    SELECT
                        Ward_code
                    FROM(SELECT
                        ward_code,
                        ROW_NUMBER() OVER (PARTITION BY ward_code ORDER BY effective_date DESC) as rn
                        FROM ward
                        WHERE hospital_code = par_H_CODE AND ward_code=par_CHANGE_NS_CODE AND effective_date <= timestamp_convert(localtimestamp) AND active_status = 'A')sub
                    WHERE rn=1
                    UNION
                    /*
                    SELECT
                        ns_code
                        FROM cmslrr_db_dbo.cms_ward_list
                        WHERE user_group = par_USER_GROUP AND hosp_code = par_H_CODE
                    */
                    SELECT par_ns_code AS ns_code
                    UNION
                    SELECT
                        'HOME'
                        FROM ward 
                        ORDER BY ward_code NULLS FIRST;
                    RETURN NEXT p_refcur;
                END;
            END IF;
        END;
    END IF;
    /* dom161100 - end */
END;
$function$
;

;ALTER FUNCTION "proc_lrr_select_wardlist_pc" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
