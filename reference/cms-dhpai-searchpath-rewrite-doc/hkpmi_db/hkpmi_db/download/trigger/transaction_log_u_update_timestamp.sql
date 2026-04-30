create trigger transaction_log_u_update_timestamp before update on download.transaction_log for each row execute procedure fn_update_timestamp();
