-- DROP PROCEDURE hpi.pass_cpi_pat_upd(in bpchar, in bpchar, in bpchar, in bpchar, in timestamp, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in varchar, in bpchar, in varchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in timestamp, in bpchar, in int4, in bpchar, in int4, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in varchar, in timestamp, in varchar, in bpchar, in int4, in int4, in timestamp, in bpchar, in bpchar, in timestamp, in bpchar, in bpchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.pass_cpi_pat_upd(IN par_hospital_code character, IN par_hkid character, IN par_patient_name character, IN par_sex character, IN par_dob timestamp without time zone, IN par_exact_dob_flag character, IN par_ccc_1 character, IN par_ccc_2 character, IN par_ccc_3 character, IN par_ccc_4 character, IN par_ccc_5 character, IN par_ccc_6 character, IN par_chi_name character, IN par_input_marital_status character, IN par_race_code character, IN par_other_document_no character, IN par_reference character varying, IN par_medical_record_number character, IN par_remark character varying, IN par_input_building character, IN par_input_room character, IN par_input_floor character, IN par_input_block character, IN par_input_district_code character, IN par_input_religion_code character, IN par_input_home_phone_no character, IN par_input_other_phone_no_1 character, IN par_input_other_phone_ext_1 character, IN par_other_phone_no_2 character, IN par_other_phone_ext_2 character, IN par_death_indicator character, IN par_death_date timestamp without time zone, IN par_death_code character, IN par_card_holder integer, IN par_patient_key character, IN par_priority integer, IN par_input_nok_name character, IN par_input_nok_hkid character, IN par_input_nok_relation_code character, IN par_input_nok_building character, IN par_input_nok_room character, IN par_input_nok_floor character, IN par_input_nok_block character, IN par_input_nok_district_code character, IN par_input_nok_home_phone character, IN par_input_nok_other_phone_no_1 character, IN par_input_nok_other_phone_ext_1 character, IN par_input_nok_other_phone_no_2 character, IN par_input_nok_other_phone_ext_2 character, IN par_input_mobile_no character, IN par_input_sms_language character varying, IN par_hago_update_datetime timestamp without time zone, IN par_mobile_status character varying, IN par_txn_type character, IN par_access_code integer, IN par_security integer, IN par_transaction_datetime timestamp without time zone, IN par_update_hospital character, IN par_update_by character, IN par_input_last_update_datetime timestamp without time zone, IN par_source_system character, IN par_force_update character, INOUT par_return_code integer, INOUT par_return_message character varying)
 LANGUAGE plpgsql
AS $procedure$ 
declare
	v_patient_key varchar(16);
	v_marital_status char(1);
	v_building char(47);
	v_room char(5);
	v_floor char(2);
	v_block char(2);
	v_district_code char(5);
	v_religion_code char(3);
	v_home_phone_no char(10);
	v_other_phone_no_1 char(10);
	v_other_phone_ext_1 char(4);
	v_nok_name char(48);
	v_nok_hkid char(12);
	v_nok_relation_code char(2);
	v_nok_building char(47);
	v_nok_room char(5);
	v_nok_floor char(2);
	v_nok_block char(2);
	v_nok_district_code char(5);
	v_nok_home_phone char(10);
	v_nok_other_phone_no_1 char(10);
	v_nok_other_phone_ext_1 char(4);
	v_nok_other_phone_no_2 char(10);
	v_nok_other_phone_ext_2 char(4);
	v_update_datetime timestamp(3);
	v_mobile_no char(10);
	v_sms_language varchar(8);
	v_last_update_datetime timestamp(3);
	v_addr_code int;
	v_doc_code char(1);
	/*---- added by WL for insert event log --*/
	 v_insert_event_log_prg char(35);
	 v_insert_event_log_dtm timestamp(3);
	 v_insert_event_log_type char(3);
	 v_get_event_log_dtm_code int;
	 v_insert_event_log_ret_code int;
	 v_event_log_mrn 
	char(8);
	 v_get_event_log_dtm_prg char(35);
	begin
		par_mobile_status := 'ACTIVE';
		par_return_code := 0;
		par_return_message := '';
		v_patient_key := par_patient_key;
		select patient_name ,
			sex,
			dob,
			exact_dob_flag,
			cccode1,
			cccode2,
			cccode3,
			cccode4,
			cccode5,
			cccode6,
			chi_name,
			marital_status ,
			race ,
			other_doc_no,
			reference,
			building,
			room,
			floor,
			block,
			district,
			religion,
			phone1,
			phone2,
			address_indicator,
			mobile_phone,
			sms_language,
			death_indicator,
			death_date,
			death_code,
			card_holder,
			patient_key,
			access_code,
			security,
			update_dtm 
		 into par_patient_name,par_sex,par_dob,par_exact_dob_flag,par_ccc_1,par_ccc_2,par_ccc_3,par_ccc_4,par_ccc_5,par_ccc_6,
			par_chi_name,v_marital_status,par_race_code,par_other_document_no,par_reference,v_building,v_room,v_floor,v_block,v_district_code,v_religion_code,
			v_home_phone_no,v_other_phone_no_1,v_other_phone_ext_1,par_other_phone_no_2,par_other_phone_ext_2,par_death_indicator,par_death_date,par_death_code,
			par_card_holder,v_patient_key,par_access_code,par_security,v_last_update_datetime 
		from cpi_patient
		where hkid = par_hkid;
		
		if v_patient_key is null
		then
		 par_return_code := -1;
		 par_return_message := 'patient not found';
		 return;
		end if;
		select mrn, remark 
			into par_medical_record_number, par_remark
		from cpi_patient_hospital_data
		where patient_key = v_patient_key
		and hospital_code = par_hospital_code;
		--check user input and update
		if par_input_home_phone_no = '' then
		 v_home_phone_no := null;
		elsif par_input_home_phone_no is not null then
		 v_home_phone_no := par_input_home_phone_no;
		end if;
		if par_input_other_phone_no_1 = '' then
		 v_other_phone_no_1 := null;
		elsif par_input_other_phone_no_1 is not null then
		 v_other_phone_no_1 := par_input_other_phone_no_1;
		end if;
		if par_input_other_phone_ext_1 = '' then
		 v_other_phone_ext_1 := null;
		elsif par_input_other_phone_ext_1 is not null then
		 v_other_phone_ext_1 := par_input_other_phone_ext_1;
		end if;
		--address update
		-- 1. clear address
		if par_input_building = '' AND par_input_room = '' AND
		par_input_floor = '' AND par_input_block = '' AND 
		par_input_district_code = '' then
			v_building := 'UNKNOWN';
			v_district_code := 'UNK';
		-- 2. structured address setting
		elsif par_input_building is not null and substring(par_input_building, 1, 7) = 'HACODE:' then
			v_building := par_input_building;
			v_addr_code := cast(right(rtrim(par_input_building), char_length(rtrim(par_input_building)) - 7) as int);
			v_district_code := null;
			select district_code into v_district_code
			from address_detail
			where record_id = v_addr_code;
			if v_district_code is null
			then
				par_return_code := -1;
				par_return_message := 'invalid address record id';
				return;
			end if;
		-- 3. free text address setting
		else
			if par_input_building = '' then
				v_building := null;
			elsif par_input_building is not null then
				v_building := par_input_building;
			end if;
			if par_input_district_code = '' then
				v_district_code := 'UNK';
			elsif par_input_district_code is not null then
			if par_input_district_code in (select district_code from district) then
				v_district_code := par_input_district_code;
			else
				par_return_code := -1;
				par_return_message := 'invalid district';
				return;
			end if;
		end if;
	end if;
	if par_input_room = '' then
		v_room := null;
	elsif par_input_room is not null then
		v_room := par_input_room;
	end if;
	if par_input_floor = '' then
		v_floor := null;
	elsif par_input_floor is not null then
		v_floor := par_input_floor;
	end if;
	if par_input_block = '' then
		v_block := null;
	elsif par_input_block is not null then
		v_block := par_input_block;
	end if;
	--nok update
	select	relationship,
			nok_name,
			hkid,
			building,
			room,
			floor,
			block,
			district,
			phone1,
			phone2,
			address_indicator,
			mobile_phone,
			sms_language 
			into v_nok_relation_code,v_nok_name,v_nok_hkid,v_nok_building,v_nok_room,v_nok_floor,v_nok_block,v_nok_district_code,v_nok_home_phone,
				v_nok_other_phone_no_1, v_nok_other_phone_ext_1, v_nok_other_phone_no_2, v_nok_other_phone_ext_2
	from cpi_nok
	where patient_key = v_patient_key
	and major_nok = 'Y';
	
	if par_input_nok_name = '' then
		v_nok_relation_code := null;
		v_nok_name := null;
		v_nok_hkid := null;
		v_nok_building := null;
		v_nok_room := null;
		v_nok_floor := null;
		v_nok_block := null;
		v_nok_district_code := null;
		v_nok_home_phone := null;
		v_nok_other_phone_no_1 := null;
		v_nok_other_phone_ext_1 := null;
		v_nok_other_phone_no_2 := null;
		v_nok_other_phone_ext_2 := null;
	else
		if par_input_nok_name is not null then
			v_nok_name := par_input_nok_name;
		end if;
		if par_input_nok_relation_code is not null
		then
			if par_input_nok_relation_code in (select nok_relation_code from nok_relation) then
				v_nok_relation_code := par_input_nok_relation_code;
			else
				par_return_code := -1;
				par_return_message := 'invalid contactPerson.relationCode';
				return;
			end if;
		end if;
		if par_input_nok_building is not null then
			if v_nok_name is null then
				par_return_code := -1;
				par_return_message := 'contact person not found';
				return;
			end if;
		if substring(par_input_nok_building, 1, 7) = 'HACODE:' then
			v_addr_code := cast(right(rtrim(par_input_nok_building), char_length(rtrim(par_input_nok_building)) - 7) as int);
			v_nok_district_code := null;
			select district_code into v_nok_district_code from address_detail
			where record_id = v_addr_code;
			if v_nok_district_code is null
			then
				par_return_code := -1;
				par_return_message := 'invalid contactPerson address record id';
				return;
			end if;
			v_nok_building := par_input_nok_building;
		else --free-text address
			if par_input_nok_building = '' then
				v_nok_building := null;
			else
				v_nok_building := par_input_nok_building;
			end if;
			if par_input_nok_district_code = '' then
				v_nok_district_code := null;
			elsif par_input_nok_district_code is not null then
				if par_input_nok_district_code in (select district_code from district) then
					v_nok_district_code := par_input_nok_district_code;
				else
					par_return_code := -1;
					par_return_message := 'invalid contactPerson.district';
					return;
				end if;
			end if;
		end if;
	end if;
		if par_input_nok_hkid = '' then
			v_nok_hkid := null;
		elsif par_input_nok_hkid is not null then
			v_nok_hkid := par_input_nok_hkid;
		end if;
		if par_input_nok_room = '' then
			v_nok_room := null;
		elsif par_input_nok_room is not null then
			v_nok_room := par_input_nok_room;
		end if;
		if par_input_nok_floor = '' then
			v_nok_floor := null;
		elsif par_input_nok_floor is not null then
			v_nok_floor := par_input_nok_floor;
		end if;
		if par_input_nok_block = '' then
			v_nok_block := null;
		elsif par_input_nok_block is not null then
			v_nok_block := par_input_nok_block;
		end if;
		if par_input_nok_home_phone = '' then
			v_nok_home_phone := null;
		elsif par_input_nok_home_phone is not null then
			v_nok_home_phone := par_input_nok_home_phone;
		end if;
		if par_input_nok_other_phone_no_1 = '' then
			v_nok_other_phone_no_1 := null;
		elsif par_input_nok_other_phone_no_1 is not null then
			v_nok_other_phone_no_1 := par_input_nok_other_phone_no_1;
		end if;
		if par_input_nok_other_phone_ext_1 = '' then
			v_nok_other_phone_ext_1 := null;
		elsif par_input_nok_other_phone_ext_1 is not null then
			v_nok_other_phone_ext_1 := par_input_nok_other_phone_ext_1;
		end if;
		if par_input_nok_other_phone_no_2 = '' then
			v_nok_other_phone_no_2 := null;
		elsif par_input_nok_other_phone_no_2 is not null then
			v_nok_other_phone_no_2 := par_input_nok_other_phone_no_2;
		end if;
		if par_input_nok_other_phone_ext_2 = '' then
			v_nok_other_phone_ext_2 := null;
		elsif par_input_nok_other_phone_ext_2 is not null then
			v_nok_other_phone_ext_2 := par_input_nok_other_phone_ext_2;
		end if;
	end if;
	if par_input_marital_status = '' then
		v_marital_status := 'U';
	elsif par_input_marital_status is not null then
		if par_input_marital_status in ('D','M','S','W','U') then
			v_marital_status := par_input_marital_status;
		else
			par_return_code := -1;
			par_return_message := 'invalid maritalStatus';
			return;
		end if;
	end if;
	if par_input_religion_code = '' then
		v_religion_code := null;
	elsif par_input_religion_code is not null then
		if par_input_religion_code in (select religion_code from religion) then
			v_religion_code := par_input_religion_code;
		else
			par_return_code := -1;
			par_return_message := 'invalid religion';
			return;
		end if;
	end if;
	if par_hago_update_datetime is not null then
		if par_force_update = 'Y' or par_hago_update_datetime >= v_last_update_datetime then
			par_input_last_update_datetime := v_last_update_datetime;
		else
			par_return_code := -1;
			par_return_message := 'patient updated by others';
			return;
		end if;
	end if;
	/*-- Use other phone as mobile_no --*/ 
	if par_input_mobile_no is not null then
		if par_input_mobile_no = ''
		then
		 par_other_phone_no_2 := null;
		else
		 par_other_phone_no_2 := par_input_mobile_no;
		end if;
	end if;
	/*-- Use other phone ext as sms_language --*/ 
	if par_input_sms_language is not null then
		if par_input_sms_language = '' then
			par_other_phone_ext_2 := null;
			else
			par_other_phone_ext_2 := null;
			select sms_language_code into par_other_phone_ext_2 from sms_language_table where sms_language = par_input_sms_language;
			if par_other_phone_ext_2 is null
			then
				par_return_code := -1;
				par_return_message := 'invalid sms language input';
				return;
			end if;
		end if;
	end if;
	select doc_code into v_doc_code from patient_doc_info where patient_key = v_patient_key;
	/* begin transaction */
	begin 
		/*-- update patient --*/
		call cpi_patient_update(par_return_code,
		par_hospital_code,
		par_hkid,
		par_patient_name,
		par_sex,
		par_dob,
		par_exact_dob_flag,
		par_ccc_1,
		par_ccc_2,
		par_ccc_3,
		par_ccc_4,
		par_ccc_5,
		par_ccc_6,
		par_chi_name,
		v_marital_status,
		par_race_code,
		par_other_document_no,
		par_reference,
		par_medical_record_number,
		par_remark,
		v_building,
		v_room,
		v_floor,
		v_block,
		v_district_code,
		v_religion_code,
		v_home_phone_no,
		v_other_phone_no_1,
		v_other_phone_ext_1,
		par_other_phone_no_2,
		par_other_phone_ext_2,
		par_death_indicator,
		par_death_date,
		par_death_code,
		par_card_holder,
		v_patient_key,
		par_priority,
		v_nok_name,
		v_nok_hkid,
		v_nok_relation_code,
		v_nok_building,
		v_nok_room,
		v_nok_floor,
		v_nok_block,
		v_nok_district_code,
		v_nok_home_phone,
		v_nok_other_phone_no_1,
		v_nok_other_phone_ext_1,
		v_nok_other_phone_no_2,
		v_nok_other_phone_ext_2,
		par_txn_type,
		par_access_code,
		par_security,
		par_transaction_datetime,
		par_update_hospital,
		par_update_by,
		par_input_last_update_datetime,
		par_source_system,
		v_doc_code);
		if par_return_code = 0 
		then
			select update_dtm into v_update_datetime
			from cpi_patient
			where patient_key = v_patient_key;
		else
			select messages into par_return_message
			from error_msgs
			where error_code = par_return_code;
			return;
		end if;
		/*-- insert Event log --*/
		 v_event_log_mrn := par_medical_record_number;
		 v_insert_event_log_type :='030';
		 v_get_event_log_dtm_prg := 'hasp_get_event_log_dtm';
		 v_insert_event_log_dtm := now();
		 v_insert_event_log_prg := 'hasp_insert_event_log';
		/*-- avoid duplicate insert event log, check first---*/
		call hasp_get_event_log_dtm(v_get_event_log_dtm_code, par_hospital_code, v_insert_event_log_dtm);
		
		if v_get_event_log_dtm_code <> 0 
		then
			/*print "Fail to insert event log!" */
			par_return_code := -1;
			par_return_message :='Fail to get event log dtm';
			return;
		end if;
		
		call hasp_insert_event_log(
		v_insert_event_log_ret_code,
		par_hospital_code,
		v_insert_event_log_dtm,
		v_insert_event_log_type,
		par_hkid,
		par_patient_name,
		par_sex,
		par_dob,
		par_exact_dob_flag,
		par_ccc_1,
		par_ccc_2,
		par_ccc_3,
		par_ccc_4,
		par_ccc_5,
		par_ccc_6,
		v_marital_status,
		par_race_code,
		par_other_document_no,
		par_medical_record_number,
		v_building,
		v_room,
		v_floor,
		v_block,
		v_district_code,
		v_religion_code,
		v_home_phone_no,
		v_other_phone_no_1,
		v_other_phone_ext_1,
		par_other_phone_no_2,
		par_other_phone_ext_2,
		par_death_indicator,
		par_death_date,
		v_patient_key,
		v_nok_name,
		v_nok_hkid,
		v_nok_relation_code,
		v_nok_building,
		v_nok_room,
		v_nok_floor,
		v_nok_block,
		v_nok_district_code,
		v_nok_home_phone,
		v_nok_other_phone_no_1,
		v_nok_other_phone_ext_1,
		v_nok_other_phone_no_2,
		v_nok_other_phone_ext_2,
		null,/*case no*/
		null,/*adm dtm*/
		null,/*source ind*/
		null,/*source code*/
		null,/*paycode*/
		null,/*disc code*/
		null,/*disc dtm*/
		null,/*dest code*/
		null,/*case type*/
		null,/*move cnt*/
		null,/*security cnt*/
		null,/*case access code*/
		par_access_code,/*pmi access code*/
		null,/*ambulance no*/
		null,/*police case*/
		null,/*labour case*/
		null,/*ae case type*/
		null,/*dba flag*/
		null,/*follow up dtm*/
		null,/*ward code*/
		null,/*spec code*/
		null,/*bed*/
		null,/*ward class*/
		par_patient_name,
		par_hkid,
		par_sex,
		par_dob,
		null,/*old ward class*/
		null,/*old ward code*/
		null,/*old spec code*/
		null,/*old bed no*/
		par_update_by,/*user id*/
		null,/*doctor code*/
		null,/*old doctor code*/
		null,/*old TPRK*/
		null,/*mrt*/
		'P');/*upload status*/
		
		if v_insert_event_log_ret_code <> 0 
		then
			/*print "Fail to insert event log!" */
			par_return_code := 200023;
			par_return_message :='Fail to insert event log';
			--ROLLBACK;
            raise exception '';
		end if;
		
		EXCEPTION 
			WHEN OTHERS THEN 
				par_return_code := -1;
				par_return_message := SQLERRM;
				--ROLLBACK;
                raise exception '';
	end;

end;
$procedure$
;

;ALTER PROCEDURE "pass_cpi_pat_upd" OWNER TO "HPI_SCHEMA_OWNER_ROLE";