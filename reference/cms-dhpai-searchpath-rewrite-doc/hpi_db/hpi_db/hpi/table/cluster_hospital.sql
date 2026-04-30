-- cluster_hospital definition

-- Drop table

-- DROP TABLE cluster_hospital;

CREATE TABLE cluster_hospital (
	hospital_code varchar(6) NULL,
	english_name varchar(160) NULL,
	chinese_name varchar(160) NULL,
	"cluster" varchar(10) NULL,
	server_name varchar(40) NULL,
	db_name varchar(40) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cluster_hospital_index ON cluster_hospital USING btree (hospital_code);
CREATE INDEX hospital_cluster_index ON cluster_hospital USING btree (cluster, hospital_code);




ALTER TABLE cluster_hospital OWNER TO "HPI_SCHEMA_OWNER_ROLE";
