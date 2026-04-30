-- hkpmi.pp_opt_out definition

-- Drop table

-- DROP TABLE hkpmi.pp_opt_out;

CREATE TABLE hkpmi.pp_opt_out (
	patient_key varchar(16) NOT NULL,
	request_type varchar(2) NOT NULL,
	effective_datetime timestamp(6) NOT NULL,
	request_hkid varchar(24) NULL,
	request_name varchar(96) NULL,
	request_sex varchar(2) NULL,
	request_phone varchar(20) NULL,
	request_relationship varchar(4) NULL,
	request_address varchar(510) NULL,
	request_datetime timestamp(6) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL
);
CREATE UNIQUE INDEX pp_opt_out_index ON hkpmi.pp_opt_out USING btree (patient_key, effective_datetime);




ALTER TABLE hkpmi.pp_opt_out OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
