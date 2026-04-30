-- hkpmi.system_permit definition

-- Drop table

-- DROP TABLE hkpmi.system_permit;

CREATE TABLE hkpmi.system_permit (
	source_system varchar(10) NOT NULL,
	func_name varchar(90) NOT NULL,
	update_by varchar(16) NOT NULL,
	system_dtm timestamp(6) NOT NULL,
	row_update_datetime timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKsystem_permit" ON hkpmi.system_permit USING btree (source_system, func_name);



ALTER TABLE hkpmi.system_permit OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
