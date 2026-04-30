-- patient_key_exception definition

-- Drop table

-- DROP TABLE patient_key_exception;

CREATE TABLE patient_key_exception (
	hospital_code varchar(6) NOT NULL,
	hkid varchar(24) NOT NULL,
	patient_key varchar(16) NULL,
	mf_patient_key varchar(16) NULL,
	system_dtm timestamp NOT NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX patient_key_exception_ui ON patient_key_exception USING btree (hospital_code, hkid, patient_key, mf_patient_key, system_dtm);
CREATE UNIQUE INDEX patient_key_exception_ui ON patient_key_exception USING btree (record_id);

ALTER TABLE patient_key_exception OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";
