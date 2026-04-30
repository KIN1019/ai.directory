-- hkpmi.move_episode_indicator_log definition

-- Drop table

-- DROP TABLE hkpmi.move_episode_indicator_log;

CREATE TABLE hkpmi.move_episode_indicator_log (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	create_dtm timestamp(6) NOT NULL,
	from_patient_key varchar(16) NULL,
	to_patient_key varchar(16) NULL,
	create_user varchar(24) NULL,
	create_system varchar(10) NULL,
	move_status varchar(2) NULL,
	update_dtm timestamp(6) NULL,
	update_user varchar(24) NULL,
	update_system varchar(10) NULL,
	info_source_code varchar(2) NULL,
	reason_code varchar(2) NULL,
	other_reason varchar(510) NULL
);
CREATE INDEX "XAK1move_episode_indicator_log" ON hkpmi.move_episode_indicator_log USING btree (from_patient_key);
CREATE INDEX "XAK2move_episode_indicator_log" ON hkpmi.move_episode_indicator_log USING btree (to_patient_key);
CREATE INDEX "XAK3move_episode_indicator_log" ON hkpmi.move_episode_indicator_log USING btree (update_dtm);
CREATE UNIQUE INDEX "XPKmove_episode_indicator_log" ON hkpmi.move_episode_indicator_log USING btree (hospital_code, case_no, create_dtm, update_dtm);




ALTER TABLE hkpmi.move_episode_indicator_log OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
