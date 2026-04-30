-- "source" definition

-- Drop table

-- DROP TABLE "source";

CREATE TABLE "source" (
	source_indicator varchar(2) NOT NULL,
	description varchar(100) NOT NULL,
	get_opas_appt_info varchar(2) DEFAULT 'N'::character varying NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX source_idx ON source USING btree (source_indicator);




ALTER TABLE source OWNER TO "HPI_SCHEMA_OWNER_ROLE";
