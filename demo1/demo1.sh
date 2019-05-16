#!/usr/bin/env bash

#set haproxy config to point to postgresql10
sed -e "s;%PG_VERSION%;10;g" ./haproxy/haproxy.cfg.tpl > ./haproxy/haproxy.cfg

#setup basis
docker-compose up -d

#give postgres the time to initialize
sleep 5

#dump the database
docker exec demo1_postgresql10_1 pg_dump --format=plain --schema-only --clean --if-exists -U demo1 demo1 -f /share/demo1.dump

#create publication
docker exec demo1_postgresql10_1 psql -c "create publication demo1_publication for all tables;" -U demo1 demo1

#restore the dump on postgresql 11
docker exec demo1_postgresql11_1 psql -U demo1 -d demo1 -f /share/demo1.dump

#create subscription
docker exec demo1_postgresql11_1 psql -c "create subscription demo1_subscription connection 'host=postgresql10 port=5432 dbname=demo1 user=demo1' publication demo1_publication;" -U demo1 demo1;

#correct sequence
docker exec demo1_postgresql11_1 psql -c "SELECT SETVAL('public.test_id_seq', COALESCE(MAX(id), 1) + 1000) FROM public.test;" -U demo1 demo1;

#set haproxy config to point to postgresql11
sed -e "s;%PG_VERSION%;11;g" ./haproxy/haproxy.cfg.tpl > ./haproxy/haproxy.cfg
docker kill -s HUP demo1_haproxy_1
