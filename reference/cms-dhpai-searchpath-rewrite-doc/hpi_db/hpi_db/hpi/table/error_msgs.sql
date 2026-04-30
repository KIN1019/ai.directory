-- error_msgs definition

-- Drop table

-- DROP TABLE error_msgs;

CREATE TABLE error_msgs (
	error_code int4 NOT NULL,
	messages varchar(510) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKerror_msgs" PRIMARY KEY (error_code) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE error_msgs OWNER TO "HPI_SCHEMA_OWNER_ROLE";
