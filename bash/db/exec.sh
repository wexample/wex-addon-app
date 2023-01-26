#!/usr/bin/env bash

dbExecArgs() {
  _ARGUMENTS=(
    'command c "Database request or command" true'
    'verbose v "Print command in log" false'
  )
}

dbExec() {
  _wexAppGoTo . && . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  local DB_EXEC_COMMAND=$(wex service/exec -c=dbExec -a="${COMMAND}")

  if [[ ${VERBOSE} == true ]]; then
    _wexLog "Database exec : ${COMMAND}"
  fi

  wex app/exec -n="${DB_CONTAINER}" -c="${DB_EXEC_COMMAND}"
}
