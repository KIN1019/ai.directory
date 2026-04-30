-- hkpmi.pmi_reg_exception definition

-- Drop table

-- DROP TABLE hkpmi.pmi_reg_exception;

CREATE TABLE hkpmi.pmi_reg_exception (
	hkid varchar(24) NOT NULL,
	hospital_code varchar(6) NOT NULL,
	source_system_dtm timestamp(6) NOT NULL,
	source_system varchar(10) NOT NULL,
	exception_dtm timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKpmi_reg_exception" ON hkpmi.pmi_reg_exception USING btree (hkid, hospital_code, source_system_dtm);



ALTER TABLE hkpmi.pmi_reg_exception OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
