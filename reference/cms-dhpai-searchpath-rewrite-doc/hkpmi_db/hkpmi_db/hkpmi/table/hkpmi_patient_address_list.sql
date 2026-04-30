-- hkpmi.hkpmi_patient_address_list definition

-- Drop table

-- DROP TABLE hkpmi.hkpmi_patient_address_list;

CREATE TABLE hkpmi.hkpmi_patient_address_list (
	patient_key varchar(16) NOT NULL,
	address_type varchar(2) NOT NULL,
	building varchar(510) NULL,
	room varchar(20) NULL,
	floor varchar(10) NULL,
	block varchar(10) NULL,
	district_code varchar(10) NULL,
	source_system varchar(10) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL
);
CREATE UNIQUE INDEX hkpmi_pat_addr_idx ON hkpmi.hkpmi_patient_address_list USING btree (patient_key, address_type);
CREATE INDEX hkpmi_pat_addr_idx2 ON hkpmi.hkpmi_patient_address_list USING btree (update_datetime);



ALTER TABLE hkpmi.hkpmi_patient_address_list OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
