-- DROP FUNCTION hkpmi.hkpmi_monthly_death_reg();

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_monthly_death_reg()
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_record_date varchar(10);
    var_hkid       varchar(09);
    var_ccc        varchar(24);
    var_name       varchar(48);
    var_tmp_name       varchar(48);
    var_sex        varchar(01);
    var_dob        varchar(10);
    var_death_date varchar(10);
    var_diagnosis  varchar(04);
    var_org_death_indicator varchar(04);
    var_org_death_diagnosis  varchar(04);
    var_external_cause varchar(04);
    var_org_death_external_cause varchar(04);
    var_fail_msg   varchar(80);
    var_pat_name   varchar(48);
    var_tmp_pat_name   varchar(48);
    var_pat_sex    varchar(01);
    var_pat_dob    TIMESTAMP WITHOUT TIME ZONE;
    var_pat_dob_flag varchar(01);
    var_pat_ccc    varchar(24);
    var_pat_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_death_indicator varchar(04);
    var_death_date_dt   TIMESTAMP WITHOUT TIME ZONE;
    var_sys_date	TIMESTAMP WITHOUT TIME ZONE;
    var_source_system  varchar(03);
    var_update_by      varchar(08);
    var_dob_dt     TIMESTAMP WITHOUT TIME ZONE;
    var_retx_code  int;
    var_commit_flag  varchar(01);
    var_hosp_code  varchar(03);
    var_hkid_char  varchar(12);
    var_hkid_tmp   varchar(12);
    var_active_status varchar(01);
    var_upd_dtm    TIMESTAMP WITHOUT TIME ZONE;
    var_error		int;
    var_rowcount	int;
    var_last_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_tmp_char		varchar(1);
    var_tmp_date		varchar(30);
    var_tmp_pos		int;
    var_char_len		int;
    var_exact_death_date	varchar(01);
    dreg_cur cursor
      for select record_date,hkid,patient_name,sex,
      dob,death_date,death_diagnosis,death_external_cause,ccc
      from death_registry;

	p_refcur refcursor;
    sql$rowcount BIGINT;
