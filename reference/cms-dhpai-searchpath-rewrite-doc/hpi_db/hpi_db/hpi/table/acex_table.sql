-- acex_table definition

-- Drop table

-- DROP TABLE acex_table;

CREATE TABLE acex_table (
	acex_hosp varchar(6) NOT NULL,
	acex_month varchar(12) NOT NULL,
	acex_hkid varchar(24) NOT NULL,
	acex_case varchar(24) NOT NULL,
	acex_count varchar(12) NOT NULL,
	acex_spec varchar(6) NOT NULL,
	acex_los varchar(12) NOT NULL,
	acex_bdo varchar(12) NOT NULL,
	acex_dsch varchar(2) NOT NULL,
	acex_src_ind varchar(2) NOT NULL,
	acex_adm_src varchar(6) NOT NULL,
	acex_adm_date varchar(16) NOT NULL,
	acex_prev_dsch_date varchar(16) NOT NULL,
	acex_dsch_type varchar(2) NOT NULL,
	acex_to_home varchar(2) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX "acex_table_ui" ON acex_table USING btree (acex_hosp,acex_month,acex_hkid,acex_case,acex_count,acex_spec,acex_los,acex_bdo,acex_dsch,acex_src_ind,acex_adm_src,acex_adm_date,acex_prev_dsch_date,acex_dsch_type,acex_to_home);
CREATE UNIQUE INDEX acex_table_ui ON acex_table USING btree (record_id);

ALTER TABLE acex_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
