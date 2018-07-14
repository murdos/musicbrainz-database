FROM postgres:9.5 as build-env

ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
 && apt-get -y -q install \
   git-core \
   build-essential \
   libxml2-dev \
   libpq-dev \
   libexpat1-dev \
   libdb-dev \
   libicu-dev \
   postgresql-server-dev-$PG_MAJOR \
   wget

# pull musicbrainz postgres extensions from git & install them
RUN git clone https://github.com/metabrainz/postgresql-musicbrainz-unaccent.git \
 && cd postgresql-musicbrainz-unaccent \
 && make \
 && make install

RUN git clone https://github.com/metabrainz/postgresql-musicbrainz-collate.git \
 && cd postgresql-musicbrainz-collate \
 && make \
 && make install


FROM postgres:9.5

COPY --from=build-env /usr/lib/postgresql/$PG_MAJOR/lib/musicbrainz_* /usr/lib/postgresql/$PG_MAJOR/lib/
COPY --from=build-env /usr/share/postgresql/$PG_MAJOR/extension/musicbrainz_* /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=build-env /usr/share/doc/postgresql-doc-$PG_MAJOR/extension/README.musicbrainz_* /usr/share/doc/postgresql-doc-$PG_MAJOR/extension/

RUN echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf \
 && echo "shared_buffers = 512MB" >> /var/lib/postgresql/data/postgresql.conf

ENV POSTGRES_USER musicbrainz