/* check for death cause only */
/* check for setting death */
BEGIN
    select  
    'ADT'
    into var_source_system;
    select 
    'DREG'
    into var_update_by;
    select 
    'DR'
    into var_death_indicator;
    select
    'DR'
    into var_hosp_code;
    
    open dreg_cur;
    fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
            var_death_date,var_diagnosis,var_external_cause,var_ccc;
    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        select 
        null,null
        into var_death_date_dt,var_dob_dt;
        select 
        null,null,null
        into var_fail_msg,var_pat_name,var_pat_ccc;
        select 
        null,null,null
        into var_pat_sex,var_pat_dob,var_pat_dob_flag;
		select 
        'N'
        into var_commit_flag;
        select  
        'Y'
        into var_active_status;
        select 
        upper(right(repeat(' ',9)||var_hkid,9))
        into var_hkid_tmp;
      --select var_hkid_tmp
        select 
        var_hkid_tmp
        into var_hkid_char;
        select   
        timestamp_convert(localtimestamp)
        into var_sys_date;
        select 
        'DR'
        into var_death_indicator;


        if rtrim(var_hkid_char) is null then
            begin
                select  
                'Invalid HKID'
                into  var_fail_msg;
                --goto insert_error

                INSERT INTO hkpmi.death_reg_error(system_datetime, record_date, hkid, death_indicator, death_date, death_diagnosis, death_external_cause, err_msg, patient_name, ccc, sex, dob)
                values(timestamp_convert(localtimestamp),var_record_date,var_hkid_char,
                        var_death_indicator,var_death_date,
                        var_diagnosis,var_external_cause,var_fail_msg,var_name,var_ccc,var_sex,var_dob);
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                if var_error!=0 then
                    begin
                        raise notice 'Error in insertion of death_reg_error ';
                        raise notice 'hkid : %s death_diagnosis:%s external_cause: %s 
                            death_date : %s error_msg: %s',var_hkid_char,var_diagnosis,
                            var_external_cause,var_death_date,var_fail_msg ;
                    end;
                end if;

                begin
                    delete  from death_registry 
                        where current of dreg_cur;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                end;

                if var_error!=0 then 
                    begin
                        raise notice ' error in deleting death_registry ';
                        raise notice 'hkid : %s death_diagnosis: %s external_cause: %s death_date : %s',var_hkid_char,var_diagnosis,var_external_cause,var_death_date;
                    end;
                end if;

	            --goto process_next

                fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                        var_death_date,var_diagnosis,var_external_cause,var_ccc;

            end;
        end if;
        begin
            select  patient_name,
                sex,
                dob,
                exact_dob_flag,
                death_date,
                (rtrim(substring(cccode1,1,4))||
                            rtrim(substring(cccode2,1,4))||
                            rtrim(substring(cccode3,1,4))||
                            rtrim(substring(cccode4,1,4))||
                            rtrim(substring(cccode5,1,4))||
                            rtrim(substring(cccode6,1,4))),
                rtrim(death_indicator),
                death_diagnosis,
                death_external_cause
            into var_pat_name,var_pat_sex,var_pat_dob,var_pat_dob_flag,var_pat_death_date,var_pat_ccc,var_org_death_indicator,var_org_death_diagnosis,var_org_death_external_cause
            from patient
            where hkid = var_hkid_char;
            var_error :=0;
            EXCEPTION WHEN OTHERS THEN
                var_error :=1;
        end;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        if var_error !=0 then
            RAISE notice 'Error in patient selection';
			--goto process_next
            fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                    var_death_date,var_diagnosis,var_external_cause,var_ccc;
                        
        end if;

        IF sql$rowcount = 0 THEN
            /* No me_log found */
            select  
                'patient not found'
            into var_fail_msg;
           --goto insert_error
            begin
                INSERT INTO hkpmi.death_reg_error(system_datetime, record_date, hkid, death_indicator, death_date, death_diagnosis, death_external_cause, err_msg, patient_name, ccc, sex, dob)
                values(timestamp_convert(localtimestamp),var_record_date,var_hkid_char,
                        var_death_indicator,var_death_date,
                        var_diagnosis,var_external_cause,var_fail_msg,var_name,var_ccc,var_sex,var_dob);
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            end;
            if var_error!=0 then
                begin
                    raise notice 'Error in insertion of death_reg_error ';
                    raise notice 'hkid : %s death_diagnosis:%s external_cause: %s 
                        death_date : %s error_msg: %s',var_hkid_char,var_diagnosis,
                        var_external_cause,var_death_date,var_fail_msg ;
                end;
            end if;

            begin
                delete  from death_registry 
                    where current of dreg_cur;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            end;

            if var_error!=0 then 
                begin
                    raise notice ' error in deleting death_registry ';
                    raise notice 'hkid : %s death_diagnosis: %s external_cause: %s death_date : %s',var_hkid_char,var_diagnosis,var_external_cause,var_death_date;
                end;
            end if;

            --goto process_next

            fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                    var_death_date,var_diagnosis,var_external_cause,var_ccc;

        END IF;

        --set arithabort arith_overflow off
        select 
        'Y'
        into var_exact_death_date;
        if var_dob='00-00-0000' then
        begin
            select 
            null
            into var_dob_dt;
        end;
        else
            if right(var_dob,4)::INTEGER >0 and substring(var_dob,1,5)='00-00' then
                select '01-01'||right(var_dob,5)
                into var_dob;
            else
                if right(var_dob,4)::INTEGER>0 and substring(var_dob,1,2)='00' and substring(var_dob,4,2)::INTEGER>0 and substring(var_dob,4,2)::INTEGER<13 then
                    begin
                        select var_dob='01'+substring(var_dob,3,8);
                    end;
                end if;
            end if;
            select
            TO_TIMESTAMP(rtrim(var_dob),'DD/MM/YYYY')
            into var_dob_dt;

            if (var_error!=0 or (var_dob_dt>timestamp_convert(localtimestamp))) and rtrim(var_dob) is not null then
                begin
                    select  
                    'invalid dob'
                    into var_fail_msg; 
                    --goto insert_error
                    INSERT INTO hkpmi.death_reg_error(system_datetime, record_date, hkid, death_indicator, death_date, death_diagnosis, death_external_cause, err_msg, patient_name, ccc, sex, dob)
                    values(timestamp_convert(localtimestamp),var_record_date,var_hkid_char,
                            var_death_indicator,var_death_date,
                            var_diagnosis,var_external_cause,var_fail_msg,var_name,var_ccc,var_sex,var_dob);
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                    if var_error!=0 then
                        begin
                            raise notice 'Error in insertion of death_reg_error ';
                            raise notice 'hkid : %s death_diagnosis:%s external_cause: %s 
                                death_date : %s error_msg: %s',var_hkid_char,var_diagnosis,
                                var_external_cause,var_death_date,var_fail_msg ;
                        end;
                    end if;

                    begin
                        delete  from death_registry 
                            where current of dreg_cur;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    end;

                    if var_error!=0 then 
                        begin
                            raise notice ' error in deleting death_registry ';
                            raise notice 'hkid : %s death_diagnosis: %s external_cause: %s death_date : %s',var_hkid_char,var_diagnosis,var_external_cause,var_death_date;
                        end;
                    end if;

                    --goto process_next       

                    fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                            var_death_date,var_diagnosis,var_external_cause,var_ccc;

                end;
            end if;
        end if;

        if right(var_death_date,4)::INTEGER>0 and substring(var_death_date,1,5)='00-00' then
            begin
                select 
                'N'
                into var_exact_death_date;    
                select 
                --convert(datetime,rtrim('31-12-'+right(var_death_date,4)),103)
                TO_DATE(rtrim('31-12-'||right(var_death_date,4)),'DD-MM-YYYY')
                into var_death_date_dt;
            end;
        elsif right(var_death_date,4)::INTEGER>0 and substring(var_death_date,1,2)='00' and substring(var_death_date,4,2)::INTEGER>0 and substring(var_death_date,4,2)::INTEGER<13 then
            begin
                select 
                'N'
                into var_exact_death_date;
                select 
                --dateadd(dd,-1,dateadd(mm,1,convert(datetime,rtrim('01'+substring(var_death_date,3,8)),103)))
                (TO_DATE('01'||substring(var_death_date FROM 3 FOR 8),'DD-MM-YYYY')+ INTERVAL '1 month')- INTERVAL '1 day'
                into var_death_date_dt;
            end;
        else
            begin
                    select 
                    --convert(datetime,rtrim(var_death_date),103)
                    TO_DATE(TRIM(TRAILING FROM var_death_date),'DD-MM-YYYY')
                    into var_death_date_dt;
            end;
        end if;

        if (var_error!=0 or var_death_date_dt>timestamp_convert(localtimestamp) or var_death_date_dt<var_dob_dt) then
            begin
                    select  
                    null
                    into var_death_date_dt;
                    select  
                    'invalid death date' 
                    into var_fail_msg;
                    --goto insert_error 
                    INSERT INTO hkpmi.death_reg_error(system_datetime, record_date, hkid, death_indicator, death_date, death_diagnosis, death_external_cause, err_msg, patient_name, ccc, sex, dob)
                    values(timestamp_convert(localtimestamp),var_record_date,var_hkid_char,
                            var_death_indicator,var_death_date,
                            var_diagnosis,var_external_cause,var_fail_msg,var_name,var_ccc,var_sex,var_dob);
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                    if var_error!=0 then
                        begin
                            raise notice 'Error in insertion of death_reg_error ';
                            raise notice 'hkid : %s death_diagnosis:%s external_cause: %s 
                                death_date : %s error_msg: %s',var_hkid_char,var_diagnosis,
                                var_external_cause,var_death_date,var_fail_msg ;
                        end;
                    end if;

                    begin
                        delete  from death_registry 
                            where current of dreg_cur;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    end;

                    if var_error!=0 then 
                        begin
                            raise notice ' error in deleting death_registry ';
                            raise notice 'hkid : %s death_diagnosis: %s external_cause: %s death_date : %s',var_hkid_char,var_diagnosis,var_external_cause,var_death_date;
                        end;
                    end if;

                    --goto process_next

                    fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                            var_death_date,var_diagnosis,var_external_cause,var_ccc;

            end;
        end  if;
        
        select  
        upper(var_name)
        into var_name;

        select  
        length(trim(TRAILING FROM var_name))
        into var_char_len;
        select 
        1
        into var_tmp_pos;
        select 
        null
        into var_tmp_name;
        while var_tmp_pos <= var_char_len and var_name is not null LOOP
            begin
                select  
                substring(var_name, var_tmp_pos,1)
                into var_tmp_char;
                if var_tmp_char != ' ' and var_tmp_char != ',' and var_tmp_char != '-' then
                    select  
                    var_tmp_name || var_tmp_char
                    into var_tmp_name;
                end if;
                select 
                var_tmp_pos + 1
                into var_tmp_pos;
            end;
        END LOOP;
        /* For pat_name  */
        select 
        length(trim(TRAILING FROM var_pat_name))
        into var_char_len;
        select 
        1
        into var_tmp_pos;
        select 
        null
        into var_tmp_pat_name;
        while var_tmp_pos <= var_char_len and var_pat_name is not null LOOP
            begin
                select
                substring(var_pat_name, var_tmp_pos,1)
                into var_tmp_char;
                if var_tmp_char != ' ' and var_tmp_char != ',' and var_tmp_char != '-' then
                    select 
                    var_tmp_pat_name || var_tmp_char
                    into var_tmp_pat_name;
                end if;
                select 
                var_tmp_pos + 1
                into var_tmp_pos;
            end;
        END LOOP;

        select 
        upper(var_sex)
        into  var_sex;
        select 
        trim(TRAILING FROM var_diagnosis)
        into var_diagnosis;
        select 
        trim(TRAILING FROM var_external_cause)
        into var_external_cause;

        /* checking the major seperate for set death or death cause */
        if var_org_death_indicator is not null then
            begin
                /* check for death cause only*/
                if (trim(TRAILING FROM var_tmp_pat_name)!=trim(TRAILING FROM var_tmp_name) or
                    (var_pat_sex!=var_sex and var_pat_sex!='U') or
                    (var_pat_dob is not null and
                    (var_pat_dob > var_dob_dt+INTERVAL '2 years' or
                    var_pat_dob < var_dob_dt-INTERVAL '2 years') or
                    (var_pat_dob is not null and var_dob_dt is null))or
                    (var_pat_ccc!=trim(TRAILING FROM var_ccc) and trim(TRAILING FROM var_pat_ccc) is not null)) then
                    begin
                        select  
                        'Major key unmatched'
                        into var_fail_msg;
                            --goto insert_error
                        INSERT INTO hkpmi.death_reg_error(system_datetime, record_date, hkid, death_indicator, death_date, death_diagnosis, death_external_cause, err_msg, patient_name, ccc, sex, dob)
                        values(timestamp_convert(localtimestamp),var_record_date,var_hkid_char,
                                var_death_indicator,var_death_date,
                                var_diagnosis,var_external_cause,var_fail_msg,var_name,var_ccc,var_sex,var_dob);
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                        if var_error!=0 then
                            begin
                                raise notice 'Error in insertion of death_reg_error ';
                                raise notice 'hkid : %s death_diagnosis:%s external_cause: %s 
                                    death_date : %s error_msg: %s',var_hkid_char,var_diagnosis,
                                    var_external_cause,var_death_date,var_fail_msg ;
                            end;
                        end if;

                        begin
                            delete  from death_registry 
                                where current of dreg_cur;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        end;

                        if var_error!=0 then 
                            begin
                                raise notice ' error in deleting death_registry ';
                                raise notice 'hkid : %s death_diagnosis: %s external_cause: %s death_date : %s',var_hkid_char,var_diagnosis,var_external_cause,var_death_date;
                            end;
                        end if;

                        --goto process_next
                
                        fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                                var_death_date,var_diagnosis,var_external_cause,var_ccc;

                    end;
                end if;
            end;
        else
            begin
                /* check for setting death */
                if (trim(TRAILING FROM var_tmp_pat_name)!=trim(TRAILING FROM var_tmp_name) or 
                            (var_pat_sex!=var_sex and var_pat_sex !='U') or 
                            (var_pat_dob is not null and
                                var_pat_dob!=var_dob_dt and
                                not (substring(to_char(var_pat_dob,'YYYYMMDD')FROM 5 FOR 4) = '0101' 
                                and upper(var_pat_dob_flag) = 'N'))or 
                        (var_pat_ccc!=trim(TRAILING FROM var_ccc) and trim(TRAILING FROM var_pat_ccc) is not null)) then
                    begin
                        select 
                        'Major key unmatched'
                        into var_fail_msg;
                        --goto insert_error
                        INSERT INTO hkpmi.death_reg_error(system_datetime, record_date, hkid, death_indicator, death_date, death_diagnosis, death_external_cause, err_msg, patient_name, ccc, sex, dob)
                        values(timestamp_convert(localtimestamp),var_record_date,var_hkid_char,
                                var_death_indicator,var_death_date,
                                var_diagnosis,var_external_cause,var_fail_msg,var_name,var_ccc,var_sex,var_dob);
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                        if var_error!=0 then
                            begin
                                raise notice 'Error in insertion of death_reg_error ';
                                raise notice 'hkid : %s death_diagnosis:%s external_cause: %s 
                                    death_date : %s error_msg: %s',var_hkid_char,var_diagnosis,
                                    var_external_cause,var_death_date,var_fail_msg ;
                            end;
                        end if;

                        begin
                            delete  from death_registry 
                                where current of dreg_cur;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        end;

                        if var_error!=0 then 
                            begin
                                raise notice ' error in deleting death_registry ';
                                raise notice 'hkid : %s death_diagnosis: %s external_cause: %s death_date : %s',var_hkid_char,var_diagnosis,var_external_cause,var_death_date;
                            end;
                        end if;

                        --goto process_next

                        fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                            var_death_date,var_diagnosis,var_external_cause,var_ccc;

                    end;
                end if;
            end;
        end if;

        --set arithabort arith_overflow on

        if var_diagnosis is null and var_external_cause is not null then
        begin
            select 
            'Diagnosis cannot be null while external cause is not'
            into var_fail_msg;
            --goto insert_error
            INSERT INTO hkpmi.death_reg_error(system_datetime, record_date, hkid, death_indicator, death_date, death_diagnosis, death_external_cause, err_msg, patient_name, ccc, sex, dob)
            values(timestamp_convert(localtimestamp),var_record_date,var_hkid_char,
                    var_death_indicator,var_death_date,
                    var_diagnosis,var_external_cause,var_fail_msg,var_name,var_ccc,var_sex,var_dob);
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
            if var_error!=0 then
                begin
                    raise notice 'Error in insertion of death_reg_error ';
                    raise notice 'hkid : %s death_diagnosis:%s external_cause: %s 
                        death_date : %s error_msg: %s',var_hkid_char,var_diagnosis,
                        var_external_cause,var_death_date,var_fail_msg ;
                end;
            end if;

            begin
                delete  from death_registry 
                    where current of dreg_cur;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            end;

            if var_error!=0 then 
                begin
                    raise notice ' error in deleting death_registry ';
                    raise notice 'hkid : %s death_diagnosis: %s external_cause: %s death_date : %s',var_hkid_char,var_diagnosis,var_external_cause,var_death_date;
                end;
            end if;

            --goto process_next
            fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                var_death_date,var_diagnosis,var_external_cause,var_ccc;

        end;
        end if;
        

        /* reject update for active patient */
        if exists (select * from pmi_case c, patient p
                    where p.patient_key=c.patient_key
                    and p.hkid = var_hkid_char
                    and discharge_code is NULL
                    and (case_no like ' HN%' or case_no like ' AE%')) then 
            select  
            'Y'
            into var_active_status;
        else
            select 
            'N'
            into var_active_status;
        end if;

        if var_active_status = 'Y' then
            begin
                select 
                'Cannot Update Active Patient'
                into var_fail_msg;
                --goto insert_error
                INSERT INTO hkpmi.death_reg_error(system_datetime, record_date, hkid, death_indicator, death_date, death_diagnosis, death_external_cause, err_msg, patient_name, ccc, sex, dob)
                values(timestamp_convert(localtimestamp),var_record_date,var_hkid_char,
                        var_death_indicator,var_death_date,
                        var_diagnosis,var_external_cause,var_fail_msg,var_name,var_ccc,var_sex,var_dob);
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                if var_error!=0 then
                    begin
                        raise notice 'Error in insertion of death_reg_error ';
                        raise notice 'hkid : %s death_diagnosis:%s external_cause: %s 
                            death_date : %s error_msg: %s',var_hkid_char,var_diagnosis,
                            var_external_cause,var_death_date,var_fail_msg ;
                    end;
                end if;

                begin
                    delete  from death_registry 
                        where current of dreg_cur;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                end;

                if var_error!=0 then 
                    begin
                        raise notice ' error in deleting death_registry ';
                        raise notice 'hkid : %s death_diagnosis: %s external_cause: %s death_date : %s',var_hkid_char,var_diagnosis,var_external_cause,var_death_date;
                    end;
                end if;

	            --goto process_next

                fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                        var_death_date,var_diagnosis,var_external_cause,var_ccc;

            end;
        end if;
        /* reject update for patient with death date < last adm dtm */
		select  max(adm_dtm)
        into var_last_adm_dtm
		from patient p, pmi_case c
		where p.patient_key = c.patient_key
		and hkid = var_hkid_char and substring(case_no, 1, 3)!='MSS'
        and substring(case_no, 1, 2)!='CP';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        if (sql$rowcount = 1) and (var_last_adm_dtm is not null) then
            if (var_last_adm_dtm >= var_death_date_dt+INTERVAL '1 day') and
                (var_death_date_dt is not null) then
                begin
                    select 'Last admission Date ' + 
                                            to_char(var_last_adm_dtm,'DD/MM/YYYY') ||
                                            ' > Death Date ' || 
                                            to_char(var_death_date_dt,'DD/MM/YYYY')
                    into var_fail_msg;
                    --goto insert_error
                    INSERT INTO hkpmi.death_reg_error(system_datetime, record_date, hkid, death_indicator, death_date, death_diagnosis, death_external_cause, err_msg, patient_name, ccc, sex, dob)
                    values(timestamp_convert(localtimestamp),var_record_date,var_hkid_char,
                            var_death_indicator,var_death_date,
                            var_diagnosis,var_external_cause,var_fail_msg,var_name,var_ccc,var_sex,var_dob);
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                    if var_error!=0 then
                        begin
                            raise notice 'Error in insertion of death_reg_error ';
                            raise notice 'hkid : %s death_diagnosis:%s external_cause: %s 
                                death_date : %s error_msg: %s',var_hkid_char,var_diagnosis,
                                var_external_cause,var_death_date,var_fail_msg ;
                        end;
                    end if;

                    begin
                        delete  from death_registry 
                            where current of dreg_cur;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    end;

                    if var_error!=0 then 
                        begin
                            raise notice ' error in deleting death_registry ';
                            raise notice 'hkid : %s death_diagnosis: %s external_cause: %s death_date : %s',var_hkid_char,var_diagnosis,var_external_cause,var_death_date;
                        end;
                    end if;

                    --goto process_next 

                    fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                        var_death_date,var_diagnosis,var_external_cause,var_ccc;

                end;
            end if;
        end if;

        if ((trim(TRAILING FROM var_org_death_diagnosis) is not null) or
          (trim(TRAILING FROM var_org_death_external_cause) is not null)) then
            begin
                select  'Death Diagnosis already Exists!'
                into var_fail_msg;
                --goto insert_error
                INSERT INTO hkpmi.death_reg_error(system_datetime, record_date, hkid, death_indicator, death_date, death_diagnosis, death_external_cause, err_msg, patient_name, ccc, sex, dob)
                values(timestamp_convert(localtimestamp),var_record_date,var_hkid_char,
                        var_death_indicator,var_death_date,
                        var_diagnosis,var_external_cause,var_fail_msg,var_name,var_ccc,var_sex,var_dob);
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                if var_error!=0 then
                    begin
                        raise notice 'Error in insertion of death_reg_error ';
                        raise notice 'hkid : %s death_diagnosis:%s external_cause: %s 
                            death_date : %s error_msg: %s',var_hkid_char,var_diagnosis,
                            var_external_cause,var_death_date,var_fail_msg ;
                    end;
                end if;

                begin
                    delete  from death_registry 
                        where current of dreg_cur;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                end;

                if var_error!=0 then 
                    begin
                        raise notice ' error in deleting death_registry ';
                        raise notice 'hkid : %s death_diagnosis: %s external_cause: %s death_date : %s',var_hkid_char,var_diagnosis,var_external_cause,var_death_date;
                    end;
                end if;

	            --goto process_next   

                fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                        var_death_date,var_diagnosis,var_external_cause,var_ccc;

            end;
        end if;

        if (var_org_death_indicator is not null) and 
            (to_char(var_death_date_dt,'DD/MM/YYYY') <> to_char(var_pat_death_date,'DD/MM/YYYY')) then
            begin
                select  'Death Date Different from Record'
                into var_fail_msg;
                --goto insert_error
                INSERT INTO hkpmi.death_reg_error(system_datetime, record_date, hkid, death_indicator, death_date, death_diagnosis, death_external_cause, err_msg, patient_name, ccc, sex, dob)
                values(timestamp_convert(localtimestamp),var_record_date,var_hkid_char,
                        var_death_indicator,var_death_date,
                        var_diagnosis,var_external_cause,var_fail_msg,var_name,var_ccc,var_sex,var_dob);
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                if var_error!=0 then
                    begin
                        raise notice 'Error in insertion of death_reg_error ';
                        raise notice 'hkid : %s death_diagnosis:%s external_cause: %s 
                            death_date : %s error_msg: %s',var_hkid_char,var_diagnosis,
                            var_external_cause,var_death_date,var_fail_msg ;
                    end;
                end if;

                begin
                    delete  from death_registry 
                        where current of dreg_cur;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                end;

                if var_error!=0 then 
                    begin
                        raise notice ' error in deleting death_registry ';
                        raise notice 'hkid : %s death_diagnosis: %s external_cause: %s death_date : %s',var_hkid_char,var_diagnosis,var_external_cause,var_death_date;
                    end;
                end if;

	            --goto process_next
                fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                        var_death_date,var_diagnosis,var_external_cause,var_ccc;

            end;
        end if;

        select system_dtm
        into var_upd_dtm 
        from patient 
        where hkid = var_hkid_char;

        if var_upd_dtm >= var_sys_date then
            begin 
                select 'Patient Last update datetime > this tx'
                into var_fail_msg;
                --goto insert_error
                INSERT INTO hkpmi.death_reg_error(system_datetime, record_date, hkid, death_indicator, death_date, death_diagnosis, death_external_cause, err_msg, patient_name, ccc, sex, dob)
                values(timestamp_convert(localtimestamp),var_record_date,var_hkid_char,
                        var_death_indicator,var_death_date,
                        var_diagnosis,var_external_cause,var_fail_msg,var_name,var_ccc,var_sex,var_dob);
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                if var_error!=0 then
                    begin
                        raise notice 'Error in insertion of death_reg_error ';
                        raise notice 'hkid : %s death_diagnosis:%s external_cause: %s 
                            death_date : %s error_msg: %s',var_hkid_char,var_diagnosis,
                            var_external_cause,var_death_date,var_fail_msg ;
                    end;
                end if;

                begin
                    delete  from death_registry 
                        where current of dreg_cur;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                end;

                if var_error!=0 then 
                    begin
                        raise notice ' error in deleting death_registry ';
                        raise notice 'hkid : %s death_diagnosis: %s external_cause: %s death_date : %s',var_hkid_char,var_diagnosis,var_external_cause,var_death_date;
                    end;
                end if;

	            --goto process_next
                fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                        var_death_date,var_diagnosis,var_external_cause,var_ccc;

            end;
        end if;

        select  timestamp_convert(localtimestamp)
        into var_sys_date;
        
        --begin tran

        /** When Patient Dead Already with Same Death date **/
        if (var_org_death_indicator is not null) then
            begin
                update patient
                set death_diagnosis = var_diagnosis,
                    death_external_cause = var_external_cause,
                    system_dtm = var_sys_date,
                    source_system_dtm = var_sys_date,
                    source_system = var_source_system,
                    update_hospital = var_hosp_code,
                    update_by = var_update_by
                where hkid = var_hkid_char;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                if var_error != 0 then
                    --goto abnormal_err

                    rollback;
                    raise notice 'Error : Error in update! %',var_hkid;
                    --goto process_next
                    fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                            var_death_date,var_diagnosis,var_external_cause,var_ccc;

                    --select var_death_date_dt = var_pat_death_date
                    select  var_org_death_indicator
                    into var_death_indicator;
                end if;
            end;
        else
            begin
                select  'DR'
                into var_death_indicator;
                --if var_death_date_dt = null
                --select var_death_date_dt = var_pat_death_date      
                update patient
                set death_indicator = var_death_indicator,
                    death_date = var_death_date_dt,
                    death_diagnosis = var_diagnosis,
                    death_external_cause = var_external_cause,
                    source_system_dtm = var_sys_date,
                    source_system = var_source_system,
                    update_hospital = var_hosp_code,
                    system_dtm = var_sys_date,
                    update_by = var_update_by
                where hkid = var_hkid_char;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                if var_var_error!=0 then
                    --goto abnormal_err

                    rollback;
                    raise notice 'Error : Error in update! %',var_hkid;
                    --goto process_next

                    fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                        var_death_date,var_diagnosis,var_external_cause,var_ccc;

                end if;
            end;
        end if;
        -- execute var_retx_code = hkpmi_patient_death_tx
        --                    var_hosp_code,'033',var_hkid_char,'N',var_exact_death_date
        call hkpmi_patient_death_tx(var_retx_code,var_hosp_code,'033',var_hkid_char,'N',var_exact_death_date);
        if var_retx_code!=0 then
            --goto abnormal_err

            rollback;
            raise notice 'Error : Error in update! %',var_hkid;
            --goto process_next
            fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                    var_death_date,var_diagnosis,var_external_cause,var_ccc;

        end if;

        if exists (select * from hkpmi_uid_table
		  where link_hkid=var_hkid_char and link_status in ('L','PS')) then
            begin
                update hkpmi_uid_table
                set link_status='RD',
                update_dtm=var_sys_date,
                update_hospital=var_hosp_code,
                update_user=var_update_by,
                update_system=var_source_system
                where link_hkid=var_hkid_char and link_status in ('L','PS');
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                if var_error!=0 then
                    --goto abnormal_err

                    rollback;
                    raise notice 'Error : Error in update! %',var_hkid;
                    --goto process_next
                    
                    fetch dreg_cur into var_record_date, var_hkid, var_name,var_sex,var_dob,
                        var_death_date,var_diagnosis,var_external_cause,var_ccc;
                end if;
            end;
        end if;
        select  'Y'
        into var_commit_flag;
        --goto normal_end
        if var_commit_flag = 'Y' then 
            begin
                commit;
                --print 'commit'
                insert into death_reg_log
                values(var_sys_date,var_record_date,var_hkid_char,var_death_indicator,
                    to_char(var_death_date_dt,'DD-MM-YYYY'),var_diagnosis,
                    var_external_cause,var_name,var_ccc,var_sex,var_dob);
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                    var_error := 1;
                if var_error!=0 then
                    begin
                    raise notice ' error in insert death_reg_log ';
                    raise notice 'hkid : %s death_diagnosis: %s external_cause: %s 
                            death_date : %s',var_hkid_char,var_diagnosis,
                            var_external_cause,var_death_date;
                    end;
                end if;
                
                begin
                    delete  from death_registry 
                        where current of dreg_cur;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                end;

                if var_var_error!=0 then 
                    begin
                    raise notice ' error in deleting death_registry ';
                    raise notice 'hkid : %s death_diagnosis: %s external_cause: %s
                            death_date : %s',var_hkid_char,var_diagnosis,
                            var_external_cause,var_death_date;
                    end;
                end if;
            end;
        end if;
        --waitfor delay '00:00:00:500' ---- wait 500 msec  
        --waitfor delay '00:00:05' ---- wait 5 sec : 60x60/5 = 720 DR records per Hour   ---20140811
        select pg_sleep(5);
    end loop;
    close dreg_cur;
