alter table fda_products add column rs varchar(10);
select
  pardi_id,
  ingredient,
  df_route,
  trade_name,
  applicant,
  strength,
  appl_type,
  appl_no,
  product_no,
  te_code,
  approval_date,
  rld,
  rs,
  type,
  applicant_full_name
  into fda_products_temp
  from fda_products;

  alter table fda_products_temp set tablespace fdadata_tbs;

  drop table fda_products;

  alter table fda_products_temp rename to fda_products;
