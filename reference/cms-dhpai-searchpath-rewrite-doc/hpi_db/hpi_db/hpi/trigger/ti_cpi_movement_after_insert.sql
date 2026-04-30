create trigger ti_cpi_movement_after_insert after
insert
    on
    hpi.cpi_movement referencing new table as inserted for each statement execute function hpi.fn_ti_cpi_movement();