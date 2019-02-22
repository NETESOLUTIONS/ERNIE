SELECT pid 
FROM pg_stat_activity 
WHERE pid <> pg_backend_pid() and state <> 'idle' and usename != 'postgres';
