-- cms_ward_occ_preference definition

-- Drop table

-- DROP TABLE cms_ward_occ_preference;

CREATE TABLE cms_ward_occ_preference (
	hosp_code varchar(8) NOT NULL,
	ward_occ_group varchar(8) NOT NULL,
	ward_code varchar(10) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cms_ward_occ_preference_idx1 ON cms_ward_occ_preference USING btree (hosp_code, ward_occ_group, ward_code);




ALTER TABLE cms_ward_occ_preference OWNER TO "HPI_SCHEMA_OWNER_ROLE";
