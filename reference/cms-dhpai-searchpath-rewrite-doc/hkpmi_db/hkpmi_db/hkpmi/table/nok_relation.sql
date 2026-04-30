-- hkpmi.nok_relation definition

-- Drop table

-- DROP TABLE hkpmi.nok_relation;

CREATE TABLE hkpmi.nok_relation (
	nok_relation_code varchar(4) NOT NULL,
	description varchar(160) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKnok_relation" ON hkpmi.nok_relation USING btree (nok_relation_code);




ALTER TABLE hkpmi.nok_relation OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
