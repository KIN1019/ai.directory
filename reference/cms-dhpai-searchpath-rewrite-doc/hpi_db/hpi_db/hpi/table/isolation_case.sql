-- isolation_case definition

-- Drop table

-- DROP TABLE isolation_case;

CREATE TABLE isolation_case (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	movement_count int4 NOT NULL,
	iso_status varchar(4) NULL,
	update_datetime timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL
);
CREATE UNIQUE INDEX "XPKisolation_case" ON isolation_case USING btree (hospital_code, case_no, movement_count);




ALTER TABLE isolation_case OWNER TO "HPI_SCHEMA_OWNER_ROLE";
