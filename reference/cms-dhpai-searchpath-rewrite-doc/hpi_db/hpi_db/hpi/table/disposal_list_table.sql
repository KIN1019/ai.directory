-- disposal_list_table definition

-- Drop table

-- DROP TABLE disposal_list_table;

CREATE TABLE disposal_list_table (
	hospital_code varchar(6) NOT NULL,
	hkid varchar(24) NOT NULL,
	"name" varchar(96) NOT NULL,
	mrn varchar(16) NULL,
	case_no varchar(24) NOT NULL,
	discharge_datetime timestamp(6) NOT NULL,
	disposal_date timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX disposal_list_index ON disposal_list_table USING btree (hospital_code, case_no, hkid);




ALTER TABLE disposal_list_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
