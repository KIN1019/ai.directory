-- pp_consent_fax definition

-- Drop table

-- DROP TABLE pp_consent_fax;

CREATE TABLE pp_consent_fax (
	pp_code varchar(16) NOT NULL,
	hospital_code varchar(6) NULL,
	cluster_code varchar(10) NULL,
	consent_start_date timestamp(6) NOT NULL,
	consent_end_date timestamp(6) NULL,
	update_by varchar(24) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	update_datetime timestamp(6) NOT NULL
);
CREATE UNIQUE INDEX pp_consent_fax_idx ON pp_consent_fax USING btree (pp_code, hospital_code, cluster_code, consent_start_date);




ALTER TABLE pp_consent_fax OWNER TO "HPI_SCHEMA_OWNER_ROLE";
