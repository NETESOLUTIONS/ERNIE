SELECT
  id, num_scopus_pub,
  num_scopus_pub - lead(num_scopus_pub) OVER (ORDER BY id DESC) AS delta_with_next,
  num_scopus_pub - lead(num_scopus_pub) OVER (ORDER BY id DESC) >= 0 AS has_not_decreased
  FROM update_log_scopus
 WHERE num_scopus_pub IS NOT NULL
 ORDER BY id DESC LIMIT 1;