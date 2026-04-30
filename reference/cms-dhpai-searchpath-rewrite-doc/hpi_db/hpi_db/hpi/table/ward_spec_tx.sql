-- ward_spec_tx definition

-- Drop table

-- DROP TABLE ward_spec_tx;

CREATE TABLE ward_spec_tx (
	hospital_code varchar(6) NOT NULL,
	ward_spec_tx_date timestamp(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	specialty_code varchar(8) NOT NULL,
	treatment_location varchar(8) NULL,
	previous_remaining int2 NOT NULL,
	admission int2 NOT NULL,
	discharge int2 NOT NULL,
	transfer_in int2 NOT NULL,
	transfer_out int2 NOT NULL,
	death int2 NOT NULL,
	day_discharge int2 NOT NULL,
	day_death int2 NOT NULL,
	admission_thru_ae int2 NOT NULL,
	transfer_in_from_td int2 NOT NULL,
	transfer_out_to_td int2 NOT NULL,
	ae_day_discharge int2 NOT NULL,
	ae_day_death int2 NOT NULL,
	transfer_within_specialty int2 NOT NULL,
	transfer_within_ward int2 NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XIE1Ward_spec_tx" ON ward_spec_tx USING btree (hospital_code, ward_code, specialty_code, treatment_location, ward_spec_tx_date);
CREATE UNIQUE INDEX "XPKWard_spec_tx" ON ward_spec_tx USING btree (hospital_code, ward_spec_tx_date, ward_code, specialty_code, treatment_location);




ALTER TABLE ward_spec_tx OWNER TO "HPI_SCHEMA_OWNER_ROLE";
