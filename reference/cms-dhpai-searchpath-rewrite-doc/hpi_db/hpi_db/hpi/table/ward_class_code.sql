-- ward_class_code definition

-- Drop table

-- DROP TABLE ward_class_code;

/*
The PostgreSQL table "ward_class_code" is mapped to the Sybase table "Ward_class", because there's another Sybase table "ward_class" with the same name in lowercase, 
so the table is renamed in PostgreSQL.
*/
CREATE TABLE ward_class_code (
	ward_class varchar(2) NOT NULL,
	description varchar(100) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKWard_class" PRIMARY KEY (ward_class) DEFERRABLE INITIALLY DEFERRED
);

ALTER TABLE ward_class_code OWNER TO "HPI_SCHEMA_OWNER_ROLE";
