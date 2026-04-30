-- hkpmi.patient_detail_1 definition

-- Drop table

-- DROP TABLE hkpmi.patient_detail_1;

CREATE TABLE hkpmi.patient_detail_1 (
	patient_key varchar(16) NOT NULL,
	hosp_byte_1 int4 NOT NULL,
	hosp_byte_2 int4 NOT NULL,
	hosp_byte_3 int4 NOT NULL,
	update_by varchar(16) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	source_system varchar(10) NOT NULL,
	system_dtm timestamp(6) NOT NULL,
	row_update_datetime timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKpatient_detail_1" ON hkpmi.patient_detail_1 USING btree (patient_key);



ALTER TABLE hkpmi.patient_detail_1 OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
