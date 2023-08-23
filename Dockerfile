# Base kong image
FROM cristianchiru/docker-kong-oidc:3.4.0-1 AS kong-base

USER root

ENV DEV_PACKAGES="libssl-dev make gcc git curl unzip"

RUN set -ex \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y $DEV_PACKAGES \
    ## Install plugins
    && luarocks install kong-jwt2header \
    && luarocks install kong-path-allow \
    && luarocks install kong-plugin-response-cache \
    && luarocks install kong-plugin-upstream-google-id-token \
    ## Cleanup
    && rm -fr *.rock* \
    # && rm -f /usr/local/openresty/nginx/modules/ngx_wasm_module.so \
    && apt-get purge -y $DEV_PACKAGES \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt \
    ## Create kong and working directory (https://github.com/Kong/kong/issues/2690)
    && mkdir -p /usr/local/kong \
    && chown -R kong:`id -gn kong` /usr/local/kong

USER kong


# Build kong
FROM kong-base

USER root

ENV KONG_NGINX_PROXY_GZIP="on"
ENV KONG_NGINX_PROXY_GZIP_DISABLE="msie6"
ENV KONG_NGINX_PROXY_GZIP_VARY="on"
ENV KONG_NGINX_PROXY_GZIP_PROXIED="any"
ENV KONG_NGINX_PROXY_GZIP_COMP_LEVEL="6"
ENV KONG_NGINX_PROXY_GZIP_BUFFERS="16 8k"
ENV KONG_NGINX_PROXY_GZIP_HTTP_VERSION="1.1"
ENV KONG_NGINX_PROXY_GZIP_MIN_LENGTH="256"
ENV KONG_NGINX_PROXY_GZIP_TYPES="application/atom+xml application/geo+json application/javascript application/x-javascript application/json application/ld+json application/manifest+json application/rdf+xml application/rss+xml application/xhtml+xml application/xml font/eot font/otf font/ttf image/svg+xml text/css text/javascript text/plain text/xml"

ENV KONG_DATABASE="off"
ENV KONG_PROXY_LISTEN="0.0.0.0:8080"
ENV KONG_ADMIN_LISTEN="0.0.0.0:8001"
ENV KONG_STATUS_LISTEN="0.0.0.0:8100"
ENV KONG_CLUSTER_LISTEN="off"
ENV KONG_ADMIN_ACCESS_LOG="off"
ENV KONG_PROXY_ACCESS_LOG="off"
ENV KONG_ADMIN_GUI_ACCESS_LOG="off"
ENV KONG_PORTAL_API_ACCESS_LOG="off"
ENV KONG_PROXY_ERROR_LOG="/dev/stderr"
ENV KONG_ADMIN_ERROR_LOG="/dev/stderr"
ENV KONG_ADMIN_GUI_ERROR_LOG="/dev/stderr"
ENV KONG_PORTAL_API_ERROR_LOG="/dev/stderr"
ENV KONG_ANONYMOUS_REPORTS="false"
ENV KONG_LOG_LEVEL="error"

ENV KONG_DECLARATIVE_CONFIG="/opt/kong/kong.yaml"
ENV KONG_PLUGINS="bundled,oidc"

RUN mkdir -p /opt/kong
COPY kong.yaml /opt/kong/kong.yaml
RUN chown -R kong:kong /opt/kong

USER kong
