-- ae_multi_registration definition

-- Drop table

-- DROP TABLE ae_multi_registration;

CREATE TABLE ae_multi_registration (
	hospital_code varchar(6) NOT NULL,
	hkid varchar(24) NOT NULL,
	effective_date timestamp(6) NOT NULL,
	close_date timestamp(6) NULL,
	multi_type varchar(2) NULL,
	request_by varchar(96) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX ae_multi_reg_index ON ae_multi_registration USING btree (hospital_code, hkid, multi_type, effective_date);




ALTER TABLE ae_multi_registration OWNER TO "HPI_SCHEMA_OWNER_ROLE";
