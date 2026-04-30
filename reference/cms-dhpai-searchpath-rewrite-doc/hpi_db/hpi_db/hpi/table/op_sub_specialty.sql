-- op_sub_specialty definition

-- Drop table

-- DROP TABLE op_sub_specialty;

CREATE TABLE op_sub_specialty (
	specialty_code varchar(8) NOT NULL,
	sub_specialty varchar(8) NOT NULL,
	hospital_code varchar(6) NOT NULL,
	sub_spec_desc varchar(60) NOT NULL,
	chi_long varchar(32) NULL,
	chi_short varchar(16) NULL,
	"type" varchar(2) NOT NULL,
	phone varchar(20) NOT NULL,
	exclusive_group int2 NOT NULL,
	am_pm_time timestamp(6) NULL,
	multi_book varchar(2) NOT NULL,
	imis_specialty varchar(8) NOT NULL,
	subs_control varchar(2) NOT NULL,
	default_period int2 NOT NULL,
	default_period_unit varchar(2) NOT NULL,
	status varchar(2) NOT NULL,
	remark varchar(60) NULL,
	quota_control varchar(24) NULL,
	imis_service_type varchar(2) NULL,
	print_priority_no varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX sub_specialty_idx ON op_sub_specialty USING btree (specialty_code, sub_specialty, hospital_code);




ALTER TABLE op_sub_specialty OWNER TO "HPI_SCHEMA_OWNER_ROLE";
