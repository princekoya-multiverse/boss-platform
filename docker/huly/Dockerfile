# Minimal Huly single-container image for Akash
# Uses official front image + nginx reverse proxy
FROM hardcoreeng/front:v0.7.423

# Install nginx
RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/nginx/sites-enabled/default

# Configure nginx as reverse proxy to the front service (port 8080)
COPY nginx.conf /etc/nginx/nginx.conf

# Startup script that launches nginx then runs the original CMD
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80

# Use ENTRYPOINT wrapper so original CMD from base image passes through
ENTRYPOINT ["/start.sh"]
