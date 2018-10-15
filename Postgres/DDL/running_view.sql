CREATE OR REPLACE VIEW running
  AS
    SELECT
      pid,
      psa.query,
      /*state,*/ psa.wait_event_type || ': ' || psa.wait_event AS waiting_on,
      pg_blocking_pids(pspv.pid) AS blocking_pids,
      to_char(current_timestamp - psa.query_start, 'DD"d"HH24"h":MI"m":SS"s"') AS running_time,
      to_char(psa.query_start, 'YYYY-MM-DD HH24:MI TZ') AS started,
      pspv.phase || format(' (phase #%s/7)', CASE pspv.phase
                                               WHEN 'initializing' THEN 1
                                               WHEN 'scanning heap' THEN 2
                                               WHEN 'vacuuming indexes' THEN 3
                                               WHEN 'vacuuming heap' THEN 4
                                               WHEN 'cleaning up indexes' THEN 5
                                               WHEN 'truncating heap' THEN 6
                                               WHEN 'performing final cleanup' THEN 7
                                             END) AS vacuum_phase,
      CASE pspv.phase
        WHEN 'scanning heap' THEN round(CAST(pspv.heap_blks_scanned AS NUMERIC) / pspv.heap_blks_total * 100, 1) || '%'
        WHEN 'vacuuming indexes' THEN format('Cycles completed: %s; current cycle: %s%% (heap scanned: %s%%)',
                                             pspv.index_vacuum_count,
                                             round(CAST(pspv.num_dead_tuples AS NUMERIC) / pspv.max_dead_tuples * 100,
                                                   1),
                                             round(CAST(pspv.heap_blks_scanned AS NUMERIC) / pspv.heap_blks_total * 100,
                                                   1))
        WHEN 'vacuuming heap' THEN format('%s%% (heap scanned: %s%%)',
                                          round(CAST(pspv.heap_blks_vacuumed AS NUMERIC) / pspv.heap_blks_total * 100,
                                                1),
                                          round(CAST(pspv.heap_blks_scanned AS NUMERIC) / pspv.heap_blks_total * 100),
                                          1)
        ELSE CASE WHEN pspv.phase IS NULL THEN NULL ELSE 'N/A' END
      END AS vacuum_phase_progress,
      psa.usename AS user,
      psa.application_name AS app,
      coalesce(host(psa.client_addr), 'server socket') AS from
    FROM pg_stat_activity psa
    LEFT JOIN pg_stat_progress_vacuum pspv USING (pid)
    WHERE
      /* not this query */
        pid <> pg_backend_pid() AND psa.state = 'active'
    ORDER BY psa.query_start;

COMMENT ON VIEW running
IS 'Active server processes';