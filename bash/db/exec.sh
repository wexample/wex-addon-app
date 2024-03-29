#!/usr/bin/env bash

dbExecArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Execute a command or a request inside database"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'command c "Database request or command" true'
    'verbose v "Print command in log" false'
  )
}

dbExec() {
  . "${WEX_FILEPATH_REL_CONFIG_BUILD}"

  local DB_EXEC_COMMAND=$(wex-exec service/exec -c=dbExec -a="${COMMAND}")

  if [[ ${VERBOSE} == true ]]; then
    _wexLog "Database exec : ${COMMAND}"
  fi

  wex-exec app/exec -n="${DB_CONTAINER}" -c="${DB_EXEC_COMMAND}"
}
