#!/usr/bin/env bash

#set haproxy config to point to postgresql10
sed -e "s;%PG_VERSION%;10;g" ./haproxy/haproxy.cfg.tpl > ./haproxy/haproxy.cfg

#setup basis
docker-compose up -d

#wait for postgres to init
sleep 5

#bootstrap config of pgadmin4
docker exec demo1_pgadmin4_1 python /pgadmin4/setup.py --load-servers /servers.json --user user@domain.com

#open browser with pgadmin
read -p "Go to http://localhost:8080 . Login with user@domain.com and password: admin. Press any key to continue... " -n1 -s

#dump the database
docker exec demo1_postgresql10_1 pg_dump --format=plain --schema-only --clean --if-exists -U demo1 demo1 -f /share/demo1.dump

#restore the dump on postgresql 11
docker exec demo1_postgresql11_1 psql -U demo1 -d demo1 -f /share/demo1.dump

#check the restore of the db
read -p "Check the db restored correctly in PGAdmin4. Press any key to continue... " -n1 -s

#create publication
docker exec demo1_postgresql10_1 psql -c "create publication demo1_publication for all tables;" -U demo1 demo1

#create subscription
docker exec demo1_postgresql11_1 psql -c "create subscription demo1_subscription connection 'host=postgresql10 port=5432 dbname=demo1 user=demo1' publication demo1_publication;" -U demo1 demo1;

#check that it is replicating
read -p "Insert something in PG10 and check it appears in PG11. Insert something in PG11 and see what happens. Press any key to continue... " -n1 -s

#correct sequence https://wiki.postgresql.org/wiki/Fixing_Sequences
docker exec demo1_postgresql11_1 psql -c "SELECT SETVAL('public.test_id_seq', COALESCE(MAX(id), 1) + 1000) FROM public.test;" -U demo1 demo1;

#set haproxy config to point to postgresql11
sed -e "s;%PG_VERSION%;11;g" ./haproxy/haproxy.cfg.tpl > ./haproxy/haproxy.cfg
docker kill -s HUP demo1_haproxy_1
docker stop demo1_postgresql10_1