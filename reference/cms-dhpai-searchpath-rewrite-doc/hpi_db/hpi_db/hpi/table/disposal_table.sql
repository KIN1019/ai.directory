-- disposal_table definition

-- Drop table

-- DROP TABLE disposal_table;

CREATE TABLE disposal_table (
	hospital_code varchar(6) NOT NULL,
	hkid varchar(24) NOT NULL,
	"name" varchar(96) NOT NULL,
	mrn varchar(16) NULL,
	case_no varchar(24) NOT NULL,
	discharge_datetime timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX disposal_index ON disposal_table USING btree (hospital_code, hkid, case_no);




ALTER TABLE disposal_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
