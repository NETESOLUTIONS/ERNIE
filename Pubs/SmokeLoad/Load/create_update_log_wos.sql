
-- Author: VJ Davey
-- Create Date: 09/18/2017
-- Usage: psql -d ernie -f create_update_log_wos.sql

SET default_tablespace = ernie_wos_tbs;

CREATE TABLE update_log_wos (
    id integer NOT NULL,
    last_updated timestamp without time zone,
    num_wos integer,
    num_new integer,
    num_update integer,
    num_delete integer
);

ALTER TABLE update_log_wos OWNER TO ernie_admin;

CREATE SEQUENCE update_log_wos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE update_log_wos_id_seq OWNER TO ernie_admin;


ALTER SEQUENCE update_log_wos_id_seq OWNED BY update_log_wos.id;


ALTER TABLE ONLY update_log_wos ALTER COLUMN id SET DEFAULT nextval('update_log_wos_id_seq'::regclass);
