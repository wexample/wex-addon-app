#!/usr/bin/env bash

appLogsArgs() {
  _ARGUMENTS=(
    'container_name c "Container name suffix like site_name_suffix" false'
  )
}

appLogs() {
  _wexAppGoTo && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  docker logs "$(wex app::app/container -c="${MAIN_CONTAINER_NAME}")"
}
