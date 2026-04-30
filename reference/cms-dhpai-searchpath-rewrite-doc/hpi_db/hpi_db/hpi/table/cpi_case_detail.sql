-- cpi_case_detail definition

-- Drop table

-- DROP TABLE cpi_case_detail;

CREATE TABLE cpi_case_detail (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	reference varchar(40) NULL,
	document_flag varchar(2) NULL,
	eh_code varchar(16) NULL,
	case_flag1 varchar(2) NULL,
	case_flag2 varchar(2) NULL,
	case_code1 varchar(16) NULL,
	case_code2 varchar(16) NULL,
	case_filler varchar(96) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_case_detail_idx ON cpi_case_detail USING btree (case_no, hospital_code);




ALTER TABLE cpi_case_detail OWNER TO "HPI_SCHEMA_OWNER_ROLE";
