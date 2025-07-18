# Inception

A Docker-based web infrastructure project that virtualizes a complete web stack using Docker Compose.

## 📋 Project Overview

This project implements a small infrastructure composed of different services under specific rules. The entire project runs in a virtual machine using Docker Compose to orchestrate multiple containerized services.

### Architecture

The infrastructure consists of three main services:
- **NGINX**: Web server with TLS encryption (entry point)
- **WordPress**: Content management system with PHP-FPM
- **MariaDB**: Database server

All services communicate through a custom Docker network and use persistent volumes for data storage.

## 🏗️ Infrastructure Components

### Services

1. **NGINX Container**
   - Serves as the sole entry point to the infrastructure
   - Configured with TLSv1.2/TLSv1.3 only
   - Accessible only via port 443 (HTTPS)
   - Self-signed SSL certificates

2. **WordPress Container**
   - PHP-FPM configuration without NGINX
   - Connected to MariaDB database
   - Manages website content and user authentication

3. **MariaDB Container**
   - Database server for WordPress
   - Configured with secure root access
   - Stores all WordPress data

### Volumes

- **WordPress Volume**: Contains website files (`/home/<userlogin>/data/wordpress`)
- **MariaDB Volume**: Contains database files (`/home/<userlogin>/data/mariadb`)

### Network

- **Custom Docker Network**: `inception` - enables communication between containers

## 🔧 Configuration

### Environment Variables

The project uses a `.env` file and Docker secrets for secure configuration:

```env
DOMAIN_NAME=userlogin.42.fr
MYSQL_DATABASE=WordPressDB
CERTS_KEY=/etc/ssl/private/nginx-selfsigned.key
CERTS_CRT=/etc/ssl/certs/nginx-selfsigned.crt
```

### Docker Secrets

Sensitive information is stored in separate secret files:
- `mysql_user.txt`
- `mysql_password.txt`
- `mysql_root_password.txt`
- `wp_admin_user.txt`
- `wp_admin_password.txt`
- `wp_user.txt`
- `wp_user_password.txt`

## 🚀 Installation & Usage

### Prerequisites

- Virtual Machine (Ubuntu/Debian recommended)
- Docker and Docker Compose installed
- Sudo privileges

### Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd inception
   ```

2. **Setup and run the infrastructure**
   ```bash
   make all
   ```

3. **Access the website**
   - Open your browser and navigate to `https://userlogin.42.fr`
   - For admin access: `https://userlogin.42.fr/wp-admin`

### Available Commands

```bash
# Start the infrastructure
make all

# Stop all services
make down

# Clean up (remove volumes and reset)
make clean

# Restart the infrastructure
make re

# Prepare system (install Docker)
make prepare
```

## 📁 Project Structure

```
inception/
├── Makefile
├── secrets/
│   ├── mysql_user.txt
│   ├── mysql_password.txt
│   ├── mysql_root_password.txt
│   ├── wp_admin_user.txt
│   ├── wp_admin_password.txt
│   ├── wp_user.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── mariadb.cnf
        │   └── tools/
        │       └── setup.sh
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       ├── http.conf
        │       └── https.conf
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            │   └── www.conf
            └── tools/
                └── setup.sh
```

## 🔒 Security Features

- **TLS Encryption**: Only TLSv1.2 and TLSv1.3 protocols allowed
- **Docker Secrets**: Sensitive data stored securely
- **No Root Access**: MariaDB configured with secure authentication
- **Network Isolation**: Custom Docker network for internal communication
- **Self-signed Certificates**: SSL/TLS encryption for HTTPS

## 🛠️ Technical Details

### Container Specifications

- **Base Images**: Debian Bullseye (stable)
- **Init Process**: Docker init to handle zombie processes
- **Health Checks**: MariaDB container includes health monitoring
- **Restart Policy**: All containers restart automatically on failure

### WordPress Configuration

- **Admin User**: `theboss` (configurable via secrets)
- **Regular User**: `theuser` (configurable via secrets)
- **Database**: `WordPressDB`
- **PHP Version**: 7.4 with FPM

### Database Security

- Root password protection
- Anonymous user removal
- Test database removal
- Secure authentication plugins

## 🔧 Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure proper sudo privileges
2. **Port 443 in Use**: Stop other web servers using port 443
3. **Domain Resolution**: The Makefile automatically adds the domain to `/etc/hosts`
4. **Container Startup**: Check container logs with `docker logs <container-name>`

### Useful Commands

```bash
# Check container status
docker ps

# View container logs
docker logs <container-name>

# Access container shell
docker exec -it <container-name> bash

# Check volumes
docker volume ls

# Inspect network
docker network inspect inception
```

## 📝 Notes

- The project uses the domain `userlogin.42.fr` (replace with your login)
- All containers restart automatically on system reboot
- Volumes are persistent and survive container restarts
- SSL certificates are self-signed (browser will show security warning)

## 🎯 Project Requirements Compliance

✅ **Mandatory Requirements Met:**
- Docker Compose orchestration
- Custom Dockerfiles for each service
- TLS-only NGINX configuration
- Separate containers for each service
- Persistent volumes for data storage
- Custom Docker network
- Environment variables and secrets
- Health checks and restart policies
- Secure database configuration

---
*Replace "userlogin" on all fields with the name of your choice.*
*This project is part of the 42 School curriculum, focusing on system administration and containerization technologies.*
