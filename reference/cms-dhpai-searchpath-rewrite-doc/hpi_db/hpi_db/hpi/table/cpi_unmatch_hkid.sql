-- cpi_unmatch_hkid definition

-- Drop table

-- DROP TABLE cpi_unmatch_hkid;

CREATE TABLE cpi_unmatch_hkid (
	hkid varchar(24) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_unmatch_hkid_idx ON cpi_unmatch_hkid USING btree (hkid);




ALTER TABLE cpi_unmatch_hkid OWNER TO "HPI_SCHEMA_OWNER_ROLE";
