-- division definition

-- Drop table

-- DROP TABLE division;

CREATE TABLE division (
	d_specialty varchar(8) NOT NULL,
	div_code varchar(16) NOT NULL,
	div_desc varchar(60) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "DIV_IDX1" ON division USING btree (d_specialty, div_code);




ALTER TABLE division OWNER TO "HPI_SCHEMA_OWNER_ROLE";
