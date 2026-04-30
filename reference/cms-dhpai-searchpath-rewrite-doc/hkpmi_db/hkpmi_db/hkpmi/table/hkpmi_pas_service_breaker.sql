-- hkpmi.hkpmi_pas_service_breaker definition

-- Drop table

-- DROP TABLE hkpmi.hkpmi_pas_service_breaker;

CREATE TABLE hkpmi.hkpmi_pas_service_breaker (
	hospital_code varchar(10) NOT NULL,
	database_type varchar(20) NOT NULL,
	project_id varchar(100) NOT NULL,
	service_type varchar(40) NOT NULL,
	service_name varchar(100) NOT NULL,
	service_feature varchar(100) NULL,
	"enable" varchar(2) NOT NULL,
	create_by varchar(24) NOT NULL,
	create_datetime timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_datetime timestamp(6) NOT NULL
);
CREATE UNIQUE INDEX hkpmi_pas_service_breaker_idx ON hkpmi.hkpmi_pas_service_breaker USING btree (hospital_code, project_id, service_name, service_feature);




ALTER TABLE hkpmi.hkpmi_pas_service_breaker OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
