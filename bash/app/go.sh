#!/usr/bin/env bash

appGoArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Enter into the main app container"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'container_name c "Container name suffix like site_name_suffix" false'
    'dir d "Application directory" false'
    'super_user su "Run as sudo inside container" false'
    'user_uid u "Run as given user (overridden by super_user argument)" false'
  )
}

appGo() {
  # Use default container if missing
  local CONTAINER
  local COMMAND

  _wexAppGoTo "${DIR:-.}"
  . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  CONTAINER_NAME=${CONTAINER_NAME:-${MAIN_CONTAINER_NAME}}

  CONTAINER=$(wex-exec app::app/container -c="${CONTAINER_NAME}")

  COMMAND_GO=$(wex-exec hook/exec -c=appGo -a="${CONTAINER_NAME}" --quiet)

  if [[ ${SUPER_USER} == true ]]; then
    USER_UID=0
  fi

  if [[ "${USER_UID}" != "" ]]; then
    ARGS+=" -u ${USER_UID} "
  fi

  SHELL_COMMAND=${SHELL_COMMAND:-/bin/bash}

  if [ "${COMMAND_GO}" != "" ]; then
    COMMAND="${COMMAND_GO} && ${SHELL_COMMAND}"
  else
    COMMAND="${SHELL_COMMAND}"
  fi

  docker exec -it ${ARGS} "${CONTAINER}" "${SHELL_COMMAND}" -c "${COMMAND}"
}
