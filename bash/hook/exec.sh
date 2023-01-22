#!/usr/bin/env bash

hookExecArgs() {
  _ARGUMENTS=(
    'command c "Command name" true'
  )
}

hookExec() {
  wex app::service/exec -c="${COMMAND}"
  wex app::script/exec -c="${COMMAND}"
}