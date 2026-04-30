-- ciwl_table definition

-- Drop table

-- DROP TABLE ciwl_table;

CREATE TABLE ciwl_table (
	hosp_code varchar(6) NOT NULL,
	spec_code varchar(8) NOT NULL,
	ciwl_ind varchar(2) NOT NULL,
	active_status varchar(2) NULL,
	eff_date timestamp(6) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX ciwl_index ON ciwl_table USING btree (hosp_code, spec_code, active_status, eff_date);




ALTER TABLE ciwl_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
