-- hago_rollout_control definition

-- Drop table

-- DROP TABLE hago_rollout_control;

CREATE TABLE hago_rollout_control (
	hospital_code varchar(6) NOT NULL,
	workstation_id varchar(60) NOT NULL,
	rollout_control_flag varchar(60) NOT NULL,
	description varchar(200) NULL,
	rollout_ready varchar(2) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_datetime timestamp(6) NOT NULL
);
CREATE UNIQUE INDEX hago_rollout_control_idx ON hago_rollout_control USING btree (hospital_code, workstation_id, rollout_control_flag);



ALTER TABLE hago_rollout_control OWNER TO "HPI_SCHEMA_OWNER_ROLE";
