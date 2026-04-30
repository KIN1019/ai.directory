CREATE OR REPLACE PROCEDURE opas_cpi_ccc_to_chi_name(INOUT pas_return_code int, IN par_ccc1 VARCHAR, IN par_ccc2 VARCHAR, IN par_ccc3 VARCHAR, IN par_ccc4 VARCHAR, IN par_ccc5 VARCHAR, IN par_ccc6 VARCHAR, INOUT par_chi_name VARCHAR, INOUT par_return_code INTEGER, INOUT par_return_msg VARCHAR)
AS 
$BODY$
/* 2009-05-05 Shelley SMR20017336 Get the Chi Name from CCCode */
DECLARE
    var_big51 VARCHAR(4);
    var_big52 VARCHAR(4);
    var_big53 VARCHAR(4);
    var_big54 VARCHAR(4);
    var_big55 VARCHAR(4);
    var_big56 VARCHAR(4);
BEGIN
    CALL opas_cpi_ccc_to_big5(par_ccc1, var_big51, par_return_code, par_return_msg);

    IF par_return_code <> 0 THEN
        pas_return_code := 0;
        RETURN;
    END IF;
    CALL opas_cpi_ccc_to_big5(par_ccc2, var_big52, par_return_code, par_return_msg);

    IF par_return_code <> 0 THEN
        pas_return_code := 0;
        RETURN;
    END IF;
    CALL opas_cpi_ccc_to_big5(par_ccc3, var_big53, par_return_code, par_return_msg);

    IF par_return_code <> 0 THEN
        pas_return_code := 0;
        RETURN;
    END IF;
    CALL opas_cpi_ccc_to_big5(par_ccc4, var_big54, par_return_code, par_return_msg);

    IF par_return_code <> 0 THEN
        pas_return_code := 0;
        RETURN;
    END IF;
    CALL opas_cpi_ccc_to_big5(par_ccc5, var_big55, par_return_code, par_return_msg);

    IF par_return_code <> 0 THEN
        pas_return_code := 0;
        RETURN;
    END IF;
    CALL opas_cpi_ccc_to_big5(par_ccc6, var_big56, par_return_code, par_return_msg);

    IF par_return_code <> 0 THEN
        pas_return_code := 0;
        RETURN;
    END IF;
    SELECT
        CONCAT(var_big51, var_big52, var_big53, var_big54, var_big55, var_big56)
        INTO par_chi_name;
END;
$BODY$
LANGUAGE plpgsql;