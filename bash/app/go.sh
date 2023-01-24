#!/usr/bin/env bash

appGoArgs() {
  _ARGUMENTS=(
    'container_name c "Container name suffix like site_name_suffix" false'
    'super_user su "Run as sudo inside container" false'
  )
}

appGo() {
  # Use default container if missing
  local CONTAINER
  local COMMAND

  _wexAppGoTo && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  CONTAINER=$(wex app::app/container -c="${CONTAINER_NAME:-${MAIN_CONTAINER_NAME}}")
  COMMAND=$(wex hook/exec -c=appGo --quiet)

  if [ "${SUPER_USER}" = "true" ];then
    ARGS+=" -u 0 "
  fi

  if [ "${COMMAND}" != '' ];then
    docker exec -it ${ARGS} "${CONTAINER}" /bin/bash -c "${COMMAND} && /bin/bash"
  else
    docker exec -it ${ARGS} "${CONTAINER}" /bin/bash
  fi
}
