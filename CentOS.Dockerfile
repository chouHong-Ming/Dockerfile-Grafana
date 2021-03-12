FROM centos:7.7.1908


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


RUN yum install -y wget

RUN wget https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}-1.x86_64.rpm
RUN yum install -y grafana-${GRAFANA_VERSION}-1.x86_64.rpm

RUN mkdir "$PID_FILE_DIR" && \
    chmod 777 "$PID_FILE_DIR"

RUN yum remove -y wget
RUN rm -f grafana-${GRAFANA_VERSION}-1.x86_64.rpm


ADD asset/grafana.ini /etc/grafana/.
RUN chown root:grafana /etc/grafana/grafana.ini && \
    chmod 640 /etc/grafana/grafana.ini


USER grafana:grafana

ADD asset/entrypoint.sh .
ENTRYPOINT ["sh", "entrypoint.sh"]

