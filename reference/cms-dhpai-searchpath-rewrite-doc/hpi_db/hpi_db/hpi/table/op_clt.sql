-- op_clt definition

-- Drop table

-- DROP TABLE op_clt;

CREATE TABLE op_clt (
	hospital varchar(6) NOT NULL,
	specialty varchar(8) NOT NULL,
	sub_specialty varchar(8) NOT NULL,
	specialty_desc varchar(60) NOT NULL,
	sub_spec_desc varchar(60) NOT NULL,
	eis_service_type varchar(8) NOT NULL,
	eis_specialty varchar(8) NULL,
	eis_sub_specialty varchar(20) NULL,
	effective_date timestamp(6) NOT NULL,
	expiry_date timestamp(6) NULL,
	system_type varchar(2) NOT NULL,
	status varchar(2) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	update_by varchar(16) NOT NULL
);
CREATE UNIQUE INDEX clt_index1 ON op_clt USING btree (specialty, sub_specialty, hospital, effective_date);



ALTER TABLE op_clt OWNER TO "HPI_SCHEMA_OWNER_ROLE";
