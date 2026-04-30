-- upload_control definition

-- Drop table

-- DROP TABLE upload_control_pg;

CREATE TABLE upload_control_pg (
	hospital_code varchar(6) NOT NULL,
	provider_id varchar(6) NOT NULL,
	gateway_id varchar(16) NOT NULL,
	adt_cics_id varchar(16) NOT NULL,
	ops_cics_id varchar(16) NOT NULL,
	upload_enable varchar(2) NOT NULL,
	last_upload_datetime timestamp(6) NOT NULL,
	check_patient_key varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX upload_control_idx ON upload_control_pg USING btree (hospital_code);




ALTER TABLE upload_control_pg OWNER TO "HPI_SCHEMA_OWNER_ROLE";
