#!/usr/bin/env bash

hookExecArgs() {
  _ARGUMENTS=(
    'args a "Arguments to pass" false'
    'command c "Command name" true'
  )
}

hookExec() {
  wex app::service/exec -c="${COMMAND}" -a="${ARGS}"
  wex app::script/exec -c="${COMMAND}" -a="${ARGS}"
}