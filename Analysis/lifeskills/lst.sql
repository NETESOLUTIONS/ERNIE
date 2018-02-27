-- script to assemble a nodelist and edgelist for a graph spanning the President's report on 
-- combating addiction and the LST dataset.
-- Author George Chacko 2/26/2018

-- Assemble Trump report citations (Didi Cross and George Chacko)
DROP TABLE IF EXISTS pcreport_start;
CREATE TABLE pcreport_start (wos_id varchar(19));
INSERT INTO pcreport_start (wos_id) '~/ERNIE/Analysis/lifeskills/trump_wosids.csv' CSV HEADER DELIMITER ',';

DROP TABLE IF EXIST sg_start;
CREATE TABLE sg_start (wos_id varchar(19));
INSERT INTO sg_start (wos_id) '~/ERNIE/Analysis/lifeskills/sg_80thp_wosid.csv' CSV HEADER DELIMITER ',';





