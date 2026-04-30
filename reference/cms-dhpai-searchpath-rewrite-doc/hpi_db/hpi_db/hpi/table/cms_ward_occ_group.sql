-- cms_ward_occ_group definition

-- Drop table

-- DROP TABLE cms_ward_occ_group;

CREATE TABLE cms_ward_occ_group (
	hosp_code varchar(8) NOT NULL,
	ward_occ_group varchar(8) NOT NULL,
	description varchar(100) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cms_ward_occ_group_idx1 ON cms_ward_occ_group USING btree (hosp_code, ward_occ_group);




ALTER TABLE cms_ward_occ_group OWNER TO "HPI_SCHEMA_OWNER_ROLE";
