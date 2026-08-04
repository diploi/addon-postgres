FROM postgres:18.3

# pgvector ships in the PGDG apt repository, which the official postgres image
# already configures. PG_MAJOR is set by the base image, so bumping the FROM tag
# automatically selects the matching extension build.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      "postgresql-${PG_MAJOR}-pgvector"; \
    rm -rf /var/lib/apt/lists/*
