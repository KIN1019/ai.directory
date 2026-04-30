-- hospital_mortuary definition

-- Drop table

-- DROP TABLE hospital_mortuary;

CREATE TABLE hospital_mortuary (
	hospital_code varchar(6) NOT NULL,
	mortuary_id int4 NOT NULL,
	effective_date timestamp(6) NULL,
	active_indicator varchar(2) NOT NULL,
	mortuary_hospital varchar(6) NOT NULL,
	english_name varchar(510) NOT NULL,
	chinese_name varchar(510) NOT NULL,
	english_address varchar(510) NOT NULL,
	chinese_address varchar(510) NOT NULL,
	office_phone varchar(20) NOT NULL,
	office_extension varchar(8) NULL,
	office_phone_2 varchar(20) NULL,
	office_extension_2 varchar(8) NULL,
	office_start_normal varchar(10) NOT NULL,
	office_end_normal varchar(10) NOT NULL,
	office_start_sat varchar(10) NULL,
	office_end_sat varchar(10) NULL,
	office_start_sun varchar(10) NULL,
	office_end_sun varchar(10) NULL,
	office_start_hol varchar(10) NULL,
	office_end_hol varchar(10) NULL,
	lunch_start varchar(10) NULL,
	lunch_end varchar(10) NULL,
	contact_phone varchar(20) NOT NULL,
	contact_extension varchar(8) NULL,
	priority int4 NOT NULL,
	pro_phone varchar(20) NULL,
	pro_extension varchar(8) NULL,
	update_by varchar(24) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	workstation_id varchar(24) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	parent_hospital varchar(6) NULL,
	booking_office_phone varchar(20) NULL,
	booking_office_phone_ext varchar(8) NULL,
	booking_office_phone_2 varchar(20) NULL,
	booking_office_phone_2_ext varchar(8) NULL
);
CREATE UNIQUE INDEX hospital_mortuary_idx ON hospital_mortuary USING btree (hospital_code, mortuary_id, effective_date, update_datetime);




ALTER TABLE hospital_mortuary OWNER TO "HPI_SCHEMA_OWNER_ROLE";
