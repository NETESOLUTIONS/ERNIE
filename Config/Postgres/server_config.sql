\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

--region Server restart is required

/*
Specifies the TCP/IP address(es) on which the server is to listen for connections from client applications.
Default = localhost
*/
ALTER SYSTEM SET listen_addresses = '*';

/*
This parameter controls the average number of object locks allocated for each transaction; individual transactions can
lock more objects as long as the locks of all transactions fit in the lock table.
The default, 64, has historically proven sufficient, but you might need to raise this value if you have queries that
touch many different tables in a single transaction, e.g. query of a parent table with many children.
*/
ALTER SYSTEM SET max_locks_per_transaction = 256;

/*
Sets the amount of memory the database server uses for shared memory buffers. The default is typically 128 megabytes
(128MB) but might be less if your kernel settings will not support it (as determined during `initdb`).
If you have a dedicated database server with 1GB or more of RAM, a reasonable starting value for shared_buffers is 25%
of the memory in your system. There are some workloads where even large settings for shared_buffers are effective, but
because PostgreSQL also relies on the operating system cache, it is unlikely that an allocation of more than 40% of RAM
to shared_buffers will work better than a smaller amount.
*/
ALTER SYSTEM SET shared_buffers = '10 GB';

--endregion

--region Configuration reload is required

ALTER SYSTEM SET log_statement = 'ddl';

/*
Sets the planner's estimate of the cost of a non-sequentially-fetched disk page. The default is 4.0.
This value can be overridden for tables and indexes in a particular tablespace by setting the tablespace parameter of
the same name (see ALTER TABLESPACE).

Reducing this value relative to seq_page_cost will cause the system to prefer index scans; raising it will make index
scans look relatively more expensive. You can raise or lower both values together to change the importance of disk
I/O costs relative to CPU costs.

Random access to mechanical disk storage is normally much more expensive than four times sequential access. However,
a lower default is used (4.0) because the majority of random accesses to disk, such as indexed reads, are assumed to be
in cache. The default value can be thought of as modeling random access as 40 times slower than sequential, while
expecting 90% of random reads to be cached.

If you believe a 90% cache rate is an incorrect assumption for your workload, you can increase random_page_cost to
better reflect the true cost of random storage reads. Correspondingly, if your data is likely to be completely in cache,
such as when the database is smaller than the total server memory, decreasing random_page_cost can be appropriate.
Storage that has a low random read cost relative to sequential, e.g. solid-state drives, might also be better modeled
with a lower value for random_page_cost.
*/
ALTER SYSTEM SET random_page_cost = 1;

/*
Specifies the amount of memory to be used by internal sort operations and hash tables before writing to temporary disk
files. The value defaults to four megabytes (4MB).

Postgres executor node-based work_mem management means that the peak space usage depends on the number of concurrent queries * number of executor nodes * number of parallel processes allowed * `work_mem`.

High values can cause Shared Memory to overflow on memory-intensive queries.
Observed shared memory single query consumption max: 8.4 GB for `work_mem` = '512 MB'.

The recommended setting ≈ {`/dev/shm` size} / { CPU cores } / 2.
*/
ALTER SYSTEM SET work_mem = '512 MB';

/*
Specifies the maximum amount of memory to be used by maintenance operations, such as VACUUM, CREATE INDEX, and
ALTER TABLE ADD FOREIGN KEY. It defaults to 64 megabytes (64MB).
*/
ALTER SYSTEM SET maintenance_work_mem = '2 GB';

/*
Maximum size to let the WAL grow to between automatic WAL checkpoints. This is a soft limit; WAL size can exceed
max_wal_size under special circumstances, like under heavy load, a failing archive_command, or a high wal_keep_segments
setting. The default is 1 GB.
*/
ALTER SYSTEM SET max_wal_size = '2 GB';

ALTER SYSTEM SET temp_tablespaces = 'temp_tbs';

-- Client Connection Default
ALTER SYSTEM SET default_tablespace = 'user_tbs';

--endregion