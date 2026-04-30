-- hpi.ccc_unicode_view source

-- Sybase counterpart is "CCC_big5"

CREATE OR REPLACE VIEW hpi.ccc_unicode_view with(security_invoker = on)
AS SELECT ccc_head,
    ccc_tail,
    unicode_char,
    phonetic_text,
    unicode_int
   FROM hpi.ccc_unicode c;






ALTER TABLE ccc_unicode_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
