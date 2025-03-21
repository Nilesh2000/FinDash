CONTAINER_NAME=postgres

DB_HOST=localhost
DB_USER=postgres

DB_NAME=portfolio
MB_DB_DBNAME=metabase

ENTRYPOINT_INITDB_DIR=docker-entrypoint-initdb.d
PORTFOLIO_SCHEMA_FILE=$(ENTRYPOINT_INITDB_DIR)/02-schema_$(TIMESTAMP).sql
PORTFOLIO_DATA_FILE=$(ENTRYPOINT_INITDB_DIR)/03-data_$(TIMESTAMP).sql
MB_FILE=$(ENTRYPOINT_INITDB_DIR)/04-metabase_dump_$(TIMESTAMP).sql

TIMESTAMP=$(shell date +%Y%m%d%_H%M%S)

.PHONY: backup

backup:
	@rm -f $(ENTRYPOINT_INITDB_DIR)/0[234]-*.sql
	mkdir -p $(ENTRYPOINT_INITDB_DIR)
	docker exec -it $(CONTAINER_NAME) pg_dump -U $(DB_USER) -d $(DB_NAME) --no-owner --no-privileges --schema-only >> $(PORTFOLIO_SCHEMA_FILE)
	docker exec -it $(CONTAINER_NAME) pg_dump -U $(DB_USER) -d $(DB_NAME) --no-owner --no-privileges >> $(PORTFOLIO_DATA_FILE)

	@printf "\\connect %s;\n" $(MB_DB_DBNAME) > $(MB_FILE)
	docker exec $(CONTAINER_NAME) pg_dump -U $(DB_USER) -d $(MB_DB_DBNAME) --no-owner --no-privileges | tee -a $(MB_FILE) > /dev/null

	@echo "Backup completed successfully"
