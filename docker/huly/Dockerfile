# BOSS Platform — All-in-One Huly Container
# Single container with Huly + CockroachDB + MinIO managed by supervisord
# Targets Akash deployment with minimal complexity

FROM alpine:3.19

# Install dependencies
RUN apk add --no-cache \
    bash curl ca-certificates supervisor nginx \
    nodejs npm openssl tzdata \
    py3-pip

# ============================================================
# Download CockroachDB binary
# ============================================================
RUN wget -q -O /tmp/cockroach.tgz "https://binaries.cockroachdb.com/cockroach-v24.2.5.linux-amd64.tgz" && \
    tar -xzf /tmp/cockroach.tgz -C /tmp/ && \
    mv /tmp/cockroach-v24.2.5.linux-amd64/cockroach /usr/local/bin/ && \
    rm -rf /tmp/cockroach*

# ============================================================
# Download MinIO binary
# ============================================================
RUN wget -q -O /usr/local/bin/minio "https://dl.min.io/server/minio/release/linux-amd64/minio" && \
    chmod +x /usr/local/bin/minio

# ============================================================
# Create all needed directories
# ============================================================
RUN mkdir -p /data/cockroach /data/minio /data/huly /var/log/supervisor /var/run/supervisor

# ============================================================
# Supervisor config
# ============================================================
COPY docker/huly/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ============================================================
# Entrypoint
# ============================================================
COPY docker/huly/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=180s --retries=5 \
  CMD curl -f http://localhost:8080/ || exit 1

ENTRYPOINT ["/entrypoint.sh"]
