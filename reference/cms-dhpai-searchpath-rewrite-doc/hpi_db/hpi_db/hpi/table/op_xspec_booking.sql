-- op_xspec_booking definition

-- Drop table

-- DROP TABLE op_xspec_booking;

CREATE TABLE op_xspec_booking (
	op_xspec_ipas_code varchar(8) NOT NULL,
	op_xspec_op_code varchar(8) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "OP_XSPEC_BOOKING_IDX1" ON op_xspec_booking USING btree (op_xspec_ipas_code, op_xspec_op_code);




ALTER TABLE op_xspec_booking OWNER TO "HPI_SCHEMA_OWNER_ROLE";