--    DEALLOCATE dreg_cur;
END;
/* * select records from death registry * */
/* --select hkid_tmp */
/* --print 'hkid:%1! name:%2! sex:%3! dob: %4! ccc:%5! death_date:%6!', */
/* --hkid,name,sex,dob,ccc,death_date */
/* --print 'death_diagnosis:%1! death_external_cause:%2!',diagnosis,external_cause */
/* * Validate input hkid,dob, death date * */
/* * Get patient details from patient table * */
/* reformat name for checking */
/* by taking out space,',', '-' from name */
/* For name */
/* For pat_name */
/* checking the major seperate for set death or death cause */
/* reject update for active patient */
/* reject update for patient with death date < last adm dtm */
/* --print 'begin tran' */
/* * When Patient Dead Already with Same Death date * */
/* --select death_date_dt = pat_death_date */
/* --if death_date_dt = null */
/* --select death_date_dt = pat_death_date */
/* reject update for settled linkage */
/* --print 'hkid : %1!', hkid */
/* --print 'commit' */
/* --waitfor delay '00:00:00:500' ---- wait 500 msec */
/* ---- wait 5 sec : 60x60/5 = 720 DR records per Hour   ---20140811 */
$function$
;

ALTER FUNCTION "hkpmi_monthly_death_reg" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
