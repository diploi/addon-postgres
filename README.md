<img alt="icon" src=".diploi/icon.svg" width="32">

# PostgreSQL Addon for Diploi

Built on the official [postgres](https://hub.docker.com/_/postgres) Docker
image, with third-party extensions installed in [`Dockerfile`](Dockerfile).

## Extensions

Extensions are per-database, so enable the ones you need against your own database:

```sql
CREATE EXTENSION IF NOT EXISTS vector;              -- pgvector
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;  -- preloaded, ready to enable
```

Everything else below is part of the
[contrib](https://www.postgresql.org/docs/current/contrib.html) set that ships with the base
image, so it needs no installation — just `CREATE EXTENSION`:

| Extension | Use |
| --- | --- |
| `pg_trgm` | Fuzzy matching; accelerates `ILIKE` and similarity search |
| `btree_gin`, `btree_gist` | Mixed-column GIN indexes and exclusion constraints; commonly needed alongside `pg_trgm` |
| `unaccent` | Accent-insensitive search |
| `citext` | Case-insensitive text, for emails and usernames |
| `pgcrypto` | Hashing and encryption functions |
| `postgres_fdw`, `dblink` | Cross-database queries |
| `pg_buffercache`, `pgstattuple`, `amcheck` | Diagnostics and corruption checking |

`uuid-ossp` and `hstore` are available but not recommended for new schemas —
`gen_random_uuid()` and `uuidv7()` are built in, and `jsonb` supersedes `hstore`.

### Adding another extension

Add the package to [`Dockerfile`](Dockerfile) and open a PR. The image is built and
published by [`.github/workflows/Prebuild.yaml`](.github/workflows/Prebuild.yaml).
Extensions requiring `shared_preload_libraries` must also be added to the `args` list in
[`.diploi/helm/postgres.yaml`](.diploi/helm/postgres.yaml), where `pg_stat_statements` is
already preloaded.

Treat additions as permanent. Once a deployment runs `CREATE EXTENSION`, removing that
extension from the image breaks the database on its next restart, and dropping an entry from
`shared_preload_libraries` stops the cluster from starting at all.

Extensions are deliberately not user-configurable at deploy time: an arbitrary image
reference would let a deployment run a mismatched PostgreSQL major against an existing data
directory, which is unrecoverable without a dump and restore.

## Upgrading PostgreSQL majors

Bumping the `FROM` tag in [`Dockerfile`](Dockerfile) changes the major version. PostgreSQL
cannot start on a data directory written by a different major, and storage here is
persistent, so a major bump requires `pg_dumpall` on the old version followed by a restore
into a freshly initialised directory. Downgrades are not possible in place.

## Links

- [Adding Postgres to a project](https://docs.diploi.com/building/add-ons/postgres)
- [Postgres docs](https://www.postgresql.org/docs/)
- [pgvector](https://github.com/pgvector/pgvector)
