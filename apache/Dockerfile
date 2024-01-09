FROM govpf/apache:2.4-bullseye

USER root

RUN apt-get update \
        && apt-get install --no-install-recommends -y gettext-base \
        && rm -rf /var/lib/apt/lists/* \
        && a2enmod rewrite proxy proxy_http ssl \
        && mkdir /opt/apache-config

COPY files/* /docker-entrypoint-init.d/

USER apache
