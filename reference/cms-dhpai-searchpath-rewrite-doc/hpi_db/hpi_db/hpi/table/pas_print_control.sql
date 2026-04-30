-- pas_print_control definition

-- Drop table

-- DROP TABLE pas_print_control;

CREATE TABLE pas_print_control (
	hosp_code varchar(6) NOT NULL,
	spec_code varchar(8) NULL,
	spec_imis varchar(6) NULL,
	ward_code varchar(8) NULL,
	ward_loc_code varchar(8) NULL,
	eff_dtm timestamp(6) NOT NULL,
	ws_id varchar(24) NULL,
	hn_print_format varchar(16) NULL,
	hn_label_set int2 NULL,
	num_of_hn_full_label int2 NULL,
	num_of_hn_partial_label int2 NULL,
	num_of_hn_barcode_label int2 NULL,
	num_of_hn_med_cert_label int2 NULL,
	num_of_hn_without_hkid_label int2 NULL,
	num_of_hn_document_label int2 NULL,
	num_of_hn_name_label int2 NULL,
	num_of_hn_case_label int2 NULL,
	num_of_hn_specimen_label int2 NULL,
	priority_hn_full_label int2 NULL,
	priority_hn_partial_label int2 NULL,
	priority_hn_barcode_label int2 NULL,
	priority_hn_med_cert_label int2 NULL,
	priority_hn_without_hkid_label int2 NULL,
	priority_hn_document_label int2 NULL,
	priority_hn_name_label int2 NULL,
	priority_hn_case_label int2 NULL,
	priority_hn_specimen_label int2 NULL,
	wb_print_format varchar(16) NULL,
	wb_label_set int2 NULL,
	num_of_hn_wb_adult int2 NULL,
	num_of_hn_wb_child int2 NULL,
	num_of_ae_wb_adult int2 NULL,
	num_of_ae_wb_child int2 NULL,
	update_by varchar(24) NOT NULL,
	update_sys varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL
);
CREATE UNIQUE INDEX "XPKpas_print_control" ON pas_print_control USING btree (hosp_code, spec_code, eff_dtm);




ALTER TABLE pas_print_control OWNER TO "HPI_SCHEMA_OWNER_ROLE";
