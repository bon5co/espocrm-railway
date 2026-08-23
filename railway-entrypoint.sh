#!/bin/bash
# Runs before upstream's docker-entrypoint.sh, i.e. before EspoCRM installs or
# migrates. Its only job is to make the volume usable.
set -euo pipefail

DATA_DIR=/var/www/html/data

echo "[railway] volume owner before repair: $(stat -c %u:%g "$DATA_DIR")"

# Railway mounts volumes owned by uid 0 while EspoCRM runs as www-data.
mkdir -p "$DATA_DIR/.custom" "$DATA_DIR/.client-custom"
# Seed the customisation skeletons upstream ships in the image layer. cp -n so a
# redeploy never overwrites customisations already on the volume.
cp -rn /usr/src/espocrm-custom/custom/. "$DATA_DIR/.custom/"
cp -rn /usr/src/espocrm-custom/client-custom/. "$DATA_DIR/.client-custom/"
chown -R www-data:www-data "$DATA_DIR"

if [ -z "${ESPOCRM_ADMIN_PASSWORD:-}" ]; then
    echo >&2 "[railway] ESPOCRM_ADMIN_PASSWORD is empty. Refusing to boot with the upstream default."
    exit 1
fi
if [ "${ESPOCRM_ADMIN_PASSWORD}" = "password" ]; then
    echo >&2 "[railway] ESPOCRM_ADMIN_PASSWORD is the publicly documented upstream default. Refusing to boot."
    exit 1
fi

exec /usr/local/bin/docker-entrypoint.sh "$@"
