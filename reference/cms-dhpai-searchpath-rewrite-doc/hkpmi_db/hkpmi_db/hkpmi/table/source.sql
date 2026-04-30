-- hkpmi."source" definition

-- Drop table

-- DROP TABLE hkpmi."source";

CREATE TABLE hkpmi."source" (
	source_indicator varchar(2) NULL,
	description varchar(100) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKsource" ON hkpmi."source" USING btree (source_indicator);




ALTER TABLE hkpmi."source" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
