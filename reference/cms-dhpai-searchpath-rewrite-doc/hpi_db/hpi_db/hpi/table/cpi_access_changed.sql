-- cpi_access_changed definition

-- Drop table

-- DROP TABLE cpi_access_changed;

CREATE TABLE cpi_access_changed (
	patient_key varchar(16) NOT NULL,
	original_hkid varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL,
	access_status varchar(2) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	row_update_datetime timestamp(6) NULL

	-- Remove "last_update_datetime" as there already exists "update_dtm"
	--last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_access_c_idx ON cpi_access_changed USING btree (patient_key, original_hkid, update_dtm);
CREATE INDEX cpi_access_c_updtm_idx ON cpi_access_changed USING btree (update_dtm);



ALTER TABLE cpi_access_changed OWNER TO "HPI_SCHEMA_OWNER_ROLE";
