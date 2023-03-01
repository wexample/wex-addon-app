#!/usr/bin/env bash

configPathArgs() {
  _NEEDS_APP_LOCATION=true
  # shellcheck disable=SC2034
  _DESCRIPTION="Search into parent tree if current folder is in a wex project. Returns the wex project real path if found"
  # shellcheck disable=SC2034
  _ARGUMENTS=(
    'app_dir ad "Application directory" false'
  )
}

configPath() {
  local CONFIG
  CONFIG="$(wex-exec app::app/locate -ad="${APP_DIR}")${WEX_FILEPATH_REL_CONFIG}"

  if [ -f "${CONFIG}" ]; then
    echo "${APP_DIR}${WEX_FILEPATH_REL_CONFIG}"
  fi
}
