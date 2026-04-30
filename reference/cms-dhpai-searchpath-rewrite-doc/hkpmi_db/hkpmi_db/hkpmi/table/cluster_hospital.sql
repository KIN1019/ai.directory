-- hkpmi.cluster_hospital definition

-- Drop table

-- DROP TABLE hkpmi.cluster_hospital;

CREATE TABLE hkpmi.cluster_hospital (
	hospital_code varchar(6) NOT NULL,
	english_name varchar(160) NOT NULL,
	chinese_name varchar(160) NOT NULL,
	"cluster" varchar(10) NOT NULL,
	server_name varchar(40) NOT NULL,
	db_name varchar(40) NOT NULL,
	chinese_address varchar(510) NULL,
	english_address varchar(510) NULL,
	phone_number varchar(20) NULL,
	fax_number varchar(20) NULL,
	hospital_type varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cluster_hospital_index ON hkpmi.cluster_hospital USING btree (hospital_code);
CREATE INDEX hospital_cluster_index ON hkpmi.cluster_hospital USING btree (cluster, hospital_code);




ALTER TABLE hkpmi.cluster_hospital OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
