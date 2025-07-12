# DOCKER Basics

## Basic commands

```bash
docker --help

docker ps

docker ps -a
```

```bash
docker run --name my-web0 nginx
```
Press cntrl+c to stop the container.

```bash
docker run -d --name my-web1 nginx

docker run -d --name my-web2 httpd

docker run -d --name my-app1 alpine
```

## Working with Images

Visit https://hub.docker.com/ and create an account if needed.

Visit https://labs.play-with-docker.com/ and login using _docker_.

Clone a repo that has a nodejs sample code
```bash
git clone https://github.com/sangramrath/2170.git
```

```bash
cd 2170/CH03
```

```bash
vi Dockerfile

```bash
docker build -t links:1.0 .
```

```bash
docker images
```

```bash
docker tag links:1.0 sangramrath/links:1.0
```

```bash
docker login
```

```bash
docker push sangramrath/links:1.0
```

```bash
docker history sangramrath/links:1.0
```

## Working with Networks

```bash
docker network ls
```

```bash
docker network create prodnet
```

```bash
docker run -d -p 8082:80 --name containerinprod --network prodnet nginx
```

## Working with Volumes

### Volume Using Host Path

```bash
mkdir data

echo "<h1>Welcome to Kubernetes Competency Bootcamp!</h1>" > ~/data/index.html

docker run -d -v ~/data:/usr/share/nginx -p 8080:80 --name containerwithvolpath nginx
```

### Volume Using Named Volume

```bash
docker volume create nginxvol

docker inspect volume nginxvol

cd /var/lib/docker/volumes/

echo "<h1>Welcome to Docker Competency Bootcamp!</h1>" > index.html

docker run -d -v nginxvol:/usr/share/nginx -p 8081:80 --name containerwithvol nginx
```
