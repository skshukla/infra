FROM postgres:9.6.14

COPY pg_hba.conf /tmp/pg_hba.conf
COPY init_db_setup.sh /docker-entrypoint-initdb.d/init_db_setup.sh

RUN chmod +x /docker-entrypoint-initdb.d/init_db_setup.sh