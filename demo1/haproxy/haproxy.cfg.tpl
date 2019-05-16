defaults
        mode    tcp
        balance leastconn
        timeout client      30000ms
        timeout server      30000ms
        timeout connect      3000ms
        retries 3
frontend fr_server1
        bind 0.0.0.0:5432
        default_backend bk_server1
backend bk_server1
        server srv1 postgresql%PG_VERSION%:5432 maxconn 2048