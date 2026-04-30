-- hkpmi.hkpmi_patient_address_log definition

-- Drop table

-- DROP TABLE hkpmi.hkpmi_patient_address_log;

CREATE TABLE hkpmi.hkpmi_patient_address_log (
	system_dtm timestamp(6) NOT NULL,
	patient_key varchar(16) NOT NULL,
	update_type varchar(10) NOT NULL,
	address_type varchar(2) NOT NULL,
	building varchar(510) NULL,
	room varchar(20) NULL,
	floor varchar(10) NULL,
	block varchar(10) NULL,
	district_code varchar(10) NULL,
	old_building varchar(510) NULL,
	old_room varchar(20) NULL,
	old_floor varchar(10) NULL,
	old_block varchar(10) NULL,
	old_district_code varchar(10) NULL,
	source_system varchar(10) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL
);
CREATE UNIQUE INDEX hkpmi_pat_addr_log_idx ON hkpmi.hkpmi_patient_address_log USING btree (patient_key, system_dtm);




ALTER TABLE hkpmi.hkpmi_patient_address_log OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
