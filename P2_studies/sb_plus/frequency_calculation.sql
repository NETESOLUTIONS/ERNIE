DO
$do$
  DECLARE
    counter INT := 1;
    processed BIGINT := :batch_size;
  BEGIN
    WHILE processed = :batch_size
    LOOP
      INSERT INTO test_one_million_pairs_frequency (cited_1, cited_2, frequency)
      SELECT cited_1, cited_2, COUNT(1) as frequency
        FROM test_one_million_pairs tomp
        JOIN public.scopus_references sr1
             ON sr1.ref_sgr = tomp.cited_1
        JOIN public.scopus_references sr2
             ON sr2.scp = sr1.scp AND sr2.ref_sgr = tomp.cited_2
       GROUP BY tomp.cited_1, tomp.cited_2
       ORDER BY cited_1, cited_2
       LIMIT :batch_size OFFSET (counter - 1)*:batch_size;
      RAISE NOTICE 'BATCH %', counter;
      counter := counter + 1;
      GET DIAGNOSTICS processed = ROW_COUNT;
    END LOOP;
  END
$do$;
