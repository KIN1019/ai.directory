-- patient_key definition

-- Drop table

-- DROP TABLE patient_key;

CREATE TABLE patient_key (
	effective_dtm timestamp NOT NULL,
	patient_key int4 NOT NULL,
	patient_key_from int4 NOT NULL,
	patient_key_to int4 NOT NULL,
	last_update_datetime timestamp(6) NULL
);

CREATE UNIQUE INDEX "XPKpatient_key" ON patient_key USING btree (effective_dtm);

ALTER TABLE patient_key OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
