CREATE TABLE control_point_code_table(
    code VARCHAR(6) NOT NULL,
    eng_desc VARCHAR(200) NOT NULL,
    chi_desc VARCHAR(200) NOT NULL,
    last_update_datetime timestamp(6) NULL
);

CREATE UNIQUE INDEX control_point_code_table_idx ON control_point_code_table USING btree (code);

ALTER TABLE control_point_code_table OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";