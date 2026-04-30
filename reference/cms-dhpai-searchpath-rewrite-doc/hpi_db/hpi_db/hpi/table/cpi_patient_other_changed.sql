-- cpi_patient_other_changed definition

-- Drop table

-- DROP TABLE cpi_patient_other_changed;

CREATE TABLE cpi_patient_other_changed (
	patient_key varchar(16) NOT NULL,
	marital_status varchar(2) NOT NULL,
	other_doc_no varchar(24) NULL,
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
	update_hospital varchar(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL,
	row_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_patient_oc_idx ON cpi_patient_other_changed USING btree (patient_key, update_dtm);



ALTER TABLE cpi_patient_other_changed OWNER TO "HPI_SCHEMA_OWNER_ROLE";
