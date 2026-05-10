# Deploy FinDash on DigitalOcean (no domain required)

This stack is PostgreSQL + Metabase (+ optional pgAdmin). Use a **Droplet** with Docker and access Metabase at **`http://<your-droplet-ip>/`** on port 80 (HTTP only—no domain or TLS in this setup).

## 1. Create a Droplet

- **Image**: Ubuntu 24.04 LTS  
- **Size**: At least **2 GB RAM** (4 GB is safer for steady Metabase + Postgres use).  
- **Authentication**: SSH keys.

## 2. Install Docker (one-time)

On the Droplet:

```bash
sudo bash deploy/digitalocean/bootstrap.sh
```

This installs Docker Engine with Compose v2 and configures **UFW** to allow SSH and HTTP (port 80).

## 3. Put the project on the server

```bash
git clone <your-repo-url> FinDash && cd FinDash
```

## 4. Environment

Copy `.env.example` to `.env` and set strong values for Postgres, pgAdmin, and Metabase (`MB_*` must match your Postgres credentials and database names). Nothing else is required for IP-only access.

## 5. pgAdmin volume on first deploy

`pgadmin4_backup.db` is gitignored. Before the first `up`, create an empty file so Docker does not create a wrong directory mount:

```bash
mkdir -p docker-entrypoint-initdb.d
touch docker-entrypoint-initdb.d/pgadmin4_backup.db
```

## 6. Start the stack

```bash
docker compose -f docker-compose.yaml -f docker-compose.prod.yaml up -d
```

Open **`http://<droplet-public-ip>/`** in your browser (plain HTTP).

Postgres listens on **127.0.0.1:5432** and pgAdmin on **127.0.0.1:5050** only. From your laptop, use an SSH tunnel:

```bash
ssh -L 5050:127.0.0.1:5050 -L 5432:127.0.0.1:5432 root@YOUR_DROPLET_IP
```

Then use `http://localhost:5050` for pgAdmin and Postgres at `localhost:5432`.

## 7. NAV loader (optional)

Run `nav_loader` on the server with `DB_HOST=127.0.0.1` and `DB_PORT=5432`, or run from your machine while the tunnel is up. Schedule `latest` mode with **cron** or **systemd timers** if you want daily NAV updates.

## HTTPS with only an IP (no domain)

You **can** use HTTPS to a bare IP address. TLS does not require a hostname; the certificate just has to match what users type in the browser (for example the IP in the certificate’s Subject Alternative Name).

What usually stops people is **getting a browser-trusted certificate**, not TLS itself:

| Approach | Notes |
|----------|--------|
| **HTTP** (this repo’s default) | Simplest. No encryption between browser and Droplet. |
| **Self-signed certificate** | Generate a cert whose SAN includes your Droplet’s public IP, configure Caddy (or another proxy) to use it. Browsers show a warning until you trust the cert or add an exception. Fully workable for personal use. |
| **Let’s Encrypt for IPs** | Let’s Encrypt [issues certificates for public IPv4/IPv6 addresses](https://letsencrypt.org/), but they are **short-lived** (on the order of days), so renewals must be automated (for example Certbot on a schedule). Caddy’s automatic HTTPS is aimed mainly at hostnames; IP issuance often uses Certbot + mounting PEM files into Caddy. |
| **A domain name** | Still the smoothest path to a green padlock with long-lived certs and simple automation (Caddy + Let’s Encrypt). |

So the limitation was never “HTTPS doesn’t work on IPs”; it was “a **free, trusted** cert without a domain used to be awkward.” IP certs from Let’s Encrypt are possible now but need more ops than a single hostname.

## Security notes

- The default Compose setup uses **HTTP on port 80** so you do not need certificates or renewal jobs.
- For encryption without a domain, use **self-signed** (warning in browser) or automate **Let’s Encrypt IP** certs with renewal.
- Keep Postgres and pgAdmin bound to localhost (as in `docker-compose.prod.yaml`) unless you know you need remote DB access.

## Alternatives

- **Managed PostgreSQL**: Possible by pointing Metabase at a [DO Managed Database](https://www.digitalocean.com/products/managed-databases-postgresql); requires Compose edits not included here by default.
