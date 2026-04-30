-- hkpmi.unmatch_hkid definition

-- Drop table

-- DROP TABLE hkpmi.unmatch_hkid;

CREATE TABLE hkpmi.unmatch_hkid (
	hkid varchar(24) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKunmatch_hkid" ON hkpmi.unmatch_hkid USING btree (hkid);


ALTER TABLE hkpmi.unmatch_hkid OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
