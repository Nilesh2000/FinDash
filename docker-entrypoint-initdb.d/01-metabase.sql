-- Create Metabase internal database
CREATE DATABASE metabase;

-- Create Metabase internal user
CREATE USER metabase_user WITH PASSWORD 'metabase_password';

-- Grant database-level privileges (to connect)
GRANT ALL PRIVILEGES ON DATABASE metabase TO metabase_user;

-- Connect to metabase_internal_db to set schema-level privileges
\connect metabase;

-- Grant schema privileges explicitly
GRANT ALL ON SCHEMA public TO metabase_user;

-- Create read-only user
CREATE USER metabase_ro WITH PASSWORD 'metabase_ro_password';

-- Grant connect and select privileges on portfolio database
GRANT CONNECT ON DATABASE portfolio TO metabase_ro;

-- Connect to portfolio database
\connect portfolio;

-- Grant select privileges on all tables in public schema
GRANT SELECT ON ALL TABLES IN SCHEMA public TO metabase_ro;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO metabase_ro;
