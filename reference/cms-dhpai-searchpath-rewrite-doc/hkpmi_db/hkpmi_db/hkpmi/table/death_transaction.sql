-- hkpmi.death_transaction definition

-- Drop table

-- DROP TABLE hkpmi.death_transaction;

CREATE TABLE hkpmi.death_transaction (
	hospital_code varchar(6) NOT NULL,
	discharge_dtm timestamp(6) NOT NULL,
	patient_key varchar(24) NOT NULL,
	case_no varchar(24) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPXdeath_transaction" ON hkpmi.death_transaction USING btree (hospital_code, case_no, patient_key);
CREATE INDEX death_tx_index ON hkpmi.death_transaction USING btree (discharge_dtm, hospital_code);




ALTER TABLE hkpmi.death_transaction OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
