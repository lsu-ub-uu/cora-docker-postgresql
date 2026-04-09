#!/bin/bash
dbFilesFolder="dbfiles"
dataDividers="$DATA_DIVIDERS"

function start(){
  setPsqlEnvVars
  importDataForDataDividers
}

function setPsqlEnvVars(){
  export PGUSER="$POSTGRES_USER"
  export PGDATABASE="$POSTGRES_DB"
  export PGPASSWORD="$POSTGRES_PASSWORD"
}

function importDataForDataDividers(){
  for dataDivider in $dataDividers ; do
    echo ""
    echo "Importing dataDivider: $dataDivider"
    importForDataDivider "$dbFilesFolder/$dataDivider"
  done
}

function importForDataDivider(){
  local folder="$1"

  for sqlFileName in "$folder"/*.sql ; do
    importSqlFileForDataDivider "$sqlFileName"
  done
}

function importSqlFileForDataDivider(){
  local sqlFileName="$1"

  [ -e "$sqlFileName" ] || return 0

  echo "Run SQL file: $sqlFileName"
  psql -v ON_ERROR_STOP=1 \
    -f "$sqlFileName" \
    > "$sqlFileName.log" 2>&1
}

start