CREATE OR REPLACE PROCEDURE hasp_dnl_pat_loc_to_PC(INOUT pas_return_code int, IN par_hosp_code VARCHAR, INOUT p_refcur refcursor)
AS 
$BODY$
/* -- add hospital_code as input parm by WL on 27 July 1999 -- */
DECLARE
    var_temp_name VARCHAR(96);
    var_temp_sex VARCHAR(2);
    var_temp_space_1 VARCHAR(2);
    var_temp_space_2 VARCHAR(4);
    var_temp_home_phone_no VARCHAR(20);
    var_temp_ward_code VARCHAR(8);
    var_temp_bed VARCHAR(10);
    var_temp_disc_date VARCHAR(16);
    var_temp_disc_time VARCHAR(20);
    var_temp_dest_code VARCHAR(6);
    var_temp_space_3 VARCHAR(6);
    var_temp_mrn VARCHAR(16);
    var_temp_hkid VARCHAR(24);
    var_temp_patient_key VARCHAR(16);
    var_temp_adm_dtm VARCHAR(16);
    var_temp_dob VARCHAR(16);
    var_temp_case_no VARCHAR(24);
    var_temp_access_code INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_temp_specialty_code VARCHAR(8);
    var_temp_ward_class VARCHAR(2);
    var_temp_race VARCHAR(4);
    var_temp_adm_time VARCHAR(16);
    sel_pat_loc_csr CURSOR FOR
    SELECT
        patient_name, sex, home_phone_no, dob, patient_key, case_no
        FROM t$pat_loc_table;
    sql$rowcount BIGINT;
