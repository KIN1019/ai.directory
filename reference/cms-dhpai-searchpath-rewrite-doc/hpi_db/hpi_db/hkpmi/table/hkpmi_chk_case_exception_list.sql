-- hkpmi_chk_case_exception_list definition

-- Drop table

-- DROP FOREIGN TABLE hkpmi_chk_case_exception_list;

CREATE FOREIGN TABLE hkpmi_chk_case_exception_list (
	case_hosp_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	case_adm_dtm timestamp NOT NULL,
	caset_type varchar(2) NOT NULL,
	hkid varchar(24) NOT NULL,
	patient_dob timestamp NULL,
	patient_exact_dob varchar(2) NOT NULL,
	exception_type varchar(10) NOT NULL,
	exception_flag varchar(2) NOT NULL,
	exception_eff_dtm timestamp NOT NULL,
	exception_remarks varchar(510) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp NOT NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'hkpmi_chk_case_exception_list');

ALTER TABLE hkpmi_chk_case_exception_list OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
