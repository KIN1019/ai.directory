-- patient_type definition

-- Drop table

-- DROP TABLE patient_type;

CREATE TABLE patient_type (
	patient_type varchar(6) NOT NULL,
	description varchar(160) NOT NULL,
	effective_dtm timestamp(6) NULL,
	patient_group varchar(10) NULL,
	pay_code_type varchar(10) NULL,
	active_status varchar(2) NULL,
	user_define varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX patient_type_idx ON patient_type USING btree (patient_type, effective_dtm);




ALTER TABLE patient_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
