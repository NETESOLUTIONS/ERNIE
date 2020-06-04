CREATE TABLE public.:t (
  LIKE :source_schema.:t INCLUDING ALL
);

INSERT
INTO public.:t
SELECT *
FROM :source_schema.:t;