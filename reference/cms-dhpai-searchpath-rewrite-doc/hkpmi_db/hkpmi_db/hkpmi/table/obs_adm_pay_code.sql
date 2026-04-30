-- hkpmi.obs_adm_pay_code definition

-- Drop table

-- DROP TABLE hkpmi.obs_adm_pay_code;

CREATE TABLE hkpmi.obs_adm_pay_code (
	mother_pay_code varchar(6) NOT NULL,
	baby_pay_code varchar(8) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX obs_adm_pay_code_index ON hkpmi.obs_adm_pay_code USING btree (mother_pay_code);




ALTER TABLE hkpmi.obs_adm_pay_code OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
