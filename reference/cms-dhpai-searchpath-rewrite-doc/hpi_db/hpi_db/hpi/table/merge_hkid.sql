-- merge_hkid definition

-- Drop table

-- DROP TABLE merge_hkid;

CREATE TABLE merge_hkid (
	hospital_code varchar(6) NOT NULL,
	from_hkid varchar(24) NOT NULL,
	to_hkid varchar(24) NOT NULL,
	message varchar(80) NULL,
	requested_user_id varchar(16) NOT NULL,
	requested_datetime timestamp(6) NOT NULL,
	user_id varchar(16) NOT NULL,
	system_datetime timestamp(6) NOT NULL,
	row_update_datetime timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKMerge_HKID" PRIMARY KEY (hospital_code, from_hkid) DEFERRABLE INITIALLY DEFERRED
);



ALTER TABLE merge_hkid OWNER TO "HPI_SCHEMA_OWNER_ROLE";
