FROM alpine:3.10


ENV GRAFANA_VERSION="7.4.2"
ENV GRAFANA_USER="grafana"
ENV GRAFANA_GROUP="grafana"
ENV GRAFANA_HOME="/usr/share/grafana"
ENV LOG_DIR="/var/log/grafana"
ENV DATA_DIR="/var/lib/grafana"
ENV MAX_OPEN_FILES="10000"
ENV CONF_DIR="/etc/grafana"
ENV CONF_FILE="/etc/grafana/grafana.ini"
ENV RESTART_ON_UPGRADE="true"
ENV PLUGINS_DIR="/var/lib/grafana/plugins"
ENV PROVISIONING_CFG_DIR="/etc/grafana/provisioning"
ENV PID_FILE_DIR="/var/run/grafana"


RUN mkdir /tmp/grafana && \
    wget -P /tmp/ https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz && \
    tar xfz /tmp/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz --strip-components=1 -C /tmp/grafana
RUN apk add --no-cache libc6-compat ca-certificates bash

RUN addgroup -S grafana && \
    adduser -S -G grafana grafana

RUN mv /tmp/grafana "$GRAFANA_HOME"
RUN mkdir -p "$CONF_DIR" \
            "$PROVISIONING_CFG_DIR"/dashboards \
            "$PROVISIONING_CFG_DIR"/datasources \
            "$PROVISIONING_CFG_DIR"/notifiers \
            "$PROVISIONING_CFG_DIR"/plugins \
            "$DATA_DIR" \
            "$PID_FILE_DIR" \
            "$LOG_DIR"

ADD asset/grafana.ini /etc/grafana/.
ADD asset/ldap.toml /etc/grafana/.
ADD asset/provisioning/dashboards/sample.yaml /etc/grafana/provisioning/dashboards/.
ADD asset/provisioning/datasources/sample.yaml /etc/grafana/provisioning/datasources/.
ADD asset/provisioning/notifiers/sample.yaml /etc/grafana/provisioning/notifiers/.
ADD asset/provisioning/plugins/sample.yaml /etc/grafana/provisioning/plugins/.

RUN chown -R grafana:grafana "$LOG_DIR" "$DATA_DIR" && \
    chown -R root:root "$CONF_DIR" "$GRAFANA_HOME" "$PID_FILE_DIR" && \
    chown -R root:grafana "$CONF_DIR"/*
RUN chmod -R 777 "$PID_FILE_DIR" && \
    chmod -R 755 "$LOG_DIR" "$DATA_DIR" "$CONF_DIR" && \
    chmod 755 "$GRAFANA_HOME"
RUN chmod 640 "$CONF_DIR"/grafana.ini "$CONF_DIR"/ldap.toml "$PROVISIONING_CFG_DIR"/*/sample.yaml

RUN cp "$GRAFANA_HOME"/bin/grafana-cli "$GRAFANA_HOME"/bin/grafana-server /usr/sbin/.

RUN rm -rf /tmp/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz


USER grafana:grafana

ADD asset/entrypoint.sh .
ENTRYPOINT ["sh", "entrypoint.sh"]

