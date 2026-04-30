-- cpi_ae_case_detail definition

-- Drop table

-- DROP TABLE cpi_ae_case_detail;

CREATE TABLE cpi_ae_case_detail (
	case_no varchar(24) NOT NULL,
	hospital_code varchar(6) NOT NULL,
	ambulance_no varchar(8) NULL,
	police_case varchar(2) NULL,
	labour_case_flag varchar(2) NULL,
	ae_case_type varchar(2) NULL,
	dba_flag varchar(2) NULL,
	follow_up_datetime timestamp(6) NULL,
	eh_code varchar(16) NULL,
	pp_code varchar(16) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_ae_case_detail_idx ON cpi_ae_case_detail USING btree (case_no, hospital_code);




ALTER TABLE cpi_ae_case_detail OWNER TO "HPI_SCHEMA_OWNER_ROLE";
