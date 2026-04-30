-- cpi_linked_case definition

-- Drop table

-- DROP TABLE cpi_linked_case;

CREATE TABLE cpi_linked_case (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	previous_hospital varchar(6) NOT NULL,
	previous_case varchar(24) NOT NULL,
	create_by varchar(24) NOT NULL,
	create_dtm timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL

	-- Remove "last_update_datetime" as there already exists "update_dtm"
	--last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_linked_case_idx ON cpi_linked_case USING btree (hospital_code, case_no, previous_hospital, previous_case);
CREATE INDEX cpi_linked_case_idx2 ON cpi_linked_case USING btree (previous_hospital, previous_case);
CREATE INDEX cpi_linked_case_idx3 ON cpi_linked_case USING btree (update_dtm);




ALTER TABLE cpi_linked_case OWNER TO "HPI_SCHEMA_OWNER_ROLE";
