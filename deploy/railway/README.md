# Railway production deployment

Upstream source: bigcapitalhq/bigcapital at d2a0bf153a0f11dc4250df504105d3fea74356bd (main, v0.25.42). Original license is preserved. Upstream workflows are archived under .github/upstream-workflows and do not execute.

## Services

- MariaDB 10.11 with /var/lib/mysql persistent volume. Application user is restricted to bigcapital_system and bigcapital_tenant_% databases.
- Redis 7 with persistent /data and authentication.
- Server: deploy/railway/server.Dockerfile; migrations run before the HTTP server starts. Healthcheck: /api/system_db.
- Webapp: deploy/railway/webapp.Dockerfile; healthcheck /.
- Gateway: deploy/railway/gateway.Dockerfile; port 8080; healthcheck /health. Resolves private DNS dynamically and forwards HTTPS requests to private services.
- Gotenberg for PDF generation.
- Attachments private S3-compatible Railway bucket.
- Automatic database backups are NOT enabled, by owner preference. Backup implementation is present as an optional deployment; it has no configured credentials, source or schedule.

## Secrets and access

Database passwords, Redis password, JWT signing secret and S3 credentials are Railway variables. Never commit .env or accounting exports. Only the gateway has a public domain. Initial signup is restricted to the approved administrator email, and must be fully closed after provisioning.

Email delivery and external bank feeds require separate provider configuration and are not enabled by this deployment.

## Build

Node 22 and pinned base-image digests are used. pnpm 9.0.5 installs the committed lockfile. pnpm --force handles an upstream SDK manifest's platform-specific dependency; shared packages and application packages are compiled from this repository. The API runtime receives only production dependencies using pnpm deploy.

## Upgrades

Production services are pinned to Git commit SHAs, so pushes do not automatically change the live build. Merge upstream changes into a review branch, build and test against a separate database, verify invoices/payments/reports and PDF output, take a manual database backup, then reconnect the service source to the approved commit SHA. Keep the previous deployment and backup for recovery. Do not assume an old binary can read a database migrated by a newer version.

## Initial verification

Verify public login page, /api/system_db, authenticated organization status, empty financial reports, and protected API denial without authentication. Configure company name, country, base currency and fiscal year before entering actual transactions.


## Retained demo and stopped state (2026-10-13)

The owner requested a single retained demonstration organization followed by shutdown. Demo Company (US, USD, America/New_York, January fiscal year) was initialized in the separate production database. Sign-in, organization readiness and the empty profit/loss report API were verified. Signup exceptions have now been cleared in Railway variables; backups remain disabled.

All six services were stopped without deleting services or volumes: their start command is temporarily `sh -c 'exit 0'`, restart policy NEVER, and HTTP healthchecks are cleared. Railway may display a successful deployment with zero running replicas; inspect replica counts instead of the green deployment label. The public site is unavailable while stopped.

To resume, restore the original start commands and healthchecks below, set restart policy ON_FAILURE (max retries 5), and reconnect each service to its configured pinned source so Railway uses the restored configuration. Start MariaDB and Redis first, then Server, Webapp, Gotenberg and Gateway. Do not simply redeploy a stopped deployment snapshot, which still contains the exit command. Blank start commands mean the Docker image default.

| Service | Original start command | Healthcheck |
| --- | --- | --- |
| MariaDB | `sh -c 'printf "%s" "$APP_INIT_SQL" > /docker-entrypoint-initdb.d/10-app.sql; exec docker-entrypoint.sh mariadbd'` | `` |
| Redis | `sh -c 'exec redis-server --appendonly yes --requirepass "$REDIS_PASSWORD"'` | `` |
| Gotenberg | `` | `` |
| Server | `sh -c 'node dist/cli.js system:migrate:latest && node dist/cli.js tenants:migrate:latest && exec node dist/main.js'` | `/api/system_db` |
| Webapp | `` | `/` |
| Gateway | `` | `/health` |

Server's final pinned source commit is `c5ceffd8a73bffa9958e505e8b5b3f66f45d97bb`. Other source/image pins remain in each Railway service. Storage and buckets are retained and may still incur storage charges. Administrator credentials are kept out of this repository.
