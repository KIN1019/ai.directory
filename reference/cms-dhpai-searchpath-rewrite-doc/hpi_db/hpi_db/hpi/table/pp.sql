-- pp definition

-- Drop table

-- DROP TABLE pp;

CREATE TABLE pp (
	pp_code varchar(16) NOT NULL,
	pp_name varchar(96) NOT NULL,
	room varchar(10) NULL,
	floor varchar(4) NULL,
	block varchar(4) NULL,
	building varchar(94) NULL,
	district_code varchar(10) NULL,
	phone varchar(20) NULL,
	fax_no varchar(20) NULL,
	email_address varchar(48) NULL,
	remarks varchar(80) NULL,
	hkma_code varchar(2) NULL,
	expiry_date timestamp(6) NULL,
	last_name varchar(80) NULL,
	first_name varchar(80) NULL,
	chinese_name varchar(12) NULL,
	address_1 varchar(255) NULL,
	address_2 varchar(255) NULL,
	address_3 varchar(255) NULL,
	address_4 varchar(255) NULL,
	chinese_address varchar(255) NULL,
	office_phone varchar(48) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX pp_idx ON pp USING btree (pp_code);




ALTER TABLE pp OWNER TO "HPI_SCHEMA_OWNER_ROLE";
