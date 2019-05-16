CREATE USER replica REPLICATION LOGIN ENCRYPTED PASSWORD 'aqwe123@';

create table test(
id serial PRIMARY KEY,
name text
);

insert into test(name) values ('hello');