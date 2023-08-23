# Kong + Google OAuth 2.0

This repository aims to integrate Kong with Google Login, being based on:

- https://github.com/revomatico/kong-oidc

- https://github.com/revomatico/docker-kong-oidc



## Development

This repo uses [Task](https://taskfile.dev/). Task is a task runner / build tool that aims to be simpler and easier to use than, for example, GNU Make.

```
cp .env.example .env

task download

task config

task up
```


## Usage

Generate a strong cookie secret use the command:

```
python -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(32)).decode())'
```


Replace the content of the `.env` file and configure the `kong-template.yaml` with your variables.

Your custom Dockerfile:

```
FROM heitorcarneiro/docker-kong-oidc:3.4.0-1

USER root

ENV KONG_DECLARATIVE_CONFIG="/opt/kong/kong.yaml"
ENV KONG_PLUGINS="bundled,oidc"
ENV KONG_LOG_LEVEL="error"

RUN mkdir -p /opt/kong
COPY kong.yaml /opt/kong/kong.yaml
RUN chown -R kong:kong /opt/kong

USER kong
```

Then, execute the following command:

```
task run
```