BEGIN
    /* -- Remarked by WL on 27 July 1999, becasue it is input parm -- */
    
    /* --declare @hosp_code char(3) */
    
    /* Remarked by WL on 27 July 1999 for HPI -- */
    
    /*
    select @hosp_code = Text_value
     from Hospital_control
    where Type = 'hospital_code'
    */
    SELECT
        REPEAT(' ', 3)
        INTO var_temp_space_3;
    SELECT
        REPEAT(' ', 2)
        INTO var_temp_space_2;
    SELECT
        REPEAT(' ', 1)
        INTO var_temp_space_1;
    /* create temp patient location table */
    DROP TABLE IF EXISTS t$pat_loc_table;
    CREATE TEMPORARY TABLE t$pat_loc_table
    (patient_name VARCHAR(96) NULL,
        sex VARCHAR(2) NULL,
        space_3 VARCHAR(6) NULL,
        space_2 VARCHAR(4) NULL,
        home_phone_no VARCHAR(20) NULL,
        ward_code VARCHAR(8) NULL,
        bed_no VARCHAR(10) NULL,
        disc_date VARCHAR(16) NULL,
        disc_time VARCHAR(20) NULL,
        dest_code VARCHAR(6) NULL,
        space_1 VARCHAR(2) NULL,
        mrn VARCHAR(16) NULL,
        hkid VARCHAR(24) NULL,
        patient_key VARCHAR(16) NULL,
        adm_dtm VARCHAR(16) NULL,
        dob VARCHAR(16) NULL,
        access_code INTEGER NULL,
        case_no VARCHAR(24) NULL,
        race VARCHAR(4) NULL,
        ward_class VARCHAR(2) NULL,
        specialty_code VARCHAR(8) NULL,
        adm_time VARCHAR(8) NULL);
    CREATE UNIQUE INDEX pat_loc_index ON t$pat_loc_table
        (case_no);
    /* -- remove cpi.. by WL on 27 July 1999 for HPI--- */
    INSERT INTO t$pat_loc_table (patient_name, sex, home_phone_no, dob, patient_key, case_no)
    SELECT
        patient_name, sex, mobile_phone, to_char(dob, 'YYYYMMDD'), patient_key, case_no
        /* --from cpi..cpi_patient_location */
        FROM cpi_patient_location;
    OPEN sel_pat_loc_csr;
    FETCH sel_pat_loc_csr INTO var_temp_name, var_temp_sex, var_temp_home_phone_no, var_temp_dob, var_temp_patient_key, var_temp_case_no;

    IF ((CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 2) THEN
        BEGIN
            RAISE EXCEPTION '% ', 'No patient location information available!' USING ERRCODE := '20026';
            CLOSE sel_pat_loc_csr;
            pas_return_code := 0;
            RETURN;
        END;
    END IF;

    WHILE ((CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0) LOOP
        /* -- remove cpi.. and add hosp_code by WL on 27 July 1999-- */
        
        /* table join and insert data into temp table */
        SELECT
            m.Ward_code, m.Ward_class, m.Specialty_code, m.Bed_no,
			to_char(c.Discharge_datetime, 'YYYYMMDD'),
			CONCAT(SUBSTRING(to_char(c.Discharge_datetime, 'HH24:mi:ss'), 1, 2),
				   SUBSTRING(to_char(c.Discharge_datetime, 'HH24:mi:ss'), 4, 2)),
			c.Destination_code, h.mrn, p.hkid, p.access_code,
			to_char(c.Admission_datetime, 'YYYYMMDD'),
			CONCAT(SUBSTRING(to_char(c.Admission_datetime, 'YYYYMMDD'), 1, 2),
				   SUBSTRING(to_char(c.Admission_datetime, 'HH24:mi:ss'), 4, 2)),
			p.race
            INTO var_temp_ward_code, var_temp_ward_class, var_temp_specialty_code, var_temp_bed, var_temp_disc_date, var_temp_disc_time, var_temp_dest_code, var_temp_mrn, var_temp_hkid, var_temp_access_code, var_temp_adm_dtm, var_temp_adm_time, var_temp_race
            FROM ADT_Case AS c, Movement AS m,
            /* --cpi..cpi_patient p, */
            cpi_patient AS p,
            /* --cpi..cpi_patient_hospital_data h */
            cpi_patient_hospital_data AS h
            WHERE (c.Case_no = m.Case_no) AND (c.Case_no = var_temp_case_no) AND (c.Hospital_code = par_hosp_code) AND (c.Movement_count = m.Movement_count) AND (m.Hospital_code = par_hosp_code) AND (var_temp_patient_key = p.patient_key) AND (h.hospital_code = par_hosp_code) AND (h.patient_key = var_temp_patient_key);
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF var_rowcount = 1 THEN
            BEGIN
                BEGIN
                    UPDATE t$pat_loc_table
                    SET space_3 = var_temp_space_3, space_2 = var_temp_space_2, ward_code = var_temp_ward_code, specialty_code = var_temp_specialty_code, ward_class = var_temp_ward_class, bed_no = var_temp_bed, disc_date = var_temp_disc_date, disc_time = var_temp_disc_time, dest_code = var_temp_dest_code, space_1 = var_temp_space_1, mrn = var_temp_mrn, hkid = var_temp_hkid, adm_dtm = var_temp_adm_dtm, adm_time = var_temp_adm_time, access_code = var_temp_access_code, race = var_temp_race
                        WHERE CURRENT OF sel_pat_loc_csr;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF (var_error <> 0) THEN
                    BEGIN
                        RAISE EXCEPTION '% ', 'hasp_dnl_pat_loc_to_PC - update temp table failed!' USING ERRCODE := '20026';
                        CLOSE sel_pat_loc_csr;
                        pas_return_code := 0;
                        RETURN;
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                DELETE FROM t$pat_loc_table
                    WHERE CURRENT OF sel_pat_loc_csr;
            END;
        END IF;
        FETCH sel_pat_loc_csr INTO var_temp_name, var_temp_sex, var_temp_home_phone_no, var_temp_dob, var_temp_patient_key, var_temp_case_no;
    END LOOP;

    IF ((CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 1) THEN
        BEGIN
            RAISE EXCEPTION '% ', 'hasp_dnl_pat_loc_to_PC - Error in fetching cursor!' USING ERRCODE := '20026';
            CLOSE sel_pat_loc_csr;
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    CLOSE sel_pat_loc_csr;
    /* display data in temp table */
    OPEN p_refcur FOR
    SELECT
        patient_name, sex, space_3, space_2, home_phone_no, ward_code, bed_no, disc_date, disc_time, dest_code, space_1, mrn, hkid, adm_dtm, dob, access_code, race, ward_class, specialty_code, case_no, adm_time
        FROM t$pat_loc_table;
    -- DROP TABLE t$pat_loc_table;
    /*
    
    DROP TABLE IF EXISTS t$pat_loc_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$BODY$
LANGUAGE plpgsql;