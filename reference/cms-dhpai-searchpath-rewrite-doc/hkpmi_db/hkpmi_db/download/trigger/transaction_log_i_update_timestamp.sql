create trigger transaction_log_i_update_timestamp before INSERT on download.transaction_log for each row execute procedure fn_update_timestamp();
