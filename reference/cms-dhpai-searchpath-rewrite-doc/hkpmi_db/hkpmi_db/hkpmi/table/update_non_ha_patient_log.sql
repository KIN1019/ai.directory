-- hkpmi.update_non_ha_patient_log definition

-- Drop table

-- DROP TABLE hkpmi.update_non_ha_patient_log;

CREATE TABLE hkpmi.update_non_ha_patient_log (
	hospital_code varchar(6) NOT NULL,
	patient_key varchar(16) NOT NULL,
	adm_booking_dtm timestamp(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	status varchar(40) NOT NULL,
	update_datetime timestamp(6) NOT NULL
);
CREATE UNIQUE INDEX update_non_ha_patient_log_idx ON hkpmi.update_non_ha_patient_log USING btree (patient_key, hospital_code, case_no, update_datetime);



ALTER TABLE hkpmi.update_non_ha_patient_log OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
