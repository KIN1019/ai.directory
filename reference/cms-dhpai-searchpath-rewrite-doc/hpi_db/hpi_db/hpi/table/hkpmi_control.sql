-- hkpmi_control definition

-- Drop table

-- DROP TABLE hkpmi_control;

CREATE TABLE hkpmi_control (
	hkpmi_server varchar NOT NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC

	--Remove the following column which did not exist in PRD Sybase (Aug-2025)
	--,schema_name varchar NULL
);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX hkpmi_control_ui ON hkpmi_control USING btree (hkpmi_server);
CREATE UNIQUE INDEX hkpmi_control_ui ON hkpmi_control USING btree (record_id);

ALTER TABLE hkpmi_control OWNER TO "HPI_SCHEMA_OWNER_ROLE";
