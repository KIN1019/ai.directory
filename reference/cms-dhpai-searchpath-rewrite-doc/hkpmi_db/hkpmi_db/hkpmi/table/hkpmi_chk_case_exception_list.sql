-- hkpmi.hkpmi_chk_case_exception_list definition

-- Drop table

-- DROP TABLE hkpmi.hkpmi_chk_case_exception_list;

CREATE TABLE hkpmi.hkpmi_chk_case_exception_list (
	case_hosp_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	case_adm_dtm timestamp(6) NOT NULL,
	caset_type varchar(2) NOT NULL,
	hkid varchar(24) NOT NULL,
	patient_dob timestamp(6) NULL,
	patient_exact_dob varchar(2) NOT NULL,
	exception_type varchar(10) NOT NULL,
	exception_flag varchar(2) NOT NULL,
	exception_eff_dtm timestamp(6) NOT NULL,
	exception_remarks varchar(510) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL
);
CREATE UNIQUE INDEX hkpmi_chk_case_exception_list_pky ON hkpmi.hkpmi_chk_case_exception_list USING btree (case_hosp_code, case_no, exception_eff_dtm);




ALTER TABLE hkpmi.hkpmi_chk_case_exception_list OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
