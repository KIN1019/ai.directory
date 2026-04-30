-- hkpmi.death_reg_error definition

-- Drop table

-- DROP TABLE hkpmi.death_reg_error;

CREATE TABLE hkpmi.death_reg_error (
	system_datetime timestamp(6) NOT NULL,
	record_date varchar(24) NULL,
	hkid varchar(18) NULL,
	death_indicator varchar(8) NULL,
	death_date varchar(24) NULL,
	death_diagnosis varchar(8) NULL,
	death_external_cause varchar(8) NULL,
	err_msg varchar(160) NOT NULL,
	patient_name varchar(160) NULL,
	ccc varchar(48) NULL,
	sex varchar(2) NULL,
	dob varchar(20) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKdreg_err" ON hkpmi.death_reg_error USING btree (hkid, system_datetime);




ALTER TABLE hkpmi.death_reg_error OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
