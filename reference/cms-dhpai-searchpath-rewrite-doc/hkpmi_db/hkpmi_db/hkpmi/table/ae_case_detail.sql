-- hkpmi.ae_case_detail definition

-- Drop table

-- DROP TABLE hkpmi.ae_case_detail;

CREATE TABLE hkpmi.ae_case_detail (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	ambulance_no varchar(8) NULL,
	police_case varchar(2) NULL,
	labour_case varchar(2) NULL,
	ae_case_type varchar(2) NULL,
	dba varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKae_case_detail" ON hkpmi.ae_case_detail USING btree (hospital_code, case_no);


ALTER TABLE hkpmi.ae_case_detail OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
