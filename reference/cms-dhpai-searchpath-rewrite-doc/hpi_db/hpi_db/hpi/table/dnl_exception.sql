-- dnl_exception definition

-- Drop table

-- DROP TABLE dnl_exception;

CREATE TABLE dnl_exception (
	hospital_code varchar(6) NOT NULL,
	download_key varchar(46) NOT NULL,
	patient_key varchar(16) NOT NULL,
	hkid varchar(24) NOT NULL,
	error_code int4 NOT NULL,
	error_msg varchar(510) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL,
	row_update_datetime timestamp(6) NULL,
	download_system_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX dnl_exception_idx ON dnl_exception USING btree (hospital_code, update_dtm);
CREATE INDEX dnl_exception_idx2 ON dnl_exception USING btree (hospital_code, download_key);
CREATE INDEX dnl_exception_idx3 ON dnl_exception USING btree (hospital_code, download_system_datetime);



ALTER TABLE dnl_exception OWNER TO "HPI_SCHEMA_OWNER_ROLE";
