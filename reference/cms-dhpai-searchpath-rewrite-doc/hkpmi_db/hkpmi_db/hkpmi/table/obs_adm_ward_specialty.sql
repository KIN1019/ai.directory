-- hkpmi.obs_adm_ward_specialty definition

-- Drop table

-- DROP TABLE hkpmi.obs_adm_ward_specialty;

CREATE TABLE hkpmi.obs_adm_ward_specialty (
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NULL,
	specialty_code varchar(8) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX obs_adm_ward_specialty_index ON hkpmi.obs_adm_ward_specialty USING btree (hospital_code);




ALTER TABLE hkpmi.obs_adm_ward_specialty OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
