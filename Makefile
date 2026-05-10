POSTGRES_CONTAINER_NAME := postgres
PGADMIN_CONTAINER_NAME  := pgadmin

DB_USER      := admin
DB_NAME      := portfolio
MB_DB_DBNAME := metabase

ENTRYPOINT_INITDB_DIR := docker-entrypoint-initdb.d
BACKUP_DIR            := backups

PORTFOLIO_DATA_FILE := $(ENTRYPOINT_INITDB_DIR)/03-data.sql
MB_FILE             := $(ENTRYPOINT_INITDB_DIR)/04-metabase_dump.sql


.PHONY: backup up down prod

backup:
	@mkdir -p $(ENTRYPOINT_INITDB_DIR) $(BACKUP_DIR)
	@TS=$$(date +"%Y%m%d_%H%M%S"); \
	DATA_BACKUP="$(BACKUP_DIR)/backup_data_$${TS}.sql"; \
	MB_BACKUP="$(BACKUP_DIR)/backup_metabase_$${TS}.sql"; \
	echo "→ Dumping $(DB_NAME) data…"; \
	docker exec $(POSTGRES_CONTAINER_NAME) \
	  pg_dump -U $(DB_USER) -d $(DB_NAME) \
	          --no-owner --no-privileges --data-only \
	  | tee $(PORTFOLIO_DATA_FILE) "$${DATA_BACKUP}" > /dev/null; \
	echo "→ Dumping $(MB_DB_DBNAME)…"; \
	printf '\\connect %s;\n' $(MB_DB_DBNAME) \
	  | tee $(MB_FILE) "$${MB_BACKUP}" > /dev/null; \
	docker exec $(POSTGRES_CONTAINER_NAME) \
	  pg_dump -U $(DB_USER) -d $(MB_DB_DBNAME) \
	          --no-owner --no-privileges \
	  | tee -a $(MB_FILE) "$${MB_BACKUP}" > /dev/null; \
	echo "→ Copying pgAdmin database…"; \
	docker cp $(PGADMIN_CONTAINER_NAME):/var/lib/pgadmin/pgadmin4.db \
	  $(ENTRYPOINT_INITDB_DIR)/pgadmin4_backup.db; \
	echo "✓ Backup complete"; \
	echo "  Portfolio : $${DATA_BACKUP}"; \
	echo "  Metabase  : $${MB_BACKUP}"

up:
	docker compose -f docker-compose.yaml -f docker-compose.local.yaml up

down:
	docker compose -f docker-compose.yaml -f docker-compose.local.yaml down -v

prod:
	docker compose -f docker-compose.yaml -f docker-compose.prod.yaml up -d
