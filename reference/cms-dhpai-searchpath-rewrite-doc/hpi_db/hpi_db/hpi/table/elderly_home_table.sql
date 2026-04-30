-- elderly_home_table definition

-- Drop table

-- DROP TABLE elderly_home_table;

CREATE TABLE elderly_home_table (
	eh_code varchar(16) NOT NULL,
	eh_name varchar(510) NULL,
	eh_chinese_name varchar(510) NULL,
	eh_address varchar(510) NULL,
	eh_building varchar(94) NULL,
	eh_room varchar(10) NULL,
	eh_floor varchar(4) NULL,
	eh_block varchar(4) NULL,
	eh_district_code varchar(10) NULL,
	eh_expiry_date timestamp(6) NULL,
	eh_district varchar(80) NULL,
	eh_phone varchar(20) NULL,
	eh_address_id int4 NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX eh_address_id_idx ON elderly_home_table USING btree (eh_address_id);
CREATE UNIQUE INDEX elderly_home_idx ON elderly_home_table USING btree (eh_code);




ALTER TABLE elderly_home_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
