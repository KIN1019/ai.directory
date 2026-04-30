-- eh_cgat definition

-- Drop table

-- DROP TABLE eh_cgat;

CREATE TABLE eh_cgat (
	eh_code varchar(16) NOT NULL,
	cgat_hospital varchar(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX eh_cgat_index ON eh_cgat USING btree (eh_code);




ALTER TABLE eh_cgat OWNER TO "HPI_SCHEMA_OWNER_ROLE";
