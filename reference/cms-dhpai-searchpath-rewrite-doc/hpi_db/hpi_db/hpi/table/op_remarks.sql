-- op_remarks definition

-- Drop table

-- DROP TABLE op_remarks;

CREATE TABLE op_remarks (
	op_rmk_code varchar(6) NOT NULL,
	op_booking_type varchar(8) NULL,
	op_rmk_description varchar(20) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "OP_REMARKS_IDX1" ON op_remarks USING btree (op_rmk_code);




ALTER TABLE op_remarks OWNER TO "HPI_SCHEMA_OWNER_ROLE";
