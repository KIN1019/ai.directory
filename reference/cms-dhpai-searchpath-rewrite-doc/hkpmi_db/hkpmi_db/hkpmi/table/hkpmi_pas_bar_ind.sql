-- hkpmi.hkpmi_pas_bar_ind definition

-- Drop table

-- DROP TABLE hkpmi.hkpmi_pas_bar_ind;

CREATE TABLE hkpmi.hkpmi_pas_bar_ind (
	hospital_code varchar(6) NOT NULL,
	system_dtm timestamp(6) NOT NULL,
	txn_type varchar(6) NULL,
	hkid varchar(24) NULL,
	patient_key varchar(16) NULL,
	case_no varchar(24) NULL,
	txn_type_ind varchar(2) NULL,
	filler bpchar(128) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX "IE1hkpmi_pas_bar_ind" ON hkpmi.hkpmi_pas_bar_ind USING btree (patient_key);
CREATE INDEX "IE2hkpmi_pas_bar_ind" ON hkpmi.hkpmi_pas_bar_ind USING btree (hkid);
CREATE INDEX "IE3hkpmi_pas_bar_ind" ON hkpmi.hkpmi_pas_bar_ind USING btree (case_no, hospital_code);
CREATE UNIQUE INDEX "XPKhkpmi_pas_bar_ind" ON hkpmi.hkpmi_pas_bar_ind USING btree (hospital_code, system_dtm);




ALTER TABLE hkpmi.hkpmi_pas_bar_ind OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
