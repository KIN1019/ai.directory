-- hkpmi.del_pmi_log definition

-- Drop table

-- DROP TABLE hkpmi.del_pmi_log;

CREATE TABLE hkpmi.del_pmi_log (
	patient_key varchar(16) NOT NULL,
	hkid varchar(24) NOT NULL,
	patient_name varchar(96) NOT NULL,
	sex varchar(2) NOT NULL,
	dob timestamp(6) NULL,
	cccode1 varchar(10) NULL,
	cccode2 varchar(10) NULL,
	cccode3 varchar(10) NULL,
	cccode4 varchar(10) NULL,
	cccode5 varchar(10) NULL,
	cccode6 varchar(10) NULL,
	update_hospital varchar(6) NOT NULL,
	source_system varchar(10) NOT NULL,
	update_by varchar(16) NOT NULL,
	source_system_dtm timestamp(6) NOT NULL,
	system_dtm timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XIE1del_pmi_log" ON hkpmi.del_pmi_log USING btree (patient_key);




ALTER TABLE hkpmi.del_pmi_log OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
