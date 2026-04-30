-- DROP PROCEDURE hasp_get_elder_home_discharge(inout int4, in varchar, in timestamp, in timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_get_elder_home_discharge(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_from_date timestamp without time zone, IN par_to_date timestamp without time zone, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_case         VARCHAR(12);
    var_tx_date      TIMESTAMP WITHOUT TIME ZONE;
    var_ward         VARCHAR(4);
    var_spec         VARCHAR(4);
    var_eh_code      VARCHAR(8);
    var_eh_dist      VARCHAR(40);
    var_eh_name      VARCHAR(255);
    var_hkid         VARCHAR(12);
    var_patient_name VARCHAR(48);
    var_dsch_code    VARCHAR(1);
    var_dest_desc    VARCHAR(5);
    var_adm_dtm      TIMESTAMP WITHOUT TIME ZONE;
    var_dest_code    VARCHAR(3);
    csr CURSOR FOR
        SELECT Case_no,
               Transaction_datetime,
               From_ward_code,
               From_specialty_code
        FROM Transaction_log
        WHERE Transaction_datetime >= par_from_date
          AND Transaction_datetime < par_to_date
          AND Transaction_type LIKE '13_'
          AND Cancel_flag IS NULL;
    sql$rowcount     BIGINT;
BEGIN
    DROP TABLE IF EXISTS t$temp_table;
    CREATE TEMPORARY TABLE t$temp_table
    (
        eh_dist      VARCHAR(40) NULL,
        eh_code      VARCHAR(8),
        eh_name      VARCHAR(255),
        spec         VARCHAR(4),
        ward         VARCHAR(4),
        case_no      VARCHAR(12),
        adm_dtm      TIMESTAMP WITHOUT TIME ZONE,
        dsch_code    VARCHAR(1),
        dest_desc    VARCHAR(5)  NULL,
        dsch_date    TIMESTAMP WITHOUT TIME ZONE,
        hkid         VARCHAR(12),
        patient_name VARCHAR(48)
    );
    SELECT 1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
    INTO par_to_date;

    OPEN csr;
    FETCH csr INTO var_case, var_tx_date, var_ward, var_spec;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
        END) = 0
        LOOP
            SELECT EH_code
            INTO var_eh_code
            FROM HN_case_detail
            WHERE Case_no = var_case
			and EH_code in (select eh_code from elderly_home_table);
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount <> 1 THEN
                SELECT NULL
                INTO var_eh_code;
            END IF;

            IF var_eh_code IS NOT NULL THEN
                BEGIN
                    IF EXISTS(SELECT eh_district,
                                     eh_name
                              FROM elderly_home_table
                              WHERE eh_code = var_eh_code) THEN
                        SELECT eh_district,
                               CASE 
									WHEN eh_name IS NULL
									OR eh_name = '' THEN eh_chinese_name
									ELSE eh_name
								END AS eh_name
                        INTO var_eh_dist, var_eh_name
                        FROM elderly_home_table
                        WHERE eh_code = var_eh_code;
                    END IF;

                    IF EXISTS(SELECT HKID,
                                     Admission_datetime,
                                     Discharge_code,
                                     Destination_code
                              FROM Case_view
                              WHERE Case_no = var_case) THEN
                        SELECT HKID,
                               Admission_datetime,
                               Discharge_code,
                               Destination_code
                        INTO var_hkid, var_adm_dtm, var_dsch_code, var_dest_code
                        FROM Case_view
                        WHERE Case_no = var_case;
                    END IF;

                    IF var_dsch_code IS NULL THEN
                        SELECT NULL
                        INTO var_dest_desc;
                    ELSE
                        BEGIN
                            IF var_dsch_code NOT IN ('0', '4', '9') THEN
                                IF EXISTS(SELECT Short_description
                                          FROM Discharge_type
                                          WHERE Discharge_code = var_dsch_code) THEN
                                    SELECT Short_description
                                    INTO var_dest_desc
                                    FROM Discharge_type
                                    WHERE Discharge_code = var_dsch_code;
                                END IF;
                            ELSE
                                SELECT var_dest_code
                                INTO var_dest_desc;
                            END IF;
                        END;
                    END IF;

                    IF EXISTS(SELECT Name
                              FROM PMI_wo_MRN
                              WHERE HKID = var_hkid) THEN
                        SELECT Name
                        INTO var_patient_name
                        FROM PMI_wo_MRN
                        WHERE HKID = var_hkid;
                    END IF;

                    INSERT INTO t$temp_table
                    VALUES (var_eh_dist, var_eh_code, var_eh_name, var_spec, var_ward, var_case, var_adm_dtm,
                            var_dsch_code, var_dest_desc, var_tx_date, var_hkid, var_patient_name);
                END;
            END IF;
            /* Clear Buffer */
            SELECT NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL
            INTO var_eh_dist, var_eh_code, var_eh_name, var_spec, var_ward, var_case, var_adm_dtm, var_dsch_code, var_dest_desc, var_tx_date, var_hkid, var_patient_name;
            FETCH csr INTO var_case, var_tx_date, var_ward, var_spec;
        END LOOP;
    CLOSE csr;
    
    OPEN p_refcur FOR
        SELECT eh_dist,
               eh_code,
               eh_name,
               spec,
               ward,
               case_no,
               adm_dtm,
               dsch_code,
               dest_desc,
               dsch_date,
               hkid,
               patient_name
        FROM t$temp_table
        ORDER BY eh_dist NULLS FIRST, eh_code NULLS FIRST, eh_name NULLS FIRST, spec NULLS FIRST, ward NULLS FIRST,
                 case_no NULLS FIRST, adm_dtm NULLS FIRST, dsch_code NULLS FIRST, dest_desc NULLS FIRST,
                 dsch_date NULLS FIRST, hkid NULLS FIRST, patient_name NULLS FIRST;
    
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_elder_home_discharge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
