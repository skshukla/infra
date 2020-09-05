#!/usr/bin/env bash

PG_DATA_DIR=/var/lib/postgresql/data

cat /tmp/pg_hba.conf > ${PG_DATA_DIR}/pg_hba.conf

echo wal_level = logical >> ${PG_DATA_DIR}/postgresql.conf
echo max_replication_slots = 4 >> ${PG_DATA_DIR}/postgresql.conf
echo max_wal_senders = 4 >> ${PG_DATA_DIR}/postgresql.conf
