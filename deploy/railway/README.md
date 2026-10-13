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
