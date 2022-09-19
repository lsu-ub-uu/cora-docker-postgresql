FROM postgres:14

RUN localedef -i en_GB -c -f UTF-8 -A /usr/share/locale/locale.alias en_GB.UTF-8
ENV LANG en_GB.utf8

USER root

RUN mkdir data

COPY sql/tables/* sql/tables/
COPY initdb/*.sh docker-entrypoint-initdb.d/

RUN chmod +rx docker-entrypoint-initdb.d/*.sh && chown -R postgres: sql