-- exception_rpt_table definition

-- Drop table

-- DROP TABLE exception_rpt_table;

CREATE TABLE exception_rpt_table (
	hospital_code varchar(6) NOT NULL,
	specialty_code varchar(8) NOT NULL,
	from_age int4 NULL,
	from_age_unit varchar(4) NULL,
	to_age int4 NULL,
	to_age_unit varchar(4) NULL,
	sex varchar(2) NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX exception_rpt_table_ui ON exception_rpt_table USING btree (hospital_code, specialty_code, from_age, from_age_unit, to_age, to_age_unit, sex);
CREATE UNIQUE INDEX exception_rpt_table_ui ON exception_rpt_table USING btree (record_id);

ALTER TABLE exception_rpt_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
