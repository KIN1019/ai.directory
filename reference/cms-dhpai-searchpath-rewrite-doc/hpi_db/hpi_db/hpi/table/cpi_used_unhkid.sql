-- cpi_used_unhkid definition

-- Drop table

-- DROP TABLE cpi_used_unhkid;

CREATE TABLE cpi_used_unhkid (
	hkid varchar(24) NOT NULL,
	create_dtm timestamp(6) NOT NULL,
	block_type varchar(2) NULL,
	request_hosp varchar(6) NULL,
	request_by varchar(24) NULL,
	filler bpchar(50) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_used_hkid_idx ON cpi_used_unhkid USING btree (hkid);




ALTER TABLE cpi_used_unhkid OWNER TO "HPI_SCHEMA_OWNER_ROLE";
