-- ## Current configuration ##

-- All parameters
SHOW ALL;

-- Server configuration
SELECT
  seqno,
  name,
  setting,
  applied,
  error
FROM pg_file_settings
ORDER BY name;

WITH settings_cte AS (
  SELECT cast(current_setting('block_size') AS INTEGER) AS block_size
) --
SELECT
  (100 * checkpoints_req) / (checkpoints_timed + checkpoints_req) AS checkpoints_req_pct,
  pg_size_pretty(
    buffers_checkpoint * settings_cte.block_size / (checkpoints_timed + checkpoints_req)) AS avg_checkpoint_write,
  pg_size_pretty(settings_cte.block_size * (buffers_checkpoint + buffers_clean + buffers_backend)) AS total_written,
  100 * buffers_checkpoint / (buffers_checkpoint + buffers_clean + buffers_backend) AS checkpoint_write_pct,
  100 * buffers_backend / (buffers_checkpoint + buffers_clean + buffers_backend) AS backend_write_pct
FROM pg_stat_bgwriter, settings_cte;

-- Metadata retrieval
-- Sync in DataGrip:
-- (Prod) 33.0s after DB restart
-- (Prod) 1m:42s under load: 12 running processes (8 INSERTs, 3 VACUUMs)
-- (Prod) 9m:18s under load: 11 running processed (8 INSERTS, 3 pg_catalog VACUUMs)
-- (Prod) 2m:43s under load: 4 running processes (4 INSERTs)