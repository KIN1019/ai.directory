-- DROP PROCEDURE hkpmi.hkpmi_monthly_dreg_attend_info(inout int4);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_monthly_dreg_attend_info(INOUT pas_return_code integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_record_date CHAR(10);
    var_hkid_tmp CHAR(09);
    var_hkid CHAR(12);
    var_pkey CHAR(08);
    var_latest_hosp_code CHAR(03);
    var_latest_case_no CHAR(12);
    var_latest_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_rowcount INTEGER;
    var_error INTEGER;
    /* @adm_specialty_code	char(04), */
    /* @imis_code	char(03), */
    var_dreg_rst VARCHAR(255);
    var_dreg_rst2 VARCHAR(255);
    var_latest_disc_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_o_record_date CHAR(10);
    var_o_name CHAR(80);
    var_o_ccc CHAR(24);
    var_o_sex CHAR(1);
    var_o_hkid CHAR(09);
    var_o_death_date CHAR(10);
    var_o_age CHAR(3);
    var_o_doc_no CHAR(22);
    var_o_dob CHAR(10);
    var_o_diagnosis CHAR(4);
    var_o_external_cause CHAR(4);
    var_o_death_place CHAR(150);
    var_o_latest_attend_hospital CHAR(3);
    "var_o_latest_attend_HN" CHAR(12);
    var_o_latest_attend_date CHAR(10);
    var_o_latest_disc_dtm CHAR(10);
    attend_cur CURSOR FOR
    SELECT
        hkid
        FROM death_registry
        WHERE death_external_cause LIKE 'E95%' OR (death_external_cause >= 'X60' AND death_external_cause <= 'X84');
    sql$rowcount BIGINT;
    rst_cur CURSOR FOR
    SELECT
        death_registry.record_date, death_registry.patient_name, death_registry.ccc, death_registry.sex, death_registry.hkid, death_registry.death_date, death_registry.age, death_registry.doc_no, death_registry.dob, death_registry.death_diagnosis, death_registry.death_external_cause, death_registry.death_place, death_registry.latest_attend_hospital, death_registry.latest_attend_HN, death_registry.latest_attend_date, death_registry.latest_discharge_date
        FROM death_registry;
BEGIN
    /* select records from death registry */
    OPEN attend_cur;
    FETCH attend_cur INTO var_hkid_tmp;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        <<process_next>>
        BEGIN
            SELECT
                var_hkid_tmp
                INTO var_hkid;

            IF EXISTS (SELECT
                *
                FROM patient
                WHERE hkid = var_hkid) THEN
                BEGIN
                    SELECT
                        patient_key
                        INTO var_pkey
                        FROM patient
                        WHERE hkid = var_hkid;
                    SELECT
                        MAX(discharge_dtm)
                        INTO var_latest_disc_dtm
                        FROM pmi_case AS p, dr_specialty AS d
                        WHERE p.patient_key = var_pkey AND p.case_no SIMILAR TO ' HN%' AND p.hospital_code = d.hospital_code AND p.last_specialty_code = d.specialty_code AND d.imis_code = 'PSY' AND p.discharge_dtm >= (SELECT
                            MAX(effective_date)
                            FROM pmi_case AS p, dr_specialty AS d
                            WHERE p.patient_key = var_pkey AND p.case_no SIMILAR TO ' HN%' AND p.hospital_code = d.hospital_code AND p.last_specialty_code = d.specialty_code AND d.imis_code = 'PSY' AND d.active_status = 'A');
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    
                        var_rowcount := sql$rowcount;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    

                    IF var_error != 0 THEN
                        BEGIN
                            RAISE NOTICE 'error in getting maximum discharge datetime %', var_hkid;
                            EXIT process_next;
                        END;
                    END IF;

                    IF var_rowcount = 0 OR var_latest_disc_dtm IS NULL THEN
                        EXIT process_next;
                    END IF;
                    begin
                    SELECT
                        hospital_code, case_no, adm_dtm
                        INTO var_latest_hosp_code, var_latest_case_no, var_latest_dtm
                        FROM pmi_case
                        WHERE patient_key = var_pkey AND discharge_dtm = var_latest_disc_dtm;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
					var_rowcount := sql$rowcount;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    
					end;
                    IF var_error != 0 THEN
                        BEGIN
                            RAISE NOTICE 'error in getting attendance record %', var_hkid;
                            EXIT process_next;
                        END;
                    END IF;
		
                    IF var_rowcount != 1 THEN
                        EXIT process_next;
                    ELSE
                        BEGIN
                            /* start to update */
                            /* begin tran */
                            UPDATE death_registry
                            SET latest_attend_hospital = var_latest_hosp_code, latest_attend_HN = var_latest_case_no, latest_attend_date = to_char(var_latest_dtm::TIMESTAMP WITHOUT TIME ZONE, 'DD-MM-YYYY'), latest_discharge_date = to_char(var_latest_disc_dtm::TIMESTAMP WITHOUT TIME ZONE, 'DD-MM-YYYY')
                                WHERE CURRENT OF attend_cur;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            
                            var_rowcount := sql$rowcount;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                           
                        if var_rowcount !=1 or var_error != 0 THEN
                        BEGIN
                            RAISE NOTICE 'error in update attendance record %', var_hkid;
                           	--rollback;
                            raise exception 'error in update attendance record';
                            EXIT process_next;
                        END;
                    	END IF;
                           
                            /* end of update process */
                        END;
                    END IF;
                END;
            ELSE
                EXIT process_next;
            END IF;
        END;
        FETCH attend_cur INTO var_hkid_tmp;
    END LOOP;
    CLOSE attend_cur;
    OPEN rst_cur;
    FETCH rst_cur INTO var_o_record_date, var_o_name, var_o_ccc, var_o_sex, var_o_hkid, var_o_death_date, var_o_age, var_o_doc_no, var_o_dob, var_o_diagnosis, var_o_external_cause, var_o_death_place, var_o_latest_attend_hospital, "var_o_latest_attend_HN", var_o_latest_attend_date, var_o_latest_disc_dtm;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            CONCAT(SUBSTRING(CONCAT(var_o_record_date, REPEAT(' ', 10)), 1, 10), SUBSTRING(CONCAT(var_o_name, REPEAT(' ', 80)), 1, 80), SUBSTRING(CONCAT(var_o_ccc, REPEAT(' ', 24)), 1, 24), SUBSTRING(CONCAT(var_o_sex, REPEAT(' ', 1)), 1, 1), SUBSTRING(CONCAT(var_o_hkid, REPEAT(' ', 9)), 1, 9), SUBSTRING(CONCAT(var_o_death_date, REPEAT(' ', 10)), 1, 10), SUBSTRING(CONCAT(var_o_age, REPEAT(' ', 3)), 1, 3), SUBSTRING(CONCAT(var_o_doc_no, REPEAT(' ', 22)), 1, 22), SUBSTRING(CONCAT(var_o_dob, REPEAT(' ', 10)), 1, 10), SUBSTRING(CONCAT(var_o_diagnosis, REPEAT(' ', 4)), 1, 4), SUBSTRING(CONCAT(var_o_external_cause, REPEAT(' ', 4)), 1, 4))
            INTO var_dreg_rst;
        SELECT
            CONCAT(SUBSTRING(CONCAT(var_o_death_place, REPEAT(' ', 150)), 1, 150), SUBSTRING(CONCAT(var_o_latest_attend_hospital, REPEAT(' ', 3)), 1, 3), SUBSTRING(CONCAT("var_o_latest_attend_HN", REPEAT(' ', 12)), 1, 12), SUBSTRING(CONCAT(var_o_latest_attend_date, REPEAT(' ', 10)), 1, 10), SUBSTRING(CONCAT(var_o_latest_disc_dtm, REPEAT(' ', 10)), 1, 10))
            INTO var_dreg_rst2;
        RAISE NOTICE '% %', var_dreg_rst, var_dreg_rst2;
        FETCH rst_cur INTO var_o_record_date, var_o_name, var_o_ccc, var_o_sex, var_o_hkid, var_o_death_date, var_o_age, var_o_doc_no, var_o_dob, var_o_diagnosis, var_o_external_cause, var_o_death_place, var_o_latest_attend_hospital, "var_o_latest_attend_HN", var_o_latest_attend_date, var_o_latest_disc_dtm;
    END LOOP;
    CLOSE rst_cur;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_monthly_dreg_attend_info" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";