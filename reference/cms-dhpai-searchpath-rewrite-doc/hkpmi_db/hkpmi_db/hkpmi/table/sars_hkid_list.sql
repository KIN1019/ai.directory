-- sars_hkid_list definition

-- Drop table

-- DROP TABLE sars_hkid_list;

CREATE TABLE sars_hkid_list (
	hkid varchar(24) NOT NULL,
	last_update_datetime timestamp(6) NULL
);

CREATE UNIQUE INDEX sars_hkid_index ON sars_hkid_list USING btree (hkid);

ALTER TABLE sars_hkid_list OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
