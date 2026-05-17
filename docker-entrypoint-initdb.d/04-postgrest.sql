-- Anon role for unauthenticated access
CREATE ROLE anon NOLOGIN;
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;

-- Authenticator role (PostgREST connects as this)
CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD 'postgrest';
GRANT anon TO authenticator;

-- Revoke all privileges on nav_history table from anon role
REVOKE ALL ON public.nav_history FROM anon;
