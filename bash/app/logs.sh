#!/usr/bin/env bash

appLogsArgs() {
  _DESCRIPTION="Show app logs"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'container_name c "Container name suffix like site_name_suffix" false'
    'dir d "Application directory" false'
    'tail t "Keep log opened" false'
  )
}

appLogs() {
  _wexAppGoTo "${DIR:-.}" && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  local OPTIONS=""
  if [ "${TAIL}" = "true" ]; then
    OPTIONS="-f"
  fi

  docker logs ${OPTIONS} "$(wex-exec app::app/container -c="${CONTAINER_NAME:-${MAIN_CONTAINER_NAME}}")"
}
