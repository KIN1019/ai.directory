-- address_detail_cx_down definition

-- Drop table

-- DROP TABLE address_detail_cx_down;

CREATE TABLE address_detail_cx_down (
	record_id int4 NOT NULL,
	bldg_chi varchar(200) NULL,
	bldg_eng varchar(400) NULL,
	estate_chi varchar(160) NULL,
	estate_eng varchar(200) NULL,
	house_no varchar(20) NULL,
	street_chi varchar(100) NULL,
	street_eng varchar(200) NULL,
	district_code varchar(10) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cx_down_address_detail_idx ON address_detail_cx_down USING btree (record_id);




ALTER TABLE address_detail_cx_down OWNER TO "HPI_SCHEMA_OWNER_ROLE";
