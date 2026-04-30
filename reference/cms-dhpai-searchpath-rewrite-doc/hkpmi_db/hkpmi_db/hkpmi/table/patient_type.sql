-- hkpmi.patient_type definition

-- Drop table

-- DROP TABLE hkpmi.patient_type;

CREATE TABLE hkpmi.patient_type (
	patient_type varchar(6) NOT NULL,
	description varchar(160) NOT NULL,
	effective_dtm timestamp(6) NULL,
	patient_group varchar(10) NULL,
	pay_code_type varchar(10) NULL,
	active_status varchar(2) NULL,
	user_define varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKpatient_type" ON hkpmi.patient_type USING btree (patient_type);




ALTER TABLE hkpmi.patient_type OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
