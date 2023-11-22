#!/bin/bash
set -e
PGPASSWORD=$POSTGRES_PASSWORD

function run_sql () {
   for SQL in "$1"/*
	do
 	 echo "Run file: $SQL"
		psql -v ON_ERROR_STOP=1 -U $POSTGRES_USER $POSTGRES_DB < $SQL > $SQL.log
	done
}

echo ""
echo "Creating tables"
run_sql "sql/tables"