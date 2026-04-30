-- imis definition

-- Drop table

-- DROP TABLE imis;

CREATE TABLE imis (
	imis_code varchar(6) NOT NULL,
	description varchar(48) NULL,
	eis_code varchar(6) NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKIMIS" PRIMARY KEY (imis_code) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE imis OWNER TO "HPI_SCHEMA_OWNER_ROLE";
