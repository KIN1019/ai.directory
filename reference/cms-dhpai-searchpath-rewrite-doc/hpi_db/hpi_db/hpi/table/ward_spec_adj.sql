-- ward_spec_adj definition

-- Drop table

-- DROP TABLE ward_spec_adj;

CREATE TABLE ward_spec_adj (
	hospital_code varchar(6) NOT NULL,
	ward_spec_adj_date timestamp(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	specialty_code varchar(8) NOT NULL,
	treatment_location varchar(8) NULL,
	canc_admission int2 NOT NULL,
	canc_discharge int2 NOT NULL,
	canc_transfer_in int2 NOT NULL,
	canc_transfer_out int2 NOT NULL,
	canc_death int2 NOT NULL,
	canc_day_discharge int2 NOT NULL,
	canc_day_death int2 NOT NULL,
	canc_admission_thru_ae int2 NOT NULL,
	canc_transfer_in_from_td int2 NOT NULL,
	canc_transfer_out_to_td int2 NOT NULL,
	canc_ae_day_discharge int2 NOT NULL,
	canc_ae_day_death int2 NOT NULL,
	canc_transfer_within_specialty int2 NOT NULL,
	canc_transfer_within_ward int2 NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKWard_spec_adj" ON ward_spec_adj USING btree (hospital_code, ward_spec_adj_date, ward_code, specialty_code, treatment_location);




ALTER TABLE ward_spec_adj OWNER TO "HPI_SCHEMA_OWNER_ROLE";
