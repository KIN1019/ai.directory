-- hkpmi.hkpmi_used_unhkid definition

-- Drop table

-- DROP TABLE hkpmi.hkpmi_used_unhkid;

CREATE TABLE hkpmi.hkpmi_used_unhkid (
	hkid varchar(24) NOT NULL,
	create_dtm timestamp(6) NOT NULL,
	block_type varchar(2) NULL,
	request_hosp varchar(6) NULL,
	request_by varchar(24) NULL,
	filler bpchar(50) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX hkpmi_used_hkid_idx ON hkpmi.hkpmi_used_unhkid USING btree (hkid);




ALTER TABLE hkpmi.hkpmi_used_unhkid OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
