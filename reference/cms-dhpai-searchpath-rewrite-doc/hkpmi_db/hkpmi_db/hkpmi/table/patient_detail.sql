-- patient_detail definition

-- Drop table

-- DROP TABLE patient_detail;

CREATE TABLE patient_detail (
	patient_key varchar(16) NOT NULL,
	blood_group varchar(4) NULL,
	blood_rh_factor varchar(2) NULL,
	blood_transfusion_reaction varchar(2) NULL,
	non_classfied_1 varchar(10) NULL,
	non_classfied_2 varchar(10) NULL,
	non_classfied_3 varchar(10) NULL,
	non_classfied_4 varchar(10) NULL,
	non_classfied_5 varchar(10) NULL,
	non_classfied_6 varchar(10) NULL,
	non_classfied_7 varchar(10) NULL,
	non_classfied_8 varchar(10) NULL,
	non_classfied_9 varchar(10) NULL,
	non_classfied_10 varchar(10) NULL,
	classfied_1 varchar(10) NULL,
	classfied_2 varchar(10) NULL,
	classfied_3 varchar(10) NULL,
	classfied_4 varchar(10) NULL,
	classfied_5 varchar(10) NULL,
	classfied_6 varchar(10) NULL,
	classfied_7 varchar(10) NULL,
	classfied_8 varchar(10) NULL,
	classfied_9 varchar(10) NULL,
	classfied_10 varchar(10) NULL,
	source_system_dtm timestamp NOT NULL,
	update_by varchar(16) NOT NULL,
	last_update_datetime timestamp(6) NULL
);

CREATE UNIQUE INDEX "XPKpatient_detail" ON patient_detail USING btree (patient_key);

ALTER TABLE patient_detail OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

