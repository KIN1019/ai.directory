-- obs_adm_pay_code definition

-- Drop table

-- DROP TABLE obs_adm_pay_code;

CREATE TABLE obs_adm_pay_code (
	mother_pay_code varchar(6) NOT NULL,
	baby_pay_code varchar(8) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX obs_adm_pay_code_index ON obs_adm_pay_code USING btree (mother_pay_code);




ALTER TABLE obs_adm_pay_code OWNER TO "HPI_SCHEMA_OWNER_ROLE";
