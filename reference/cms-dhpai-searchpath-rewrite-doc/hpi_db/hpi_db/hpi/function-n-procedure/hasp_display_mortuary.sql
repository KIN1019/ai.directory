-- DROP PROCEDURE hpi.hasp_display_mortuary(inout int4, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_display_mortuary(INOUT pas_return_code integer, IN par_input_mortuary_hospital character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_like_mortuary VARCHAR(5);
BEGIN
    /* ******************************************** */
    /* Create temp table for display */
    /* ******************************************** */
	DROP TABLE IF EXISTS t$tx_table1;
    DROP TABLE IF EXISTS t$tx_table2;
    CREATE TEMPORARY TABLE t$tx_table1
    (mortuary_hospital VARCHAR(3) NULL,
        active_indicator VARCHAR(1) NULL,
        effective_date TIMESTAMP WITHOUT TIME ZONE NULL,
        update_datetime TIMESTAMP WITHOUT TIME ZONE NULL);
    CREATE TEMPORARY TABLE t$tx_table2
    (mortuary_hospital VARCHAR(3) NULL,
        active_indicator VARCHAR(1) NULL,
        effective_date TIMESTAMP WITHOUT TIME ZONE NULL,
        update_datetime TIMESTAMP WITHOUT TIME ZONE NULL);
    CREATE INDEX tx_index1 ON t$tx_table1
        (mortuary_hospital);
    CREATE INDEX tx_index2 ON t$tx_table2
        (mortuary_hospital);
       
    IF COALESCE(par_input_mortuary_hospital,'') <> '' THEN
    	SELECT safe_substring(par_input_mortuary_hospital,1,3)
    	INTO 
    	par_input_mortuary_hospital ;
    END IF;
    

    IF par_input_mortuary_hospital <> '%' THEN
        SELECT
            CONCAT('%', RTRIM(par_input_mortuary_hospital), '%')
            INTO var_like_mortuary;
    ELSE
        SELECT
            '%'
            INTO var_like_mortuary;
    END IF;
    INSERT INTO t$tx_table1 (mortuary_hospital, active_indicator, effective_date, update_datetime)
    SELECT
        ungrouped_query.mortuary_hospital, active_indicator, effective_date, update_datetime
        FROM (SELECT
            mortuary_hospital, active_indicator, effective_date, update_datetime
            FROM hospital_mortuary) AS ungrouped_query
        INNER JOIN (SELECT
            mortuary_hospital, MAX(effective_date) AS max_1
            FROM hospital_mortuary
            WHERE mortuary_hospital LIKE var_like_mortuary AND effective_date <= timestamp_convert(localtimestamp)
            GROUP BY mortuary_hospital) AS grouped_query
            ON (ungrouped_query.mortuary_hospital = grouped_query.mortuary_hospital OR (ungrouped_query.mortuary_hospital IS NULL AND grouped_query.mortuary_hospital IS NULL))
        WHERE effective_date = max_1;
    INSERT INTO t$tx_table2 (mortuary_hospital, active_indicator, effective_date, update_datetime)
    SELECT
        ungrouped_query.mortuary_hospital, active_indicator, ungrouped_query.effective_date, update_datetime
        FROM (SELECT
            mortuary_hospital, active_indicator, effective_date, update_datetime
            FROM t$tx_table1) AS ungrouped_query
        INNER JOIN (SELECT
            mortuary_hospital, effective_date, MAX(update_datetime) AS max_2
            FROM t$tx_table1
            GROUP BY mortuary_hospital, effective_date) AS grouped_query
            ON (ungrouped_query.mortuary_hospital = grouped_query.mortuary_hospital OR (ungrouped_query.mortuary_hospital IS NULL AND grouped_query.mortuary_hospital IS NULL))
        WHERE update_datetime = max_2
    UNION
    SELECT
        mortuary_hospital, active_indicator, effective_date, update_datetime
        FROM hospital_mortuary
        WHERE effective_date > timestamp_convert(localtimestamp) AND mortuary_hospital LIKE var_like_mortuary;
    OPEN p_refcur FOR
    SELECT
        ungrouped_query.mortuary_hospital, active_indicator, effective_date, update_datetime
        FROM (SELECT
            mortuary_hospital, active_indicator, effective_date, update_datetime
            FROM t$tx_table2) AS ungrouped_query
        INNER JOIN (SELECT
            mortuary_hospital, MIN(effective_date) AS min_1
            FROM t$tx_table2
            GROUP BY mortuary_hospital) AS grouped_query
            ON (ungrouped_query.mortuary_hospital = grouped_query.mortuary_hospital OR (ungrouped_query.mortuary_hospital IS NULL AND grouped_query.mortuary_hospital IS NULL))
        WHERE effective_date = min_1
        ORDER BY mortuary_hospital NULLS FIRST;
      
    
	
   	RAISE NOTICE 'Procedure executed successfully.';
    /*
    
    DROP TABLE IF EXISTS t$tx_table1;
    
    
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$tx_table2;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$procedure$
;

;ALTER PROCEDURE "hasp_display_mortuary" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
