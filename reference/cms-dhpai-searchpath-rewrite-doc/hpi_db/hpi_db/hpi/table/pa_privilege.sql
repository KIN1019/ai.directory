-- pa_privilege definition

-- Drop table

-- DROP TABLE pa_privilege;

CREATE TABLE pa_privilege (
	pa_ns_code varchar(8) NOT NULL,
	pa_specialty varchar(8) NOT NULL,
	pa_sub_specialty varchar(8) NOT NULL,
	pa_quota_type varchar(2) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "PA_PVLG_IDX1" ON pa_privilege USING btree (pa_ns_code, pa_specialty, pa_sub_specialty);
CREATE INDEX "PA_PVLG_IDX2" ON pa_privilege USING btree (pa_ns_code, pa_specialty);




ALTER TABLE pa_privilege OWNER TO "HPI_SCHEMA_OWNER_ROLE";
