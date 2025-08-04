# Inception – Subject

### Summary:

This document is a System Administration related exercise.

**Version:** 4.0

---

## Contents

* I. Preamble – p.2
* II. Introduction – p.3
* III. General guidelines – p.4
* IV. AI Instructions – p.5
* V. Mandatory part – p.7
* VI. Bonus part – p.12
* VII. Submission and peer-evaluation – p.13

---

## Chapter I – Preamble

---

## Chapter II – Introduction

This project aims to broaden your knowledge of system administration through the use of Docker technology.
You will virtualize several Docker images by creating them in your new personal virtual machine.

---

## Chapter III – General guidelines

* This project must be completed on a **Virtual Machine**.
* All the files required for the configuration of your project must be placed in a `srcs` folder.
* A `Makefile` is also required and must be located at the **root** of your directory.
  It must set up your entire application (i.e., build Docker images using `docker-compose.yml`).
* This subject requires putting into practice concepts that, depending on your background, you may not have learned yet.
  Therefore, read extensive documentation related to Docker usage, as well as any other helpful resources.

---

## Chapter IV – AI Instructions

### ● Context

AI can assist with many tasks. Explore how AI tools can support your work — but always approach them with caution and critically assess the results.

### ● Main message

☛ Use AI to reduce repetitive or tedious tasks.
☛ Develop prompting skills — both coding and non-coding.
☛ Learn how AI systems work to avoid common risks and biases.
☛ Work with peers to build both technical and power skills.
☛ Only use AI-generated content that you fully understand and can justify.

### ● Learner rules

* Explore AI tools and learn how they work.
* Think through your problem before prompting.
* Always test, review, and question generated outputs.
* Get peer reviews — don't rely on your own judgment alone.

### ● Phase outcomes

* Develop prompting skills.
* Boost productivity with AI tools.
* Strengthen computational thinking, adaptability, and collaboration.

### ● Comments and examples

**✓ Good practice**:

> I ask AI: “How do I test a sorting function?” It gives me ideas. I test them and review results with a peer. We refine it together.

**✗ Bad practice**:

> I ask AI to write a function, copy-paste it, but can't explain it during evaluation. I fail the project.

---

## Chapter V – Mandatory part

You must set up a small infrastructure with different services under strict rules.

* Must use **Docker Compose**.
* Each service = separate container.
* Base image: either **penultimate stable** version of Alpine or Debian.
* You must **write your own Dockerfiles**, one per service.
* No pulling pre-made images or DockerHub (Alpine/Debian allowed).
* Docker images built via Makefile which calls `docker-compose.yml`.

### Required services:

* A container with **NGINX** and **TLSv1.2 or TLSv1.3** only.
* A container with **WordPress + php-fpm only** (no nginx).
* A container with **MariaDB only** (no nginx).
* A **volume for WordPress DB**.
* A **volume for WordPress website files**.
* A **Docker network** for connecting all containers.

> Containers must **auto-restart** if they crash.

**Forbidden practices:**

* `network: host`
* `--link`, `links:`
* Infinite loops: `tail -f`, `bash`, `sleep infinity`, `while true`
* Latest tag usage
* Storing passwords in Dockerfiles

> You must read about **PID 1** and daemon practices in Docker.

### WordPress Database:

* Must include 2 users — one must be administrator.
* Administrator username **must not contain**: `admin`, `administrator`, `Admin`, etc.

Volumes available under:
`/home/login/data` → Replace `login` with your 42 username.

Domain must resolve to:
`login.42.fr` → Replace `login` with your username.

> Your **NGINX container** must be the sole entry point, exposed only on **port 443** with **TLSv1.2 or TLSv1.3**.

### Environment variables:

* Required: Use `.env` file.
* Use **Docker secrets** for sensitive data.
* Credentials/API keys **must be ignored by git**.

---

## Directory structure example

```
.
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── mariadb/
│       │   ├── Dockerfile
│       │   └── ...
│       ├── nginx/
│       │   ├── Dockerfile
│       │   └── ...
│       └── wordpress/
│           ├── Dockerfile
│           └── ...
```

Example `.env`:

```env
DOMAIN_NAME=wil.42.fr

# MYSQL SETUP
MYSQL_USER=XXXXXXXXXXXX
```

---

## Chapter VI – Bonus part

Each bonus must run in its own container with its own Dockerfile.
Volumes are allowed if needed.

### Suggested Bonuses:

* Add **Redis cache** for WordPress.
* Add an **FTP server** for WordPress volume.
* Create a **simple static site** (any language except PHP).
* Set up **Adminer**.
* Add a service of your choice and justify it during defense.

> You may open extra ports **only** for bonus services.
> Bonus **only evaluated if mandatory part is perfect** (no bugs, all features working).

---

## Chapter VII – Submission and peer-evaluation

* Submit your project to Git **as usual**.
* Only your repo will be evaluated.
* Be careful with filenames and structure.

During evaluation:

* You may be asked to **make minor changes** (small edits, logic changes, etc.).
* This is to assess your **true understanding**.
* You can use **any environment** during this step.
* Expected to complete within a few minutes unless specified otherwise.

---