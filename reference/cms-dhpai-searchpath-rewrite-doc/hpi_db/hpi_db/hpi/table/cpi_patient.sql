-- cpi_patient definition

-- Drop table

-- DROP TABLE cpi_patient;

CREATE TABLE cpi_patient (
	patient_key varchar(16) NOT NULL,
	hkid varchar(24) NOT NULL,
	patient_name varchar(96) NOT NULL,
	sex varchar(2) NOT NULL,
	cccode1 varchar(10) NULL,
	cccode2 varchar(10) NULL,
	cccode3 varchar(10) NULL,
	cccode4 varchar(10) NULL,
	cccode5 varchar(10) NULL,
	cccode6 varchar(10) NULL,
	chi_name varchar(24) NULL,
	dob timestamp(6) NULL,
	exact_dob_flag varchar(2) NOT NULL,
	marital_status varchar(2) NOT NULL,
	race varchar(4) NOT NULL,
	other_doc_no varchar(24) NULL,
	reference varchar(40) NULL,
	building varchar(94) NULL,
	room varchar(10) NULL,
	floor varchar(4) NULL,
	block varchar(4) NULL,
	district varchar(10) NULL,
	religion varchar(6) NULL,
	phone1 varchar(20) NULL,
	phone2 varchar(20) NULL,
	address_indicator varchar(8) NULL,
	mobile_phone varchar(20) NULL,
	sms_language varchar(8) NULL,
	death_indicator varchar(2) NOT NULL,
	death_date timestamp(6) NULL,
	death_code varchar(8) NULL,
	card_holder int4 NULL,
	access_code int4 NOT NULL,
	"security" int4 DEFAULT 0 NOT NULL,
	patient_no int4 NOT NULL,
	create_hospital varchar(6) NULL,
	create_by varchar(24) NOT NULL,
	create_dtm timestamp(6) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL,
	rep_clusters int4 NOT NULL,
	init_hospital int4 NULL,
	init_source int4 NULL,
	row_update_datetime timestamp(6) NULL,
	rep_hosp1 int4 DEFAULT 1 NOT NULL,
	rep_hosp2 int4 DEFAULT 0 NOT NULL,
	rep_clinic1 int4 DEFAULT 0 NOT NULL,
	rep_clinic2 int4 DEFAULT 0 NOT NULL,
	body_category varchar(2) NULL,
	hkic_symbol varchar(2) NULL
);
CREATE INDEX cpi_patient_building_idx ON cpi_patient USING btree (building);
CREATE INDEX cpi_patient_doc_no_idx ON cpi_patient USING btree (other_doc_no);
CREATE UNIQUE INDEX cpi_patient_hkid_idx ON cpi_patient USING btree (hkid);
CREATE UNIQUE INDEX cpi_patient_idx ON cpi_patient USING btree (patient_key);
CREATE INDEX cpi_patient_nam_idx ON cpi_patient USING btree (patient_name varchar_pattern_ops);
CREATE UNIQUE INDEX cpi_patient_no_idx ON cpi_patient USING btree (patient_no);
CREATE INDEX cpi_patient_phone_idx ON cpi_patient USING btree (phone1);

ALTER TABLE cpi_patient OWNER TO "HPI_SCHEMA_OWNER_ROLE";
