-- hkpmi.move_episode_code_table definition

-- Drop table

-- DROP TABLE hkpmi.move_episode_code_table;

CREATE TABLE hkpmi.move_episode_code_table (
	"type" varchar(100) NOT NULL,
	code varchar(2) NOT NULL,
	description varchar(510) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKmove_episode_code_table" ON hkpmi.move_episode_code_table USING btree (type, code);




ALTER TABLE hkpmi.move_episode_code_table OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
