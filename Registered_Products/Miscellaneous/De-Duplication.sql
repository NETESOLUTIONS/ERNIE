-- region fda_exclusivities
ALTER TABLE fda_exclusivities
  ALTER COLUMN appl_no SET NOT NULL,
  ALTER COLUMN product_no SET NOT NULL,
  ALTER COLUMN exclusivity_code SET NOT NULL;
--

DELETE
FROM fda_exclusivities fe1
WHERE EXISTS(SELECT 1
             FROM fda_exclusivities fe2
             WHERE fe2.appl_no = fe1.appl_no
               AND fe2.product_no = fe1.product_no
               AND fe2.exclusivity_code = fe1.exclusivity_code
               AND (fe2.exclusivity_date > fe1.exclusivity_date OR
                fe2.exclusivity_date = fe1.exclusivity_date AND fe2.ctid > fe1.ctid));
--

ALTER TABLE fda_exclusivities
  ADD CONSTRAINT fda_exclusivities_pk PRIMARY KEY (appl_no, product_no, exclusivity_code);
-- endregion

-- region fda_patents
ALTER TABLE fda_patents
  ALTER COLUMN appl_no SET NOT NULL,
  ALTER COLUMN product_no SET NOT NULL,
  ALTER COLUMN patent_no SET NOT NULL;
-- 0.2s

DELETE
FROM fda_patents fp1
WHERE EXISTS(SELECT 1
             FROM fda_patents fp2
             WHERE fp2.appl_no = fp1.appl_no
               AND fp2.product_no = fp1.product_no
               AND fp2.patent_no = fp1.patent_no
               AND fp2.patent_use_code = fp1.patent_use_code
               AND fp2.ctid > fp1.ctid);
--

CREATE UNIQUE INDEX fda_patents_uk
  ON fda_patents (appl_no, product_no, patent_no, patent_use_code);
-- 0.1s
-- endregion

-- region fda_products
ALTER TABLE fda_products
  ALTER COLUMN appl_no SET NOT NULL,
  ALTER COLUMN product_no SET NOT NULL,
  ALTER COLUMN "type" SET NOT NULL;
-- 0.4s

ALTER TABLE fda_products
  ADD CONSTRAINT fda_products_pk PRIMARY KEY (appl_no, product_no, "type");
-- endregion

-- region fda_purple_book
ALTER TABLE fda_purple_book
  ALTER COLUMN bla_stn SET NOT NULL;
--

DO $$ BEGIN
  IF NOT EXISTS(SELECT 1
                FROM information_schema.constraint_column_usage
                WHERE constraint_schema = 'public'
                  AND constraint_name = 'fda_purple_book_pk')
  THEN
    ALTER TABLE fda_purple_book
      ADD CONSTRAINT fda_purple_book_pk PRIMARY KEY (bla_stn);
  END IF;
END $$;
-- 0.3s
-- endregion