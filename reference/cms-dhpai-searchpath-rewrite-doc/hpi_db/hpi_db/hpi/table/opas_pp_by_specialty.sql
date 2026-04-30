-- opas_pp_by_specialty definition

-- Drop table

-- DROP TABLE opas_pp_by_specialty;

CREATE TABLE opas_pp_by_specialty (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	specialty varchar(8) NOT NULL,
	pp_code varchar(16) NULL,
	create_by varchar(16) NOT NULL,
	create_datetime timestamp(6) NOT NULL,
	update_by varchar(16) NOT NULL,
	update_datetime timestamp(6) NOT NULL
);
CREATE UNIQUE INDEX "IDX_opas_pp_by_specialty" ON opas_pp_by_specialty USING btree (hospital_code, case_no, specialty);




ALTER TABLE opas_pp_by_specialty OWNER TO "HPI_SCHEMA_OWNER_ROLE";
