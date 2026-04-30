-- DROP PROCEDURE hpi.hasp_insert_lof_log(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in varchar, in varchar, in varchar, in varchar, in timestamp, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_insert_lof_log(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_action_type character varying, IN par_hkid character varying, IN par_patient_name character varying, IN par_cccode1 character varying, IN par_cccode2 character varying, IN par_cccode3 character varying, IN par_cccode4 character varying, IN par_cccode5 character varying, IN par_cccode6 character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_death_datetime timestamp without time zone, IN par_exact_dob_flag character varying, IN par_last_case_no character varying, IN par_last_hospital_code character varying, IN par_last_ward_code character varying, IN par_body_category character varying, IN par_mortuary_id integer, IN par_user_id character varying, IN par_user_hospital character varying, IN par_workstation_id character varying, IN par_source_system character varying, IN par_issue_datetime timestamp without time zone, INOUT par_return_code integer, INOUT par_error_message character varying)
 LANGUAGE plpgsql
AS $procedure$

DECLARE
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_parent_hospital VARCHAR(6);
    var_rtn_code int;
    var_rtn_msg VARCHAR(160);
    var_ret int;
    var_today TIMESTAMP WITHOUT TIME ZONE;

	/*
	if not exists(select * from hospital
		where hospital_code = @hospital_code)
	begin
		select @return_code = 210002	---new error_msg..error_code
		select @rtn_msg ="Incorrect hospital code"
		goto return_error
	end
	*/
begin
    <<return_error>>
    begin
        select timestamp_convert(localtimestamp) INTO var_today;
        if ltrim(rtrim(par_body_category))= '' or ltrim(rtrim(par_body_category)) is null THEN
            select null into par_body_category;
        END IF;
        if ltrim(rtrim(par_death_datetime))='' or ltrim(rtrim(par_death_datetime)) is null then
            select null into par_death_datetime;
        END IF;
        if ltrim(rtrim(par_exact_dob_flag)) ='' or ltrim(rtrim(par_exact_dob_flag)) is null then
            select null into par_exact_dob_flag;
        end if;
        if ltrim(rtrim(par_hospital_code)) ='' or ltrim(rtrim(par_hospital_code))  is  null then
            select null into par_hospital_code;
        end if;
        if ltrim(rtrim(par_user_hospital))='' or ltrim(rtrim(par_user_hospital))  is  null then
            select null into par_user_hospital;
        end if;
        if ltrim(rtrim(par_patient_name)) ='' or ltrim(rtrim(par_patient_name))  is  null then
            select null into par_patient_name;
        end if;
        if ltrim(rtrim(par_hkid)) =''       or ltrim(rtrim(par_hkid))  is  null then
            select null into par_hkid;
        end if;
        if ltrim(rtrim(par_user_id))=''     or ltrim(rtrim(par_user_id))  is  null then
            select null into par_user_id;
        end if;
        if ltrim(rtrim(par_workstation_id))='' or ltrim(rtrim(par_workstation_id)) is  null then
            select null into par_workstation_id;
        end if;
        if ltrim(rtrim(par_last_ward_code))='' or ltrim(rtrim(par_last_ward_code)) is null then
            select null into par_last_ward_code;
        end if;
        if ltrim(rtrim(par_last_case_no))=''  or ltrim(rtrim(par_last_case_no)) is null then
            select null into par_last_case_no;
        end if;
            ----- 1). Validation ----------
        if par_source_system not in ('LRRDT') then
            begin
                select 210003 into var_rtn_code;	---new error_msg..error_code
                select "Invalid source system" into var_rtn_msg ;
                raise exception '';
            end;
        end if;

        if (par_action_type not in ('A','C','U'))
            OR (par_action_type in ('A','U') and (par_body_category is null or par_death_datetime is null))
            OR (par_action_type ='C' and (par_body_category is not null or par_death_datetime is not null)) then
            begin
                select 210003 into var_rtn_code; 	---new error_msg..error_code
                select "Invalid Action Type" into var_rtn_msg;
                raise exception '';
            end;
        end if;
            ---- for non-nullable fields of table ---
        if (par_hospital_code is null) OR (par_issue_datetime is null)
            OR (par_hkid is null) OR (par_patient_name is null) OR (par_sex not in ('U','M','F'))
            OR (par_exact_dob_flag is null)
            OR (par_user_id is null) OR (par_workstation_id is null) OR (par_user_hospital is null) then
            begin
                select 210003 into var_rtn_code;	---new error_msg..error_code
                select "Invalid Parm " into var_rtn_msg;
                raise exception '';
            end;
        end if;

        ---  Enable after 2008 -June
        if (par_action_type in ('A','U'))
            AND (par_last_ward_code  is null or par_last_case_no is null ) then
            begin
                select 210003 into var_rtn_code;	---new error_msg..error_code
                select "Ward code and Case no cannot be null " into var_rtn_msg; 
                raise exception '';
            end;
        end if;

        if par_dob is not null then
            begin
            if coalesce(par_death_datetime, par_dob) < par_dob then
                begin
                    select 210003 into var_rtn_code;	---new error_msg..error_code
                    select "Invalid Death Date/Time" into var_rtn_msg; 
                    raise exception '';
                end;
            end if;
            end;
        end if;

        if coalesce(par_death_datetime, var_today) > var_today then
            begin
                select 210003 into var_rtn_code; 	---new error_msg..error_code
                select "Invalid Death Date/Time" into var_rtn_msg; 
                raise exception '';
            end;
        end if;

        if exists (select * From last_office_form_log
                        where hkid =par_hkid and issue_datetime = par_issue_datetime and action_type = par_action_type) then
            begin
                select 210003 into var_rtn_code;	---new error_msg..error_code
                select "Record already exist !" into var_rtn_msg;
                raise exception '';
            end;
        end if;
        ----- 2). Insert Log ----------
        select timestamp_convert(localtimestamp) var_update_datetime;	---get current system datetime
        select Hospital_code into var_parent_hospital from Hospital;  ---local dbíªs hospital code
        select ltrim(rtrim(var_parent_hospital)) into var_parent_hospital;
        ---updat_hospital = @user_hospital---

    /*	----20080530 handle for null ward code temp.----
        if @last_ward_code is null
            or ltrim(rtrim(@last_ward_code))=''
        begin
            ---if @last_case_no is not null
            ---begin
                select @last_ward_code = Ward_code
                    from Movement
                    -----HPI ----
                    where 	Hospital_code =@hospital_code
                        and Case_no =@last_case_no
                        group by Hospital_code,Case_no
                        having Movement_count=max(Movement_count)
            ---end
            ---else
            ---	select @last_ward_code =''
        end
    */


        insert into last_office_form_log (hospital_code,/*mortuary_id,*/issue_datetime,action_type,
                hkid,patient_name,cccode1,cccode2,cccode3,cccode4,cccode5,cccode6,
                sex,dob,death_datetime,exact_dob_flag,
                last_case_no,last_hospital_code,last_ward_code,body_category,
                source_system,	update_by,update_hospital,workstation_id,update_datetime,parent_hospital)
            values (par_hospital_code,/*@mortuary_id,*/par_issue_datetime,par_action_type,
                par_hkid,par_patient_name,par_cccode1,par_cccode2,par_cccode3,par_cccode4,par_cccode5,par_cccode6,
                par_sex,par_dob,par_death_datetime,par_exact_dob_flag,
                par_last_case_no,par_last_hospital_code,par_last_ward_code,par_body_category,
                par_source_system,par_user_id,par_user_hospital,par_workstation_id,var_update_datetime,var_parent_hospital);

        if @@error <> 0 or @@rowcount = 0 then
            begin
                select 210004 into var_rtn_code;	---new error_msg..error_code
                select "Insert lof log failed !" into var_rtn_msg;
                raise exception '';
            end;
        end if;

        ----- 3). Update Death Info. ----------
        ---hasp_update_death_dtm Called after insert last_offce_form_log
        ---Because cpi_update_death_dtm will COMMMIT the tran  && cann't roll-back cpi Txn. if insert		 last_office_form_log failed --

        call hasp_update_death_dtm(var_ret, par_hospital_code,par_hkid,par_death_datetime,par_body_category,
            par_user_id,par_user_hospital,par_source_system,par_workstation_id,
        var_rtn_code, var_rtn_msg);

        if var_ret <> 0 then
            begin
                select 210003 into var_rtn_code;	---new error_msg..error_code
                select "Call hasp_update_death_dtm Failed " into var_rtn_msg;
                raise exception '';
            end;
        end if;

    ----- 4). Exit SP : 0 / -1 ONLY ------------
        select 0 into pas_return_code;
        select null into par_error_message;
        return;

        exception when others then
            begin
                --rollback;
                raise exception '';
                select -1 into pas_return_code;
                select var_rtn_msg into par_error_message;
                return;
            end;
    end;
end;
$procedure$
;
