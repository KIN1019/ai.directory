-- DROP PROCEDURE hasp_get_elder_home_adm(inout int4, in varchar, in timestamp, in timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_get_elder_home_adm(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_from_date timestamp without time zone, IN par_to_date timestamp without time zone, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    result_str_value_1 VARCHAR(255);
    result_str_value_2 VARCHAR(255);
    var_source_ind     VARCHAR(1);
    var_patient_name   VARCHAR(48);
    var_source_desc    VARCHAR(50);
    var_case_no        VARCHAR(12);
    var_tx_date        TIMESTAMP WITHOUT TIME ZONE;
    var_ward           VARCHAR(4);
    var_spec           VARCHAR(4);
    var_eh_code        VARCHAR(8);
    var_eh_dist        VARCHAR(40);
    var_eh_name        VARCHAR(255);
    var_hkid           VARCHAR(12);
    csr CURSOR FOR
        SELECT Case_no,
               Transaction_datetime,
               From_ward_code,
               From_specialty_code
        FROM Transaction_log
        WHERE Transaction_datetime >= par_from_date
          AND Transaction_datetime < par_to_date
          AND Transaction_type = '100'
          AND /* HN Case */ Cancel_flag IS NULL
        ORDER BY hospital_code  ,transaction_datetime ;
BEGIN
    DROP TABLE IF EXISTS t$temp_table;
    CREATE TEMPORARY TABLE t$temp_table
    (
        eh_dist      VARCHAR(40)  NULL,
        eh_code      VARCHAR(8),
        eh_name      VARCHAR(255) NULL, /* ---20120726 */
        spec         VARCHAR(4),
        ward         VARCHAR(4),
        adm_date     TIMESTAMP WITHOUT TIME ZONE,
        hkid         VARCHAR(12),
        patient_name VARCHAR(48),
        case_no      VARCHAR(12),
        source_desc  VARCHAR(50)  NULL /* ---20120726 */);

    SELECT 1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
    INTO par_to_date;

    OPEN csr;
    FETCH csr INTO var_case_no, var_tx_date, var_ward, var_spec;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            SELECT EH_code
            --INTO var_eh_code
            INTO result_str_value_1
            FROM HN_case_detail
            WHERE Case_no = var_case_no AND hospital_code = par_hosp_code;
            
            IF FOUND THEN 
        		var_eh_code := result_str_value_1;
        	ELSE 
        		var_eh_code := NULL ;
            END IF ;

            /* Found HN case with Elderly Home info */
            IF var_eh_code IS NOT NULL THEN
                BEGIN
                    SELECT eh_district,
                           CASE 
									WHEN eh_name IS NULL
									OR eh_name = '' THEN eh_chinese_name
									ELSE eh_name
								END AS eh_name
                    -- INTO var_eh_dist, var_eh_name
                    INTO result_str_value_1,result_str_value_2
                    FROM elderly_home_table
                    WHERE eh_code = var_eh_code;
                   
                    IF FOUND THEN
                        var_eh_dist := result_str_value_1;
                        var_eh_name := result_str_value_2;
                    END IF;

                    SELECT HKID,
                           Source_indicator
                    -- INTO var_hkid, var_source_ind
                    INTO result_str_value_1,result_str_value_2
                    FROM Case_view
                    WHERE Case_no = var_case_no;
                   
                    IF FOUND THEN
                        var_hkid := result_str_value_1;
                        var_source_ind := result_str_value_2;
                    END IF;

                    SELECT Description
                    --INTO var_source_desc
                    INTO result_str_value_1
                    FROM Source
                    WHERE Source_indicator = var_source_ind;

                    IF FOUND THEN
                        var_source_desc := result_str_value_1;
                    ELSE 
                    	var_source_desc := NULL ;
                    END IF;

                    SELECT patient_name
                    -- INTO var_patient_name
                    INTO result_str_value_1
                    /* ---	from cpi..cpi_patient */
                    FROM cpi_patient /* For HPI */
                    WHERE hkid = var_hkid;
                   
                    IF FOUND THEN
                        var_patient_name := result_str_value_1;
                    END IF;

                    INSERT INTO t$temp_table
                    VALUES (var_eh_dist, var_eh_code, var_eh_name, var_spec, var_ward, var_tx_date, var_hkid,
                            var_patient_name, var_case_no, var_source_desc);
                END;
            END IF;
            /* searching for other HN case which have EH info */
            FETCH csr INTO var_case_no, var_tx_date, var_ward, var_spec;
        END LOOP;
    CLOSE csr;
    /* Adaptive Server has expanded all '*' elements in the following statement */
    OPEN p_refcur FOR
        SELECT eh_dist,
               eh_code,
               eh_name,
               spec,
               ward,
               adm_date,
               hkid,
               patient_name,
               case_no,
               source_desc
        FROM t$temp_table
        WHERE eh_code IS NOT NULL
          AND eh_name IS NOT NULL /* ---20120726 */
        ORDER BY eh_dist NULLS FIRST, eh_code NULLS FIRST, eh_name NULLS FIRST, spec NULLS FIRST, ward NULLS FIRST,
                 adm_date NULLS FIRST, hkid NULLS FIRST;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_elder_home_adm" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
