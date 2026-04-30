-- funded_isolation_type definition

-- Drop table

-- DROP TABLE funded_isolation_type;

CREATE TABLE funded_isolation_type (
	funded_isolation varchar(4) NULL,
	description varchar(160) NOT NULL,
	status varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX funded_isolation_index ON funded_isolation_type USING btree (funded_isolation);




ALTER TABLE funded_isolation_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
