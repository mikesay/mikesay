## Dockerfile for Go
> Use debian version of golang image to buld go program at build stage, because the golang image of alphine version will met network/dns issue (apk update) to run in docker in docker build (dind, dood method).

```docker
# golang:1.16.2-stretch
# go version: 1.16.2
# pull from the exact digest for security purpose to make sure it is the exact image you want
#
FROM golang@sha256:098e7f9c6a628d24db7283e6b774e0b4a095a96cea157f1fb516d31e3dd575bf AS builder

# Change go proxy
#
ENV GOPROXY=https://goproxy.cn,direct

# apk update
#
RUN apt-get update && \
    apt-get install -y git tzdata ca-certificates

# Set timezone to Asia/Shanghai
#
RUN rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Africa/Shanghai" > /etc/timezone

# Setup non root user with limit option
#
RUN adduser -q \
    --gecos "First Last,RoomNumber,WorkPhone,HomePhone" \
    --disabled-password \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid 80008 \
    hello

WORKDIR $GOPATH/src/main/hello/
COPY . .

RUN go mod download && \
    go mod verify

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/hello

##
## Build real docker image
##
FROM scratch

WORKDIR /opt/work

COPY --from=builder /go/bin/hello /opt/work/hello

# Copy zoneinfo
#
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/localtime /etc/localtime
COPY --from=builder /etc/timezone /etc/timezone

# Copy the ca-certificate.crt from the build stage
#
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy running user
#
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# User non root user with limited privelege
#
USER hello:hello

# Expose the service by port. Try to use port higher 
# than 1024, so that no need root priveledge to bind
#
EXPOSE 39501

# Export directory
#
VOLUME /opt/work/configs

ENTRYPOINT ["/opt/work/hello"]
```

## Dockerfile for Python
```docker
## Create python runtime
#
FROM python:3.8-slim-buster as builder
# Use PYPI_REPO to pass customized PyPI registry
# docker build --timeout 120 -t dap-cn-sddc:latest --build-arg PYPI_REPO=-i\ xxx
# i.e -i https://<username>:<password>@xxxx/artifactory/api/pypi/xxxx-pypi-virtual/simple
ARG PYPI_REPO

WORKDIR /opt/app

# Copy python code
COPY app.py /opt/app/
COPY requirements.txt /opt/app/

# Install dependencies
RUN pip install --timeout 120 ${PYPI_REPO} -r requirements.txt

## Build real docker image
##
FROM python:3.8-slim-buster

# Setup non root user with limit option
RUN adduser \
    --gecos \
    --disabled-password \
    --disabled-login \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid 80008 \
    apprunner

WORKDIR /opt/app

# Copy python code
COPY --from=builder /opt/app/ /opt/app/

# Copy dependencies
COPY --from=builder /usr/local/lib/python3.8/site-packages/ /usr/local/lib/python3.8/site-packages/

# Define volume for config
VOLUME /opt/app/config

# Change ownership of working directory
RUN chown -R apprunner:apprunner /opt/app

# User non root user with limited privelege
USER apprunner:appruner

ENTRYPOINT ["/usr/local/bin/python", "/opt/app/app.py"]
```

## Dockerfile for Angular
```docker
FROM node:10.20.1 AS builder
WORKDIR /opt/dashboard
COPY . .
RUN npm install && \
    ./node_modules/@angular/cli/bin/ng build --prod --base-href /dashboard/ --deploy-url /dashboard/

FROM nginx:1.15.9
RUN /bin/bash -c 'mkdir -p /opt/dashboard/www/dashboard'
WORKDIR /opt/dashboard
COPY --from=builder /opt/dashboard/build/dashboard /opt/dashboard/www/dashboard/
COPY docker/start.sh /opt/dashboard/
COPY docker/dashboard.conf /etc/nginx/conf.d/

CMD ["/bin/bash", "/opt/cw-dashboard/start.sh"]
```

**dashboard.conf**
```nginx
server {
    listen 8888;
    server_name _;

    root /opt/dashboard/www;
    index index.html index.htm index.nginx-debian.html;

    location /dashboard {
        try_files $uri $uri/ /dashboard/index.html =404;
    }
}
```

**start.sh**
```bash
onfig_file="/opt/dashboard/www/dashboard/assets/data/app-config.json"

if [ ! -z "${CONTEXT_NAME}" ] && [ "${CONTEXT_NAME}" != "dashboard" ]
then
	sed -i "s/\/dashboard\//\/${CONTEXT_NAME}\//g" /opt/dashboard/www/dashboard/index.html
	sed -i "s/\/dashboard/\/${CONTEXT_NAME}/g" /etc/nginx/conf.d/dashboard.conf
	mv /opt/dashboard/www/dashboard /opt/dashboard/www/${CONTEXT_NAME}
	config_file="/opt/dashboard/www/${CONTEXT_NAME}/assets/data/app-config.json"
fi

if [ ! -z "${BACKEND_HOST}" ]
then
	sed -ibak.1 -r "s/(.*ServicesBaseUrl.*?:.*http:\/\/).*(\/api[\'|\"].*$)/\1${BACKEND_HOST}\2/g" ${config_file}
fi

nginx -g 'daemon off;'
```

## Access MacOS host from a docker container

https://medium.com/@balint_sera/access-macos-host-from-a-docker-container-e0c2d0273d7f

The host is:
```bash
host.docker.internal
```

## Start a NFS server
```bash
docker run -it -d --name nfs-server --privileged -p 2049:2049 -v /Users/mizha53/Documents/MikeStorage/MikeNFSDocker:/nfsshare -e SHARED_DIRECTORY=/nfsshare itsthenetwork/nfs-server-alpine:12
```
> Note, the volume mount will not work for client which will meet permission issue.