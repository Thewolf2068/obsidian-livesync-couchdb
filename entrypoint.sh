#!/bin/bash
set -e

# ---- Validate required env vars ----
: "${COUCHDB_USER:?COUCHDB_USER is required}"
: "${COUCHDB_PASSWORD:?COUCHDB_PASSWORD is required}"
: "${OLS_HOSTNAME:?OLS_HOSTNAME is required}"
: "${OLS_DATABASE:?OLS_DATABASE is required}"
: "${OLS_PASSPHRASE:?OLS_PASSPHRASE is required}"

COUCH_URL="http://localhost:${COUCHDB_PORT:-5984}"

# ---- NEW: Inject Admin Credentials ----
# Manually write the credentials so the CouchDB binary doesn't panic
echo "Configuring CouchDB admin account..."
echo "[admins]" > /opt/couchdb/etc/local.d/docker.ini
echo "${COUCHDB_USER} = ${COUCHDB_PASSWORD}" >> /opt/couchdb/etc/local.d/docker.ini

# ---- Start CouchDB in background ----
/opt/couchdb/bin/couchdb &

echo "Waiting for CouchDB to start..."
until curl -sf "$COUCH_URL" > /dev/null; do sleep 1; done
echo "CouchDB is up."

# ---- First-time init ----
if [ ! -f /opt/couchdb/data/.ols_initialized ]; then
    echo "Running first-time initialization..."

    # Run vendored init script, explicitly passing vars to avoid
    # collision with the shell built-in $hostname variable
    hostname="$COUCH_URL" \
    username="$COUCHDB_USER" \
    password="$COUCHDB_PASSWORD" \
    bash /couchdb-init.sh

    # Create the notes database
    curl -sf -X PUT "$COUCH_URL/$OLS_DATABASE" \
        -u "$COUCHDB_USER:$COUCHDB_PASSWORD" || true

    # Map our env vars to what the Deno script expects,
    # again explicitly overriding $hostname
    export hostname="$OLS_HOSTNAME"
    export database="$OLS_DATABASE"
    export passphrase="$OLS_PASSPHRASE"
    export username="$COUCHDB_USER"
    export password="$COUCHDB_PASSWORD"

    echo ""
    echo "========================================"
    echo "  Self-hosted LiveSync Setup"
    echo "========================================"
    echo ""
    deno run -A /generate_setupuri.ts
    echo ""
    echo "  Save the passphrase above somewhere safe."
    echo "  It will NOT be shown again."
    echo "========================================"
    echo ""

    touch /opt/couchdb/data/.ols_initialized
else
    echo "CouchDB already initialized, skipping."
fi

# ---- Hand off to foreground CouchDB ----
wait
