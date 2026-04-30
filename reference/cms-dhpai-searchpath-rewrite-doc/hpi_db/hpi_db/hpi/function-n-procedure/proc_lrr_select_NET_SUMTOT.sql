-- DROP PROCEDURE hpi.proc_lrr_select_net_sumtot(inout int4, in timestamp, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.proc_lrr_select_net_sumtot(INOUT pas_return_code integer, IN par_trans_sys_fdatetime timestamp without time zone, IN par_trans_sys_tdatetime timestamp without time zone, IN par_trans_ns_code01 character varying, IN par_trans_ns_code02 character varying, IN par_trans_ns_code03 character varying, IN par_trans_ns_code04 character varying, IN par_trans_ns_code05 character varying, IN par_inc_flag_ward01 integer, INOUT p_refcur refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_hosp_code VARCHAR(3);
    var_return_code INTEGER;
    var_EXCL_WARD01 VARCHAR(04);
BEGIN
    /* Jack 20 Apr 17 PasCr 201700212 To limit report range up to 2 years - Start */
    IF 12 * (DATE_PART('year', par_TRANS_SYS_TDATETIME::TIMESTAMP) - DATE_PART('year', par_TRANS_SYS_FDATETIME::TIMESTAMP)) + DATE_PART('month', par_TRANS_SYS_TDATETIME::TIMESTAMP) - DATE_PART('month', par_TRANS_SYS_FDATETIME::TIMESTAMP) > 2 THEN
        BEGIN
            RAISE EXCEPTION 'Date range cannot be larger than 3 months' USING ERRCODE := '999999';
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    /* Jack 20 Apr 17 PasCr 201700212 To limit report range up to 2 years - End */
    SELECT
        'AE01'
        INTO var_EXCL_WARD01;
       
    -- CP2 & Harmonycloud on Jan-2025:
    -- Since the ownership of cmslrr_db and the migration approach are to be confirmed with other CMS teams (E.g. Related SPs may be changed to APIs),
    -- the following logic about cmslrr_db was not migrated to PG in this moment and was commented in PG DDL with this remark for record.
    /*
    CALL proc_lrr_get_hosp_map(var_return_code,var_hosp_code);

    IF var_return_code != 0 THEN
        pas_return_code := var_return_code;
        RETURN;
    END IF;
    */
       
    /*
    [3069 - Severity CRITICAL - Automatic conversion of FORCEPLAN clause of SET statement is not supported. Perform a manual conversion.]
    set forceplan on
    */
    /* Noel 01 Dec 14  Cater Transaction_log and Event_log System_datetime unmatch issue - Start */
    drop table if exists t$temp_net_sum_tot;
   
    CREATE TEMPORARY TABLE t$temp_net_sum_tot
    (transaction_datetime TIMESTAMP WITHOUT TIME ZONE NULL,
        case_no VARCHAR(12) NULL,
        hkid VARCHAR(12) NULL,
        patient_name VARCHAR(48) NULL,
        sex VARCHAR(1) NULL,
        dob TIMESTAMP WITHOUT TIME ZONE NULL,
        death_date TIMESTAMP WITHOUT TIME ZONE NULL,
        from_ward_code VARCHAR(4) NULL,
        from_class VARCHAR(1) NULL,
        from_bed VARCHAR(5) NULL,
        from_specialty_code VARCHAR(4) NULL,
        to_ward_code VARCHAR(4) NULL,
        to_class VARCHAR(1) NULL,
        to_bed VARCHAR(5) NULL,
        to_specialty_code VARCHAR(4) NULL,
        description VARCHAR(80) NULL,
        short_description VARCHAR(5) NULL,
        tran_tdate TIMESTAMP WITHOUT TIME ZONE NULL,
        tran_fdate TIMESTAMP WITHOUT TIME ZONE NULL,
        tran_ns_code1 VARCHAR(4) NULL,
        tran_ns_code2 VARCHAR(4) NULL,
        tran_ns_code3 VARCHAR(4) NULL,
        tran_ns_code4 VARCHAR(4) NULL,
        tran_ns_code5 VARCHAR(4) NULL,
        discharge_code VARCHAR(1) NULL,
        destination_code VARCHAR(3) NULL,
        doctor_code VARCHAR(8) NULL,
        system_datetime TIMESTAMP WITHOUT TIME ZONE NULL);
    INSERT INTO t$temp_net_sum_tot
    SELECT
        t1.Transaction_datetime, t1.Case_no, p.hkid, p.patient_name, p.sex, p.dob, p.death_date, t1.From_ward_code, t1.From_class, t1.From_bed, t1.From_specialty_code, t1.To_ward_code, t1.To_class, t1.To_bed, t1.To_specialty_code, (SELECT
            Description
            FROM DT_transaction_type
            WHERE t1.Transaction_type = ADT_code), d1.Short_description, par_TRANS_SYS_TDATETIME, par_TRANS_SYS_FDATETIME, par_TRANS_NS_CODE01, par_TRANS_NS_CODE02, par_TRANS_NS_CODE03, par_TRANS_NS_CODE04, par_TRANS_NS_CODE05, NULL, NULL, NULL, t1.System_datetime
        FROM Transaction_log AS t1, Discharge_type AS d1, Case_view AS c, cpi_patient AS p
        WHERE t1.Hospital_code = var_hosp_code AND SUBSTRING(t1.Transaction_type, 3, 1) = d1.Discharge_code AND (t1.Transaction_type IN ('140', '160', '170', '700', '710', '230', '240') OR t1.Transaction_type LIKE '35%' OR t1.Transaction_type LIKE '21%') AND (t1.Transaction_datetime >= par_TRANS_SYS_FDATETIME) AND (t1.Transaction_datetime <= par_TRANS_SYS_TDATETIME) AND ((t1.From_ward_code IN (par_TRANS_NS_CODE01, par_TRANS_NS_CODE02, par_TRANS_NS_CODE03, par_TRANS_NS_CODE04, par_TRANS_NS_CODE05) OR (t1.From_ward_code LIKE par_TRANS_NS_CODE01 AND t1.From_ward_code <> var_EXCL_WARD01) OR (t1.From_ward_code = var_EXCL_WARD01 AND par_INC_FLAG_WARD01 = 1)) OR (t1.To_ward_code IN (par_TRANS_NS_CODE01, par_TRANS_NS_CODE02, par_TRANS_NS_CODE03, par_TRANS_NS_CODE04, par_TRANS_NS_CODE05) OR (t1.To_ward_code LIKE par_TRANS_NS_CODE01 AND t1.To_ward_code <> var_EXCL_WARD01) OR (t1.To_ward_code = var_EXCL_WARD01 AND par_INC_FLAG_WARD01 = 1))) AND t1.Hospital_code = c.Hospital_code AND t1.Cancel_flag is NULL AND t1.Case_no = c.Case_no AND c.T_PRK = p.patient_key;
    INSERT INTO t$temp_net_sum_tot
    SELECT
        t1.Transaction_datetime, t1.Case_no, p.hkid, p.patient_name, p.sex, p.dob, p.death_date, t1.From_ward_code, t1.From_class, t1.From_bed, t1.From_specialty_code, t1.To_ward_code, t1.To_class, t1.To_bed, t1.To_specialty_code, (SELECT
            Description
            FROM DT_transaction_type
            WHERE t1.Transaction_type = ADT_code), d1.Short_description, par_TRANS_SYS_TDATETIME, par_TRANS_SYS_FDATETIME, par_TRANS_NS_CODE01, par_TRANS_NS_CODE02, par_TRANS_NS_CODE03, par_TRANS_NS_CODE04, par_TRANS_NS_CODE05, c.Discharge_code, c.Destination_code, NULL, t1.System_datetime
        FROM Transaction_log AS t1, Discharge_type AS d1, Case_view AS c, cpi_patient AS p
        WHERE t1.Hospital_code = var_hosp_code AND SUBSTRING(t1.Transaction_type, 3, 1) = d1.Discharge_code AND (t1.Transaction_type LIKE '13%' OR t1.Transaction_type LIKE '33%') AND (t1.Transaction_datetime >= par_TRANS_SYS_FDATETIME) AND (t1.Transaction_datetime <= par_TRANS_SYS_TDATETIME) AND ((t1.From_ward_code IN (par_TRANS_NS_CODE01, par_TRANS_NS_CODE02, par_TRANS_NS_CODE03, par_TRANS_NS_CODE04, par_TRANS_NS_CODE05) OR (t1.From_ward_code LIKE par_TRANS_NS_CODE01 AND t1.From_ward_code <> var_EXCL_WARD01) OR (t1.From_ward_code = var_EXCL_WARD01 AND par_INC_FLAG_WARD01 = 1)) OR (t1.To_ward_code IN (par_TRANS_NS_CODE01, par_TRANS_NS_CODE02, par_TRANS_NS_CODE03, par_TRANS_NS_CODE04, par_TRANS_NS_CODE05) OR (t1.To_ward_code LIKE par_TRANS_NS_CODE01 AND t1.To_ward_code <> var_EXCL_WARD01) OR (t1.To_ward_code = var_EXCL_WARD01 AND par_INC_FLAG_WARD01 = 1))) AND t1.Hospital_code = c.Hospital_code AND t1.Cancel_flag is NULL AND t1.Case_no = c.Case_no AND c.T_PRK = p.patient_key;
    INSERT INTO t$temp_net_sum_tot
    SELECT
        t1.Transaction_datetime, t1.Case_no, p.hkid, p.patient_name, p.sex, p.dob, p.death_date, t1.From_ward_code, t1.From_class, t1.From_bed, t1.From_specialty_code, t1.To_ward_code, t1.To_class, t1.To_bed, t1.To_specialty_code, (SELECT
            Description
            FROM DT_transaction_type
            WHERE t1.Transaction_type = ADT_code), ' ', par_TRANS_SYS_TDATETIME, par_TRANS_SYS_FDATETIME, par_TRANS_NS_CODE01, par_TRANS_NS_CODE02, par_TRANS_NS_CODE03, par_TRANS_NS_CODE04, par_TRANS_NS_CODE05, NULL, NULL, NULL, t1.System_datetime
        FROM Transaction_log AS t1, Case_view AS c, cpi_patient AS p
        WHERE t1.Hospital_code = var_hosp_code AND (t1.Transaction_type IN ('100', '300')) AND (t1.Transaction_datetime >= par_TRANS_SYS_FDATETIME) AND (t1.Transaction_datetime <= par_TRANS_SYS_TDATETIME) AND (t1.From_ward_code IN (par_TRANS_NS_CODE01, par_TRANS_NS_CODE02, par_TRANS_NS_CODE03, par_TRANS_NS_CODE04, par_TRANS_NS_CODE05) OR (t1.From_ward_code LIKE par_TRANS_NS_CODE01 AND t1.From_ward_code <> var_EXCL_WARD01) OR (t1.From_ward_code = var_EXCL_WARD01 AND par_INC_FLAG_WARD01 = 1)) AND (t1.Cancel_flag IS NULL) AND t1.Hospital_code = c.Hospital_code AND t1.Case_no = c.Case_no AND c.T_PRK = p.patient_key;
    INSERT INTO t$temp_net_sum_tot
    SELECT
        t1.Transaction_datetime, t1.Case_no, p.hkid, p.patient_name, p.sex, p.dob, p.death_date, t1.From_ward_code, t1.From_class, t1.From_bed, t1.From_specialty_code, t1.To_ward_code, t1.To_class, t1.To_bed, t1.To_specialty_code, (SELECT
            Description
            FROM DT_transaction_type
            WHERE t1.Transaction_type = ADT_code), ' ', par_TRANS_SYS_TDATETIME, par_TRANS_SYS_FDATETIME, par_TRANS_NS_CODE01, par_TRANS_NS_CODE02, par_TRANS_NS_CODE03, par_TRANS_NS_CODE04, par_TRANS_NS_CODE05, NULL, NULL, NULL, t1.System_datetime
        FROM Transaction_log AS t1, Case_view AS c, cpi_patient AS p
        WHERE (t1.Hospital_code = var_hosp_code) AND (t1.Transaction_type = '220') AND (t1.Transaction_datetime >= par_TRANS_SYS_FDATETIME) AND (t1.Transaction_datetime <= par_TRANS_SYS_TDATETIME) AND ((t1.From_ward_code IN (par_TRANS_NS_CODE01, par_TRANS_NS_CODE02, par_TRANS_NS_CODE03, par_TRANS_NS_CODE04, par_TRANS_NS_CODE05) OR (t1.From_ward_code LIKE par_TRANS_NS_CODE01 AND t1.From_ward_code <> var_EXCL_WARD01) OR (t1.From_ward_code = var_EXCL_WARD01 AND par_INC_FLAG_WARD01 = 1)) OR (t1.To_ward_code IN (par_TRANS_NS_CODE01, par_TRANS_NS_CODE02, par_TRANS_NS_CODE03, par_TRANS_NS_CODE04, par_TRANS_NS_CODE05) OR (t1.To_ward_code LIKE par_TRANS_NS_CODE01 AND t1.To_ward_code <> var_EXCL_WARD01) OR (t1.To_ward_code = var_EXCL_WARD01 AND par_INC_FLAG_WARD01 = 1))) AND t1.Hospital_code = c.Hospital_code AND t1.Case_no = c.Case_no AND c.T_PRK = p.patient_key;
    INSERT INTO t$temp_net_sum_tot
    SELECT
        t1.Transaction_datetime, t1.Case_no, p.hkid, p.patient_name, p.sex, p.dob, p.death_date, m.Ward_code, m.Ward_class, m.Bed_no, m.Specialty_code, t1.To_ward_code, t1.To_class, t1.To_bed, t1.To_specialty_code, 'Discharge from Trial Discharge', d1.Short_description, par_TRANS_SYS_TDATETIME, par_TRANS_SYS_FDATETIME, par_TRANS_NS_CODE01, par_TRANS_NS_CODE02, par_TRANS_NS_CODE03, par_TRANS_NS_CODE04, par_TRANS_NS_CODE05, c.Discharge_code, c.Destination_code, NULL, t1.System_datetime
        FROM Transaction_log AS t1, Discharge_type AS d1, Case_view AS c, cpi_patient AS p, Movement AS m
        WHERE t1.Hospital_code = var_hosp_code AND SUBSTRING(t1.Transaction_type, 3, 1) = d1.Discharge_code AND t1.Transaction_type LIKE '13%' AND (t1.Transaction_datetime >= par_TRANS_SYS_FDATETIME) AND (t1.Transaction_datetime <= par_TRANS_SYS_TDATETIME) AND t1.From_ward_code = 'HOME' AND t1.Hospital_code = c.Hospital_code AND t1.Cancel_flag is NULL AND t1.Case_no = c.Case_no AND c.T_PRK = p.patient_key AND m.Hospital_code = c.Hospital_code AND m.Movement_count = c.Movement_count - 2 AND m.Case_no = c.Case_no AND (m.Ward_code IN (par_TRANS_NS_CODE01, par_TRANS_NS_CODE02, par_TRANS_NS_CODE03, par_TRANS_NS_CODE04, par_TRANS_NS_CODE05) OR (m.Ward_code LIKE par_TRANS_NS_CODE01 AND m.Ward_code <> var_EXCL_WARD01) OR (m.Ward_code = var_EXCL_WARD01 AND par_INC_FLAG_WARD01 = 1));
    UPDATE t$temp_net_sum_tot
    SET doctor_code = e.Doctor_code
    FROM Event_log AS e
        WHERE t$temp_net_sum_tot.system_datetime = e.System_datetime AND t$temp_net_sum_tot.case_no = e.Case_no AND e.Hospital_code = var_hosp_code;
    OPEN p_refcur FOR
    SELECT
        transaction_datetime, case_no, hkid, patient_name, sex, dob, death_date, from_ward_code, from_class, from_bed, from_specialty_code, to_ward_code, to_class, to_bed, to_specialty_code, description, short_description, tran_tdate, tran_fdate, tran_ns_code1, tran_ns_code2, tran_ns_code3, tran_ns_code4, tran_ns_code5, discharge_code, destination_code, doctor_code
        FROM t$temp_net_sum_tot;
    /*
    select t1.Transaction_datetime,
                   t1.Case_no,
                   p.hkid,
                   p.patient_name,
                   p.sex,
                   p.dob,
                   p.death_date,
                   t1.From_ward_code,
                   t1.From_class,
                   t1.From_bed,
                   t1.From_specialty_code,
                   t1.To_ward_code,
                   t1.To_class,
                   t1.To_bed,
                   t1.To_specialty_code,
    	           (select Description from DT_transaction_type
    			   where t1.Transaction_type = ADT_code),
    			   d1.Short_description,
                   @TRANS_SYS_TDATETIME,
                   @TRANS_SYS_FDATETIME,
                   @TRANS_NS_CODE01,
                   @TRANS_NS_CODE02,
                   @TRANS_NS_CODE03,
                   @TRANS_NS_CODE04,
                   @TRANS_NS_CODE05,
                   null,
                   null,
                   e.Doctor_code
              from Transaction_log t1 (index XIE2Transaction_Log), Discharge_type d1,
                   Case_view c, cpi_patient p, Event_log e (index XIE1Event_log)
             where t1.Hospital_code = @hosp_code and
    		 substring(t1.Transaction_type,3,1)=d1.Discharge_code
    		 and
                   ( t1.Transaction_type in ('140','160','170','700','710', '230', '240') or
                     t1.Transaction_type like '35%' or
                     t1.Transaction_type like '21%') and
                   (t1.Transaction_datetime >= @TRANS_SYS_FDATETIME) and
                   (t1.Transaction_datetime <= @TRANS_SYS_TDATETIME) and
                   ((	t1.From_ward_code in (@TRANS_NS_CODE01, @TRANS_NS_CODE02, @TRANS_NS_CODE03, @TRANS_NS_CODE04, @TRANS_NS_CODE05)
    				or (t1.From_ward_code like @TRANS_NS_CODE01 and t1.From_ward_code <> @EXCL_WARD01)
    				or (t1.From_ward_code = @EXCL_WARD01 and @INC_FLAG_WARD01 = 1)
    			   )	 or
    			   (	t1.To_ward_code in (@TRANS_NS_CODE01, @TRANS_NS_CODE02, @TRANS_NS_CODE03, @TRANS_NS_CODE04, @TRANS_NS_CODE05)
    				or (t1.To_ward_code like @TRANS_NS_CODE01 and t1.To_ward_code <> @EXCL_WARD01)
    				or (t1.To_ward_code = @EXCL_WARD01 and @INC_FLAG_WARD01 = 1)
    			   )) and
    		t1.Hospital_code = c.Hospital_code and
    		 t1.Cancel_flag = null   and
    		 t1.Case_no = c.Case_no  and
                     c.T_PRK    = p.patient_key and
                     t1.Hospital_code = e.Hospital_code and
                     t1.System_datetime = e.System_datetime and
                     t1.Case_no = e.Case_no
    
    union
    
            select t1.Transaction_datetime,
                   t1.Case_no,
                   p.hkid,
                   p.patient_name,
                   p.sex,
                   p.dob,
                   p.death_date,
                   t1.From_ward_code,
                   t1.From_class,
                   t1.From_bed,
                   t1.From_specialty_code,
                   t1.To_ward_code,
                   t1.To_class,
                   t1.To_bed,
                   t1.To_specialty_code,
    	           (select Description from DT_transaction_type
    			   where t1.Transaction_type = ADT_code),
    			   d1.Short_description,
                   @TRANS_SYS_TDATETIME,
                   @TRANS_SYS_FDATETIME,
                   @TRANS_NS_CODE01,
                   @TRANS_NS_CODE02,
                   @TRANS_NS_CODE03,
                   @TRANS_NS_CODE04,
                   @TRANS_NS_CODE05,
                   c.Discharge_code,
                   c.Destination_code,
                   e.Doctor_code
              from Transaction_log t1 (index XIE2Transaction_Log), Discharge_type d1,
                   Case_view c, cpi_patient p, Event_log e (index XIE1Event_log)
             where t1.Hospital_code = @hosp_code and
    		 substring(t1.Transaction_type,3,1)=d1.Discharge_code
    		 and
                   (t1.Transaction_type like '13%' or
                    t1.Transaction_type like '33%' ) and
                   (t1.Transaction_datetime >= @TRANS_SYS_FDATETIME) and
                   (t1.Transaction_datetime <= @TRANS_SYS_TDATETIME) and
                   ((	t1.From_ward_code in (@TRANS_NS_CODE01, @TRANS_NS_CODE02, @TRANS_NS_CODE03, @TRANS_NS_CODE04, @TRANS_NS_CODE05)
    				or (t1.From_ward_code like @TRANS_NS_CODE01 and t1.From_ward_code <> @EXCL_WARD01)
    				or (t1.From_ward_code = @EXCL_WARD01 and @INC_FLAG_WARD01 = 1)
    			   )	 or
    			   (	t1.To_ward_code in (@TRANS_NS_CODE01, @TRANS_NS_CODE02, @TRANS_NS_CODE03, @TRANS_NS_CODE04, @TRANS_NS_CODE05)
    				or (t1.To_ward_code like @TRANS_NS_CODE01 and t1.To_ward_code <> @EXCL_WARD01)
    				or (t1.To_ward_code = @EXCL_WARD01 and @INC_FLAG_WARD01 = 1)
    			   )) and
    		t1.Hospital_code = c.Hospital_code and
    		 t1.Cancel_flag = null   and
    		 t1.Case_no = c.Case_no  and
                     c.T_PRK    = p.patient_key and
                     t1.Hospital_code = e.Hospital_code and
                     t1.System_datetime = e.System_datetime and
                     t1.Case_no = e.Case_no
    
    union
    
    
    
    		select t1.Transaction_datetime,
                   t1.Case_no,
    			   p.hkid,
    			   p.patient_name,
    			   p.sex,
    			   p.dob,
    			   p.death_date,
                   t1.From_ward_code,
                   t1.From_class,
                   t1.From_bed,
                   t1.From_specialty_code,
                   t1.To_ward_code,
                   t1.To_class,
                   t1.To_bed,
                   t1.To_specialty_code,
    	           (select Description from DT_transaction_type
    			   where t1.Transaction_type = ADT_code),
    			   ' ',
                   @TRANS_SYS_TDATETIME,
                   @TRANS_SYS_FDATETIME,
                   @TRANS_NS_CODE01,
                   @TRANS_NS_CODE02,
                   @TRANS_NS_CODE03,
                   @TRANS_NS_CODE04,
                   @TRANS_NS_CODE05,
                   null,
                   null,
                   e.Doctor_code
              from Transaction_log t1 (index XIE2Transaction_Log),
                   Case_view c, cpi_patient p, Event_log e (index XIE1Event_log)
             where
    	       t1.Hospital_code = @hosp_code and
                   (t1.Transaction_type in ('100', '300')) and
                   (t1.Transaction_datetime >= @TRANS_SYS_FDATETIME) and
                   (t1.Transaction_datetime <= @TRANS_SYS_TDATETIME) and
    		(t1.From_ward_code in (@TRANS_NS_CODE01, @TRANS_NS_CODE02, @TRANS_NS_CODE03, @TRANS_NS_CODE04, @TRANS_NS_CODE05)
    				or (t1.From_ward_code like @TRANS_NS_CODE01 and t1.From_ward_code <> @EXCL_WARD01)
    				or (t1.From_ward_code = @EXCL_WARD01 and @INC_FLAG_WARD01 = 1)
    			   ) and
                   (t1.Cancel_flag is NULL) and
                   t1.Hospital_code = c.Hospital_code and
                   t1.Case_no = c.Case_no  and
                   c.T_PRK    = p.patient_key and
                   t1.Hospital_code = e.Hospital_code and
                   t1.System_datetime = e.System_datetime and
                   t1.Case_no = e.Case_no
    
    union
           select  t1.Transaction_datetime,
                       t1.Case_no,
                       p.hkid,
                       p.patient_name,
                       p.sex,
                       p.dob,
                       p.death_date,
                       t1.From_ward_code,
                       t1.From_class,
                       t1.From_bed,
                       t1.From_specialty_code,
                       t1.To_ward_code,
                       t1.To_class,
                       t1.To_bed,
                       t1.To_specialty_code,
    	           (select Description from DT_transaction_type
    			   where t1.Transaction_type = ADT_code),
    				   ' ',
                       @TRANS_SYS_TDATETIME,
                       @TRANS_SYS_FDATETIME,
                   @TRANS_NS_CODE01,
                   @TRANS_NS_CODE02,
                   @TRANS_NS_CODE03,
                   @TRANS_NS_CODE04,
                   @TRANS_NS_CODE05,
                       null,
                       null,
                       e.Doctor_code
                 from Transaction_log t1 (index XIE2Transaction_Log),
                      Case_view c, cpi_patient p, Event_log e (index XIE1Event_log)
                 where
    	(t1.Hospital_code = @hosp_code) and
            (t1.Transaction_type = '220') and
             (t1.Transaction_datetime >= @TRANS_SYS_FDATETIME) and
             (t1.Transaction_datetime <= @TRANS_SYS_TDATETIME) and
                   ((	t1.From_ward_code in (@TRANS_NS_CODE01, @TRANS_NS_CODE02, @TRANS_NS_CODE03, @TRANS_NS_CODE04, @TRANS_NS_CODE05)
    				or (t1.From_ward_code like @TRANS_NS_CODE01 and t1.From_ward_code <> @EXCL_WARD01)
    				or (t1.From_ward_code = @EXCL_WARD01 and @INC_FLAG_WARD01 = 1)
    			   )	 or
    			   (	t1.To_ward_code in (@TRANS_NS_CODE01, @TRANS_NS_CODE02, @TRANS_NS_CODE03, @TRANS_NS_CODE04, @TRANS_NS_CODE05)
    				or (t1.To_ward_code like @TRANS_NS_CODE01 and t1.To_ward_code <> @EXCL_WARD01)
    				or (t1.To_ward_code = @EXCL_WARD01 and @INC_FLAG_WARD01 = 1)
    			   )) and
    			t1.Hospital_code = c.Hospital_code and
    			   t1.Case_no = c.Case_no  and
                               c.T_PRK    = p.patient_key and
                               t1.Hospital_code = e.Hospital_code and
                               t1.System_datetime = e.System_datetime and
                               t1.Case_no = e.Case_no
    
    union
    	select t1.Transaction_datetime,
                   t1.Case_no,
                   p.hkid,
                   p.patient_name,
                   p.sex,
                   p.dob,
                   p.death_date,
                   m.Ward_code,
                   m.Ward_class,
                   m.Bed_no,
                   m.Specialty_code,
                   t1.To_ward_code,
                   t1.To_class,
                   t1.To_bed,
                   t1.To_specialty_code,
                   Discharge from Trial Discharge,
                   d1.Short_description,
                   @TRANS_SYS_TDATETIME,
                   @TRANS_SYS_FDATETIME,
                   @TRANS_NS_CODE01,
                   @TRANS_NS_CODE02,
                   @TRANS_NS_CODE03,
                   @TRANS_NS_CODE04,
                   @TRANS_NS_CODE05,
                   c.Discharge_code,
                   c.Destination_code,
                   e.Doctor_code
              from Transaction_log t1 (index XIE2Transaction_Log), Discharge_type d1,
                   Case_view c, cpi_patient p,  Movement m, Event_log e (index XIE1Event_log)
             where t1.Hospital_code = @hosp_code and
                   substring(t1.Transaction_type,3,1)=d1.Discharge_code  and
                   t1.Transaction_type like '13%' and
                   (t1.Transaction_datetime >= @TRANS_SYS_FDATETIME) and
                   (t1.Transaction_datetime <= @TRANS_SYS_TDATETIME) and
                   t1.From_ward_code = HOME and
                   t1.Hospital_code = c.Hospital_code and
                   t1.Cancel_flag = null   and
                   t1.Case_no = c.Case_no  and
                   c.T_PRK    = p.patient_key and
                   m.Hospital_code = c.Hospital_code and
                   m.Movement_count = c.Movement_count - 2 and
                   m.Case_no = c.Case_no and
                   (m.Ward_code in (@TRANS_NS_CODE01, @TRANS_NS_CODE02, @TRANS_NS_CODE03, @TRANS_NS_CODE04, @TRANS_NS_CODE05)
    					or (m.Ward_code like @TRANS_NS_CODE01 and m.Ward_code <> @EXCL_WARD01)
    					or (m.Ward_code = @EXCL_WARD01 and @INC_FLAG_WARD01 = 1)
    			   	) and
                   t1.Hospital_code = e.Hospital_code and
                   t1.System_datetime = e.System_datetime and
                   t1.Case_no = e.Case_no
    */
    /* Noel 01 Dec 14  Cater Transaction_log and Event_log System_datetime unmatch issue - End */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of FORCEPLAN clause of SET statement is not supported. Perform a manual conversion.]
    set forceplan off
    */
    pas_return_code := 0;
    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$temp_net_sum_tot;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
/* ### DEFNCOPY: END OF DEFINITION */
$procedure$
;


;ALTER PROCEDURE "proc_lrr_select_net_sumtot" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
