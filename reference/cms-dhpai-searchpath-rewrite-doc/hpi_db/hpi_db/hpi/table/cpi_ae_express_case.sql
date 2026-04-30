-- Drop table

-- DROP TABLE cpi_ae_express_case;

CREATE TABLE cpi_ae_express_case (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	ocsss_status varchar(20) NOT NULL,
	by_smart_id varchar(2) NULL,
	matched_hkpmi varchar(2) NULL,
	is_new_patient varchar(2) NULL,
	create_dtm timestamp NOT NULL,
	update_dtm timestamp NOT NULL,
	is_ae_reg varchar(2) DEFAULT 'N'::character varying NOT NULL,
	is_claimed_hkid varchar(2) DEFAULT 'N'::character varying NOT NULL,
	is_update_major_keys varchar(2) DEFAULT 'N'::character varying NOT NULL

	-- Remove "last_update_datetime" as there already exists "update_dtm"
	--last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_ae_express_case_idx ON cpi_ae_express_case USING btree (case_no, hospital_code);



ALTER TABLE cpi_ae_express_case OWNER TO "HPI_SCHEMA_OWNER_ROLE";