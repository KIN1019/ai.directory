-- hkpmi.death_registry definition

-- Drop table

-- DROP TABLE hkpmi.death_registry;

CREATE TABLE hkpmi.death_registry (
	record_date varchar(20) NOT NULL,
	patient_name varchar(160) NOT NULL,
	ccc varchar(48) NOT NULL,
	sex varchar(2) NOT NULL,
	hkid varchar(18) NOT NULL,
	death_date varchar(20) NOT NULL,
	age varchar(6) NOT NULL,
	doc_no varchar(44) NOT NULL,
	dob varchar(20) NOT NULL,
	death_diagnosis varchar(8) NOT NULL,
	death_external_cause varchar(8) NOT NULL,
	death_place varchar(300) NOT NULL,
	latest_attend_hospital varchar(6) DEFAULT ' '::bpchar NOT NULL,
	latest_attend_hn varchar(24) DEFAULT ' '::bpchar NOT NULL,
	latest_attend_date varchar(20) DEFAULT ' '::bpchar NOT NULL,
	latest_discharge_date varchar(20) DEFAULT ' '::bpchar NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKdreg" ON hkpmi.death_registry USING btree (hkid, dob, patient_name, ccc, sex, doc_no, death_date, death_diagnosis, death_external_cause, death_place);




ALTER TABLE hkpmi.death_registry OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
