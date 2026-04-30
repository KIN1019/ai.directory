-- comp_doc_spec definition

-- Drop table

-- DROP TABLE comp_doc_spec;

CREATE TABLE comp_doc_spec (
	hosp_code varchar(6) NOT NULL,
	spec varchar(8) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "COMP_DOC_SPEC_IDX1" ON comp_doc_spec USING btree (hosp_code, spec);




ALTER TABLE comp_doc_spec OWNER TO "HPI_SCHEMA_OWNER_ROLE";
