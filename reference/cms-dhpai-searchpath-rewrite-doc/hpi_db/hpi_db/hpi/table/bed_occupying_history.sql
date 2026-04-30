-- bed_occupying_history definition

-- Drop table

-- DROP TABLE bed_occupying_history;

CREATE TABLE bed_occupying_history (
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	bed_no varchar(10) NOT NULL,
	bed_status varchar(2) NOT NULL,
	effective_datetime timestamp(6) NOT NULL,
	case_no varchar(24) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX bed_occ_history_index ON bed_occupying_history USING btree (hospital_code, ward_code, bed_no, effective_datetime, case_no, bed_status);




ALTER TABLE bed_occupying_history OWNER TO "HPI_SCHEMA_OWNER_ROLE";
