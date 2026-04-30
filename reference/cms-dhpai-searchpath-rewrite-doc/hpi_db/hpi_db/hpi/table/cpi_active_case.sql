-- cpi_active_case definition

-- Drop table

-- DROP TABLE cpi_active_case;

CREATE TABLE cpi_active_case (
	hospital_code varchar(6) NOT NULL,
	active_indicator varchar(2) NOT NULL,
	case_no varchar(24) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX cpi_active_case_idx ON cpi_active_case USING btree (hospital_code, active_indicator, case_no);
CREATE UNIQUE INDEX cpi_active_case_idx2 ON cpi_active_case USING btree (hospital_code, case_no);




ALTER TABLE cpi_active_case OWNER TO "HPI_SCHEMA_OWNER_ROLE";
