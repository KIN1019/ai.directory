-- DROP FUNCTION hasp_get_patient_attn_history(varchar, varchar, timestamp, timestamp, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hasp_get_patient_attn_history(par_hospital character varying, par_hkid character varying, par_from_date timestamp without time zone, par_to_date timestamp without time zone, par_ae_enable character varying, par_ip_enable character varying, par_ip_eis_specialty character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_patient_key VARCHAR(8);
    var_max_loop_times INTEGER;
    var_counter INTEGER;
    p_refcur refcursor;
BEGIN
    DROP TABLE IF EXISTS t$temp_pat_attn_list;
    CREATE TEMPORARY TABLE t$temp_pat_attn_list
    (hospital VARCHAR(4) NOT NULL,
        attn_type VARCHAR(10) NOT NULL,
        case_no VARCHAR(12) NULL,
        adm_attn_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
        adm_attn_specialty VARCHAR(4) NULL,
        discharge_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
        discharge_specialty VARCHAR(4) NULL);
    /* update to date to the end of date */
    SELECT
        1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
        INTO par_to_date;
    /* CPI */
    SELECT
        patient_key
        INTO var_patient_key
        FROM cpi_patient
        WHERE hkid = par_hkid;

    IF (par_ae_enable = 'Y') THEN
        BEGIN
            INSERT INTO t$temp_pat_attn_list
            SELECT
                cc.hospital_code, 'A&E', cc.case_no, cc.admission_dtm, cc.last_specialty, cc.discharge_dtm, cc.last_specialty
                FROM
                /* AE does not need to check movement as there is only one specialty */
                cpi_case AS cc
                WHERE cc.patient_key = var_patient_key AND cc.admission_dtm >= par_from_date AND cc.admission_dtm <= par_to_date AND cc.hospital_code = par_hospital AND cc.case_type = 'A';
        END;
    END IF;

    IF (par_ip_enable = 'Y') THEN
        BEGIN
            IF (par_ip_eis_specialty is NULL OR par_ip_eis_specialty = '') THEN
                BEGIN
                    SELECT
                        '%'
                        INTO par_ip_eis_specialty;
                END;
            END IF;

            IF par_ip_eis_specialty = '%' THEN
                BEGIN
                    INSERT INTO t$temp_pat_attn_list
                    SELECT
                        cc.hospital_code, 'Inpatient', cc.case_no, cc.admission_dtm,
                        cm_first.specialty AS adm_attn_specialty, cc.discharge_dtm, cm_discharge.specialty AS discharge_specialty 
                    FROM cpi_case cc
                    LEFT JOIN (
                        SELECT case_no, specialty FROM cpi_movement
                        WHERE hospital_code = par_hospital and movement_count = 1
                    ) cm_first ON cc.case_no = cm_first.case_no
                    LEFT JOIN (
                        SELECT case_no, specialty
                        FROM cpi_movement
                        WHERE hospital_code = par_hospital AND movement_type = 'D'
                    ) cm_discharge ON cc.case_no = cm_discharge.case_no
                    WHERE cc.patient_key = var_patient_key 
                        AND cc.hospital_code = par_hospital 
                        AND EXISTS (
                            SELECT 1
                            FROM cpi_movement cm
                            WHERE
                                cm.hospital_code = par_hospital AND
                                cm.case_no = cc.case_no AND
                                cm.movement_dtm >= par_from_date AND
                                cm.movement_dtm <= par_to_date
                        ) 
                        AND cc.case_type = 'I';
                END;
            ELSE
                BEGIN
                    CREATE TEMPORARY TABLE t$temp_specialty
                    (eis_specialty VARCHAR(4) NOT NULL);
                    /* Add number of max loop time to make sure it will be fall into infinity loop */
                    /* calculate max loop time by dividing 4 VARCHARacters for each specialty plus 1 time (in case there is less than 4 VARCHARacters group in the string) */
                    /* --select @counter = 0, @max_loop_times = ((len(@ip_eis_specialty)) / 4) + 1 */
                    /* Avoid calucation error, make the longest loop to 64 instead by calculation, 64 times allow selection of 64 specialties, more than enough */
                    SELECT
                        0, 64
                        INTO var_counter, var_max_loop_times;
                    /* if there is mutliple specialty selected, loop through and put it in temp teble, use it as IN criteria later */
                    WHILE (par_ip_eis_specialty is not NULL AND LENGTH(par_ip_eis_specialty) > 1 AND var_counter < var_max_loop_times) LOOP
                        INSERT INTO t$temp_specialty
                        SELECT
                            RTRIM(SUBSTRING(par_ip_eis_specialty, 1, 4));

                        IF LENGTH(par_ip_eis_specialty) > 4 THEN
                            SELECT
                                SUBSTRING(par_ip_eis_specialty, 5, LENGTH(par_ip_eis_specialty) - 4)
                                INTO par_ip_eis_specialty;
                        ELSE
                            SELECT
                                NULL
                                INTO par_ip_eis_specialty;
                        END IF;
                        SELECT
                            var_counter + 1
                            INTO var_counter;
                    END LOOP;
                    CREATE TEMPORARY TABLE t$temp_effective_specialty
                    (specialty_code VARCHAR(4) NOT NULL,
                        imis_code VARCHAR(4),
                        effective_date TIMESTAMP WITHOUT TIME ZONE);
                    /* Filter the specialty table within the effective period for join by Union two tables */
                    /* 1 - select the latest effective date effected ON or BEFORE from date */
                    INSERT INTO t$temp_effective_specialty
                    SELECT
                        ungrouped_query.specialty_code, imis_code, effective_date
                        FROM (SELECT
                            specialty_code, imis_code, effective_date
                            FROM ip_specialty) AS ungrouped_query
                        INNER JOIN (SELECT
                            specialty_code, MAX(effective_date) AS max_1
                            FROM ip_specialty
                            WHERE hospital_code = par_hospital AND effective_date <= par_from_date AND active_status = 'A'
                            GROUP BY specialty_code) AS grouped_query
                            ON COALESCE(ungrouped_query.specialty_code, '') = COALESCE(grouped_query.specialty_code, '') and effective_date = max_1;
                    /* --UNION */
                    /* 2 - Select the effective date within the range */
                    INSERT INTO t$temp_effective_specialty
                    SELECT
                        specialty_code, imis_code, effective_date
                        FROM ip_specialty
                        WHERE effective_date > par_from_date AND effective_date <= par_to_date AND active_status = 'A';
                    INSERT INTO t$temp_pat_attn_list                   
                    WITH adm_specialty AS (
					    SELECT 
					        case_no, 
					        specialty
					    FROM 
					        cpi_movement
					    WHERE 
					        hospital_code = par_hospital 
					        AND movement_count = 1
					),
					discharge_specialty AS (
					    SELECT 
					        case_no, 
					        specialty
					    FROM 
					        cpi_movement
					    WHERE 
					        hospital_code = par_hospital 
					        AND movement_type = 'D'
					)
					SELECT 
					    cc.hospital_code, 
					    'Inpatient' AS patient_type, 
					    cc.case_no, 
					    cc.admission_dtm, 
					    adm_s.specialty AS adm_attn_specialty, 
					    cc.discharge_dtm, 
					    dis_s.specialty AS discharge_specialty
					FROM  
					    cpi_case cc
					JOIN 
					    cpi_movement cm ON cc.hospital_code = cm.hospital_code 
					                   AND cc.case_no = cm.case_no
					JOIN 
					    t$temp_effective_specialty s ON s.specialty_code = cm.specialty 
					LEFT JOIN 
					    adm_specialty adm_s ON cc.case_no = adm_s.case_no
					LEFT JOIN 
					    discharge_specialty dis_s ON cc.case_no = dis_s.case_no
					WHERE  
					    cc.patient_key =  var_patient_key 
					    AND cc.case_type = 'I' 
					    AND cc.hospital_code = par_hospital
					    AND cm.hospital_code = par_hospital 
					    AND cm.movement_dtm BETWEEN par_from_date AND par_to_date
					    AND s.imis_code IN (SELECT DISTINCT eis_specialty FROM t$temp_specialty)
					GROUP BY 
					    cc.hospital_code, 
					    cc.case_no, 
					    cc.admission_dtm, 
					    cc.discharge_dtm, 
					    adm_s.specialty, 
					    dis_s.specialty
					ORDER BY 
					    cc.case_no;
                    DROP TABLE t$temp_effective_specialty;
                    DROP TABLE t$temp_specialty;
                END;
            END IF;
        END;
    END IF;
    /* Return all result */
    OPEN p_refcur FOR
    SELECT
        hospital, attn_type, case_no, adm_attn_dtm, adm_attn_specialty, discharge_dtm, discharge_specialty
        FROM t$temp_pat_attn_list
        ORDER BY attn_type NULLS FIRST, adm_attn_dtm NULLS FIRST, adm_attn_specialty NULLS FIRST;
    return next p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_get_patient_attn_history" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
