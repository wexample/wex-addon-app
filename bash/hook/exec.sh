#!/usr/bin/env bash

hookExecArgs() {
  _ARGUMENTS=(
    'args a "Arguments to pass" false'
    'command c "Command name" true'
  )
}

hookExec() {
  wex-exec app::service/exec -c="${COMMAND}" -a="${ARGS}"
  wex-exec app::script/exec -c="${COMMAND}" -a="${ARGS}"
}