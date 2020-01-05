-- 1.6s
SELECT title
  FROM scopus_titles
 WHERE to_tsvector('english', title) @@ to_tsquery('deletion & polymorphism & haplotypes')
 LIMIT 20;

-- 1.6s
SELECT title
  FROM scopus_titles
 WHERE to_tsvector(title) @@ to_tsquery('deletion & polymorphism & haplotypes')
 LIMIT 20;