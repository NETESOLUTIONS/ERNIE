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