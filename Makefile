CONTAINER_NAME=postgres

DB_HOST=localhost
DB_USER=postgres

DB_NAME=portfolio
MB_DB_DBNAME=metabase

ENTRYPOINT_INITDB_DIR=docker-entrypoint-initdb.d
PORTFOLIO_SCHEMA_FILE=$(ENTRYPOINT_INITDB_DIR)/02-schema.sql
PORTFOLIO_DATA_FILE=$(ENTRYPOINT_INITDB_DIR)/03-data.sql
MB_FILE=$(ENTRYPOINT_INITDB_DIR)/04-metabase_dump.sql

.PHONY: backup up down

backup:
	mkdir -p $(ENTRYPOINT_INITDB_DIR)
	rm -f $(PORTFOLIO_SCHEMA_FILE) $(PORTFOLIO_DATA_FILE) $(MB_FILE)
	docker exec -it $(CONTAINER_NAME) pg_dump -U $(DB_USER) -d $(DB_NAME) --no-owner --no-privileges --schema-only >> $(PORTFOLIO_SCHEMA_FILE)
	docker exec -it $(CONTAINER_NAME) pg_dump -U $(DB_USER) -d $(DB_NAME) --no-owner --no-privileges --data-only >> $(PORTFOLIO_DATA_FILE)

	@printf "\\connect %s;\n" $(MB_DB_DBNAME) > $(MB_FILE)
	docker exec $(CONTAINER_NAME) pg_dump -U $(DB_USER) -d $(MB_DB_DBNAME) --no-owner --no-privileges | tee -a $(MB_FILE) > /dev/null

	@echo "Backup completed successfully"

up:
	docker-compose up

down:
	docker-compose down -v
