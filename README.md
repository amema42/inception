# Inception - Dockerized WordPress Stack

This project sets up a fully containerized WordPress environment using Docker and Docker Compose, following the Inception subject guidelines from the 42 school.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Repository Structure](#repository-structure)
3. [Initial Setup](#initial-setup)

   * [1. Clone the repository](#1-clone-the-repository)
   * [2. Create persistence directories](#2-create-persistence-directories)
   * [3. Generate secrets](#3-generate-secrets)
4. [Usage](#usage)

   * [Start the stack](#start-the-stack)
   * [Verify services](#verify-services)
   * [Browser setup](#browser-setup)
5. [Stopping & Cleanup](#stopping--cleanup)
6. [Troubleshooting](#troubleshooting)
7. [Additional Notes](#additional-notes)

---

## Prerequisites

* Docker (>= 20.10)
* Docker Compose (>= 1.29)
* `openssl` for generating certificates and passwords
* A Linux host or VM (Debian/Ubuntu recommended)

---

## Repository Structure

```
inception/
├── Makefile
├── README.md            # This guide
├── secrets/             # Secret placeholders and TLS samples
│   ├── db_root_password.txt.sample
│   ├── db_password.txt.sample
│   └── nginx.sample/
│       ├── server.crt.sample
│       └── server.key.sample
└── srcs/
    ├── docker-compose.yml
    ├── requirements/
    │   ├── mariadb/Dockerfile
    │   ├── wordpress/Dockerfile
    │   └── nginx/
    │       ├── Dockerfile
    │       └── conf/nginx.conf
    └── data/             # (Optional) custom nginx configs
```

---

## Initial Setup

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd inception
```

### 2. Create persistence directories

These directories live **outside** the repository, in your home directory:

```bash
export LOGIN=$(whoami)
# On a new machine, set LOGIN=amema or your 42 login
mkdir -p /home/$LOGIN/data/wp_db_data /home/$LOGIN/data/wp_data
```

> The database files will live in `wp_db_data`, and WordPress uploads in `wp_data`.

### 3. Generate secrets

Copy the sample placeholders and generate your own secrets locally:

```bash
# Copy placeholder files
cp secrets/db_root_password.txt.sample secrets/db_root_password.txt
cp secrets/db_password.txt.sample    secrets/db_password.txt
mkdir -p secrets/nginx
cp -r secrets/nginx.sample/* secrets/nginx/

# Generate strong passwords
openssl rand -base64 16 > secrets/db_root_password.txt
openssl rand -base64 16 > secrets/db_password.txt
chmod 600 secrets/db_*.txt

# Generate self-signed TLS cert & key
openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
  -keyout secrets/nginx/server.key \
  -out secrets/nginx/server.crt \
  -subj "/C=IT/ST=State/L=City/O=42School/OU=Inception/CN=$LOGIN.42.fr"
chmod 600 secrets/nginx/{server.key,server.crt}
```

---

## Usage

### Start the stack

```bash
make        # or: make up
```

Builds and starts all containers in detached mode.

### Verify services

```bash
docker-compose -f srcs/docker-compose.yml ps
```

You should see **nginx**, **mariadb**, and **wordpress** containers in the *Up* state.

### Browser setup

1. Add an entry to `/etc/hosts` on your host machine:

   ```
   127.0.0.1   $LOGIN.42.fr
   ```
2. Open `https://$LOGIN.42.fr` in your browser.
3. Complete the WordPress installation wizard (DB name, user, password from `secrets/`).

---

## Stopping & Cleanup

To stop and remove all containers and network:

```bash
make down   # stop and remove containers
```

To also remove volumes and images:

```bash
make clean
```

---

## Troubleshooting

* **Container restart loops**: check logs

  ```bash
  docker-compose -f srcs/docker-compose.yml logs --tail=20 <service>
  ```

- **Permissions issues**: ensure host directories and secrets have correct owners:
  - `/home/$LOGIN/data/wp_db_data` owned by UID/GID 999 (mysql)
  - `/home/$LOGIN/data/wp_data` owned by `www-data`

---

## Additional Notes

- All container images are built from Debian 12 base.
- Nginx is the sole HTTPS entrypoint, serving via FastCGI to PHP-FPM.
- Docker secrets are used for database credentials and TLS certificates.

---

Status: This README is aligned 100% with the Inception Mandatory subject.

