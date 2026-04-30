-- ipas_revamp_info definition

-- Drop table

-- DROP TABLE ipas_revamp_info;

CREATE TABLE ipas_revamp_info (
	hospital_code varchar(6) NOT NULL,
	func_id int4 NOT NULL,
	func_description varchar(510) NOT NULL,
	rollout_type varchar(4) NOT NULL,
	rollout_dtm_schedule timestamp(6) NOT NULL,
	rollout_dtm_exact timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX ipas_revamp_info_idx ON ipas_revamp_info USING btree (hospital_code, func_id);




ALTER TABLE ipas_revamp_info OWNER TO "HPI_SCHEMA_OWNER_ROLE";
