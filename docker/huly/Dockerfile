# BOSS Platform — All-in-One Huly Deployment
# Business Operating Solution System (BO$$)
# Version: 1.0.0
# Builds a single container with Huly + all dependencies

FROM debian:bookworm-slim AS base

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget gnupg ca-certificates supervisor \
    nginx nodejs npm python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# === Install CockroachDB (single-node) ===
FROM cockroachdb/cockroach:latest-v24.2 AS cockroach

# === Install MinIO ===
FROM minio/minio AS minio

# === Install Elasticsearch 7.14 ===
FROM elasticsearch:7.14.2 AS elastic

# === Build Stage ===
FROM node:20-bookworm AS builder

WORKDIR /build

# Install rush
RUN npm install -g @microsoft/rush

# Clone Huly platform
RUN git clone https://github.com/hcengineering/platform.git /build/huly && \
    cd /build/huly && \
    git checkout v0.7.423

WORKDIR /build/huly

# Build Huly (this takes a while)
RUN rush install && rush build && rush bundle && rush package

# === Runtime Stage ===
FROM debian:bookworm-slim

# Install runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl jq supervisor nginx ca-certificates \
    openssl procps \
    && rm -rf /var/lib/apt/lists/*

# Node.js runtime
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Copy CockroachDB binary
COPY --from=cockroach /cockroach/cockroach /usr/local/bin/cockroach

# Copy MinIO binary
COPY --from=minio /usr/bin/minio /usr/local/bin/minio

# Copy Elasticsearch
COPY --from=elastic /usr/share/elasticsearch /usr/share/elasticsearch
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch ingest-attachment || true

# Create directories
RUN mkdir -p /data/cockroach /data/minio /data/elastic /data/redpanda && \
    mkdir -p /var/log/supervisor /var/run/supervisor

# Add dedicated user
RUN useradd -m -s /bin/bash huly

# === Supervisor Config ===
COPY docker/huly/supervisord.conf /etc/supervisor/supervisord.conf
COPY docker/huly/services/*.conf /etc/supervisor/conf.d/

# === Huly Services ===
COPY --from=builder /build/huly/dev/ /opt/huly/

# === Nginx Config ===
COPY docker/huly/nginx/huly.conf /etc/nginx/conf.d/default.conf

# === Entrypoint ===
COPY docker/huly/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD curl -f http://localhost:8087/ || exit 1

EXPOSE 8087 9000 9001 9200 3333 3000 8094 8099 4900

VOLUME ["/data"]

ENTRYPOINT ["/entrypoint.sh"]
