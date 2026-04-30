-- func_table definition

-- Drop table

-- DROP TABLE func_table;

CREATE TABLE func_table (
	func_id int4 NOT NULL,
	func_description varchar(80) NOT NULL,
	func_win_1 varchar(80) NOT NULL,
	func_win_2 varchar(80) NULL,
	func_win_3 varchar(80) NULL,
	func_win_4 varchar(80) NULL,
	func_win_5 varchar(80) NULL,
	func_win_6 varchar(80) NULL,
	func_win_7 varchar(80) NULL,
	func_win_8 varchar(80) NULL,
	func_win_9 varchar(80) NULL,
	func_win_10 varchar(80) NULL,
	func_tx_id int4 NULL,
	access_code int4 NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKFunc_table" PRIMARY KEY (func_id) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE func_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
