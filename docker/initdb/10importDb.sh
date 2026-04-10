#!/bin/bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
dbFilesFolder="dbfiles"
dataDividers="$DATA_DIVIDERS"
updatedbVersion="$applicationVersion"

function start(){
  setPsqlEnvVars
  importDataForDataDividers
  shouldStoreVersion || return 0
  storeUpdateDbVersion
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

function shouldStoreVersion(){
  if [ -z "$updatedbVersion" ]; then
    echo "applicationVersion is not set - refusing to store version"
    return 1
  fi

  return 0
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