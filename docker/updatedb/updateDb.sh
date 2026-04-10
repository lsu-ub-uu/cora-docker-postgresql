#!/bin/bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
dbFilesFolder="dbfiles"
deleteScript="$SCRIPT_DIR/deleteDataDivider.sql"
dataDividers="$DATA_DIVIDERS"
updatedbVersion="$applicationVersion"

function start(){
  setPsqlEnvVars
  ensureMetaTableExists
  shouldRunUpdate || return 0
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

function ensureMetaTableExists(){
  psql -v ON_ERROR_STOP=1 \
    -c "
      create table if not exists cora_meta (
        key text primary key,
        value text not null,
        updated_at timestamptz not null default now()
      );
    " > "$SCRIPT_DIR/ensure_meta.log" 2>&1
}

function shouldRunUpdate(){
  if [ -z "$updatedbVersion" ]; then
    echo "applicationVersion is not set - refusing to run update"
    return 1
  fi

  local currentDbVersion="$(getCurrentDbVersion)"
  echo "DB updatedb_version='${currentDbVersion}', desired='${updatedbVersion}'"

  if [ "$currentDbVersion" = "$updatedbVersion" ]; then
    echo "DB is already at version '$updatedbVersion' - skipping update"
    return 1
  fi

  return 0
}

function getCurrentDbVersion(){
  # -t: tuples only, -A: unaligned, so output is just the value
  psql -v ON_ERROR_STOP=1 -tA \
    -c "select value from cora_meta where key='updatedb_version';" 2>/dev/null | tr -d '\r'
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
  local updatedbVersionSql="$(escapeSqlLiteral "$updatedbVersion")"
  echo "Storing updatedb_version=$updatedbVersion in DB"

  psql -v ON_ERROR_STOP=1 \
    -c "
      insert into cora_meta(key, value, updated_at)
      values ('updatedb_version', '$updatedbVersionSql', now())
      on conflict (key) do update
        set value = excluded.value,
            updated_at = excluded.updated_at;
     "
}

function escapeSqlLiteral(){
  local value="$1"
  value="${value//\'/\'\'}"
  echo "$value"
}

start