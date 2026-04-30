-- hago_close_reason_list definition

-- Drop table

-- DROP TABLE hago_close_reason_list;

CREATE TABLE hago_close_reason_list (
	reason_code varchar(6) NULL,
	hago_close_reason_code varchar(6) NULL,
	reason_description varchar(400) NULL,
	input_remark int4 NOT NULL,
	patient_type varchar(2) NULL,
	status varchar(6) NULL,
	order_no int4 NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX pk_hago_close_reason_list ON hago_close_reason_list USING btree (reason_code);




ALTER TABLE hago_close_reason_list OWNER TO "HPI_SCHEMA_OWNER_ROLE";
