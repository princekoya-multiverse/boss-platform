#!/bin/bash
set -e

# Start nginx in background (it will daemonize since config does not have daemon off)
nginx -c /etc/nginx/nginx.conf

# Execute the original CMD from the base image
# This is passed via ENTRYPOINT from the Dockerfile
exec "$@"
