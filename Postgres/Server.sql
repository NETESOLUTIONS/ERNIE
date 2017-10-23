-- Server version
SELECT version();

-- Reload server configuartion
SELECT CASE WHEN pg_reload_conf() THEN 'Reloaded.' ELSE 'Failed to reload!' END;
