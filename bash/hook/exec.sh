#!/usr/bin/env bash

hookExecArgs() {
  _NEEDS_APP_LOCATION=true
  _DESCRIPTION="Execute a command inside service core and app local scripts folder"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'app_dir ad "Application directory" false'
    'args a "Arguments to pass" false'
    'command c "Command name" true'
  )
}

hookExec() {
  wex-exec app::service/exec -c="${COMMAND}" -a="${ARGS}" -ad="${APP_DIR}"
  wex-exec app::script/exec -c="${COMMAND}" -a="${ARGS}" -ad="${APP_DIR}"
}
