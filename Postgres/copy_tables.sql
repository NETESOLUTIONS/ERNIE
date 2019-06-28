CREATE TABLE public.:t (
  LIKE ernie1_public.:t INCLUDING ALL
);

INSERT
INTO public.:t
SELECT *
FROM ernie1_public.:t;