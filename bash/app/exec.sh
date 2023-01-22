#!/usr/bin/env bash

appExecArgs() {
  _DESCRIPTION="Execute a script from inside the container, at project root"
  _ARGUMENTS=(
    'container_name n "Container name suffix like site_name_suffix. Default is web" false'
    'command c "Bash command to execute" true'
    'starts "Start container verification" false'
    'localized l "Execute script in project location" false true'
    'super_user su "Run as sudo inside container" false'
    'inform i "Print command in log" false'
  )
}

appExec() {
  if [ "$(wex app::app/started -ic)" = "false" ];then
    return
  fi

  _wexAppGoTo && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  # Use default container if missing
  local CONTAINER=$(wex app::app/container -c="${CONTAINER_NAME}")

  if [ "${LOCALIZED}" == true ];then
    COMMAND="$(wex service/exec -c=appGo) && ${COMMAND}"
  fi;

  local ARGS=""
  if [ "${NON_INTERACTIVE}" != true ];then
    ARGS+="-ti"
  fi;

  if [ "${SUPER_USER}" = "true" ];then
    ARGS+=" -u 0 "
  fi

  if [ "${INFO}" == "true" ]; then
    _wexLog "${COMMAND}"
  fi

  docker exec ${ARGS} "${CONTAINER}" /bin/bash -c "${COMMAND}"
}