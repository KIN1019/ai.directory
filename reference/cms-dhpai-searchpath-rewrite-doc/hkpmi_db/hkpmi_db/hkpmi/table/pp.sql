-- hkpmi.pp definition

-- Drop table

-- DROP TABLE hkpmi.pp;

CREATE TABLE hkpmi.pp (
	pp_code varchar(16) NOT NULL,
	pp_name varchar(96) NOT NULL,
	room varchar(10) NULL,
	floor varchar(4) NULL,
	block varchar(4) NULL,
	building varchar(94) NULL,
	district_code varchar(10) NULL,
	phone varchar(20) NULL,
	fax_no varchar(20) NULL,
	email_address varchar(96) NULL,
	remarks varchar(160) NULL,
	hkma_code varchar(2) NULL,
	expiry_date timestamp(6) NULL,
	last_name varchar(160) NULL,
	first_name varchar(160) NULL,
	chinese_name varchar(24) NULL,
	address_1 varchar(510) NULL,
	address_2 varchar(510) NULL,
	address_3 varchar(510) NULL,
	address_4 varchar(510) NULL,
	chinese_address varchar(510) NULL,
	office_phone varchar(96) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKpp" ON hkpmi.pp USING btree (pp_code);




ALTER TABLE hkpmi.pp OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
