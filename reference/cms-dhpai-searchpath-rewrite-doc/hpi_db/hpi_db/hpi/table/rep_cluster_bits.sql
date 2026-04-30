-- rep_cluster_bits definition

-- Drop table

-- DROP TABLE rep_cluster_bits;

CREATE TABLE rep_cluster_bits (
	hospital_code varchar(6) NOT NULL,
	cluster_hosp varchar(6) NOT NULL,
	bit_value int4 NOT NULL,
	class_catg varchar(4) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX rep_cluster_bits_idx ON rep_cluster_bits USING btree (hospital_code);




ALTER TABLE rep_cluster_bits OWNER TO "HPI_SCHEMA_OWNER_ROLE";
