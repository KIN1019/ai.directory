-- hospital_upload_control definition

-- Drop table

-- DROP TABLE hospital_upload_control;

CREATE TABLE hospital_upload_control (
	hospital_code varchar(6) NOT NULL,
	pbrc_upload_flag varchar(2) NOT NULL,
	opas_upload_flag varchar(2) NOT NULL,
	last_update_datetime timestamp(6) NULL
);

CREATE UNIQUE INDEX hospital_upload_control_idx ON hospital_upload_control USING btree (hospital_code);

--Sybase DDL (PROD Jul-2025 snapshot): exec sp_primarykey 'download.dbo.hospital_upload_control', 'hospital_code'
ALTER TABLE hospital_upload_control ADD PRIMARY KEY (hospital_code);

ALTER TABLE hospital_upload_control OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";
