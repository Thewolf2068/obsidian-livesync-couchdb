FROM couchdb:latest

RUN apt-get update && apt-get install -y curl unzip && \
    curl -fsSL https://deno.land/install.sh | sh && \
    mv /root/.deno/bin/deno /usr/local/bin/deno && \
    rm -rf /root/.deno /var/lib/apt/lists/*

COPY couchdb-init.sh /couchdb-init.sh
COPY generate_setupuri.ts /generate_setupuri.ts
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh /couchdb-init.sh

ENTRYPOINT ["/entrypoint.sh"]
