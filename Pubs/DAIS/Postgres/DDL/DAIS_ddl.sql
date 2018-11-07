create table if not exists dais
(
	dais_id varchar(30),
  source_id varchar(30) default ''::character varying not null,
	full_name varchar(200),
	last_name varchar(200),
	first_name varchar(200),
	seq_no integer default 0 not null,
	source_filename varchar(200),
	last_updated_time timestamp default now(),
	constraint dais_test_pk
	primary key (dais_id, source_id, full_name, seq_no)
);
comment on column dais.dais_id is ' Example: 4624188';
comment on column dais.source_id is 'UT. Example: WOS:000003907500008';
comment on column dais.full_name is ' Example: Balick, M.';
comment on column dais.last_name is ' Example: Balick';
comment on column dais.first_name is ' Example: M';
comment on column dais.seq_no is ' Example: 3';
comment on column dais.source_filename is 'source txt file. Example: UT_DAISID.txt';
