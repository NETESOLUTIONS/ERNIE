
-- Author : Samet Keserci
-- Date : 09/27/17
-- Note: This process is semi manual. Two csv file should be provided - CDER_20170926_done.csv, CBER_20170926_done
-- which are scrappped and formatted from fda website.
-- https://www.fda.gov/drugs/developmentapprovalprocess/howdrugsaredevelopedandapproved/approvalapplications/therapeuticbiologicapplications/biosimilars/ucm411418.htm



alter table fda_purple_book rename to old_fda_purple_book;

create table fda_cder(
  bla_stn varchar(20),
  product_name varchar(300),
  proprietary_name varchar(300),
  date_of_licensure_m_d_y varchar(20),
  date_of_first_licensure_m_d_y varchar(20),
  reference_product_exclusivity_expiry_date_m_d_y varchar(20),
  interchangable_biosimilar varchar(20),
  withdrawn varchar(20)
) tablespace ernie_fda_tbs;


copy fda_cder from '/erniedev_data1/FDAupdate/FDA_Purple/CDER_20170926_done.csv' with delimiter ',' csv header;


create table fda_cber(
  bla_stn varchar(20),
  product_name varchar(300),
  proprietary_name varchar(300),
  date_of_licensure_m_d_y varchar(20),
  date_of_first_licensure_m_d_y varchar(20),
  reference_product_exclusivity_expiry_date_m_d_y varchar(20),
  interchangable_biosimilar varchar(20),
  withdrawn varchar(20)
) tablespace ernie_fda_tbs;

copy fda_cber from '/erniedev_data1/FDAupdate/FDA_Purple/CBER_20170926_done.csv' with delimiter ',' csv header;

create table fda_purple_book (
  bla_stn varchar(20),
  product_name varchar(300),
  proprietary_name varchar(300),
  date_of_licensure_m_d_y varchar(20),
  date_of_first_licensure_m_d_y varchar(20),
  reference_product_exclusivity_expiry_date_m_d_y varchar(20),
  interchangable_biosimilar varchar(20),
  withdrawn varchar(20)
) tablespace ernie_fda_tbs;

insert into fda_purple_book
  select * from fda_cder
  union
  select * from fda_cber;

drop table fda_cder;
drop table fda_cber;
