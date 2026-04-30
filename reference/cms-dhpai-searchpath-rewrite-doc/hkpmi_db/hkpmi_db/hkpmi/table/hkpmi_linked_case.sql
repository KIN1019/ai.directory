-- hkpmi.hkpmi_linked_case definition

-- Drop table

-- DROP TABLE hkpmi.hkpmi_linked_case;

CREATE TABLE hkpmi.hkpmi_linked_case (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	previous_hospital varchar(6) NOT NULL,
	previous_case varchar(24) NOT NULL,
	create_by varchar(24) NOT NULL,
	create_dtm timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL
);
CREATE UNIQUE INDEX hkpmi_linked_case_idx ON hkpmi.hkpmi_linked_case USING btree (hospital_code, case_no, previous_hospital, previous_case);
CREATE INDEX hkpmi_linked_case_idx2 ON hkpmi.hkpmi_linked_case USING btree (previous_hospital, previous_case);
CREATE INDEX hkpmi_linked_case_idx3 ON hkpmi.hkpmi_linked_case USING btree (update_dtm);




ALTER TABLE hkpmi.hkpmi_linked_case OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
