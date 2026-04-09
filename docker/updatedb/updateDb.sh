#!/bin/bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
dbFilesFolder="dbfiles"
deleteScript="$SCRIPT_DIR/deleteDataDivider.sql"
dataDividers="$DATA_DIVIDERS"
	
function start(){
  setPsqlEnvVars
  deleteDataForDataDividers
  importDataForDataDividers
  storeUpdateDbVersion
}

function setPsqlEnvVars(){
  export PGHOST="$POSTGRES_HOST"
  export PGUSER="$POSTGRES_USER"
  export PGDATABASE="$POSTGRES_DB"
  export PGPASSWORD="$POSTGRES_PASSWORD"
}

function deleteDataForDataDividers(){
  for dataDivider in $dataDividers ; do
    deleteDataDivider "$dataDivider"
  done
}

function deleteDataDivider(){
  local dataDivider="$1"
  local logFile="$SCRIPT_DIR/delete_${dataDivider}.log"

  echo "Deleting $dataDivider (logging to $logFile)"

  psql -v ON_ERROR_STOP=1 \
    -v dataDivider="$dataDivider" \
    -f "$deleteScript" \
    > "$logFile" 2>&1
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

function storeUpdateDbVersion(){
  local updatedbVersion="$applicationVersion"

  if [ -z "$updatedbVersion" ]; then
    echo "applicationVersion is not set, skipping version update in DB"
    return 0
  fi

  echo "Storing updatedb_version=$updatedbVersion in DB"

  psql -v ON_ERROR_STOP=1 \
    -v updatedbVersion="$updatedbVersion" \
    -c "
      create table if not exists cora_meta (
        key text primary key,
        value text not null,
        updated_at timestamptz not null default now()
      );

      insert into cora_meta(key, value, updated_at)
      values ('updatedb_version', '$updatedbVersion', now())
      on conflict (key) do update
        set value = excluded.value,
            updated_at = excluded.updated_at;
    "
}

start