-- upload_control definition

-- Drop table

-- DROP TABLE upload_control;

CREATE TABLE upload_control (
	hospital_code varchar(6) NOT NULL,
	provider_id varchar(6) NOT NULL,
	gateway_id varchar(16) NOT NULL,
	adt_cics_id varchar(16) NOT NULL,
	ops_cics_id varchar(16) NOT NULL,
	upload_enable varchar(2) NOT NULL,
	last_upload_dtm timestamp NOT NULL,
	check_patient_key varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);

CREATE UNIQUE INDEX upload_control_idx ON upload_control USING btree (hospital_code);

--Sybase DDL (PROD Jul-2025 snapshot): exec sp_primarykey 'download.dbo.upload_control', 'hospital_code'
ALTER TABLE upload_control ADD PRIMARY KEY (hospital_code);

ALTER TABLE upload_control OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";
