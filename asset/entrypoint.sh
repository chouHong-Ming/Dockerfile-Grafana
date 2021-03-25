#!/bin/bash


test -z $TIMEZONE && TIMEZONE=UTC
test -z $MOUNT_CONFIG && MOUNT_CONFIG=false

if [ -n "$PATHS_LOGS" ]; then
    if [ -w "$PATHS_LOGS" ]; then
        LOG_DIR=${PATHS_LOGS}
    else
        echo "[Warning] ${PATHS_LOGS} can't be used, use default path '${LOG_DIR}'"
        PATHS_LOGS=${LOG_DIR}
    fi
fi

if [ -n "$PATHS_DATA" ]; then
    if [ -w "$PATHS_DATA" ]; then
        DATA_DIR=${PATHS_DATA}
    else
        echo "[Warning] ${PATHS_DATA} can't be used, use default path '${DATA_DIR}'"
        PATHS_DATA=${DATA_DIR}
    fi
fi

if [ -n "$PATHS_PLUGINS" ]; then
    if [ -w "$PATHS_PLUGINS" ]; then
        PLUGINS_DIR=${PATHS_PLUGINS}
    else
        echo "[Warning] ${PATHS_PLUGINS} can't be used, use default path '${PLUGINS_DIR}'"
        PATHS_PLUGINS=${PLUGINS_DIR}
    fi
fi

if [ -n "$PATHS_PROVISIONING" ]; then
    if [ -r $PATHS_PROVISIONING ]; then
        PROVISIONING_CFG_DIR=${PATHS_PROVISIONING}
    else
        echo "[Warning] ${PATHS_PROVISIONING} can't be used, use default path '${PROVISIONING_CFG_DIR}'"
        PATHS_PROVISIONING=${PROVISIONING_CFG_DIR}
    fi
fi


if [ ! -r "$CONF_FILE" ]; then
    echo "[Warning] ${CONF_FILE} can't be read, use default config file"
    MOUNT_CONFIG=false
fi

if [ "$MOUNT_CONFIG" == "false" ]; then
    cp ${CONF_FILE} /tmp
    for ENV_PAIR in $(env); do
        ENV_KEY=$(echo "$ENV_PAIR" | cut -d'=' -f 1)
        ENV_VALUE=$(echo "$ENV_PAIR" | cut -d'=' -f 2)
        SORT=$(grep -n -w "$ENV_KEY" /tmp/grafana.ini | wc -l)
        if [ "$ENV_KEY" == "HOSTNAME" ]; then
            continue
        elif [ $SORT -eq 1 ]; then
            OLD_SETTING_LINE=$(grep "$ENV_KEY" /tmp/grafana.ini)
            NEW_SETTING_LINE=$(echo "${OLD_SETTING_LINE}" | cut -d'=' -f 1)"= ${ENV_VALUE}"
            NEW_SETTING_LINE=${NEW_SETTING_LINE:1}
            echo "[Info] Apply ENV '${ENV_KEY}'"
            sed -i -e "s/${OLD_SETTING_LINE}/${NEW_SETTING_LINE}/g" /tmp/grafana.ini
        else
            echo "[Info] ENV '${ENV_KEY}' can't match the setting key in the Grafana config file. Skip..."
        fi
    done
    cat /tmp/grafana.ini > ${CONF_FILE}
    rm -f /tmp/grafana.ini
fi


if [ -n "${PLUGINS}" ]; then
    OLDIFS=$IFS
    IFS=','
    for PLUGIN in ${PLUGINS}; do
        result=$(echo "$PLUGIN" | grep ";")
        if [[ "$result" != "" ]]; then
            PLUGIN_URL=$(echo "$PLUGIN" | cut -d';' -f 1)
            PLUGIN_NAME=$(echo "$PLUGIN" | cut -d';' -f 2)
            echo "[Info] Install Grafana plugin '${PLUGIN_NAME}' from ${PLUGIN_URL}"
            grafana-cli --pluginUrl "${PLUGIN_URL}" --pluginsDir "${PLUGINS_DIR}" plugins install ${PLUGIN_NAME}
        else
            echo "[Info] Install Grafana plugin '${PLUGIN}'"
            grafana-cli --pluginsDir "${PLUGINS_DIR}" plugins install ${PLUGIN}
        fi
    done
    IFS=$OLDIFS
fi


grafana-server \
    --homepath=${GRAFANA_HOME} \
    --config=${CONF_FILE} \
    --pidfile=${PID_FILE_DIR}/grafana-server.pid \
    --packaging=rpm \
    cfg:default.paths.logs=${LOG_DIR} \
    cfg:default.paths.data=${DATA_DIR} \
    cfg:default.paths.plugins=${PLUGINS_DIR} \
    cfg:default.paths.provisioning=${PROVISIONING_CFG_DIR}

