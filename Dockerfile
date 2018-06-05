FROM postgres:9.5.10

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
   postgresql-server-dev-9.5 \
   wget

# pull musicbrainz postgres extensions from git & install them
RUN git clone https://github.com/metabrainz/postgresql-musicbrainz-unaccent.git \
 && git clone https://github.com/metabrainz/postgresql-musicbrainz-collate.git \
 && cd postgresql-musicbrainz-unaccent \
 && make \
 && make install \
 && cd ../postgresql-musicbrainz-collate \
 && make \
 && make install \
 && cd ../ \
 && rm -R postgresql-musicbrainz-unaccent \
 && rm -R postgresql-musicbrainz-collate

RUN echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf \
 && echo "shared_buffers = 512MB" >> /var/lib/postgresql/data/postgresql.conf

COPY create-database.sh /create-database.sh
