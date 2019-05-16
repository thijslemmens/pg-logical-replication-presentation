global
    maxconn 100

defaults
    log global
    mode tcp
    retries 2
    timeout client 30m
    timeout connect 4s
    timeout server 30m
    timeout check 5s

listen postgres
    bind *:5432
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server srv%PG_VERSION% postgresql%PG_VERSION%:5432 maxconn 2048