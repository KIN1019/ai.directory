-- op_ward_privilege definition

-- Drop table

-- DROP TABLE op_ward_privilege;

CREATE TABLE op_ward_privilege (
	op_ns_code varchar(8) NOT NULL,
	op_specialty varchar(8) NOT NULL,
	op_sub_specialty varchar(8) NOT NULL,
	op_quota_type varchar(2) NOT NULL,
	op_priv_level varchar(2) NOT NULL,
	op_booking_type varchar(2) NULL,
	op_sub_spec_longdescr varchar(32) NULL,
	op_sub_spec_shortdescr varchar(16) NULL,
	op_sub_spec_description varchar(60) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "WARD_PVLG_IDX1" ON op_ward_privilege USING btree (op_ns_code, op_specialty, op_sub_specialty);
CREATE INDEX "WARD_PVLG_IDX2" ON op_ward_privilege USING btree (op_ns_code, op_specialty);




ALTER TABLE op_ward_privilege OWNER TO "HPI_SCHEMA_OWNER_ROLE";
