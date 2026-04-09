# Obsidian LiveSync CouchDB

__Project Status: Maintenance Mode. CouchDB and the LiveSync plugin rarely change their core container requirements. A lack of recent commits indicates this image is stable, not abandoned. In case anything ever happens, I will try to fix it ASAP__

A custom CouchDB Docker image that fully automates the database initialization process for Obsidian LiveSync. This eliminates the need to manually execute setup scripts inside the container, allowing for a fully declarative, IaC deployment.


# Usage

Deploy using Docker Compose. The container will automatically create the admin user, configure the required database settings, and generate the setup URI on its first boot.

__Note: Upon initial startup, check the container logs (docker logs couchdb-livesync). The encrypted Setup URI required for the Obsidian plugin will be printed there.__
```yaml
services:
  couchdb-livesync:
    image: ghcr.io/thewolf2068/obsidian-livesync-couchdb:1
    container_name: couchdb-livesync
    user: 1000:1000 # Officially 5984, but 1000:1000 works for standard local user mapping
    environment:
      COUCHDB_USER: admin
      COUCHDB_PASSWORD: changeme
      OLS_HOSTNAME: https://obsidian.yourdomain.com # Alternatively use http://localhost:5984
      OLS_DATABASE: obsidiannotes
      OLS_PASSPHRASE: changeme
      # Optional: override CouchDB port (default 5984)
      # COUCHDB_PORT: 5984
    volumes:
      - ./data:/opt/couchdb/data
    ports:
      - 5984:5984
    restart: unless-stopped
```

## Next Steps

Once your container is running and you have copied your encrypted Setup URI from the logs, you need to configure the Obsidian plugin:

1. Install **Obsidian LiveSync** from the community plugins list in Obsidian.
2. Open the plugin settings and use the **Setup URI** to configure your connection.

For full instructions on using the plugin, refer to the [official Obsidian LiveSync repository](https://github.com/vrtmrz/obsidian-livesync/blob/main/docs/setup_own_server.md#2-setup-self-hosted-livesync-to-obsidian).
