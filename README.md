# espocrm-railway

EspoCRM 10.0.6 packaged for Railway.

Upstream image: `espocrm/espocrm:10.0.6`. Published as
`ghcr.io/bon5co/espocrm-railway:10.0.6`.

## What this wrapper changes

* **The volume is mounted at `/var/www/html/data`, not at `/var/www/html`.**
  Upstream's entrypoint treats a mount on the document root as the "legacy"
  layout (`isLegacy()` in `entrypoint-utils.sh`) and returns before installing
  anything, so a deploy that mounts the document root serves an empty directory.
* `custom/` and `client/custom/` are symlinked onto that volume, with upstream's
  skeletons seeded on first boot, so customisations survive a redeploy.
  Upstream's `chown -R ./custom` cannot descend through those symlinks, so the
  ownership repair is redone on the real directories.
* The admin password is re-applied on every boot. Upstream seeds it only on the
  one-time install path, so a stock instance can never rotate it and a fresh
  deploy has no SMTP for the emailed reset.
* The container refuses to boot when `ESPOCRM_ADMIN_PASSWORD` is empty or equal
  to upstream's documented default, `password`.
* Apache listens on Railway's injected `$PORT`.
* The scheduled-job daemon runs alongside Apache.

## Required variables

| Variable | Notes |
| --- | --- |
| `ESPOCRM_ADMIN_USERNAME` | Defaults to `admin`. |
| `ESPOCRM_ADMIN_PASSWORD` | Required. Boot fails if empty or `password`. |
| `ESPOCRM_DATABASE_*` | Platform, host, name, user, password. |
| `ESPOCRM_SITE_URL` | Public URL of the deployment. |
