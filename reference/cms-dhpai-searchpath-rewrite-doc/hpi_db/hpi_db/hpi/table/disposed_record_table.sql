-- disposed_record_table definition

-- Drop table

-- DROP TABLE disposed_record_table;

CREATE TABLE disposed_record_table (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	disposal_date timestamp(6) NOT NULL,
	user_id varchar(24) NOT NULL,
	update_datetime timestamp(6) NULL,
	source_system varchar(24) NULL
);
CREATE UNIQUE INDEX disposed_record_index ON disposed_record_table USING btree (hospital_code, case_no);




ALTER TABLE disposed_record_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
