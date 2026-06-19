# Huly Deployment Guide — BOSS Platform

## Option 1: VPS Deployment (Recommended for Initial Setup)

### Prerequisites
- VPS with 4 vCPU, 16GB RAM, 100GB SSD
- Docker + Docker Compose installed
- Domain: `huly.boss.warrior.world`

### Steps

```bash
# 1. SSH into VPS
ssh root@your-vps-ip

# 2. Install Docker (if not installed)
curl -fsSL https://get.docker.com | sh
apt-get install -y docker-compose-plugin

# 3. Clone Huly self-host
git clone https://github.com/hcengineering/huly-selfhost.git /opt/huly
cd /opt/huly

# 4. Configure
cp .template.huly.conf .env
# Edit .env with:
# - HOST_ADDRESS=huly.boss.warrior.world
# - SECRET=<random-secret>
# - CR_DATABASE=huly
# - CR_USERNAME=huly
# - CR_USER_PASSWORD=<strong-password>

# 5. Deploy
./setup.sh
sudo ln -s $(pwd)/nginx.conf /etc/nginx/sites-enabled/huly.conf
sudo nginx -s reload
sudo docker compose up -d

# 6. Verify
curl http://localhost:8087
# Should return Huly UI HTML

# 7. Set up SSL (optional, Cloudflare recommended)
# If using Cloudflare: proxy through Cloudflare (SSL automatically)
# If using Let's Encrypt:
certbot --nginx -d huly.boss.warrior.world
```

### Initial Configuration

1. Open `http://huly.boss.warrior.world` (or your server IP:8087)
2. Create admin account
3. Create workspace "BOSS Platform"
4. Invite users: GI Honey, Aaliyah, Chelsea
5. Create project templates for businesses

## Option 2: Akash Network Deployment (Web3)

### Prerequisites
- Akash Console account with credits
- Docker image pushed to registry

### Steps

1. Build the all-in-one Docker image:
```bash
docker build -t warriorworld/boss-huly:latest -f docker/huly/Dockerfile .
docker push warriorworld/boss-huly:latest
```

2. Deploy via Akash Console:
   - Go to console.akash.network
   - Click "New Deployment"
   - Upload `sdl/huly-lite.yaml`
   - Wait for bids (30-120 seconds)
   - Accept cheapest provider bid
   - Wait for deployment to start
   - Note the ingress URI

3. Configure DNS:
   - Point `huly.boss.warrior.world` → ingress URI via CNAME
   - Cloudflare proxy for SSL

### Troubleshooting

| Symptom | Solution |
|---------|----------|
| Container crash loop | Check logs: `docker compose logs [service]` |
| Database connection refused | CockroachDB needs 30-60s to initialize |
| 502 Bad Gateway | Services not ready yet; wait 2-3 minutes |
| Image pull timeout | Image >50MB; use smaller base image |
| Persistent storage missing | SDL needs `params.storage.persistent` section |
