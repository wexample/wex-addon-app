#!/usr/bin/env bash

appExecArgs() {
  _NEEDS_APP_LOCATION=true
  # shellcheck disable=SC2034
  _DESCRIPTION="Execute a script from inside the container, at project root"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'container_name n "Container name suffix like site_name_suffix. Default is web" false'
    'command c "Bash command to execute" true'
    'dir d "Application directory" false'
    'starts "Start container verification" false'
    'localized l "Execute script in project location" false false'
    'super_user su "Run as sudo inside container" false'
    'user_uid u "Run as given user (overridden by super_user argument)" false'
    'verbose vv "Print command in log" false'
  )
}

appExec() {
  if [ "$(wex-exec app::app/started -ic)" = "false" ]; then
    return
  fi

  . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  # Use default container if missing
  local CONTAINER=$(wex-exec app::app/container -c="${CONTAINER_NAME}")
  local COMMAND_GO=":"

  CONTAINER_NAME=${CONTAINER_NAME:-${MAIN_CONTAINER_NAME}}

  CONTAINER=$(wex-exec app::app/container -c="${CONTAINER_NAME}")

  local ARGS=""
  if [ "${NON_INTERACTIVE}" != true ]; then
    ARGS+="-ti"
  fi

  if [[ ${SUPER_USER} == true ]]; then
    USER_UID=0
  fi

  if [[ "${USER_UID}" != "" ]]; then
    ARGS+=" -u ${USER_UID} "
  fi

  if [ "${INFO}" == "true" ]; then
    _wexLog "${COMMAND}"
  fi

  EXEC_COMMAND=${COMMAND}
  SHELL_COMMAND=${SHELL_COMMAND:-/bin/bash}

  if [ "${LOCALIZED}" == true ]; then
    local COMMAND_GO=$(wex-exec hook/exec -c=appGo -a="${CONTAINER_NAME}" --quiet)
    COMMAND="${COMMAND_GO} && ${EXEC_COMMAND}"
  else
    COMMAND="${EXEC_COMMAND}"
  fi

  if [ "${VERBOSE}" = "true" ]; then
    _wexLog "Running command in container ${CONTAINER} : ${COMMAND}"
  fi

  docker exec ${ARGS} "${CONTAINER}" "${SHELL_COMMAND}" -c "${COMMAND}"
}
