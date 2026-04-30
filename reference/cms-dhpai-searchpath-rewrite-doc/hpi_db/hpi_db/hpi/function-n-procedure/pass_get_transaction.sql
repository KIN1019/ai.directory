CREATE OR REPLACE PROCEDURE pass_get_transaction(INOUT pas_return_code int, IN par_hospital VARCHAR, IN par_ward_list VARCHAR, IN par_spec_list VARCHAR, IN par_from_dtm TIMESTAMP WITHOUT TIME ZONE, IN par_to_dtm TIMESTAMP WITHOUT TIME ZONE, IN par_tran_list VARCHAR, IN par_case_no VARCHAR, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
AS 
$BODY$
DECLARE
    var_piece VARCHAR(255);
    var_pos INTEGER;
    var_case_no_org VARCHAR(12);
    var_pin VARCHAR(12);
    var_pin_len INTEGER;
BEGIN

	drop table IF EXISTS t$temp_ward_list;
	drop table IF EXISTS t$temp_spec_list;
	drop table IF EXISTS t$temp_tran_list;
	drop table IF EXISTS t$temp_ward_patient_list;
	drop table IF EXISTS t$temp_output;

    IF par_case_no = '' THEN
        select null into par_case_no; 
    END IF;

    IF par_case_no IS NOT NULL THEN
        BEGIN
            select null into par_ward_list;
            select null into par_spec_list;
            SELECT par_case_no INTO var_case_no_org;
            SELECT LTRIM(RTRIM(par_case_no)) INTO var_pin;
            SELECT OCTET_LENGTH(var_pin) INTO var_pin_len;

            IF var_pin_len = 11 THEN
                select ' ' || var_pin into par_case_no;
            ELSE
                select var_pin into par_case_no;
            END IF;
        END;
    END IF;
   
   	
	drop table if exists t$temp_ward_list;
	drop table if exists t$temp_spec_list;
	drop table if exists t$temp_tran_list;
	drop table if exists t$temp_ward_patient_list;
	
    CREATE TEMPORARY TABLE t$temp_ward_list
    (ward_code VARCHAR(4));
    CREATE TEMPORARY TABLE t$temp_spec_list
    (spec_code VARCHAR(4));
    CREATE TEMPORARY TABLE t$temp_tran_list
    (transaction_type VARCHAR(3));
    CREATE TEMPORARY TABLE t$temp_ward_patient_list
    (patient_key VARCHAR(8));
    CREATE TEMPORARY TABLE t$temp_output
    (patient_name VARCHAR(48) NULL,
        patient_key VARCHAR(8) NULL,
        hkid VARCHAR(12) NULL,
        sex VARCHAR(2) NULL,
        dob VARCHAR(10) NULL,
        exact_dob_flag VARCHAR(2) NULL,
        transaction_datetime TIMESTAMP WITHOUT TIME ZONE,
        hospital_code VARCHAR(3),
        transaction_type VARCHAR(3) NULL,
        cccode1 VARCHAR(5) NULL,
        cccode2 VARCHAR(5) NULL,
        cccode3 VARCHAR(5) NULL,
        cccode4 VARCHAR(5) NULL,
        cccode5 VARCHAR(5) NULL,
        cccode6 VARCHAR(5) NULL,
        martial_status VARCHAR(2) NULL,
        race VARCHAR(2) NULL,
        other_doc_no VARCHAR(12) NULL,
        reference VARCHAR(120) NULL,
        mrn VARCHAR(8) NULL,
        building VARCHAR(200) NULL,
        room VARCHAR(5) NULL,
        floor VARCHAR(2) NULL,
        block VARCHAR(2) NULL,
        district VARCHAR(5) NULL,
        religion VARCHAR(3) NULL,
        home_phone VARCHAR(10) NULL,
        office_phone VARCHAR(10) NULL,
        office_phone_ext VARCHAR(4) NULL,
        other_phone VARCHAR(10) NULL,
        other_phone_ext VARCHAR(4) NULL,
        death_indicator VARCHAR(2) NULL,
        death_date VARCHAR(19) NULL,
        death_code VARCHAR(4) NULL,
        card_holder INTEGER NULL,
        nok_priority INTEGER NULL,
        major_nok VARCHAR(2) NULL,
        nok_name VARCHAR(48) NULL,
        nok_hkid VARCHAR(12) NULL,
        nok_relationship VARCHAR(5) NULL,
        nok_building VARCHAR(80) NULL,
        nok_room VARCHAR(5) NULL,
        nok_floor VARCHAR(2) NULL,
        nok_block VARCHAR(2) NULL,
        nok_district VARCHAR(5) NULL,
        nok_home_phone VARCHAR(10) NULL,
        nok_office_phone VARCHAR(10) NULL,
        nok_office_phone_ext VARCHAR(4) NULL,
        nok_other_phone VARCHAR(10) NULL,
        nok_other_phone_ext VARCHAR(4) NULL,
        case_no VARCHAR(12) NULL,
        admission_time VARCHAR(19) NULL,
        source_indicator VARCHAR(2) NULL,
        source_code VARCHAR(3) NULL,
        patient_type VARCHAR(3) NULL,
        discharge_code VARCHAR(2) NULL,
        discharge_datetime VARCHAR(19) NULL,
        destination_code VARCHAR(3) NULL,
        doctor_code VARCHAR(8) NULL,
        case_type VARCHAR(2) NULL,
        security_count INTEGER NULL,
        case_access_code INTEGER NULL,
        pmi_access_code INTEGER NULL,
        ambulance_no VARCHAR(4) NULL,
        police_case VARCHAR(2) NULL,
        labour_case VARCHAR(2) NULL,
        ae_case_type VARCHAR(2) NULL,
        dba_flag VARCHAR(2) NULL,
        follow_up_datetime VARCHAR(19) NULL,
        ward_code VARCHAR(4) NULL,
        specialty_code VARCHAR(4) NULL,
        sub_specialty_code VARCHAR(4) NULL,
        bed_no VARCHAR(5) NULL,
        ward_class VARCHAR(2) NULL,
        transfer_datetime VARCHAR(19) NULL,
        old_patient_key VARCHAR(8) NULL,
        old_name VARCHAR(48) NULL,
        old_hkid VARCHAR(12) NULL,
        old_sex VARCHAR(2) NULL,
        old_dob VARCHAR(10) NULL,
        old_ward_class VARCHAR(2) NULL,
        old_ward_code VARCHAR(4) NULL,
        old_specialty_code VARCHAR(4) NULL,
        old_bed_no VARCHAR(5) NULL,
        old_doctor_code VARCHAR(8) NULL,
        pp_code VARCHAR(12) NULL,
        update_hospital VARCHAR(3) NULL,
        update_by VARCHAR(12) NULL,
        update_datetime VARCHAR(23) NULL,
        source_system VARCHAR(5) NULL,
        success_indicator VARCHAR(2) NULL,
        upload_status VARCHAR(2) NULL,
        source_system_datetime VARCHAR(23) NULL,
        address_building VARCHAR(200) NULL,
        address_estate VARCHAR(100) NULL,
        address_house_no VARCHAR(10) NULL,
        address_street VARCHAR(100) NULL,
        address_district VARCHAR(10) NULL,
        nok_address_building VARCHAR(200) NULL,
        nok_address_estate VARCHAR(100) NULL,
        nok_address_house_no VARCHAR(10) NULL,
        nok_address_street VARCHAR(100) NULL,
        nok_address_district VARCHAR(10) NULL,
        chi_name_unicode_int1 INTEGER NULL,
        chi_name_unicode_int2 INTEGER NULL,
        chi_name_unicode_int3 INTEGER NULL,
        chi_name_unicode_int4 INTEGER NULL,
        chi_name_unicode_int5 INTEGER NULL,
        chi_name_unicode_int6 INTEGER NULL);
		
		CREATE INDEX t$temp_output_idx ON t$temp_output(transaction_datetime);
		
		IF par_tran_list IS NULL THEN
			BEGIN
				SELECT
					'100'
					INTO par_tran_list;
			END;
		END IF;
		SELECT
			STRPOS(par_ward_list, ',')
			INTO var_pos;

		WHILE var_pos <> 0 LOOP
			SELECT
				LEFT(par_ward_list, var_pos - 1)
				INTO var_piece;

			IF var_piece IS NOT NULL THEN
				BEGIN
					INSERT INTO t$temp_ward_list
					VALUES (var_piece);
				END;
			END IF;
			SELECT
				OVERLAY(par_ward_list PLACING '' FROM 1 FOR var_pos)
				INTO par_ward_list;
			SELECT
				STRPOS(par_ward_list, ',')
				INTO var_pos;
		END LOOP;

		IF par_ward_list IS NOT NULL THEN
			BEGIN
				INSERT INTO t$temp_ward_list
				VALUES (par_ward_list);
			END;
		END IF;
		SELECT
			STRPOS(par_spec_list, ',')
			INTO var_pos;

		WHILE var_pos <> 0 LOOP
			SELECT
				LEFT(par_spec_list, var_pos - 1)
				INTO var_piece;

			IF var_piece IS NOT NULL THEN
				BEGIN
					INSERT INTO t$temp_spec_list
					VALUES (var_piece);
				END;
			END IF;
			SELECT
				OVERLAY(par_spec_list PLACING '' FROM 1 FOR var_pos)
				INTO par_spec_list;
			SELECT
				STRPOS(par_spec_list, ',')
				INTO var_pos;
		END LOOP;

		IF par_spec_list IS NOT NULL THEN
			BEGIN
				INSERT INTO t$temp_spec_list
				VALUES (par_spec_list);
			END;
		END IF;
		SELECT
			STRPOS(par_tran_list, ',')
			INTO var_pos;

		WHILE var_pos <> 0 LOOP
			SELECT
				LEFT(par_tran_list, var_pos - 1)
				INTO var_piece;

			IF var_piece IS NOT NULL THEN
				BEGIN
					INSERT INTO t$temp_tran_list
					VALUES (var_piece);
				END;
			END IF;
			SELECT
				OVERLAY(par_tran_list PLACING '' FROM 1 FOR var_pos)
				INTO par_tran_list;
			SELECT
				STRPOS(par_tran_list, ',')
				INTO var_pos;
		END LOOP;

		IF par_tran_list IS NOT NULL THEN
			BEGIN
				INSERT INTO t$temp_tran_list
				VALUES (par_tran_list);
			END;
		END IF;
		
		IF par_to_dtm IS NULL THEN
			BEGIN
				SELECT
					1 * INTERVAL '1 minute' + timestamp_convert(localtimestamp)::TIMESTAMP
					INTO par_to_dtm;
			END;
		END IF;
		
		IF 12 * (DATE_PART('year', par_to_dtm::TIMESTAMP) - DATE_PART('year', par_from_dtm::TIMESTAMP)) + DATE_PART('month', par_to_dtm::TIMESTAMP) - DATE_PART('month', par_from_dtm::TIMESTAMP) >= 18 THEN
			BEGIN
				RAISE EXCEPTION 'Search date range is too long. Please specify a date range within 18 months.' USING ERRCODE := '99999';
			END;
		END IF;

		IF par_case_no IS NOT NULL THEN
			BEGIN
				IF EXISTS (SELECT
					1
					FROM t$temp_tran_list
					WHERE transaction_type NOT IN ('020', '030', '031', '100', '121', '140', '700', '040')) THEN
					BEGIN
						RAISE EXCEPTION 'Invalid transaction types, only transaction types (020,030,031,100,121,140,700,040) will be supported' USING ERRCODE := '99999';
					END;
				END IF;
			END;
		ELSE
			BEGIN
				IF EXISTS (SELECT
					1
					FROM t$temp_tran_list
					WHERE transaction_type NOT IN ('020', '030', '031', '100', '121', '140', '700')) THEN
					BEGIN
						RAISE EXCEPTION 'Invalid transaction types, only transaction types (020,030,031,100,121,140,700) will be supported' USING ERRCODE := '99999';
					END;
				END IF;
			END;
		END IF;
		
		INSERT INTO t$temp_ward_patient_list
		SELECT
			c.patient_key
			FROM cpi_case AS c, cpi_ward_list AS w
			WHERE c.hospital_code = w.hospital_code AND c.case_no = w.case_no AND w.ward_code IN (SELECT
				ward_code
				FROM t$temp_ward_list);
				
		insert into t$temp_output
		(hospital_code, transaction_datetime, transaction_type, patient_key,
		mrn, case_no, source_indicator, source_code, patient_type, discharge_code,
		discharge_datetime, destination_code, doctor_code, case_type, security_count,
		case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type,
		dba_flag, follow_up_datetime, ward_code, specialty_code, sub_specialty_code, bed_no,
		ward_class, transfer_datetime, old_patient_key, old_name, old_hkid, old_sex, old_dob,
		old_ward_class, old_ward_code, old_specialty_code, old_bed_no, old_doctor_code,
		pp_code, update_hospital, update_by, update_datetime, source_system, success_indicator,
		upload_status, source_system_datetime)

		select	rtrim(t.hospital_code) as hospital_code,
		t.transaction_datetime,
		rtrim(t.transaction_type) as transaction_type,
		t.patient_key,
		rtrim(t.medical_record_number) as mrn,
		rtrim(t.case_no) as case_no,
		rtrim(t.source_indicator) as source_indicator,
		rtrim(t.source_code) as source_code,
		rtrim(t.patient_type) as patient_type,
		rtrim(t.discharge_code) as discharge_code,
		case when t.discharge_datetime is not null
			then to_char(t.discharge_datetime, 'dd-mm-yyyy') || ' ' || to_char(t.discharge_datetime, 'hh:mm:ss')
			else null end as discharge_datetime,
		rtrim(t.destination_code) as destination_code,
		rtrim(t.doctor_code) as doctor_code,
		rtrim(t.case_type) as case_type,
		t.security_count as security_count,
		t.case_access_code,
		t.pmi_access_code,
		rtrim(t.ambulance_no) as ambulance_no,
		rtrim(t.police_case) as police_case,
		rtrim(t.labour_case) as labour_case,
		rtrim(t.ae_case_type) as ae_case_type,
		rtrim(t.dba_flag) as dba_flag,
		case when t.follow_up_datetime is not null
			then to_char(t.follow_up_datetime, 'dd-mm-yyyy') || ' ' || to_char(t.follow_up_datetime, 'hh:mm:ss')
			else null end as follow_up_datetime,
		rtrim(t.ward_code) as ward_code,
		rtrim(t.specialty_code) as specialty_code,
		rtrim(t.sub_specialty_code) as sub_specialty_code,
		rtrim(t.bed_no) as bed_no,
		rtrim(t.ward_class) as ward_class,
		case when t.transfer_datetime is not null
			then to_char(t.transfer_datetime, 'dd-mm-yyyy') || ' ' || to_char(t.transfer_datetime, 'hh:mm:ss')
			else null end as transfer_datetime,
		rtrim(t.old_patient_key) as old_patient_key,
		rtrim(t.old_name) as old_name,
		rtrim(t.old_hkid) as old_hkid,
		rtrim(t.old_sex) as old_sex,
		to_char(old_dob, 'dd-mm-yyyy') as old_dob,
		rtrim(t.old_ward_class) as old_ward_class,
		rtrim(t.old_ward_code) as old_ward_code,
		rtrim(t.old_specialty_code) as old_specialty_code,
		rtrim(t.old_bed_no) as old_bed_no,
		rtrim(t.old_doctor_code) as old_doctor_code,
		rtrim(t.pp_code) as pp_code,
		rtrim(t.update_hospital) as update_hospital,
		rtrim(t.update_by) as update_by,
		case when t.update_datetime is not null
			then to_char(t.update_datetime, 'dd-mm-yyyy') || ' ' || to_char(t.update_datetime, 'hh:mm:ss')
			else null end as update_datetime,
		rtrim(t.source_system) as source_system,
		rtrim(t.success_indicator) as success_indicator,
		rtrim(t.upload_status) as upload_status,
		case when t.source_system_dtm is not null
			then to_char(t.source_system_dtm, 'dd-mm-yyyy')||' '||to_char(t.source_system_dtm, 'hh:mm:ss')
			else null end as source_system_datetime

		from cpi_transaction t
		/* Yorky: To modify the compare operator from >= to > */
		where t.transaction_datetime > par_from_dtm
		and t.transaction_datetime <= par_to_dtm
		and t.hospital_code = par_hospital
		and (
		(t.patient_key in (select patient_key from t$temp_ward_patient_list) and
		t.transaction_type in (select transaction_type from t$temp_tran_list where transaction_type in ('030','031','020')))
		or
		((t.case_no = par_case_no or t.case_no like var_case_no_org) and
		t.transaction_type in (select transaction_type from t$temp_tran_list where transaction_type in ('100','040')))
		or
		(t.ward_code in (select ward_code from t$temp_ward_list) and
		t.transaction_type in (select transaction_type from t$temp_tran_list where transaction_type in ('100','121','140','700')))
		or
		(par_ward_list is null and t.specialty_code in (select spec_code from t$temp_spec_list) and
		t.transaction_type in (select transaction_type from t$temp_tran_list where transaction_type in ('100','121','140')))
		)
		order by t.transaction_datetime;

		/* update patient details for patient-based transactions */
		update t$temp_output
		set hkid = p.hkid,
		patient_name = p.patient_name,
		sex = p.sex,
		dob = to_char(p.dob, 'dd-mm-yyyy'),
		exact_dob_flag = p.exact_dob_flag,
		cccode1 = p.cccode1,
		cccode2 = p.cccode2,
		cccode3 = p.cccode3,
		cccode4 = p.cccode4,
		cccode5 = p.cccode5,
		cccode6 = p.cccode6,
		martial_status = p.marital_status,
		race = p.race,
		other_doc_no = p.other_doc_no,
		reference = p.reference,
		building = p.building,
		room = p.room,
		floor = p.floor,
		block = p.block,
		district = p.district,
		religion = p.religion,
		home_phone=p.phone1,
		office_phone = p.phone2,
		office_phone_ext = p.address_indicator,
		other_phone = p.mobile_phone,
		other_phone_ext = p.sms_language,
		death_indicator = p.death_indicator,
		death_date = case when p.death_date is not null
			then to_char(p.death_date, 'dd-mm-yyyy')||' '||to_char(p.death_date, 'hh:mm:ss')
			else null end,
		death_code = p.death_code,
		card_holder = p.card_holder,
		chi_name_unicode_int1 = c1.unicode_int,
		chi_name_unicode_int2 = c2.unicode_int,
		chi_name_unicode_int3 = c3.unicode_int,
		chi_name_unicode_int4 = c4.unicode_int,
		chi_name_unicode_int5 = c5.unicode_int,
		chi_name_unicode_int6 = c6.unicode_int
		from cpi_patient p
		INNER JOIN t$temp_output AS t on t.patient_key = p.patient_key
		LEFT JOIN ccc_unicode AS c1 ON SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
		LEFT JOIN ccc_unicode AS c2 ON SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
		LEFT JOIN ccc_unicode AS c3 ON SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
		LEFT JOIN ccc_unicode AS c4 ON SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
		LEFT JOIN ccc_unicode AS c5 ON SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
		LEFT JOIN ccc_unicode AS c6 ON SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
		where t.patient_key is not null;
		

		/* update patient details for case-related transactions */
		update t$temp_output
		set patient_key = p.patient_key,
		hkid = p.hkid,
		patient_name = p.patient_name,
		sex = p.sex,
		dob = to_char(p.dob, 'dd-mm-yyyy'),
		exact_dob_flag = p.exact_dob_flag,
		cccode1 = p.cccode1,
		cccode2 = p.cccode2,
		cccode3 = p.cccode3,
		cccode4 = p.cccode4,
		cccode5 = p.cccode5,
		cccode6 = p.cccode6,
		martial_status = p.marital_status,
		race = p.race,
		other_doc_no = p.other_doc_no,
		reference = p.reference,
		building = p.building,
		room = p.room,
		floor = p.floor,
		block = p.block,
		district = p.district,
		religion = p.religion,
		home_phone=p.phone1,
		office_phone = p.phone2,
		office_phone_ext = p.address_indicator,
		other_phone = p.mobile_phone,
		other_phone_ext = p.sms_language,
		death_indicator = p.death_indicator,
		death_date = case when p.death_date is not null
			then to_char(p.death_date, 'dd-mm-yyyy')||' '||to_char(p.death_date, 'hh:mm:ss')
			else null end,
		death_code = p.death_code,
		card_holder = p.card_holder,
		chi_name_unicode_int1 = c1.unicode_int,
		chi_name_unicode_int2 = c2.unicode_int,
		chi_name_unicode_int3 = c3.unicode_int,
		chi_name_unicode_int4 = c4.unicode_int,
		chi_name_unicode_int5 = c5.unicode_int,
		chi_name_unicode_int6 = c6.unicode_int
		from cpi_patient p
		INNER JOIN cpi_case as c on c.patient_key = p.patient_key
		INNER JOIN t$temp_output AS t on t.hospital_code = c.hospital_code and t.case_no = c.case_no
		LEFT JOIN ccc_unicode AS c1 ON SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
		LEFT JOIN ccc_unicode AS c2 ON SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
		LEFT JOIN ccc_unicode AS c3 ON SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
		LEFT JOIN ccc_unicode AS c4 ON SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
		LEFT JOIN ccc_unicode AS c5 ON SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
		LEFT JOIN ccc_unicode AS c6 ON SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
		where t.case_no is not null;
		

		/* update address for patient */
		update t$temp_output
		set address_building = a.bldg_eng,
		address_estate = a.estate_eng,
		address_house_no = a.house_no,
		address_street = a.street_eng,
		address_district = a.district_code,
		building = case when left(t.building,7)='HACODE:'
			then CONCAT((CASE WHEN a.bldg_eng is null THEN null ELSE CONCAT(rtrim(a.bldg_eng),
				(CASE WHEN CONCAT(a.estate_eng,a.street_eng) is null THEN null ELSE ', ' END)) end),
				(CASE WHEN a.estate_eng is null THEN null ELSE CONCAT(rtrim(a.estate_eng),
				(CASE WHEN a.street_eng is null THEN null ELSE ', ' END)) END),
				(CASE WHEN a.house_no is null then null ELSE rtrim(a.house_no) || ' ' END),
				(CASE WHEN a.street_eng is null then null ELSE rtrim(a.street_eng) END))
			else rtrim(t.building) end
		from t$temp_output t 
		left join address_detail a on case when left(t.building,7)='HACODE:'
			then right(t.building, LENGTH(t.building)-7)::INTEGER else -1 end
			= a.record_id;

		/* update nok details */
		update t$temp_output
		set nok_priority = n.priority,
		major_nok = n.major_nok,
		nok_name = n.nok_name,
		nok_hkid = n.hkid,
		nok_relationship = n.relationship,
		nok_building = case when left(n.building,7)='HACODE:'
			then CONCAT((CASE WHEN noka.bldg_eng is null THEN null ELSE CONCAT(rtrim(noka.bldg_eng),
				(CASE WHEN CONCAT(noka.estate_eng,noka.street_eng) is null THEN null ELSE ', ' END)) END),
				(CASE WHEN noka.estate_eng is null THEN null ELSE CONCAT(rtrim(noka.estate_eng),
				(CASE WHEN noka.street_eng is null THEN null ELSE ', ' END)) END),
				(CASE WHEN noka.house_no is null then null ELSE rtrim(noka.house_no) || ' ' END),
				(CASE WHEN noka.street_eng is null then null ELSE rtrim(noka.street_eng) END))
			else rtrim(n.building) end,
		nok_room = n.room,
		nok_floor = n.floor,
		nok_block = n.block,
		nok_district = n.district,
		nok_home_phone = n.phone1,
		nok_office_phone = n.phone2,
		nok_office_phone_ext = n.address_indicator,
		nok_other_phone = n.mobile_phone,
		nok_other_phone_ext = n.sms_language,
		nok_address_building = rtrim(noka.bldg_eng),
		nok_address_estate = rtrim(noka.estate_eng),
		nok_address_house_no = rtrim(noka.house_no),
		nok_address_street = rtrim(noka.street_eng),
		nok_address_district = rtrim(noka.district_code)
		from t$temp_output t
		left join cpi_nok n on t.patient_key = n.patient_key
		left join address_detail noka on case when left(n.building,7)='HACODE:'
		then right(n.building, LENGTH(n.building)-7)::INTEGER else -1 end = noka.record_id
		where n.priority = 1;

		/* update case details */
		update t$temp_output
		set admission_time = to_char(c.admission_dtm, 'dd-mm-yyyy')||' '||to_char(c.admission_dtm, 'hh:mm:ss')
		from t$temp_output t, cpi_case c
		where t.hospital_code = c.hospital_code
		and t.case_no = c.case_no;

		if exists (select 1 from t$temp_spec_list) then
			begin
				OPEN p_refcur FOR select 
				patient_name,
				patient_key,
				hkid,
				sex,
				dob,
				exact_dob_flag,
				case when transaction_datetime is not null
					then to_char(transaction_datetime, 'dd-mm-yyyy')||' '||to_char(transaction_datetime, 'hh:mm:ss')
					else null end as transaction_time,
				hospital_code,
				transaction_type,
				cccode1,
				cccode2,
				cccode3,
				cccode4,
				cccode5,
				cccode6,
				martial_status,
				race,
				other_doc_no,
				reference,
				mrn,
				building,
				room,
				floor,
				block,
				district,
				religion,
				home_phone,
				office_phone,
				office_phone_ext,
				other_phone,
				other_phone_ext,
				death_indicator,
				death_date,
				death_code,
				card_holder,
				nok_priority,
				major_nok,
				nok_name,
				nok_hkid,
				nok_relationship,
				nok_building,
				nok_room,
				nok_floor,
				nok_block,
				nok_district,
				nok_home_phone,
				nok_office_phone,
				nok_office_phone_ext,
				nok_other_phone,
				nok_other_phone_ext,
				case_no,
				admission_time,
				source_indicator,
				source_code,
				patient_type,
				discharge_code,
				discharge_datetime,
				destination_code,
				doctor_code,
				case_type,
				security_count,
				case_access_code,
				pmi_access_code,
				ambulance_no,
				police_case,
				labour_case,
				ae_case_type,
				dba_flag,
				follow_up_datetime,
				ward_code,
				specialty_code,
				sub_specialty_code,
				bed_no,
				ward_class,
				transfer_datetime,
				old_patient_key,
				old_name,
				old_hkid,
				old_sex,
				old_dob,
				old_ward_class,
				old_ward_code,
				old_specialty_code,
				old_bed_no,
				old_doctor_code,
				pp_code,
				update_hospital,
				update_by,
				update_datetime,
				source_system,
				success_indicator,
				upload_status,
				source_system_datetime,
				address_building,
				address_estate,
				address_house_no,
				address_street,
				address_district,
				nok_address_building,
				nok_address_estate,
				nok_address_house_no,
				nok_address_street,
				nok_address_district,
				chi_name_unicode_int1,
				chi_name_unicode_int2,
				chi_name_unicode_int3,
				chi_name_unicode_int4,
				chi_name_unicode_int5,
				chi_name_unicode_int6
				from t$temp_output t
				where t.specialty_code in (select spec_code from t$temp_spec_list)
				order by t.transaction_datetime;
			end;
		else
			begin
				OPEN p_refcur FOR select patient_name,
				patient_key,
				hkid,
				sex,
				dob,
				exact_dob_flag,
				case when transaction_datetime is not null
					then to_char(transaction_datetime, 'dd-mm-yyyy')|| ' ' ||to_char(transaction_datetime, 'hh:mm:ss')
					else null end as transaction_time,
				hospital_code,
				transaction_type,
				cccode1,
				cccode2,
				cccode3,
				cccode4,
				cccode5,
				cccode6,
				martial_status,
				race,
				other_doc_no,
				reference,
				mrn,
				building,
				room,
				floor,
				block,
				district,
				religion,
				home_phone,
				office_phone,
				office_phone_ext,
				other_phone,
				other_phone_ext,
				death_indicator,
				death_date,
				death_code,
				card_holder,
				nok_priority,
				major_nok,
				nok_name,
				nok_hkid,
				nok_relationship,
				nok_building,
				nok_room,
				nok_floor,
				nok_block,
				nok_district,
				nok_home_phone,
				nok_office_phone,
				nok_office_phone_ext,
				nok_other_phone,
				nok_other_phone_ext,
				case_no,
				admission_time,
				source_indicator,
				source_code,
				patient_type,
				discharge_code,
				discharge_datetime,
				destination_code,
				doctor_code,
				case_type,
				security_count,
				case_access_code,
				pmi_access_code,
				ambulance_no,
				police_case,
				labour_case,
				ae_case_type,
				dba_flag,
				follow_up_datetime,
				ward_code,
				specialty_code,
				sub_specialty_code,
				bed_no,
				ward_class,
				transfer_datetime,
				old_patient_key,
				old_name,
				old_hkid,
				old_sex,
				old_dob,
				old_ward_class,
				old_ward_code,
				old_specialty_code,
				old_bed_no,
				old_doctor_code,
				pp_code,
				update_hospital,
				update_by,
				update_datetime,
				source_system,
				success_indicator,
				upload_status,
				source_system_datetime,
				address_building,
				address_estate,
				address_house_no,
				address_street,
				address_district,
				nok_address_building,
				nok_address_estate,
				nok_address_house_no,
				nok_address_street,
				nok_address_district,
				chi_name_unicode_int1,
				chi_name_unicode_int2,
				chi_name_unicode_int3,
				chi_name_unicode_int4,
				chi_name_unicode_int5,
				chi_name_unicode_int6
				from t$temp_output t
				order by t.transaction_datetime;
			end;
		end if;


END;
$BODY$
LANGUAGE plpgsql;

;ALTER PROCEDURE "pass_get_transaction" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
