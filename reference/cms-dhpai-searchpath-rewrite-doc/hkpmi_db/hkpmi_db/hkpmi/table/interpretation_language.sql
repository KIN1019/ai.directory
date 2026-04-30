-- hkpmi.interpretation_language definition

-- Drop table

-- DROP TABLE hkpmi.interpretation_language;

CREATE TABLE hkpmi.interpretation_language (
	language_code varchar(10) NOT NULL,
	"language" varchar(100) NOT NULL,
	expiry_date timestamp(6) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX interpretation_language_idx ON hkpmi.interpretation_language USING btree (language_code);




ALTER TABLE hkpmi.interpretation_language OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
