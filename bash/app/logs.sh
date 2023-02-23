#!/usr/bin/env bash

appLogsArgs() {
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'container_name c "Container name suffix like site_name_suffix" false'
  )
}

appLogs() {
  _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  docker logs "$(wex-exec app::app/container -c="${CONTAINER_NAME:-${MAIN_CONTAINER_NAME}}")"
}
