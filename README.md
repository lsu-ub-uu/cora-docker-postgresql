# cora-docker-postgresql
Docker container with a PostgreSQL database

Initdb should conatin an import script. The script must be stored in docker-entrypoint-initdb.d/ on the docker. Since we reuse anothe postgresql docker with shared tables, that docker will have as well an import script. You must be carefull that the scripts will be run automatically on start and the will be run in alphabetically order.

Read for more information: https://hub.docker.com/_/postgres/